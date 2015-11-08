<%@ page import="grails.converters.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>

<div class="container-fluid validationEngineContainer" id="validation-container">
    <div id="koActivityMainBlock">
<g:if test="${!printView}">
    <ul class="breadcrumb">
        <li><g:link controller="home">Home</g:link> <span class="divider">/</span></li>
        <li><a data-bind="click:goToProject" href="#" class="clickable">Project</a> <span class="divider">/</span></li>
        <li class="active">
            <span>${activity.type}</span>
        </li>
    </ul>
</g:if>

<g:render template="header"></g:render>

<!-- ko stopBinding: true -->
<g:each in="${metaModel?.outputs}" var="outputName">
    <g:if test="${outputName != 'Photo Points'}">
        <g:set var="blockId" value="${fc.toSingleWord([name: outputName])}"/>
        <g:set var="model" value="${outputModels[outputName]}"/>
        <g:set var="output" value="${activity.outputs.find { it.name == outputName }}"/>
        <g:if test="${!output}">
            <g:set var="output" value="[name: outputName]"/>
        </g:if>

        <md:modelStyles model="${model}" edit="true"/>

        <div class="output-block well" id="ko${blockId}">

            <h3 data-bind="css:{modified:dirtyFlag.isDirty},attr:{title:'Has been modified'}">${outputName}</h3>

            <!-- add the dynamic components -->

            <md:modelView model="${model}" site="${site}" edit="true" output="${output.name}"
                          printable="${printView}"/>

            <r:script>
                    $(function(){
                        var viewModelName = "${blockId}ViewModel", viewModelInstance = viewModelName + "Instance";

                        // load dynamic models - usually objects in a list
                <md:jsModelObjects model="${model}" site="${site}" edit="true"
                                   viewModelInstance="${blockId}ViewModelInstance"/>

                this[viewModelName] = function () {
                    var self = this;
                    self.name = "${output.name}";
                            self.outputId = "${output.outputId}";
                            self.data = {};
                            self.transients = {};
                            self.transients.dummy = ko.observable();
                            // add declarations for dynamic data
                <md:jsViewModel model="${model}" output="${output.name}" edit="true"
                                viewModelInstance="${blockId}ViewModelInstance"/>
                // this will be called when generating a savable model to remove transient properties
                self.removeBeforeSave = function (jsData) {
                    // add code to remove any transients added by the dynamic tags
                <md:jsRemoveBeforeSave model="${model}"/>
                delete jsData.activityType;
                delete jsData.transients;
                return jsData;
            };

            // this returns a JS object ready for saving
                <md:jsSaveModel model="${model}" output="${output}"/>

                // this is a version of toJSON that just returns the model as it will be saved
                // it is used for detecting when the model is modified (in a way that should invoke a save)
                // the ko.toJSON conversion is preserved so we can use it to view the active model for debugging
                self.modelAsJSON = function () {
                    return JSON.stringify(self.modelForSaving());
                };

                self.loadData = function (data) {
                    // load dynamic data
                <md:jsLoadModel model="${model}" defaultData="${defaultData}"/>

                // if there is no data in tables then add an empty row for the user to add data
                if (typeof self.addRow === 'function' && self.rowCount() === 0) {
                    self.addRow();
                }
                self.transients.dummy.notifySubscribers();
            };
        };

        window[viewModelInstance] = new this[viewModelName](site);

        var output = ${output.data ?: '{}'};

                window[viewModelInstance].loadData(output);

                        // dirtyFlag must be defined after data is loaded
                <md:jsDirtyFlag model="${model}"/>

                ko.applyBindings(window[viewModelInstance], document.getElementById("ko${blockId}"));

                        // this resets the baseline for detecting changes to the model
                        // - shouldn't be required if everything behaves itself but acts as a backup for
                        //   any binding side-effects
                        // - note that it is not foolproof as applying the bindings happens asynchronously and there
                        //   is no easy way to detect its completion
                        window[viewModelInstance].dirtyFlag.reset();

                        // register with the master controller so this model can participate in the save cycle
                        master.register(window[viewModelInstance], window[viewModelInstance].modelForSaving,
                            window[viewModelInstance].dirtyFlag.isDirty, window[viewModelInstance].dirtyFlag.reset);

                        // Check for locally saved data for this output - this will happen in the event of a session timeout
                        // for example.
                        var savedData = amplify.store('activity-${activity.activityId}');
                        var savedOutput = null;
                        if (savedData) {
                            var outputData = $.parseJSON(savedData);
                            $.each(outputData.outputs, function(i, tmpOutput) {
                                if (tmpOutput.name === '${output.name}') {
                                    if (tmpOutput.data) {
                                        savedOutput = tmpOutput.data;
                                    }
                                }
                            });
                        }
                        if (savedOutput) {
                            window[viewModelInstance].loadData(savedOutput);
                        }
                    });
            </r:script>
        </div>
    </g:if>
</g:each>
<!-- /ko -->


<g:if test="${metaModel.supportsSites?.toBoolean()}">
    <div class="row-fluid">

        <div class="span12 well">
            <h3>Site Details:</h3>
            <fc:select
                    data-bind='options:transients.pActivitySites,optionsText:"name",optionsValue:"siteId",value:siteId,optionsCaption:"Choose a site..."'
                    printable="${printView}"/>
            <div id="siteMap" style="width:100%; height: 512px;"></div>
        </div>

    </div>
</g:if>

<g:if test="${metaModel.supportsPhotoPoints?.toBoolean()}">
    <div class="output-block well" data-bind="with:transients.photoPointModel">
        <h3>Photo Points</h3>
        <g:render template="/site/photoPoints"></g:render>
    </div>
</g:if>

<g:if test="${!printView}">
    <div class="form-actions">
        <button type="button" id="save" class="btn btn-primary">Submit</button>
        <button type="button" id="cancel" class="btn">Cancel</button>
    </div>
</g:if>

<g:if env="development" test="${!printView}">
    <div class="expandable-debug">
        <hr/>

        <h3>Debug</h3>

        <div>
            <h4>KO model</h4>
            <pre data-bind="text:ko.toJSON($root.modelForSaving(),null,2)"></pre>
            <h4>Activity</h4>
            <pre>${activity?.encodeAsHTML()}</pre>
            <h4>Site</h4>
            <pre>${site?.encodeAsHTML()}</pre>
            <h4>Sites</h4>
            <pre>${(sites as JSON).toString()}</pre>
            <h4>Project</h4>
            <pre>${project?.encodeAsHTML()}</pre>
            <h4>Activity model</h4>
            <pre>${metaModel}</pre>
            <h4>Output models</h4>
            <pre>${outputModels?.encodeAsHTML()}</pre>
            <h4>Map features</h4>
            <pre>${mapFeatures.toString()}</pre>
        </div>
    </div>
</g:if>

</div>

<div id="timeoutMessage" class="hide">

    <span class='label label-important'>Important</span><h4>There was an error while trying to save your changes.</h4>

    <p>This could be because your login has timed out or the internet is unavailable.</p>

    <p>Your data has been saved on this computer but you may need to login again before the data can be sent to the server.</p>
    <a href="${createLink(action: 'enterData', id: activity.activityId)}?returnTo=${returnTo}">Click here to refresh your login and reload this page.</a>
</div>


<g:render template="/shared/imagerViewerModal" model="[readOnly: false]"></g:render>

<r:script>
        var returnTo = "${returnTo}";

        /* Master controller for page. This handles saving each model as required. */
        var Master = function () {
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
            };

            // master isDirty flag for the whole page - can control button enabling
            this.isDirty  = function () {
                var dirty = false;
                $.each(this.subscribers, function(i, obj) {
                    dirty = dirty || obj.isDirty();
                });
                return dirty;
            };

            /**
             * Collect the activity form data into a single javascript object
             * @returns JS object containing form data, or null if there is no data
             */
            this.collectData = function() {
                var activityData, outputs = [], photoPoints;
                $.each(this.subscribers, function(i, obj) {
                    if (obj.model === 'activityModel') {
                        activityData = obj.get();
                    } else if (obj.model === 'photoPoints' && obj.isDirty()) {
                        photoPoints = obj.get();
                    }
                    else if (obj.isDirty()) {
                        outputs.push(obj.get());
                    }
                });
                if (outputs.length === 0 && activityData === undefined && photoPoints === undefined) {
                    return null;
                } else {
                    if (activityData === undefined) {
                        activityData = {}
                    }
                    activityData.outputs = outputs;

                    return activityData;
                }
            };

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
            this.save = function () {
                if ($('#validation-container').validationEngine('validate')) {
                    var toSave = this.collectData();
                    if (!toSave) {
                        alert("Nothing to save.");
                        return;
                    }

                    toSave = JSON.stringify(toSave);

                    // Don't allow another save to be initiated.
                    blockUIWithMessage("Saving activity data...");

                    amplify.store('activity-${activity.activityId}', toSave);
                    var unblock = true;
                    $.ajax({
                        url: fcConfig.bioActivityUpdate,
                        type: 'POST',
                        data: toSave,
                        contentType: 'application/json',
                        success: function (data) {
                            var errorText = "";
                            if (data.errors) {
                                errorText = "<span class='label label-important'>Important</span><h4>There was an error while trying to save your changes.</h4>";
                                $.each(data.errors, function (i, error) {
                                    errorText += "<p>Saving <b>" +
                                    (error.name === 'activity' ? 'the activity context' : error.name) +
                                    "</b> threw the following error:<br><blockquote>" + error.error + "</blockquote></p>";
                                });
                                errorText += "<p>Any other changes should have been saved.</p>";
                                bootbox.alert(errorText);
                            } else {
                                unblock = false; // We will be transitioning off this page.
                                blockUIWithMessage("Successfully submitted the record.");
                                self.reset();
                                self.saved();
                            }
                            amplify.store('activity-${activity.activityId}', null);
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
                    });
                }
            };

            this.saved = function () {
                document.location.href = returnTo;
            };

            this.reset = function () {
                $.each(this.subscribers, function(i, obj) {
                    if (obj.isDirty()) {
                        obj.reset();
                    }
                });
            };
        };

        var master = new Master();

        function ActivityLevelData() {
            var self = this;
            self.activity = JSON.parse('${(activity as JSON).toString().encodeAsJavaScript()}');
            self.site = JSON.parse('${(site as JSON).toString().encodeAsJavaScript()}');
            self.pActivity = JSON.parse('${(pActivity as JSON).toString().encodeAsJavaScript()}');
        }

        var activityLevelData = new ActivityLevelData();

        $(function() {

            $('#validation-container').validationEngine('attach', {scroll: true});

            $('.helphover').popover({animation: true, trigger:'hover'});

            $('#save').click(function () {
                master.save();
            });

            $('#cancel').click(function () {
                document.location.href = returnTo;
            });

            $('#reset').click(function () {
                master.reset();
            });

            function ViewModel (act, site, project, metaModel, pActivity) {
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

                self.confirmSiteChange = function() {
                    if (self.transients.photoPointModel && self.transients.photoPointModel().isDirty()) {
                        return window.confirm(
                            "This activity has photos attached to photo points.\n  Changing the site will delete these photos.\n  This cannot be undone.  Are you sure?"
                        );
                    }
                    return true;
                };
                self.siteId = ko.vetoableObservable(act.siteId, self.confirmSiteChange);

                self.siteId.subscribe(function(siteId) {

                    var matchingSite = $.grep(self.transients.pActivitySites, function(site) { return siteId == site.siteId})[0];

                    activityLevelData.siteMap.clearFeatures();
                    if (matchingSite) {
                        activityLevelData.siteMap.replaceAllFeatures([matchingSite.extent.geometry]);
                    }
                    self.transients.site(matchingSite);

                    <g:if test="${metaModel.supportsPhotoPoints?.toBoolean()}">
                        self.updatePhotoPointModel(matchingSite);
                    </g:if>
              });

                 self.goToProject = function () {
                     if (self.projectId) {
                         document.location.href = fcConfig.projectViewUrl + self.projectId;
                     }
                 };

                 self.goToSite = function () {
                     if (self.siteId()) {
                         document.location.href = fcConfig.siteViewUrl + self.siteId();
                     }
                 };

                <g:if test="${metaModel.supportsPhotoPoints?.toBoolean()}">
                    self.transients.photoPointModel = ko.observable(new PhotoPointViewModel(site, activityLevelData.activity));
                    self.updatePhotoPointModel = function(site) {
                        self.transients.photoPointModel(new PhotoPointViewModel(site, activityLevelData.activity));
                    };
                </g:if>

                self.modelForSaving = function () {
                    // get model as a plain javascript object
                    var jsData = ko.mapping.toJS(self, {'ignore':['transients']});
                    <g:if test="${metaModel.supportsPhotoPoints?.toBoolean()}">
                        jsData.photoPoints = self.transients.photoPointModel().modelForSaving();
                    </g:if>

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
                           document.location.href = "${createLink(action: 'delete', id: activity.activityId,
                            params: [returnTo: grailsApplication.config.grails.serverURL + '/' + returnTo])}";
                        }
                    });
                };

                self.notImplemented = function () {
                    alert("Not implemented yet.")
                };

                self.dirtyFlag = ko.dirtyFlag(self, false);
            }

            var viewModel = new ViewModel(
                activityLevelData.activity,
                activityLevelData.site,
                ${project ? "JSON.parse('${project.toString().encodeAsJavaScript()}')" : 'null'},
                ${metaModel ?: 'null'},
                activityLevelData.pActivity);

            <g:if test="${metaModel.supportsSites?.toBoolean()}">
                var mapFeatures = $.parseJSON('${mapFeatures?.encodeAsJavaScript()}');
                if (!mapFeatures) {
                    mapFeatures = {zoomToBounds: true, zoomLimit: 15, highlightOnHover: true, features: []};
                }

                var mapOptions = {
                    mapContainer: "siteMap",
                    scrollwheel: false,
                    zoomToBounds:true,
                    zoomLimit:16,
                    highlightOnHover:true,
                    features:[],
                    featureService: "${createLink(controller: 'proxy', action: 'feature')}",
                    wmsServer: "${grailsApplication.config.spatial.geoserverUrl}"
                };

                activityLevelData.siteMap = new MapWithFeatures(mapOptions, mapFeatures);
            </g:if>

            ko.applyBindings(viewModel);

            master.register('activityModel', viewModel.modelForSaving, viewModel.dirtyFlag.isDirty, viewModel.dirtyFlag.reset);

        });


</r:script>
</div>
