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
var availableFacets = [
    {name: 'siteProjectNameFacet', displayName: 'Project'},
    {name: 'siteSurveyNameFacet', displayName: 'Survey'},
    {name: 'photoType', displayName: 'Photo Type'},
    {name: 'typeFacet', displayName: 'Type'},
    {name: 'stateFacet', displayName: 'State / Territory'},
    {name: 'lgaFacet', displayName: 'Local Government Area'},
    {name: 'nrmFacet', displayName: 'Natural Resource Management'}
];

/**
 * view model for sites used to display gallery
 * @param params
 * @constructor
 */
function SitesListViewModel(params) {
    var self = this,
        config = $.extend({
            // can turn off initial load if set to false
            loadOnInit: true
        }, params);

    self.facets = ko.observableArray();
    self.sites = ko.observableArray();
    self.gallery = ko.observableArray();
    self.error = ko.observable();
    self.selectedFacets = ko.observableArray();
    self.searchTerm = ko.observable('')
    self.pagination = new PaginationViewModel(null,self)
    self.doNotLoad = ko.observable(false)
    self.refineList = ko.observableArray();
    self.sitesLoaded = ko.observable(false)


    /**
     * ajax call to load sites and initial list of photo points for each point of interest
     * @param offset
     */
    self.loadSites = function (offset) {
        if(!self.doNotLoad()){
            var params = self.constructQueryParams(offset);
            self.error('');
            self.sitesLoaded(false);

            $.ajax({
                url: fcConfig.listSitesUrl,
                data: params,
                traditional:true,
                success: function (data) {
                    if(data.sites){
                        data.sites = $.map(data.sites, function (site) {
                            site.sites = self;
                            return new SiteListViewModel(site)
                        });
                        self.sites(data.sites);
                        self.gallery(self.getAllSiteId(data.sites))
                    }

                    data.facets && self.createFacets(data.facets, availableFacets);

                    self.pagination.loadPagination(self.pagination.currentPage(), data.total)

                    self.sitesLoaded(true);
                },
                error: function (xhr) {
                    self.error(xhr.responseText);
                    self.sitesLoaded(true);
                }
            })
        }
    }

    /**
     * get siteId as an array.
     * @param sites
     * @returns {Array}
     */
    self.getAllSiteId = function(sites){
        var results = []
        sites.forEach(function(site){
            results.push(site.siteId())
        })
        return results
    }

    /**
     * function to extracts facets and insert them in the order provided by facetOrder parameter.
     * Note: Only facets in facetOrder parameter is included, others are ignored.
     * @param facets
     * @param facetsOrder
     */

    self.createFacets = function (facets, facetsOrder) {
        if (!facets || !facetsOrder) {
            return;
        }
        var results = []

        facets = $.map(facets, function (facet) {
            facet.sites = self;
            return new FacetViewModelForSiteList(facet);
        })

        facetsOrder.forEach(function (metadata) {
            var result = self.find(facets, 'name', metadata.name)
            if (result) {
                result.metadata = metadata
                results.push(result)
            }
        });
        self.facets(results);
    }

    self.find = function (items, prop, value) {
        for (var i = 0; i < items.length; i++) {
            if (items[i][prop]() == value) {
                return items[i];
            }
        }
    }

    /**
     * creates an object what will be sent as parameters
     * @param tOffset
     * @returns {{max: *, offset: *, query: *, fq: *}}
     */
    self.constructQueryParams = function(tOffset){
        var offset

        if(tOffset != undefined || tOffset != null){
            offset = tOffset
        } else {
            offset = self.pagination.calculatePageOffset(self.pagination.currentPage()+1);
        }

        var params = {
            max: self.pagination.resultsPerPage(),
            offset: offset,
            query: self.searchTerm(),
            fq: $.map(self.selectedFacets(), function(fq){
                return fq.getQueryText();
            }),
            myFavourites:fcConfig.myFavourites
        }
        return params;
    }


    /**
     * clears result list
     */
    self.reset = function(){
        self.sites.removeAll();
        self.facets.removeAll();
        self.doNotLoad(true);
        self.selectedFacets.removeAll()
        self.searchTerm('')
        self.doNotLoad(false);
        self.pagination.first()
    }

    /**
     * used by pagination view model. called to inform a change to page number or pagesize.
     * @param offset
     */
    self.refreshPage = function(offset){
        self.loadSites(offset);
    }

    self.removeAllSelectedFacets = function(){
        self.selectedFacets.removeAll()
    }

    self.addFacetTerm = function(term){
        self.selectedFacets.push(term)
    }

    self.removeFacetTerm = function(term){
        self.selectedFacets.remove(term);
    }

    self.clearError = function(){
        self.error('');
    }

    self.clearErrorWithDelay = function(){
        if(self.error()){
            var delay = config.delay || 5000;
            setTimeout(self.clearError, delay)
        }
    }


    /**
     * add a facet to refine list when checked
     * @param SiteFacetTermViewModel
     */
    self.addToRefineList = function(model){
        model.checked(true);
        self.refineList.push(model);
    }

    /**
     * remove a facet from refine list when unchecked
     * @param SiteFacetTermViewModel
     */
    self.removeFromRefineList = function(model){
        self.refineList.remove(model);
    }


    /**
     * add refined list to selected facets
     */
    self.addRefineListToSelected = function(){
        var selected = self.selectedFacets();
        var refine = self.refineList.removeAll();
        refine && refine.forEach(function(fq){
            fq.checked(false);
            selected.push(fq);
        });
        self.selectedFacets(selected);
    };

    self.selectedFacets.subscribe(self.pagination.first);
    self.searchTerm.subscribe(self.pagination.first);
    self.error.subscribe(self.clearErrorWithDelay);

    config.loadOnInit && (self.pagination.loadPagination(1,0) || self.pagination.first())
}



function SiteListViewModel(prop) {
    var self = this;
    self.name = ko.observable(prop.name);
    self.siteId = ko.observable(prop.siteId);
    self.lastUpdated = ko.observable(prop.lastUpdated);
    self.description = ko.observable(prop.description);
    self.numberOfProjects = ko.observable(prop.numberOfProjects);
    self.numberOfPoi = ko.observable(prop.numberOfPoi);
    self.type = ko.observable(prop.type);
    self.canEdit = ko.observable(prop.canEdit);
    self.canDelete = ko.observable(prop.canDelete);
    self.showAddToFavourites = ko.observable(prop.addToFavourites);
    self.showRemoveFromFavourites = ko.observable(prop.removeFromFavourites);
    self.extent = prop.extent;
    self.sites = prop.sites

    /**
     * constructs url to site
     * @returns {string}
     */
    self.getSiteUrl = function () {
        return fcConfig.viewSiteUrl + '/' + self.siteId();
    }

    self.addSiteToFavourites = function () {
        $.ajax({
            url: fcConfig.addStarSiteUrl + '/' + self.siteId(),
            success: function(data){
                self.showAddToFavourites(false);
                self.showRemoveFromFavourites(true);
            },
            error: function(xhr){
                self.sites.error(xhr.responseText);
            }
        })
    }

    self.removeSiteFromFavourites = function () {
        $.ajax({
            url: fcConfig.removeStarSiteUrl + '/' + self.siteId(),
            success: function(data){
                //If we are displaying the My Favourites Sites it is important to keep consistent the contents
                //ie, if a site is un marked as favourite it should dissappear from the screen rather than
                // just changing the star icon to empty
                if (fcConfig.myFavourites) {
                    self.sites.error('Site removed from favourites');
                    //Just as self.deleteSite function, removing the site from screen seems trivial however the backing
                    // model comes from elastic search, in order to keep all values on screen consistent we need to
                    // issue a new search which will refresh most elements on screen causing a nasty flicker, not much
                    // different that reloading the whole page, hence we accept that result and facet count values won't be in sync.
                    // Eventually when the user applies any filter or revisit the page, result count and facets will be in sync.
                    self.sites.sites.remove(self);
                    //Let's refresh the view in case we get an empty list
                    if (self.sites.sites().length == 0) {
                        self.sites.pagination.first();
                        self.sites.removeAllSelectedFacets();
                    }
                } else {
                    self.showAddToFavourites(true);
                    self.showRemoveFromFavourites(false);
                }
            },
            error: function(xhr){
                self.sites.error(xhr.responseText);
            }
        })
    }

    /**
     * constructs url to edit site
     * @returns {string}
     */
    self.getSiteEditUrl = function () {
        return fcConfig.editSiteUrl + '/' + self.siteId();
    }

    self.deleteSite = function () {
        $.ajax({
            url: fcConfig.siteDeleteUrl + '/' + self.siteId(),
            success: function(data){
                self.sites.error('Successfully deleted site!!')
                self.sites.sites.remove(self);
            },
            error: function(xhr){
                self.sites.error(xhr.responseText);
            }
        })
    }

}

function FacetViewModelForSiteList(facet) {
    var self = this;
    if (!facet) facet = {};

    self.name = ko.observable(facet.name);
    self.total = ko.observable(facet.total);
    self.terms = ko.observableArray();
    self.filter = ko.observable(false);
    // controls the visibility of facet
    self.show = ko.observable(false);

    self.sites = facet.sites;

    var terms = $.map(facet.terms ? facet.terms : [], function (term, index) {
        term.facet = self;
        return new SiteFacetTermViewModel(term);
    });

    self.terms(terms);

    /**
     * toggles visibility of facet
     */
    self.toggle = function(){
        self.show(!self.show())
    }
};

function SiteFacetTermViewModel(term) {
    var self = this;
    if (!term) term = {};

    self.selected = ko.observable(false);
    self.facet = term.facet;
    self.count = ko.observable(term.count);
    self.term = ko.observable(term.term);
    self.displayName = ko.computed(function(){
       return decodeCamelCase(self.term()) || 'Unknown';
    });
    self.showTerm = ko.observable(term.showTerm || true);
    self.id = ko.observable(generateSiteTermId(self));
    self.checked = ko.observable(false);

    /**
     * constructs a facet term so that it can be passed as fq value.
     * @returns {string}
     */
    self.getQueryText = function(){
        return self.facet.name() +':'+ self.term();
    }

    /**
     * when refine result is clicked, add t
     */
    self.checked.subscribe(function(value){
        if(self.checked()){
            self.facet.sites.addToRefineList(self);
        } else {
            self.facet.sites.removeFromRefineList(self);
        }
    })
};

function generateSiteTermId(term) {
    var name, term
    name = term.facet.name()
    term = term.term()
    return name.replace(/[^a-zA-Z0-9]/g, "") + term.replace(/[^a-zA-Z0-9]/g, "")
}