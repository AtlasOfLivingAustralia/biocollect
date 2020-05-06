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
    var SITE_CREATE = 'sitecreate', SITE_PICK = 'sitepick', SITE_PICK_CREATE = 'sitepickcreate';
    var self = this;
    var sites = project.sites || [],
        defaults = {
            allowPolygons: true,
            allowPoints: true,
            allowLine: false,
            addCreatedSiteToListOfSelectedSites: false,
            surveySiteOption : SITE_PICK
        };
    config = config || {};
    config = $.extend(defaults, config);
    project.sites = project.sites || [];

    self.allowPolygons = ko.observable(config.allowPolygons);
    self.allowPoints = ko.observable(config.allowPoints);
    self.allowLine = ko.observable(config.allowLine);
    // more explanation on projectActivity.js
    self.addCreatedSiteToListOfSelectedSites = ko.observable(config.addCreatedSiteToListOfSelectedSites);
    /**
     * selectFromSitesOnly removed
     * Use surveySiteOption = 'sitepick' instead.
     * Data will be migrated by a script.
     */
    self.surveySiteOption = ko.observable(config.surveySiteOption);
    self.defaultZoomArea = ko.observable(config.defaultZoomArea || project.projectSiteId);
    self.sites = ko.observableArray(config.sites || []);
    self.toJS = function () {
        return ko.mapping.toJS(self, {ignore: ['transients']});
    };

    self.transients = {};
    self.transients.surveySiteOption = config.surveySiteOption;
    self.transients.loading = ko.observable();
    self.transients.siteWithDataAjaxFlag = ko.observable(false);
    self.transients.sitesWithData = ko.observableArray([]);
    self.transients.sites = project.sites;
    self.transients.isSelectAllSites = ko.observable(false);
    self.transients.selectedSites = ko.computed(function () {
        var sites = self.sites(),
            result = [];

        sites.forEach(function (siteId) {
            var site = $.grep(self.transients.sites, function (site) {
                return site.siteId == siteId;
            });

            if(site.length){
                if ( result.indexOf(site[0]) == -1 )
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

    self.transients.selectAllSites = function () {
        var sites = self.sites(),
            unSelectedSites = self.transients.unSelectedSites();

        if (self.transients.isSelectAllSites()) {
            unSelectedSites = unSelectedSites.map(function (site) {
                return site.siteId;
            });

            sites.push.apply(sites, unSelectedSites);
            self.sites(sites);
        } else {
            self.sites.removeAll();
        }

        // allow default action
        return true;
    };

    self.transients.areAllSitesSelected = ko.computed(function () {
        var sites = self.sites() || [],
            allSites = self.transients.sites || [];
        return sites.length == allSites.length;
    });

    self.transients.areAllSitesSelected.subscribe(function(value){
        self.transients.isSelectAllSites(value);
    });

    self.transients.siteUrl = function (site) {
        return fcConfig.siteViewUrl + '/' + site.siteId
    };
    self.transients.addSite = function (site) {
        if (self.sites.indexOf(site.siteId) == -1)
            self.sites.push(site.siteId);
    };
    self.transients.removeSite = function (site) {
        self.sites.remove(site.siteId);
    };

    self.transients.setSurveySiteOption = function () {
        if(this.value != self.surveySiteOption())
            self.surveySiteOption(this.value);
    };

    self.transients.deleteSite = function (site){
        var url = fcConfig.siteDeleteUrl + '?siteId=' + site.siteId;
        $.ajax({
            url: url,
            contentType: "application/json",
            success: function (message) {
                var displayText;
                if (message.message)
                    displayText = message.message + " Reloading in 3 seconds."
                else
                    displayText = 'Successfully deleted site. Reloading in 3 seconds.';

                bootbox.alert(displayText);
                setTimeout(function(){ window.location.reload()}, 3000);
            },
            error: function(xhr){
                var message = JSON.parse(xhr.responseText).error || "";
                message += "<br/>It is possible site configuration has not been saved. Save map configuration and click delete button.";
                bootbox.alert(message);
            }
        })
    };

    /**
     * Check if site delete button is to be disabled. If answer is no to each of the below statements, then site can be
     * deleted.
     * 1. Are data associated with site.
     * 2. Is site selected by project.
     * 3. Is site a project area.
     * @returns {*|boolean|boolean}
     */
    self.transients.isSiteDeleteDisabled = function () {
        var site = this;
        var isDataPresent = self.transients.isDataForSite.apply(site);
        if (isDataPresent) {
            return true
        } else {
            // is site selected/checked?
            if(self.sites.indexOf(site.siteId) > -1) {
                return true;
            }
            // is site a project area?
            else if (site.siteId == project.projectSiteId) {
                return true;
            } else {
                return false;
            }
        }
    };

    /**
     * Checks if this site has activity associated with it.
     */
    self.transients.isDataForSite = function (site) {
        // if ajax call is not complete return has data so that the button is disabled
        if(!self.transients.siteWithDataAjaxFlag()){
            return true
        }

        var context = this;
        var sitesWithData = self.transients.sitesWithData() || [];
        var results = $.grep(sitesWithData,function (siteId) {
            return siteId == context.siteId;
        });

        return results && results.length > 0
    };

    self.transients.toggleSiteOptionPanel = function() {
        var id = this.accordionLinkId;
        // Need to trigger a click event to have consistent accordion behaviour.
        // Programatically calling collapse function does not close open accordion panel.
        setTimeout(function () {
            $(id).trigger('click');
        }, 0);

        return true;
    };

    self.isUserSiteCreationConfigValid = function () {
        if (!(self.allowPolygons() || self.allowPoints() || self.allowLine())) {
            return "Configuration not valid - Either points, polygon or line drawing should be enabled."
        }
    };

    self.isSiteSelectionConfigValid = function () {
        if (!(self.sites().length > 0)) {
            return "Configuration not valid - At least one site must be selected."
        }
    };

    self.surveySiteOption.subscribe(function(newOption) {
        switch (newOption) {
            case SITE_CREATE:
                self.clearSelectedSites();
                break;
            case SITE_PICK:
                self.clearCreateSiteOptions();
                break;
            case SITE_PICK_CREATE:
                // do nothing
                break;
        }
    });

    self.clearSelectedSites = function() {
        self.sites.removeAll();
    };

    self.clearCreateSiteOptions = function() {
        self.allowPoints(false);
        self.allowPolygons(false);
        self.allowLine(false);

        // Must not be able to add site to pre-determined list when create site is disabled.
        self.addCreatedSiteToListOfSelectedSites(false);
    };

    /**
     * If user cannot create site, then addCreatedSiteToListOfSelectedSites should be cleared.
     */
    function clearAddCreatedSiteToListOfSelectedSitesIfUserCannotCreateSite(createSite) {
        if( !createSite )
            if (self.isUserSiteCreationConfigValid())
                self.addCreatedSiteToListOfSelectedSites(false);
    };

    self.allowPoints.subscribe(clearAddCreatedSiteToListOfSelectedSitesIfUserCannotCreateSite);
    self.allowPolygons.subscribe(clearAddCreatedSiteToListOfSelectedSitesIfUserCannotCreateSite);
    self.allowLine.subscribe(clearAddCreatedSiteToListOfSelectedSitesIfUserCannotCreateSite);

    /**
     * get sites with data for a given survey/project activity
     * @param obj
     */
    self.getSitesWithData = function () {
        self.transients.sitesWithData.removeAll();
        self.transients.siteWithDataAjaxFlag(false);
        $.ajax({
            url: fcConfig.sitesWithDataForProject + "/" + project.projectId,
            type: 'GET',
            timeout: 10000,
            success: function (data) {
                if (data.sites) {
                    self.transients.sitesWithData(data.sites)
                }
            },
            error: function (data) {
                console.log("Error retrieving sites with data for survey.", "alert-error");
            }
        }).done(function () {
            self.transients.siteWithDataAjaxFlag(true);
        });
    };

    self.getSitesWithData();
}

function isUserSiteCreationConfigValid (field, rules, i, options) {
    field = field && field[0];
    var model = ko.dataFor(field);
    if (['sitecreate', 'sitepickcreate'].indexOf(model.surveySiteOption()) > -1) {
        var msg = model.isUserSiteCreationConfigValid();
        if (msg) {
            rules.push('required');
            return msg;
        }
    }
}

function isSiteSelectionConfigValid (field, rules, i, options) {
    field = field && field[0];
    var model = ko.dataFor(field);
    if (['sitepick', 'sitepickcreate'].indexOf(model.surveySiteOption()) > -1) {
        var msg = model.isSiteSelectionConfigValid();
        if (msg) {
            rules.push('required');
            return msg;
        }
    }
}
