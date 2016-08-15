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
function FilterViewModel(){
    var self = this;
    self.facets = ko.observableArray()
    self.selectedFacets = ko.observableArray()
    self.tempListOfFacets = ko.observableArray()

    /**
     * Function for initialising facets.
     * @param facets
     */
    self.setFacets = function (facets) {
        self.facets($.map(facets, function (facet) {
            facet.ref = self;
            var facetVm = new FacetViewModel(facet)
            self.setFacetTerm(facetVm)
            return facetVm;
        }))
    }


    /**
     * check all terms of this facet that was previously selected.
     * @param facet
     */
    self.setFacetTerm = function(facet){
        var selectedFacets = self.selectedFacets()
        selectedFacets.forEach(function (term) {
            if (facet.name() == term.facet.name()) {
                facet.setTermState (term.term())
            }
        })
    }

    /**
     * add a facet term to list of facets. This will trigger an ajax call to update projects.
     * @param term
     */
    self.addToRefineList = function (term) {
        self.selectedFacets.push(term)
        term.refined(true)
    }

    /**
     * remove a facet term from selected facets. This will trigger an ajax call to update projects.
     * @param term
     */
    self.removeFromRefineList = function (term) {
        var facets = self.selectedFacets()
        var remove = []
        facets.forEach(function (item) {
            // sometimes term and item are not the same instance. Hence compare values to get the correct one to remove.
            if((item.facet.name() == term.facet.name()) && item.term() == term.term()){
                remove.push(item)
                item.refined(false)
            }
        })

        self.selectedFacets.removeAll(remove)
    }

    /**
     * create mock facet view model and term view model. This is used when recovering a previous state from location hash.
     * @param fqs
     */
    self.setFilterQuery = function (fqs) {
        if(fqs){
            if(typeof fqs  == 'string'){
                fqs = [fqs]
            }

            fqs.forEach(function (fq) {
                var nameAndValue = fq.split(':')
                var facet = new FacetViewModel({ name: nameAndValue[0], terms: [{term:nameAndValue[1]}]})
                facet.ref = self
                var term = facet.terms()[0]
                self.addToRefineList (term)
            })
        }
    }

    /**
     * merges checked facet terms with selected facets. This will trigger an ajax call to update projects.
     */
    self.mergeTempToRefine = function () {
        var tempList = self.tempListOfFacets()
        var sanitisedList = []
        tempList.forEach(function (item) {
            if(!isDuplicate(self.selectedFacets(), item)){
                sanitisedList.push(item)
            }
        })

        self.selectedFacets.push.apply(self.selectedFacets, sanitisedList)
        self.hideAllTerms(sanitisedList);
        self.tempListOfFacets.removeAll()
    }

    /**
     * clears all facet selection
     */
    self.reset = function () {
        self.showAllTerms(self.selectedFacets())
        self.tempListOfFacets.removeAll()
        self.selectedFacets.removeAll()
    }

    /**
     * Do not show the passed facet terms
     * @param terms
     */
    self.hideAllTerms = function (terms) {
        terms.forEach(function (term) {
            term.refined(true)
        })
    }

    /**
     * Show the passed facet terms
     * @param terms
     */
    self.showAllTerms = function (terms) {
        terms.forEach(function (term) {
            term.refined(false)
        })
    }

}

/**
 * Facet view model. Facet view model contains of a list of facet terms.
 * @param facet
 * @constructor
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

    self.isAnyTermVisible = ko.computed(function () {
        var count = 0;
        self.terms().forEach(function (term) {
            !term.refined()? count ++ : null;
        })

        return count > 0
    });

    self.ref = facet.ref;

    var terms = $.map(facet.terms ? facet.terms : [], function (term, index) {
        term.facet = self;
        return new FacetTermViewModel(term);
    });

    self.terms(terms);

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
                item.refined(true)
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
        var label = decodeCamelCase(self.term()) || 'Unknown'
        if(self.count()){
            label += " (" + self.count() + ")";
        }

        return label
    });
    self.showTerm = ko.observable(term.showTerm || true);
    self.id = ko.observable(generateTermId(self));
    self.checked = ko.observable(false);
    self.silent = ko.observable(false)
    self.refined = ko.observable(false)

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
        self.silent(true)
        self.checked(true)
        self.silent(false)
        self.facet.ref.addToRefineList(self);
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
                if(!isDuplicate(self.facet.ref.tempListOfFacets(), self)){
                    self.facet.ref.tempListOfFacets.push(self);
                }
            } else {
                self.facet.ref.tempListOfFacets.remove(self);
            }
        }
    })

    self.remove = function () {
        self.facet.ref.selectedFacets.remove(self)
    }
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

function isDuplicate(original, checkMe) {
    var duplicate = false

    original && original.forEach(function (term) {
        if (checkMe.facet.name() == term.facet.name()) {
            if(checkMe.term() == term.term()){
                duplicate = true
            }
        }
    })

    return duplicate
}

function findFacetTerm(list, checkMe) {
    var found

    list && list.forEach(function (term) {
        if (term.facet.name() == term.facet.name()) {
            if(term.term() == term.term()){
                found = term
            }
        }
    })

    return found
}