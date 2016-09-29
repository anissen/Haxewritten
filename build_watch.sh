haxe build.hxml
neko Haxewritten.n

echo "Watching..."
fswatch -o portfolio --exclude portfolio/pages | xargs -n1 -I{} neko Haxewritten.n
