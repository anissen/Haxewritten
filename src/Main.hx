package;

class Main {
    public static function main() {
        var contentPath = 'assets/';
        Generator.initialize_templates(contentPath, ~/[.]mtt$/);

        // function get_files(sitemap :Generator.Tree) :Array<Generator.FilePath> {
        //     return switch (sitemap) {
        //         case Resource(path): [path];
        //         case Directory(path, list): var files = []; for (l in list) files = files.concat(get_files(l)); files;
        //     }
        // }

        // Generator.do_everything(contentPath, function(page) {
        //     trace(page);    
        // });

        // var files = Generator.get_files(contentPath, ~/.*/);

        // // var files = get_files(Generator.sitemap(contentPath));

        // trace('Load layouts');
        // for (f in files) trace(f);

        // trace('Process files');
        // files.reverse();
        // for (f in files) trace(f);

        // trace('Process pages');
        // print_sitemap2(Generator.sitemap(contentPath));

        var pages = Generator.get_pages(contentPath, ~/[.]md$/); // maybe return a heirarchical structure instead, Generator.get_resources()
        trace(pages.length + ' pages');

        // TODO: Try with planetarium
        // TODO: Minimize html
        // TODO: Replace tags (e.g. youtube link with embedded youtube)
        // TODO: Expose data from pages/* to e.g. index.mtt

        // Steps:
        //  1. get resources (markdown, json, pictures, etc)
        //  2. process resources (change markdown, read data from json, etc)
        //  3. generate html from markdown and data
        //  4. output html and resources 

        for (page in pages) {
            // page = minify(extract_data(remove_comments(page));
            var filename = page.filepath.replaceExtension('html').humanize();
            var context = get_data_from_markdown(page);
            trace(filename);
            Generator.output_page(context, contentPath + (filename == 'assets/index.html' ? 'layout/index.mtt' : 'layout/page.mtt'), 'output/' + filename);
        }
    }

    static function get_data_from_markdown(page :Generator.Page) :Dynamic {
        var headerRegEx = ~/<h1>(.*?)<\/h1>/;
        
        if (page.data != null) validate_data(page.data);

        return {
            title: (headerRegEx.match(page.content) ? headerRegEx.matched(1) : 'Untitled'),
            content: ~/&lt;!--([\s\S]*?)-->/gm.replace(page.content, ''),
            data: page.data
        };
    }

    static function validate_data(data :Dynamic) {
        if (data.tags == null) throw 'Tags missing from data';
        if (data.year == null) throw 'Year missing from data';
    }
}
