<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="bs4"/>
    <title>Edit | ${activity.type} | <g:message code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/'+ hubConfig.urlPath)},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'project', action: 'index')}/${project.projectId},Project"/>
    <meta name="breadcrumb" content="${activity.type}"/>
    <asset:stylesheet src="forms-manifest.css"/>
    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="forms-manifest.js"/>
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <asset:script type="text/javascript">
    var fcConfig = {
        <g:applyCodec encodeAs="none">
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
        activityDeleteUrl: "${createLink(controller: 'activity', action: 'ajaxDelete')}",
        projectViewUrl: "${createLink(controller: 'project', action: 'index')}/",
        excelOutputTemplateUrl: "${createLink(controller: 'proxy', action:'excelOutputTemplate')}",
        mapLayersConfig: <fc:modelAsJavascript model="${mapService.getMapLayersConfig(project, null)}"/>,
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}/"
        </g:applyCodec>
        },
        here = document.location.href;
    </asset:script>
    <g:set var="formattedStartDate" value="${au.org.ala.biocollect.DateUtils.isoToDisplayFormat(project.plannedStartDate)}"/>
    <g:set var="formattedEndDate" value="${au.org.ala.biocollect.DateUtils.isoToDisplayFormat(project.plannedEndDate)}"/>
</head>
<body>
<div class="container-fluid validationEngineContainer" id="validation-container">
    <div id="koActivityMainBlock">
        <div class="row title-block card input-block-level mt-3">
            <div class="col-sm-12 title-attribute">
                <h1><span data-bind="click:goToProject" class="clickable">${project?.name?.encodeAsHTML() ?: 'no project defined!!'}</span></h1>
                <h3 data-bind="css:{modified:dirtyFlag.isDirty},attr:{title:'Has been modified'}">Activity: <span data-bind="text:type"></span><i class="fas fa-asterisk modified-icon" data-bind="visible:dirtyFlag.isDirty" title="Has been modified"></i></h3>
                <h4><span>${project.associatedProgram?.encodeAsHTML()}</span> <span>${project.associatedSubProgram?.encodeAsHTML()}</span></h4>
            </div>
        </div>

        <div class="row">
            <div class="col-sm-12 ml-3">
                <!-- Common activity fields -->
                <div class="row" data-bind="visible:transients.typeWarning()" style="display:none">
                    <div class="col-sm-12 alert alert-danger">
                        <strong>Warning!</strong> This activity has data recorded.  Changing the type of the activity will cause this data to be lost!
                    </div>
                </div>

                <div class="row mt-3 mb-3">
                    <div class="col-sm-12">
                        <div class="row">
                            <div class="col-sm-6">
                                <label for="type">Type of activity</label>
                                <select data-bind="value: type, popover:{title:'', content:transients.activityDescription, trigger:'manual', autoShow:true}" id="type" data-validation-engine="validate[required]" class="input-xlarge">
                                    <g:each in="${activityTypes}" var="t" status="i">
                                        <g:if test="${i == 0 && create}">
                                            <option></option>
                                        </g:if>
                                        <optgroup label="${t.name}">
                                            <g:each in="${t.list}" var="opt">
                                                <option>${opt.name}</option>
                                            </g:each>
                                        </optgroup>
                                    </g:each>
                                </select>
                            </div>
                            <div class="col-sm-6" data-bind="visible:transients.themes && transients.themes.length > 1">
                                <label for="theme">Major theme</label>
                                <select id="theme" data-bind="value:mainTheme, options:transients.themes, optionsCaption:'Choose..'" class="input-xlarge">
                                </select>
                            </div>
                            <div class="col-sm-6" data-bind="visible:transients.themes && transients.themes.length == 1">
                                <label for="theme">Major theme</label>
                                <span data-bind="text:mainTheme">
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-sm-12">
                        <div class="row">
                            <div class="col-sm-10 required">
                                <fc:textField data-bind="value: description" id="description" label="Description" class="col-sm-12"  data-validation-engine="validate[required]" />
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row" data-bind="template:transients.isMilestone() ? 'milestoneTmpl' : 'activityTmpl'">

                </div>
            </div>
        </div>
    </div>

    <g:if test="${!printView}">
        <div class="col-sm-12 form-actions mt-3">
            <button type="button" id="save" class="btn btn-primary-dark"><i class="fas fa-hdd"></i> Save changes</button>
            <button type="button" id="cancel" class="btn btn-dark"><i class="far fa-times-circle"></i> Cancel</button>
        </div>
    </g:if>

</div>

<!-- templates -->
<script type="text/html" id="activityTmpl">
    <div class="col-sm-6 required">
        <div class="form-group">
            <label for="plannedStartDate">Planned start date
            <fc:iconHelp title="Planned start date" printable="${printView}">Date the activity is intended to start.</fc:iconHelp>
            </label>
            <div class="input-group-append">
                <fc:datePicker targetField="plannedStartDate.date" name="plannedStartDate" data-validation-engine="validate[required,future[${formattedStartDate}]]" printable="${printView}"/>
            </div>
        </div>
    </div>
    <div class="col-sm-6 required">
        <div class="form-group">
            <label for="plannedEndDate">Planned end date
            <fc:iconHelp title="Planned end date" printable="${printView}">Date the activity is intended to finish.</fc:iconHelp>
            </label>
            <div class="input-group-append">
                <fc:datePicker targetField="plannedEndDate.date" name="plannedEndDate" data-validation-engine="validate[future[plannedStartDate],past[${formattedEndDate}],required]" printable="${printView}" />
            </div>
        </div>
    </div>
</script>
<script type="text/html" id="milestoneTmpl">
<div class="col-sm-6 required">
    <label for="plannedStartDate">Milestone date
    <fc:iconHelp title="Planned start date" printable="${printView}">Date the activity is intended to start.</fc:iconHelp>
    </label>
    <div class="input-group-append">
        <fc:datePicker targetField="plannedStartDate.date" name="plannedStartDate" data-validation-engine="validate[required,future[${formattedStartDate}]]" printable="${printView}"/>
    </div>
</div>
</script>

<asset:script type="text/javascript">

    var returnTo = "${returnTo}";

    /* Master controller for page. This handles saving each model as required. */
    var Master = function () {
        var self = this;
        this.subscribers = [];
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
            var activityData, outputs = [];
            if ($('#validation-container').validationEngine('validate')) {
                $.each(this.subscribers, function(i, obj) {
                    if (obj.isDirty()) {
                        if (obj.model === 'activityModel') {
                            activityData = obj.get();
                        } else {
                            outputs.push(obj.get());
                        }
                    }
                });
                if (outputs.length === 0 && activityData === undefined) {
                    alert("Nothing to save.");
                    return;
                }
                if (activityData === undefined) { activityData = {}}
                activityData.outputs = outputs;
                $.ajax({
                    url: "${createLink(action: 'ajaxUpdate', id: activity.activityId)}",
                    type: 'POST',
                    data: JSON.stringify(activityData),
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
                            self.reset();
                            self.saved();
                        }
                    },
                    error: function (data) {
                        var status = data.status;
                        alert('An unhandled error occurred: ' + data.status);
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

    $(function(){

        $('#validation-container').validationEngine('attach', {scroll: false, 'custom_error_messages': {
            '#plannedStartDate':{
                'future': {'message':'Activities cannot start before the project start date - ${formattedStartDate}'}
            },
            '#plannedEndDate':{
                'past': {'message':'Activities cannot end after the project end date - ${formattedEndDate}'}
            }
        }});

        $('.helphover').popover({animation: true, trigger:'hover'});

        $('#save').on('click',function () {
            master.save();

        });

        $('#cancel').on('click',function () {
            document.location.href = returnTo;
        });

        $('#reset').on('click',function () {
            master.reset();
        });

        function ViewModel (act, project, activityTypes, themes) {
            var self = this;
            self.activityId = act.activityId;
            self.description = ko.observable(act.description);
            self.notes = ko.observable(act.notes);
            self.startDate = ko.observable(act.startDate || act.plannedStartDate).extend({simpleDate: false});
            self.endDate = ko.observable(act.endDate || act.plannedEndDate).extend({simpleDate: false});
            self.plannedStartDate = ko.observable(act.plannedStartDate).extend({simpleDate: false});
            self.plannedEndDate = ko.observable(act.plannedEndDate).extend({simpleDate: false});
            self.eventPurpose = ko.observable(act.eventPurpose);
            self.associatedProgram = ko.observable(act.associatedProgram);
            self.associatedSubProgram = ko.observable(act.associatedSubProgram);
            self.projectStage = ko.observable(act.projectStage || "");
            self.progress = ko.observable(act.progress || 'started');
            self.mainTheme = ko.observable(act.mainTheme);
            self.type = ko.observable(act.type);
            self.projectId = act.projectId;
            self.transients = {};
            self.transients.project = project;
            self.transients.themes = $.map(themes, function (obj, i) { return obj.name });
            if (!act.mainTheme && self.transients.themes.length == 1) {
                self.mainTheme(self.tranients.themes[0]);
            }
            self.transients.typeWarning = ko.computed(function() {
                if (act.outputs === undefined || act.outputs.length == 0) {
                    return false;
                }
                if (!self.type()) {
                    return false;
                }
                return (self.type() != act.type);
            });

            self.transients.activityDescription = ko.computed(function() {
                var result = "";
                if (self.type()) {
                    $.each(activityTypes, function(i, obj) {
                        $.each(obj.list, function(j, type) {
                            if (type.name === self.type()) {
                                result = type.description;
                                console.log(result);
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
                    $.each(activityTypes, function(i, obj) {
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

            self.transients.isMilestone.subscribe(function(newValue) {
                if (newValue) {
                    self.plannedEndDate(self.plannedStartDate());
                }
            });
            self.plannedStartDate.subscribe(function(newValue) {
                // Keep start and end dates the same for a milestone.
                if (self.transients.isMilestone()) {
                   self.plannedEndDate(newValue);
                }
            });

            self.goToProject = function () {
                if (self.projectId) {
                    document.location.href = fcConfig.projectViewUrl + self.projectId;
                }
            };

            self.modelForSaving = function () {
                // get model as a plain javascript object
                var jsData = ko.toJS(self);
                delete jsData.transients;
                // If we leave the theme undefined, it will be ignored during JSON serialisation and hence
                // will not overwrite the current value on the server.
                var possiblyUndefinedProperties = ['mainTheme'];

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
            self.dirtyFlag = ko.dirtyFlag(self, false);
        };

            var viewModel = new ViewModel(
                <fc:modelAsJavascript model="${activity}" />,
                <fc:modelAsJavascript model="${project ?: 'null'}" />,
                <fc:modelAsJavascript model="${activityTypes}" />,
                <fc:modelAsJavascript model="${themes}" />);

        ko.applyBindings(viewModel,document.getElementById('koActivityMainBlock'));

        master.register('activityModel', viewModel.modelForSaving, viewModel.dirtyFlag.isDirty, viewModel.dirtyFlag.reset);

    });
</asset:script>
</body>
</html>
