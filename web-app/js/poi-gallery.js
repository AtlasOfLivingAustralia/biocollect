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
 * Created by Temi Varghese on 22/01/16.
 *
 * Displays a gallery for each point of interest in a site.
 * It was deal with a number of sites.
 */
function SitesGalleryViewModel(props) {
    var self = this,
        config = $.extend({
            params:{
              id: '',
              order: null
            },
            sites:[],
            error:'',
            loadOnInit: true,
            order: 'desc'
        },props);

    self.sites = ko.observableArray(config.sites);
    self.error = ko.observable(config.error);
    self.loading = ko.observable(false);
    self.sortDirection = ko.observable(config.order)

    self.isSitesEmpty =ko.computed(function() {
        // to prevent no photo point message from appearing
        if(self.loading()){
            return false;
        }

        var sites = self.sites();
        for(var i = 0; i < sites.length; i++){
            if(!sites[i].isPhotoPointsEmpty()){
                return false;
            }
        }

        return true;
    });

    self.loadGallery = function(){
        self.setParams();
        self.sites.removeAll()
        self.error('')
        self.loading(true);
        $.ajax({
            url: fcConfig.poiGalleryUrl,
            data: config.params,
            success: function(data){
                var results = []
                data && data.forEach(function(site){
                    site.gallery = self;
                    results.push( new SiteGalleryViewModel(site))
                })
                self.sites(results);
                self.loading(false);
            },
            error: function(xhr){
                self.error(xhr.responseText);
                self.loading(false);
            }
        })
    }

    self.setParams = function(params){
        for(var key in params){
            config.params[key] = params[key];
        }

        config.params.order = self.getSortDirection();
    }

    self.getSortDirection = function(){
        return self.sortDirection();
    }

    self.setSortDirection = function(viewmodel, event){
        self.sortDirection($(event.target).attr('data-value'))
    }

    self.sortDirection.subscribe(self.loadGallery)

    config.loadOnInit && self.loadGallery()
}
/**
 * site model. a site can have a number of Point of interests.
 * @param props
 * @constructor
 */
function SiteGalleryViewModel(props){
    var self = this;
    var pois = [], test;
    self.name = ko.observable(props.name);
    self.siteId = ko.observable(props.siteId);
    self.poi = ko.observableArray();
    self.gallery = props.gallery
    props.poi && props.poi.forEach(function(poi){
        poi.site = self;
        pois.push(new PoiViewModel(poi, self.siteId()))
    })

    self.poi(pois);

    self.isPhotoPointsEmpty = ko.computed(function(){
        var poi = self.poi();
        for(var i = 0; i < poi.length; i++){
            if(!poi[i].isEmpty()){
                return false;
            }
        }

        return true;
    });
}

/**
 * A point of interest(POI) view model. A POI can have a number of images which are stored in documents property.
 * Initially only a limitted POI images are loaded. loadNextPage function can be used to load more images for this
 * POI.
 * @param props
 * @param siteId
 * @constructor
 */
function PoiViewModel(props, siteId){
    var self = this,
        params = {
            siteId: siteId,
            poiId: props.poiId
        },
        size = props.docs.documents && props.docs.documents.length,
        docs = [];

    self.width = props.width || 215;
    self.name = ko.observable(props.name);
    self.poiId = ko.observable(props.poiId);
    self.type = ko.observable(props.type);
    self.pagesize = 5;
    self.offset = ko.observable(0);
    self.max = ko.observable(size);
    self.total = ko.observable(props.docs.count || 0);
    self.error = ko.observable('')
    self.documents = ko.observableArray();
    self.showPoi = ko.observable(true);
    self.hasNextPage = ko.computed(function(){
        return self.total() > (self.offset()+self.max());
    });
    self.site = props.site
    self.getWidth = ko.computed(function(){
        // load more box appears only if more images are present
        var loadMore = self.hasNextPage()?1:0;
        return self.width * (self.documents().length +loadMore)+ 'px';
    })

    /**
     * parameters sent to webservice are saved here.
     */
    self.updateUrlParameter = function(){
        params.max = self.max();
        params.offset = self.offset()
        params.order = self.site.gallery.getSortDirection();
    }

    /**
     * clears image gallery of all images
     */
    self.reset = function(){
        self.offset(0)
        self.max(self.pagesize)
        self.docs.removeAll();
        self.total(0);
    }

    self.firstPage = function(){
        self.reset();
        self.loadNextPage();
    }

    self.nextPage = function(){
        self.offset(self.offset()+self.pagesize);
        self.loadNextPage();
    }

    /**
     * check if this POI has any images
     */
    self.isEmpty = ko.computed(function(){
        var documents = self.documents();
        if( documents && (documents.length == 0)){
            return true;
        }
        return false;
    });

    self.loadNextPage = function(){
        self.updateUrlParameter();
        $.ajax({
            url: fcConfig.imagesForPoiUrl,
            data: params,
            success: function(data){
                data.documents && data.documents.forEach(function(doc){
                    self.documents.push(new ImageViewModel(doc, true))
                });
            },
            error: function(xhr){
                self.error(xhr.responseText);
            }
        })
    }

    /**
     * used to hide or show gallery
     */
    self.toggleVisibility = function(){
        self.showPoi(!self.showPoi());
    }

    // initialise data
    props.docs.documents && props.docs.documents.forEach(function(doc){
        docs.push(new ImageViewModel(doc, true))
    })
    self.documents(docs);
}