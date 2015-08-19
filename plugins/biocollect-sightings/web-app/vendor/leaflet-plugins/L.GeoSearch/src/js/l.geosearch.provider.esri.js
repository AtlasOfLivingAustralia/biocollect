/*
 * Copyright (C) 2014 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 */

/**
 * L.Control.GeoSearch - search for an address and zoom to it's location
 * L.GeoSearch.Provider.Esri uses arcgis geocoding service
 * https://github.com/smeijer/leaflet.control.geosearch
 */

L.GeoSearch.Provider.Esri = L.Class.extend({
    options: {

    },

    initialize: function(options) {
        options = L.Util.setOptions(this, options);
    },
    
    GetServiceUrl: function (qry) {
        var parameters = L.Util.extend({
            text: qry,
            f: 'pjson'
        }, this.options);

        return location.protocol 
            + '//geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/find'
            + L.Util.getParamString(parameters);
    },

    ParseJSON: function (data) {
        if (data.locations.length == 0)
            return [];
        
        var results = [];
        for (var i = 0; i < data.locations.length; i++)
            results.push(new L.GeoSearch.Result(
                data.locations[i].feature.geometry.x, 
                data.locations[i].feature.geometry.y, 
                data.locations[i].name
            ));
        
        return results;
    }
});
