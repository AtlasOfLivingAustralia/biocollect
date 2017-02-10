
var ProjectActivity = function (params) {
    if(!params) params = {};
    var pActivity = params.pActivity ? params.pActivity : {};
    var pActivityForms = params.pActivityForms ? params.pActivityForms : [];
    var projectId = params.projectId ? params.projectId : "";
    var selected = params.selected ? params.selected : false;
    var sites = params.sites ? params.sites : [];
    var startDate = params.startDate ? params.startDate : "";
    var organisationName = params.organisationName ? params.organisationName : "";
    var project = params.project ? params.project : {};
    var user = params.user ? params.user : {};
    var vocabList = params.vocabList ? params.vocabList : {};

    var self = $.extend(this, new pActivityInfo(pActivity, selected, startDate, organisationName));

    self.project = project;

    self.projectId = ko.observable(pActivity.projectId ? pActivity.projectId : projectId);
    self.restrictRecordToSites = ko.observable(pActivity.restrictRecordToSites);
    self.allowAdditionalSurveySites = ko.observable(pActivity.allowAdditionalSurveySites);
    self.baseLayersName = ko.observable(pActivity.baseLayersName);

    var speciesFields = pActivity.speciesFields || [];
    self.speciesFields = ko.observableArray($.map(speciesFields, function (obj, i) {
        return new SpeciesFieldViewModel(obj);
    }));

    self.pActivityFormName = ko.observable(pActivity.pActivityFormName);
    self.pActivityFormName.extend({rateLimit: 100});

    var images = [];
    $.each(pActivityForms, function (index, form) {
        if (form.name == self.pActivityFormName()) {
            images = form.images ? form.images : [];
        }
    });

    self.pActivityFormImages = ko.observableArray($.map(images, function (obj, i) {
        return new ImagesViewModel(obj);
    }));

    self.pActivityForms = pActivityForms;

    self.updateFormImages = function (formName) {
        self.pActivityFormImages.removeAll();
        $.each(self.pActivityForms, function (index, form) {
            if (form.name == formName && form.images) {
                for (var i = 0; i < form.images.length; i++) {
                    self.pActivityFormImages.push(new ImagesViewModel(form.images[i]));
                }
            }
        });
    }

    self.transients.oldFormName = self.pActivityFormName();
    self.transients.allowFormNameChange = false;

    // 1. There is no straightforward way to prevent/cancel a KO change in a beforeChange subscription
    // 2. bootbox.confirm is totally asynchronous so by the time a user confirms or rejects a change, the change has already happened.
    // 2a. There is no good reason to call standard confirm which would block the thread.
    // 3. Trying to use jQuery to prevent event propagation might turn a pain as it would potentially get on the way with ko observables
    // Hence the approach taken is to mimic a user rejection by reverting the old value.
    // We can't prevent the value of the select to be changed from bootbox.confirm but we can update dependable properties
    // only when a user has accepted the change.

    self.pActivityFormName.subscribe(function(oldValue) {
        self.transients.oldFormName = oldValue;
    }, null, "beforeChange");

    // Flag to prevent infinite event firing.
    // self.pActivityFormName is changed within a subscription to it
    self.transients.revertFormNameChange = false;

    self.pActivityFormName.subscribe(function(newValue) {
        if(!self.transients.revertFormNameChange) { // Normal interaction of user with  UI select control
            if(self.speciesFields().length > 0) {
                bootbox.confirm("There is specific fields configuration for this survey in the Species tab. Changing the form will override existing settings. Do you want to continue?", function (result) {
                    // Asynchronous call, too late to prevent change but depending on the user response we either:
                    // a) Restore the previous value in the select or
                    // b) Let dependent pActivityFormName fields to be updated, ko already updated the pActivityFormName
                    self.transients.allowFormNameChange = result
                    if (result) {
                        self.retrieveSpeciesFieldsForFormName(self.pActivityFormName());
                        self.updateFormImages(self.pActivityFormName());
                    } else {
                        console.log("reverting form to previous value" + self.transients.oldFormName);
                        self.pActivityFormName(self.transients.oldFormName);
                        // Stop infinite loop propagation.
                        self.transients.revertFormNameChange = true;
                    }
                });
            } else { // No need of user confirmation, let's update pActivityFormName dependent properties
                self.retrieveSpeciesFieldsForFormName(self.pActivityFormName());
                self.updateFormImages(self.pActivityFormName());
            }
        } else {
            // User chose to cancel change to pActivityFormName, self.pActivityFormName already had the old value
            // let's just re-enable the normal event propagation behavior
            self.transients.revertFormNameChange = false;
        }
    });


    /**
     * Retrieves the species fields and overrides self.speciesFields with them
     * If the species fields for this form is 0 or 1 only then  self.speciesFields will be set to an empty array
     * @param formName The new form name
     */
    self.retrieveSpeciesFieldsForFormName = function(formName) {
        var divId = 'project-activities-result-placeholder';
        $.ajax({
            url: fcConfig.getSpeciesFieldsForSurveyUrl+'/' + formName,
            type: 'GET',
            // data: model,
            // contentType: 'application/json',
            success: function (data) {
                if (data.error) {
                    showAlert("Error :" + data.error, "alert-error", divId);
                }
                else {
                    self.speciesFields.removeAll();

                    // Only one species field in the form, don't bother with its configuration
                    if(data.result && data.result.length > 1) {
                        $.map(data.result ? data.result : [], function (obj, i) {
                            self.speciesFields.push(new SpeciesFieldViewModel(obj));
                        });
                    }
                }
            },
            error: function (data) {
                showAlert("Error : An unhandled error occurred" + data.status, "alert-error", divId);
            }
        });
    }


    /**
     * @deprecated species was the original field were survey species configuration was stored.
     * Since the introduction of per species field configuration the field to store information will be self.speciesFields
     */
    self.species = ko.observable(new SpeciesConstraintViewModel(pActivity.species));

    self.showSpeciesConfiguration = function(speciesConstraintVM, fieldName, index) {
        // Create a copy to bind to the field config dialog otherwise we may change the main screen values inadvertenly
        speciesConstraintVM = new SpeciesConstraintViewModel(speciesConstraintVM.asJson(), fieldName);
        if(index) {
            speciesConstraintVM.speciesOptions.push({id: 'DEFAULT_SPECIES', name:'Use default configuration'});
        }

        showSpeciesFieldConfigInModal(speciesConstraintVM, '#configureSpeciesFieldModal', '#speciesFieldDialog')
            .done(function(result){
                    if(index) { //Update a particular species field configuration
                        var newSpeciesConstraintVM = new SpeciesConstraintViewModel(result)
                         newSpeciesConstraintVM.speciesOptions.push({id: 'DEFAULT_SPECIES', name:'Use default configuration'});
                        self.speciesFields()[index()].config(newSpeciesConstraintVM);
                    } else { // Update species default configuration
                        self.species(new SpeciesConstraintViewModel(result));
                    }
                }
            );
    }
    /**
     * Determine if each species defined in this survey are valid in order for the Survey to be Publishable
     * This is an agregation of the SpeciesConstraintViewModel#isValid as now we have, potentially, more than
     * one species configuration
     */
    self.areSpeciesValid = function() {

        // As soon as a field is not valid we stop

        if(!self.species().isValid()){
            return false;
        }

        var speciesFields = self.speciesFields();

        for (var i = 0; i < speciesFields.length; i++) {
            if(!speciesFields[i].config().isValid()) {
                return false;
            }
        }
        return true;
    }

    self.visibility = new SurveyVisibilityViewModel(pActivity.visibility);
    self.alert = new AlertViewModel(pActivity.alert);

    self.usageGuide = ko.observable(pActivity.usageGuide ? pActivity.usageGuide : "");

    self.relatedDatasets = ko.observableArray (pActivity.relatedDatasets ? pActivity.relatedDatasets : []);

    self.typeFor = ko.observableArray(pActivity.typeFor ? pActivity.typeFor : [])
    self.typeSeo = ko.observableArray(pActivity.typeSeo ? pActivity.typeSeo : [])
    self.typeResearch = ko.observableArray(pActivity.typeResearch ? pActivity.typeResearch : [])
    self.typeThreat = ko.observableArray(pActivity.typeThreat ? pActivity.typeThreat : [])
    self.typeConservation = ko.observableArray(pActivity.typeConservation ? pActivity.typeConservation : [])

    self.lastUpdated = ko.observable(pActivity.lastUpdated ? pActivity.lastUpdated : "");

    self.dataSharingLicense = ko.observable(pActivity.dataSharingLicense ? pActivity.dataSharingLicense : "CC BY");

    self.transients = self.transients || {};
    self.transients.warning = ko.computed(function () {
        return self.projectActivityId() === undefined ? true : false;
    });
    self.transients.disableEmbargoUntil = ko.computed(function () {
        if(self.visibility.embargoOption() != 'DATE'){
            return true;
        }

        return false;
    });

    self.transients.availableSpeciesDisplayFormat = ko.observableArray([{
        id:'SCIENTIFICNAME(COMMONNAME)',
        name: 'Scientific name (Common name)'
    },{
        id:'COMMONNAME(SCIENTIFICNAME)',
        name: 'Common name (Scientific name)'
    },{
        id:'COMMONNAME',
        name: 'Common name'
    },{
        id:'SCIENTIFICNAME',
        name: 'Scientific name'
    }])

    var legalCustodianVal = ko.utils.unwrapObservable(project.legalCustodianOrganisation);

    if (legalCustodianVal != "" && organisationName != legalCustodianVal) {
        self.transients.custodianOptions = [organisationName, legalCustodianVal];
    } else {
        self.transients.custodianOptions = [organisationName];
    }

    self.transients.selectedCustodianOption = legalCustodianVal;

    self.sites = ko.observableArray();
    self.loadSites = function (projectSites, surveySites) {
        $.map(projectSites ? projectSites : [], function (obj, i) {
            var defaultSites = [];
            surveySites && surveySites.length > 0 ? $.merge(defaultSites, surveySites) : defaultSites.push(obj.siteId);
            self.sites.push(new SiteList(obj, defaultSites));
        });
    };
    self.loadSites(sites, pActivity.sites);

    // AEKOS submission records
    var submissionRecs = pActivity.submissionRecords ? pActivity.submissionRecords : [];

    submissionRecs.sort(function(b, a) {
        var v1 = parseInt(a.datasetVersion.substr(7, 8))
        var v2 = parseInt(b.datasetVersion.substr(7, 8))
        if (v1 < v2) {
            return -1;
        }
        if (v1 > v2) {
            return 1;
        }

        // names must be equal
        return 0;
    });

    var sortedSubmissionRecs = submissionRecs.sort();

    self.submissionRecords = ko.observableArray();

    self.loadSubmissionRecords = function (submissionRecs) {
        $.map(submissionRecs ? submissionRecs : [], function (obj, i) {
            self.submissionRecords.push(new SubmissionRec(obj.submissionPublicationDate, obj.datasetSubmitter, obj.datasetVersion, obj.submissionDoi));
        });
    };
    self.loadSubmissionRecords(sortedSubmissionRecs);

    var methodName = pActivity.methodName? pActivity.methodName : "";

    if ((pActivity.sites ? pActivity.sites.length : 0) > 0 && methodName != "") {
        self.transients.isAekosData = ko.observable(true);
    } else {
        self.transients.isAekosData = ko.observable(false);
    }

    /*   self.showModal = function (pActivity) {
     self.modal = ko.observable(new AekosWorkflowViewModel(pActivity));

     } */

    // New fields for Aekos Submission
    self.environmentalFeatures = ko.observableArray();
    self.environmentalFeaturesSuggest = ko.observable();

    self.transients.titleOptions = ['Assoc Prof', 'Dr', 'Miss', 'Mr', 'Mrs', 'Miss', 'Prof'];

    self.datasetContactRole = ko.observable('');
    self.datasetContactDetails = ko.observable('');
    self.datasetContactEmail = ko.observable('');
    self.datasetContactName = ko.observable('');
    self.datasetContactPhone = ko.observable('');
    self.datasetContactAddress = ko.observable('');

    self.authorGivenNames = ko.observable('');
    self.authorSurname = ko.observable('');
    self.authorAffiliation = ko.observable('');

   /* self.showModal = function () {
        //  self.aekosModal(true);
        self.aekosModalView().show(true);
        $('.modal')[0].style.width = '90%'
        $('.modal')[0].style.height = '80%'
    };
*/

    /**
     * get number of sites selected for a survey
     * @returns {number}
     */
    self.getNumberOfSitesForSurvey = function () {
        var count = 0;
        var sites = self.sites();
        sites.forEach(function(site){
            if(site.added()){
                count ++;
            }
        });
        return count;
    }

    self.asJSAll = function () {
        var jsData = $.extend({},
            self.asJS("info"),
            self.asJS("access"),
            self.asJS("form"),
            self.asJS("species"),
            self.asJS("visibility"),
            self.asJS("alert"),
            self.asJS("sites"));
        return jsData;
    };

    self.asJS = function (by) {
        var jsData;

        if (by == "form") {
            jsData = {};
            jsData.pActivityFormName = self.pActivityFormName();
        }
        else if (by == "info") {
            var ignore = self.ignore.concat(['current', 'pActivityForms', 'pActivityFormImages',
                'access', 'species', 'sites', 'transients', 'endDate','visibility','pActivityFormName', 'restrictRecordToSites',
                'allowAdditionalSurveySites', 'baseLayersName', 'aekosModalView', 'project']);
            ignore = $.grep(ignore, function (item, i) {
                return item != "documents";
            });
            jsData = ko.mapping.toJS(self, {ignore: ignore});
            jsData.endDate = moment(self.endDate(), 'YYYY-MM-DDThh:mm:ssZ').isValid() ? self.endDate() : "";
        }
        else if (by == "species") {
            jsData = {};
            jsData.species = self.species().asJson();

            jsData.speciesFields = $.map(self.speciesFields(), function (obj, i) {
                return obj.asJson();
            });
        }
        else if (by == "sites") {
            jsData = {};
            var sites = [];
            $.each(self.sites(), function (index, site) {
                if (site.added()) {
                    sites.push(site.siteId());
                }
            });
            jsData.sites = sites;
            jsData.restrictRecordToSites = self.restrictRecordToSites();
            jsData.allowAdditionalSurveySites = self.allowAdditionalSurveySites();
            jsData.baseLayersName = self.baseLayersName();
        }
        else if (by == "visibility") {
            jsData = {};
            var ignore = self.ignore.concat(['transients']);
            jsData.visibility = ko.mapping.toJS(self.visibility, {ignore: ignore});
        }
        else if (by == "alert") {
            jsData = {};
            var ignore = self.ignore.concat(['transients']);
            jsData.alert = ko.mapping.toJS(self.alert, {ignore: ignore});
        }

        return jsData;
    }

    self.aekosModalView = ko.observable(new AekosViewModel (self, project, user, vocabList));

    //self.aekosModal = ko.observable(false);

    self.showModal = function () {
        //  self.aekosModal(true);
        self.aekosModalView().show(true);
    };

};


// Custom binding for modal dialog
ko.bindingHandlers.bootstrapShowModal = {
    init: function (element, valueAccessor) {
    },
    update: function (element, valueAccessor) {
        var value = valueAccessor();

        if (ko.utils.unwrapObservable(value)) {
            $(element).modal('show');
            // this is to focus input field inside dialog
            $("input", element).focus();
        }
        else {
            $(element).modal('hide');
        }
    }
};

var SiteList = function (o, surveySites) {
    var self = this;
    if (!o) o = {};
    if (!surveySites) surveySites = {};

    self.siteId = ko.observable(o.siteId);
    self.name = ko.observable(o.name);
    self.added = ko.observable(false);
    self.siteUrl = ko.observable(fcConfig.siteViewUrl + "/" + self.siteId());
    self.ibra = ko.observable(o.extent.geometry.ibra)

    self.addSite = function () {
        self.added(true);
    };
    self.removeSite = function () {
        self.added(false);
    };

    self.load = function (surveySites) {
        $.each(surveySites, function (index, siteId) {
            if (siteId == self.siteId()) {
                self.added(true);
            }
        });
    };
    self.load(surveySites);

};

var ImagesViewModel = function (image) {
    var self = this;
    if (!image) image = {};

    self.thumbnail = ko.observable(image.thumbnail);
    self.url = ko.observable(image.url);
};

var SurveyVisibilityViewModel = function (visibility) {
    var self = this;
    if (!visibility) {
        visibility = {};
    }

    self.embargoOption = ko.observable(visibility.embargoOption ? visibility.embargoOption : 'NONE');   // 'NONE', 'DAYS', 'DATE' -> See au.org.ala.ecodata.EmbargoOptions in Ecodata

    self.embargoForDays = ko.observable(visibility.embargoForDays ? visibility.embargoForDays : 10).extend({numeric:0});     // 1 - 180 days
    self.embargoUntil = ko.observable(visibility.embargoUntil).extend({simpleDate: true});
};

var AlertViewModel = function (alert) {
    var self = this;
    if (!alert) alert = {};
    self.allSpecies = ko.observableArray();
    self.emailAddresses = ko.observableArray();

    self.add = function () {
        if (!$('#project-activities-alert-validation').validationEngine('validate')) {
            return;
        }
        var species = {};
        species.name = self.transients.species.name();
        species.guid = self.transients.species.guid();

        var match = ko.utils.arrayFirst(self.allSpecies(), function(item) {
            return species.guid === item.guid();
        });

        if (!match) {
            self.allSpecies.push(new SpeciesViewModel(species));
        }
        self.transients.species.reset();
    };
    self.delete = function (species) {
        self.allSpecies.remove(species);
    };

    self.addEmail = function () {
        var emails = [];
        emails = self.transients.emailAddress().split(",");
        var invalidEmail = false;
        var message = "";
        $.each(emails, function (index, email) {
            if (!self.validateEmail(email)) {
                invalidEmail = true;
                message = email;
                return false;
            }
        });

        if (invalidEmail) {
            showAlert("Invalid email address (" + message + ")", "alert-error", "project-activities-result-placeholder");
        } else {
            $.each(emails, function (index, email) {
                if (self.emailAddresses.indexOf(email) < 0) {
                    self.emailAddresses.push(email);
                }
            });
            self.transients.emailAddress('');
        }
    };

    self.deleteEmail = function (email) {
        self.emailAddresses.remove(email);
    };

    self.transients = {};
    self.transients.species = new SpeciesViewModel();
    self.transients.emailAddress = ko.observable();
    self.transients.disableSpeciesAdd  = ko.observable(true);
    self.transients.disableAddEmail  = ko.observable(true);
    self.transients.emailAddress.subscribe(function(email) {
        return email ? self.transients.disableAddEmail(false): self.transients.disableAddEmail(true);
    });
    self.transients.species.guid.subscribe(function(guid) {
        return guid ? self.transients.disableSpeciesAdd(false) : self.transients.disableSpeciesAdd(true);
    });

    self.validateEmail = function(email){
        var expression = /^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i;
        return expression.test(email);
    };

    self.transients.bioProfileUrl = fcConfig.bieUrl + '/species/';
    self.transients.bioSearch = ko.observable(fcConfig.speciesSearchUrl);
    self.loadAlert = function (alert) {
        self.allSpecies($.map(alert.allSpecies ? alert.allSpecies : [], function (obj, i) {
                return new SpeciesViewModel(obj);
            })
        );

        self.emailAddresses($.map(alert.emailAddresses ? alert.emailAddresses : [], function (obj, i) {
                return obj;
            })
        );
    };

    self.loadAlert(alert);
};

/**
 * Custom validation function (used by the jquery-validation-engine), defined on the embargoUntil date field on the
 * survey admin visibility form
 */
function isEmbargoDateRequired(field, rules, i, options) {
    if ($('#embargoOptionDate:checked').val()) {
        if ($('#embargoUntilDate').val() == "") {
            rules.push('required');
        } else {
            var date = convertToIsoDate($('#embargoUntilDate').val(), 'dd-MM-yyyy');
            if (moment(date).isBefore(moment())) {
                return "The date must be in the future";
            } else if (moment(date).isAfter(new Date().setMonth(new Date().getMonth() + 12))) {
                return "The date cannot be more than 12 months in the future";
            }
        }
    }
}

function initialiseValidator() {
    var tabs = ['info', 'species', 'form', 'access', 'visibility', 'alert'];
    $.each(tabs, function (index, label) {
        $('#project-activities-' + label + '-validation').validationEngine();
    });
};
