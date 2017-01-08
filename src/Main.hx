package ;

using StringTools;

class Main {
    public static function main() {
        Generator.initialize_templates('portfolio/layout/', ~/[.]mtt$/);

        var portfolio_data = haxe.Json.parse(sys.io.File.getContent('portfolio/content/portfolio.json'));
        var projects :Array<Dynamic> = portfolio_data.projects;
        trace('Building ${projects.length} projects');
        for (project in projects) {
            var title :String = project.title;
            project.filename = title.trim().replace(' ', '-').toLowerCase() + '.html';
            Generator.output_page(project, 'portfolio/layout/page.mtt', 'portfolio/pages/${project.filename}');
        }

        // create index
        Generator.output_page({ projects: projects }, 'portfolio/layout/index.mtt', 'portfolio/index/index.html');
        Generator.output_page({ projects: projects }, 'portfolio/layout/home.mtt', 'portfolio/index/home.html');
    }
}
