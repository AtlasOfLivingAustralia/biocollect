/*
 * Copyright (C) 2016 Atlas of Living Australia
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
 * Created by Temi on 1/02/16.
 */
function SitesListViewModel(params) {
    var self = this,
        config = $.extend({
            // can turn off initial load if set to false
            loadOnInit: true
        }, params);

    self.facets = ko.observableArray();
    self.sites = ko.observableArray();
    self.error = ko.observable('');
    self.selectedFacets = ko.observableArray();

    self.loadSites = function () {
        self.error('')
        $.ajax({
            url: fcConfig.listSitesUrl,
            data: config.params,
            success: function (data) {
                data.sites && data.sites.forEach(function (site) {
                    self.sites.push(new SiteListViewModel(site))
                });
                data.facets && data.facets.forEach(function (facet) {
                    self.facets.push(new FacetViewModel(facet));
                });
            },
            failure: function (xhr) {
                self.error(xhr.responseText);
            }
        })
    }

    self.selectedFacets.subscribe(self.loadSites);

    config.loadOnInit && self.loadSites()
}

function SiteListViewModel(prop){
    var self = this;
    self.name = ko.observable(prop.name);
    self.siteId = ko.observable(prop.siteId);
    self.lastUpdated = ko.observable(prop.lastUpdated);

    self.getSiteUrl = function(){
        return fcConfig.viewSiteUrl + '/' + self.siteId();
    }
}

function FacetViewModel(facet, availableFacets) {
    var self = this;
    var LIMIT = 15;
    if (!facet) facet = {};

    self.name = ko.observable(facet.name);
    self.total = ko.observable(facet.total);
    self.terms = ko.observableArray();
    self.filter = ko.observable(false);

    self.toggleFilter = function () {
        self.filter(!self.filter())
    };

    self.displayText = ko.pureComputed(function () {
        return getFacetName(self.name()) + " (" + self.total() + ")";
    });

    self.order = ko.pureComputed(function () {
        return getFacetOrder(self.name());
    });

    self.searchTerm = ko.observable('');
    /**
     * search for a token and show terms matching the token.
     */
    self.search = function () {
        var terms = self.terms(), text, regex;
        regex = new RegExp(self.searchTerm(), 'i');
        terms.forEach(function (term) {
            text = term.displayText();
            if (text && text.match(regex, 'i')) {
                term.showTerm() || term.showTerm(true);
            } else {
                term.showTerm(false);
            }
        });
    };

    self.findTerm = function (termName) {
        var match = null;

        self.terms().forEach(function (term) {
            if (term.term() == termName) {
                match = term;
            }
        });

        return match;
    };

    self.searchTerm.subscribe(self.search);

    /**
     * show filter input box only when facet terms are more than the specified limit.
     * @returns {boolean}
     */
    self.showFilter = function () {
        if (self.terms().length > LIMIT) {
            return true;
        }

        return false;
    };

    var getFacetName = function (name) {
        var found = $.grep(availableFacets, function (obj, i) {
            return (obj.name == name);
        });
        return found.length > 0 ? found[0].displayName : 'Not Categorized';
    };

    var getFacetOrder = function (name) {
        var found = $.grep(availableFacets, function (obj, i) {
            return (obj.name == name);
        });
        return found.length > 0 ? found[0].order : 0;

    };

    var terms = $.map(facet.terms ? facet.terms : [], function (term, index) {
        term.facet = self;
        //todo: display name to be moved to facetviewmodel
        //term.facetDisplayName = getFacetName(self.name());
        return new FacetTermViewModel(term);
    });

    self.terms(terms);
};

function FacetTermViewModel(term) {
    var self = this;
    if (!term) term = {};

    self.id = ko.observable(generateTermId(term));
    self.selected = ko.observable(false);
    self.facet = term.facet;
    self.count = ko.observable(term.count);
    self.term = ko.observable(term.term);
    self.showTerm = ko.observable(term.showTerm || true);
};

function generateTermId(term) {
    //if (_.isFunction(term.facetName)) {
    //    return term.facet.name().replace(/[^a-zA-Z0-9]/g, "") + term.term().replace(/[^a-zA-Z0-9]/g, "")
    //} else {
    //    return term.facet.name.replace(/[^a-zA-Z0-9]/g, "") + term.term.replace(/[^a-zA-Z0-9]/g, "")
    //}
}