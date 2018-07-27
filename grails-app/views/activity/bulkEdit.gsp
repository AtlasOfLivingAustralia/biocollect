<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Create | Activity | Field Capture</title>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'project', action: 'index')}/${activity.projectId},Project"/>
    <meta name="breadcrumb" content="${title}"/>
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <asset:script type="text/javascript">
    var fcConfig = {
        organisationViewUrl: "${createLink(controller: 'organisation', action: 'index', id: organisation.organisationId)}",
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        projectViewUrl: "${createLink(controller: 'project', action: 'index')}/",
        saveUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}/",
        returnTo: "${params.returnTo}"
        },
        here = document.location.href;
    </asset:script>
    <asset:javascript src="common.js" />
    <asset:javascript src="forms-manifest.js" />
    <style type="text/css">
    input.editor-text {
        box-sizing: border-box;
        width: 100%;
    }

    .slick-column-name {
        white-space: normal;
    }

    .slick-header-column.ui-state-default {
        background: #DAE0B9;
        height: 100%;
        font-weight: bold;
    }

    .slick-header {
        background: #DAE0B9;
    }

    input[type=checkbox].progress-checkbox {
        margin-left: 10px;
        margin-right: 10px;
    }

    .finish-all-container {
        position: absolute;
        font-weight: normal;
        bottom: 0;
        padding-top: 5px;
        padding-bottom: 5px;
        border-top: 1px solid silver
    }

    .finish-all-container input[type='checkbox'] {
        margin-bottom: 5px;
    }

    </style>
    <g:set var="thisPage" value="${g.createLink(absolute: true, action: 'report', params: params)}"/>
    <g:set var="loginUrl"
           value="${grailsApplication.config.security.cas.loginUrl ?: 'https://auth.ala.org.au/cas/login'}?service=${thisPage.encodeAsURL()}"/>
</head>

<body>

<div class="container-fluid">
    <div class="row-fluid">
        <h2>${title}</h2>
    </div>

    <div class="instructions well">
        Each row of the table below allows the monthly status report for a single project to be completed.  Not all projects need to be edited at once.  If you would prefer to edit the report for an individual project, click the link in the "Project column".  When you are finished, press the save button.
    </div>

    <div id="load-xlsx-result-placeholder"></div>
    <g:render template="/shared/restoredData" model="[id: 'restoredData', cancelButton: 'Cancel']"/>


    <div class="row-fluid">
        <span class="span12">
            <div id="myGrid" class="validationEngineContainer" style="width:100%;"></div>
        </span>
    </div>


    <div class="row-fluid">

        <div class="form-actions">
            <span class="span3">
                <button type="button" id="bulkUploadTrigger" class="btn btn-small"><i
                        class="icon-upload"></i> Upload data for this table</button>

                <div id="bulkUpload" style="display:none;">
                    <div class="text-left" style="margin:5px">
                        <a target="_blank" id="downloadTemplate"
                           class="btn btn-small">Step 1 - Download template (.xlsx)</a>
                    </div>

                    <div class="text-left" style="margin:5px">
                        <span class="btn btn-small fileinput-button">
                            Step 2 - Upload populated template <input id="fileupload" type="file" name="templateFile">
                        </span>
                    </div>
                </div>
            </span>
            <span class="span9" style="text-align:right">
                <button type="button" id="save" class="btn btn-primary"
                        title="Save edits and return to the previous page">Save</button>
                <buttom type="button" id="cancel" class="btn btn"
                        title="Cancel edits and return to previous page">Cancel</buttom>
            </span>
        </div>
    </div>

</div>

<g:render template="/shared/timeoutMessage" model="${[url: loginUrl]}"/>

<asset:script type="text/javascript">

    $(function () {
    // Override the behaviour of the default to prevent spurious focus events from triggering change dection (as the value changes from 0 to "0")
    function orZero(val) {
        return val || "0";
    }
    <g:each in="${outputModels}" var="outputModel">
    <g:if test="${outputModel.name != 'Photo Points'}">
        <g:set var="blockId" value="${fc.toSingleWord([name: outputModel.name])}"/>
        <g:set var="model" value="${outputModel.dataModel}"/>

        var viewModelName = "${blockId}ViewModel",
                viewModelInstance = viewModelName + "Instance";
                //load dynamic models - usually objects in a list
        <md:jsModelObjects model="${model}" site="${site}" speciesLists="${speciesLists}" edit="true"
                           viewModelInstance="${blockId}ViewModelInstance"/>

        this[viewModelName] = function (output) {
            var self = this;
            self.name = "${outputModel.name}";
                self.outputId = orBlank(output.outputId);

                self.data = {};
                self.transients = {};
                self.transients.dummy = ko.observable();

                // add declarations for dynamic data
        <md:jsViewModel model="${model}" output="${outputModel.name}" edit="true"
                        viewModelInstance="${blockId}ViewModelInstance" readonly="${false}" surveyName="${surveyName}"/>

        // this will be called when generating a savable model to remove transient properties
        self.removeBeforeSave = function (jsData) {
            // add code to remove any transients added by the dynamic tags
        <md:jsRemoveBeforeSave model="${model}"/>
        delete jsData.activityType;
        delete jsData.transients;
        return jsData;
    };

// this returns a JS object ready for saving
self.modelForSaving = function () {
    // get model as a plain javascript object
    var jsData = ko.mapping.toJS(self, {'ignore':['transients']});
    // get rid of any transient observables
    return self.removeBeforeSave(jsData);
};

// this is a version of toJSON that just returns the model as it will be saved
// it is used for detecting when the model is modified (in a way that should invoke a save)
// the ko.toJSON conversion is preserved so we can use it to view the active model for debugging
self.modelAsJSON = function () {
    return JSON.stringify(self.modelForSaving());
};

self.loadData = function (data) {// load dynamic data
        <md:jsLoadModel model="${model}"/>

        // if there is no data in tables then add an empty row for the user to add data
        if (typeof self.addRow === 'function' && self.rowCount() === 0) {
            self.addRow();
        }
        self.transients.dummy.notifySubscribers();
    };

    if (output && output.data) {
        self.loadData(output.data);
    }
    self.dirtyFlag = ko.dirtyFlag(self, false);
};
    </g:if>
</g:each>

    var activityLinkFormatter = function( row, cell, value, columnDef, dataContext ) {
        return '<a title="'+dataContext.projectName+'" target="project"
                       href="'+fcConfig.projectViewUrl+dataContext.projectId+'">'+value+'</a>';
        };

        var activities = <fc:modelAsJavascript model="${activities}"/>;
        var outputModels = <fc:modelAsJavascript model="${outputModels}"/>;

        var top = this;

        var activityModels = [];
        var ActivityViewModel = function(activity) {
            var self = this;
            var savedData = amplify.store('activity-'+activity.activityId);
            if (savedData) {
                savedData = $.parseJSON(savedData);
            }

            $.extend(self, activity);
            self.outputModels = [];
            var progress = activity.progress;
            if (savedData) {
                progress = savedData.progress;
            }
            self.progress = ko.observable(progress);

            $.each(outputModels, function(i, outputModel) {

                var viewModelName = outputModel.name.replace(/ /g , '_')+'ViewModel';

                // Check for locally saved data for this output - this will happen in the event of a session timeout
                // for example.
                var savedOutput = null;
                if (savedData) {
                    $('#restoredData').show();

                    $.each(savedData.outputs, function(i, tmpOutput) {
                        if (tmpOutput.name === outputModel.name) {
                            savedOutput = tmpOutput;
                        }
                    });
                }

                // If there is no locally saved data, use server supplied data.
                if (!savedOutput && activity.outputs) {

                    var result = $.grep(activity.outputs, function(output) {
                        return output.name == outputModel.name;
                    });
                    if (result && result[0]) {
                        savedOutput = result[0];
                    }
                }
                self.outputModels.push(new top[viewModelName](savedOutput || {data:{}}));

            });

            self.isDirty = ko.computed(function() {
                if (savedData || self.progress() != activity.progress) {
                    return true;
                }
                var dirty = false;
                $.each(self.outputModels, function(i, outputModel) {
                    if (outputModel.dirtyFlag.isDirty()) {
                        dirty = true;

                        return false;
                    }
                });
                return dirty;
            });

            self.isDirty.subscribe(function(dirty) {

                if (self.progress() == 'planned') {
                    if (dirty) {
                        self.progress('started');
                    }
                    else {
                        self.progress('planned');
                    }
                }
            });

            self.saving = ko.observable(false);

            self.modelForSaving = function() {
                var outputData = [];
                var activityForSaving = {outputs:outputData, progress:self.progress(), activityId:activity.activityId};
                $.each(self.outputModels, function(i, outputModel) {
                    if (outputModel.dirtyFlag.isDirty()) {
                        outputData.push(outputModel.modelForSaving());
                    }
                });
                return activityForSaving;
            };

            self.modelAsJSON = function() {
                return JSON.stringify(self.modelForSaving());
            };

        };

        $.each(activities, function(i, activity) {
            var model = new ActivityViewModel(activity);
            var url = fcConfig.saveUrl+'/'+activity.activityId;
            autoSaveModel(model, url, {storageKey:'activity-'+activity.activityId});
            activityModels.push(model);
        });

        var columns = [];
        $.each(outputModels, function(i, outputModel) {
            $.each(outputModel.annotatedModel, function(i, dataItem) {

                if (dataItem.computed) {
                    return;
                }
                var columnHeader = dataItem.shortDescription ? dataItem.shortDescription : dataItem.label ? dataItem.label : dataItem.name;
                if (dataItem.description) {
                    columnHeader += helpHover(dataItem.description);
                }

                var editor = OutputValueEditor;
                if (dataItem.constraints) {
                    editor = OutputSelectEditor;
                }
                else if (dataItem.viewType == 'textarea') {
                    editor = LongTextEditor;
                }
                else if (dataItem.type == 'boolean') {
                    editor = CheckBoxEditor;
                }

                var column = {
                    id: dataItem.name,
                    name: columnHeader,
                    field: dataItem.name,
                    outputName:outputModel.name,
                    options:dataItem.constraints,
                    editor:editor,
                    cssClass:'text-center'
                };
                if (dataItem.validate) {
                    column.validationRules = 'validate['+dataItem.validate+']';
                }
                columns.push(column);
            });
        });
        var disableNavigationHook = false;
        window.addEventListener("beforeunload", function (e) {
            var dirty = false;
            $.each(activityModels, function(i, model) {
                if (model.isDirty()) {
                    dirty = true;
                    return;
                }
            });
            if (!disableNavigationHook & dirty) {
                var confirmationMessage = "You have unsaved edits";

                (e || window.event).returnValue = confirmationMessage;
                return confirmationMessage;
            }
        });


        var slickGridOptions = {
            editable: true,
            enableCellNavigation: true,
            dataItemColumnValueExtractor: outputValueExtractor,
            forceFitColumns: true,
            autoHeight:true,
            topPanelHeight: 25,
            explicitInitialization:true
        };

        // Add the project columns
        var projectColumn = {name:'Project', id:'projectName', field:'grantId', formatter:activityLinkFormatter, minWidth:100};
        var progressColumn = {name:'Finished?:'+helpHover('Check the checkbox when you have finished entering data for this project'), id:'progress', field:'progress', formatter:progressFormatter, editor:ProgressEditor};

        columns = [projectColumn].concat(columns, progressColumn);

        var dataView = new Slick.Data.DataView();
        var grid = new Slick.Grid("#myGrid", dataView, columns, slickGridOptions);

        // Focus the first editable cell that doesn't contain a popup editor.
        var highlightColumn = 0;
        for (var i=0; i<columns.length; i++) {
            if (columns[i].editor === OutputValueEditor) {
                highlightColumn = i;
                break;
            }
        }

        // Allow single click changes to progress values.
        grid.onClick.subscribe (function (e, args) {
            if ($(e.target).is('.progress-checkbox')) {
                var progress = activityModels[args.row].progress();
                var newProgress = progress != 'finished' ? 'finished' : 'started';
                activityModels[args.row].progress(newProgress);
            }
        });

        var $finishAll = $('<input type="checkbox" class="progress-checkbox" name="finishAll">');
        $finishAll.change(function(event) {
            Slick.GlobalEditorLock.commitCurrentEdit();
            var changedRows = [];
            var finish = $(event.target).is(':checked');
            $.each(activityModels, function(i, activity) {

                if (finish && activity.progress() == 'started') {
                    activity.progress('finished');
                    changedRows.push(i);
                }
                else if (!finish && activity.progress() == 'finished') {
                    activity.progress('started');
                    changedRows.push(i);
                }
            });
            grid.invalidateRows(changedRows);
            grid.render();
        });

        grid.onHeaderCellRendered.subscribe(function(e, args) {

            var column = args.column;
            if (column.id == 'progress') {
                var header = args.node;
                var rowHeight = $(header).parent().height();
                var containerHeight =$(header).outerHeight();
                var $container = $("<div></div>").height(rowHeight-containerHeight);
                var $inputContainer = $('<span class="finish-all-container"></span>');
                $container.appendTo(header);
                $container.css('position', 'relative');
                $inputContainer.append($finishAll).append($('<span>Finish '+helpHover('Finish all started project reports')+'</span>'));
                $inputContainer.appendTo($container);
            }

        });

        // wire up model events to drive the grid
        dataView.onRowCountChanged.subscribe(function (e, args) {
          grid.updateRowCount();
          grid.render();
        });
        dataView.onRowsChanged.subscribe(function (e, args) {
          grid.invalidateRows(args.rows);
          grid.render();
        });
        // Feed the data into the dataview
        dataView.setItems(activityModels);

        grid.init();

        $('.slick-cell.r'+highlightColumn)[0].click();

        $('#save').click(function() {

            Slick.GlobalEditorLock.commitCurrentEdit();
            var valid = true;
            var unblock = true;
            blockUIWithMessage("Saving report...");
            var pendingSaves = [];
            $.each(activityModels, function(i, activity) {
                if (activity.isDirty()) {

                    activity.row = i;

                    valid = valid && validate(grid, activity, outputModels);
                    activity.saving(true);
                    grid.invalidateRow(i);
                    grid.render();

                    var promise = activity.saveWithErrorDetection();
                    promise.always(function() {
                        activity.saving(false);
                        grid.invalidateRow(i);
                        grid.render();
                    });

                    pendingSaves.push(promise);
                }
            });
            $.when.apply($, pendingSaves).done(function() {
                if (valid) {
                    $('#validationError').hide();
                    if (pendingSaves.length ==0) {
                        alert('Nothing to save.');
                    }
                    else {
                        disableNavigationHook = true;
                        unblock = false;
                        document.location.href = fcConfig.returnTo;
                    }
                }
                else {
                    $('#validationError').show();
                }

            }).always(function() {
                if (unblock) {
                    $.unblockUI();
                }
            });
        });

        $('#cancel').click(function() {
            disableNavigationHook = true; // Disable the before unload event handler.
            $.each(activityModels, function(i, model) {
                amplify.store('activity-'+model.activityId, null);
            });
            window.location = fcConfig.returnTo;
        });

        // Slickgrid / jqueryValidationEngine integration for some amount of user experience consistency.
        $('.validationEngineContainer').validationEngine({scroll:false});
        $('.helphover').popover({animation: true, trigger:'hover'});

        $('#downloadTemplate').click(function() {
            var ids = []
            $.each(activities, function(i, activity) {
                ids.push(activity.activityId);
            });
            //var url = "${createLink(controller: 'proxy', action: 'excelBulkActivityTemplate')}?id=${organisation.organisationId}&type=${type}&ids="+ids.toString();
            //window.open(url,"_blank");
            var url = "${createLink(controller: 'proxy', action: 'excelBulkActivityTemplate')}";
            $.fileDownload(url, { httpMethod : "POST", data: { ids : ids.toString(), type : "${type}" }});
        });

        // Hacky slickgrid / jqueryValidationEngine integration for some amount of user experience consistency.
        $('.slick-row').addClass('validationEngineContainer').validationEngine({scroll:false});

        var updateGrid = function(ajaxData){
            $.each(activityModels, function(i, act){
                if(ajaxData[i]){
                    var keys = Object.keys(ajaxData[i]).filter(function(f) {
	                    return f != "grantId" && f != "projectName"
                    });
                    $.each(act.outputModels, function (j, output){
                        $.each(keys, function(k, key){
                            if(ajaxData[i][key]){
                                output.data[key](ajaxData[i][key]);
                            }
                        });
                    });
                    dataView.updateItem(act.id, act);
                }
            });

        };

        var url = "${createLink(controller: 'activity', action: 'ajaxBulkUpload')}";
        $('#fileupload').fileupload({
            url: url,
            dataType: 'json',
            done: function (e, data) {
                if(data.result.status == 200) {
                    updateGrid(data.result.data);
                    showAlert("Successfully populated the table with xlsx template data.","alert-success","load-xlsx-result-placeholder");
                }
                else if(data.result.status == 400) {
                    showAlert("Error: " + data.result.status.error, "alert-error","load-xlsx-result-placeholder");
                }
            },
            fail: function (e, data) {
                var message = 'Please contact MERIT support and attach your spreadsheet to help us resolve the problem';
                showAlert(message, "alert-error","load-xlsx-result-placeholder");
            },
            formData: {type:"${type}"}
        });

        $("#bulkUploadTrigger").click(function(){
             $("#bulkUpload").toggle();
        });
    });

</asset:script>

</body>
</html>