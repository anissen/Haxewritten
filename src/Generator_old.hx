package;
import haxe.Timer;
import haxe.ds.StringMap;
import markdown.AST.ElementNode;
import sys.FileSystem;
import sys.io.File;
import templo.Template;
using StringTools;

class Generator {
  var contentPath = "./assets/content/";
  var outputPath = "./output/";
  public var titlePostFix = "";
  
  var _pages :Array<Page> = new Array<Page>();
  var _folders :StringMap<Array<Page>> = new StringMap<Array<Page>>();
  
  public function new() { }
  
  public function build(doMinify :Bool = false) {
    addGeneralPages();
    addPages();

    var sitemap :Array<Category> = createSitemap();
    
    Timer.measure(function() {
      for (page in _pages) {
        // set the data for the page
        var data = {
          title: '${page.title} $titlePostFix', 
          baseHref: getBaseHref(page),
          pages: _pages,
          sitemap: sitemap,
          currentPage: page,
          pageContent: null
        };
        data.pageContent = (page.pageContent != null ? page.pageContent : getContent(contentPath + page.contentPath, data));

        // execute the template
        var template = Template.fromFile(contentPath + page.templatePath);
        var html = Minifier.removeComments(template.execute(data));
        
        if (doMinify) {
          // strip crap
          var length = html.length;
          html = Minifier.minify(html);
          var newLength = html.length;
          //trace("optimized " + (Std.int(100 / length * (length - newLength) * 100) / 100) + "%");
        }
        
        // write output into file
        var targetDirectory = getDirectoryPath(outputPath + page.outputPath);
        if (!FileSystem.exists(targetDirectory)) {
          FileSystem.createDirectory(targetDirectory);
        }
        File.saveContent(outputPath + page.outputPath, html);
      }
    });

    trace(sitemap.length + " categories");
    trace(_pages.length + " pages done!");
  }
  
  function addPage(page :Page, folder :String = null) {
    _pages.push(page);
    
    if (folder != null) {
      if (!_folders.exists(folder)) {
        _folders.set(folder, []);
      }
      _folders.get(folder).push(page);
    }
  }
  
  function addGeneralPages() {
    var homePage = new Page("layout/layout.mtt", "index.mtt", "index.html")
                          .setTitle("Easy to read Haxe coding examples");
                          
    var errorPage = new Page("layout/layout.mtt", "404.mtt", "404.html")
                          .setTitle("Page not found");
      
    addPage(homePage, "/home");
    addPage(errorPage, "/404");
  }

  function addPages(path :String = "pages/") {
    for (file in FileSystem.readDirectory(contentPath + path)) {
      if (file.charAt(0) == '.') continue;
      if (!FileSystem.isDirectory(contentPath + path + file)) {
        var page = new Page("/layout/page.mtt", path + file, 
                (path + getWithoutExtension(file)).replace(" ", "-").toLowerCase() + ".html");
        page.pageContent = parseMarkdownContent(page, path + file);
        addPage(page, path);
      } else {
        addPages(path + file + "/" );
      }
    }
  }
    
  function replaceTryHaxeTags(content :String) :String {
    //[tryhaxe](http://try.haxe.org/embed/ae6ef)
    return  ~/(\[tryhaxe\])(\()(.+?)(\))/g.replace(content, '<iframe src="$3" class="try-haxe"><a href="$3">Try Haxe!</a></iframe>');
  }
  
  function getBaseHref(page :Page) {
    // if (page.outputPath == "404.html") {
    //   return basePath;
    // }
    var href = [for (s in page.outputPath.split("/")) ".."];
    href[0] = ".";
    return href.join("/");
  }

  static inline function getDirectoryPath(file :String) {
    var paths = file.split("/");
    paths.pop();
    return paths.join("/");
  }
  
  static inline function getExtension(file :String) {
    return file.split(".").pop();
  }
  
  static inline function getWithoutExtension(file :String) {
    var path = file.split(".");
    path.pop();
    return path.join(".");
  }
  
  function getContent(file :String, data :Dynamic) {
    return switch(getExtension(file)) {
      case "md":  parseMarkdownContent(null, file);
      case "mtt": Template.fromFile(file).execute(data);
      default:    File.getContent(file);
    }
  }

  // categorizes the folders 
  function createSitemap() :Array<Category> {
    var sitemap = [];
    for (key in _folders.keys()) {
      var structure = key.split("/");
      structure.pop();
      var id = structure.pop();
      if (key.indexOf("pages/") == 0) {
        sitemap.push(new Category(id.toLowerCase().replace(" ", "-"), id, key, _folders.get(key)));
      }
    }
    return sitemap;
  }
  
  public function parseMarkdownContent(page :Page, file :String) :String {
    var document = new Markdown.Document();
    var markdown = replaceTryHaxeTags(File.getContent(contentPath + file));

    try {
      // replace windows line endings with unix, and split
      var lines = ~/(\r\n|\r)/g.replace(markdown, '\n').split("\n");
      
      // parse ref links
      document.parseRefLinks(lines);
      
      // parse ast
      var blocks = document.parseLines(lines);
      
      // pick first header, use it as title for the page
      if (page != null) {
        for (block in blocks) {
          var el = Std.instance(block, ElementNode);
          if (el != null) {
            if (el.tag == "h1" && !el.isEmpty()) {
              page.title = new markdown.HtmlRenderer().render(el.children);
              break;
            }
          }
        }
      }
      return Markdown.renderHtml(blocks);
    } catch (e:Dynamic){
      return '<pre>$e</pre>';
    }
  }
  
  public function includeDirectory(dir :String, ?path :String) {
    if (path == null) path = outputPath;
    trace("include directory: " + path);
    
    for (file in FileSystem.readDirectory(dir)) {
      var srcPath = '$dir/$file';
      var dstPath = '$path/$file';
      if (FileSystem.isDirectory(srcPath)) {
        FileSystem.createDirectory(dstPath);
        includeDirectory(srcPath, dstPath);
      } else {
        File.copy(srcPath, dstPath);
      }
    }
  }
}

class Page { 
  public var visible :Bool = true;
  public var title :String;
  public var templatePath :String;
  public var contentPath :String;
  public var outputPath :String;
  public var customData :Dynamic;
  public var pageContent :String;
  
  public function new(templatePath :String, contentPath :String, outputPath :String) {
    this.templatePath = templatePath;
    this.contentPath = contentPath;
    this.outputPath = outputPath;
  }
  
  public function setCustomData(data :Dynamic) :Page {
    this.customData = data;
    return this;
  }
  
  public function setTitle(title :String) :Page {
    this.title = title;
    return this;
  }
  
  public function hidden() {
    visible = false;
    return this;
  }
}

class Category {
  public var title:String;
  public var id:String;
  public var folder:String;
  public var pages:Array<Page>;
  
  public function new(id:String, title:String, folder:String, pages:Array<Page>){
    this.id = id;
    this.title = title;
    this.folder = folder;
    this.pages = pages;
  }
  
  public function getPageCount():Int {
    return [for (page in pages) if (page.visible) page].length;
  }
}
