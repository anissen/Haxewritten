#!/bin/bash
# fswatch -o assets | xargs -n1 -I{} ./build.sh # WORKS
haxe build.hxml
neko Haxewritten.n
# ./build-site.sh
echo "Watching..."
# fswatch -o assets | xargs -n1 -I{} haxe build.hxml
fswatch -o assets | xargs -n1 -I{} neko Haxewritten.n
# fswatch -o assets | xargs -n1 -I{} ./build-site.sh
