var Biocollect = Biocollect || {};

Biocollect.MapUtilities = {
    /**
     * Converts a 'feature' object from Ecodata into valid GeoJSON that can be handled by the ALA.Map.
     *
     * @param feature
     * @returns {{type: string, geometry: {}, properties: {}}}
     */
    featureToValidGeoJson: function(feature) {
        var geoJson = {
            type: "Feature",
            geometry: {},
            properties: {}
        };

        if (feature.type.toLowerCase() == 'pid') {
            geoJson.geometry.type = "Polygon";
            geoJson.geometry.coordinates = [];
            geoJson.properties.pid = feature.pid;
        } else if (feature.type.toLowerCase() == "circle") {
            geoJson.geometry.type = ALA.MapConstants.DRAW_TYPE.POINT_TYPE;
            geoJson.geometry.coordinates = feature.centre;
            geoJson.properties.point_type = ALA.MapConstants.DRAW_TYPE.CIRCLE_TYPE;
            geoJson.properties.radius = feature.radius;
        } else if (feature.type.toLowerCase() == "point") {
            geoJson.geometry.type = ALA.MapConstants.DRAW_TYPE.POINT_TYPE;
            geoJson.geometry.coordinates = feature.centre;
        } else if (feature.type.toLowerCase() == "polygon") {
            geoJson.geometry.type = ALA.MapConstants.DRAW_TYPE.POLYGON_TYPE;
            geoJson.geometry.coordinates = feature.coordinates;
            geoJson.properties.radius = feature.radius;
        }

        return geoJson;
    }
};