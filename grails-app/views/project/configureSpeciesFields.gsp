<%@ page import="au.org.ala.biocollect.DateUtils; grails.converters.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
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
        %{--projectUpdateUrl:"${createLink(action:'ajaxUpdate', id:project.projectId)}",--}%
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}/"
        },
        here = document.location.href;
    </r:script>
    <r:require modules="knockout,jqueryValidationEngine,speciesFieldsSettings,projectSpeciesFieldsConfiguration"/>

</head>
<body>
<div class="container-fluid validationEngineContainer" id="validation-container">
    <div id="koActivityMainBlock">
        <ul class="breadcrumb">
            <li><g:link controller="home">Home</g:link> <span class="divider">/</span></li>
            <g:if test="${project}">
                <li><a data-bind="click:goToProject" class="clickable">Project</a> <span class="divider">/</span></li>
            </g:if>
            <li class="active">Configure species fields</li>
        </ul>
        <div class="welll container">
            <div class="span5 title-attribute">
                <h2>Configuring species fields for project: <g:if test="${project}">
                    ${project.name?.encodeAsHTML()}
                </g:if></h2>

            </div>
        </div>

        <div class="row-fluid">
            <div class="span3 text-left">
                <label class="control-label"><g:message code="project.survey.species.fieldName"/>
                    <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.species.fieldName"/>', content:'<g:message code="project.survey.species.fieldName.content"/>'}">
                        <i class="icon-question-sign"></i>
                    </a>
                </label>
            </div>
            <div class="span5 text-left">
                <label class="control-label"><g:message code="project.survey.species.settings"/>
                    <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.species.settings"/>', content:'<g:message code="project.survey.species.settings.content"/>'}">
                        <i class="icon-question-sign"></i>
                    </a>
                </label>
            </div>
            <div class="span4 text-left">
                <label class="control-label"><g:message code="project.survey.species.displayAs"/>
                    <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.species.displayAs"/>', content:'<g:message code="project.survey.species.displayAs.content"/>'}">
                        <i class="icon-question-sign"></i>
                    </a>
                </label>
            </div>
        </div>
        <div class="row-fluid">
            <div class="span3 text-left">
                <span><b><g:message code="project.survey.species.defaultConfiguration"/></b>
                    <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.species.defaultConfiguration"/>', content:'<g:message code="project.survey.species.defaultConfiguration.content"/>'}">
                        <i class="icon-question-sign"></i>
                    </a>
                    <span class="right-padding"></span>
                </span>
            </div>
            <div class="span5">
                <span class="req-field">
                    <select data-validation-engine="validate[required]" data-bind="disable: true, options: species().speciesOptions, optionsText:'name', optionsValue:'id', value: species().type, optionsCaption: 'Please select'" ></select>
                </span>
                <a target="_blank" class="btn btn-link" data-bind="click: function() { showSpeciesConfiguration(species(), 'Default Configuration') }" ><small><g:message code="project.survey.species.configure"/></small></a>
            </div>
            <div class="span4 text-left">
                <select data-bind="options: transients.availableSpeciesDisplayFormat, optionsText:'name', optionsValue:'id', value:  species().speciesDisplayFormat">
                </select>
            </div>
        </div>
        %{--Specific field configuration entries if more than one species field in the form--}%
        <!-- ko  foreach: speciesFields() -->
        <div class="row-fluid">
            <div class="span3 text-left">
                <span data-bind="text: transients.fieldName "></span>
            </div>
            <div class="span5">
                <span class="req-field" data-bind="tooltip: {title:config().transients.inputSettingsTooltip()}">
                    <input type="text" class="input-large" data-bind="disable: true, value: config().transients.inputSettingsSummary"> </input>
                </span>
                <a target="_blank" data-bind="click: function() { $parent.showSpeciesConfiguration(config(), transients.fieldName, $index ) }" class="btn btn-link" ><small><g:message code="project.survey.species.configure"/></small></a>
            </div>
            <div class="span4 text-left">
                <select data-bind="options: $parent.transients.availableSpeciesDisplayFormat, optionsText:'name', optionsValue:'id', value:  config().speciesDisplayFormat">
                </select>
            </div>
        </div>
        <!-- /ko -->
    </div>

    <!-- ko stopBinding: true -->
    <div  id="speciesFieldDialog" data-bind="template: {name:'speciesFieldDialogTemplate'}"></div>
    <!-- /ko -->

    <script type="text/html" id="speciesFieldDialogTemplate">
    <g:render template="/projectActivity/speciesFieldSettingsDialog"></g:render>
    </script>



        <div class="form-actions">
            <button type="button" data-bind="click: save" class="btn btn-primary">Save changes</button>
            <button type="button" id="cancel" class="btn">Cancel</button>
        </div>


    </div>
</div>

<!-- templates -->

<r:script>

    var returnTo = "${returnTo}";

    $(function(){



        $('.helphover').popover({animation: true, trigger:'hover'});

        $('#cancel').click(function () {
            document.location.href = returnTo;
        });


        var viewModel = new ProjectSpeciesFieldsConfigurationViewModel(
            ${project ?: 'null'}
        );
        ko.applyBindings(viewModel,document.getElementById('koActivityMainBlock'));


    });

</r:script>
</body>
</html>