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
    var sites = params.sites ? params.sites : [];
    config = config || {};

    self.allowPolygons = ko.observable(config.allowPolygons || true);
    self.allowPoints = ko.observable(config.allowPoints || true);
    self.allowAdditionalSurveySites = ko.observable(config.allowAdditionalSurveySites);
    self.selectFromSitesOnly = ko.observable(config.selectFromSitesOnly);
    self.defaultZoomArea = ko.observable(config.defaultZoomArea || project.projectSiteId);
    self.baseLayersName = ko.observable(config.baseLayersName);
    self.sites = ko.observableArray();
    self.loadSites = function (projectSites, surveySites) {
        $.map(projectSites ? projectSites : [], function (obj, i) {
            var defaultSites = [];
            surveySites && surveySites.length > 0 ? $.merge(defaultSites, surveySites) : defaultSites.push(obj.siteId);
            self.sites.push(new SiteList(obj, defaultSites, self));
        });
    };

    self.loadSites(sites, pActivity.sites);
}