
SurveySpeciesFieldsVM = function (surveySettings) {
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

}
/**
 * Created by mol109 on 16/2/17.
 */

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
    }


    self.init = function () {

        speciesFieldsSettings = speciesFieldsSettings || {}
        self.placeHolder = placeHolder;
        self.projectId = projectId;
        
        // Default species configuration
        self.species = ko.observable(new SpeciesConstraintViewModel(speciesFieldsSettings.defaultSpeciesConfig));


        var surveysConfig = speciesFieldsSettings.surveysConfig || []

        self.surveysConfig = ko.observableArray();

        // Surveys that don't have species fields but need to be listed separately.
        self.surveysWithoutFields = ko.observableArray();

        // Surveys that have at least one species fields
        self.surveysToConfigure = ko.observableArray();


        for(var i=0; i<surveysConfig.length; i++) {
            var surveySpeciesFieldsVM = new SurveySpeciesFieldsVM(surveysConfig[i]);
            self.surveysConfig.push(surveySpeciesFieldsVM);

            if(surveySpeciesFieldsVM.speciesFields().length > 0) {
                self.surveysToConfigure.push(surveySpeciesFieldsVM);
            } else {
                self.surveysWithoutFields.push(surveySpeciesFieldsVM);
            }
        }

        self.species().speciesDisplayFormat.subscribe(self.onDefaultSpeciesDisplayFormatChange)
    }

    self.init();


    self.transients = self.transients || {};
    // self.transients.project = project;


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


    self.goToProject = function () {
        if (self.projectId) {
            document.location.href = fcConfig.projectViewUrl + self.projectId;
        }
    };

    /**
     * Determine if each species fields in this project are valid, this is a prerequisite to save the config
     * This is an agregation of the SpeciesConstraintViewModel#isValid
     */
    self.areSpeciesValid = function() {

        if(!self.species().isValid()) {
            return false;
        }

        // As soon as a field is not valid we stop
        var surveys = self.surveysToConfigure()
        for(var i = 0; i < surveys.length; i++) {
            var speciesFields = surveys[i].speciesFields()
            for(var j = 0; j<speciesFields.length; j++) {
                if(!speciesFields[j].config().isValid()) {
                    return false;
                }
            }
        }

        return true;
    }

    self.save = function () {
        if (self.areSpeciesValid()) {

            var surveysConfigJsData = [];

            var surveysConfig = self.surveysConfig();
            for(var i=0; i<surveysConfig.length; i++) {
                surveysConfigJsData.push(surveysConfig[i].asJson());
            }

            var jsData = {speciesFieldsSettings:
                    {defaultSpeciesConfig: self.species().asJson(),
                        surveysConfig: surveysConfigJsData}};
            var json = JSON.stringify(jsData);
            $.ajax({
                url: fcConfig.projectUpdateUrl,
                type: 'POST',
                data: json,
                contentType: 'application/json',
                success: function (data) {
                    if (data.error) {
                        alert(data.detail + ' \n' + data.error);
                    } else {
                        document.location.href = returnTo;
                    }
                },
                error: function (data) {
                    var status = data.status;
                    showAlert('An unhandled error occurred: ' + data.status, "alert-error", self.placeHolder);
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

    self.showSpeciesConfiguration = function(speciesConstraintVM, fieldName, surveyIndex,  speciesFieldIndex) {
        // Create a copy to bind to the field config dialog otherwise we may change the main screen values inadvertenly
        speciesConstraintVM = new SpeciesConstraintViewModel(speciesConstraintVM.asJson(), fieldName);

        if(speciesFieldIndex) {
            speciesConstraintVM.speciesOptions.push({id: 'DEFAULT_SPECIES', name:'Use default configuration'});
        }

        showSpeciesFieldConfigInModal(speciesConstraintVM, '#speciesFieldDialog')
            .done(function(result){
                    if(surveyIndex && speciesFieldIndex) { //Update a particular species field configuration
                        var newSpeciesConstraintVM = new SpeciesConstraintViewModel(result)
                        newSpeciesConstraintVM.speciesOptions.push({id: 'DEFAULT_SPECIES', name:'Use default configuration'});

                        // survey[i].speciesField[j]
                        var currentSpeciesField = self.surveysToConfigure()[surveyIndex()].speciesFields()[speciesFieldIndex()];
                        currentSpeciesField.config(newSpeciesConstraintVM);

                        // For all species fields if the type is changed to DEFAULT_SPECIES then the speciesDisplayFormat
                        // MUST be copied from the default configuration.
                        if(currentSpeciesField.config().type() == 'DEFAULT_SPECIES') {
                            currentSpeciesField.config().speciesDisplayFormat(self.species().speciesDisplayFormat());
                        }
                    }
                    else { // Update species default configuration
                        self.species(new SpeciesConstraintViewModel(result));
                        self.species().speciesDisplayFormat.subscribe(self.onDefaultSpeciesDisplayFormatChange)
                    }
                }
            );
    }
}

