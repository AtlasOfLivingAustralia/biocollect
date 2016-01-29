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
              id: ''
            },
            sites:[],
            error:''
        },props);

    this.sites = ko.observableArray(config.sites);
    this.error = ko.observable(config.error);

    self.loadGallery = function(){
        self.error('')
        $.ajax({
            url: fcConfig.poiGalleryUrl,
            data: config.params,
            success: function(data){
                data && data.forEach(function(site){
                    self.sites.push( new SiteGalleryViewModel(site))
                })
                console.log(sites.sites()[0].isPhotoPointsEmpty())
            },
            failure: function(xhr){
                self.error(xhr.responseText);
            }
        })
    }

    self.loadGallery()
}
/**
 * site model. a site can have a number of Point of interests.
 * @param props
 * @constructor
 */
function SiteGalleryViewModel(props){
    var self = this;
    this.name = ko.observable(props.name);
    this.siteId = ko.observable(props.siteId);
    this.poi = ko.observableArray();
    props.poi && props.poi.forEach(function(poi){
        self.poi.push(new PoiViewModel(poi, self.siteId()));
    })

    self.isPhotoPointsEmpty = ko.computed(function(){
        var empty = true;
        self.poi().forEach(function(poi){
            if(!poi.isEmpty()){
                empty = false;
            }
        })
        return empty;
    });
    console.log(this.isPhotoPointsEmpty())
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
        size = props.docs.documents && props.docs.documents.length;

    this.width = props.width || 215;
    this.name = ko.observable(props.name);
    this.poiId = ko.observable(props.poiId);
    this.type = ko.observable(props.type);
    this.pagesize = 5;
    this.offset = ko.observable(0);
    this.max = ko.observable(size);
    this.total = ko.observable(props.docs.count || 0);
    this.error = ko.observable('')
    this.documents = ko.observableArray();
    this.showPoi = ko.observable(true);
    this.hasNextPage = ko.computed(function(){
        return self.total() > self.max();
    });
    this.getWidth = ko.computed(function(){
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
        self.offset(self.max());
        self.max(self.max() + self.pagesize);
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
            failure: function(xhr){
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
        self.documents.push(new ImageViewModel(doc, true));
    })
}