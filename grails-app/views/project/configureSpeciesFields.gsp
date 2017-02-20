<%@ page import="au.org.ala.biocollect.DateUtils; grails.converters.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Configure species fields | Biocollect</title>
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
    <g:if test="${!error}">
        <div id="koActivityMainBlock">
            <ul class="breadcrumb">
                <li><g:link controller="home">Home</g:link> <span class="divider">/</span></li>
                <g:if test="${project}">
                    <li><a data-bind="click:goToProject" class="clickable">Project</a> <span class="divider">/</span></li>
                </g:if>
                <li class="active">Configure species fields</li>
            </ul>
            <div class="row-fluid">
                <div class="header-text">
                    <h2><g:if test="${project}">
                        ${project.name?.encodeAsHTML()}
                    </g:if></h2>

                </div>
            </div>

            <div class="row-fluid title-block well input-block-level">
                <div class="space-after">
                    <span>An activity has a type. If the activity type has species fields, they must be configured here.
                    It is also possible to set a species field default configuration that can be reused in each species field.</span>
                </div>
            </div>
            <div class="row-fluid">
                <div class="span1 "></div>
                <div class="span3 text-left">
                    <label class="control-label"><g:message code="project.survey.species.fieldName"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.species.fieldName"/>', content:'<g:message code="project.survey.species.fieldName.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                    </label>
                </div>
                <div class="span4 text-left">
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
                    <b><g:message code="project.survey.species.defaultConfiguration"/></b>
                    <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.species.defaultConfiguration"/>', content:'<g:message code="project.survey.species.defaultConfiguration.content"/>'}">
                        <i class="icon-question-sign"></i>
                    </a>
                </div>
            </div>
            <div class="row-fluid">
                <div class="span1 "></div>
                <div class="span3 text-left">
                </div>
                <div class="span4">
                    <span class="req-field" data-bind="tooltip: {title:species().transients.inputSettingsTooltip()}">
                        <input type="text" class="input-large" data-bind="disable: true, value: species().transients.inputSettingsSummary"> </input>
                    </span>
                    <a target="_blank" class="btn btn-link" data-bind="click: function() { showSpeciesConfiguration(species(), 'Default Configuration') }" ><small><g:message code="project.survey.species.configure"/></small></a>
                </div>
                <div class="span4 text-left">
                    <select data-bind="options: transients.availableSpeciesDisplayFormat, optionsText:'name', optionsValue:'id', value:  species().speciesDisplayFormat">
                    </select>
                </div>
            </div>


                <!-- ko  foreach: surveysToConfigure() -->
                    <div class="row-fluid">
                        <div class="span3 text-left">
                            <label>Activity Type: <b data-bind="text: name() "></b></label>
                        </div>
                    </div>
                    %{--Specific field configuration entries if more than one species field in the form--}%

                    <!-- ko  foreach: speciesFields() -->
                    <div class="row-fluid">
                        <div class="span1 "></div>
                        <div class="span3 text-left">
                            <span data-bind="text: transients.fieldName "></span>
                        </div>
                        <div class="span4">
                            <span class="req-field" data-bind="tooltip: {title:config().transients.inputSettingsTooltip()}">
                                <input type="text" class="input-large" data-bind="disable: true, value: config().transients.inputSettingsSummary"> </input>
                            </span>
                            <a target="_blank" data-bind="click: function() { $root.showSpeciesConfiguration(config(), transients.fieldName, $parentContext.$index, $index ) }" class="btn btn-link" ><small><g:message code="project.survey.species.configure"/></small></a>
                        </div>
                        <div class="span4 text-left">
                            <select data-bind="disable: config().type() == 'DEFAULT_SPECIES', options: $root.transients.availableSpeciesDisplayFormat, optionsText:'name', optionsValue:'id', value:  config().transients.dependableSpeciesDisplayFormat">
                            </select>
                        </div>
                    </div>
                    <!-- /ko -->
                <!-- /ko -->
                <!-- ko if: surveysWithoutFields().length > 0 -->
                    <div class="row-fluid">
                        <h4>Activity types with no species fields</h4>
                        <ul>
                        <!-- ko  foreach: surveysWithoutFields() -->
                        <li>
                            <span data-bind="text: name()"></span>
                        </li>
                        <!-- /ko -->
                        </ul>
                    </div>
                <!-- /ko -->
            </div>
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
    </g:if>
    <g:else>
        <div class="welll container">
            <div class="span5 title-attribute">
                <h2>${error?.encodeAsHTML()}</h2>
            </div>
        </div>
    </g:else>
    <g:if env="development">
        <hr/>
        <div class="expandable-debug">
            <h3>Debug</h3>
            <div>
                <!--h4>KO model</h4>
            <pre data-bind="text:ko.toJSON($root,null,2)"></pre-->
                <h4>Fields Config</h4>
                <pre>${fieldsConfig}</pre>
                <h4>Project</h4>
                %{--<pre>${project}</pre>--}%
            </div>
        </div>
    </g:if>
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
        <fc:modelAsJavascript model="${project}" />,
        <fc:modelAsJavascript model="${fieldsConfig}"/>
        );

        ko.applyBindings(viewModel,document.getElementById('koActivityMainBlock'));


    });

</r:script>
</body>
</html>