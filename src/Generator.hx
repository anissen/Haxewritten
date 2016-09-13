package;

import sys.FileSystem;
import sys.io.File;
import templo.Template;

using StringTools;

typedef Page = {
    filepath :FilePath,
    content :String,
    data :Dynamic
}

abstract FilePath(String) from String to String {
    public inline function new(path :String) { this = path; }
    public function withoutExtension() :FilePath { return this.substr(0, this.lastIndexOf('.')); }
    public function replaceExtension(ext :FilePath) :FilePath { return withoutExtension() + '.$ext'; }
    public function withoutFileName() :FilePath { return this.substr(0, this.lastIndexOf('/')); }
    public function humanize() :FilePath { return this.trim().replace(' ', '-').toLowerCase(); }
}

class Generator {
    public static function initialize_templates(dir :FilePath, regex :EReg) {
        for (filepath in get_files(dir, regex)) Template.fromFile(filepath);
    }

    public static function output_page(data :Dynamic, layoutPath :FilePath, outputPath :FilePath) {
        if (!FileSystem.exists(outputPath.withoutFileName())) FileSystem.createDirectory(outputPath.withoutFileName());
        var template = Template.fromFile(layoutPath);
        File.saveContent(outputPath, template.execute(data));
    }

    public static function to_markdown(content :String) :String {
        var parser = new commonmark.Parser();
        var ast = parser.parse(content);
        var writer = new commonmark.HtmlRenderer();
        return writer.render(ast);
    }

    public static function get_pages(dir :FilePath, regex :EReg) :Array<Page> {
        return [ for (filepath in get_files(dir, regex, true)) {
            filepath: filepath,
            content: to_markdown(File.getContent(filepath)),
            data: (FileSystem.exists(filepath.replaceExtension('json')) ? parse_json_data(File.getContent(filepath.replaceExtension('json'))) : null)
        } ];
    }

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
