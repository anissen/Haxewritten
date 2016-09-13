package ;

using StringTools;

class Main {
    public static function main() {
        // var contentPath = 'assets';
        Generator.initialize_templates('assets/layout/', ~/[.]mtt$/);

        // var pages = Generator.get_pages(contentPath, ~/[.]md$/);
        // trace(pages.length + ' pages');

        // for (page in pages) {
        //     var filename = page.filepath.replaceExtension('html').humanize();
        //     var context = get_data_from_markdown(page);
        //     trace(filename);
        //     Generator.output_page(context, contentPath + (filename == 'assets/content/index.html' ? 'layout/index.mtt' : 'layout/page.mtt'), 'output/' + filename);
        // }

        var portfolio_data = haxe.Json.parse(sys.io.File.getContent('assets/portfolio/portfolio.json'));
        var projects :Array<Dynamic> = portfolio_data.projects;
        trace('Building ${projects.length} projects');
        for (project in projects) {
            var title :String = project.title;
            var output_filename = title.trim().replace(' ', '-').toLowerCase() + '.html';
            Generator.output_page(project, 'assets/layout/page.mtt', 'output/$output_filename');
        }
    }

    // static function get_data_from_markdown(page :Generator.Page) :Dynamic {
    //     var headerRegEx = ~/<h1>(.*?)<\/h1>/;
    //     if (page.data != null) validate_data(page.data);

    //     return {
    //         title: (headerRegEx.match(page.content) ? headerRegEx.matched(1) : 'Untitled'),
    //         content: ~/&lt;!--([\s\S]*?)-->/gm.replace(page.content, ''),
    //         data: page.data
    //     };
    // }

    // static function validate_data(data :Dynamic) {
    //     if (data.tags == null) throw 'Tags missing from data';
    //     if (data.year == null) throw 'Year missing from data';
    // }
}
