//= require knockout/3.4.0/knockout-3.4.0.js
//= require knockout/3.4.0/knockout-3.4.0.debug.js

var RequestAssessmentRecordsModel = function(filterGroupMapping){
    const self = this;
    this.filters = Object.keys(filterGroupMapping);
    this.selected = ko.observableArray([]);
    this.deIdentify = ko.observable(false);
    this.isLoading = ko.observable(false);

    this.isFilterSelected = function(filter) {
        return self.selected.indexOf(filter) > -1;
    }

    this.onFilterSelect = function(filter) {
        // Only allow for user interaction if we're not already loading a request
        if (!self.isLoading()) {
            if (self.isFilterSelected(filter)) {
                self.selected.remove(filter);
            } else {
                self.selected.push(filter);
            }
        }
    }

    this.onRequestRecords = function() {
        // Update the loading flag
        self.isLoading(true);

        const selectedGroups = self.selected().map((filter) => filterGroupMapping[filter]);
        const unique = Array.from(new Set(selectedGroups))

        console.log(unique, self.deIdentify());
    }
}