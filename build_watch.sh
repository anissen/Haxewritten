haxe build.hxml
neko Haxewritten.n

echo "Watching..."
fswatch -o portfolio | xargs -n1 -I{} neko Haxewritten.n
