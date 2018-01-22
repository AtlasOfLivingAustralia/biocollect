/**
 * Created by mol109 on 16/2/17.
 * Modified by Temi
 */

function SurveySpeciesFieldsVM(surveySettings) {
    var self = this;
    surveySettings = surveySettings || {};

    self.name = ko.observable(surveySettings.name);

    self.speciesFields = ko.observableArray();

    var speciesFields = surveySettings.speciesFields || []
    for(var i=0; i<speciesFields.length; i++) {
        self.speciesFields.push(new SpeciesFieldViewModel(speciesFields[i]));
    }

    self.asJson = function () {
        var jsData = {};

        jsData.name = self.name();
        jsData.speciesFields = [];

        var speciesFields = self.speciesFields();
        for(var i=0; i<speciesFields.length; i++) {
            jsData.speciesFields.push(speciesFields[i].asJson());
        }

        return jsData;
    };

    self.transients = {};
    self.transients.parent = surveySettings.parent;
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


}

function ProjectSpeciesFieldsConfigurationViewModel (projectId, speciesFieldsSettings,placeHolder) {
    var self = this;


    /**
     * Update the species display format for all species fields if they are using the default configuration
     */
    self.onDefaultSpeciesDisplayFormatChange = function (newSpeciesDisplayFormat) {

        // Check every field to see if it is using default config
        var surveys = self.surveysToConfigure()

        for(var i = 0; i < surveys.length; i++) {
            var speciesFields = surveys[i].speciesFields()
            for(var j = 0; j<speciesFields.length; j++) {
                var speciesFieldConfig = speciesFields[j].config();
                if (speciesFieldConfig.type() == 'DEFAULT_SPECIES') {
                    speciesFieldConfig.speciesDisplayFormat(newSpeciesDisplayFormat);
                }
            }
        }
    };


    self.init = function () {

        speciesFieldsSettings = speciesFieldsSettings || {}
        self.placeHolder = placeHolder;
        self.projectId = projectId;

        var surveysConfig = speciesFieldsSettings.surveysConfig || []

        self.surveysConfig = ko.observableArray();

        // Surveys that don't have species fields but need to be listed separately.
        self.surveysWithoutFields = ko.observableArray();

        // Surveys that have at least one species fields
        self.surveysToConfigure = ko.observableArray();

        // How many species fields across the whole project are available to configure
        // If it is only one we use only the default configuration
        self.speciesFieldsCount = ko.observable(0);

        for(var i=0; i<surveysConfig.length; i++) {
            var config = surveysConfig[i];
            config.parent = self;
            var surveySpeciesFieldsVM = new SurveySpeciesFieldsVM(config);
            self.surveysConfig.push(surveySpeciesFieldsVM);

            var surveySpeciesFieldCount = surveySpeciesFieldsVM.speciesFields().length;
            if(surveySpeciesFieldCount > 0) {
                self.surveysToConfigure.push(surveySpeciesFieldsVM);
            } else {
                self.surveysWithoutFields.push(surveySpeciesFieldsVM);
            }
        }
    };

    self.init();


    self.transients = self.transients || {};
    self.transients.isSaving = ko.observable(false);

    self.goToProject = function () {
        if (self.projectId) {
            document.location.href = fcConfig.projectViewUrl + self.projectId;
        }
    };

    /**
     * Determine if each species fields in this project are valid, this is a prerequisite to save the config
     *
     */
    self.areSpeciesValid = function() {
        var isValid = true;
        var surveys = self.surveysToConfigure();

        for (var i = 0; i < surveys.length; i++) {
            var speciesFields = surveys[i].speciesFields()
            for (var j = 0; j < speciesFields.length; j++) {
                if (!speciesFields[j].config().isValid()) {
                    isValid = false;
                }
            }
        }

        if(!isValid){
            if(!self.species().isValid()) {
                isValid = false;
            } else {
                isValid = true;
            }
        }

        return isValid;
    };

    /**
     * Search for species configuration setting for an activity type
     * @param type
     * @returns {*}
     */
    self.findSpeciesSettingsForActivityType = function (type) {
        var configurations = self.surveysToConfigure() || [];
        var result;
        configurations.forEach(function (speciesConfig) {
            if((speciesConfig) && (speciesConfig.name() === type)){
                result = speciesConfig
            }
        });

        return result
    };

    self.findOrCreateSpeciesSettingsForActivityType = function (type) {
        var speciesConfig = self.findSpeciesSettingsForActivityType(type);
        if(!speciesConfig){
            var settings = {
                name : type,
                speciesFields: self.findSpeciesFieldsForActivityType(type) || [],
                parent: self
            };

            if(settings.speciesFields.length > 0){
                speciesConfig = new SurveySpeciesFieldsVM(settings);
                self.surveysToConfigure.push(speciesConfig)
            }
        }

        return speciesConfig;
    };

    self.findSpeciesFieldsForActivityType = function (activityName) {
        if(fcConfig.activityTypes){
            var result;
            $.each(fcConfig.activityTypes, function(i, obj) {
                $.each(obj.list, function(j, type) {
                    if (type.name === activityName) {
                        result = type.speciesFields;
                    }
                });
            });

            return result;
        }
    };

    self.copySettings = function (speciesFieldViewModel) {
        bootbox.confirm("Copy will overwrite all species configuration you have made in this project. Do you want to continue?", function(result) {
            if (result) {
                var surveys = self.surveysToConfigure();
                var data = speciesFieldViewModel.asJson(),
                    isDirty = false;

                for (var i = 0; i < surveys.length; i++) {
                    var speciesFields = surveys[i].speciesFields();
                    for (var j = 0; j < speciesFields.length; j++) {
                        if (speciesFieldViewModel != speciesFields[j]) {
                            speciesFields[j].load(data);
                            isDirty = true
                        }
                    }
                }

                if(isDirty){
                    self.save();
                }
            }
        });
    };

    self.save = function () {
        if (self.areSpeciesValid()) {

            var surveysConfigJsData = [];
            self.transients.isSaving(true);

            var surveysToConfigure = self.surveysToConfigure();
            for (var i = 0; i < surveysToConfigure.length; i++) {
                surveysConfigJsData.push(surveysToConfigure[i].asJson());
            }

            var jsData = {
                speciesFieldsSettings: {
                    surveysConfig: surveysConfigJsData
                }
            };
            var json = JSON.stringify(jsData);
            $.ajax({
                url: fcConfig.projectUpdateUrl,
                type: 'POST',
                data: json,
                contentType: 'application/json',
                success: function (data) {
                    if (data.error) {
                        alert(data.detail + ' \n' + data.error);
                    }
                },
                error: function (data) {
                    var status = data.status;
                    showAlert('An unhandled error occurred: ' + data.status, "alert-error", self.placeHolder);
                },
                complete: function () {
                    self.transients.isSaving(false);
                }
            });
        } else {
            showAlert("Project default configuration and all species fields (if any) must be configured before saving.", "alert-error", self.placeHolder);
        }
    };
    self.removeActivity = function () {
        bootbox.confirm("Delete this entire activity? Are you sure?", function(result) {
            if (result) {
            }
        });
    };
    self.notImplemented = function () {
        alert("Not implemented yet.")
    };
}

SpeciesFieldViewModel.prototype.showSpeciesConfiguration = function() {
    var self = this;

    // Create a copy to bind to the field config dialog otherwise we may change the main screen values inadvertently
    speciesConstraintVM = new SpeciesConstraintViewModel(self.config().asJson(), self.fieldName);

    showSpeciesFieldConfigInModal(speciesConstraintVM, '#speciesFieldDialog').done(function () {
        self.config(speciesConstraintVM);
    });
};