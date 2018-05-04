/* 
    Document   : wms.js
    Created on : Feb 16, 2011, 3:25:27 PM
    Author     : "Gavin Jackson <Gavin.Jackson@csiro.au>"
    Modified   : "Ajay Ranipeta <Ajay.Ranipeta@csiro.au>"
                 - Added better direct tile support rather than ImageMapType
                 - Added tiles loaded checking
                 "Nick dos Remedios (Nick.dosRemedios@csiro.au)"
                 - Modified colour palett to use Google colour scheme via array index
                 - Changed MWS opacity to 0.9
                 "Mark Woolston <Mark.Woolston@csiro.au>"
                 - allow opacity to be specified by the caller


    Refactored code from http://lyceum.massgis.state.ma.us/wiki/doku.php?id=googlemapsv3:home
*/

function bound(value, opt_min, opt_max) {
    if (opt_min != null) value = Math.max(value, opt_min);
    if (opt_max != null) value = Math.min(value, opt_max);
    return value;
}

function degreesToRadians(deg) {
    return deg * (Math.PI / 180);
}

function radiansToDegrees(rad) {
    return rad / (Math.PI / 180);
}

function MercatorProjection() {
    var MERCATOR_RANGE = 256;
    this.pixelOrigin_ = new google.maps.Point(
        MERCATOR_RANGE / 2, MERCATOR_RANGE / 2);
    this.pixelsPerLonDegree_ = MERCATOR_RANGE / 360;
    this.pixelsPerLonRadian_ = MERCATOR_RANGE / (2 * Math.PI);
};

MercatorProjection.prototype.fromLatLngToPoint = function(latLng, opt_point) {
    var me = this;

    var point = opt_point || new google.maps.Point(0, 0);

    var origin = me.pixelOrigin_;
    point.x = origin.x + latLng.lng() * me.pixelsPerLonDegree_;
    // NOTE(appleton): Truncating to 0.9999 effectively limits latitude to
    // 89.189.  This is about a third of a tile past the edge of the world tile.
    var siny = bound(Math.sin(degreesToRadians(latLng.lat())), -0.9999, 0.9999);
    point.y = origin.y + 0.5 * Math.log((1 + siny) / (1 - siny)) * -me.pixelsPerLonRadian_;
    return point;
};

MercatorProjection.prototype.fromDivPixelToLatLng = function(pixel, zoom) {
    var me = this;

    var origin = me.pixelOrigin_;
    var scale = Math.pow(2, zoom);
    var lng = (pixel.x / scale - origin.x) / me.pixelsPerLonDegree_;
    var latRadians = (pixel.y / scale - origin.y) / -me.pixelsPerLonRadian_;
    var lat = radiansToDegrees(2 * Math.atan(Math.exp(latRadians)) - Math.PI / 2);
    return new google.maps.LatLng(lat, lng);
};

MercatorProjection.prototype.fromDivPixelToSphericalMercator = function(pixel, zoom) {
    var me = this;
    var coord = me.fromDivPixelToLatLng(pixel, zoom);
    var r= 6378137.0;
    var x = r* degreesToRadians(coord.lng());
    var latRad = degreesToRadians(coord.lat());
    var y = (r/2) * Math.log((1+Math.sin(latRad))/ (1-Math.sin(latRad)));

    return new google.maps.Point(x,y);
};

function getWMSObject(map, name, baseURL, customParams){
    var tileHeight = 256;
    var tileWidth = 256;
    var opacityLevel = 1.0;
    var isPng = true;
    var minZoomLevel = 2;
    var maxZoomLevel = 28;

    //var baseURL = "";
    var wmsParams = [
    "request=GetMap",
    "service=WMS",
    "version=1.1.1",
    "bgcolor=0xFFFFFF",
    "transparent=TRUE",
    "srs=EPSG:900913", // 3395?
    "width="+ tileWidth,
    "height="+ tileHeight
    ];

    //add additional parameters
    wmsParams = wmsParams.concat(customParams);

    var overlayOptions =
    {
        getTileUrl: function(coord, zoom)
        {
            var lULP = new google.maps.Point(coord.x*256,(coord.y+1)*256);
            var lLRP = new google.maps.Point((coord.x+1)*256,coord.y*256);

            var projectionMap = new MercatorProjection();

            var lULg = projectionMap.fromDivPixelToSphericalMercator(lULP, zoom);
            var lLRg  = projectionMap.fromDivPixelToSphericalMercator(lLRP, zoom);

            var lUL_Latitude = lULg.y;
            var lUL_Longitude = lULg.x;
            var lLR_Latitude = lLRg.y;
            var lLR_Longitude = lLRg.x;

            if (lLR_Longitude < lUL_Longitude){
                lLR_Longitude = Math.abs(lLR_Longitude);
            }
            var urlResult = baseURL + wmsParams.join("&") + "&bbox=" + lUL_Longitude + "," + lUL_Latitude + "," + lLR_Longitude + "," + lLR_Latitude;
            urlResult += "&zoom="+zoom;

            return urlResult;
        },

        tileSize: new google.maps.Size(tileHeight, tileWidth),
        minZoom: minZoomLevel,
        maxZoom: maxZoomLevel,
        opacity: opacityLevel,
        isPng: isPng,
        name: name
    };

    var overlayWMS = new google.maps.ImageMapType(overlayOptions);

    return overlayWMS; 
}

var totalTileCount = 0;
var currTileCount = 0;
function WMSTileLayer(name, baseurl, customParams, fn, opacity){
    this.name = name;
    this.tileSize = new google.maps.Size(256,256);
    this.minZoom = 2;
    this.maxZoom = 17;
    this.isPng = true;
    this.customparams_ = customParams;
    this.baseurl_ = baseurl;
    this.fn_ = fn;
    this.opacity = opacity == undefined ? 0.6 : opacity;
    totalTileCount = 0;
    currTileCount = 0;
}

WMSTileLayer.prototype.getTile = function(a, b, ownerDocument) {
    var src=getWMSTileUrl(a, b, this.baseurl_, this.customparams_);
    var tile = ownerDocument.createElement('div');
    tile.style.width = this.tileSize.width + 'px';
    tile.style.height = this.tileSize.height + 'px';
    tile.style.opacity = this.opacity;
    tile.innerHTML = '<img class="wmstile" src="'+src+'" />';
    totalTileCount++;
    afterFn = this.fn_;
    $('img.wmstile').load(function() {
        currTileCount++;

        if (currTileCount == totalTileCount) {
            afterFn(totalTileCount);
            totalTileCount=0;
            currTileCount=0;
        }
    });
    return tile;
}

function getWMSTileUrl(coord, zoom, baseurl, customParams)
{

    var wmsParams = [
    "REQUEST=GetMap",
    "SERVICE=WMS",
    "VERSION=1.1.1",
    "BGCOLOR=0xFFFFFF",
    "TRANSPARENT=TRUE",
    "SRS=EPSG:900913", // 3395?
    "WIDTH=256",
    "HEIGHT=256"
    ];

    //add additional parameters
    wmsParams = wmsParams.concat(customParams);

    var lULP = new google.maps.Point(coord.x*256,(coord.y+1)*256);
    var lLRP = new google.maps.Point((coord.x+1)*256,coord.y*256);

    var projectionMap = new MercatorProjection();

    var lULg = projectionMap.fromDivPixelToSphericalMercator(lULP, zoom);
    var lLRg  = projectionMap.fromDivPixelToSphericalMercator(lLRP, zoom);

    var lUL_Latitude = lULg.y;
    var lUL_Longitude = lULg.x;
    var lLR_Latitude = lLRg.y;
    var lLR_Longitude = lLRg.x;

    if (lLR_Longitude < lUL_Longitude){
        lLR_Longitude = Math.abs(lLR_Longitude);
    }

    // hack to make this work for wms/reflect as well as occurrences/wms
    var bbox = baseurl.indexOf("reflect") > 0 ? "&BBOX=" : "&bbox=";

    var urlResult = baseurl + wmsParams.join("&") + bbox + lUL_Longitude + "," + lUL_Latitude + "," + lLR_Longitude + "," + lLR_Latitude;
    urlResult += "&zoom="+zoom;

    return urlResult;
}

//Define custom WMS tiled layer
function PIDLayer(pid, wmsServer, style){

    return new google.maps.ImageMapType({
        getTileUrl: function(coord, zoom){
             var wmsParams = [
                "format=image/png",
                "layers=ALA:Objects",
                "REQUEST=GetMap",
                "SERVICE=WMS",
                "VERSION=1.1.0",
                "BGCOLOR=0xFFFFFF",
                "TRANSPARENT=TRUE",
                "SRS=EPSG:900913", // 3395?
                "WIDTH=256",
                "HEIGHT=256",
                "viewparams=s:" + pid
                ];

            var lULP = new google.maps.Point(coord.x*256,(coord.y+1)*256);
            var lLRP = new google.maps.Point((coord.x+1)*256,coord.y*256);

            var projectionMap = new MercatorProjection();

            var lULg = projectionMap.fromDivPixelToSphericalMercator(lULP, zoom);
            var lLRg = projectionMap.fromDivPixelToSphericalMercator(lLRP, zoom);

            var lUL_Latitude = lULg.y;
            var lUL_Longitude = lULg.x;
            var lLR_Latitude = lLRg.y;
            var lLR_Longitude = lLRg.x;
            //GJ: there is a bug when crossing the -180 longitude border (tile does not render) - this check seems to fix it
            if (lLR_Longitude < lUL_Longitude){
                lLR_Longitude = Math.abs(lLR_Longitude);
            }
            var urlResult = wmsServer + "/wms/reflect?" + wmsParams.join("&") + "&bbox=" + lUL_Longitude + "," + lUL_Latitude + "," + lLR_Longitude + "," + lLR_Latitude;
            if (style) {
                urlResult+='&STYLES='+style;
            }

            return urlResult;
        },
        tileSize: new google.maps.Size(256, 256),
        minZoom: 1,
        maxZoom: 16,
        opacity: 0.5,
        isPng: true
    });
}


