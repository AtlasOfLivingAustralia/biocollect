<script type="text/javascript">
    (function(w, d){
        var b = d.getElementsByTagName('head')[0];
        var s = d.createElement("script");
        var o = "${asset.assetPath(src:'lazyload/lazyload.8.15.2.min.js')}";
        var n = "${asset.assetPath(src:'lazyload/lazyload.10.17.0.min.js')}";
        s.src = "IntersectionObserver" in w ? n : o;
        b.appendChild(s);
    }(window, document));
</script>