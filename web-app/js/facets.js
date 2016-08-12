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
 * Created by Temi on 9/08/2016.
 */
function FacetViewModel(facet) {
    var self = this;
    if (!facet) facet = {};

    self.name = ko.observable(facet.name);
    self.displayName = ko.computed(function(){
        return cleanName(self.name()) || 'Unknown';
    });
    self.total = ko.observable(facet.total);
    self.terms = ko.observableArray();
    self.filter = ko.observable(false);
    // controls the visibility of facet
    self.show = ko.observable(false);

    self.ref = facet.ref;

    var terms = $.map(facet.terms ? facet.terms : [], function (term, index) {
        term.facet = self;
        return new FacetTermViewModel(term);
    });

    self.terms(terms);

    /**
     * toggles visibility of facet
     */
    self.toggle = function(){
        self.show(!self.show())
    }

    /**
     * Set a flag on a term to indicate that it is selected. 
     * @param term
     */
    self.setTermState = function (term ){
        self.terms().forEach(function(item){
            if ( term == item.term() ) {
                item.silent(true)
                item.checked(true)
                item.silent(false)
            }
        })
    }
};

function FacetTermViewModel(term) {
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
    self.id = ko.observable(generateTermId(self));
    self.checked = ko.observable(false);
    self.silent = ko.observable(false)

    /**
     * constructs a facet term so that it can be passed as fq value.
     * @returns {string}
     */
    self.getQueryText = function(){
        return self.facet.name() +':'+ self.term();
    }

    /**
     * toggle checked status
     */
    self.filterNow = function () {
        self.checked(true)
        self.facet.ref.addToRefineList(self);
        self.facet.ref.doSearch()
    }

    /**
     * add to refine list
     */
    self.addToRefine = function () {
        self.facet.ref.addToRefineList(self);
    }

    /**
     * when refine result is clicked, add t
     */
    self.checked.subscribe(function(value){
        if(!self.facet.ref){
            return
        }

        if(!self.silent()){
            if(self.checked()){
                self.facet.ref.addToRefineList(self);
            } else {
                self.facet.ref.removeFromRefineList(self);
            }
        }
    })
};

function generateTermId(facetTerm) {
    var name, term
    name = facetTerm.facet.name()
    term = facetTerm.term()
    return name.replace(/[^a-zA-Z0-9]/g, "") + term.replace(/[^a-zA-Z0-9]/g, "")
}

/**
 * Roles have camelCase names and this is a work-around for printing them from AJAX
 * responses.
 * TODO implement i18n encoding with JS
 *
 * @param text
 * @returns {string}
 */
function decodeCamelCase(text) {
    var result = text.replace( /([A-Z])/g, " $1" );
    return result.charAt(0).toUpperCase() + result.slice(1); // capitalize the first letter - as an example.
}

function cleanName(text) {
    return decodeCamelCase(text.replace('_', ' '))
}