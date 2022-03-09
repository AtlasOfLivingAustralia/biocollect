<%@ page import="grails.converters.JSON; au.org.ala.biocollect.DateUtils;" %>
<asset:script type="text/javascript">
    var PROJECT_STATE = {approved: 'approved', submitted: 'submitted', planned: 'not approved'};
    var ACTIVITY_STATE = {
        planned: 'planned', started: 'started', finished: 'finished', deferred: 'deferred',
        cancelled: 'cancelled'
    };
</asset:script>
<g:set var="formattedStartDate" value="${DateUtils.isoToDisplayFormat(project.plannedStartDate)}"/>
<g:set var="formattedEndDate" value="${DateUtils.isoToDisplayFormat(project.plannedEndDate)}"/>
<!-- This section is bound to a secondary KO viewModel. The following line prevents binding
         to the main viewModel. -->
<!-- ko stopBinding: true -->
<div class="container-fluid">
    <div class="row" id="planContainer">
        <div class="col-12">
            <bc:koLoading>
    <div id="status-update-error-placeholder"></div>

    <div id="activityContainer" class="space-before">
        <h4 class="inline">Planned Activities</h4>

        <ul class="nav nav-tabs nav-tab-small space-before">
            <li class="nav-item"><a class="nav-link active" href="#tablePlan" data-toggle="tab">Tabular</a></li>
            <li class="nav-item"><a class="nav-link" href="#ganttPlan" data-toggle="tab">Gantt chart</a></li>
        </ul>

        <div class="tab-content" style="padding:0;border:none;overflow:visible">
            <div class="tab-pane active" id="tablePlan">
                <!-- ko template: 'workScheduleActionButtonsTmpl' -->
                <!-- /ko -->

                <table class="table table-condensed table-hover" id="activities">
                    <thead>
                    <!-- ko template: 'activityHeaderTmpl'-->
                    <!-- /ko -->
                    </thead>
                    <tbody data-bind="foreach:activities.activities" id="activityList">
                    <tr data-bind="template:typeCategory() == 'Milestone' ? 'milestoneRow':'activityRow', css:typeCategory, slideVisible: !transients.editActivity() || !transients.remove(), highlight: transients.remove() || !transients.editActivity(), slideDuration: 200">

                    </tr>
                    <!-- ko if: transients.speciesSettings() -->
                    <tr class="no-highlight-on-hover" data-bind="slideVisible: transients.speciesConfigurationToggle, slideDuration: 200">
                        <td colspan="7">
                            <div class="padding-10 border-1">
                                <!-- ko template: 'speciesConfigurationTmpl' -->
                                <!-- /ko -->
                            </div>
                        </td>
                    </tr>
                    <!-- /ko -->
                    </tbody>
                    <tfoot>
                    <!-- ko template: 'activityHeaderTmpl'-->
                    <!-- /ko -->
                    </tfoot>
                </table>
            </div>
            <div class="tab-pane" id="ganttPlan" style="overflow:hidden;">
                <div id="gantt-container"></div>
            </div>
        </div>
    </div>


    <!-- ko with: selectedWorksActivityViewModel -->
    <div class="modal hide fade" id="createOrUpdateActivity" data-bind="dismissModal: transients.dismissModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <div data-bind="validateOnClick:  { callback: save, selector: '.save-activity'}, css: {'ajax-opacity': transients.isSaving}" class="validationEngineContainer">
                <h4><!-- ko text: activityId ? 'Update activity': 'Add a new activity' --> <!-- /ko --></h4>
                <div id="add-new-activity">
                    <div class="row form-group">
                        <div class="col-sm-4 required">
                            <label>Type of activity</label>
                            <select class="form-control form-control-sm" data-bind="value: type,
                                popover:{title:'', content: transients.activityDescription,
                                trigger:'manual', autoShow:true}, enable: canEditType"  class="full-width form-control"
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

                        <div class="col-sm-2">
                            <div data-bind="visible:fcConfig.themes && fcConfig.themes.length > 1">
                                <label>Major theme</label>
                                <select class="form-control form-control-sm"
                                        data-bind="value:mainTheme, options:fcConfig.themes,
                                                                optionsText: 'name', optionsValue: 'name',
                                                                optionsCaption:'Choose..'">
                                </select>
                            </div>
                        </div>
                        <div class="col-sm-6 required">
                            <fc:textArea data-bind="value: description" id="description"
                                         label="Description" class="form-control" row="5"
                                         data-validation-engine="validate[required]"/>
                        </div>
                    </div>

                    <div class="row"
                         data-bind="template:transients.isMilestone() ? 'milestoneTmpl' : 'activityTmpl'">

                    </div>

                    <div class="row mt-3">
                        <div class="col-sm-12">
                            <button class="btn btn-primary-dark save-activity">
                                <i class="fas "
                                   data-bind="css: {'fa-plus': !activityId, 'fa-hdd': activityId}">
                                </i>
                                <!-- ko text: activityId ? '<g:message code="project.works.workschedule.activitymodal.save"/>': '<g:message code="project.works.workschedule.activitymodal.create"/>' --> <!-- /ko -->
                            </button>
                            <button class="btn btn-dark" data-bind="click: transients.stopEditing"><i class="far fa-times-circle"></i> <g:message code="project.works.workschedule.activitymodal.close"/></button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
            </div>
        </div>
    </div>

    <!-- Modal for getting reasons for status change -->
    <div id="activityStatusReason" class="modal hide fade"
         data-bind="showModal: displayReasonModal(), with:deferReason">
        <div class="modal-dialog">
            <div class="modal-content">
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
                                  class="validate[required] form-control"></textarea>
                    </div>

                    <div class="modal-footer">
                        <button class="btn btn-dark"
                                data-bind="click: $parent.displayReasonModal.cancelReasonModal"
                                data-dismiss="modal" aria-hidden="true"><i class="far fa-times-circle"></i> Discard status change</button>
                        <button class="btn btn-primary-dark"
                                data-bind="click:$parent.displayReasonModal.saveReasonDocument"><i class="fas fa-hdd"></i> Save reason</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <!-- /ko -->

    <form id="outputTargetsContainer" data-bind="visible: outputTargets().length">
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
                    <textarea class="form-control"
                              data-bind="visible:$root.canEditOutputTargets(),value:$parents[1].outcomeTarget"
                              rows="3"
                              cols="80"></textarea>
                    <span data-bind="visible:!$root.canEditOutputTargets(),text:$parents[1].outcomeTarget"></span>
                    <span class="save-indicator" data-bind="visible:$parents[1].isSaving"><img src="${asset.assetPath(src:'ajax-saver.gif')}"
                                                                                                 alt="saving icon"/> saving</span>
                </td>
                <!-- /ko -->
                <td><span data-bind="text:scoreLabel"></span></td>
                <td>
                    <input type="text" class="form-control form-control-sm"
                           data-bind="visible:$root.canEditOutputTargets(),value:target"
                           data-validation-engine="validate[required,custom[number]]"/>
                    <span data-bind="visible:!$root.canEditOutputTargets(),text:target"></span>
                    <span data-bind="text:units"></span>
                    <span class="save-indicator" data-bind="visible:isSaving"><img src="${asset.assetPath(src:'ajax-saver.gif')}"
                                                                                   alt="saving icon"/> saving</span>
                </td>

            </tr>
            </tbody>
            <!-- /ko -->
        </table>

    </form>

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
</bc:koLoading>
        </div>
    </div>
</div>
<!-- /ko -->

<!-- ko stopBinding: true -->
<div  id="speciesFieldDialog" data-bind="template: {name:'speciesFieldDialogTemplate'}"></div>
<!-- /ko -->

<!-- ko stopBinding: true -->
<div id="attachReasonDocument" class="modal fade" style="display:none;" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
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
                                <i class="fas fa-plus"></i>
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
                            <span class="alert alert-danger" data-bind="text:error"></span>
                        </div>
                    </div>

                    <g:if test="${grailsApplication.config.debugUI}">
                        <div class="expandable-debug">
                            <h3>Debug</h3>

                            <div>
                                <h4>Document model</h4>
                                <pre class="row" data-bind="text:toJSONString()"></pre>
                            </div>
                        </div>
                    </g:if>

                </form>
            </div>

            <div class="modal-footer control-group">
                <div class="controls">
                    <button type="button" class="btn btn-success"
                            data-bind="enable:name() && !error(), click:save, visible:!complete()"><i class="fas fa-hdd"></i> Save</button>
                    <button class="btn" data-bind="click:cancel, visible:!complete()"><i class="far fa-times-circle"></i> Cancel</button>
                    <button class="btn" data-bind="click:close, visible:complete()"><i class="fas fa-times"></i> Close</button>

                </div>
            </div>

        </div>
    </div>
</div>
<!-- /ko -->

<!-- templates -->
<script id="activityHeaderTmpl" type="text/html">
<tr>
    <th>Actions</th>
    <th>From</th>
    <th>To</th>
    <th>Description</th>
    <th>Activity &nbsp;
        <a href="#createOrUpdateActivity" role="button" class="btn btn-dark btn-sm" data-toggle="modal"
                    data-bind="click: openActivityModal(newActivityViewModel), visible: fcConfig.canAddActivity"><i class="fas fa-plus"></i>
        <g:message code="project.works.createNewActivity"/> </a>
    </th>
    <th>Site &nbsp;
        <a class="btn btn-dark btn-sm" data-bind="attr: {href: fcConfig.siteCreateUrl}, visible: fcConfig.canAddSite">
            <i class="fas fa-plus"></i>
            <g:message code="project.works.workschedule.button.createsite"/>
        </a>
    </th>
    <th>Status</th>
</tr>
</script>
<script id="activityRow" type="text/html">

<td class="btn-space">
    <a class="btn btn-dark btn-sm" href="#createOrUpdateActivity" role="button" data-toggle="modal"  data-bind="click: $parent.openActivityModal($data), visible: canEditActivity"><i
            class="fas fa-pencil-alt" title="Edit Activity"></i></a>
    <button type="button" class="btn btn-dark btn-sm" data-bind="click:viewActivity"><i
            class="far fa-eye" title="View Activity"></i></button>
    <button type="button" class="btn btn-sm btn-danger"
            data-bind="click:deleteActivity, visible: canDeleteActivity"><i class="far fa-trash-alt" title="Delete activity"></i>
    </button>
</td>
<td><span data-bind="text:plannedStartDate.formattedDate"></span></td>
<td><span data-bind="text:plannedEndDate.formattedDate"></span></td>
<td>
    <span class="truncate"
          data-bind="text:description,click: editActivity, css:{clickable:true}"></span>
</td>
<td>
    <a href="#" data-bind="text:type,click: editActivity"></a>
    <button class="btn btn-dark btn-sm float-right" data-bind="click: transients.editSpeciesConfiguration, visible: transients.canEditSpeciesConfiguration">
        <i class="fas " data-bind="css: { 'fa-arrow-down': transients.speciesConfigurationToggle, 'fa-arrow-up': !transients.speciesConfigurationToggle() }"></i>
        <g:message code="project.survey.activity.editSpecies"/>
    </button>
</td>
<td>
    <div class="row" data-bind="css: {'ajax-opacity': transients.isSaving}">
        <div class="col-sm-12">
            <select class="form-control form-control-sm" data-bind="options: resolveSites(fcConfig.siteIds, true), optionsText: 'name', optionsValue: 'siteId', optionsCaption: 'Please choose', value: siteId"></select>
            <span class="margin-left-1">
                <a href="#" data-bind="click:$parent.openSite, attr: {title: siteName}, visible: siteId"><i class="fas fa-info-circle"></i></a>
                <span data-bind="visible: transients.siteArea">
                    <!-- ko text: transients.siteArea -->
                    <!-- /ko -->
                    <g:message code="unit.distance"></g:message><sup>2</sup>
                </span>
            </span>
        </div>
    </div>
<td>
    <span data-bind="template:canUpdateStatus() ? 'updateStatusTmpl' : 'viewStatusTmpl'"></span>
</td>

</script>
<script id="milestoneRow" type="text/html">

    <td class="btn-space">
        <a class="btn btn-sm btn-dark" href="#createOrUpdateActivity" role="button" data-toggle="modal"  data-bind="click: $parent.openActivityModal($data), visible: canEditActivity"><i
                class="fas fa-pencil-alt" title="Edit Milestone"></i></a>
        <button type="button" class="btn btn-sm btn-dark" data-bind="click:viewActivity"><i
                class="far fa-eye" title="View Milestone"></i></button>
        <button type="button" class="btn btn-sm btn-danger"
                data-bind="click:deleteActivity, visible: canDeleteActivity"><i class="far fa-trash-alt" title="Delete Milestone"></i>
        </button>
    </td>
    <td><span data-bind="text:plannedStartDate.formattedDate"></span></td>
    <td><span data-bind="text:plannedEndDate.formattedDate"></span></td>
    <td>
        <span class="truncate"
              data-bind="text:description,click:editActivity, css:{clickable:true}"></span>
    </td>
    <td>
        <a href="#" data-bind="text:type,click:editActivity"></a>
    </td>
    <td></td>
    <td><span data-bind="template:canUpdateStatus() ? 'updateStatusTmpl' : 'viewStatusTmpl'"></span></td>

</script>
<script id="updateStatusTmpl" type="text/html">
<div class="btn-group">
    <button type="button" class="btn btn-sm dropdown-toggle" data-toggle="dropdown"
            data-bind="css: {'btn-warning':progress()=='planned','btn-success':progress()=='started','btn-info':progress()=='finished','btn-danger':progress()=='deferred','btn-dark':progress()=='cancelled'}"
            style="line-height:16px;min-width:86px;text-align:left;">
        <span data-bind="text: progress"></span> <span class="caret float-right" style="margin-top:6px;"></span>
    </button>
    <ul class="dropdown-menu" data-bind="foreach:$root.progressOptions" style="min-width:100px;">
        <!-- Disable item if selected -->
        <li data-bind="css: {'disabled' : $data==$parent.progress() || $data=='planned'}">
            <a href="#" data-bind="click: $parent.progress"><span data-bind="text: $data"></span></a>
        </li>
    </ul>
</div>
<a class="save-indicator" data-bind="visible:transients.isSaving">
    <img src="${asset.assetPath(src:'ajax-saver.gif')}" alt="saving icon"/> saving
</a>
<!-- ko with: deferReason -->
<span data-bind="visible: $parent.progress()=='deferred' || $parent.progress()=='cancelled'">
    <i class="fas fa-list"
       data-bind="popover: {title: 'Reason for deferral<br><small>(Click icon to edit reason.)</small>', content: notes, placement: 'left'}, click:$parent.displayReasonModal.editReason">
    </i>
</span>
<!-- /ko -->
</script>
<script id="viewStatusTmpl" type="text/html">
<button type="button" class="btn btn-sm"
        data-bind="css: {'btn-warning':progress()=='planned','btn-success':progress()=='started','btn-info':progress()=='finished','btn-danger':progress()=='deferred','btn-dark':progress()=='cancelled'}"
        style="line-height:16px;min-width:75px;text-align:left;cursor:default;color:white">
    <span data-bind="text: progress"></span>
</button>
<!-- ko with: deferReason -->
<span data-bind="visible: $parent.progress()=='deferred' || $parent.progress()=='cancelled'">
    <i class="fas fa-list"
       data-bind="popover: {title: 'Reason for deferral', content: notes, placement: 'left'}">
    </i>
</span>
<!-- /ko -->
</script>
<script type="text/html" id="activityTmpl">
<div class="col-sm-6 required">
    <label for="plannedStartDate">Planned start date
    <fc:iconHelp title="Planned start date"
                 printable="${printView}">Date the activity is intended to start.</fc:iconHelp>
    </label>

    <div class="input-group">
        <fc:datePicker class="from-control" targetField="plannedStartDate.date" name="plannedStartDate"
                       data-validation-engine="validate[required,future[${formattedStartDate}]]"
                       printable="${printView}" bs4="true" theme="btn-dark"/>
    </div>
</div>

<div class="col-sm-6 required">
    <label for="plannedEndDate">Planned end date
    <fc:iconHelp title="Planned end date"
                 printable="${printView}">Date the activity is intended to finish.</fc:iconHelp>
    </label>

    <div class="input-group">
        <fc:datePicker class="from-control" targetField="plannedEndDate.date" name="plannedEndDate"
                       data-validation-engine="validate[future[plannedStartDate],past[${formattedEndDate}],required]"
                       printable="${printView}" bs4="true" theme="btn-dark"/>
    </div>
</div>
</script>
<script type="text/html" id="milestoneTmpl">
<div class="col-sm-6 required">
    <label for="plannedStartDate">Milestone date
    <fc:iconHelp title="Planned start date"
                 printable="${printView}">Date the activity is intended to start.</fc:iconHelp>
    </label>

    <div class="input-group-append">
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
                        <i class="fas fa-question-circle"></i>
                    </a>
                </label>
            </th>
            <th>
                <label class="control-label"><g:message code="project.survey.species.settings"/>
                    <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.species.settings"/>', content:'<g:message code="project.survey.species.settings.content.works"/>'}">
                        <i class="fas fa-question-circle"></i>
                    </a>
                </label>
            </th>
            <th>
                <label class="control-label"><g:message code="project.survey.species.displayAs"/>
                    <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.species.displayAs"/>', content:'<g:message code="project.survey.species.displayAs.content"/>'}">
                        <i class="fas fa-question-circle"></i>
                    </a>
                </label>
            </th>
            <th>
                <label class="control-label"><g:message code="project.survey.species.actions"/>
                    <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.species.actions"/>', content:'<g:message code="project.survey.species.actions.content"/>'}">
                        <i class="fas fa-question-circle"></i>
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
                    <span data-bind="tooltip: {title:config().transients.inputSettingsTooltip()}, disable: true, text: config().transients.inputSettingsSummary"></span>
                </td>
                <td>
                    <select class="form-control form-control-sm" data-bind="disable: config().type() == 'DEFAULT_SPECIES', options: $parent.transients.availableSpeciesDisplayFormat, optionsText:'name', optionsValue:'id', value:  config().speciesDisplayFormat">
                    </select>
                </td>
                <td>
                    <button data-bind="click: showSpeciesConfiguration" class="btn btn-dark" ><i class="fas fa-cog"></i> <g:message code="project.survey.species.configure.works"/></button>
                    <button class="btn btn-dark" data-bind="click: $parent.transients.parent.copySettings">
                        <i class="fas fa-bookmark"/>
                        <g:message code="project.survey.species.setdefault"/>
                    </button>
                </td>
            </tr>
        <!-- /ko -->
        </tbody>
    </table>
    <button class="btn btn-primary-dark" data-bind="click: transients.parent.save">
        <i class="fas fa-hdd"></i>
        <g:message code="project.survey.species.saveButton"/>
    </button>
    <button class="btn btn-dark" data-bind="click: $parent.transients.editSpeciesConfiguration">
        <i class="far fa-times-circle"></i>
        <g:message code="project.survey.species.closeButton"/>
    </button>

    <!-- /ko -->
</div>
</script>
<script type="text/html" id="speciesFieldDialogTemplate">
<g:render template="/projectActivity/speciesFieldSettingsDialog"></g:render>
</script>
<script type="text/html" id="workScheduleActionButtonsTmpl">
<div class="row no-gutters">
    <div class="col-sm-12">
        <div class="float-right">
            <a class="btn btn-info my-2" data-bind="attr: {href: fcConfig.worksScheduleIntroUrl}"><i class="fas fa-question-circle"></i>
                <g:message code="project.works.workschedule.button.help"/></a>
        </div>
    </div>
</div>
</script>
<asset:script type="text/javascript">

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

    $(window).on('load',function () {
     var project = <fc:modelAsJavascript model="${project}"/>;
     var config = {
            activities: <fc:modelAsJavascript model="${activities ?: []}"/>,
            outputTargets: project.outputTargets || {},
            project: project,
            placeholder: 'status-update-error-placeholder',
            speciesPlaceholder: 'species-validation-result-placeholder'
     }
    var planViewModel = new PlanViewModel(config);
        ko.cleanNode(document.getElementById('planContainer'));
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

</asset:script>
