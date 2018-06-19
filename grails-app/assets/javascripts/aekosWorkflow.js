/**
 * @namespace
 */
var AEKOS = {};

AEKOS.AekosViewModel = function (pActivityVM, activityRec, projectViewModel, projectActivities, user, vocabList, projectArea, activityRecords) {

    var self = $.extend(this, pActivityVM);

    self.projectViewModel = projectViewModel;

    if (!self.projectViewModel.name) return;

    self.user = user;
    self.parentProjectActivities = projectActivities;

    self.transients.preQ = new AEKOS.PreQualification();

    self.transients.questions = self.transients.preQ.questions;

    qArray = self.transients.questions();

    self.transients.showAekosWorkflow = ko.observable(false);

    self.transients.cannotSubmitError = ko.observable('');

    self.transients.currentQuestion = ko.observable(1);

    self.yes = function () {
        if (qArray[self.transients.currentQuestion() - 1].exitAnswer != 'yes') {
            self.proceed ('Yes');
        } else {
            self.exitPreQualification ('Yes');
        }
    };

    self.no = function () {
        if (qArray[self.transients.currentQuestion() - 1].exitAnswer != 'no') {
            self.proceed ('No');
        } else {
            self.exitPreQualification ("No");
        }
    };

    self.proceed = function (answer) {
        if (qArray.length > self.transients.currentQuestion()) {
            self.transients.questions()[self.transients.currentQuestion() - 1].answer(answer);
            self.transients.currentQuestion(self.transients.currentQuestion() + 1);
        } else {
            self.loadAekosData();
            self.transients.showAekosWorkflow(true);
        };
    };

    self.exitPreQualification = function (answer) {
        self.transients.questions()[self.transients.currentQuestion() - 1].answer(answer);
        self.transients.cannotSubmitError(qArray[self.transients.currentQuestion() - 1].exitAnswerMsg);
    };

    self.validationFailed = ko.observable(false);

    self.datasetTitle = ko.computed(function() {
        return self.projectViewModel.organisationName() + ' - ' + self.name();
    });

    if (self.submissionRecords && self.submissionRecords().length > 0) {
        $.each(self.submissionRecords(), function (i, o) {
            if (o.submissionDoi() == "Draft") {
                self.currentSubmissionRecord = o;
                self.currentSubmissionPackage = o.submissionPackage;
            }
        });
    };

    var currentDatasetVersion = function () {
        var res = self.projectViewModel.name().substr(0, 3) + self.name().substr(0, 3);

        if (self.submissionRecords && self.submissionRecords().length > 0) {
            var datasetArray = $.map(self.submissionRecords(), function (o) {
                if (o.datasetVersion().length > 0) {
                    return o.datasetVersion().substr(8, o.datasetVersion().length)
                } else {
                    return 0;
                }
            });
            var highest = Math.max.apply(Math, datasetArray);
            highest = highest + 1;
            var i = (highest > 9) ? "" + highest: "0" + highest;

            return res + "_" + i;
        } else {
            return res + "_01";
        }
    };

    if (!self.currentSubmissionRecord) {
        var params = {};
        params.datasetVersion = currentDatasetVersion();
        params.submissionDoi = "Draft";
        self.currentSubmissionRecord = new SubmissionRec(params);
        if (self.submissionRecords() && self.submissionRecords().length > 0) {
            // Copy from the previous dataset version
            self.currentSubmissionPackage = new SubmissionPackage(self.submissionRecords()[0])
        } else {
            self.currentSubmissionPackage = new SubmissionPackage({});
        }

        self.transients.newDraft = true;
    } else {
        self.transients.newDraft = false;
    };

    self.submissionName = self.projectViewModel.name() + " - " + self.name() + " - " + self.currentSubmissionRecord.datasetVersion();

    var today = moment().format('DD-MM-YYYY');

    self.currentSubmissionPackage.collectionStartDate = self.startDate()? moment(self.startDate()).format('DD-MM-YYYY') : today;
    self.currentSubmissionPackage.collectionEndDate = self.endDate()? moment(self.endDate()).format('DD-MM-YYYY') : today;

    self.transients.getImageUrl = ko.pureComputed(function(){
        if (self.logoUrl()) {
            return self.logoUrl();
        } else if (self.mainImageUrl()) {
            return self.mainImageUrl();
        } else {
            return "";
        }
    });

    self.transients.enableSubmission = ko.observable(true);
    self.transients.submissionInProgress = ko.observable(false);
    
    self.transients.fieldsOfResearch = [];
    self.transients.socioEconomic = [];
    self.transients.economicResearch = [];
    self.transients.anthropogenic = [];
    self.transients.conservationManagement = [];
    self.transients.plantGroups = [];
    self.transients.animalGroups = [];
    self.transients.environmentalFeatures = [];
    self.transients.samplingDesign = [];
    self.transients.observationMeasurements = [];
    self.transients.observedAttributes = [];
    self.transients.identificationMethod = [];

    self.loadVocabData = function() {
      //  debugger;
        self.transients.fieldsOfResearch = new TreeModel(vocabList.fieldsOfResearch.navTree, self.currentSubmissionPackage.selectedFieldsOfResearch, "fieldsOfResearch");
        self.transients.socioEconomic = new TreeModel(vocabList.socioEconomicObjectives.navTree, self.currentSubmissionPackage.selectedSocioEconomic, "socioEconomic");
        self.transients.economicResearch = new TreeModel(vocabList.ecologicalResearch.navTree, self.currentSubmissionPackage.selectedEconomicResearch, "economicResearch");
        self.transients.anthropogenic = new TreeModel(vocabList.anthropogenic.navTree, self.currentSubmissionPackage.selectedAnthropogenic, "anthropogenic");
        self.transients.conservationManagement = new TreeModel(vocabList.conservationManagement.navTree, self.currentSubmissionPackage.selectedConservativeMgmt, "conservationManagement");
        self.transients.plantGroups = new TreeModel(vocabList.plantGroups.navTree, self.currentSubmissionPackage.selectedPlantGroups, "plantGroups");
        self.transients.animalGroups = new TreeModel(vocabList.animalGroups.navTree, self.currentSubmissionPackage.selectedAnimalGroups, "animalGroups");
        self.transients.environmentalFeatures = new TreeModel(vocabList.environmentalFeatures.navTree, self.currentSubmissionPackage.selectedEnvironmentFeatures, "environmentalFeatures");
        self.transients.samplingDesign = new TreeModel(vocabList.samplingDesign.navTree, self.currentSubmissionPackage.selectedSamplingDesign, "samplingDesign");
        self.transients.observationMeasurements = new TreeModel(vocabList.observationMeasurements.navTree, self.currentSubmissionPackage.selectedObservationMeasurements, "observationMeasurements");
        self.transients.observedAttributes = new TreeModel(vocabList.observedAttributes.navTree, self.currentSubmissionPackage.selectedObservedAttributes, "observedAttributes");
        self.transients.identificationMethod = new TreeModel(vocabList.identificationMethod.navTree, self.currentSubmissionPackage.selectedIdentificationMethod, "identificationMethod");
    };


    // Environment Features and Supplementary Materials

    self.transients.associatedMaterialTypes = ['Algorithms', 'Database Manual', 'Database Schema',
        'Derived Spatial Layers', 'Field Manual', 'Mathematical Equations',
        'None', 'Other', 'Patent', 'Published Paper', 'Published Report'];

    self.transients.materialIdentifierTypes = ['Ark Persistent Identifier Scheme', 'Australian Research Council Identifier',
        'DOI', 'National Library Of Australia Identifier', 'None'];

    self.transients.titleOptions = ['Assoc Prof', 'Dr', 'Miss', 'Mr', 'Mrs', 'Ms', 'Prof'];

    // Dataset conditions and Management
    self.transients.legalCustodianOrganisationTypeList = (['Community-based Organisation', 'Federal Agency', 'Foreign Government Agency', 'Herbarium', 'Individual Researcher', 'International Organisation', 'Museum',
        'Non-government Organisation', 'Private Enterprise', 'Research Institution', 'State Agency', 'University']);

    self.transients.curationStatusList = (['Active', 'Completed', 'Stalled']);

    self.transients.curationActivitiesOtherList = (['Data Validation', 'Not curated', 'Plausibility Review', 'Taxonomic Opinion', 'Taxonomic Determination']);

    self.loadVocabData();
    
    self.selectedTab = ko.observable('tab-1');

    self.selectTab = function(data, event) {
        var tabId = event.currentTarget.id;
        $("#" + tabId).tab('show');
        var tabNumber = tabId.substr(0, 5);
        self.selectedTab(tabNumber);
    };

    self.showTab = function(tabId) {
        $("#" + tabId).tab('show');
        self.selectedTab(tabId);
    };

    var nextTab =  function(){
        var currentTab = ko.utils.unwrapObservable(self.selectedTab);
        var currentTabNumber = parseInt(currentTab.charAt(4));
        var nextTabNumber = currentTabNumber + 1;
        var nextTab = currentTab.substr(0, 4) + nextTabNumber;
        return nextTab;
    };
    self.selectNextTab = function() {
        var nextTabVal = nextTab();
        $('#' + nextTabVal).tab('show');
        self.selectedTab(nextTabVal);
    };

    self.dataToggleVal = function(){
        return 'tab';
        /*if(self.isValidationValid()){
            return 'tab'
        } else {
            return ''
        }*/
    };

    self.hideModal = function () {

        if (self.transients.showAekosWorkflow()) {
            bootbox.confirm("You will lose unsaved changes. Are you sure you want to close this window?", function (result) {
                if (result) {
                    alaMap = null;
                    $("#aekosModal").modal('hide');
                    self.get();
                    // window.location.reload();
                    // self.aekosModalView(null);
                    /*  $(window).on('beforeunload', function(){
                     $('*').css("cursor", "progress");
                     }); */
                    //  window.location.reload();
                }
            });
        } else {
            $("#aekosModal").modal('hide');
        }

    };

    self.selectedIbraRegion = ko.observable();
    self.siteCoordinates = ko.observable();
    self.animalSpecies = ko.observableArray();
    self.plantSpecies = ko.observableArray();
    self.noSpeciesClassification = ko.observableArray();

    self.loadAekosData = function() {
        self.transients.aekosMap = aekosMap = new AEKOS.Map ();

        $.ajax({
            //'http://spatial.ala.org.au/ws/shape/wkt/' + projectArea.pid
            url: fcConfig.spatialBaseUrl + '/ws/shape/wkt/' + projectArea.pid
        }).done(function (data) {
            self.siteCoordinates(data);
        });

       extractDataFromRecords(activityRecords).done (function (result) {
            var features = (result && result.features)? result.features : null;
            var speciesInfo = (result && result.speciesInfo)? result.speciesInfo: null;
            if (speciesInfo) {
                self.noSpeciesClassification($.grep (speciesInfo, function (it) {
                    return it && it.kingdom == null;
                }));
                self.animalSpecies($.grep (speciesInfo, function (it) {
                    if  (it && it.kingdom && it.kingdom.toUpperCase() == "ANIMALIA") {
                        if (!it.commonName) {
                            it.commonName = it.commonNameSingle? it.commonNameSingle : '';
                            return it;
                        }
                    };
                }));
                self.plantSpecies($.grep (speciesInfo, function (it) {
                    if  (it && it.kingdom && it.kingdom.toUpperCase() == "PLANTAE") {
                        if (!it.commonName) {
                            it.commonName = it.commonNameSingle? it.commonNameSingle : '';
                            return it;
                        }
                    };
                }));
            };

            var lat = '';
            var lng = '';
            var getIbraRegion = false;
            if (projectArea.decimalLatitude && projectArea.decimalLongitude) {
                lat = projectArea.decimalLatitude.toString();
                lng = projectArea.decimalLongitude.toString();
                getIbraRegion = true;
            } else if (features && features.length > 0 && features[0] != undefined) {
                lat = features[0].lat.toString();
                lng = features[0].lng.toString();
                getIbraRegion = true;
            }

            if (getIbraRegion) {
                $.ajax({
                    // cl1048 is Ibra 7 region //'https://spatial.ala.org.au/ws/intersect/cl1048/' + lat + "/" + lng
                    url: fcConfig.spatialBaseUrl + "/ws/intersect/cl1048/" + lat + "/" + lng
                }).done(function (ibraRegion) {
                    self.selectedIbraRegion(ibraRegion[0].value);
                    aekosMap.plotOnAekosMap(features, projectArea, ibraRegion)
                });
            } else {
                self.selectedIbraRegion(null);
                aekosMap.plotOnAekosMap(features, projectArea, null)
            }

        });
        self.showTab('tab-1');
    };

    /**
     * converts ajax data to activities or records according to selection.
     * @param data
     */
    var extractDataFromRecords = function (dataset){
        var deferredElement = $.Deferred();
        var result = {};
        var features = [];
        var speciesGuids = [];
        if (dataset.activities) {
            $.each(dataset.activities, function(index, activity) {
                if (activity.records && activity.records.length > 0) {
                    $.each(activity.records, function(k, el) {
                        features.push (aekosMap.getPointFeatures(activity, el));
                    });
                    speciesGuids = speciesGuids.concat($.map(activity.records, function (it) {
                        return it.guid;
                    }));
               };
            });

            result.features = features;
            result.speciesInfo = {};
            if (speciesGuids.length > 0) {
                var url = fcConfig.bieUrl + '/ws/species/guids/bulklookup'; //"http://bie.ala.org.au/ws/species/guids/bulklookup.json";
                $.ajax({
                    url: url,
                    type: 'POST',
                    data: JSON.stringify(speciesGuids),
                    contentType: 'application/json',
                    success: function (data) {
                        result.speciesInfo = data.searchDTOList;
                        deferredElement.resolve(result);
                    },
                    error: function (data) {
                        deferredElement.resolve(result);
                    }
                });
            } else {
                deferredElement.resolve(result);
            }
        } else {
            deferredElement.resolve(result);
        };
        return deferredElement;
    };

    self.message = ko.observable('');
    self.showMessage = function (message) {
        self.message(message);
    }

    self.showMap = function (data, event) {
        if (self.transients.aekosMap) {
            self.transients.aekosMap.showMap()
        }
    };

    self.findLogoScalingClass = function (imageElement, parentElement) {
        var $elem = $(imageElement);
        var parentHeight = $(parentElement).height();
        var parentWidth = $(parentElement).width();
        var height = imageElement.height;
        var width = imageElement.width;

        var ratio = parentWidth/parentHeight;
        if( ratio * height > width){
            $elem.addClass('tall')
        } else {
            $elem.addClass('wide')
        }
    };

    self.addAuthorRow = function () {
        self.currentSubmissionPackage.datasetAuthors.push (new DatasetAuthor('', '', ''));
    };

    self.removeAuthorRow = function (row) {
        if (row > 0) {
            self.currentSubmissionPackage.datasetAuthors.splice(row, row);
        }
    };

    var validationFailedMessage = "Please complete all mandatory fields before submitting."

    self.isProjectInfoValidated = function () {
        if (!ko.utils.unwrapObservable(self.projectViewModel.description)) {
            self.showMessage(validationFailedMessage);
            return false;
        };
        return true;
    };

    self.isDatasetInfoValidated = function () {
        if (!(ko.utils.unwrapObservable(self.datasetTitle) &&
              ko.utils.unwrapObservable(self.description))) {
            self.showMessage(validationFailedMessage);
            return false;
        };
        return true;
    };

    self.isDatasetContentValidated = function () {
        if (!(self.transients.fieldsOfResearch.validateSelectedValues() &&
              self.transients.socioEconomic.validateSelectedValues() &&
              self.transients.economicResearch.validateSelectedValues())) {
            self.showMessage(validationFailedMessage);
            return false;
        };
        return true;
    };

    self.isLocationDatesValidated = function () {
        if (!(ko.utils.unwrapObservable(self.currentSubmissionPackage.geographicalExtentDescription)) ||
            !(ko.utils.unwrapObservable(self.currentSubmissionPackage.collectionStartDate)) ||
            !(ko.utils.unwrapObservable(self.currentSubmissionPackage.collectionEndDate))) {
            self.showMessage(validationFailedMessage);
            return false;
        }
        return true;
    };

    self.isDatasetSpeciesValidated = function () {
        if ((self.plantSpecies() && self.plantSpecies().length > 0 && self.transients.plantGroups.validateSelectedValues()) ||
            (self.animalSpecies() && self.animalSpecies().length > 0 && self.transients.animalGroups.validateSelectedValues())) {
            return true;
        };
        self.showMessage(validationFailedMessage);
        return false;
    };

    self.isMaterialsValidated = function () {
        // nothing to validate...non mandatory fields
        return true;
    };

    self.isMethodsValidated = function () {
        if (!(ko.utils.unwrapObservable(self.methodName)) ||
            !(ko.utils.unwrapObservable(self.methodAbstract))) {
            self.showMessage(validationFailedMessage);
            return false;
        }
        return true;
    };

    self.isDatasetAuthorValidated = function (o) {

        var authorSurnameOrOrgName = ko.utils.unwrapObservable(o.authorSurnameOrOrgName);
        var authorAffiliation = ko.utils.unwrapObservable(o.authorAffiliation);

        if ((authorSurnameOrOrgName && (authorSurnameOrOrgName.trim() != "")) &&
            (authorAffiliation && (authorAffiliation.trim()) != "")) {
            return true;
        } else {
            return false;
        }
    };

    self.isContactsValidated = function () {
        if (ko.utils.unwrapObservable(self.currentSubmissionPackage.datasetContact.title) &&
            ko.utils.unwrapObservable(self.currentSubmissionPackage.datasetContact.name) &&
            ko.utils.unwrapObservable(self.currentSubmissionPackage.datasetContact.role) &&
            ko.utils.unwrapObservable(self.currentSubmissionPackage.datasetContact.phone) &&
            ko.utils.unwrapObservable(self.currentSubmissionPackage.datasetContact.email)) {

            var authorValidated = true;

            var datasetAuthorList = ko.utils.unwrapObservable(self.currentSubmissionPackage.datasetAuthors);

            if (datasetAuthorList && datasetAuthorList.length > 0) {
                $.each (datasetAuthorList, function (i, o) {
                    if (!self.isDatasetAuthorValidated(o)) {
                        authorValidated = false;
                        self.showMessage(validationFailedMessage);
                        return;
                    }
                });
                return authorValidated;
            } else {
                self.showMessage(validationFailedMessage);
                return false;
            }

        }
        self.showMessage(validationFailedMessage);
        return false;
    };

    self.isManagementValidated = function () {
        return true;
    };

    self.isValidationValid = function () {
        return true;
       /* switch(ko.utils.unwrapObservable(self.selectedTab)) {
            case 'tab-1':
                return self.isProjectInfoValidated();
                break;
            case 'tab-2':
                return self.isDatasetInfoValidated();
                break;
            case 'tab-3':
                return self.isDatasetContentValidated();
                break;
            case 'tab-4':
                return self.isLocationDatesValidated();
                break;
            case 'tab-5':
                return self.isDatasetSpeciesValidated();
                break;
            case 'tab-6':
                return self.isMaterialsValidated();
                break;
            case 'tab-7':
                return self.isMethodsValidated();
                break;
            case 'tab-8':
                return self.isContactsValidated();
                break;
            case 'tab-9':
                return self.isManagementValidated();
                break;
            default:
                return true;
        }*/
    };

    self.isAllValidationValid = function (index) {
        //self.validationFailed(true);
        if (!self.isProjectInfoValidated()) {
            self.showTab('tab-1');
            return false;
        } else if (!self.isDatasetInfoValidated()) {
            self.showTab('tab-2');
            return false;
        } else if (!self.isDatasetContentValidated()) {
            self.showTab('tab-3');
            return false;
        } else if (!self.isLocationDatesValidated()) {
            self.showTab('tab-4');
            return false;
        } else if (!self.isDatasetSpeciesValidated()) {
            self.showTab('tab-5');
            return false;
        } else if (!self.isMaterialsValidated()) {
            self.showTab('tab-6');
            return false;
        } else if (!self.isMethodsValidated()) {
            self.showTab('tab-7');
            return false;
        } else if (!self.isContactsValidated()) {
            self.showTab('tab-8');
            return false;
        } else if (!self.isManagementValidated()) {
            self.showTab('tab-9');
            return false;
        }
        //self.validationFailed(false);
        self.showMessage('');
        return true;
    };

    self.asJS = function () {
        var jsData;
        var ignore = self.ignore.concat(['current', 'pActivityForms', 'pActivityFormImages', 'projectViewModel', 'selectedTab',
            'access', 'species', 'sites', 'transients', 'endDate','visibility','pActivityFormName', 'restrictRecordToSites', 'user',
            'allowAdditionalSurveySites', 'baseLayersName', 'project', 'currentSubmissionRecord', 'currentSubmissionPackage', 'siteCoordinates', 'selectedIbraRegion', 'animalSpecies', 'plantSpecies', 'parentProjectActivities',
            'noSpeciesClassification', 'submissionName', 'displayDate']);
        ignore = $.grep(ignore, function (item, i) {
            return item != "documents";
        });
        jsData = ko.mapping.toJS(self, {ignore: ignore});
        jsData.endDate = moment(self.endDate(), 'YYYY-MM-DDThh:mm:ssZ').isValid() ? self.endDate() : "";
        return jsData;
    };

    self.get = function(){
        var promise = $.Deferred();
        var test = self.asJS();
        var jsonData = JSON.stringify(self.asJS(), function (key, value) {return value === undefined ? "" : value;});

        var url =  fcConfig.projectActivityGetUrl + "/" + self.projectActivityId();
        $.ajax({
            url: url,
            type: 'GET',
            success: function (data) {
                self.loadSubmissionRecords(data.submissionRecords);
                $.map(self.submissionRecords() ? self.submissionRecords() : [], function (obj, i) {
                    if (obj.datasetVersion() == self.currentSubmissionRecord.datasetVersion()) {
                        if (!self.currentSubmissionPackage.submissionRecordId) {
                            self.currentSubmissionPackage.submissionRecordId = obj.submissionPackage.submissionRecordId; //new SubmissionPackage(obj.submissionPackage);
                        }
                    }
                });
            },
            error: function (data) {
                showAlert("Error in retrieving submission.", "alert-success", 'alert-placeholder');
            }
        });
        return promise;
    };

    self.update = function(){
        var promise = $.Deferred();
        var jsStr = self.asJS();
        var jsonData = JSON.stringify(jsStr, function (key, value) {return value === undefined ? "" : value;});

        var url =  fcConfig.projectActivityUpdateUrl + "/" + self.projectActivityId();
        $.ajax({
            url: url,
            type: 'POST',
            data: JSON.stringify(self.asJS(), function (key, value) {return value === undefined ? "" : value;}),
            contentType: 'application/json',
            success: function (data) {
                var result = data.resp;
                if (result && result.message == 'updated') {
                    self.get();
                    promise.resolve(result);
                } else {
                    promise.resolve(result);
                }
            },
            error: function (data) {
                self.showAlert("Error updating the survey -" + data.status, "alert-error", 'alert-placeholder');
            }
        });
        return promise;
    };

    var convertFormElemntToJson = function (el, findChildElements) {
        //$('#projectInfo > div.row-fluid > div.span8').children()[0].outerHTML
        //var jsonStr = '';
        var formData =  {};
        var array = [];
        var multiselectArray = {};
        var thisElement;
        if (findChildElements) {
            thisElement = el.find('textarea, select, img, input:not(.extrafield), span:not(.multiselect):not(.tree-item):not(.add-on open-datepicker)');
        } else {
            thisElement = el;
        }
        var parentId = "";
        var multiInput = {};
        var multiInputArray = {};
        //var multiInputParent = [];
        //:input:not(:checkbox), input:checkbox:checked
        $.each(thisElement, function (i, it){
            var a = {};
            if ($(it).is("input.multiselect") || $(it).is("input.tree-item")) {
                if (it.checked && it.value) {
                    if (!multiselectArray[it.name]) {
                        multiselectArray[it.name] = [it.value]
                    } else {
                        multiselectArray[it.name].push(it.value);
                    }
                } else {
                    if (!multiselectArray[it.name]) {
                        multiselectArray[it.name] = [];
                    }
                }
            } else if ($(it).is("input.multiInput")) { // for Dataset Authors in DatasetContacts page
                parentId = $(it).parent().parent().parent()[0].id;
                var index = parseInt(parentId.split('-').pop());
                if (it.value) {
                   if (!multiInput[parentId]) {
                        a[it.name] = it.value;
                        multiInput[parentId] = [a];
                   } else {
                       a[it.name] = it.value;
                       multiInput[parentId].push(a);
                   }
                   // }
                } else {
                    if (!multiInput[parentId]) {
                        a[it.name] = it.value;
                        multiInput[parentId] = [a];
                    }
                }
            } else if ($(it).is("span.datasetList")) {
                var elemId = it.getAttribute("data-name");
                if(it.innerHTML) {
                    if (!multiselectArray[elemId]) {
                        multiselectArray[elemId] = [jsonEscapeValue(it.innerHTML)]
                    } else {
                        multiselectArray[elemId].push(jsonEscapeValue(it.innerHTML));
                    }
                } else {
                    if (!multiselectArray[elemId]) {
                        multiselectArray[elemId] = [];
                    }
                }
            } else if ($(it).is("span")) {
               // a[it.id] = jsonEscapeValue(it.innerHTML);
               // array.push(a);
                formData[it.id] = jsonEscapeValue(it.innerHTML);
            } else if ($(it).is("img#urlImage.image-logo.wide")) {
                formData[it.id] = it.src;
            } else {
              //  a[it.id] = it.value;
              //  array.push(a);
                formData[it.id] = jsonEscapeValue(it.value);
            }
        });

        if (multiselectArray && Object.keys(multiselectArray).length > 0) {
            $.each(multiselectArray, function(i,it) {
               // var ob = {};
               // ob[i] = it;
               // array.push(ob);
                formData[i] = it
            })
         }

        if (multiInput && Object.keys(multiInput).length > 0) {

            $.each(multiInput, function(i,it) {
                var ob = {};
                $.each(it, function(k,val) {
                    var key = Object.keys(val)[0]
                    ob[key] = val[key];
                });
                if (formData["datasetAuthors"]) {
                    formData["datasetAuthors"].push(ob);
                } else {
                    formData["datasetAuthors"] = [ob];
                }


            });
        }
        return formData;

    };

    self.save = function(){

        if (self.transients.newDraft) {
            self.currentSubmissionRecord.submissionPackage = self.currentSubmissionPackage
            self.submissionRecords.push(self.currentSubmissionRecord);
        } else {
            $.map(self.submissionRecords() ? self.submissionRecords() : [], function (obj, i) {
                if (obj.datasetVersion() == self.currentSubmissionRecord.datasetVersion()) {
                    obj.submissionPackage = self.currentSubmissionPackage;
                    obj.submissionId(self.currentSubmissionRecord.submissionId());
                    obj.submissionDoi(self.currentSubmissionRecord.submissionDoi());
                    obj.datasetSubmitter(self.currentSubmissionRecord.datasetSubmitter());
                    obj.submissionPublicationDate(self.currentSubmissionRecord.submissionPublicationDate());
                }
            });

        };

        self.transients.newDraft = false;

        var promise = $.Deferred ();

        $.when(self.update ()).done(function (result) {
            if (result.message == 'updated') {
                showAlert("Successfully updated", "alert-success", 'alert-placeholder');
                promise.resolve(result);
            } else {
                promise.resolve({status: "error", error: "An error occurred while to save Aekos data" });
            }
        });

        return promise;
    };

    var jsonEscapeValue = function (value) {
        //var str = value.replace(/\n/g, "\r\n");
        var str = value.replace(/\n/g, " ");
        return str;
    };

    var generateAekosSubmissionPayload = function () {
        var submissionPages =  {};
        //  var projectInfoFields = JSON.stringify($('#projectInfo > div.row-fluid > div.span8').children().html());
        var projectInfoArr = convertFormElemntToJson($("#projectInfo > div.row-fluid > div.span8"), true);

        submissionPages["projectInfo"] = projectInfoArr;

        var datasetInfoArr = convertFormElemntToJson($('#datasetInfo > div.row-fluid > div.span8 > div.controls'), true);

        submissionPages["datasetInfo"] = datasetInfoArr;

        var datasetContentArr = convertFormElemntToJson($('#datasetContent > div.row-fluid > div.span8'), true);

        submissionPages["datasetContent"] = datasetContentArr;

        var spatialInfoCollectionDates = convertFormElemntToJson($("#spatialInfoCollectionDates > div.row-fluid > div.span8").children(":not(div#recordOrActivityMap):not(br):not(span.add-on)"), false);

        submissionPages["spatialInfoCollectionDates"] = spatialInfoCollectionDates;

        var datasetSpecies = convertFormElemntToJson($("#datasetSpecies > div.speciesClassDiv > div.row-fluid > div.span8"), true);

        submissionPages["datasetSpecies"] = datasetSpecies;

        var environmentFeaturesAndMaterials = convertFormElemntToJson($("#environmentFeaturesAndMaterials > div.row-fluid > div.span8"), true);

        submissionPages["environmentFeaturesAndMaterials"] = environmentFeaturesAndMaterials;

        var collectionMethods = convertFormElemntToJson($("#collectionMethods > div.row-fluid > div.span8"), true);

        submissionPages["collectionMethods"] = collectionMethods;

        var datasetContact = convertFormElemntToJson($("#datasetContact > div.container > div.panel > div.panel-body >div.row-fluid > div.span8")
                                                     .add("#datasetContact > div.container > div.panel > div.panel-body > div > div.row-fluid > div.span8"), true);

        submissionPages["datasetContact"] = datasetContact;

        var datasetConditionAndManagement = convertFormElemntToJson($("#datasetConditionAndManagement > div.row-fluid > div.span8"), true);

        submissionPages["datasetConditionAndManagement"] = datasetConditionAndManagement;

        return {"submissionPages": submissionPages};

    };

    self.postJsonSubmission = function (userDetails) {

        var promise = $.Deferred ();
        var submissionBody = generateAekosSubmissionPayload ();

        submissionBody.userDetails = userDetails;

        var jsonParam = {};
        var aekosActivityRec = {};

        jsonParam['submissionBody'] = submissionBody;

        aekosActivityRec.projectId = self.projectId();
        aekosActivityRec.activityName = self.name();
        jsonParam['aekosActivityRec'] =  aekosActivityRec;
        
        var json = JSON.stringify(jsonParam);

        $.ajax({
            url: fcConfig.aekosSubmissionUrl,
            type: 'POST',
            data: json,
            contentType: 'application/json',
            success: function (data) {
                promise.resolve(data)

            },
            error: function (data) {
                promise.resolve({status: "error", error: "An error occurred prior to sending data to Aekos" });
            },
            timeout: 25*1000,
            async: true
        });

        return promise;
    };

    self.proceedSubmission = function (previousPendingSubmissions) {
        var userDetails = {};

         bootbox.confirm("<h4>Please enter your SHaRED Login: </h4><hr style='color: grey'/><br><form id='infos' action=''>\
        User:&emsp;&emsp;&emsp;&emsp;<input type='text' name='username' /><br/>\
        Password:&emsp;&nbsp;&nbsp;&nbsp;<input type='password' name='password' /><br/>\
        Email:&emsp;&emsp;&emsp;&emsp;<input type='text' name='emailAddress' />\
        </form>", function(result1) {
            if(result1) {

                if (previousPendingSubmissions) {
                    previousPendingSubmissions.forEach(function (submissionRecord) {
                        submissionRecord.submissionDoi('Cancelled')
                    });
                }

                var invalidUser = false;
                $('#infos :input').each(function() {
                    if (!invalidUser && $(this).val() && $(this).val().trim() != "") {
                        if (this.name == 'emailAddress' && $(this).val().indexOf('@') < 0) {
                            invalidUser = true;
                        } else {
                            userDetails[this.name] = $(this).val();
                        }
                    } else {
                        invalidUser = true;
                    };
                });

                if (!invalidUser && userDetails && Object.keys(userDetails).length > 0) {

                    self.transients.submissionInProgress(true);

                    var saveDataset = self.save();

                    var submitToAekos = self.postJsonSubmission(userDetails);

                    // First save is needed in case this submission fails
                    $.when(saveDataset, submitToAekos).done(function (result1, result2) {
                        if (result2 && result2.status == "ok") {
                            showAlert("Successful submission to Aekos. Submission Id: " + result2.submissionId, "alert-success", 'alert-placeholder');
                            var current_time = Date.now();
                            var submissionDate = moment(current_time).format("YYYY-MM-DDTHH:mm:ssZZ"); //moment(new Date(), 'YYYY-MM-DDThh:mm:ssZ').isValid() ? self.endDate() : "";

                            self.currentSubmissionRecord.submissionId(result2.submissionId);
                            self.currentSubmissionRecord.submissionDoi("Pending");
                            self.currentSubmissionRecord.datasetSubmitter(self.user.userId);
                            self.currentSubmissionRecord.submissionPublicationDate(submissionDate);

                            $.when(self.save()).done(function (result3) {
                                if (result3.message == 'updated') {
                                    showAlert("Submission DOI status is now pending. This status will be updated once the dataset is minted.",
                                        "alert-success", 'alert-placeholder');
                                    self.transients.submissionInProgress(false);
                                }
                            });

                            self.transients.enableSubmission(false);

                        } else if (result2) {
                            showAlert("Error submitting dataset to Aekos. Error: " + result2.error, "alert-error", 'alert-placeholder');
                            self.transients.enableSubmission(true);
                            self.transients.submissionInProgress(false);
                        }
                    });
                } else if (invalidUser) {
                    bootbox.alert("Please enter Username, Password and a valid Email(must contain @) in order to submit.");
                    self.transients.enableSubmission(true);
                }
            } else {
                self.transients.enableSubmission(true);
            }
        });
    };

    self.submit = function(index){

        if (self.isAllValidationValid()) {

            self.transients.enableSubmission(false);

            var previousSubmissionExist = false;
            var previousPendingSubmissions = [];

            self.submissionRecords().forEach (function (submissionRecord) {
                if (submissionRecord.datasetVersion() != self.currentSubmissionRecord.datasetVersion() && submissionRecord.submissionDoi() == 'Pending') {
                    previousSubmissionExist = true;
                    bootbox.confirm("There is another submission that is still pending. In order to cancel previous submission in SHaRED, you must login into SHaRED and manually cancel the previous submission before you re-submit. Click OK if you want to continue and cancel previous pending submission.", function (result) {
                        if (result) {
                            previousPendingSubmissions.push(submissionRecord);
                            self.proceedSubmission(previousPendingSubmissions);
                        } else {
                            self.transients.enableSubmission(true);
                        }

                    })
                };
            });

            if (!previousSubmissionExist) {
                self.proceedSubmission();
            }

        } else {
            self.transients.enableSubmission(true);
        };
    };


};

var DatasetAuthor = function (authorInitials, authorSurnameOrOrgName, authorAffiliation) {

    var self = this;
    self.authorInitials = authorInitials ? authorInitials : '';
    self.authorSurnameOrOrgName = authorSurnameOrOrgName ? authorSurnameOrOrgName : '';
    self.authorAffiliation = authorAffiliation ? authorAffiliation : '';

};


var DatasetContact = function (params) {
    if(!params) params = {};

    var self = this;

    self.title = params.title ? params.title : '';
    self.name = params.name ? params.name : '';
    self.role = params.role ? params.role : '';
    self.address = params.address ? params.address : '';
    self.email = params.email ? params.email : '';
    self.phone = params.phone ? params.phone : '';
};


var SubmissionPackage = function (params) {

    if(!params) params = {};

    var self = this;

    // Dataset Content
    self.selectedFieldsOfResearch = params.submissionPackage && params.submissionPackage.selectedFieldsOfResearch ? params.submissionPackage.selectedFieldsOfResearch : [];
    self.selectedSocioEconomic = params.submissionPackage && params.submissionPackage.selectedSocioEconomic ? params.submissionPackage.selectedSocioEconomic : [];
    self.selectedEconomicResearch = params.submissionPackage && params.submissionPackage.selectedEconomicResearch ? params.submissionPackage.selectedEconomicResearch : [];
    self.selectedAnthropogenic = params.submissionPackage && params.submissionPackage.selectedAnthropogenic ? params.submissionPackage.selectedAnthropogenic : [];
    self.selectedConservativeMgmt = params.submissionPackage && params.submissionPackage.selectedConservativeMgmt ? params.submissionPackage.selectedConservativeMgmt : [];

    //Spatial and CollectionDates
    self.geographicalExtentDescription = params.submissionPackage && params.submissionPackage.geographicalExtentDescription ? params.submissionPackage.geographicalExtentDescription : '';
    self.collectionStartDate = params.submissionPackage && params.submissionPackage.collectionStartDate ? params.submissionPackage.collectionStartDate : '';
    self.collectionEndDate = params.submissionPackage && params.submissionPackage.collectionEndDate ? params.submissionPackage.collectionEndDate : '';

    // Dataset Species
    self.selectedPlantGroups = params.submissionPackage && params.submissionPackage.selectedPlantGroups ? params.submissionPackage.selectedPlantGroups : [];
    self.selectedAnimalGroups = params.submissionPackage && params.submissionPackage.selectedAnimalGroups ? params.submissionPackage.selectedAnimalGroups : [];

    self.selectedEnvironmentFeatures = params.submissionPackage && params.submissionPackage.selectedEnvironmentFeatures ? params.submissionPackage.selectedEnvironmentFeatures : [];
    self.selectedMaterialType = params.submissionPackage && params.submissionPackage.selectedMaterialType ? params.submissionPackage.selectedMaterialType : '';
    self.otherMaterials = params.submissionPackage && params.submissionPackage.otherMaterials ? params.submissionPackage.otherMaterials : '';
    self.associatedMaterialNane = params.submissionPackage && params.submissionPackage.associatedMaterialNane ? params.submissionPackage.associatedMaterialNane : '';
    self.selectedMaterialIdentifier = params.submissionPackage && params.submissionPackage.selectedMaterialIdentifier ? params.submissionPackage.selectedMaterialIdentifier : '';
    self.associatedMaterialIdentifier = params.submissionPackage && params.submissionPackage.associatedMaterialIdentifier ? params.submissionPackage.associatedMaterialIdentifier : '';


    // Dataset Collection Methods
    self.selectedSamplingDesign = params.submissionPackage && params.submissionPackage.selectedSamplingDesign ? params.submissionPackage.selectedSamplingDesign : [];
    self.selectedObservationMeasurements = params.submissionPackage && params.submissionPackage.selectedObservationMeasurements ? params.submissionPackage.selectedObservationMeasurements : [];
    self.selectedObservedAttributes = params.submissionPackage && params.submissionPackage.selectedObservedAttributes ? params.submissionPackage.selectedObservedAttributes : [];
    self.methodDriftDescription = params.submissionPackage && params.submissionPackage.methodDriftDescription ? params.submissionPackage.methodDriftDescription : '';
    self.selectedIdentificationMethod = params.submissionPackage && params.submissionPackage.selectedIdentificationMethod ? params.submissionPackage.selectedIdentificationMethod : [];

    self.datasetContact = new DatasetContact(params.submissionPackage && params.submissionPackage.datasetContact ? params.submissionPackage.datasetContact : {})

    self.datasetAuthors = ko.observableArray();
    var datasetAuthors = params.submissionPackage && params.submissionPackage.datasetAuthors ? params.submissionPackage.datasetAuthors : [];
    if (datasetAuthors.length > 0) {
        $.each(datasetAuthors, function (i, o) {
            self.datasetAuthors.push (new DatasetAuthor(o.authorInitials, o.authorSurnameOrOrgName, o.authorAffiliation));
        });
    } else {
        self.datasetAuthors.push (new DatasetAuthor('', '', ''));
    };

    self.acknowledgement = params.submissionPackage && params.submissionPackage.acknowledgement ? params.submissionPackage.acknowledgement : '';
    self.curationStatus = params.submissionPackage && params.submissionPackage.curationStatus ? params.submissionPackage.curationStatus : '';
    self.curationActivitiesOther = params.submissionPackage && params.submissionPackage.curationActivitiesOther ? params.submissionPackage.curationActivitiesOther : '';

};

var SubmissionRec = function (params) {

    if(!params) params = {};

    var self = this;

    // Submission Details
    self.submissionPublicationDate = ko.observable(params.submissionPublicationDate ? params.submissionPublicationDate : "");
    self.datasetSubmitter = ko.observable(params.datasetSubmitter ? params.datasetSubmitter : "");
    self.datasetVersion = ko.observable(params.datasetVersion ? params.datasetVersion : "");
    self.submissionDoi = ko.observable(params.submissionDoi ? params.submissionDoi : "Draft");
    self.submissionRecordId = ko.observable(params.submissionRecordId ? params.submissionRecordId : "");
    self.submissionId = ko.observable(params.submissionId ? params.submissionId : "");

    self.submissionPackage =  new SubmissionPackage(params.submissionPackage ? params : {});

    self.displayDate = ko.computed (function(){
        return self.submissionPublicationDate() ? moment(self.submissionPublicationDate()).format("DD-MM-YYYY") : '';
    });

    //self.datasetSubmmiterUser = {};

    if (params.datasetSubmitterUser) {
        self.datasetSubmitterUser = ko.observable(params.datasetSubmitterUser);
        self.datasetSubmitterUser().displayName = ko.observable(params.datasetSubmitterUser.displayName? params.datasetSubmitterUser.displayName: '');
    } else {
        self.datasetSubmitterUser = ko.observable({});

    }
};

var NodeModel = function(data) {

    var self = this;

    self.isExpanded = ko.observable(true);
    self.description = ko.observable();
    self.name = ko.observable();
    self.nodes = ko.observableArray([]);

    self.toggleVisibility = function() {
        self.isExpanded(!self.isExpanded());
    };

    ko.mapping.fromJS(data, self.mapOptions, self);

};

var TreeModel = function(data, selectedValues, treeName) {
    var self = this;
    self.tree = new NodeModel(data);

    self.treeName = treeName;

    self.selectedValues = ko.utils.unwrapObservable(selectedValues); //selectedValues; //ko.observableArray([]);

    self.validateSelectedValues = function () {
        var selected = self.selectedValues;
        if (selected && selected.length == 0) {
            return false;
        }
        return true;
    };

    self.extraField = ko.observable();
    self.extraAddedField = ko.observableArray([]);
    var checkNodes = function(nodes) {
        for (var i in nodes()) {
            if (nodes()[i].name().toLowerCase() == self.extraField().toLowerCase()) {
                return true;
            }
            if (checkNodes(nodes()[i].nodes)) {
                return true
            };
        };
        return false;
    };

    self.addTreeNode = function(parentTreeNodes) {
        if (parentTreeNodes && self.extraField() != undefined) {
            if (!checkNodes(parentTreeNodes)) {
                var newNodeModel = new NodeModel({name: self.extraField(), description: self.extraField()});
                parentTreeNodes.push(newNodeModel);
            }
        }
    };

};

NodeModel.prototype.mapOptions = {
    nodes: {
        create: function(args) {
            return new NodeModel(args.data);
        }
    }
};

ko.bindingHandlers.treeView = {
    init: function(element, valueAccessor, allBindindsAccessor, viewModel, bindingContext) {
        var accessor = valueAccessor();
        ko.renderTemplate("tree-template", accessor, {}, element, 'replaceNode');
        return { controlsDescendantBindings: true };
    },
    update: function(element, valueAccessor, allBindingsAccessor,  viewModel, bindingContext) {
    }
};
