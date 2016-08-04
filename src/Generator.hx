package;

import sys.FileSystem;
import sys.io.File;
import templo.Template;

using StringTools;

typedef Page = {
    filepath :FilePath,
    content :String,
    data :Dynamic,
    // subpages :Array<Page>
}

// enum Tree {
//     Directory(path :FilePath, content: Array<Tree>);
//     Resource(path :FilePath /* type enum + data ? */);
// }

abstract FilePath(String) from String to String {
    public inline function new(path :String) { this = path; }
    public function withoutExtension() :FilePath { return this.substr(0, this.lastIndexOf('.')); }
    public function replaceExtension(ext :FilePath) :FilePath { return withoutExtension() + '.$ext'; }
    public function withoutFileName() :FilePath { return this.substr(0, this.lastIndexOf('/')); }
    public function humanize() :FilePath { return this.trim().replace(' ', '-').toLowerCase(); }
}

class Generator {
    // public static function get_page_heirarchy(sitemap :Generator.Tree) :Array<Path> {
    //     return switch (sitemap) {
    //         case Resource(path): [{
    //             filepath: path,
    //             content: Markdown.markdownToHtml(File.getContent(filepath)),
    //             (FileSystem.exists(filepath.replaceExtension('json')) ? parse_json_data(File.getContent(filepath.replaceExtension('json'))) : null)
    //         }];
    //         case Directory(path, list): var files = []; for (l in list) files = files.concat(get_files(l)); files;
    //     }
    // }

    public static function do_everything(contentPath :String, handler :Page->Void) {
        trace('Load layouts');
        for (layout in Generator.get_files(contentPath, ~/[.]mtt$/)) {
            trace('Initializing layout $layout');
            Template.fromFile(layout);
        }

        for (page in get_pages(contentPath, ~/[.]md$/)) {
            handler(page);
        }
    }

    public static function initialize_templates(dir :FilePath, regex :EReg) {
        for (filepath in get_files(dir, regex)) Template.fromFile(filepath);
    }

    public static function output_page(data :Dynamic, layoutPath :FilePath, outputPath :FilePath) {
        if (!FileSystem.exists(outputPath.withoutFileName())) FileSystem.createDirectory(outputPath.withoutFileName());
        var template = Template.fromFile(layoutPath);
        File.saveContent(outputPath, template.execute(data));
    }

    // public static function output_resource(path :FilePath, outputPath :FilePath) {
    //     if (!FileSystem.exists(outputPath.withoutFileName())) FileSystem.createDirectory(outputPath.withoutFileName());
    //     File.copy(path, outputPath);
    // }

    public static function get_pages(dir :FilePath, regex :EReg) :Array<Page> {
        return [ for (filepath in get_files(dir, regex, true)) {
            filepath: filepath,
            content: Markdown.markdownToHtml(File.getContent(filepath)),
            data: (FileSystem.exists(filepath.replaceExtension('json')) ? parse_json_data(File.getContent(filepath.replaceExtension('json'))) : null)
        } ];
    }

    // public static function sitemap(path :FilePath, regex :EReg) :Tree {
    //     if (!FileSystem.isDirectory(path)) return Resource(path);
    //     // return Directory(path, [ for (p in FileSystem.readDirectory(path)) sitemap('$path/$p'.replace('//', '/')) ]);
    //     var resources = [];
    //     var directories = [];
    //     for (file in FileSystem.readDirectory(path)) {
    //         var p = '$path/$file'.replace('//', '/');
    //         if (FileSystem.isDirectory(p)) {
    //             directories.push(p);
    //         } else if (regex.match(p)) {
    //             resources.push(p);
    //         }
    //     }
    //     return Directory(path, [ for (p in resources.concat(directories)) sitemap(p, regex) ]); // resources first, then directories
    // }

    static public function get_files(dir :FilePath, regex :EReg, ?reverseOrder :Bool = false) :Array<FilePath> {
        var files = [];
        var directories = [];
        for (file in FileSystem.readDirectory(dir)) {
            var path = dir + file;
            if (FileSystem.isDirectory(path)) {
                directories.push(path);
            } else if (regex.match(path)) {
                files.push(path);
            }
        }
        for (directory in directories) {
            files = files.concat(get_files(directory + '/', regex));
        }
        if (reverseOrder) files.reverse();
        return files;
    }

    static function parse_json_data(content :String) :Dynamic {
        return haxe.Json.parse(content);
    }
}

/*
class MyGenerator {
    var contentPath = 'assets/content/';

    public function new(contentPath :String, outputPath) {
        this.contentPath = contentPath;
        Generator.initialize_templates(contentPath, ~/[.]mtt$/);
    }

    public function do_it() {
        var pages = Generator.get_pages(contentPath, ~/[.]md$/); // maybe return a heirarchical structure instead, Generator.get_resources()
        trace(pages.length + ' pages');

        for (page in pages) {
            // page = minify(extract_data(remove_comments(page));
            var filename = page.filepath.replaceExtension('html').humanize();
            var context = get_data_from_markdown(page);

            // var comments = [];
            // var withoutComments = ~/<!--([\s\S]*?)-->/gm.map(context.content, function(r) {
            //     comments.push(r.matched(0).replace('<!--', '').replace('-->', '').trim());
            //     return ''; // remove comments
            // });
            // trace('comments: $comments');
            
            // var simpleCommentCollector = new EReg('<!--(.*?)-->', 'g');
            // trace(simpleCommentCollector.match(context.content));
            // simpleCommentCollector.map(context.content, function(r) {
            //     var match = r.matched(0);
            //     trace('simpleCollector match: $match');
            //     return match;
            // });

            Generator.output_page(context, contentPath + 'layout/page.mtt', 'output_test/' + filename);
        }
    }
}
*/
