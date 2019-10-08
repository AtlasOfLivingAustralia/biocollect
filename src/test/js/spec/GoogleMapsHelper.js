
// Stub the Google Maps API
google = { maps : {
    drawing : { OverlayType: {RECTANGLE:'rectangle'} },
    MVCArray: function() { return { push: function(){} } },
    LatLng: function() {},
    geometry: { spherical : { computeArea : function() {} } }
} };



var Bounds = function(ne, sw) {

    return {
        getSouthWest : function() {
            return {
                lat: function() {
                    return sw[1];
                },
                lng: function() {
                    return sw[0];
                }
            }
        },
        getNorthEast : function() {
            return {
                lat: function() {
                    return ne[1];
                },
                lng: function() {
                    return ne[0];
                }
            }
        }
    };

};
