$(window).load(function(){
/*!
 *
 * jQuery collagePlus Plugin v0.3.3
 * https://github.com/ed-lea/jquery-collagePlus
 *
 * Copyright 2012, Ed Lea twitter.com/ed_lea
 *
 * built for http://qiip.me
 *
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.opensource.org/licenses/GPL-2.0
 *
 */
;(function(e){e.fn.collagePlus=function(t){function n(t,n,i,s){var o=i.padding*(t.length-1)+t.length*t[0][3],u=i.albumWidth-o,a=u/(n-o),f=o,l=n<i.albumWidth?true:false;for(var c=0;c<t.length;c++){var h=e(t[c][0]),p=Math.floor(t[c][1]*a),d=Math.floor(t[c][2]*a),v=!!(c<t.length-1);if(i.allowPartialLastRow===true&&l===true){p=t[c][1];d=t[c][2]}f+=p;if(!v&&f<i.albumWidth){if(i.allowPartialLastRow===true&&l===true){p=p}else{p=p+(i.albumWidth-f)}}p--;var m=h.is("img")?h:h.find("img");m.width(p);if(!h.is("img")){h.width(p+t[c][3])}m.height(d);if(!h.is("img")){h.height(d+t[c][4])}r(h,v,i);m.one("load",function(e){return function(){if(i.effect=="default"){e.animate({opacity:"1"},{duration:i.fadeSpeed})}else{if(i.direction=="vertical"){var t=s<=10?s:10}else{var t=c<=9?c+1:10}e.removeClass(function(e,t){return(t.match(/\beffect-\S+/g)||[]).join(" ")});e.addClass(i.effect);e.addClass("effect-duration-"+t)}}}(h)).each(function(){if(this.complete)e(this).trigger("load")})}}function r(e,t,n){var r={"margin-bottom":n.padding+"px","margin-right":t?n.padding+"px":"0px",display:n.display,"vertical-align":"bottom",overflow:"hidden"};return e.css(r)}function i(t){$img=e(t);var n=new Array;n["w"]=parseFloat($img.css("border-left-width"))+parseFloat($img.css("border-right-width"));n["h"]=parseFloat($img.css("border-top-width"))+parseFloat($img.css("border-bottom-width"));return n}return this.each(function(){var r=0,s=[],o=1,u=e(this);e.fn.collagePlus.defaults.albumWidth=u.width();e.fn.collagePlus.defaults.padding=parseFloat(u.css("padding-left"));e.fn.collagePlus.defaults.images=u.children();var a=e.extend({},e.fn.collagePlus.defaults,t);a.images.each(function(t){var u=e(this),f=u.is("img")?u:e(this).find("img");var l=typeof f.data("width")!="undefined"?f.data("width"):f.width(),c=typeof f.data("height")!="undefined"?f.data("height"):f.height();var h=i(f);f.data("width",l);f.data("height",c);var p=Math.ceil(l/c*a.targetHeight),d=Math.ceil(a.targetHeight);s.push([this,p,d,h["w"],h["h"]]);r+=p+h["w"]+a.padding;if(r>a.albumWidth&&s.length!=0){n(s,r-a.padding,a,o);delete r;delete s;r=0;s=[];o+=1}if(a.images.length-1==t&&s.length!=0){n(s,r,a,o);delete r;delete s;r=0;s=[];o+=1}})})};e.fn.collagePlus.defaults={targetHeight:400,fadeSpeed:"fast",display:"inline-block",effect:"default",direction:"vertical",allowPartialLastRow:false}})(jQuery);

    (function(a){a.fn.removeWhitespace=function(){this.contents().filter(function(){return this.nodeType==3&&!/\S/.test(this.nodeValue)}).remove();return this}})(jQuery);

/*!
 *
 * jQuery collageCaption Plugin v0.1.1
 * extra for collagePlus plugin
 * https://github.com/ed-lea/jquery-collagePlus
 *
 * Copyright 2012, Ed Lea twitter.com/ed_lea
 *
 * built for http://qiip.me
 *
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.opensource.org/licenses/GPL-2.0
 *
 */
;(function(e){e.fn.collageCaption=function(t){var n={images:e(this).children(),background:"black",opacity:"0.8",speed:100,cssClass:"Caption"};var r=e.extend({},n,t);return this.each(function(){var t=0,n=[];r.images.each(function(t){var n=e(this);if(typeof n.data("caption")=="undefined"){return}var i='<div class="'+r.cssClass+'" style="position:relative;"><div class="Caption_Background" style="background-color:'+r.background+";opacity:"+r.opacity+';position:relative;top:0;"></div><div class="Caption_Content" style="position:relative;">'+n.data("caption")+"</div></div>";n.append(i);var s=n.find("."+r.cssClass),o=n.find(".Caption_Background"),u=n.find(".Caption_Content");var a=s.height();o.height(a);u.css("top","-"+a+"px");n.bind({mouseenter:function(e){s.animate({top:-1*a},{duration:r.speed,queue:false})},mouseleave:function(e){s.animate({top:0},{duration:r.speed,queue:false})}})});return this})}})(jQuery);


// All images need to be loaded for this plugin to work so
// we end up waiting for the whole window to load in this example
// $(window).load(function () {
//     $(document).ready(function(){
//         collage();
//         $('.Collage').collageCaption();
//     });
// });


// Here we apply the actual CollagePlus plugin
// function collage() {
    $('.Collage').removeWhitespace().collagePlus(
        {
            'fadeSpeed'     : 2000,
            'targetHeight'  : 400,
            'effect'        : 'effect-2',
            'direction'     : 'vertical',
            'allowPartialLastRow' : true
        }
    ).collageCaption();
// };
});

// This is just for the case that the browser window is resized
var resizeTimer = null;
$(window).bind('resize', function() {
    // hide all the images until we resize them
    $('.Collage .Image_Wrapper').css("opacity", 0);
    // set a timer to re-apply the plugin
    if (resizeTimer) clearTimeout(resizeTimer);
    resizeTimer = setTimeout(collage, 200);
});
