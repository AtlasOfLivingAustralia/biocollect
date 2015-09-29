<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Image viewer</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <r:require module="leaflet" />
    <r:layoutResources disposition="head" />
    <style>
    body {
        padding: 0;
        margin: 0;
    }
    html, body, #image-map {
        height: 100%;
    }

    #image-map {
        width: 100%;
    }
    </style>
</head>
<body>
<div id="image-map"></div>

<r:script>
    // Using leaflet.js to pan and zoom a big image.
    // See also: http://kempe.net/blog/2014/06/14/leaflet-pan-zoom-image.html


    /**
     * Helper function to parse query string (e.g. ?param1=value&parm2=...).
     */
    function parseQueryString(query) {
        var parts = query.split('&');
        var params = {};
        for (var i = 0, ii = parts.length; i < ii; ++i) {
            var param = parts[i].split('=');
            var key = param[0].toLowerCase();
            var value = param.length > 1 ? param[1] : null;
            params[decodeURIComponent(key)] = decodeURIComponent(value);
        }
        return params;
    }

    var queryString = document.location.search.substring(1);
    var params = parseQueryString(queryString);
    var file = 'file' in params ? params.file : '';

    if (!file) alert("No file specified!?");

    // create the slippy map
    var map = L.map('image-map', {
        minZoom: 1,
        maxZoom: 4,
        center: [0, 0],
        zoom: 1,
        crs: L.CRS.Simple
    });

    // need to discover the image dimensions
    var img = new Image();
    img.onload = function() {
        // dimensions of the image
        var w = this.width,
            h = this.height;

        // calculate the edges of the image, in coordinate space
        var southWest = map.unproject([0, h], map.getMaxZoom()-1);
        var northEast = map.unproject([w, 0], map.getMaxZoom()-1);
        var bounds = new L.LatLngBounds(southWest, northEast);

        // add the image overlay,
        // so that it covers the entire map
        L.imageOverlay(file, bounds).addTo(map);

        // tell leaflet that the map is exactly as big as the image
        map.setMaxBounds(bounds);
    };
    img.src = file;

</r:script>
<r:layoutResources disposition="defer" />
</body>
</html>