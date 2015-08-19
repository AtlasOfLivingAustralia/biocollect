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

/*
 * L.Geocoding
 */

L.Geocoding = L.Control.extend({
    options: {
        provider: 'osm'
        , i18n: {
            cadnum : '<b>Cadastral number</b>: '
            , objectaddress : '<b>Object address</b>: '
            , area : '<b>Area (sq. m)</b>: '
            , cost : '<b>Cadastral value (rub.)</b>: '
            , name : '<b>Name</b>: '
        }
        , apikeys : {
        }
    }

    , initialize: function (options) {
        this.setOptions(options);
        var providers= {
            'osm' : this._osm
            , 'google' : this._google
            , 'bing' : this._bing
            , 'esri' : this._esri
            , 'geonames' : this._geonames
            , 'mapquest' : this._mapquest
            , 'nokia' : this._nokia
            , 'yandex' : this._yandex
            , 'rucadastre' : this._rucadastre
        }
        this.options.providers = L.extend({}, providers, this.options.providers);
    }

    , onAdd: function (map) {
        this._map = map;
        return L.DomUtil.create('div', 'leaflet-geocoding');;
    }

    , onRemove: function (map) {
    }

    , setOptions:function (options) {
        var providers = this.options.providers;

        L.setOptions(this, options);
        this.options.providers = L.extend({}, providers, this.options.providers);
        return this;
    }

    , geocode:function(query) {
        var that=this
            , provider=this.options.provider
            , geoFn = this.options.providers[provider]
            , geoFnProxy=$.proxy(geoFn, that);

            geoFnProxy({
                query : query
                , bounds : that._map.getBounds()
                , zoom : that._map.getZoom()
                , cb : $.proxy(that._zoomto, that)
            });
    }

    , _zoomto: function(georesult) {
        var map = this._map
            , popup=new L.Popup();

        map.fitBounds(georesult.bounds);
        //L.rectangle(georesult.bounds, {color: "#ff7800", weight: 1}).addTo(map);
        popup.setLatLng(georesult.latlng).setContent(georesult.content).addTo(map);
        map.openPopup(popup);
    }

    , _osm: function(arg) {
        var that = this
            , query = arg.query
            , cb = arg.cb;

        $.ajax({
            url : 'http://nominatim.openstreetmap.org/search'
            , dataType : 'jsonp'
            , jsonp : 'json_callback'
            , data : {
                'q' : query
                , 'format' : 'json'
            }
        })
        .done(function(data){
            if (data.length>0) {
                var res=data[0];
                cb({
                    query : query
                    , content : res.display_name
                    , latlng : new L.LatLng(res.lat, res.lon)
                    , bounds : new L.LatLngBounds([res.boundingbox[0], res.boundingbox[2]], [res.boundingbox[1], res.boundingbox[3]])
                });
            }
        });
    }

    , _google: function(arg) {
        var that = this
            , query = arg.query
            , cb = arg.cb
            , loadAPI = function(onloadFn) {
                if ((typeof google === 'undefined') || (typeof google.maps.Geocoder==='undefined')) {
                    $.getScript('https://www.google.com/jsapi', function()
                    {
                        google.load('maps', '3', {
                            other_params: 'sensor=false'
                            , callback: function() {
                                onloadFn();
                            }
                        });
                    });
                } else onloadFn();
            };

            loadAPI( function () {
                var geocoder = new google.maps.Geocoder();
                geocoder.geocode( { 'address': query}, function(results, status) {
                    if (status == google.maps.GeocoderStatus.OK) {
                        var res=results[0];
                        cb({
                            query : query
                            , content : res.formatted_address
                            , latlng : new L.LatLng(res.geometry.location.lat(), res.geometry.location.lng())
                            , bounds : new L.LatLngBounds([
                                res.geometry.bounds.getSouthWest().lat(), res.geometry.bounds.getSouthWest().lng()
                                ], [
                                res.geometry.bounds.getNorthEast().lat(), res.geometry.bounds.getNorthEast().lng()
                            ])
                        });
                    }
                });
            });
    }

    , _bing: function(arg) {
        var that = this
            , query = arg.query
            , cb = arg.cb;

        $.ajax({
            url : 'http://dev.virtualearth.net/REST/v1/Locations'
            , dataType : 'jsonp'
            , jsonp : 'jsonp'
            , data : {
                'q' : query
                , 'key' : that.options.apikeys['bing']
            }
        })
        .done(function(data){
            if ((data.resourceSets.length>0) && (data.resourceSets[0].resources.length>0)) {
                var res=data.resourceSets[0].resources[0];
                cb({
                    query : query
                    , content : res.name
                    , latlng : new L.LatLng(res.point.coordinates[0], res.point.coordinates[1])
                    , bounds : new L.LatLngBounds([res.bbox[0], res.bbox[1]], [res.bbox[2], res.bbox[3]])
                });
            }
        });
    }

    , _esri: function(arg) {
        var that = this
            , query = arg.query
            , cb = arg.cb;

        $.ajax({
            url : 'http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/find'
            , dataType : 'jsonp'
            , data : {
                'text' : query
                , 'f' : 'pjson'
            }
        })
        .done(function(data){
            if (data.locations.length>0) {
                var res=data.locations[0];
                cb({
                    query : query
                    , content : res.name
                    , latlng : new L.LatLng(res.feature.geometry.y, res.feature.geometry.x)
                    , bounds : new L.LatLngBounds([res.extent.ymin, res.extent.xmin], [res.extent.ymax, res.extent.xmax])
                });
            }
        });
    }

    , _geonames: function(arg) {
        var that = this
            , query = arg.query
            , cb = arg.cb;

        $.ajax({
            url : 'http://ws.geonames.org/searchJSON'
            , dataType : 'jsonp'
            , data : {
                'q' : query
                , 'style' : 'full'
                , 'maxRows' : '1'
            }
        })
        .done(function(data){
            if (data.geonames.length > 0) {
                var res=data.geonames[0];
                cb({
                    query : query
                    , content : res.name
                    , latlng : new L.LatLng(res.lat, res.lng)
                    , bounds : new L.LatLngBounds([res.bbox.south, res.bbox.west], [res.bbox.north, res.bbox.east])
                });
            }
        });
    }

    , _mapquest: function(arg) {
        var that = this
            , query = arg.query
            , cb = arg.cb;

        $.ajax({
            url : 'http://www.mapquestapi.com/geocoding/v1/address'
            , dataType : 'jsonp'
            , data : {
                'location' : query
                , 'key' : that.options.apikeys['mapquest']
                , 'outFormat' : 'json'
                , 'maxResults' : '1'
            }
        })
        .done(function(data){
            if (data.results.length > 0 && data.results[0].locations.length > 0) {
                var res=data.results[0]
                    , location = res.locations[0].latLng;
                cb({
                    query : query
                    , content : res.providedLocation.location
                    , latlng : new L.LatLng(location.lat, location.lng)
                    , bounds : new L.LatLngBounds([location.lat-1, location.lng-1], [location.lat+1, location.lng+1])
                });
            }
        });
    }

    , _nokia: function(arg) {
        var that = this
            , query = arg.query
            , cb = arg.cb;

        $.ajax({
            url : 'http://geo.nlp.nokia.com/search/6.2/geocode.json'
            , dataType : 'jsonp'
            , jsonp : 'jsoncallback'
            , data : {
                'searchtext' : query
                , 'app_id' : that.options.apikeys['nokia']
            }
        })
        .done(function(data){
            if (data.Response.View.length > 0 && data.Response.View[0].Result.length > 0) {
                var res=data.Response.View[0].Result[0];
                cb({
                    query : query
                    , content : res.name
                    , latlng : new L.LatLng(res.Location.DisplayPosition.Latitude, res.Location.DisplayPosition.Longitude)
                    , bounds : new L.LatLngBounds([res.extent.ymin, res.extent.xmin], [res.extent.ymax, res.extent.xmax])
                });
            }
        });
    }

    , _yandex: function(arg) {
        var that = this
            , query = arg.query
            , cb = arg.cb;
        // http://api.yandex.ru/maps/doc/geocoder/desc/concepts/input_params.xml
        $.ajax({
            url : 'http://geocode-maps.yandex.ru/1.x/'
            , dataType : 'jsonp'
            , data : {
                'geocode' : query
                , 'format' : 'json'
            }
        })
        .done(function(data){
            if (data.response.GeoObjectCollection.featureMember.length>0) {
                var res=data.response.GeoObjectCollection.featureMember[0].GeoObject
                    , points = res.Point.pos.split(' ')
                    , lowerCorner = res.boundedBy.Envelope.lowerCorner.split(' ')
                    , upperCorner = res.boundedBy.Envelope.upperCorner.split(' ')
                    , content = res.metaDataProperty.GeocoderMetaData.text;

                cb({
                    query : query
                    , content : content
                    , latlng : new L.LatLng(points[1], points[0])
                    , bounds : new L.LatLngBounds([lowerCorner[1], lowerCorner[0]], [upperCorner[1], upperCorner[0]])
                });
            }
        });
    }

    , _rucadastre: function(arg) {
        var that=this
        , cadnum = arg.query
        , cadparts = cadnum.split(':')
        , cadjoin = cadparts.join('')
        , cb = arg.cb
        , bounds = arg.bounds
        , unproject = function (x, y) {
            var earthRadius = 6378137;
            return L.CRS.EPSG900913.projection.unproject((new L.Point(x, y)).divideBy(earthRadius));
        }
        , i18n = that.options.i18n
        , ajaxopt
        , ajaxtype
        , zoom;

        if (cadparts.length==4) {
            ajaxtype='find';
            ajaxopt = {
                url : 'http://maps.rosreestr.ru/arcgis/rest/services/Cadastre/CadastreSelected/MapServer/exts/GKNServiceExtension/online/parcel/find'
                , dataType : 'jsonp'
                , data : {
                    'f' : 'json'
                    , 'cadNum' : cadnum
                    , 'onlyAttributes' : 'false'
                    , 'returnGeometry' : 'true'
                }
            }
        } else {
            var ajaxtype='query';

            if (cadjoin.length < 3) {
                zoom = 1;
            } else if (cadjoin.length < 5) {
                zoom = 7;
            } else {
                zoom = 12;
            }

            ajaxopt = {
                url : 'http://maps.rosreestr.ru/arcgis/rest/services/Cadastre/CadastreSelected/MapServer/'+zoom+'/query'
                , dataType : 'jsonp'
                , data : {
                    'f' : 'json'
                    , 'where' : 'PKK_ID like \''+cadjoin+'%\''
                    , 'returnGeometry' : 'true'
                    , 'spatialRel' : 'esriSpatialRelIntersects'
                    , 'outFields' : '*'
                }
            }
        }


        $.ajax(ajaxopt)
        .done(function(data){
            if (data.features.length>0) {
                var res=data.features[0].attributes
                    , content;

                if (ajaxtype=='find') {
                    content = ''
                        + i18n.cadnum + res['CAD_NUM'] + '<br/>'
                        + i18n.objectaddress + res['OBJECT_ADDRESS'] + '<br/>'
                        + i18n.area + res['AREA_VALUE'] + '<br/>'
                        + i18n.cost + res['CAD_COST'] + '<br/>'
                } else {
                    content = ''
                        + i18n.cadnum + res['CAD_NUM'] + '<br/>'
                        + (zoom < 12 ? i18n.name + res['NAME'] + '<br/>' : '')
                }

                cb({
                    query : arg.query
                    , content : content
                    , latlng : unproject(res['XC'],res['YC'])
                    , bounds : new L.LatLngBounds(unproject(res['XMIN'],res['YMIN']), unproject(res['XMAX'],res['YMAX']))
                });
            }
        });
    }

});
