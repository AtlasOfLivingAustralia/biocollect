<g:set bean="settingService" var="settingService"></g:set>
<div id="configureSpeciesFieldModal" class="species-modal fade" role="dialog">
    <div class="species-modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-bind="click:cancel">&times;</button>
                <h4 class="modal-title">Configure <span
                        data-bind="visible: transients.fieldName, text: transients.fieldName()"></span></h4>

                <div id="species-dialog-alert-placeholder"></div>
            </div>

            <div class="modal-main">
                <div class="species-modal-body">
                    <div class="row-fluid">
                        <div class="span12">
                            <div class="controls">
                                <h5>Step 1. Constrain species available for selection</h5>
                                <span class="req-field">
                                    <select data-validation-engine="validate[required]"
                                            data-prompt-position="centerRight"
                                            data-bind="options: speciesOptions, optionsText:'name', optionsValue:'id', value: type, optionsCaption: 'Please select'"></select>
                                </span>
                            </div>

                            <g:if test="${settingService.getSettingText(au.org.ala.biocollect.merit.SettingPageType.SURVEY_SPECIES_ALL)}">
                                <div class="alert alert-info" data-bind="visible: type()">
                                    <div data-bind="visible: type() == 'ALL_SPECIES'">
                                        <fc:getSettingContent
                                                settingType="${au.org.ala.biocollect.merit.SettingPageType.SURVEY_SPECIES_ALL}"/>
                                    </div>

                                    <div data-bind="visible: singleInfoVisible">
                                        <fc:getSettingContent
                                                settingType="${au.org.ala.biocollect.merit.SettingPageType.SURVEY_SPECIES_SINGLE}"/>
                                    </div>

                                    <div data-bind="visible: groupInfoVisible">
                                        <fc:getSettingContent
                                                settingType="${au.org.ala.biocollect.merit.SettingPageType.SURVEY_SPECIES_GROUP}"/>
                                    </div>

                                    <div data-bind="visible: type() == 'DEFAULT_SPECIES'">
                                        <fc:getSettingContent
                                                settingType="${au.org.ala.biocollect.merit.SettingPageType.SURVEY_DEFAULT}"/>
                                    </div>
                                </div>
                            </g:if>

                            <div data-bind="visible: groupInfoVisible">
                                <h5>Step 2. Create or select species list</h5>

                                <div class="btn-group">
                                    <button class="btn btn-xs btn-small btn-default"
                                            data-bind="click: transients.toggleShowExistingSpeciesLists">Choose from existing species lists</button>
                                    <button class="btn btn-xs btn-small btn-default" target="blank"
                                            data-bind="click: transients.toggleShowAddSpeciesLists">Create new species lists</button>
                                </div>
                            </div>

                            <div data-bind="visible: singleInfoVisible" class="margin-top-10">
                                <h5>Step 2. Search and select a species below</h5>

                                <div class="row-fluid">
                                    <div class="span6">
                                        <span class="req-field">
                                            <input class="input-xlarge" type="text" placeholder="Search species"
                                                   data-bind="value:singleSpecies.name,
                                                    event:{focusout: singleSpecies.focusLost},
                                                    fusedAutocomplete:{
                                                        source: transients.bioSearch,
                                                        name: singleSpecies.transients.name,
                                                        guid: singleSpecies.transients.guid,
                                                        scientificName: singleSpecies.transients.scientificName,
                                                        commonName: singleSpecies.transients.commonName
                                                    }" data-validation-engine="validate[required]">
                                        </span>
                                    </div>

                                    <div class="span6">
                                        <span data-bind="visible: singleSpecies.transients.guid">
                                            <a data-bind="attr:{href: transients.bioProfileUrl}" target="_blank"><small
                                                    data-bind="text:  singleSpecies.transients.name"></small></a>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div data-bind="visible: groupInfoVisible, if: speciesLists().length == 0">
                        <h5><span class="req-field">No lists selected</span></h5>
                    </div>

                    <div class="row-fluid" data-bind="slideVisible: groupInfoVisible, if: speciesLists().length > 0">
                        <h5>Step 3. Construct species name using the following columns</h5>
                        <label class="inline">Scientific name is associated with column <select
                                data-bind="options: commonFields, value: scientificNameField, valueAllowUnset: true"></select>
                        </label>
                        <label class="inline">Common name is associated with column <select
                                data-bind="options: commonFields, value: commonNameField, valueAllowUnset: true"></select>
                        </label>

                        <h5><span class="req-field">Selected lists</span></h5>
                        <ol>
                            <!-- ko foreach: speciesLists -->
                            <li>
                                <a class="btn-link" target="_blank"
                                   data-bind="attr:{href: transients.url, title: listName }">
                                    <small data-bind="text: transients.truncatedListName"></small>
                                </a>
                                <button data-bind="click: $parent.removeSpeciesLists"
                                        class="btn btn-link"><small>&times;</small></button>
                            </li>
                            <!-- /ko -->
                        </ol>
                    </div>

                </div>

                <div class="modal-footer control-group">
                    <div class="controls">
                        <button type="button" class="btn btn-success" data-bind="click:accept">Apply</button>
                        <button class="btn" data-bind="click:cancel">Cancel</button>
                    </div>
                </div>
                <!-- Group species -->
                <div class="species-modal-body"
                     data-bind="visible: groupInfoVisible() && (transients.showAddSpeciesLists() || transients.showExistingSpeciesLists())">
                    <span>
                        <g:render template="/projectActivity/addSpecies"/>

                        <g:render template="/projectActivity/chooseSpecies"/>
                    </span>
                </div>
            </div>
        </div>
    </div>
</div>

