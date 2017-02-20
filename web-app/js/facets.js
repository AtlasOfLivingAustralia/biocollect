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

var CONSTANT_VARIABLES = {
    specialFacets: [{name: 'plannedStartDate', type: 'date'}]
};

function FilterViewModel(config){
    var self = this;
    var parent = config.parent;
    self.flimit = config.flimit;

    self.facets = ko.observableArray()
    self.selectedFacets = ko.observableArray()
    self.tempListOfFacets = ko.observableArray()
    self.showMoreTermList = ko.observableArray([]);
    self.showMoreFacet  = ko.observable();
    self.searchText = ko.observable();
    self.switchOffSearch = ko.observable(false);

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
    };


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
    };

    /**
     * add a facet term to list of facets. This will trigger an ajax call to update projects.
     * @param term
     */
    self.addToRefineList = function (term) {
        self.selectedFacets.push(term)
        term.refined(true)
    };

    self.replaceOrAddTermToRefineList = function (terms) {
        var fqs = self.selectedFacets(), index = 0;
        if(terms){
            self.switchOffSearch(true);
            $.each(terms, function (j, term) {
                // make sure search is switched on before last update
                if(j == (terms.length - 1 )){
                    self.switchOffSearch(false);
                }

                var match = $.each(fqs, function (i, fq) {
                    index = i;
                    return fq.facet.name() == term.facet;
                });

                if(match.length > 0){
                    fqs[index] = term;
                    self.selectedFacets(fqs);
                } else {
                    self.selectedFacets.push(term)
                }

                term.refined(true);
            })
        }
    };

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
    };

    /**
     * create mock facet view model and term view model. This is used when recovering a previous state from location hash.
     * @param fqs
     */
    self.setFilterQuery = function (fqs) {
        if(fqs){
            var exceptions = {};
            if(typeof fqs  == 'string'){
                fqs = [fqs]
            }

            fqs.forEach(function (fq) {
                var nameAndValue = fq.split(':');
                var exclude = false, facet;
                if(nameAndValue[0] && nameAndValue[0].indexOf('-') == 0){
                    exclude = true;
                    nameAndValue[0] = nameAndValue[0].replace('-', '');
                }

                var match = $.grep(CONSTANT_VARIABLES.specialFacets, function (item) {
                   return  item.name == nameAndValue[0];
                });

                if(match){
                    if(!exceptions[nameAndValue[0]]){
                        exceptions[nameAndValue[0]] = []
                    }

                    exceptions[nameAndValue[0]].push(nameAndValue);
                } else {
                    facet = new FacetViewModel({ name: nameAndValue[0], terms: [{term:nameAndValue[1], exclude: exclude}], ref: self});
                    facet.ref = self;
                    var term = facet.terms()[0];
                    self.addToRefineList (term)
                }
            });

            for(var key in exceptions){
                switch (key){
                    case 'plannedStartDate':
                        var filters = exceptions[key];
                        var facet = key;
                        var cleanedTerms = {};
                        $.each(filters, function (index, fq) {
                            if(fq[1] && (fq[1].indexOf('>=') > -1) ) {
                                cleanedTerms.fromDate = fq[1].replace('>=', '');
                            } else if(fq[1] && (fq[1].indexOf('<=') > -1) ) {
                                cleanedTerms.toDate = fq[1].replace('<=', '');
                            }
                        });

                        var dateVM = new FacetViewModel({ name: facet, terms: [cleanedTerms], ref: self, type: 'date'});
                        dateVM.terms()[0].addToRefine();
                        break;
                }
            }
        }
    };

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

    /**
     * Check if a facet is selected.
     * @param facet
     * @returns {boolean}
     */
    self.isFacetSelected = function (facet) {
        var flag = false;
        var selectedFacets = self.selectedFacets()
        selectedFacets.forEach(function (term) {
            if (facet.name() == term.facet.name()) {
                flag = true
            }
        });

        return flag;
    };

    self.getFacetTerms = function (facetVM) {
        self.searchText('');
        self.showMoreFacet(facetVM);
        var promise = parent.getFacetTerms(facetVM.name());
        promise.then(function (data) {
            var facets = data.facets;
            var facet = facets && facets[0];
            if(facet){
                var terms = facetVM.getTerms(facet.terms);
                self.showMoreTermList(terms);
            }
        })
    };

    self.displayTitle = function (title) {
        if(self.showMoreFacet()){
            return title + ' ' + self.showMoreFacet().displayName();
        }

        return title;
    };

    self.excludeSelection = function () {
        var tempList = self.tempListOfFacets();
        tempList.forEach(function (item) {
            item.exclude = true;
        });

        self.mergeTempToRefine();
    };

    self.includeSelection = function () {
        self.mergeTempToRefine();
    };

    /**
     * search for a token and show terms matching the token.
     */
    self.searchText.subscribe(function(){
        var terms = self.showMoreTermList(), text, regex;
        regex = new RegExp(self.searchText(), 'i');
        terms.forEach(function(term){
            text = term.displayName();
            if(text && text.match(regex, 'i')){
                 term.showTerm(true);
            } else {
                term.showTerm(false);
            }
        });
    });
}

/**
 * Facet view model. Facet view model contains of a list of facet terms.
 * @param facet
 * @constructor
 */
function FacetViewModel(facet) {
    if (!facet) facet = {};
    var self = this;
    var state = facet.state|| 'Expanded';

    self.name = ko.observable(facet.name);
    self.title = facet.title
    self.total = ko.observable(facet.total);
    self.terms = ko.observableArray();
    self.filter = ko.observable(false);
    self.helpText = ko.observable(facet.helpText)
    self.displayName = ko.computed(function(){
        return self.title || cleanName(self.name()) || 'Unknown';
    });
    self.type = facet.type;

    if(facet.ref.isFacetSelected(self)){
        state = 'Expanded'
    }
    self.state = ko.observable(state);


    self.showTermPanel = ko.computed(function () {
        var count = 0;
        if(self.type == 'date'){
            return true;
        } else {
            self.terms().forEach(function (term) {
                !term.refined()? count ++ : null;
            });

            return count > 0
        }
    });
    self.toggleState = function () {
        switch (self.state()){
            case 'Expanded':
              self.state('Collapsed');
              break;
            case 'Collapsed':
              self.state('Expanded');
              break;
        }
    };

    self.ref = facet.ref;

    self.getTerms = function (terms) {
        var terms = $.map(terms || [], function (term, index) {
            term.facet = self;
            switch (self.type){
                case 'date':
                    return new FacetDateViewModel(term);
                    break;
                default:
                    return new FacetTermViewModel(term);
                    break;
            }
        });
        return terms;
    };

    self.terms(self.getTerms(facet.terms));

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
    };

    /**
     * Get the whole set of terms for this facets. The list only shows first 15.
     */
    self.loadMoreTerms = function () {
        self.ref.getFacetTerms(self);
    };

    self.showChooseMore = function () {
        if(self.type == 'date'){
            return false;
        } else {
            var terms = self.terms() || [];
            if(terms.length >= self.ref.flimit){
                return true;
            }

            return false
        }
    };
};

function FacetTermViewModel(term) {
    var self = this;
    if (!term) term = {};

    self.selected = ko.observable(false);
    self.facet = term.facet;
    self.count = ko.observable(term.count);
    self.term = ko.observable(term.term);
    self.title = term.title;
    self.displayName = ko.computed(function(){
        var label = self.title || decodeCamelCase(self.term()) || 'Unknown';
        if(self.count()){
            label += " (" + self.count() + ")";
        }

        return label
    });

    self.showTerm = ko.observable(term.showTerm || true);
    self.id = ko.observable(generateTermIdForFacetTerm(self));
    self.checked = ko.observable(false);
    self.silent = ko.observable(false);
    self.refined = ko.observable(false);
    self.exclude = term.exclude || false;


    self.displayNameWithoutCount = function(){
        return self.title || decodeCamelCase(self.term()) || 'Unknown';
    };

    /**
     * constructs a facet term so that it can be passed as fq value.
     * @returns {string}
     */
    self.getQueryText = function(){
        var prefix = self.exclude? '-':'';
        return prefix + self.facet.name() +':' + self.term();
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

function DatePickerViewModel(date) {
    var self = this;
    self.fromDate = ko.observable().extend({simpleDate:false});
    if(date.fromDate){
        self.fromDate.date(new Date(date.fromDate));
    }

    self.toDate = ko.observable().extend({simpleDate:false});
    if(date.toDate){
        self.toDate.date(new Date(date.toDate));
    }

    /**
     * get from and to date in format yyyy-mm-dd
     * @returns {string}
     */
    self.getParams = function(){
        var params = {};

        if(self.fromDate()){
            params.fromDate = getYearMonthDate(self.fromDate.date());
        }

        if(self.toDate()){
            params.toDate = getYearMonthDate(self.toDate.date());
        }

        return params;
    };
   
};

function generateTermIdForFacetTerm(facetTerm) {
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

function getYearMonthDate(date){
    if(date){
        var str = date.getFullYear() + '-' + pad(date.getMonth() + 1, 2) + '-' + pad(date.getDate(), 2);
        return str;
    }
}