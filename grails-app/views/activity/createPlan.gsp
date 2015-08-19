<%@ page import="au.org.ala.biocollect.merit.DateUtils; grails.converters.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Create | Activity | Field Capture</title>
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <r:script disposition="head">
    var fcConfig = {
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        projectViewUrl: "${createLink(controller: 'project', action: 'index')}/",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}/"
        },
        here = document.location.href;
    </r:script>
    <r:require modules="knockout,jqueryValidationEngine,datepicker"/>
    <g:set var="formattedStartDate" value="${au.org.ala.biocollect.merit.DateUtils.isoToDisplayFormat(project.plannedStartDate)}"/>
    <g:set var="formattedEndDate" value="${au.org.ala.biocollect.merit.DateUtils.isoToDisplayFormat(project.plannedEndDate)}"/>
</head>
<body>
<div class="container-fluid validationEngineContainer" id="validation-container">
    <div id="koActivityMainBlock">
        <ul class="breadcrumb">
            <li><g:link controller="home">Home</g:link> <span class="divider">/</span></li>
            <g:if test="${project}">
                <li><a data-bind="click:goToProject" class="clickable">Project</a> <span class="divider">/</span></li>
            </g:if>
            <g:elseif test="${site}">
                <li><a data-bind="click:goToSite" class="clickable">Site</a> <span class="divider">/</span></li>
            </g:elseif>
            <li class="active">Create new activity</li>
        </ul>

        <div class="row-fluid title-block well input-block-level">
            <div class="space-after"><span>An activity is usually associated with a site and a project. Less commonly, the activity may just be
            linked to a project (usually planning activities).</span></div>
            <div class="span6 title-attribute">
                <span class="pull-right" style="padding:10px 20px 0 0;">${create ? 'OR' : ''}</span>
                <div class="">
                    <h2>Site:</h2>
                    <g:if test="${site}">
                        <h2>${site.name?.encodeAsHTML()}</h2>
                    </g:if>
                    <g:else>
                        <select data-bind="options:transients.sites,optionsText:'name',optionsValue:'siteId',value:siteId,optionsCaption:'Choose a site...'"></select>
                    </g:else>
                </div>
            </div>
            <div class="span5 title-attribute">
                <h2>Project: </h2>
                <g:if test="${project}">
                    <h2>${project.name?.encodeAsHTML()}</h2>
                </g:if>
                <g:else>
                    <select data-bind="options:transients.projects,optionsText:'name',optionsValue:'projectId',value:projectId,optionsCaption:'Choose a project...',disabled:true"></select>
                </g:else>
            </div>
        </div>

        <bs:form action="update" inline="true">

            <div class="row-fluid">
                <div class="span6">
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
                <div class="span6">
                    <label for="theme">Major theme</label>
                    <select id="theme" data-bind="value:mainTheme, options:transients.themes, optionsCaption:'Choose..'" class="input-xlarge">
                    </select>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span12">
                    <fc:textArea data-bind="value: description" id="description" label="Description" class="span12" rows="2" />
                </div>
            </div>

            <div class="row-fluid">
                <div class="span6">
                    <label for="plannedStartDate">Planned start date
                    <fc:iconHelp title="Planned start date" printable="${printView}">Date the activity is intended to start.</fc:iconHelp>
                    </label>
                    <div class="input-append">
                        <fc:datePicker targetField="plannedStartDate.date" name="plannedStartDate" data-validation-engine="validate[required,future[${formattedStartDate}]]" printable="${printView}"/>
                    </div>
                </div>
                <div class="span6">
                    <label for="plannedEndDate">Planned end date
                    <fc:iconHelp title="Planned end date" printable="${printView}">Date the activity is intended to finish.</fc:iconHelp>
                    </label>
                    <div class="input-append">
                        <fc:datePicker targetField="plannedEndDate.date" name="plannedEndDate" data-validation-engine="validate[future[plannedStartDate],past[${formattedEndDate}],required]" printable="${printView}" />
                    </div>
                </div>
            </div>

            <div class="form-actions">
                <button type="button" data-bind="click: save" class="btn btn-primary">Save changes</button>
                <button type="button" id="cancel" class="btn">Cancel</button>
            </div>
        </bs:form>

    </div>
</div>

<!-- templates -->

<r:script>

    var returnTo = "${returnTo}";

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

        $('#cancel').click(function () {
            document.location.href = returnTo;
        });

        function getProjectsForSite(siteId) {
            if (siteId) {
                return $.getJSON("${createLink(controller:'site', action:'projectsForSite')}/" + siteId);
            } else {
                return [];
            }
        }

        function ViewModel (act, sites, projects, site, project, activityTypes) {
            var self = this;

            self.description = ko.observable(act.description);
            self.notes = ko.observable(act.notes);
            self.type = ko.observable(act.type);
            self.startDate = ko.observable(act.startDate).extend({simpleDate: false});
            self.endDate = ko.observable(act.endDate).extend({simpleDate: false});
            self.plannedStartDate = ko.observable(act.plannedStartDate).extend({simpleDate: false});
            self.plannedEndDate = ko.observable(act.plannedEndDate).extend({simpleDate: false});
            self.projectStage = 'Stage 1'; // hardwire until we have a scheme for picking the stage by date
            self.progress = ko.observable('planned');
            self.censusMethod = ko.observable(act.censusMethod);
            self.methodAccuracy = ko.observable(act.methodAccuracy);
            self.collector = ko.observable(act.collector)/*.extend({ required: true })*/;
            self.fieldNotes = ko.observable(act.fieldNotes);
            self.siteId = ko.observable(act.siteId);
            self.projectId = ko.observable(act.projectId);
            self.mainTheme = ko.observable(act.mainTheme);
            self.transients = {};
            self.transients.site = site;
            self.transients.project = project;
            self.transients.sites = project ? project.sites : sites;
            self.transients.projects = site ? site.projects : projects;
            self.transients.themes = $.map(${themes ?: '[]'}, function (obj, i) { return obj.name });
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

            self.transients.activityDescription = ko.computed(function() {
                var result = "";
                if (self.type()) {
                    $.each(activityTypes, function(i, obj) {
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

            self.save = function () {
                if ($('#validation-container').validationEngine('validate')) {
                    var jsData = ko.mapping.toJS(self, {'ignore':['transients']});
                    var json = JSON.stringify(jsData);
                    $.ajax({
                        url: "${createLink(action: 'ajaxUpdate', id: activity.activityId)}",
                        type: 'POST',
                        data: json,
                        contentType: 'application/json',
                        success: function (data) {
                            if (data.error) {
                                alert(data.detail + ' \n' + data.error);
                            } else {
                                // Redirect to the edit page for a new started activity, otherwise go back to
                                // where you came from (the project or site activity list most likely).
                                if (self.progress() != 'planned') {
                                    document.location.href = "${createLink(action: 'edit')}"+'/'+data.activityId+'?returnTo='+returnTo;
                                }
                                else {
                                    document.location.href = returnTo;
                                }
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
                        document.location.href = "${createLink(action:'delete',id:activity.activityId,
        params:[returnTo:grailsApplication.config.grails.serverURL + '/' + returnTo])}";
                    }
                });
            };
            self.notImplemented = function () {
                alert("Not implemented yet.")
            };
        }

        var viewModel = new ViewModel(
    ${(activity as JSON).toString()},
    ${((sites ?: []) as JSON).toString()},
    ${((projects ?: []) as JSON).toString()},
    ${site ?: 'null'},
    ${project ?: 'null'},
    ${(activityTypes as JSON).toString()});
        ko.applyBindings(viewModel,document.getElementById('koActivityMainBlock'));


    });

</r:script>
</body>
</html>