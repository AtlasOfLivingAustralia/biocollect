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
 * L.GeoSearch.Provider.Nokia uses Nokia geocoding service
 * https://github.com/smeijer/leaflet.control.geosearch
 */

L.GeoSearch.Provider.Nokia = L.Class.extend({
    options: {

    },

    initialize: function(options) {
        options = L.Util.setOptions(this, options);
    },

    GetServiceUrl: function (qry) {
        var parameters = L.Util.extend({
            searchtext: qry,
            jsoncallback: '?'
        }, this.options);

        return 'http://geo.nlp.nokia.com/search/6.2/geocode.json'
            + L.Util.getParamString(parameters);
    },

    ParseJSON: function (data) {
        if (data.Response.View.length == 0 || data.Response.View[0].Result.length == 0)
            return [];

        var results = [];
        for (var i = 0; i < data.Response.View[0].Result.length; i++)
            results.push(new L.GeoSearch.Result(
                data.Response.View[0].Result[i].Location.DisplayPosition.Longitude, 
                data.Response.View[0].Result[i].Location.DisplayPosition.Latitude, 
                data.Response.View[0].Result[i].Location.Address.Label
            ));

        return results;
    }
});