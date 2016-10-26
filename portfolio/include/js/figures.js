var colors = ['#001F3F', '#0074D9', '#7FDBFF', '#39CCCC', '#3D9970', '#2ECC40', '#01FF70', '#FFDC00', '#FF851B', '#FF4136', '#F012BE', '#B10DC9', '#85144B'];

var seed = 2;
function random() {
    var x = Math.sin(seed++) * 10000;
    return x - Math.floor(x);
}

var elements = document.getElementsByTagName('figure');
for (var i = 0; i < elements.length; i++) {
  elements[i].setAttribute('style', 'background-color:' + colors[Math.floor(random() * colors.length)] + ';');
}
