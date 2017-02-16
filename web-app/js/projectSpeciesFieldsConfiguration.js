/**
 * Created by mol109 on 16/2/17.
 */

function ProjectSpeciesFieldsConfigurationViewModel (project) {
    var self = this;


    self.species = ko.observable(new SpeciesConstraintViewModel(project.species));

    self.speciesFields = ko.observableArray([new SpeciesFieldViewModel(project.species)]);


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
            document.location.href = fcConfig.projectViewUrl + self.projectId();
        }
    };
    self.goToSite = function() {
        if (self.siteId) {
            document.location.href = fcConfig.siteViewUrl + self.siteId();
        }
    };


    self.save = function () {
        if ($('#validation-container').validationEngine('validate')) {
            var jsData = ko.mapping.toJS(self, {'ignore':['transients']});
            var json = JSON.stringify(jsData);
            $.ajax({
                url: projectUpdateUrl,
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
                    alert('An unhandled error occurred: ' + data.status);
                }
            });
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