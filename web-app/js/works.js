/*
 * Copyright (C) 2017 Atlas of Living Australia
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
 * Created by Temi on 1/11/17.
 */
function WorksActivityViewModel (config) {
    var self = this;
    var act = config.act || {},
        project = config.project || {},
        planViewModel = config.planViewModel,
        speciesSettings = config.speciesSettings,
        initialProgress = 'planned',
        progress = act.progress || initialProgress;
    self.activityId = act.activityId;
    self.siteId = ko.observable(act.siteId || "");
    self.typeCategory = ko.observable(act.typeCategory);
    self.hasOutputs = act.outputs && act.outputs.length;
    self.publicationStatus = act.publicationStatus ? act.publicationStatus : 'unpublished';
    self.deferReason = ko.observable(undefined); // a reason document or undefined
    self.description = ko.observable(act.description);
    self.notes = ko.observable(act.notes);
    self.type = ko.observable(act.type);
    self.startDate = ko.observable(act.startDate).extend({simpleDate: false});
    self.endDate = ko.observable(act.endDate).extend({simpleDate: false});
    self.plannedStartDate = ko.observable(act.plannedStartDate).extend({simpleDate: false});
    self.plannedEndDate = ko.observable(act.plannedEndDate).extend({simpleDate: false});
    self.projectStage = 'Stage 1'; // hardwire until we have a scheme for picking the stage by date
    self.progress = ko.observable(progress).extend({withPrevious:progress});
    self.censusMethod = ko.observable(act.censusMethod);
    self.methodAccuracy = ko.observable(act.methodAccuracy);
    self.collector = ko.observable(act.collector);
    self.fieldNotes = ko.observable(act.fieldNotes);
    self.projectId = ko.observable(act.projectId);
    self.mainTheme = ko.observable(act.mainTheme);
    self.siteName = ko.computed(function () {
        return lookupSiteName(self.siteId());
    });

    self.isReadOnly = ko.computed(function() {
        var isEditor = fcConfig.isEditor;
        return !isEditor;
    });
    self.isAdmin = ko.computed(function() {
        var isAdmin = fcConfig.isAdmin;
        return !!isAdmin;
    });
    self.canAddActivity = ko.computed(function () {
        return self.isAdmin();
    });
    self.canEditActivity = ko.computed(function () {
        return self.isAdmin();
    });
    self.canEditOutputData = ko.computed(function () {
        return !self.isReadOnly();
    });
    self.canDeleteActivity = ko.computed(function () {
        return self.isAdmin();
    });
    self.canUpdateStatus = ko.computed(function () {
        return !self.isReadOnly();
    });
    self.canEditType = ko.computed(function () {
        if(self.isAdmin()){
            if(self.progress() === initialProgress){
                return true;
            }
        }

        return false;
    });


    self.transients = {};
    self.transients.isSaving = ko.observable(false);
    self.transients.activityType = ko.observable();
    self.transients.created = ko.observable();
    self.transients.editActivity = ko.observable();
    self.transients.remove = ko.observable(false);
    self.transients.speciesSettings = ko.observable(speciesSettings);
    self.transients.speciesConfigurationToggle = ko.observable(false);
    self.transients.editSpeciesConfiguration = function () {
        self.transients.speciesConfigurationToggle(!self.transients.speciesConfigurationToggle());
    };
    self.transients.canEditSpeciesConfiguration = ko.computed(function () {
        return !!self.transients.speciesSettings() && self.isAdmin();
    });
    self.transients.activitySnapshot = undefined;
    self.transients.project = project;
    self.transients.activityDescription = ko.computed(function() {
        var result = "";
        if (self.type()) {
            $.each(fcConfig.activityTypes, function(i, obj) {
                $.each(obj.list, function(j, type) {
                    if (type.name === self.type()) {
                        result = type.description;
                        return false;
                    }
                });
                if (result) {
                    return false;
                }
            });
        }
        return result;
    });
    self.transients.isMilestone = ko.computed(function() {
        var milestone = false;
        if (self.type()) {
            $.each(fcConfig.activityTypes, function(i, obj) {
                $.each(obj.list, function(j, type) {
                    if (type.name === self.type()) {
                        milestone = type.type == 'Milestone';
                        return false;
                    }
                });

            });
        }

        return milestone;
    });
    self.transients.stopEditing = function () {
        self.transients.restoreActivitySnapshot();
        self.transients.editActivity(false);
    };
    self.transients.toJS = function () {
        return ko.mapping.toJS(self, {'ignore':['transients']});
    };
    self.transients.loadActivity = function (activity) {
        if(activity){
            self.deferReason(activity.deferReason); // a reason document or undefined
            self.description(activity.description);
            self.notes(activity.notes);
            self.typeCategory(activity.typeCategory);
            self.type(activity.type);
            self.startDate.date(activity.startDate || '');
            self.endDate.date(activity.endDate || '');
            self.plannedStartDate.date(activity.plannedStartDate || '');
            self.plannedEndDate.date(activity.plannedEndDate || '');
            self.censusMethod(activity.censusMethod);
            self.methodAccuracy(activity.methodAccuracy);
            self.collector(activity.collector);
            self.fieldNotes(activity.fieldNotes);
            self.mainTheme(activity.mainTheme);
        }

    };
    self.transients.restoreActivitySnapshot = function(){
        self.transients.loadActivity(self.transients.activitySnapshot);
    };
    self.transients.saveActivitySnapshot = function(){
        self.transients.activitySnapshot = self.transients.toJS()
    };
    self.transients.clear = function () {
        self.transients.loadActivity({})
    };
    /**
     * Dismiss modal showing activity edit form.
     */
    self.transients.dismissModal = ko.computed(function () {
        var a =self.transients.created(),
            b = self.transients.editActivity();

        return a || !b;
    });
    self.transients.site = ko.computed(function () {
        return lookupSite(self.siteId());
    });
    self.transients.siteArea = ko.computed(function () {
        var site = self.transients.site();
        if(site && site.extent && site.extent.geometry && site.extent.geometry.areaKmSq ){
            var precision = 4, constant = Math.pow(10, precision);
            return Math.floor(site.extent.geometry.areaKmSq * constant)/constant;
        }
    });

    self.save = function (isValid) {
        if (isValid) {
            self.transients.isSaving(true);
            var jsData =self.transients.toJS();
            var json = JSON.stringify(jsData);
            var url = fcConfig.activityUpdateUrl;
            if(self.activityId){
                url += '/' + self.activityId
            }
            return $.ajax({
                url: url,
                type: 'POST',
                data: json,
                contentType: 'application/json',
                success: function (data) {
                    if (data.error) {
                        bootbox.alert(data.detail + ' \n' + data.error);
                    } else {
                        if(!self.activityId && data.activityId){
                            self.transients.created(data.activityId);
                        } else {
                            self.transients.editActivity(false);
                        }
                    }
                },
                error: function (data) {
                    var status = data.status;
                    alert('An unhandled error occurred: ' + data.status);
                },
                complete: function () {
                    self.transients.isSaving(false);
                }
            });
        }
    };

    self.saveSite = function () {
        if (self.siteId()) {
            self.transients.isSaving(true);
            var jsData = {
                activityId: self.activityId,
                siteId: self.siteId()
            };
            var json = JSON.stringify(jsData);
            var url = fcConfig.activityUpdateUrl;
            if(self.activityId){
                url += '/' + self.activityId
            }
            return $.ajax({
                url: url,
                type: 'POST',
                data: json,
                contentType: 'application/json',
                success: function (data) {
                    if (data.error) {
                        bootbox.alert(data.detail + ' \n' + data.error);
                    }
                },
                error: function (data) {
                    var status = data.status;
                    alert('An unhandled error occurred: ' + data.status);
                },
                complete: function () {
                    self.transients.isSaving(false);
                }
            });
        }
    };

    // the following handles the modal dialog for deferral/cancel reasons
    self.displayReasonModal = ko.observable(false);
    self.displayReasonModal.trigger = ko.observable();
    self.displayReasonModal.needsToBeSaved = true; // prevents unnecessary saves when a change to progress is reverted
    self.displayReasonModal.closeReasonModal = function() {
        self.displayReasonModal(false);
        self.displayReasonModal.needsToBeSaved = true;
    };
    self.displayReasonModal.cancelReasonModal = function() {
        if (self.displayReasonModal.trigger() === 'progress_change') {
            self.displayReasonModal.needsToBeSaved = false;
            self.progress.revert();
        }
        self.displayReasonModal.closeReasonModal();
    };
    self.displayReasonModal.saveReasonDocument = function (item , event) {
        // make sure reason text has been added
        var $form = $(event.currentTarget).parents('form');
        if ($form.validationEngine('validate')) {
            if (self.displayReasonModal.trigger() === 'progress_change') {
                self.saveProgress({progress: self.progress(), activityId: self.activityId});
            }
            self.deferReason().recordOnlySave(fcConfig.documentUpdateUrl + "/" + (self.deferReason().documentId ? self.deferReason().documentId : ''));
            self.displayReasonModal.closeReasonModal();
        }
    };
    self.displayReasonModal.editReason = function () {
        // popup dialog for reason
        self.displayReasonModal.trigger('edit');
        self.displayReasonModal(true);
    };

    // save progress updates - with a reason document in some cases
    self.progress.subscribe(function (newValue) {
        if (!self.progress.changed()) { return; } // Cancel if value hasn't changed
        if (!self.displayReasonModal.needsToBeSaved) { return; } // Cancel if value hasn't changed

        if (newValue === 'deferred' || newValue === 'cancelled') {
            // create a reason document if one doesn't exist
            // NOTE that 'deferReason' role is used in both cases, ie refers to cancel reason as well
            if (self.deferReason() === undefined) {
                self.deferReason(new DocumentViewModel(
                    {role:'deferReason', name:'Deferred/canceled reason document'},
                    {activityId:act.activityId}));
            }
            // popup dialog for reason
            self.displayReasonModal.trigger('progress_change');
            self.displayReasonModal(true);
        } else if (self.displayReasonModal.needsToBeSaved) {

            if ((newValue === 'started' || newValue === 'finished') && !self.hasOutputs) {
                blockUIWithMessage('Loading activity form...');
                var url = fcConfig.activityEnterDataUrl;
                document.location.href = url + "/" + self.activityId + "?returnTo=" + here + '&progress='+newValue;
            }
            else {
                self.saveProgress({progress: newValue, activityId: self.activityId});
            }
        }
    });
    self.plannedStartDate.subscribe(function(newValue) {
        // Keep start and end dates the same for a milestone.
        if (self.transients.isMilestone()) {
            self.plannedEndDate(newValue);
        }
    });
    self.transients.isMilestone.subscribe(function(newValue) {
        if (newValue) {
            self.plannedEndDate(self.plannedStartDate());
        }
    });
    self.transients.editActivity.subscribe(function(newValue) {
        if (newValue) {
            self.transients.saveActivitySnapshot();
        }
    });
    // update typeCategory
    self.type.subscribe(function(newType){
        $.each(fcConfig.activityTypes, function(i, obj) {
            $.each(obj.list, function(j, type) {
                if (type.name === newType) {
                    self.typeCategory(type.type);
                }
            });
        });
    });
    self.siteId.subscribe(self.saveSite);

    self.saveProgress = function(payload) {
        self.transients.isSaving(true);
        // save new status
        $.ajax({
            url: fcConfig.activityUpdateUrl + "/" + self.activityId,
            type: 'POST',
            data: JSON.stringify(payload),
            contentType: 'application/json',
            success: function (data) {
                if (data.error) {
                    alert(data.detail + ' \n' + data.error);
                }
                drawGanttChart(planViewModel.getGanttData());
            },
            error: function (data) {
                bootbox.alert('The activity was not updated due to a login timeout or server error.  Please try again after the page reloads.', function() {location.reload();});
            },
            complete: function () {
                self.transients.isSaving(false);
            }
        });
    };
    self.editActivity = function () {
        var url;
        if (self.isReadOnly() || (self.progress() == 'finished')) {
            self.viewActivity();
        } else if (self.canEditOutputData()) {
            url = fcConfig.activityEnterDataUrl;
            document.location.href = url + "/" + self.activityId +
                "?returnTo=" + here;
        } else if (self.canEditActivity()) {
            // toggle
            self.transients.editActivity(!self.transients.editActivity())
        }
    };
    self.editActivityMetadata = function () {
        self.transients.editActivity(true)
    };

    self.viewActivity = function() {
        url = fcConfig.activityViewUrl;
        document.location.href = url + "/" + self.activityId +
            "?returnTo=" + here;
    };
    self.deleteActivity = function () {
        // confirm first
        bootbox.confirm("Delete this activity? Are you sure?", function(result) {
            if (result) {
                $.getJSON(fcConfig.activityDeleteUrl + '/' + self.activityId,
                    function (data) {
                        if (data.code < 400) {
                            self.transients.remove(true);
                        } else {
                            alert("Failed to delete activity - error " + data.code);
                        }
                    });
            }
        });
    };


    var reasonDocs = $.grep(act.documents || [], function(document) {
        return document.role === 'deferReason';
    });
    if (reasonDocs.length > 0) {
        self.deferReason(new DocumentViewModel(reasonDocs[0], {activityId:act.activityId/*, projectId:project.projectId*/}));
    }
    self.isApproved = function() {
        return self.publicationStatus == 'published';
    };
    self.isSubmitted = function() {
        return self.publicationStatus == 'pendingApproval';
    };
    if (!act.mainTheme && fcConfig.themes.length == 1) {
        self.mainTheme(fcConfig.themes[0]);
    }
    if(act.siteId){
        fcConfig.siteIds = fcConfig.siteIds || [];
        if (fcConfig.siteIds.indexOf(act.siteId) < 0) {
            fcConfig.siteIds.push(act.siteId);
        }
    }
}

function PlanViewModel(config) {
    var self = this;
    var activities = config.activities,
        outputTargets = config.outputTargets,
        project = config.project,
        placeholder = config.placeholder,
        sites = config.sites;

    self.userIsCaseManager = ko.observable(fcConfig.isCaseManager);
    self.selectedWorksActivityViewModel = ko.observable();
    self.canEditOutputTargets = ko.computed(function() {
        var isEditor = fcConfig.isEditor;
        return isEditor;
    });
    self.openActivityModal = function (activity) {
        activity.editActivityMetadata();
        self.selectedWorksActivityViewModel(activity);
    };
    //this.currentDate = ko.observable("2014-02-03T00:00:00Z"); // mechanism for testing behaviour at different dates
    self.currentDate = ko.observable(new Date().toISOStringNoMillis()); // mechanism for testing behaviour at different dates

    self.progressOptions = ['planned','started','finished','deferred','cancelled'];
    self.projectSpeciesFieldsConfigurationViewModel = new ProjectSpeciesFieldsConfigurationViewModel(
        project.projectId,
        project.speciesFieldsSettings,
        placeholder
    );
    self.speciesFieldsConfiguration = function () {
        var context = '',
            projectId = project.projectId,
            returnTo = '&returnTo=' + document.location.href;
        if (projectId) {
            context = '&projectId=' + projectId;
        }
        document.location.href = fcConfig.configureSpeciesFieldsUrl + '?' + context + returnTo;
    };

    self.openSite = function () {
        var siteId = this.siteId();
        if (siteId !== '') {
            document.location.href = fcConfig.siteViewUrl + '/' + siteId;
        }
    };
    self.descriptionExpanded = ko.observable(false);
    self.toggleDescriptions = function() {
        self.descriptionExpanded(!self.descriptionExpanded());
        adjustTruncations();
    };
    var mockActivity = {
        activityId: "",
        siteId: null,
        projectId: project.projectId
    };
    self.newActivityViewModel = new WorksActivityViewModel({act: mockActivity, project: project, planViewModel: self});
    self.selectedWorksActivityViewModel(self.newActivityViewModel);

    self.submitReport = function (e) {
        //bootbox.alert("Reporting has not been enabled yet.");
        $('#declaration').modal('show');
    };
    self.getGanttData = function () {
        var values = [],
            previousStage = '',
            hasAnyValidPlannedEndDate = false;
        $.each([self.activities], function (i, stage) {
            $.each(stage.activities(), function (j, act) {
                var statusClass = 'gantt-' + act.progress(),
                    startDate = act.plannedStartDate.date().getTime(),
                    endDate = act.plannedEndDate.date().getTime();
                var isMilestone = act.typeCategory() == 'Milestone';
                if (!isNaN(startDate)) {
                    values.push({
                        name:act.projectStage === previousStage ? '' : act.projectStage,
                        desc:act.type(),
                        values: [{
                            label: act.type(),
                            from: "/Date(" + startDate + ")/",
                            to: "/Date(" + endDate + ")/",
                            customClass: isMilestone ? 'milestone' : statusClass,
                            dataObj: act
                        }]
                    });
                }
                hasAnyValidPlannedEndDate |= !isNaN(endDate);
                previousStage = act.projectStage;
            });
        });
        // don't return any data if there is no valid end date because the lib will throw an error
        return hasAnyValidPlannedEndDate ? values : [];
    };
    self.outputTargets = ko.observableArray([]);
    self.saveOutputTargets = function() {
        if (self.canEditOutputTargets()) {
            if ($('#outputTargetsContainer').validationEngine('validate')) {
                var targets = [];
                $.each(self.outputTargets(), function (i, target) {
                    $.merge(targets, target.toJSON());
                });
                var project = {projectId:project.projectId, outputTargets:targets};
                var json = JSON.stringify(project);
                var url = fcConfig.projectUpdateUrl;
                $.ajax({
                    url: url,
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
                        alert('An unhandled error occurred: ' + data.status);
                    },
                    complete: function(data) {
                        $.each(self.outputTargets(), function(i, target) {
                            // The timeout is here to ensure the save indicator is visible long enough for the
                            // user to notice.
                            setTimeout(function(){target.clearSaving();}, 1000);
                        });
                    }
                });
            } else {
                // clear the saving indicator when validation fails
                $.each(self.outputTargets(), function (i, target) {
                    target.clearSaving();
                });
            }
        }
    };
    self.addOutputTarget = function(target) {
        var newOutputTarget = new OutputTarget(target);
        self.outputTargets.push(newOutputTarget);
        newOutputTarget.target.subscribe(function() {
            if (self.canEditOutputTargets()) {
                newOutputTarget.isSaving(true);
                self.saveOutputTargets();
            }
        });
    };
    self.createWorkActivityViewModel = function (act, index) {
        var config = {
            act: act,
            project: project,
            planViewModel: self,
            speciesSettings: self.projectSpeciesFieldsConfigurationViewModel.findOrCreateSpeciesSettingsForActivityType(act.type)
        };
        var activity = new WorksActivityViewModel(config);
        activity.type.subscribe(function () {
            activity.transients.speciesSettings(self.projectSpeciesFieldsConfigurationViewModel.findOrCreateSpeciesSettingsForActivityType(activity.type()));
            self.updateProjectSpeciesConfiguration();
        });

        activity.transients.remove.subscribe(function (newValue) {
            if(newValue){
                setTimeout(function(){
                    self.activities.activities.remove(activity);
                }, 500);
            }
        });

        // update selectedWorksActivityViewModel
        activity.displayReasonModal.subscribe(function (newValue) {
            if(newValue){
                self.selectedWorksActivityViewModel(activity);
            }
        });

        return activity;
    };
    /**
     * Remove species configuration that are no longer relevant.
     */
    self.updateProjectSpeciesConfiguration = function () {
        var activityTypes = self.activities.listUniqueActivityTypes();
        var configs = self.projectSpeciesFieldsConfigurationViewModel.surveysToConfigure() || [];
        var configsToRemove = [];
        configs.forEach(function (config) {
            if(activityTypes.indexOf(config.name()) == -1){
                configsToRemove.push(config)
            }
        });

        self.projectSpeciesFieldsConfigurationViewModel.surveysToConfigure.removeAll(configsToRemove)
    };

    self.addNewActivity = function(activityId) {
        if(activityId){
            $.ajax({
                url: fcConfig.activityJsonUrl + '/' + activityId + '?format=json',
                success: function (data) {
                    if(!data.error){
                        var activity = self.createWorkActivityViewModel(data, self.activities.activities().length);
                        self.activities.addActivity(activity);
                        drawGanttChart(self.getGanttData());
                    } else {
                        bootbox.alert("An error occurred while loading activity.");
                    }
                },
                error: function (data) {
                    bootbox.alert("Failed to load activity.");
                }
            }).done(function () {
                self.newActivityViewModel.transients.created('');
                self.newActivityViewModel.transients.clear();
            });
        }
    };
    self.newActivityViewModel.transients.created.subscribe(self.addNewActivity);
    // metadata for setting up the output targets
    self.targetMetadata = fcConfig.outputTargetMetadata;

    var outputTargetHelper = new OutputTargets(activities, outputTargets, self.canEditOutputTargets, self.targetMetadata,  {saveTargetsUrl:fcConfig.projectUpdateUrl});
    $.extend(self, outputTargetHelper);
    self.saveOutputTargets = function() {
        var result;
        if (self.canEditOutputTargets()) {
            if ($('#outputTargetsContainer').validationEngine('validate')) {
                return outputTargetHelper.saveOutputTargets();

            } else {
                // clear the saving indicator when validation fails
                $.each(self.outputTargets(), function (i, target) {
                    target.clearSaving();
                });
            }
        }
    };

    self.loadActivities = function (activities) {
        return new PlanStage('', activities, self, true, project)
    };
    self.activities = self.loadActivities(activities);
}

function PlanStage(stage, activities, planViewModel, isCurrentStage, project) {
    var stageLabel = '';

    // Note that the two $ transforms used to extract activities are not combined because we
    // want the index of the PlannedActivity to be relative to the filtered set of activities.
    var self = this,
        activitiesInThisStage = activities;
    self.label = stageLabel;
    self.isCurrentStage = isCurrentStage;
    self.isReportable = fcConfig.enableReporting? stage.toDate < new Date().toISOStringNoMillis() : false;
    self.projectId = project.projectId;
    self.planViewModel = planViewModel;

    // sort activities by assigned sequence or date created (as a proxy for sequence).
    // CG - still needs to be addressed properly.
    activitiesInThisStage.sort(function (a,b) {
        if (a.sequence !== undefined && b.sequence !== undefined) {
            return a.sequence - b.sequence;
        }
        if (a.plannedStartDate != b.plannedStartDate) {
            return a.plannedStartDate < b.plannedStartDate ? -1 : (a.plannedStartDate > b.plannedStartDate ? 1 : 0);
        }


        var numericActivity = /[Aa]ctivity (\d+)(\w)?.*/;
        var first = numericActivity.exec(a.description);
        var second = numericActivity.exec(b.description);
        if (first && second) {
            var firstNum = Number(first[1]);
            var secondNum = Number(second[1]);
            if (firstNum == secondNum) {
                // This is to catch activities of the form Activity 1a, Activity 1b etc.
                if (first.length == 3 && second.length == 3) {
                    return first[2] > second[2] ? 1 : (first[2] < second[2] ? -1 : 0);
                }
            }
            return  firstNum - secondNum;
        }
        else {
            if (a.dateCreated !== undefined && b.dateCreated !== undefined && a.dateCreated != b.dateCreated) {
                return a.dateCreated < b.dateCreated ? 1 : -1;
            }
            return a.description > b.description ? 1 : (a.description < b.description ? -1 : 0);
        }

    });
    self.sortActivities = function (newValue, activity) {
        self.activities.sort(function (left, right) {
            return left.plannedStartDate.date() == right.plannedStartDate.date() ? 0 : (left.plannedStartDate.date() < right.plannedStartDate.date() ? -1 : 1)
        });
    };

    self.checkForEditAndSort = function (newValue) {
        if(!newValue){
            self.sortActivities();
        }
    };

    self.activities = ko.observableArray($.map(activitiesInThisStage, function (act, index) {
        act.projectStage = stageLabel;
        var activity = planViewModel.createWorkActivityViewModel(act, index);
        activity.transients.editActivity.subscribe(self.checkForEditAndSort);
        return activity
    }));

    self.addActivity = function (activity) {
        if(activity){
            self.activities.push(activity);
            activity.transients.editActivity.subscribe(self.checkForEditAndSort);
            self.sortActivities();
        }
    };

    /**
     * List all activity types.
     */
    self.listUniqueActivityTypes = function () {
        var types = [];
        self.activities().forEach(function (activity) {
            if(types.indexOf(activity.type()) === -1){
                types.push(activity.type());
            }
        });

        return types;
    };

    /**
     * A stage is considered to be approved when all of the activities in the stage have been marked
     * as published.
     */
    self.isApproved = ko.computed(function() {
        var numActivities = self.activities() ? self.activities().length : 0;
        if (numActivities == 0) {
            return false;
        }
        return $.grep(self.activities(), function(act, i) {
            return act.isApproved();
        }).length == numActivities;
    }, self, {deferEvaluation: true});
    self.isSubmitted = ko.computed(function() {
        var numActivities = self.activities() ? self.activities().length : 0;
        if (numActivities == 0) {
            return false;
        }
        return $.grep(self.activities(), function(act, i) {
            return act.isSubmitted();
        }).length == numActivities;
    }, self, {deferEvaluation: true});


    self.stageStatusTemplateName = ko.computed(function() {
        if (!self.isReportable) {
            return 'stageNotReportableTmpl';
        }
        if (self.isApproved()) {
            return 'stageApprovedTmpl';
        }
        if (self.isSubmitted()) {
            return 'stageSubmittedTmpl';
        }
        return 'stageNotApprovedTmpl';
    });
};


function lookupSiteName (siteId) {
    var site = lookupSite(siteId) || {};
    return site.name;
}

function lookupSite (siteId) {
    var site;
    if (siteId !== undefined && siteId !== '') {
        site = $.grep(fcConfig.sites, function(obj, i) {
            return (obj.siteId === siteId);
        });

        if (site.length > 0) {
            return site[0];
        }
    }
}
/**
* It is for  projects which contain a list of site ids instead of sites
 * e.g workprojects
* @param sites
* @param addNotFoundSite
* @returns {Array}
 */
function resolveSites(sites, addNotFoundSite) {
    var resolved = [];
    sites = sites || [];

    sites.forEach(function (siteId) {
        var site;
        if(typeof siteId === 'string'){
            site = lookupSite(siteId);

             if(site){
                    resolved.push(site);
                } else if(addNotFoundSite && siteId) {
                    resolved.push({
                        name: 'User created site',
                        siteId: siteId
                    });
                }
        } else if(typeof siteId === 'object'){
            resolved.push(siteId);
        }
    });

    return resolved;
}

function drawGanttChart(ganttData) {
    if (ganttData.length > 0) {
        $("#gantt-container").gantt({
            source: ganttData,
            navigate: "keys",
            scale: "weeks",
            itemsPerPage: 30
        });
    }
}