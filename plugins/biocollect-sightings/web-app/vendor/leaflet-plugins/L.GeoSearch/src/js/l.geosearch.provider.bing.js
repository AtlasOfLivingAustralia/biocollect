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
 * L.GeoSearch.Provider.Bing uses bing geocoding service
 * https://github.com/smeijer/leaflet.control.geosearch
 */

L.GeoSearch.Provider.Bing = L.Class.extend({
    options: {

    },

    initialize: function(options) {
        options = L.Util.setOptions(this, options);
    },

    GetServiceUrl: function (qry) {
        var parameters = L.Util.extend({
            query: qry,
            jsonp: '?'
        }, this.options);

        return 'http://dev.virtualearth.net/REST/v1/Locations'
            + L.Util.getParamString(parameters);
    },

    ParseJSON: function (data) {
        if (data.resourceSets.length == 0 || data.resourceSets[0].resources.length == 0)
            return [];

        var results = [];
        for (var i = 0; i < data.resourceSets[0].resources.length; i++)
            results.push(new L.GeoSearch.Result(
                data.resourceSets[0].resources[i].point.coordinates[1], 
                data.resourceSets[0].resources[i].point.coordinates[0], 
                data.resourceSets[0].resources[i].address.formattedAddress
            ));

        return results;
    }
});