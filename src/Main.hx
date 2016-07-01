package;

import Generator;

class Main {
  public static function main() {
    var generator = new Generator();
    generator.titlePostFix = " - Haxewritten";
    
    generator.build(false);
    generator.includeDirectory("assets/includes");
  }
}
