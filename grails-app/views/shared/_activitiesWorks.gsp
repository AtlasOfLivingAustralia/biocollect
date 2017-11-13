<%@ page import="grails.converters.JSON; au.org.ala.biocollect.DateUtils;" %>
<r:require modules="datepicker, jqueryGantt, jqueryValidationEngine, attachDocuments"/>
<r:script>
    var PROJECT_STATE = {approved: 'approved', submitted: 'submitted', planned: 'not approved'};
    var ACTIVITY_STATE = {
        planned: 'planned', started: 'started', finished: 'finished', deferred: 'deferred',
        cancelled: 'cancelled'
    };
</r:script>
<g:set var="formattedStartDate" value="${DateUtils.isoToDisplayFormat(project.plannedStartDate)}"/>
<g:set var="formattedEndDate" value="${DateUtils.isoToDisplayFormat(project.plannedEndDate)}"/>
<!-- This section is bound to a secondary KO viewModel. The following line prevents binding
         to the main viewModel. -->
<!-- ko stopBinding: true -->
<div class="row-fluid" id="planContainer">
    <g:if test="${(project.planStatus == 'not approved') && params.userIsProjectEditor}">
        <div class="alert alert-info">
            <g:message code="project.works.workschedule.notapproved.message"></g:message>
        </div>
    </g:if>
    <g:else>
        <div id="status-update-error-placeholder"></div>

        <div id="activityContainer" class="space-before">
            <h4 class="inline">Planned Activities</h4>

            <ul class="nav nav-tabs nav-tab-small space-before">
                <li class="active"><a href="#tablePlan" data-toggle="tab">Tabular</a></li>
                <li><a href="#ganttPlan" data-toggle="tab">Gantt chart</a></li>
            </ul>

            <div class="tab-content" style="padding:0;border:none;overflow:visible">
                <div class="tab-pane active" id="tablePlan">
                    <table class="table table-condensed" id="activities">
                        <thead>
                        <tr>
                            <th style="width:128px;">Actions</th>
                            <th style="min-width:64px">From</th>
                            <th style="min-width:64px">To</th>
                            <th style="width:25%;" id="description-column">Description</th>
                            <th>Activity</th>
                            <th>Site</th>
                            <th>Status</th>
                        </tr>
                        </thead>
                        <tbody data-bind="foreach:activities.activities" id="activityList">
                        <tr data-bind="template:typeCategory == 'Milestone' ? 'milestoneRow':'activityRow', css:typeCategory, slideVisible: !transients.editActivity()">

                        </tr>
                        <tr data-bind="slideVisible: transients.editActivity">
                            <td colspan="7">
                                <div class="padding-10 border-1">
                                    <!-- ko template: 'basicActivityTmpl' -->
                                    <!-- /ko -->
                                </div>
                            </td>
                        </tr>
                        <!-- ko if: transients.speciesSettings() -->
                        <tr data-bind="slideVisible: transients.speciesConfigurationToggle">
                            <td colspan="7">
                                <div class="padding-10 border-1">
                                    <!-- ko template: 'speciesConfigurationTmpl' -->
                                    <!-- /ko -->
                                </div>
                            </td>
                        </tr>
                        <!-- /ko -->
                        </tbody>
                    </table>
                    <!-- ko with: newActivityViewModel-->
                    <!-- ko if: canEditActivity -->
                    <div class="border-1 padding-10">
                        <!-- ko template: 'basicActivityTmpl' -->
                        <!-- /ko -->
                    </div>
                    <!-- /ko -->
                    <!-- /ko -->
                </div>

                <div class="tab-pane" id="ganttPlan" style="overflow:hidden;">
                    <div id="gantt-container"></div>
                </div>
            </div>
        </div>

        <form id="outputTargetsContainer">
            <h4>Output Targets</h4>
            <table id="outputTargets" class="table table-condensed tight-inputs">
                <thead><tr><th>Output Type</th><th>Outcome Targets</th><th>Output Targets</th><th>Target</th></tr>
                </thead>
                <!-- ko foreach:outputTargets -->
                <tbody data-bind="foreach:scores">
                <tr>
                    <!-- ko with:isFirst -->
                    <td data-bind="attr:{rowspan:$parents[1].scores.length}">
                        <b><span data-bind="text:$parents[1].name"></span></b>
                    </td>
                    <td data-bind="attr:{rowspan:$parents[1].scores.length}">
                        <textarea data-bind="visible:$root.canEditOutputTargets(),value:$parents[1].outcomeTarget"
                                  rows="3"
                                  cols="80" style="width:90%"></textarea>
                        <span data-bind="visible:!$root.canEditOutputTargets(),text:$parents[1].outcomeTarget"></span>
                        <span class="save-indicator" data-bind="visible:$parents[1].transients.isSaving"><r:img dir="images"
                                                                                                     file="ajax-saver.gif"
                                                                                                     alt="saving icon"/> saving</span>
                    </td>
                    <!-- /ko -->
                    <td><span data-bind="text:scoreLabel"></span></td>
                    <td>
                        <input type="text" class="input-mini"
                               data-bind="visible:$root.canEditOutputTargets(),value:target"
                               data-validation-engine="validate[required,custom[number]]"/>
                        <span data-bind="visible:!$root.canEditOutputTargets(),text:target"></span>
                        <span data-bind="text:units"></span>
                        <span class="save-indicator" data-bind="visible:transients.isSaving"><r:img dir="images"
                                                                                         file="ajax-saver.gif"
                                                                                         alt="saving icon"/> saving</span>
                    </td>

                </tr>
                </tbody>
                <!-- /ko -->
            </table>

        </form>
    </g:else>

    <g:if env="development">
        <hr/>

        <div class="expandable-debug">
            <h3>Plan Debug</h3>

            <div>
                <h4>Target metadata</h4>
                <pre data-bind="text:ko.toJSON(targetMetadata,null,2)"></pre>
            </div>
        </div>
    </g:if>

</div>
<!-- /ko -->

<!-- ko stopBinding: true -->
<div id="attachReasonDocument" class="modal fade" style="display:none;">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="title">Activity Deferral</h4>
            </div>

            <div class="modal-body">
                <p>Please enter the reason the activity is being deferred.  You can also attach supporting documentation.</p>

                <form class="form-horizontal" id="documentForm">

                    <div class="control-group">
                        <label class="control-label" for="deferralReason">Reason</label>

                        <div class="controls">
                            <textarea id="deferralReason" rows="4" cols="80"
                                      data-bind="value:name, valueUpdate:'keyup'"></textarea>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="documentFile">Supporting documentation</label>

                        <div class="controls">
                            <span class="btn fileinput-button" data-bind="visible:!filename()">
                                <i class="icon-plus"></i>
                                <input id="documentFile" type="file" name="files"/>
                                Attach file
                            </span>
                            <span data-bind="visible:filename()">
                                <input type="text" readonly="readonly" data-bind="value:fileLabel"/>
                                <button class="btn" data-bind="click:removeFile">
                                    <span class="icon-remove"></span>
                                </button>
                            </span>
                        </div>
                    </div>

                    <div class="control-group" data-bind="visible:hasPreview">
                        <label class="control-label">Preview</label>

                        <div id="preview" class="controls"></div>
                    </div>

                    <div class="control-group" data-bind="visible:progress() > 0">
                        <label for="progress" class="control-label">Progress</label>

                        <div id="progress" class="controls progress progress-info active input-large"
                             data-bind="visible:!error() && progress() < 100, css:{'progress-info':progress()<100, 'progress-success':complete()}">
                            <div class="bar" data-bind="style:{width:progress()+'%'}"></div>
                        </div>

                        <div id="successmessage" class="controls" data-bind="visible:complete()">
                            <span class="alert alert-success">File successfully uploaded</span>
                        </div>

                        <div id="message" class="controls" data-bind="visible:error()">
                            <span class="alert alert-error" data-bind="text:error"></span>
                        </div>
                    </div>

                    <g:if test="${grailsApplication.config.debugUI}">
                        <div class="expandable-debug">
                            <h3>Debug</h3>

                            <div>
                                <h4>Document model</h4>
                                <pre class="row-fluid" data-bind="text:toJSONString()"></pre>
                            </div>
                        </div>
                    </g:if>

                </form>
            </div>

            <div class="modal-footer control-group">
                <div class="controls">
                    <button type="button" class="btn btn-success"
                            data-bind="enable:name() && !error(), click:save, visible:!complete()">Save</button>
                    <button class="btn" data-bind="click:cancel, visible:!complete()">Cancel</button>
                    <button class="btn" data-bind="click:close, visible:complete()">Close</button>

                </div>
            </div>

        </div>
    </div>
</div>
<!-- /ko -->

<!-- templates -->
<script id="basicActivityTmpl" type="text/html">
<div data-bind="validateOnClick:  { callback: save, selector: '.save-activity'}, css: {'ajax-opacity': transients.isSaving}" class="validationEngineContainer">
    <h4><!-- ko text: activityId ? 'Update activity': 'Add a new activity' --> <!-- /ko --></h4>
    <div id="add-new-activity">
        <div class="row-fluid">
            <div class="span4 required">
                <label>Type of activity</label>
                <select data-bind="value: type,
                        popover:{title:'', content: transients.activityDescription,
                        trigger:'manual', autoShow:true}"  class="full-width form-control"
                        data-validation-engine="validate[required]">
                    <option></option>
                    <g:each in="${activityTypes}" var="t" status="i">
                        <optgroup label="${t.name}">
                            <g:each in="${t.list}" var="opt">
                                <option>${opt.name}</option>
                            </g:each>
                        </optgroup>
                    </g:each>
                </select>
            </div>

            <div class="span2"
                 data-bind="visible:fcConfig.themes && fcConfig.themes.length > 1">
                <label>Major theme</label>
                <select class="full-width form-control"
                        data-bind="value:mainTheme, options:fcConfig.themes,
                                                    optionsText: 'name', optionsValue: 'name',
                                                    optionsCaption:'Choose..'">
                </select>
            </div>
            <div class="span6 required">
                <fc:textArea data-bind="value: description" id="description"
                             label="Description" class="full-width form-control" row="5"
                             data-validation-engine="validate[required]"/>
            </div>
        </div>

        <div class="row-fluid"
             data-bind="template:transients.isMilestone() ? 'milestoneTmpl' : 'activityTmpl'">

        </div>

        <div class="row-fluid">
            <div class="span12">
                <button class="btn btn-primary save-activity">
                    <i class="icon icon-white"
                       data-bind="css: {'icon-plus': !activityId, 'icon-file': activityId}">
                    </i>
                    <!-- ko text: activityId ? 'Save activity': 'Create activity' --> <!-- /ko -->
                </button>
                <button class="btn" data-bind="click: transients.stopEditing, visible: activityId">Cancel</button>
            </div>
        </div>
    </div>
</div>
</script>
<script id="activityRow" type="text/html">

<td>
    <button type="button" class="btn btn-mini"
            data-bind="click:editActivity"><i
            class="icon-edit" title="Edit Activity"></i></button>
    <button type="button" class="btn btn-mini" data-bind="click:viewActivity"><i
            class="icon-eye-open" title="View Activity"></i></button>
    <button type="button" class="btn btn-mini"
            data-bind="click:printActivity"><i
            class="icon-print" title="Print activity"></i></button>
    <button type="button" class="btn btn-mini"
            data-bind="click:deleteActivity"><i class="icon-remove" title="Delete activity"></i>
    </button>
</td>
<td><span data-bind="text:plannedStartDate.formattedDate"></span></td>
<td><span data-bind="text:plannedEndDate.formattedDate"></span></td>
<td>
    <span class="truncate"
          data-bind="text:description,click: editActivity, css:{clickable:true}"></span>
</td>
<td>
    <span data-bind="text:type,click: editActivity, css:{clickable:true}"></span>
    <button class="btn btn-default btn-mini" data-bind="click: editActivityMetadata, visible: canEditActivity"><i class="icon icon-edit"></i> <g:message code="project.survey.activity.edit"/></button>
    <button class="btn btn-default btn-mini" data-bind="click: transients.editSpeciesConfiguration, visible: transients.canEditSpeciesConfiguration"><i class="icon icon-edit"></i> <g:message code="project.survey.activity.editSpecies"/></button>
</td>
<td><a class="clickable" data-bind="text:siteName,click:$parent.openSite"></a></td>
<td>
    <span data-bind="template:canUpdateStatus() ? 'updateStatusTmpl' : 'viewStatusTmpl'"></span>

    <!-- Modal for getting reasons for status change -->
    <div id="activityStatusReason" class="modal hide fade" tabindex="-1" role="dialog"
         aria-labelledby="myModalLabel" aria-hidden="true"
         data-bind="showModal: displayReasonModal(), with:deferReason">
        <form class="reasonModalForm">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true"
                        data-bind="click:$parent.displayReasonModal.cancelReasonModal">×</button>

                <h3 id="myModalLabel">Reason for deferring or cancelling an activity</h3>
            </div>

            <div class="modal-body">
                <p>If you wish to defer or cancel a planned activity you must provide an explanation. Your case
                manager will use this information when assessing your report.</p>

                <p>You can simply refer to a document that has been uploaded to the project if you like.</p>
                <textarea data-bind="value:notes,hasFocus:true" name="reason" rows=4 cols="80"
                          class="validate[required]"></textarea>
            </div>

            <div class="modal-footer">
                <button class="btn"
                        data-bind="click: $parent.displayReasonModal.cancelReasonModal"
                        data-dismiss="modal" aria-hidden="true">Discard status change</button>
                <button class="btn btn-primary"
                        data-bind="click:$parent.displayReasonModal.saveReasonDocument">Save reason</button>
            </div></form>
    </div>

</td>

</script>
<script id="milestoneRow" type="text/html">

    <td>
        <button type="button" class="btn btn-mini"
                data-bind="click:editActivity"><i
                class="icon-edit" title="Edit Milestone"></i></button>
        <button type="button" class="btn btn-mini" data-bind="click:viewActivity"><i
                class="icon-eye-open" title="View Milestone"></i></button>
        <button type="button" class="btn btn-mini"
                data-bind="click:deleteActivity"><i class="icon-remove" title="Delete Milestone"></i>
        </button>
    </td>
    <td><span data-bind="text:plannedStartDate.formattedDate"></span></td>
    <td><span data-bind="text:plannedEndDate.formattedDate"></span></td>
    <td>
        <span class="truncate"
              data-bind="text:description,click:$parent.editActivity, css:{clickable:true}"></span>
    </td>
    <td>
        <span data-bind="text:type,click:$parent.editActivity, css:{clickable:true}"></span>
    </td>
    <g:if test="${showSites}">
        <td></td>
    </g:if>
    <td>

</td>

</script>
<script id="updateStatusTmpl" type="text/html">
<div class="btn-group">
    <button type="button" class="btn btn-small dropdown-toggle" data-toggle="dropdown"
            data-bind="css: {'btn-warning':progress()=='planned','btn-success':progress()=='started','btn-info':progress()=='finished','btn-danger':progress()=='deferred','btn-inverse':progress()=='cancelled'}"
            style="line-height:16px;min-width:86px;text-align:left;">
        <span data-bind="text: progress"></span> <span class="caret pull-right" style="margin-top:6px;"></span>
    </button>
    <ul class="dropdown-menu" data-bind="foreach:$root.progressOptions" style="min-width:100px;">
        <!-- Disable item if selected -->
        <li data-bind="css: {'disabled' : $data==$parent.progress() || $data=='planned'}">
            <a href="#" data-bind="click: $parent.progress"><span data-bind="text: $data"></span></a>
        </li>
    </ul></div>
<span class="save-indicator" data-bind="visible:transients.isSaving"><r:img dir="images" file="ajax-saver.gif"
                                                                 alt="saving icon"/> saving</span>
<!-- ko with: deferReason -->
<span data-bind="visible: $parent.progress()=='deferred' || $parent.progress()=='cancelled'">
    <i class="icon-list-alt"
       data-bind="popover: {title: 'Reason for deferral<br><small>(Click icon to edit reason.)</small>', content: notes, placement: 'left'}, click:$parent.displayReasonModal.editReason">
    </i>
</span>
<!-- /ko -->
</script>
<script id="viewStatusTmpl" type="text/html">
<button type="button" class="btn btn-small"
        data-bind="css: {'btn-warning':progress()=='planned','btn-success':progress()=='started','btn-info':progress()=='finished','btn-danger':progress()=='deferred','btn-inverse':progress()=='cancelled'}"
        style="line-height:16px;min-width:75px;text-align:left;cursor:default;color:white">
    <span data-bind="text: progress"></span>
</button>
<!-- ko with: deferReason -->
<span data-bind="visible: $parent.progress()=='deferred' || $parent.progress()=='cancelled'">
    <i class="icon-list-alt"
       data-bind="popover: {title: 'Reason for deferral', content: notes, placement: 'left'}">
    </i>
</span>
<!-- /ko -->
</script>
<script type="text/html" id="activityTmpl">
<div class="span6 required">
    <label for="plannedStartDate">Planned start date
    <fc:iconHelp title="Planned start date"
                 printable="${printView}">Date the activity is intended to start.</fc:iconHelp>
    </label>

    <div class="input-append">
        <fc:datePicker targetField="plannedStartDate.date" name="plannedStartDate"
                       data-validation-engine="validate[required,future[${formattedStartDate}]]"
                       printable="${printView}"/>
    </div>
</div>

<div class="span6 required">
    <label for="plannedEndDate">Planned end date
    <fc:iconHelp title="Planned end date"
                 printable="${printView}">Date the activity is intended to finish.</fc:iconHelp>
    </label>

    <div class="input-append">
        <fc:datePicker targetField="plannedEndDate.date" name="plannedEndDate"
                       data-validation-engine="validate[future[plannedStartDate],past[${formattedEndDate}],required]"
                       printable="${printView}"/>
    </div>
</div>
</script>
<script type="text/html" id="milestoneTmpl">
<div class="span6 required">
    <label for="plannedStartDate">Milestone date
    <fc:iconHelp title="Planned start date"
                 printable="${printView}">Date the activity is intended to start.</fc:iconHelp>
    </label>

    <div class="input-append">
        <fc:datePicker targetField="plannedStartDate.date" name="plannedStartDate"
                       data-validation-engine="validate[required,future[${formattedStartDate}]]"
                       printable="${printView}"/>
    </div>
</div>
</script>
<script type="text/html" id="speciesConfigurationTmpl">
<div>
    <!-- ko with: transients.speciesSettings -->
    <h4><g:message code="project.survey.species.configureSpeciesFields"/></h4>
    <div id="species-validation-result-placeholder"></div>
    <table class="table" data-bind="css: {'ajax-opacity': transients.parent.transients.isSaving}">
        <thead>
        <tr>
            <th>
                <label class="control-label"><g:message code="project.survey.species.fieldName"/>
                    <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.species.fieldName"/>', content:'<g:message code="project.survey.species.fieldName.content"/>'}">
                        <i class="icon-question-sign"></i>
                    </a>
                </label>
            </th>
            <th>
                <label class="control-label"><g:message code="project.survey.species.settings"/>
                    <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.species.settings"/>', content:'<g:message code="project.survey.species.settings.content"/>'}">
                        <i class="icon-question-sign"></i>
                    </a>
                </label>
            </th>
            <th>
                <label class="control-label"><g:message code="project.survey.species.displayAs"/>
                    <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.species.displayAs"/>', content:'<g:message code="project.survey.species.displayAs.content"/>'}">
                        <i class="icon-question-sign"></i>
                    </a>
                </label>
            </th>
            <th>
                <label class="control-label"><g:message code="project.survey.species.actions"/>
                    <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.species.actions"/>', content:'<g:message code="project.survey.species.actions.content"/>'}">
                        <i class="icon-question-sign"></i>
                    </a>
                </label>
            </th>
        </tr>
        </thead>
        <tbody>
        <!-- ko foreach: speciesFields -->
            <tr>
                <td>
                    <span data-bind="text: label"></span>
                </td>
                <td>
                    <span class="req-field" data-bind="tooltip: {title:config().transients.inputSettingsTooltip()}">
                        <input type="text" class="input-large" data-bind="disable: true, value: config().transients.inputSettingsSummary"> </input>
                    </span>
                    <a target="_blank" data-bind="click:showSpeciesConfiguration" class="btn btn-link" ><small><g:message code="project.survey.species.configure"/></small></a>
                </td>
                <td>
                    <select class="form-control full-width" data-bind="disable: config().type() == 'DEFAULT_SPECIES', options: $parent.transients.availableSpeciesDisplayFormat, optionsText:'name', optionsValue:'id', value:  config().speciesDisplayFormat">
                    </select>
                </td>
                <td>
                    <button class="btn btn-default" data-bind="click: $parent.transients.parent.toggleDefault"><g:message code="project.survey.species.showdefault"/></button>
                    <button class="btn btn-default" data-bind="click: $parent.transients.parent.setAsDefault, disable: !config().isValid()"><g:message code="project.survey.species.setdefault"/></button>
                </td>
            </tr>
            <tr data-bind="slideVisible: $parent.transients.parent.showDefault">
                <!-- ko with: $parent.transients.parent.species -->
                <td></td>
                <td>
                    <span class="req-field" data-bind="tooltip: {title:transients.inputSettingsTooltip()}">
                        <input type="text" class="input-large" data-bind="disable: true, value: transients.inputSettingsSummary"> </input>
                    </span>
                </td>
                <td>
                    <input class="form-control full-width" data-bind="value: speciesDisplayFormat" disabled/>
                </td>
                <td></td>
                <!-- /ko -->
            </tr>
        <!-- /ko -->
        </tbody>
    </table>
    <button class="btn btn-primary" data-bind="click: transients.parent.save">
        <i class="icon icon-white icon-file"/>
        <g:message code="project.survey.species.saveButton"/>
    </button>
    <!-- /ko -->
</div>
</script>
<!-- ko stopBinding: true -->
<div  id="speciesFieldDialog" data-bind="template: {name:'speciesFieldDialogTemplate'}"></div>
<!-- /ko -->

<script type="text/html" id="speciesFieldDialogTemplate">
<g:render template="/projectActivity/speciesFieldSettingsDialog"></g:render>
</script>
<r:script>

    ko.bindingHandlers.showModal = {
        init: function (element, valueAccessor) {
            $(element).modal({ backdrop: 'static', keyboard: true, show: false });
        },
        update: function (element, valueAccessor) {
            var value = valueAccessor();
            if (ko.utils.unwrapObservable(value)) {
                $(element).modal('show');
            }
            else {
                $(element).modal('hide');
            }
        }
    };

    ko.extenders.withPrevious = function (target) {
        // Define new properties for previous value and whether it's changed
        target.previous = ko.observable();
        target.changed = ko.computed(function () { return target() !== target.previous(); });
        target.revert = function () {
            target(target.previous());
        };

        // Subscribe to observable to update previous, before change.
        target.subscribe(function (v) {
            target.previous(v);
        }, null, 'beforeChange');

        // Return modified observable
        return target;
    };

    var sites = ${sites ?: []};
    function lookupSiteName (siteId) {
        var site;
        if (siteId !== undefined && siteId !== '') {
            site = $.grep(sites, function(obj, i) {
                    return (obj.siteId === siteId);
            });
            if (site.length > 0) {
                 return site[0].name;
            }
        }
        return '';
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

    $(window).load(function () {
     var project = <fc:modelAsJavascript model="${project}"/>;
     var config = {
            activities: ${activities ?: []},
            outputTargets: project.outputTargets || {},
            project: project,
            placeholder: 'status-update-error-placeholder',
            speciesPlaceholder: 'species-validation-result-placeholder'
     }
    var planViewModel = new PlanViewModel(config);
        ko.applyBindings(planViewModel, document.getElementById('planContainer'));

        // the following code handles resize-sensitive truncation of the description field
        $.fn.textWidth = function(text, font) {
            if (!$.fn.textWidth.fakeEl) $.fn.textWidth.fakeEl = $('<span>').hide().appendTo(document.body);
            $.fn.textWidth.fakeEl.html(text || this.val() || this.text()).css('font', font || this.css('font'));
            return $.fn.textWidth.fakeEl.width();
        };

        function adjustTruncations () {
            function truncate (cellWidth, originalTextWidth, originalText) {
                var fractionThatFits = cellWidth/originalTextWidth,
                    truncationPoint = Math.floor(originalText.length * fractionThatFits) - 4;
                return originalText.substr(0,truncationPoint) + '..';
            }
            $('.truncate').each( function () {
                var $span = $(this),
                    text = $span.html(),
                    textWidth = $span.textWidth(),
                    textLength = text.length,
                    original = $span.data('truncation');
                // store original values if first time in
                if (original === undefined) {
                    original = {
                        text: text,
                        textWidth: textWidth,
                        textLength: textLength
                    };
                    $span.data('truncation',original);
                }
                if (!planViewModel.descriptionExpanded()) {
                var cellWidth = $span.parent().width(),
                    isTruncated = original.text !== text;
                if (cellWidth > 0 && textWidth > cellWidth) {
                    $span.attr('title',original.text);
                    $span.html(truncate(cellWidth, original.textWidth, original.text));
                } else if (isTruncated && cellWidth > textWidth + 4) {
                    // check whether the text can be fully expanded
                    if (original.textWidth < cellWidth) {
                        $span.html(original.text);
                        $span.removeAttr('title');
                    } else {
                        $span.html(truncate(cellWidth, original.textWidth, original.text));
                    }
                }
                }
                else {
                    $span.html(original.text);
                    $span.removeAttr('title');
                }
            });
        }

        // throttle the resize events so it doesn't go crazy
        (function() {
             var timer;
             $(window).resize(function () {
                 if(timer) {
                     clearTimeout(timer);
                 }
                 timer = setTimeout(adjustTruncations, 50);
             });
        }());

        // only initialise truncation when the table is visible else we will get 0 widths
        $(document).on('planTabShown', function () {
            // initial adjustments
            adjustTruncations();
        });

        // the following draws the gantt chart
        drawGanttChart(planViewModel.getGanttData());

        $('#outputTargetsContainer').validationEngine('attach', {scroll:false});

    });

</r:script>
