<r:require modules="datepicker, jqueryGantt, jqueryValidationEngine, attachDocuments"/>
<r:script>
    var PROJECT_STATE = {approved: 'approved', submitted: 'submitted', planned: 'not approved'};
    var ACTIVITY_STATE = {
        planned: 'planned', started: 'started', finished: 'finished', deferred: 'deferred',
        cancelled: 'cancelled'
    };

</r:script>
<!-- This section is bound to a secondary KO viewModel. The following line prevents binding
         to the main viewModel. -->
<!-- ko stopBinding: true -->
<div class="row-fluid" id="planContainer">
    <div id="status-update-error-placeholder"></div>

    <div id="activityContainer" class="space-before">

        <div class="row-fluid" data-bind="visible:planStatus()==='not approved'">
            <div class="row-fluid">
                <div class="span6"><span class="badge badge-info">Planning Mode</span>
                    <fc:iconHelp>Use the "Add new activity" button to add a new activity to your plan.  When you have finished adding activities, use the "Finished planning" button to go into data entry mode.  You can toggle freely between planning and data entry modes.</fc:iconHelp>
                </div>
            </div>
            <g:if test="${user?.isEditor}">

                    <div class="well">
                        <fc:getSettingContent settingType="${au.org.ala.biocollect.merit.SettingPageType.WORKS_PLANNING_MODE_INTRO}"/>
                    </div>

                <div class="form-actions">

                    <span>Planning actions: </span>
                    <a class="btn btn-success" class="btn btn-link"
                            data-bind="visible:planStatus()==='not approved',click:newActivity"
                            style="vertical-align: baseline"><i class="fa fa-plus"></i> Add new activity</a>

                    <a class="btn btn-success" class="btn btn-link"
                       data-bind="visible:planStatus()==='not approved',click:speciesFieldsConfiguration"
                       style="vertical-align: baseline"><i class="fa fa-table"></i> Configure species fields</a>

                    <button class="btn btn-info" data-bind="click:finishedPlanning">Finished planning</button>

                </div>
            </g:if>

        </div>

        <div class="row-fluid" data-bind="visible:planStatus()==='approved'">
            <div class="span6"><span class="badge badge-info">Data Entry Mode</span>
                <fc:iconHelp>Enter implementation details for project activities using the controls to the left of each activity.  Use the "Edit plann" button to return to planning mode to add new activities or change planning dates.</fc:iconHelp>
            </div>
            <g:if test="${user?.isEditor}">
                <h5></h5>
                <div class="form-actions">

                    <span>Actions: </span>

                    <button class="btn btn-info" data-bind="click:editPlan">Edit plan</button>
            </g:if>
        </div>
        </div>


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
                        <g:if test="${showSites}">
                            <th>Site</th>
                        </g:if>
                        <th>Status</th>
                    </tr>
                    </thead>
                    <tbody data-bind="foreach:activities.activities" id="activityList">
                    <tr>
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
                                  data-bind="text:description,click:$parent.editActivity, css:{clickable:true}"></span>
                        </td>
                        <td>
                            <span data-bind="text:type,click:$parent.editActivity, css:{clickable:true}"></span>
                        </td>
                        <g:if test="${showSites}">
                            <td><a class="clickable" data-bind="text:siteName,click:$parent.openSite"></a></td>
                        </g:if>
                        <td>
                            <span data-bind="template:canUpdateStatus() ? 'updateStatusTmpl' : 'viewStatusTmpl'"></span>

                            <!-- Modal for getting reasons for status change -->
                            <div id="activityStatusReason" class="modal hide fade" tabindex="-1" role="dialog"
                                 aria-labelledby="myModalLabel" aria-hidden="true"
                                 data-bind="showModal:displayReasonModal(),with:deferReason">
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
                    </tr>
                    </tbody>
                </table>
            </div>

            <div class="tab-pane" id="ganttPlan" style="overflow:hidden;">
                <div id="gantt-container"></div>
            </div>
        </div>
    </div>

    <form id="outputTargetsContainer">
        <h4>Output Targets</h4>
        <table id="outputTargets" class="table table-condensed tight-inputs">
            <thead><tr><th>Output Type</th><th>Outcome Targets</th><th>Output Targets</th><th>Target</th></tr></thead>
            <!-- ko foreach:outputTargets -->
            <tbody data-bind="foreach:scores">
            <tr>
                <!-- ko with:isFirst -->
                <td data-bind="attr:{rowspan:$parents[1].scores.length}">
                    <b><span data-bind="text:$parents[1].name"></span></b>
                </td>
                <td data-bind="attr:{rowspan:$parents[1].scores.length}">
                    <textarea data-bind="visible:$root.canEditOutputTargets(),value:$parents[1].outcomeTarget" rows="3"
                              cols="80" style="width:90%"></textarea>
                    <span data-bind="visible:!$root.canEditOutputTargets(),text:$parents[1].outcomeTarget"></span>
                    <span class="save-indicator" data-bind="visible:$parents[1].isSaving"><r:img dir="images"
                                                                                                 file="ajax-saver.gif"
                                                                                                 alt="saving icon"/> saving</span>
                </td>
                <!-- /ko -->
                <td><span data-bind="text:scoreLabel"></span></td>
                <td>
                    <input type="text" class="input-mini" data-bind="visible:$root.canEditOutputTargets(),value:target"
                           data-validation-engine="validate[required,custom[number]]"/>
                    <span data-bind="visible:!$root.canEditOutputTargets(),text:target"></span>
                    <span data-bind="text:units"></span>
                    <span class="save-indicator" data-bind="visible:isSaving"><r:img dir="images" file="ajax-saver.gif"
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

</div>

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
<span class="save-indicator" data-bind="visible:isSaving"><r:img dir="images" file="ajax-saver.gif"
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
                itemsPerPage: 30/*,
                onItemClick: function(data) {
                    alert(data.type + ' (' + data.progress() + ')');
                },
                onAddClick: function(dt, rowId) {
                    alert("Empty space clicked - add an item!");
                },
                onRender: function() {
                    if (window.console && typeof console.log === "function") {
                        console.log("chart rendered");
                    }
                }*/
            });
        }
    }

    $(window).load(function () {

        var PlannedActivity = function (act, isFirst, project, planViewModel) {
            var self = this;
            this.activityId = act.activityId;
            this.isFirst = isFirst ? this : undefined;
            this.siteId = act.siteId;
            this.siteName = lookupSiteName(act.siteId);
            this.type = act.type;
            this.projectStage = act.projectStage;
            this.description = act.description;
            this.hasOutputs = act.outputs && act.outputs.length;
            this.startDate = ko.observable(act.startDate).extend({simpleDate:false});
            this.endDate = ko.observable(act.endDate).extend({simpleDate:false});
            this.plannedStartDate = ko.observable(act.plannedStartDate).extend({simpleDate:false});
            this.plannedEndDate = ko.observable(act.plannedEndDate).extend({simpleDate:false});
            this.progress = ko.observable(act.progress).extend({withPrevious:act.progress});
            this.isSaving = ko.observable(false);
            this.publicationStatus = act.publicationStatus ? act.publicationStatus : 'unpublished';
            this.deferReason = ko.observable(undefined); // a reason document or undefined
            // the following handles the modal dialog for deferral/cancel reasons
            this.displayReasonModal = ko.observable(false);
            this.displayReasonModal.trigger = ko.observable();
            this.displayReasonModal.needsToBeSaved = true; // prevents unnecessary saves when a change to progress is reverted
            this.displayReasonModal.closeReasonModal = function() {
                self.displayReasonModal(false);
                self.displayReasonModal.needsToBeSaved = true;
            };
            this.displayReasonModal.cancelReasonModal = function() {
                if (self.displayReasonModal.trigger() === 'progress_change') {
                    self.displayReasonModal.needsToBeSaved = false;
                    self.progress.revert();
                }
                self.displayReasonModal.closeReasonModal();
            };
            this.displayReasonModal.saveReasonDocument = function (item , event) {
                // make sure reason text has been added
                var $form = $(event.currentTarget).parents('form');
                if ($form.validationEngine('validate')) {
                    if (self.displayReasonModal.trigger() === 'progress_change') {
                        self.saveProgress({progress: self.progress(), activityId: self.activityId});
                    }
                    self.deferReason().recordOnlySave("${createLink(controller: 'proxy', action: 'documentUpdate')}/" + (self.deferReason().documentId ? self.deferReason().documentId : ''));
                    self.displayReasonModal.closeReasonModal();
                }
            };
            this.displayReasonModal.editReason = function () {
                // popup dialog for reason
                self.displayReasonModal.trigger('edit');
                self.displayReasonModal(true);
            };
            // save progress updates - with a reason document in some cases
            this.progress.subscribe(function (newValue) {
                if (!self.progress.changed()) { return; } // Cancel if value hasn't changed
                if (!self.displayReasonModal.needsToBeSaved) { return; } // Cancel if value hasn't changed

                if (newValue === 'deferred' || newValue === 'cancelled') {
                    // create a reason document if one doesn't exist
                    // NOTE that 'deferReason' role is used in both cases, ie refers to cancel reason as well
                    if (self.deferReason() === undefined) {
                        self.deferReason(new DocumentViewModel(
                            {role:'deferReason', name:'Deferred/canceled reason document'},
                            {activityId:act.activityId/*, projectId:project.projectId*/}));
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

            this.saveProgress = function(payload) {
                self.isSaving(true);
                // save new status
                $.ajax({
                    url: "${createLink(controller: 'activity', action: 'ajaxUpdate')}/" + self.activityId,
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
                        //console.log('saved progress');
                        self.isSaving(false);
                    }
                });
            };
            this.isReadOnly = ko.computed(function() {
                var isEditor = ${user?.isEditor ? 'true' : 'false'};
                return !isEditor;
            });
            this.canEditActivity = ko.computed(function () {
                return !self.isReadOnly() && planViewModel.planStatus() === 'not approved';
            });
            this.canEditOutputData = ko.computed(function () {
                return !self.isReadOnly() && planViewModel.planStatus() === 'approved';
            });
            this.canPrintActivity = ko.computed(function () {
                return true;
            });
            this.canDeleteActivity = ko.computed(function () {
                return !self.isReadOnly() && planViewModel.planStatus() === 'not approved';
            });
            this.canUpdateStatus = ko.computed(function () {
                return !self.isReadOnly() && planViewModel.planStatus() === 'approved';
            });


            this.editActivity = function () {
                var url;
                if (self.isReadOnly()) {
                    self.viewActivity(activity);
                } else if (self.canEditOutputData()) {
                    url = fcConfig.activityEnterDataUrl;
                    document.location.href = url + "/" + self.activityId +
                        "?returnTo=" + here;
                } else if (self.canEditActivity()) {
                    url = fcConfig.activityEditUrl;
                    document.location.href = url + "/" + self.activityId +
                        "?returnTo=" + here;
                }
            };
            this.viewActivity = function() {
                url = fcConfig.activityViewUrl;
                document.location.href = url + "/" + self.activityId +
                        "?returnTo=" + here;
            };
            this.printActivity = function() {
                open(fcConfig.activityPrintUrl + "/" + self.activityId, "fieldDataPrintWindow");
            };
            this.deleteActivity = function () {
                // confirm first
                bootbox.confirm("Delete this activity? Are you sure?", function(result) {
                    if (result) {
                        $.getJSON(fcConfig.activityDeleteUrl + '/' + self.activityId,
                            function (data) {
                                if (data.code < 400) {
                                    document.location.reload();
                                } else {
                                    alert("Failed to delete activity - error " + data.code);
                                }
                            });
                    }
                });
            };


            var reasonDocs = $.grep(act.documents, function(document) {
                return document.role === 'deferReason';
            });
            if (reasonDocs.length > 0) {
                self.deferReason(new DocumentViewModel(reasonDocs[0], {activityId:act.activityId/*, projectId:project.projectId*/}));
            }
            this.isApproved = function() {
                return this.publicationStatus == 'published';
            };
            this.isSubmitted = function() {
                return this.publicationStatus == 'pendingApproval';
            }
        };

        var PlanStage = function (stage, activities, planViewModel, isCurrentStage, project) {
            var stageLabel = '';

            // Note that the two $ transforms used to extract activities are not combined because we
            // want the index of the PlannedActivity to be relative to the filtered set of activities.
            var self = this,
            activitiesInThisStage = activities
            this.label = stageLabel;
            this.isCurrentStage = isCurrentStage;
            <g:if test="${enableReporting}">
                this.isReportable = stage.toDate < new Date().toISOStringNoMillis();
            </g:if>
            <g:else>
                this.isReportable = false;
            </g:else>
            this.projectId = project.projectId;
            this.planViewModel = planViewModel;

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
            this.activities = $.map(activitiesInThisStage, function (act, index) {
                act.projectStage = stageLabel;
                return new PlannedActivity(act, index === 0, project, planViewModel);
            });
            /**
             * A stage is considered to be approved when all of the activities in the stage have been marked
             * as published.
             */
            this.isApproved = ko.computed(function() {
                var numActivities = self.activities ? self.activities.length : 0;
                if (numActivities == 0) {
                    return false;
                }
                return $.grep(self.activities, function(act, i) {
                    return act.isApproved();
                }).length == numActivities;
            }, this, {deferEvaluation: true});
            this.isSubmitted = ko.computed(function() {
                var numActivities = self.activities ? self.activities.length : 0;
                if (numActivities == 0) {
                    return false;
                }
                return $.grep(self.activities, function(act, i) {
                    return act.isSubmitted();
                }).length == numActivities;
            }, this, {deferEvaluation: true});


            this.stageStatusTemplateName = ko.computed(function() {
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

        function PlanViewModel(activities, outputTargets, project) {
            var self = this;
            this.userIsCaseManager = ko.observable(${user?.isCaseManager});
            this.planStatus = ko.observable(project.planStatus || 'not approved');

            this.isApproved = ko.computed(function () {
                return (self.planStatus() === 'approved');
            });

            this.canEditOutputTargets = ko.computed(function() {
                var isEditor = ${user?.isEditor ? 'true' : 'false'};
                return isEditor && self.planStatus() === 'not approved';
            });
            //this.currentDate = ko.observable("2014-02-03T00:00:00Z"); // mechanism for testing behaviour at different dates
            this.currentDate = ko.observable(new Date().toISOStringNoMillis()); // mechanism for testing behaviour at different dates

            this.loadActivities = function (activities) {
                return new PlanStage('', activities, self, true, project)
            };
            self.activities = self.loadActivities(activities);

            self.progressOptions = ['planned','started','finished','deferred','cancelled'];
            self.newActivity = function () {
                var context = '',
                    projectId = project.projectId,
                    siteId = "${site?.siteId}",
                    returnTo = '&returnTo=' + document.location.href;
                if (projectId) {
                    context = '&projectId=' + projectId;
                } else if (siteId) {
                    context = '&siteId=' + siteId;
                }

                document.location.href = fcConfig.activityCreateUrl + '?' + context + returnTo;
            };
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
                var siteId = this.siteId;
                if (siteId !== '') {
                    document.location.href = fcConfig.siteViewUrl + '/' + siteId;
                }
            };
            self.descriptionExpanded = ko.observable(false);
            self.toggleDescriptions = function() {
                self.descriptionExpanded(!self.descriptionExpanded());
                adjustTruncations();
            };


            // Project status manipulations
            // ----------------------------
            // This has been refactored to update project status on specific actions (rather than subscribing
            //  to changes in the status) so that errors can be handled in a known context.

            // save new status and return a promise
            this.saveStatus = function (newValue) {
                var payload = {planStatus: newValue, projectId: project.projectId};
                return $.ajax({
                    url: "${createLink(action: 'ajaxUpdate')}/" + project.projectId,
                    type: 'POST',
                    data: JSON.stringify(payload),
                    contentType: 'application/json'
                });
            };
            // submit plan and handle errors
            this.editPlan = function () {
                self.saveStatus('not approved')
                .done(function (data) {
                    if (data.error) {
                        showAlert("Unable to enter planing mode. An error occurred: " + data.detail + ' \n' + data.error,
                            "alert-error","status-update-error-placeholder");
                    } else {
                        self.planStatus('approved');
                        window.location.reload();
                    }
                })
                .fail(function (data) {
                    if (data.status === 401) {
                        showAlert("Unable to submit plan. You do not have editor rights for this project.",
                            "alert-error","status-update-error-placeholder");
                    } else {
                        showAlert("Unable to submit plan. An error occurred: [" + data.status + "] " + (data.responseText || ""),
                            "alert-error","status-update-error-placeholder");
                    }
                });
            };
            this.finishedPlanning = function () {

                self.saveStatus('approved')
                .done(function (data) {
                    if (data.error) {
                        showAlert("Unable to leave planning mode. An unhandled error occurred: " + data.detail + ' \n' + data.error,
                            "alert-error","status-update-error-placeholder");
                    } else {
                        self.planStatus('approved');
                        window.location.reload();
                    }
                })
                .fail(function (data) {
                    if (data.status === 401) {
                        showAlert("Unable to leave planning mode.  You do not have administrator rights for this project.",
                            "alert-error","status-update-error-placeholder");
                    } else {

                        showAlert("Unable to leave planning mode. An error occurred: [" + data.status + "] " + (data.responseText || ""),
                            "alert-error","status-update-error-placeholder");
                    }
                });
            };

            this.submitReport = function (e) {
            console.log(e);
                //bootbox.alert("Reporting has not been enabled yet.");
                $('#declaration').modal('show');
            };

            this.getGanttData = function () {
                var values = [],
                    previousStage = '',
                    hasAnyValidPlannedEndDate = false;
                $.each([self.activities], function (i, stage) {
                    $.each(stage.activities, function (j, act) {
                        var statusClass = 'gantt-' + act.progress(),
                            startDate = act.plannedStartDate.date().getTime(),
                            endDate = act.plannedEndDate.date().getTime();
                        if (!isNaN(startDate)) {
                            values.push({
                                name:act.projectStage === previousStage ? '' : act.projectStage,
                                desc:act.type,
                                values: [{
                                    label: act.type,
                                    from: "/Date(" + startDate + ")/",
                                    to: "/Date(" + endDate + ")/",
                                    customClass: statusClass,
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
                        var project = {projectId:'${project.projectId}', outputTargets:targets};
                        var json = JSON.stringify(project);
                        var id = "${'/' + project.projectId}";
                        $.ajax({
                            url: "${createLink(action: 'ajaxUpdate')}" + id,
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

            // metadata for setting up the output targets
            self.targetMetadata = ${outputTargetMetadata as grails.converters.JSON};

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
        }
        var project = <fc:modelAsJavascript model="${project}"/>;
        var planViewModel = new PlanViewModel(
    ${activities ?: []},
            project.outputTargets || {},
            project
        );
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
