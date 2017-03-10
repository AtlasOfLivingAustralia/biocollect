<%@ page import="grails.converters.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <g:if test="${printView}">
        <meta name="layout" content="nrmPrint"/>
        <title>Print | ${activity.type} | Field Capture</title>
    </g:if>
    <g:else>
        <meta name="layout" content="${hubConfig.skin}"/>
        <title>Edit | ${activity.type} | Field Capture</title>
    </g:else>

    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <r:script disposition="head">
    var fcConfig = {
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
        activityDeleteUrl: "${createLink(controller: 'activity', action: 'ajaxDelete')}",
        projectViewUrl: "${createLink(controller: 'project', action: 'index')}/",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}/",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        speciesProfileUrl: "${createLink(controller: 'proxy', action: 'speciesProfile')}",
        imageLocation:"${resource(dir:'/images')}",
        // And this is the start of changes to make species work
        getSingleSpeciesUrl : "${createLink(controller: 'project', action: 'getSingleSpecies', params: [id: project.projectId])}",
        speciesSearch: "${createLink(controller: 'project', action: 'searchSpecies', params: [id: project.projectId, limit: 10])}"
        },
        here = document.location.href;
    </r:script>
    <r:require modules="knockout,jqueryValidationEngine,datepicker,timepicker,jQueryFileUploadUI,map,activity,attachDocuments,species,amplify,imageDataType,imageViewer,bootstrap,viewmodels"/>
</head>
<body>
<div class="container-fluid validationEngineContainer" id="validation-container">
    <div id="koActivityMainBlock">
        <g:if test="${!printView && !hubConfig.hideBreadCrumbs}">
            <ul class="breadcrumb">
                <li><g:link controller="home">Home</g:link> <span class="divider">/</span></li>
                <li><a data-bind="click:goToProject" class="clickable">Project</a> <span class="divider">/</span></li>
                <li class="active">
                    <span data-bind="text:type"></span>
                    <span data-bind="text:startDate.formattedDate"></span><span data-bind="visible:endDate">/</span><span data-bind="text:endDate.formattedDate"></span>
                </li>
            </ul>
        </g:if>

        <div class="row-fluid title-block well well-small input-block-level">
            <div class="span12 title-attribute">
                <h1><span data-bind="click:goToProject" class="clickable">${project?.name?.encodeAsHTML() ?: 'no project defined!!'}</span></h1>
                    <div class="row-fluid">
                        <div class="span1">
                            Site:
                        </div>
                        <div class="span2">
                            <fc:select data-bind='options:transients.project.sites,optionsText:"name",optionsValue:"siteId",value:siteId,optionsCaption:"Choose a site..."' printable="${printView}"/>
                        </div>
                        <div class="span6">
                            Leave blank if this activity is not associated with a specific site.
                        </div>
                    </div>
                <h3 data-bind="css:{modified:dirtyFlag.isDirty},attr:{title:'Has been modified'}">Activity: <span data-bind="text:type"></span></h3>
                <h4><span>${project.associatedProgram?.encodeAsHTML()}</span> <span>${project.associatedSubProgram?.encodeAsHTML()}</span></h4>
            </div>
        </div>


        <div class="row-fluid">
            <div class="span9">
                <!-- Common activity fields -->

                <div class="row-fluid space-after">

                    <div class="span9 required">
                        <label class="for-readonly" for="description">Description</label>
                        <input id="description" type="text" class="input-xxlarge" data-bind="value:description" data-validation-engine="validate[required]"></span>
                    </div>
                </div>

                <div class="row-fluid space-after">
                    <div class="span6">
                        <label for="theme" class="for-readonly">Major theme</label>
                        <select id="theme" data-bind="value:mainTheme, options:transients.themes, optionsCaption:'Choose..'" class="input-xlarge">
                        </select>
                    </div>
                    <div class="span6">
                        <label class="for-readonly inline">Activity progress</label>
                        <button type="button" class="btn btn-small"
                                data-bind="css: {'btn-warning':progress()=='planned','btn-success':progress()=='started','btn-info':progress()=='finished','btn-danger':progress()=='deferred','btn-inverse':progress()=='cancelled'}"
                                style="line-height:16px;cursor:default;color:white">
                            <span data-bind="text: progress"></span>
                        </button>
                    </div>
                </div>

                <div class="row-fluid space-after">

                    <div class="span6" data-bind="visible:plannedStartDate()">
                        <label class="for-readonly inline">Planned start date</label>
                        <span class="readonly-text" data-bind="text:plannedStartDate.formattedDate"></span>
                    </div>
                    <div class="span6" data-bind="visible:plannedEndDate()">
                        <label class="for-readonly inline">Planned end date</label>
                        <span class="readonly-text" data-bind="text:plannedEndDate.formattedDate"></span>
                    </div>
                </div>

                <div class="row-fluid">
                    <div class="span6 required">
                        <label for="startDate"><b>Actual start date</b>
                        <fc:iconHelp title="Start date" printable="${printView}">Date the activity was started.</fc:iconHelp>
                        </label>
                        <g:if test="${printView}">
                            <div class="row-fluid">
                                <fc:datePicker targetField="startDate.date" name="startDate" data-validation-engine="validate[required]" printable="${printView}"/>
                            </div>
                        </g:if>
                        <g:else>
                            <div class="input-append">
                                <fc:datePicker targetField="startDate.date" name="startDate" data-validation-engine="validate[required]" printable="${printView}"/>
                            </div>
                        </g:else>
                    </div>
                    <div class="span6 required">
                        <label for="endDate"><b>Actual end date</b>
                        <fc:iconHelp title="End date" printable="${printView}">Date the activity finished.</fc:iconHelp>
                        </label>
                        <g:if test="${printView}">
                            <div class="row-fluid">
                            <fc:datePicker targetField="endDate.date" name="endDate" data-validation-engine="validate[future[startDate]]" printable="${printView}" />
                            </div>
                        </g:if>
                        <g:else>
                            <div class="input-append">
                                <fc:datePicker targetField="endDate.date" name="endDate" data-validation-engine="validate[future[startDate]]" printable="${printView}" />
                            </div>
                        </g:else>
                    </div>
                </div>


            </div>

            <div class="span3">
                <div id="smallMap" style="width:100%"></div>
            </div>

        </div>

        <g:if env="development" test="${!printView}">
          <div class="expandable-debug">
              <hr />
              <h3>Debug</h3>
              <div>
                  <h4>KO model</h4>
                  %{--<pre data-bind="text:ko.toJSON($root.modelForSaving(),null,2)"></pre>--}%
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
                  <h4>Themes</h4>
                  <pre>${themes.toString()}</pre>
                  <h4>Map features</h4>
                  <pre>${mapFeatures.toString()}</pre>
              </div>
          </div>
        </g:if>
    </div>

<!-- ko stopBinding: true -->
    <g:each in="${metaModel?.outputs}" var="outputName">
        <g:if test="${outputName != 'Photo Points'}">
            <g:set var="blockId" value="${fc.toSingleWord([name: outputName])}"/>
            <g:set var="model" value="${outputModels[outputName]}"/>
            <g:set var="output" value="${activity.outputs.find {it.name == outputName}}"/>
            <g:if test="${!output}">
                <g:set var="output" value="[name: outputName]"/>
            </g:if>
            <md:modelStyles model="${model}" edit="true"/>
            <div class="output-block" id="ko${blockId}">
                <h3 data-bind="css:{modified:dirtyFlag.isDirty},attr:{title:'Has been modified'}">${outputName}</h3>
                <!-- add the dynamic components -->
                <md:modelView model="${model}" site="${site}" edit="true" printable="${printView}" surveyName="${metaModel?.name}" output="${output.name}"/>
        <r:script>


            $(function(){

                var viewModelName = "${blockId}ViewModel",
                    viewModelInstance = viewModelName + "Instance";

                // load dynamic models - usually objects in a list
                <md:jsModelObjects model="${model}" site="${site}" speciesLists="${speciesLists}" edit="true" viewModelInstance="${blockId}ViewModelInstance" surveyName="${metaModel?.name}" output="${output.name}"/>

                this[viewModelName] = function () {
                    var self = this;
                    self.name = "${output.name}";
                    self.outputId = "${output.outputId}";
                    self.data = {};
                    self.transients = {};
                    self.transients.dummy = ko.observable();

                    // add declarations for dynamic data
                    <md:jsViewModel model="${model}" edit="true" viewModelInstance="${blockId}ViewModelInstance" surveyName="${metaModel?.name}" output="${output.name}"/>

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
                        <md:jsLoadModel model="${model}"/>

                        // if there is no data in tables then add an empty row for the user to add data
                        if (typeof self.addRow === 'function' && self.rowCount() === 0) {
                            self.addRow();
                        }
                        self.transients.dummy.notifySubscribers();
                    };
                };

                window[viewModelInstance] = new this[viewModelName](site);

                var output = ${output.data ?: '{}'};

                if (Object.keys(output).length) {
                    window[viewModelInstance].loadData(output);
                }

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

    <g:if test="${metaModel.supportsPhotoPoints?.toBoolean()}">
        <div class="output-block" data-bind="with:transients.photoPointModel">
            <h3>Photo Points</h3>

             <g:render template="/site/photoPoints"></g:render>
        </div>
    </g:if>

    <g:if test="${!printView}">
        <div class="form-actions">
            <button type="button" id="save" class="btn btn-primary">Save changes</button>
            <button type="button" id="cancel" class="btn">Cancel</button>
            <label class="checkbox inline">
                <input data-bind="checked:transients.markedAsFinished" type="checkbox"> Mark this activity as finished.
            </label>
        </div>
    </g:if>

</div>

<div id="timeoutMessage" class="hide">

    <span class='label label-important'>Important</span><h4>There was an error while trying to save your changes.</h4>
    <p>This could be because your login has timed out or the internet is unavailable.</p>
    <p>Your data has been saved on this computer but you may need to login again before the data can be sent to the server.</p>
    <a href="${createLink(action:'enterData', id:activity.activityId)}?returnTo=${returnTo}">Click here to refresh your login and reload this page.</a>
</div>


<g:render template="/shared/imagerViewerModal" model="[readOnly:false]"></g:render>

<r:script>

    var returnTo = "${returnTo}";

    function ActivityLevelData() {
        var self = this;
        self.activity = JSON.parse('${(activity as JSON).toString().encodeAsJavaScript()}');
        self.site = JSON.parse('${(site as JSON).toString().encodeAsJavaScript()}');
        self.pActivity = {sites: []};
    }

    var activityLevelData = new ActivityLevelData();


    /* Master controller for page. This handles saving each model as required. */
    var Master = function () {
        var self = this;
        this.subscribers = [];

        // client models register their name and methods to participate in saving
        self.register = function (modelInstanceName, getMethod, isDirtyMethod, resetMethod) {
            this.subscribers.push({
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
                if (obj.isDirty()) {
                    if (obj.model === 'activityModel') {
                        activityData = obj.get();
                    } else if (obj.model === 'photoPoints') {
                        photoPoints = obj.get();
                    }
                    else {
                        outputs.push(obj.get());
                    }
                }
            });
            if (outputs.length === 0 && activityData === undefined && photoPoints === undefined) {
                return null;
            } else {
                if (activityData === undefined) { activityData = {}}
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
                    url: "${createLink(action: 'ajaxUpdate', id: activity.activityId)}",
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
                            blockUIWithMessage("Activity data saved.")
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
            console.log("Reset called -> dirty = " + obj.isDirty())
                if (obj.isDirty()) {
                    obj.reset();
                }
            });
        };
    };

    var master = new Master();

    $(function(){

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

        function ViewModel (act, site, project, metaModel) {
            var self = this;
            self.activityId = act.activityId;
            self.description = ko.observable(act.description);
            self.notes = ko.observable(act.notes);
            self.startDate = ko.observable(act.startDate).extend({simpleDate: false});
            self.endDate = ko.observable(act.endDate || act.plannedEndDate).extend({simpleDate: false});
            self.plannedStartDate = ko.observable(act.plannedStartDate).extend({simpleDate: false});
            self.plannedEndDate = ko.observable(act.plannedEndDate).extend({simpleDate: false});
            self.eventPurpose = ko.observable(act.eventPurpose);
            self.fieldNotes = ko.observable(act.fieldNotes);
            self.associatedProgram = ko.observable(act.associatedProgram);
            self.associatedSubProgram = ko.observable(act.associatedSubProgram);
            self.projectStage = ko.observable(act.projectStage || "");
            self.progress = ko.observable(act.progress);
            self.mainTheme = ko.observable(act.mainTheme);
            self.type = ko.observable(act.type);
            self.projectId = act.projectId;
            self.transients = {};
            self.transients.site = ko.observable(site);
            self.transients.project = project;
            self.transients.outputs = [];
            self.transients.metaModel = metaModel || {};
            self.transients.activityProgressValues = ['planned','started','finished'];
            self.transients.themes = $.map(${themes}, function (obj, i) { return obj.name });
            self.transients.markedAsFinished = ko.observable(act.progress === 'finished');
            self.transients.markedAsFinished.subscribe(function (finished) {
                self.progress(finished ? 'finished' : 'started');
            });

            self.confirmSiteChange = function() {

                if (self.transients.photoPointModel().isDirty()) {
                    return window.confirm(
                        "This activity has photos attached to photo points.\n  Changing the site will delete these photos.\n  This cannot be undone.  Are you sure?"
                    );
                }
                return true;
            };

            self.siteMap = null;
            self.siteId = ko.vetoableObservable(act.siteId, self.confirmSiteChange);

            self.siteId.subscribe(function(siteId) {
                if (!self.siteMap) {
                    return;
                }
                var matchingSite = $.grep(self.transients.project.sites, function(site) { return siteId == site.siteId})[0];

                self.siteMap.clearFeatures();
                if (matchingSite) {
                    self.siteMap.replaceAllFeatures([matchingSite.extent.geometry]);
                }
                self.transients.site(matchingSite);
                self.updatePhotoPointModel(matchingSite);

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

            self.transients.photoPointModel = ko.observable(new PhotoPointViewModel(site, activity));
            self.updatePhotoPointModel = function(site) {
                self.transients.photoPointModel(new PhotoPointViewModel(site, activity));
            };

            self.modelForSaving = function () {
                // get model as a plain javascript object
                var jsData = ko.mapping.toJS(self, {'ignore':['transients']});
                jsData.photoPoints = self.transients.photoPointModel().modelForSaving();

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
                        document.location.href = "${createLink(action:'delete',id:activity.activityId,
                            params:[returnTo:grailsApplication.config.grails.serverURL + '/' + returnTo])}";
                    }
                });
            };
            self.notImplemented = function () {
                alert("Not implemented yet.")
            };
            self.dirtyFlag = ko.dirtyFlag(self, false);

            // make sure progress moves to started if we save any data (unless already finished)
            // (do this here so the model becomes dirty)
            self.progress(self.transients.markedAsFinished() ? 'finished' : 'started');
        };

        var activity = JSON.parse('${(activity as JSON).toString().encodeAsJavaScript()}');
        var site = JSON.parse('${(site as JSON).toString().encodeAsJavaScript()}');

        var viewModel = new ViewModel(
            activity,
            site,
            ${project ? "JSON.parse('${project.toString().encodeAsJavaScript()}')": 'null'},
            ${metaModel ?: 'null'});


        var mapFeatures = $.parseJSON('${mapFeatures?.encodeAsJavaScript()}');
        if (!mapFeatures) {
            mapFeatures = {zoomToBounds: true, zoomLimit: 15, highlightOnHover: true, features: []};
        }

        var mapOptions = {
            mapContainer: "smallMap",
            zoomToBounds:true,
            zoomLimit:16,
            featureService: "${createLink(controller: 'proxy', action:'feature')}",
            wmsServer: "${grailsApplication.config.spatial.geoserverUrl}"
        }

        ko.applyBindings(viewModel);

        master.register('activityModel', viewModel.modelForSaving, viewModel.dirtyFlag.isDirty, viewModel.dirtyFlag.reset);

    });



    var PhotoPointViewModel = function(site, activity) {

        var self = this;

        self.site = site;
        self.photoPoints = ko.observableArray();

        if (site && site.poi) {

            $.each(site.poi, function(index, obj) {
                var photos = ko.utils.arrayFilter(activity.documents, function(doc) {
                    return doc.siteId === site.siteId && doc.poiId === obj.poiId;
                });
                self.photoPoints.push(photoPointPhotos(site, obj, activity.activityId, photos));
            });
        }

        self.removePhotoPoint = function(photoPoint) {
            self.photoPoints.remove(photoPoint);
        }

        self.addPhotoPoint = function() {
            self.photoPoints.push(photoPointPhotos(site, null, activity.activityId, []));
        };

        self.modelForSaving = function() {
            var siteId = site?site.siteId:''
            var toSave = {siteId:siteId, photos:[], photoPoints:[]};

            $.each(self.photoPoints(), function(i, photoPoint) {

                if (photoPoint.isNew()) {
                    var newPhotoPoint = photoPoint.photoPoint.modelForSaving();
                    toSave.photoPoints.push(newPhotoPoint);
                    $.each(photoPoint.photos(), function(i, photo) {
                        if (!newPhotoPoint.photos) {
                            newPhotoPoint.photos = [];
                        }
                        newPhotoPoint.photos.push(photo.modelForSaving());
                    });
                }
                else {
                    $.each(photoPoint.photos(), function(i, photo) {
                        toSave.photos.push(photo.modelForSaving());
                    });
                }

            });
            return toSave;
        };

        self.isDirty = function() {
            var isDirty = false;
            $.each(self.photoPoints(), function(i, photoPoint) {
                isDirty = isDirty || photoPoint.isDirty();
            });
            return isDirty;
        };

        self.reset = function() {};


    };

    var photoPointPOI = function(data) {
        if (!data) {
            data = {
                geometry:{}
            };
        }
        var name = ko.observable(data.name);
        var description = ko.observable(data.description);
        var lat = ko.observable(data.geometry.decimalLatitude);
        var lng = ko.observable(data.geometry.decimalLongitude);
        var bearing = ko.observable(data.geometry.bearing);


        return {
            poiId:data.poiId,
            name:name,
            description:description,
            geometry:{
                type:'Point',
                decimalLatitude:lat,
                decimalLongitude:lng,
                bearing:bearing,
                coordinates:[lng, lat]
            },
            type:'photopoint',
            modelForSaving:function() { return ko.toJS(this); }
        }
    };

    var photoPointPhotos = function(site, photoPoint, activityId, existingPhotos) {

        var files = ko.observableArray();
        var photos = ko.observableArray();
        var isNewPhotopoint = !photoPoint;
        var isDirty = isNewPhotopoint;

        var photoPoint = photoPointPOI(photoPoint);

        $.each(existingPhotos, function(i, photo) {
            photos.push(photoPointPhoto(photo));
        });


        files.subscribe(function(newValue) {
            var f = newValue.splice(0, newValue.length);
            for (var i=0; i < f.length; i++) {

                var data = {
                    thumbnailUrl:f[i].thumbnail_url,
                    url:f[i].url,
                    contentType:f[i].contentType,
                    filename:f[i].name,
                    filesize:f[i].size,
                    dateTaken:f[i].isoDate,
                    lat:f[i].decimalLatitude,
                    lng:f[i].decimalLongitude,
                    poiId:photoPoint.poiId,
                    siteId:site.siteId,
                    activityId:activityId,
                    name:site.name+' - '+photoPoint.name(),
                    type:'image'


                };
                isDirty = true;
                if (isNewPhotopoint && data.lat && data.lng && !photoPoint.geometry.decimalLatitude() && !photoPoint.geometry.decimalLongitude()) {
                    photoPoint.geometry.decimalLatitude(data.lat);
                    photoPoint.geometry.decimalLongitude(data.lng);
                }

                photos.push(photoPointPhoto(data));
            }
        });


        return {
            photoPoint:photoPoint,
            photos:photos,
            files:files,

            uploadConfig : {
                url: '${createLink(controller: 'image', action: 'upload')}',
                target: files
            },
            removePhoto : function (photo) {
                if (photo.documentId) {
                    photo.status('deleted');
                }
                else {
                    photos.remove(photo);
                }
            },
            template : function(photoPoint) {
                return isNewPhotopoint ? 'editablePhotoPoint' : 'readOnlyPhotoPoint'
            },
            isNew : function() { return isNewPhotopoint },
            isDirty: function() {
                if (isDirty) {
                    return true;
                };
                var tmpPhotos = photos();
                for (var i=0; i < tmpPhotos.length; i++) {
                    if (tmpPhotos[i].dirtyFlag.isDirty()) {
                        return true;
                    }
                }
                return false;
            }

        }
    }

    var photoPointPhoto = function(data) {
        if (!data) {
            data = {};
        }
        data.role = 'photoPoint';
        var result = new DocumentViewModel(data);
        result.dateTaken = ko.observable(data.dateTaken).extend({simpleDate:false});
        result.formattedSize = formatBytes(data.filesize);

        for (var prop in data) {
            if (!result.hasOwnProperty(prop)) {
                result[prop]= data[prop];
            }
        }
        var docModelForSaving = result.modelForSaving;
        result.modelForSaving = function() {
            var js = docModelForSaving();
            delete js.lat;
            delete js.lng;
            delete js.thumbnailUrl;
            delete js.formattedSize;

            return js;
        };
        result.dirtyFlag = ko.dirtyFlag(result, false);

        return result;
    };
</r:script>
</body>
</html>