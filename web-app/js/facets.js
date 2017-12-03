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
var BIOCOLLECT_ALA_FACET_MAPPING = {
    'recordNameFacet':'taxon_name',
    'surveyYearFacet': 'year',
    'userId': 'alau_user_id',
    'projectNameFacet':undefined,
    'organisationNameFacet':undefined,
    'projectActivityNameFacet':undefined,
    'embargoedFacet':undefined,
    'surveyMonthFacet': {
        'name': 'month',
        'transform': function (month) {
            var months = {"january":"01", "february":"02", "march":"03", "april":"04", "may":"05", "june":"06", "july":"07", "august":"08", "september":"09", "october":"10", "november":"11", "december":"12"}
            month = (month || '').toLowerCase()
            return months[month]
        }
    }
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


    self.createFacetViewModel = function (facet) {
        var facetVm;
        facet.ref = self;
        switch (facet.type) {
            case 'date':
                facetVm = new DatePickerViewModel(facet);
                break;
            default:
                facetVm = new FacetViewModel(facet);
                break;
        }

        return facetVm;
    };
    /**
     * Function for initialising facets.
     * @param facets
     */
    self.setFacets = function (facets) {
        self.facets($.map(facets, function (facet) {
            self.restoreFacetState(facet);
            var facetVm = self.createFacetViewModel(facet);
            self.setFacetTerm(facetVm);
            return facetVm;
        }))
    };

    /**
     * Get facet state set by the user and make sure the current facet preserves it.
     * @param facet
     */
    self.restoreFacetState = function (facet) {
        var previousFacets = self.facets();
        var prevFacet = $.grep(previousFacets, function(pFacet){
            return pFacet.name() == facet.name;
        });

        if(prevFacet && (prevFacet.length == 1)){
            facet.state = prevFacet[0].state();
        }
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

                if(FacetRangeViewModel.isRangeQuery(nameAndValue[1])){
                    var range = FacetRangeViewModel.parseRangeQuery(nameAndValue[1]);
                    if(isValidDate(new Date(range.to)) || isValidDate(new Date(range.from))){
                        facet = new DatePickerViewModel({ name: nameAndValue[0], to: range.to, from: range.from, ref: self, type: 'range'});
                        self.addToRefineList (facet.term);
                    } else {
                        facet = new FacetViewModel({ name: nameAndValue[0], ranges: [{term:nameAndValue[1], exclude: exclude}], ref: self, type: 'range'});
                        self.addToRefineList (facet.terms()[0]);
                    }
                } else {
                    facet = new FacetViewModel({ name: nameAndValue[0], terms: [{term:nameAndValue[1], exclude: exclude}], ref: self, type: 'terms'});
                    self.addToRefineList (facet.terms()[0]);
                }
            });
        }
    };

    /**
     * Get a list of facets that can be used to query ALA systems
     * @returns {Array}
     */
    self.getALACompatibleQuery = function () {
        var facetGroup = {}, facets = [];
        self.selectedFacets().forEach(function (term) {
            var name = term.facet.name();
            if(!facetGroup[name]){
                facetGroup[name] = [];
            }

            facetGroup[name].push(term.getALACompatibleQueryText());
        });

        for( var key in facetGroup){
            facets.push(facetGroup[key].join(' OR '));
        }

        return facets;
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
            var facet = facets && $.grep(facets, function (facet) {
                return facet.name == facetVM.name()
            });

            if(facet && (facet.length == 1)){
                var terms = facetVM.getTerms(facet[0]);
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
    self.title = facet.title;
    self.total = ko.observable(facet.total);
    self.terms = ko.observableArray();
    self.filter = ko.observable(false);
    self.helpText = ko.observable(facet.helpText);
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
        self.terms().forEach(function (term) {
            !term.refined()? count ++ : null;
        });

        return count > 0
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

    self.getTerms = function (facet) {
        switch (facet.type){
            case 'terms':
                var terms = $.map(facet.terms || [], function (term, index) {
                    term.facet = self;
                    return new FacetTermViewModel(term);
                });
                return terms;
                break;
            case 'range':
                var ranges = $.map(facet.ranges || [], function (term, index) {
                    term.facet = self;
                    return new FacetRangeViewModel(term);
                });
                return ranges;
                break;
        }
    };

    self.terms(self.getTerms(facet));

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
        switch (self.type){
            case 'terms':
                var terms = self.terms() || [];
                if(terms.length >= self.ref.flimit){
                    return true;
                }

                return false;
            case 'ranges':
                return false;
        }
    };

    /**
     * translate Biocollect facet name to a format understood by ALA systems like Biocache, Spatial portal etc.
     * @returns {*}
     */
    self.nameALAFormat = function () {
        var mapName = BIOCOLLECT_ALA_FACET_MAPPING[self.name()];
        if(mapName && mapName.name){
            return mapName.name
        }

        return mapName;
    };

    /**
     * Some facets need to be transformed since Biocollect and ALA system represent data differently
     * example month - Biocollect represents them as 'January', 'February' etc. But ALA represent them as 01, 02 etc.
     */
    self.transformValueToALAFormat = function (value) {
        var map = BIOCOLLECT_ALA_FACET_MAPPING[self.name()];
        if(map && map.transform){
            return map.transform(value)
        }

        return value
    };
};

function FacetTermViewModel(term) {
    var self = this;
    if (!term) term = {};

    self.type = 'term';
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
     * constructs a query that can be understood by Atlas of Living Australia systems like biocache
     * @returns {string}
     */
    self.getALACompatibleQueryText = function(){
        var name = self.facet.nameALAFormat();
        if(name){
            var prefix = self.exclude? '-':'';
            var term = self.term() || "";
            term = self.facet.transformValueToALAFormat(term);
            if(typeof term === 'string'){
                term = term.replace(/ /g,"+");
            }
            return prefix + name +':"' + term + '"';
        }
    };

    /**
     * toggle checked status
     */
    self.filterNow = function () {
        self.silent(true);
        self.checked(true);
        self.silent(false);
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

function FacetRangeViewModel(term) {
    var self = this;
    if (!term) term = {};

    self.type = 'range';
    self.selected = ko.observable(false);
    self.facet = term.facet;
    self.count = ko.observable(term.count);
    self.to = ko.observable(term.to);
    self.from = ko.observable(term.from);
    self.title = term.title;
    self.term = ko.observable();
    self.displayName = ko.computed(function(){
        var label = self.title || generateTitle() || 'Unknown';
        if(self.count()){
            label += " (" + self.count() + ")";
        }

        return label
    });

    self.showTerm = ko.observable(term.showTerm || true);
    // self.id = ko.observable(generateTermIdForFacetTerm(self));
    self.checked = ko.observable(false);
    self.silent = ko.observable(false);
    self.refined = ko.observable(false);
    self.exclude = term.exclude || false;


    function generateTitle() {
        var label = '';
        if(self.from() != undefined){
            label += 'from ' + self.from();
        }

        if(self.to() != undefined){
            label += ' to < ' + self.to();
        }

        return label;
    };

    self.displayNameWithoutCount = function(){
        return self.title|| generateTitle() || 'Unknown';
    };

    /**
     * constructs a facet term so that it can be passed as fq value.
     * @returns {string}
     */
    self.getQueryText = function(){
        var prefix = self.exclude? '-':'';
        var to, from;

        if((self.to() == undefined)){
            to = '*'
        } else {
            to = self.to()
        }

        if((self.from() == undefined)){
            from = '*'
        } else {
            from = self.from()
        }


        return prefix + self.facet.name() + ':' + '[' + from + ' TO ' + to + '}';
    };

    /**
     * constructs a query that can be understood by Atlas of Living Australia systems like biocache
     * @returns {string}
     */
    self.getALACompatibleQueryText = function(){
        var name = self.facet.nameALAFormat();
        if(name){
            var prefix = self.exclude? '-':'';
            var term = self.term() || "";
            term = self.facet.transformValueToALAFormat(term);
            if(typeof term === 'string'){
                term = term.replace(/ /g,"+");
            }
            return prefix + name +':"' + term + '"';
        }
    };

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

FacetRangeViewModel.isRangeQuery = function (query) {
    var regExp = new RegExp(/([\[\{])(.*) TO (.*)([\]\}])/);
    var execResult = regExp.exec(query);
    if(execResult && execResult.length > 1){
        return true
    }

    return false
};

FacetRangeViewModel.parseRangeQuery = function (query) {
    var regExp = new RegExp(/([\[\{])(.*) TO (.*)([\]\}])/);
    var result = {};
    var execResult = regExp.exec(query);

    if(execResult && execResult.length > 1){
        if(execResult[2] != '*'){
            result.from = execResult[2];
        }

        if(execResult[3] != '*'){
            result.to = execResult[3]
        }
    }

    return result
};

function DatePickerViewModel(config) {
    var self = this;
    var element;
    self.ref = config.ref;
    self.title = config.title;
    self.state = ko.observable(config.state || 'Collapsed');
    self.name = ko.observable(config.name);
    self.displayName = ko.observable(config.displayName || config.title);
    self.helpText = ko.observable(config.helpText);
    self.fromDate = ko.observable(config.fromDate).extend({simpleDate:false});
    self.toDate = ko.observable(config.toDate).extend({simpleDate:false});
    self.type = config.type;
    self.term = new FacetRangeViewModel({
        facet: self,
        to: config.to,
        from: config.from
    });
    self.doNotUpdate = ko.observable(false);

    self.fromDate.subscribe(function () {
        self.term.from(getYearMonthDate(self.fromDate.date()));
        self.updateSelectedFacets();
    });

    self.toDate.subscribe(function () {
        self.term.to(getYearMonthDate(self.toDate.date()));
        self.updateSelectedFacets();
    });

    self.setTermState = function () {
        self.ref.selectedFacets().forEach(function (term) {
            if(term.facet.name() == self.name()){
                if(term instanceof FacetRangeViewModel){
                    self.term = term;
                } else {
                    self.term = new FacetRangeViewModel(term);
                }

                self.doNotUpdate(true);
                self.term.to() && self.toDate.date(new Date(self.term.to()));
                self.term.from() && self.fromDate.date(new Date(self.term.from()));
                self.doNotUpdate(false);
            }
        });
    };

    /**
     * Update selected filter list with from or to date
     */
    self.updateSelectedFacets = function () {
        if(!self.doNotUpdate()){
            self.ref.switchOffSearch(true);
            self.ref.selectedFacets.remove(self.term);
            self.ref.switchOffSearch(false);
            self.ref.selectedFacets.push(self.term);
        }
    };

    /**
     * translate Biocollect facet name to a format understood by ALA systems like Biocache, Spatial portal etc.
     * @returns {*}
     */
    self.nameALAFormat = function () {
        var mapName = BIOCOLLECT_ALA_FACET_MAPPING[self.name()];
        if(mapName && mapName.name){
            return mapName.name
        }

        return mapName;
    };

    /**
     * This function is called on blur event
     * @param con
     */
    self.setContext = function (el) {
        if(el){
            element = el;
        }
    };

    /**
     * set properties of date picker view model.
     * @param config
     */
    self.loadFromConfig = function (config) {
        self.state(self.state() || config.state || 'Collapsed');
        self.displayName(config.title);
        self.helpText(config.helpText);
        if(config.fromDate){
            self.fromDate(new Date(config.fromDate));
        }

        if(config.toDate){
            self.toDate(new Date(config.toDate));
        }
    };

    /**
     * get from and to date in format yyyy-mm-dd
     * @returns {string}
     */
    self.getParams = function(){
        var params = {};

        if(self.fromDate.date().toString() !== "Invalid Date"){
            params.fromDate = getYearMonthDate(self.fromDate.date());
        }

        if(self.toDate.date().toString() !== "Invalid Date"){
            params.toDate = getYearMonthDate(self.toDate.date());
        }

        return params;
    };
    
    self.clearDates = function () {
        self.ref.selectedFacets.remove(self.term);
        self.doNotUpdate(true);
        self.fromDate.date('');
        self.toDate.date('');
        self.doNotUpdate(false);
    };

    self.showClearButton = function () {
        return self.fromDate() || self.toDate()
    };

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
};

function generateTermIdForFacetTerm(facetTerm) {
    var name, term
    name = facetTerm.facet.name()
    term = facetTerm.term()
    return name.replace(/[^a-zA-Z0-9]/g, "") + term.toString().replace(/[^a-zA-Z0-9]/g, "")
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
    if(typeof text == 'string'){
        var result = text.replace( /([A-Z])/g, " $1" );
        return result.charAt(0).toUpperCase() + result.slice(1); // capitalize the first letter - as an example.
    }
}

function cleanName(text) {
    text = text || '';
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