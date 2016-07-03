package;

import sys.FileSystem;
import sys.io.File;
import templo.Template;

using StringTools;

typedef Page = {
    title :String,
    content :String
}

class Test {
    public static function main() {
        // initialize the layout files
        initialize_templates('assets_test/');
        var pages = get_pages('assets_test/');

        trace(get_files('assets_test/', ~/[.]md$/));

         // TODO: Pass to hooks

        for (page in pages) {
            var filename = page.title.trim().replace(' ', '-').toLowerCase() + '.html';
            output_page(page, 'assets_test/layout/page.mtt', 'output_test/' + filename);
        }
    }

    public static function output_page(page :Page, layoutPath :String, outputPath :String) {
        // write output into file
        var targetDirectory = outputPath.substr(0, outputPath.lastIndexOf('/'));
        if (!FileSystem.exists(targetDirectory)) {
            FileSystem.createDirectory(targetDirectory);
        }
        var template = Template.fromFile(layoutPath);
        File.saveContent(outputPath, template.execute(page));
    }

    public static function get_pages(dir :String) :Array<Page> {
        var pages = [];
        for (file in FileSystem.readDirectory(dir)) {
            var path = dir + file;
            if (FileSystem.isDirectory(path)) {
                pages = pages.concat(get_pages(path + '/'));
            } else if (file.indexOf('.md') > 0) { // TODO: Replace with regex
                var page = parse_markdown(File.getContent(path));
                pages.push(page);
            }
        }
        return pages;
    }

    static function initialize_templates(dir :String) {
        for (file in FileSystem.readDirectory(dir)) {
            var path = dir + file;
            trace(path);
            if (FileSystem.isDirectory(path)) {
                initialize_templates(path + '/');
            } else if (file.indexOf('.mtt') > 0) { // TODO: Replace with regex
                Template.fromFile(path);
            }
        }
    }

    static function get_files(dir :String, regex :EReg) :Array<String> {
        var files = [];
        for (file in FileSystem.readDirectory(dir)) {
            var path = dir + file;
            if (FileSystem.isDirectory(path)) {
                files = files.concat(get_files(path + '/', regex));
            } else if (regex.match(path)) {
                files.push(path);
            }
        }
        return files;
    }

    static function parse_markdown(content :String) :Page {
        var document = new Markdown.Document();
        var page = { title: '', content: '' };

        try {
            // replace windows line endings with unix, and split
            var lines = ~/(\r\n|\r)/g.replace(content, '\n').split("\n");

            // parse ref links
            document.parseRefLinks(lines);

            // parse ast
            var blocks = document.parseLines(lines);

            // pick first header, use it as title for the page
            for (block in blocks) {
                var el = Std.instance(block, markdown.AST.ElementNode);
                if (el != null) {
                    if (el.tag == "h1" && !el.isEmpty()) {
                        page.title = new markdown.HtmlRenderer().render(el.children);
                        break;
                    }
                }
            }
            page.content = Markdown.renderHtml(blocks);
        } catch (e:Dynamic){
            page.content = '<pre>$e</pre>';
        }

        return page;
    }
}

