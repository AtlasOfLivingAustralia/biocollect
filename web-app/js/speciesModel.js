
/**
 * Manages the species data type in the output model.
 * Allows species information to be searched for and displayed.
 */
var SpeciesViewModel = function(data, speciesLists) {

    var self = this;
    self.guid = ko.observable();
    self.name = ko.observable();
    self.listId = ko.observable();
    self.transients = {};
    self.transients.speciesInformation = ko.observable();
    self.transients.availableLists = speciesLists;
    self.transients.editing = ko.observable(false);
    self.transients.textFieldValue = ko.observable();
    self.transients.bioProfileUrl =  ko.computed(function (){
        return  fcConfig.bieUrl + '/species/' + self.guid();
    });

    self.speciesSelected = function(event, data) {
        if (!data.listId) {
            data.listId = self.listId();
        }

        self.loadData(data);
        self.transients.editing(!data.name);
    };

    self.textFieldChanged = function(newValue) {
        if (newValue != self.name()) {
            self.transients.editing(true);
        }
    };

    self.listName = function(listId) {
        if (listId == 'Atlas of Living Australia') {
            return listId;
        }
        var name = '';
        $.each(self.transients.availableLists, function(i, val) {
            if (val.listId === listId) {
                name = val.listName;
                return false;
            }
        });
        return name;
    };

    self.renderItem = function(row) {

        var term = self.transients.textFieldValue();

        var result = '';
        if (!row.listId) {
            row.listId = 'Atlas of Living Australia';
        }
        if (row.listId !== 'unmatched' && row.listId !== 'error-unmatched' && self.renderItem.lastHeader !== row.listId) {
            result+='<div style="background:grey;color:white; padding-left:5px;"> '+self.listName(row.listId)+'</div>';
        }
        // We are keeping track of list headers so we only render each one once.
        self.renderItem.lastHeader = row.listId ? row.listId : 'Atlas of Living Australia';
        result+='<a class="speciesAutocompleteRow">';
        if (row.listId && row.listId === 'unmatched') {
            result += '<i>Unlisted or unknown species</i>';
        }
        else if (row.listId && row.listId === 'error-unmatched') {
            result += '<i>Offline</i><div>Species:<b>'+row.name+'</b></div>';
        }
        else {

            var commonNameMatches = row.commonNameMatches !== undefined ? row.commonNameMatches : "";

            result += (row.scientificNameMatches && row.scientificNameMatches.length>0) ? row.scientificNameMatches[0] : commonNameMatches ;
            if (row.name != result && row.rankString) {
                result = result + "<div class='autoLine2'>" + row.rankString + ": " + row.name + "</div>";
            } else if (row.rankString) {
                result = result + "<div class='autoLine2'>" + row.rankString + "</div>";
            }
        }
        result += '</a>';
        return result;
    };
    self.loadData = function(data) {
        if (!data) data = {};
        self['guid'](orBlank(data.guid));
        self['name'](orBlank(data.name));
        self['listId'](orBlank(data.listId));

        self.transients.textFieldValue(self.name());
        if (self.guid()) {

            var profileUrl = fcConfig.bieUrl + '/species/' + self.guid();
            $.ajax({
                url: fcConfig.speciesProfileUrl+'/' + self.guid(),
                dataType: 'json',
                success: function (data) {
                    var profileInfo = '<a href="'+profileUrl+'" target="_blank">';
                    var imageUrl = data.taxonConcept.smallImageUrl;
                    if (imageUrl) {
                        profileInfo += "<img title='Click to show profile' class='taxon-image ui-corner-all' src='"+imageUrl+"'>";
                    }
                    else {
                        profileInfo += "No profile image available";
                    }
                    profileInfo += "</a>";
                    self.transients.speciesInformation(profileInfo);
                },
                error: function(request, status, error) {
                    console.log(error);
                }
            });
        }
        else {
            if (self.listId() === 'unmatched') {
                self.transients.speciesInformation("This species was unable to be matched in the Atlas of Living Australia.");
            }
            else {
                self.transients.speciesInformation("No profile information is available.");
            }
        }

    };
    self.list = ko.computed(function() {
        if (self.transients.availableLists.length) {
            // Only supporting a single species list per activity at the moment.
            return self.transients.availableLists[0].listId;
        }
        return '';
    });

    if (data) {
        self.loadData(data);
    }
    self.focusLost = function(event) {
        self.transients.editing(false);
        if (self.name()) {
            self.transients.textFieldValue(self.name());
        }
        else {
            self.transients.textFieldValue('');
        }
    };


};