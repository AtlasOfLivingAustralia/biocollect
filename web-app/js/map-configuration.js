/*
 * Copyright (C) 2017 Atlas of Living Australia
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
 * 
 * Created by Temi on 8/12/17.
 */
function MapConfiguration(config, project)
{
    var self = this;
    var sites = project.sites || [],
        defaults = {
            allowPolygons: true,
            allowPoints: true,
            allowAdditionalSurveySites: false,
            selectFromSitesOnly: false
        };
    config = config || {};
    config = $.extend(defaults, config);
    project.sites = project.sites || [];

    self.allowPolygons = ko.observable(config.allowPolygons);
    self.allowPoints = ko.observable(config.allowPoints);
    self.allowAdditionalSurveySites = ko.observable(config.allowAdditionalSurveySites);
    self.selectFromSitesOnly = ko.observable(config.selectFromSitesOnly);
    self.defaultZoomArea = ko.observable(config.defaultZoomArea || project.projectSiteId);
    self.baseLayersName = ko.observable(config.baseLayersName);
    self.sites = ko.observableArray(config.sites || []);
    self.toJS = function () {
        return ko.mapping.toJS(self, {ignore: ['transients']});
    };

    self.transients = {};
    self.transients.loading = ko.observable();
    self.transients.sites = project.sites;
    self.transients.selectedSites = ko.computed(function () {
        var sites = self.sites(),
            result = [];

        sites.forEach(function (siteId) {
            var site = $.grep(self.transients.sites, function (site) {
                return site.siteId == siteId;
            });

            if(site.length){
                result.push(site[0]);
            }
        });

        return result;
    });
    self.transients.unSelectedSites = ko.computed(function () {
        var sites = self.sites(),
            result = [];

        self.transients.sites.forEach(function (site) {
            if(sites.indexOf(site.siteId) == -1){
                result.push(site)
            }
        });

        return result;
    });
    self.transients.siteUrl = function (site) {
        return fcConfig.siteViewUrl + '/' + site.siteId
    };
    self.transients.addSite = function (site) {
        self.sites.push(site.siteId);
    };
    self.transients.removeSite = function (site) {
        self.sites.remove(site.siteId);
    };

    self.selectFromSitesOnly.subscribe(function(checked){
        if(checked){
            self.allowAdditionalSurveySites(false);
            self.allowPolygons(false);
            self.allowPoints(false);
        }
    });

    self.allowAdditionalSurveySites.subscribe(function(checked){
        if(checked){
            self.selectFromSitesOnly(false);
            // make sure drawing controls are checked when allowAdditionalSurveySites is switched on
            if (!(self.allowPolygons() || self.allowPoints())) {
                self.allowPolygons(true);
                self.allowPoints(true);
            }
        }
    });
}