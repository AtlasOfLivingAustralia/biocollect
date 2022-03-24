<div id="pActivitySurvey">

    <!-- ko foreach: projectActivities -->

    <!-- ko if: current -->

    <div class="row mt-4">
        <div class="col-12">
            <h5 class="d-inline">Step 5 of 7 - Set the range of species applicable for the survey</h5>
            <g:render template="/projectActivity/status"/>
        </div>
    </div>

    <g:render template="/projectActivity/warning"/>

    <div class="row">
        <div class="col-12">
            <p><g:message code="project.survey.species.description"/></p>
        </div>
    </div>

    <div class="row mt-2" data-bind="visible: speciesFields().length == 0">
        <span class="alert-success"><g:message code="project.survey.species.noSpeciesInSurvey"/></span>
    </div>

    <div class="table-responsive">
        <table class="not-stacked-table w-100" data-bind="visible: speciesFields().length > 0">
            <thead>
                <tr>
                <td>
                        <g:message code="project.survey.species.fieldName"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                code="project.survey.species.fieldName"/>', content:'<g:message
                                code="project.survey.species.fieldName.content"/>'}">
                            <i class="fas fa-info-circle"></i>
                        </a>
                </td>
                <td>
                        <g:message code="project.survey.species.settings"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                code="project.survey.species.settings"/>', content:'<g:message
                                code="project.survey.species.settings.content"/>'}">
                            <i class="fas fa-info-circle"></i>
                        </a>
                </td>
                <td>
                        <g:message code="project.survey.species.displayAs"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                code="project.survey.species.displayAs"/>', content:'<g:message
                                code="project.survey.species.displayAs.content"/>'}">
                            <i class="fas fa-info-circle"></i>
                        </a>
                </td>
            </tr>
            </thead>
            %{--Specific field configuration entries if more than one species field in the form--}%
            <tbody>
                <!-- ko  foreach: speciesFields() -->
                <tr>
                    <td>
                        <span data-bind="text: transients.fieldName "></span>
                    </td>
                    <td>
                        <span class="req-field" data-bind="tooltip: {title:config().transients.inputSettingsTooltip()}">
                            <input type="text" class="input-large"
                                   data-bind="disable: true, value: config().transients.inputSettingsSummary"></input>
                        </span>
                        <a target="_blank"
                           data-bind="click: function() { $parent.showSpeciesConfiguration(config(), transients.fieldName, $index ) }"
                           class="btn btn-sm btn-primary-dark"><small><i class="fas fa-cog"></i> <g:message code="project.survey.species.configure"/></small></a>
                    </td>
                    <td>
                        <select class="form-control" data-bind="options: $parent.transients.availableSpeciesDisplayFormat, optionsText:'name', optionsValue:'id', value:  config().speciesDisplayFormat">
                        </select>
                    </td>
                </tr>
                <!-- /ko -->
            </tbody>
        </table>
    </div>
    <!-- ko stopBinding: true -->
    <div id="speciesFieldDialog" data-bind="template: {name:'speciesFieldDialogTemplate'}"></div>
    <!-- /ko -->

    <script type="text/html" id="speciesFieldDialogTemplate">
    <g:render template="/projectActivity/speciesFieldSettingsDialog"></g:render>
    </script>


    <div class="row mt-2">

        <div class="col-12">
            <button class="btn-primary-dark btn btn-sm"
                    data-bind="click: $parent.saveForm"><i class="fas fa-hdd"></i> Save</button>
            <button class="btn-dark btn btn-sm" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-form-tab'}"><i
                    class="far fa-arrow-alt-circle-left"></i> Back</button>
            <button class="btn-dark btn btn-sm"
                    data-bind="showTabOrRedirect: {url:'', tabId: '#survey-locations-tab'}"><i
                    class="far fa-arrow-alt-circle-right"></i> Next</button>
        </div>

    </div>

    <!-- /ko -->

    <!-- /ko -->
</div>


