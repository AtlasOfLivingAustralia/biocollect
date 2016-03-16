<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<!doctype html>
<html>
<head>
    <meta name="layout" content="adminLayout"/>
    <title>Activity model - Admin - Data capture - Atlas of Living Australia</title>
    <r:require modules="knockout,a-jquery-ui,knockout_sortable,admin"/>
    <r:script disposition="head">
        var fcConfig = {
            activityModelUpdateUrl:"${createLink(action: 'updateActivitiesModel')}",
            outputDataModelUrl: "${createLink(action: 'getOutputDataModel')}"
        };
    </r:script>

</head>

<body>
<content tag="pageTitle">Activity model</content>
<content tag="adminButtonBar">
    <button type="button" data-bind="click:save" class="btn btn-success">Save</button>
    <button type="button" data-bind="click:revert" class="btn">Cancel</button>
</content>
<div class="row-fluid clearfix">
    <div class="span5">
        <h2>Activities</h2>
        <ul data-bind="sortable:{data:activities}" class="activityList sortableList">
            <li class="item" data-bind="css:{disabled:!enabled()}">
                <div data-bind="click:toggle"><span data-bind="text:name"></span></div>
                <div data-bind="visible:expanded" class="details clearfix" style="display:none;">
                    <div data-bind="template: {name: displayMode}"></div>
                </div>
            </li>
        </ul>
        <span data-bind="click:addActivity" class="clickable"><i class="icon-plus"></i> Add new</span>
    </div>
    <div class="span5 pull-right">
        <h2>Outputs</h2>
        <ul data-bind="sortable:outputs" class="sortableList">
            <li data-bind="css:{referenced: isReferenced}" class="item">
                <div data-bind="click:toggle">
                    <span data-bind="click:addToCurrentActivity, clickBubble:false, visible:isAddable" class="add-arrow clickable" title="Add output to current activity"><i class="icon-arrow-left"></i></span>
                    <span data-bind="text:name"></span>
                </div>
                <div data-bind="visible:expanded" class="details clearfix" style="display:none;">
                    <div data-bind="template: {name: displayMode}"></div>
                </div>
            </li>
        </ul>
        <span data-bind="click:addOutput" class="clickable"><i class="icon-plus"></i> Add new</span>
    </div>
</div>

<script id="viewActivityTmpl" type="text/html">
<div>Type: <span data-bind="text:type"></span></div>
<div>Category: <span data-bind="text:category"></span></div>
<div>Enabled: <span data-bind="text:enabled"></span></div>
<div>GMS ID: <span data-bind="text:gmsId"></span></div>
<div>Supports Sites: <span data-bind="text:supportsSites"></span></div>
<div>Supports Photo Points: <span data-bind="text:supportsPhotoPoints"></span></div>


<div>Outputs: <ul data-bind="foreach:outputs">
    <li><span data-bind="text:$data"></span><span data-bind="visible:$parent.outputConfigByName()[$data].optional()"> (optional)</span></li>
</ul></div>
<button data-bind="click:$root.removeActivity" type="button" class="btn btn-mini pull-right">Remove</button>
<button data-bind="click:edit" type="button" class="btn btn-mini pull-right">Edit</button>
</script>

<script id="editActivityTmpl" type="text/html">
<div style="margin-top:4px"><span class="span2">Name:</span> <input type="text" class="input-large pull-right" data-bind="value:name"></div>
<div class="clearfix"><span class="span2">Type:</span> <select data-bind="options:['Activity','Assessment','Report'],value:type" class="pull-right"></select></div>
<div class="clearfix"><span class="span2">Category:</span> <input type="text" class="input-large pull-right" data-bind="value:category"></div>
<div class="clearfix"><span class="span2">Enabled:</span><input type="checkbox" class="pull-right" data-bind="checked:enabled"></div>
<div class="clearfix"><span class="span2">GMS ID:</span> <input type="text" class="input-large pull-right" data-bind="value:gmsId"></div>
<div class="clearfix"><span class="span2">Sites?:</span><input type="checkbox" class="pull-right" data-bind="checked:supportsSites,enable:type()!='Report'"></div>
<div class="clearfix"><span class="span2">Photo points?:</span><input type="checkbox" class="pull-right" data-bind="checked:supportsPhotoPoints,enable:type()!='Report'"></div>

<div>Outputs: <ul data-bind="sortable:{data:outputs}" class="output-drop-target sortableList small">
    <li>
        <span data-bind="text:$data"></span>
        <span class="pull-right"><i data-bind="click:$parent.removeOutput" class="icon-remove"></i></span>
        <div data-bind="with:$parent.outputConfigByName()[$data]">
            <label class="checkbox">Optional? <input type="checkbox" class="pull-right" data-bind="checked:optional"></label>

            <label class="checkbox">Collapsed? <input type="checkbox" class="pull-right" data-bind="checked:collapsedByDefault"></label>
            <label>Question text if optional:</label>
            <input type="text" class="input-xlarge" data-bind="value:optionalQuestionText, disable:!optional()">
        </div>
    </li>
</ul></div>
<button data-bind="click:done" type="button" class="btn btn-mini pull-right">Done</button>
</script>

<script id="viewOutputTmpl" type="text/html">
<div>Template: <span data-bind="text:template"></span></div>
<div>Scores: <ul data-bind="foreach:scores">
    <li><span data-bind="text:label"></span> (<span data-bind="text:category"></span>), <span data-bind="text:aggregationType"></span></li>
</ul></div>
<button data-bind="click:$root.removeOutput" type="button" class="btn btn-mini pull-right">Remove</button>
<button data-bind="click:edit" type="button" class="btn btn-mini pull-right">Edit</button>
</script>

<script id="editOutputTmpl" type="text/html">
<div style="margin-top:4px"><span class="span3">Name:</span> <input type="text" class="input pull-right" data-bind="value:name"></div>
<div class="clearfix"><span class="span3">Template:</span> <input type="text" class="input pull-right" data-bind="value:template"></div>
<div>Scores: <ul data-bind="sortable:{data:scores}" class="sortableList small">
    <li>
        <div style="text-align:left;">
            Name: <select data-bind="value:compoundName,options:nameOptions"/>
            <span class="pull-right"><i data-bind="click:$parent.removeScore" class="icon-remove"></i></span>
        </div>
        <div style="text-align:left;">
            Label: <input type="text" data-bind="value:label"/>
        </div>
        <div style="text-align: left;">
            Description: <input type="text" data-bind="value:description"/>
        </div>
        <div style="text-align:left;">
            Category: <input type="text" data-bind="value:category"/>
        </div>
        <div style="text-align:left;">
            Units: <input type="text" data-bind="value:units"/>
        </div>
        <div style="text-align:left;">
            GMS ID: <input type="text" data-bind="value:gmsId"/>
        </div>

        <div style="text-align:left;">
            Aggregation:
            <select data-bind="value:aggregationType, style: { color: aggregationTypeValid() ? 'black':'red' }">
                <option value="SUM">summed</option>
                <option value="COUNT">counted</option>
                <option value="AVERAGE">averaged</option>
                <option value="HISTOGRAM">count by value</option>
                <option value="SET">list of distinct values</option>
            </select>
        </div>
        <div style="text-align:left;">
            Grouping: <input type="text" data-bind="value:groupBy"/>
        </div>
        <div style="text-align:left;">
            Filtering: <input type="text" data-bind="value:filterBy"/>
        </div>

        <div style="text-align:left;">
            Display type: <select data-bind="value:displayType">
            <option value=""></option>
            <option value="piechart">Pie chart</option>
            <option value="barchart">Bar chart</option>
        </select>
        </div>

        <div style="text-align:left;">
            Use as output target:
            <input type="checkbox" data-bind="checked:isOutputTarget"/>
        </div>
    </li>
</ul><span data-bind="click:addScore" class="clickable"><i class="icon-plus"></i> Add new</span>
</div>
<button data-bind="click:done" type="button" class="btn btn-mini pull-right">Done</button>
</script>


<r:script>
    $(function(){
        var options = {
            outputDataModelUrl: fcConfig.outputDataModelUrl,
            activityModelUpdateUrl:fcConfig.activityModelUpdateUrl
        };
        var viewModel = new ActivityModelViewModel(${activitiesModel}, options);
        ko.applyBindings(viewModel);
    });
</r:script>
</body>
</html>