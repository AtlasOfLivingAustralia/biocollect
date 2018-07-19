/*
 * Copyright (C) 2018 Atlas of Living Australia
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
 * Created by Temi on 6/6/18.
 */

//= require_self
// $.fn.select2.defaults.set("width", "100%");

function validateDateField(dateField) {
    var date = stringToDate($(dateField).val());

    if (!isValidDate(date)) {
        return "Date must be in the format dd-MM-YYYY";
    }
}

/* Master controller for page. This handles saving each model as required. */
function Master(activityId, config) {
    var self = this;
    self.subscribers = [];

    // client models register their name and methods to participate in saving
    self.register = function (modelInstanceName, getMethod, isDirtyMethod, resetMethod) {
        self.subscribers.push({
            model: modelInstanceName,
            get: getMethod,
            isDirty: isDirtyMethod,
            reset: resetMethod
        });

        if (ko.isObservable(isDirtyMethod)) {
            isDirtyMethod.subscribe(function () {
                self.dirtyCheck();
            });
        }
    };

    self.dirtyCheck = function () {
        self.dirtyFlag.isDirty(self.isDirty());
    };

    /**
     *  Takes into account changes to the photo point photo's as the default knockout dependency
     *  detection misses edits to some of the fields.
     */
    self.dirtyFlag = {
        isDirty: ko.observable(false),
        reset: function () {
            $.each(self.subscribers, function (i, obj) {
                obj.reset();
            });
        }
    };

    // master isDirty flag for the whole page - can control button enabling
    self.isDirty = function () {
        var dirty = false;
        $.each(this.subscribers, function (i, obj) {
            dirty = dirty || obj.isDirty();
        });

        return dirty;
    };

    /**
     * Collect the activity form data into a single javascript object
     * @returns JS object containing form data, or null if there is no data
     */
    self.collectData = function () {
        var activityData, outputs = [], photoPoints;
        $.each(this.subscribers, function (i, obj) {
            if (obj.model === 'activityModel') {
                activityData = obj.get();
            } else if (obj.model === 'photoPoints' && obj.isDirty()) {
                photoPoints = obj.get();
            }
            else { // Update outputs unconditionally, backend needs the activityModel and outputs to
                // create derived data even if outputs didn't change
                outputs.push(obj.get());
            }
        });
        if (outputs.length === 0 && activityData === undefined && photoPoints === undefined) {
            return {validation: false, message: "Nothing need to be updated!"};
        }
        if (typeof activityLevelData.checkMapInfo === "function") {
            var mapInfoCheck = activityLevelData.checkMapInfo();

            if (!mapInfoCheck.validation) {
                return mapInfoCheck;
            }
            else {
                if (activityData === undefined) {
                    activityData = {}
                }
                activityData.outputs = outputs;
                //assign siteId to activity
                if (activityLevelData.siteId())
                    activityData.siteId = activityLevelData.siteId();

                return activityData;
            }
        } else {
            //quick fix for some suverys which don't have map
            if (activityData === undefined) {
                activityData = {}
            }
            activityData.outputs = outputs;
            return activityData;
        }
    };

    self.removeTemporarySite = function () {
        var sites = this.subscribers[0].model.data.locationSitesArray();
        var linkedSite = this.subscribers[0].model.data.location();

        var waitingForDelete = _.find(sites, function (site) {
            return site.siteId != linkedSite && site.visibility == 'private'
        })

        var siteUrl = config.siteDeleteUrl;
        if (waitingForDelete) {
            console.log('Found a temporary site ' + waitingForDelete.siteId);
            $.ajax({
                method: 'POST',
                url: siteUrl + "?id=" + waitingForDelete.siteId,
                data: JSON.stringify({id: waitingForDelete}),
                contentType: 'application/json',
                dataType: 'json'
            });
        }

    }


    /**
     * Makes an ajax call to save any sections that have been modified. This includes the activity
     * itself and each output.
     *
     * Modified outputs are injected as a list into the activity object. If there is nothing to save
     * in the activity itself, then the root is an object that is empty except for the outputs list.
     *
     * NOTE that the model for each section must register itself to be included in this save.
     *
     * Validates the entire page before saving.
     */
    self.save = function () {
        if ($('#validation-container').validationEngine('validate')) {
            var toSave = this.collectData();

            if (toSave.hasOwnProperty('validation')) {
                if (!toSave.validation) {
                    alert(toSave.message);
                    return;
                }

            }

            toSave = JSON.stringify(toSave);

            // Don't allow another save to be initiated.
            blockUIWithMessage("Saving activity data...");

            amplify.store('activity-' + config.activityId, toSave);
            var unblock = true;
            var url = config.isMobile ? config.bioActivityMobileUpdate : config.bioActivityUpdate;
            var ajaxRequestParams = {
                url: url,
                type: 'POST',
                data: toSave,

                contentType: 'application/json',
                success: function success(data) {
                    var errorText = "";
                    var activityId;
                    if (data.errors) {
                        errorText = "<span class='label label-important'>Important</span><h4>There was an error while trying to save your changes.</h4>";
                        $.each(data.errors, function (i, error) {
                            errorText += "<p>Saving <b>" +
                                (error.name === 'activity' ? 'the activity context' : error.name) +
                                "</b> threw the following error:<br><blockquote>" + error.error + "</blockquote></p>";
                        });
                        errorText += "<p>Any other changes should have been saved.</p>";
                        bootbox.alert(errorText);
                    } else if (data.error) {
                        bootbox.alert(data.error);
                    } else {
                        unblock = false; // We will be transitioning off this page.
                        activityId = config.activityId || data.resp.activityId;
                        config.returnTo = config.bioActivityView + activityId;
                        blockUIWithMessage("Successfully submitted the record.");
                        self.reset();
                        self.saved();
                    }
                    amplify.store('activity-' + config.activityId, null);
                },
                error: function (jqXHR, status, error) {

                    // This is to detect a redirect to CAS response due to session timeout, which is not
                    // 100% reliable using ajax (e.g. no network will give the same response).
                    if (jqXHR.readyState == 0) {
                        bootbox.alert($('#timeoutMessage').html());
                    }
                    else {
                        alert('An unhandled error occurred: ' + error);
                    }
                },
                complete: function () {
                    if (unblock) {
                        $.unblockUI();
                    }
                }
            };

            if (config.isMobile) {
                $.extend(ajaxRequestParams, {
                    xhrFields: {
                        withCredentials: true
                    },
                    beforeSend: function (xhr) {
                        xhr.setRequestHeader('userName', config.userName);
                        xhr.setRequestHeader('authKey', config.authKey);
                    }
                });
            }

            $.ajax(ajaxRequestParams);
        }
    };

    self.saved = function () {
        if (config.isMobile) {
            location.href = config.returnToMobile;
        } else {
            document.location.href = config.returnTo;
        }
    };

    self.reset = function () {
        $.each(this.subscribers, function (i, obj) {
            if (obj.isDirty()) {
                obj.reset();
            }
        });
    };

    autoSaveModel(self, null, {preventNavigationIfDirty: true});
};

function ActivityHeaderViewModel (act, site, project, metaModel, pActivity, config) {
    var self = this;
    self.activityId = act.activityId;
    self.notes = ko.observable(act.notes);
    self.eventPurpose = ko.observable(act.eventPurpose);
    self.fieldNotes = ko.observable(act.fieldNotes);
    self.projectStage = ko.observable(act.projectStage || "");
    self.mainTheme = ko.observable(act.mainTheme);
    self.type = ko.observable(act.type);
    self.projectId = act.projectId;
    self.transients = {};
    self.transients.pActivity = new pActivityInfo(pActivity);
    self.transients.pActivitySites = pActivity.sites;
    self.transients.site = ko.observable(site);
    self.transients.project = project;
    self.transients.outputs = [];
    self.transients.metaModel = metaModel || {};

    self.confirmSiteChange = function () {
        if (self.transients.photoPointModel && self.transients.photoPointModel().isDirty()) {
            return window.confirm(
                "This activity has photos attached to photo points.\n  Changing the site will delete these photos.\n  This cannot be undone.  Are you sure?"
            );
        }
        return true;
    };
    self.siteId = ko.vetoableObservable(act.siteId, self.confirmSiteChange);

    self.siteId.subscribe(function (siteId) {

        var matchingSite = $.grep(self.transients.pActivitySites, function (site) {
            return siteId == site.siteId
        })[0];

        if (matchingSite && matchingSite.extent && matchingSite.extent.geometry) {
            var geometry = matchingSite.extent.geometry;
            if (geometry.pid) {
                activityLevelData.siteMap.addWmsLayer(geometry.pid);
            } else {
                var geoJson = ALA.MapUtils.wrapGeometryInGeoJSONFeatureCol(geometry);
                activityLevelData.siteMap.setGeoJSON(geoJson);
            }
        }
        self.transients.site(matchingSite);

        if (metaModel.supportsPhotoPoints) {
            self.updatePhotoPointModel(matchingSite);
        }
    });

    self.goToProject = function () {
        if (self.projectId) {
            document.location.href = config.projectViewUrl + self.projectId;
        }
    };

    self.goToSite = function () {
        if (self.siteId()) {
            document.location.href = config.siteViewUrl + self.siteId();
        }
    };

    if (metaModel.supportsPhotoPoints) {
        self.transients.photoPointModel = ko.observable(new PhotoPointViewModel(site, activityLevelData.activity));
        self.updatePhotoPointModel = function (site) {
            self.transients.photoPointModel(new PhotoPointViewModel(site, activityLevelData.activity));
        };
    }

    self.modelForSaving = function () {
        // get model as a plain javascript object
        var jsData = ko.mapping.toJS(self, {'ignore':['transients']});
        if (metaModel.supportsPhotoPoints) {
            jsData.photoPoints = self.transients.photoPointModel().modelForSaving();
        }

        // If we leave the site or theme undefined, it will be ignored during JSON serialisation and hence
        // will not overwrite the current value on the server.
        var possiblyUndefinedProperties = ['siteId', 'mainTheme'];

        $.each(possiblyUndefinedProperties, function(i, propertyName) {
            if (jsData[propertyName] === undefined) {
                jsData[propertyName] = '';
            }
        });

        return jsData;
    };

    self.modelAsJSON = function () {
        return JSON.stringify(self.modelForSaving());
    };

    self.save = function (callback, key) {
    };

    self.removeActivity = function () {
        bootbox.confirm("Delete this entire activity? Are you sure?", function(result) {
            if (result) {
                document.location.href = config.activityDeleteAndReturnToUrl;
            }
        });
    };

    self.notImplemented = function () {
        alert("Not implemented yet.")
    };

    self.dirtyFlag = ko.dirtyFlag(self, false);
}

function initialiseOutputViewModel(outputViewModelName, dataModel, elementId, activity, output, master, config) {
    var viewModelInstance = outputViewModelName + 'Instance';

    var context = {
        project: config.project,
        activity: activity,
        documents: activity.documents,
        site: activity.site
    };
    ecodata.forms[viewModelInstance] = new ecodata.forms[outputViewModelName](output, dataModel, context, config);
    ecodata.forms[viewModelInstance].loadData(output.data);

    // dirtyFlag must be defined after data is loaded
    ecodata.forms[viewModelInstance].dirtyFlag = ko.simpleDirtyFlag(ecodata.forms[viewModelInstance], false);

    ko.applyBindings(ecodata.forms[viewModelInstance], document.getElementById(elementId));

    // this resets the baseline for detecting changes to the model
    // - shouldn't be required if everything behaves itself but acts as a backup for
    //   any binding side-effects
    // - note that it is not foolproof as applying the bindings happens asynchronously and there
    //   is no easy way to detect its completion
    ecodata.forms[viewModelInstance].dirtyFlag.reset();

    // register with the master controller so this model can participate in the save cycle
    master.register(ecodata.forms[viewModelInstance], ecodata.forms[viewModelInstance].modelForSaving,
        ecodata.forms[viewModelInstance].dirtyFlag.isDirty, ecodata.forms[viewModelInstance].dirtyFlag.reset);

    // Check for locally saved data for this output - this will happen in the event of a session timeout
    // for example.
    var savedData = amplify.store('activity-' + activity.activityId);
    var savedOutput = null;
    if (savedData) {
        var outputData = $.parseJSON(savedData);
        if (outputData.outputs) {
            $.each(outputData.outputs, function (i, tmpOutput) {
                if (tmpOutput.name === output.name) {
                    if (tmpOutput.data) {
                        savedOutput = tmpOutput.data;
                    }
                }
            });
        }
    }
    if (savedOutput) {
        ecodata.forms[viewModelInstance].loadData(savedOutput);
    }
};