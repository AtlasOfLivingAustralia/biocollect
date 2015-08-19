<div class="row-fluid">
    <div class="control-group">
        <label for="name" class="control-label">Project name</label>
        <div class="controls">
            <input type="text" class="input-xxlarge" id="name" data-bind="value: name"
                   data-validation-engine="validate[required]"/>
        </div>
    </div>
</div>
<div class="row-fluid">
    <div class="control-group span5">
        <label class="control-label">Choose an organisation</label>
        <select class="input-xlarge" id="organisation"
                data-bind="options:transients.organisations, optionsText:'name', optionsValue:'organisationId', value:organisationId, optionsCaption: 'Choose...'"></select>
    </div>
    <div class="control-group span6">
        <label class="control-label">Organisation name</label>
        <input class="input-xlarge" readonly="readonly" data-bind="value:organisationName" id="organisationName"/>
    </div>
</div>
<div class="row-fluid">
    <div class="control-group span5">
        <label class="control-label">Service provider organisation name</label>
        <input class="input-xlarge" data-bind="value:serviceProviderName" id="serviceProviderName"/>
    </div>
</div>
<div class="row-fluid">
    <div class="control-group">
        <label for="description" class="control-label">Project description</label>
        <div class="controls">
            <textarea data-bind="value:description" class="input-xxlarge" id="description" rows="3" cols="50"></textarea>
        </div>
    </div>
</div>
<div class="row-fluid">
    <div class="control-group span4">
        <label class="control-label" for="externalId">External id</label>
        <div class="controls">
            <g:textField class="" name="externalId" data-bind="value:externalId"/>
        </div>
    </div>
    <div class="control-group span4">
        <label class="control-label" for="grantId">Grant id</label>
        <div class="controls">
            <g:textField class="" name="grantId" data-bind="value:grantId"/>
        </div>
    </div>
    <div class="control-group span4">
        <label class="control-label" for="workOrderId">Work order id</label>
        <div class="controls">
            <g:textField class="" name="workOrderId" data-bind="value:workOrderId"/>
        </div>
    </div>

</div>

<div class="row-fluid">
    <div class="control-group span4">
        <label class="control-label" for="manager">Project manager</label>
        <div class="controls">
            <g:textField class="" name="manager" data-bind="value:manager"/>
        </div>
    </div>

    <div class="control-group span4">
        <label class="control-label" for="manager">Project funding</label>
        <div class="controls">
            <g:textField class="" name="funding" data-bind="value:funding" data-validation-engine="validate[custom[number]]"/>
        </div>
    </div>

</div>

<div class="alert alert-block">Be careful if you are considering changing the programme, project dates or regenerating the timeline for a project with approved stages.</div>

<div class="row-fluid">
    <div class="span4">
        <label class="control-label">Programme name</label>
        <select data-bind="value:associatedProgram,options:transients.programs,optionsCaption: 'Choose...'"
                data-validation-engine="validate[required]"></select>
    </div>
    <div class="span4">
        <label class="control-label">Sub-programme name</label>
        <select data-bind="value:associatedSubProgram,options:transients.subprogramsToDisplay,optionsCaption: 'Choose...'"></select>
    </div>
</div>

<div class="row-fluid">
    <div class="span4">
        <label for="startDate">Planned start date
        <fc:iconHelp title="Start date">Date the project is intended to commence.</fc:iconHelp>
        </label>
        <div class="input-append">
            <fc:datePicker targetField="plannedStartDate.date" name="startDate" data-validation-engine="validate[required]" printable="${printView}" size="input-large"/>
        </div>
    </div>
    <div class="span4">
        <label for="endDate">Planned end date
        <fc:iconHelp title="End date">Date the project is intended to finish.</fc:iconHelp>
        </label>
        <div class="input-append">
            <fc:datePicker targetField="plannedEndDate.date" name="endDate" data-validation-engine="validate[future[startDate]]" printable="${printView}" size="input-large"/>
        </div>

    </div>
    <div class="span1">
        OR
    </div>
    <div class="span3">
        <label for="duration">Duration (weeks)
        <fc:iconHelp title="Duration">The number of weeks the project will run for.</fc:iconHelp>
        </label>
        <div class="input-append">
            <g:textField class="" name="duration" data-bind="value:transients.plannedDuration" data-validation-engine="validate[custom[number]]"/>
        </div>

    </div>
</div>

<div class="row-fluid">
    <div class="span4">
        <label for="contractStartDate">Contract start date
        <fc:iconHelp title="Contract Start date">Contracted start date.</fc:iconHelp>
        </label>
        <div class="input-append">
            <fc:datePicker targetField="contractStartDate.date" name="contractStartDate" printable="${printView}" size="input-large"/>
        </div>
    </div>
    <div class="span4">
        <label for="endDate">Contract end date
        <fc:iconHelp title="Contract End date">Date the project is contracted to finish.</fc:iconHelp>
        </label>
        <div class="input-append">
            <fc:datePicker targetField="contractEndDate.date" name="contractEndDate" data-validation-engine="validate[future[contractStartDate]]" printable="${printView}" size="input-large"/>
        </div>

    </div>
    <div class="span1">
        OR
    </div>
    <div class="span3">
        <label for="duration">Duration (weeks)
        <fc:iconHelp title="Duration">The number of weeks the project will run for.</fc:iconHelp>
        </label>
        <div class="input-append">
            <g:textField class="" name="duration" data-bind="value:transients.contractDuration" data-validation-engine="validate[custom[number]]"/>
        </div>

    </div>
</div>

<div class="row-fluid">
    <div class="span4">
        <label>Project status
        	<fc:iconHelp title="Project status">Project status.</fc:iconHelp>
        </label>
        <select class="input-xlarge" id="projectState" data-bind="options:projectStatus, optionsText: 'name', optionsValue: 'id', value:status"></select>
    </div>
    <div class="span4">

    </div>
</div>


<div class="row-fluid">
    <span class="span6">
        <label for="regenerateProjectTimeline">Re-calculate the project stage dates? (This page must be reloaded before the change will be visible)</label>
        <fc:iconHelp title="Timeline">Selecting the checkbox will result in the project stage start and end dates being adjusted to match the new project dates.</fc:iconHelp>
        <input id="regenerateProjectTimeline" type="checkbox" data-bind="checked:regenerateProjectTimeline">
    </span>
</div>

<div class="form-actions">
    <button type="button" data-bind="click: saveSettings" class="btn btn-primary">Save changes</button>
    <button type="button" id="cancel" class="btn">Cancel</button>
</div>
