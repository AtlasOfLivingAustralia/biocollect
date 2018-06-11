<%@ page import="grails.converters.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<g:set var="showCreate" value="${activity.activityId ||  (!activity.activityId && !hubConfig.content?.hideCancelButtonOnForm)}"></g:set>
<div class="container-fluid validationEngineContainer" id="validation-container">
    <div id="koActivityMainBlock">
        <g:if test="${!mobile}">
            <div class="row-fluid">
                %{--page title--}%
                <div class="span4">
                    <h2>${title}</h2>
                </div>
                %{-- quick links --}%
                <div class="span8">
                    <g:render template="/shared/quickLinks" model="${[cssClasses: 'pull-right']}"></g:render>
                </div>
                %{--quick links END--}%
            </div>
        </g:if>
<!-- ko stopBinding: true -->
<g:set var="user" value="${user}"/>
<g:each in="${metaModel?.outputs}" var="outputName">
    <g:if test="${outputName != 'Photo Points'}">
        <script type="text/javascript" src="${createLink(controller: 'dataModel', action: 'getScript', params: [outputName: outputName])}"></script>
        <g:set var="blockId" value="${fc.toSingleWord([name: outputName])}"/>
        <g:set var="model" value="${outputModels[outputName]}"/>
        <g:set var="output" value="${activity.outputs.find { it.name == outputName }}"/>

        <g:if test="${!output}">
            <g:set var="output" value="[name: outputName]"/>
        </g:if>

        <md:modelStyles model="${model}" edit="true"/>

        <div class="output-block" id="ko${blockId}">

            <div data-bind="if:transients.optional || outputNotCompleted()">
                <label class="checkbox" ><input type="checkbox" data-bind="checked:outputNotCompleted"> <span data-bind="text:transients.questionText"></span> </label>
            </div>

            <div id="${blockId}-content" class="well" data-bind="visible:!outputNotCompleted()">
                <!-- add the dynamic components -->
                <md:modelView model="${model}" site="${site}" edit="true" output="${output.name}" printable="${printView}"/>
            </div>
        </div>
    </g:if>
</g:each>
<!-- /ko -->


<g:if test="${metaModel.supportsSites?.toBoolean()}">
    <div >
        <h3 class="text-center text-error well-title">Site Details</h3>
        <div class="output-block text-center well">
            <fc:select
                    data-bind='options:transients.pActivitySites,optionsText:"name",optionsValue:"siteId",value:siteId,optionsCaption:"Choose a site..."'
                    printable="${printView}"/>
            <m:map id="activitySiteMap" width="90%" height="512px"/>
        </div>

    </div>
</g:if>

<g:if test="${metaModel.supportsPhotoPoints?.toBoolean()}">
    <h3 class="text-center text-error well-title">Photo Points</h3>
    <div class="output-block well" data-bind="with:transients.photoPointModel">
        <g:render template="/site/photoPoints"></g:render>
    </div>
</g:if>

<g:if test="${!printView}">
    <div class="form-actions">
        <g:if test="${!preview}">
            <button type="button" id="save" class="btn btn-primary">Submit</button>
        </g:if>
        <g:if test="${showCreate && !mobile}">
            <g:if test="${!preview}">
                <button type="button" id="cancel" class="btn">Cancel</button>
            </g:if>
        </g:if>
    </div>
</g:if>

<g:if env="development" test="${!printView && !preview}">
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
    <a href="${createLink(action: 'create', id: activity.activityId)}?returnTo=${returnTo}">Click here to refresh your login and reload this page.</a>
</div>


<g:render template="/shared/imagerViewerModal" model="[readOnly: false]"/>
<g:render template="/shared/attachDocument"/>
<g:render template="/shared/documentTemplate"/>

<asset:script type="text/javascript">
        var returnTo = "${returnTo}";
        var activity = JSON.parse('${(activity as JSON).toString().encodeAsJavaScript()}');

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

                if (ko.isObservable(isDirtyMethod)) {
                    isDirtyMethod.subscribe(function() {
                        self.dirtyCheck();
                    });
                }
            };

            self.dirtyCheck = function() {
                self.dirtyFlag.isDirty(self.isDirty());
            };

            /**
             *  Takes into account changes to the photo point photo's as the default knockout dependency
             *  detection misses edits to some of the fields.
             */
            self.dirtyFlag = {
                isDirty: ko.observable(false),
                reset: function() {
                    $.each(self.subscribers, function(i, obj) {
                        obj.reset();
                    });
                }
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
                    else { // Update outputs unconditionally, backend needs the activityModel and outputs to
                           // create derived data even if outputs didn't change
                        outputs.push(obj.get());
                    }
                });
                if (outputs.length === 0 && activityData === undefined && photoPoints === undefined) {
                    return {validation:false, message:"Nothing need to be updated!"};
                }
                if (typeof activityLevelData.checkMapInfo === "function"){
                    var mapInfoCheck= activityLevelData.checkMapInfo();

                    if( !mapInfoCheck.validation){
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
                }else{
                    //quick fix for some suverys which don't have map
                     if (activityData === undefined) {
                            activityData = {}
                        }
                        activityData.outputs = outputs;
                        return activityData;
                }
            };

            this.removeTemporarySite = function() {
                var sites = this.subscribers[0].model.data.locationSitesArray();
                var linkedSite = this.subscribers[0].model.data.location();

                var waitingForDelete =  _.find(sites, function(site){
                    return site.siteId != linkedSite && site.visibility == 'private'
                })

               var siteUrl = fcConfig.siteDeleteUrl;
               if (waitingForDelete){
                   console.log('Found a temporary site '+ waitingForDelete.siteId);
                   $.ajax({
                        method: 'POST',
                        url: siteUrl+"?id="+waitingForDelete.siteId,
                        data: JSON.stringify({id:waitingForDelete}),
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
            this.save = function () {
                if ($('#validation-container').validationEngine('validate')) {
                    var toSave = this.collectData();

                    if (toSave.hasOwnProperty('validation')){
                        if (!toSave.validation){
                            alert(toSave.message);
                            return;
                        }

                    }

                    toSave = JSON.stringify(toSave);

                    // Don't allow another save to be initiated.
                    blockUIWithMessage("Saving activity data...");

                    amplify.store('activity-${activity.activityId}', toSave);
                    var unblock = true;
                    var url = fcConfig.bioActivityUpdate
                    <g:if test="${mobile}">url = url + "?mobile=true"</g:if>
                    $.ajax({
                        url: url,
                        type: 'POST',
                        data: toSave,

                        <g:if test="${mobile}">
                            xhrFields: {
                               withCredentials: true
                            },
                            beforeSend: function(xhr){
                                xhr.setRequestHeader('userName', "${userName}");
                                xhr.setRequestHeader('authKey', "${authKey}");
                            },
                        </g:if>
                        contentType: 'application/json',
                        success: function (data) {
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
                            } else if(data.error) {
                                   bootbox.alert(data.error);
                            } else {
                                unblock = false; // We will be transitioning off this page.
                                activityId = fcConfig.activityId || data.resp.activityId;
                                returnTo = fcConfig.bioActivityView + activityId;
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
                <g:if test="${mobile}">
                    location.href = "${createLink(controller: 'mobile', action: 'status')}"+"#successfully-posted"
                </g:if>
                <g:else>
                    document.location.href = returnTo;
                </g:else>
            };

            this.reset = function () {
                $.each(this.subscribers, function(i, obj) {
                    if (obj.isDirty()) {
                        obj.reset();
                    }
                });
            };

            autoSaveModel(self, null, {preventNavigationIfDirty:true});
        };

        var master = new Master();

        function ActivityLevelData() {
            var self = this;
            self.activity = JSON.parse('${(activity as JSON).toString().encodeAsJavaScript()}');
            self.site = JSON.parse('${(site as JSON).toString().encodeAsJavaScript()}');
            self.pActivity = JSON.parse('${(pActivity as JSON).toString().encodeAsJavaScript()}');
            self.projectSite = JSON.parse('${(projectSite as JSON).toString().encodeAsJavaScript()}');
            self.mobile = ${mobile ?: false};
        }

        var activityLevelData = new ActivityLevelData();

        $(function() {

            $('#validation-container').validationEngine('attach', {scroll: true});

            $('.helphover').popover({animation: true, trigger:'hover'});

            $('#save').click(function () {
                master.save();
                master.removeTemporarySite();
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

            viewModel = new ViewModel(
                activityLevelData.activity,
                activityLevelData.site,
                ${project ? "JSON.parse('${project.toString().encodeAsJavaScript()}')" : 'null'},
                ${metaModel ?: 'null'},
                activityLevelData.pActivity);

            var activityId = '${activity.activityId}';
            var projectId = '${activity.projectId}';
            var siteId = '${activity.siteId?:""}';
            var outputModelConfig = {
                projectId:projectId,
                activityId:activityId,
                speciesConfig :<fc:modelAsJavascript model="${speciesConfig}"/>
            };

            outputModelConfig = _.extend(fcConfig, outputModelConfig);

        <g:if test="${metaModel.supportsSites?.toBoolean()}">
            var mapFeatures = $.parseJSON('${mapFeatures?.encodeAsJavaScript()}');

            var mapOptions = {
                drawControl: false,
                showReset: true,
                draggableMarkers: false,
                useMyLocation: false,
                allowSearchLocationByAddress: false,
                allowSearchRegionByAddress: false,
                wmsFeatureUrl: "${createLink(controller: 'proxy', action: 'feature')}?featureId=",
                wmsLayerUrl: "${grailsApplication.config.spatial.geoserverUrl}/wms/reflect?"
            }

            activityLevelData.siteMap = new ALA.Map("activitySiteMap", mapOptions);

            if (mapFeatures && mapFeatures.features && mapFeatures.features.length > 0) {
                if (mapFeatures.features[0].pid) {
                    activityLevelData.siteMap.addWmsLayer(mapFeatures.features[0].pid);
                } else {
                    var geometry = _.pick(mapFeatures.features[0], "type", "coordinates");
                    var geoJson = ALA.MapUtils.wrapGeometryInGeoJSONFeatureCol(geometry);
                    activityLevelData.siteMap.setGeoJSON(geoJson);
                }
            } else if (activityLevelData.pActivity.sites.length == 1) {
                viewModel.siteId(activityLevelData.pActivity.sites[0].siteId);
            } else if (activityLevelData.projectSite && activityLevelData.projectSite.extent) {
                activityLevelData.siteMap.fitToBoundsOf(Biocollect.MapUtilities.featureToValidGeoJson(activityLevelData.projectSite.extent.geometry));
            }
        </g:if>

            ko.applyBindings(viewModel);
            viewModel.dirtyFlag.reset();

            master.register('activityModel', viewModel.modelForSaving, viewModel.dirtyFlag.isDirty, viewModel.dirtyFlag.reset);

    <g:each in="${metaModel?.outputs}" var="outputName">
        <g:if test="${outputName != 'Photo Points'}">
            var output = <fc:modelAsJavascript model="${output}"/>;
            var config = ${fc.modelAsJavascript(model:metaModel.outputConfig?.find{it.outputName == outputName}, default:'{}')};
            config.model = ${fc.modelAsJavascript(model:model)},
            config = _.extend({}, outputModelConfig, config);
            var viewModelName = "${blockId}ViewModel",
                elementId = "ko${blockId}";

            initialiseOutputViewModel(viewModelName, config.model.dataModel, elementId, activity, output, master, config);

            setTimeout(function(){
                // Forcing map refresh because of tricky race condition that resets the map
                // to the project area. This refresh needs to happen after everything else has run.
                ecodata.forms["${blockId}ViewModelInstance"].reloadGeodata();
            }, 0);
        </g:if>
    </g:each>

        });
</asset:script>
</div>
