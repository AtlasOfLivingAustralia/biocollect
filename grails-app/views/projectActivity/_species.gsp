<div id="pActivitySurvey">

        <!-- ko foreach: projectActivities -->

            <!-- ko if: current -->

            <div class="well">
                <div class="row-fluid">
                    <div class="span10 text-left">
                        <h2 class="strong">Step 5 of 7 - Set the range of species applicable for the survey</h2>
                    </div>
                    <div class="span2 text-right">
                        <g:render template="/projectActivity/status"/>
                    </div>
                </div>

                <g:render template="/projectActivity/warning"/>

                <div class="row-fluid">
                    <div class="span12 text-left">
                        <p><g:message code="project.survey.species.description"/></p>
                    </div>
                </div>
                </br>
                <div class="row-fluid" data-bind="visible: speciesFields().length == 0">
                    <span class="alert-success"><g:message code="project.survey.species.noSpeciesInSurvey"/></span>

                </div>

                <div class="row-fluid" data-bind="visible: speciesFields().length > 0">
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



            <div class="row-fluid">

                <div class="span12">
                    <button class="btn-primary btn block btn-small"
                            data-bind="click: $parent.saveSpecies"><i class="icon-white  icon-hdd" ></i>Save</button>
                    <button class="btn-primary btn btn-small block" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-form-tab'}"><i class="icon-white icon-chevron-left" ></i>Back</button>
                    <button class="btn-primary btn btn-small block" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-locations-tab'}">Next <i class="icon-white icon-chevron-right" ></i></button>
                </div>

            </div>

        <!-- /ko -->

        <!-- /ko -->
</div>


