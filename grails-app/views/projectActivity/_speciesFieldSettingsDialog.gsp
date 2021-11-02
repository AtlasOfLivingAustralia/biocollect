<g:set bean="settingService" var="settingService"></g:set>
<div id="configureSpeciesFieldModal" class="species-modal modal fade" role="dialog">
    <div class="species-modal-dialog modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title">Configure <span
                        data-bind="visible: transients.fieldName, text: transients.fieldName()"></span></h4>
                <button type="button" class="close" data-bind="click:cancel" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>

                <div id="species-dialog-alert-placeholder"></div>
            </div>

            <div class="modal-main modal-body">
                <div class="species-modal-body">
                    <div class="row">
                        <div class="col-12">
                            <div class="controls">
                                <h5>Step 1. Constrain species available for selection</h5>
                                <span class="req-field">
                                    <select class="form-control" data-validation-engine="validate[required]"
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

                            <div class="btn-space" data-bind="visible: groupInfoVisible">
                                <h5>Step 2. Create or select species list</h5>
                                <button class="btn btn-sm btn-dark"
                                        data-bind="click: transients.toggleShowExistingSpeciesLists"><i
                                        class="fas fa-list-ol"></i> Choose from existing species lists</button>
                                <button class="btn btn-sm btn-dark" target="blank"
                                        data-bind="click: transients.toggleShowAddSpeciesLists"><i
                                        class="fas fa-plus"></i> Create new species lists</button>
                            </div>

                            <div data-bind="visible: singleInfoVisible" class="mt-2">
                                <h5>Step 2. Search and select a species below</h5>

                                <div class="row">
                                    <div class="col-12 col-md-6">
                                        <div class="form-group row">
                                            <label class="col-form-label col-1"><span class="req-field"></span></label>

                                            <div class="col-11">
                                                <input class="form-control" type="text" placeholder="Search species"
                                                       data-bind="value:singleSpecies.name,
                                                    event:{focusout: singleSpecies.focusLost},
                                                    fusedAutocomplete:{
                                                        source: transients.bioSearch,
                                                        name: singleSpecies.transients.name,
                                                        guid: singleSpecies.transients.guid,
                                                        scientificName: singleSpecies.transients.scientificName,
                                                        commonName: singleSpecies.transients.commonName,
                                                        classes: {'ui-autocomplete': 'modal-zindex'}
                                                    }" data-validation-engine="validate[required]">
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-12 col-md-6">
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

                    <div class="mt-2" data-bind="slideVisible: groupInfoVisible, if: speciesLists().length > 0">
                        <h5>Step 3. Construct species name using the following columns</h5>
                        <label class="d-block">Scientific name is associated with column <select class="form-control"
                                data-bind="options: commonFields, value: scientificNameField, valueAllowUnset: true"></select>
                        </label>
                        <label class="d-block">Common name is associated with column <select class="form-control"
                                data-bind="options: commonFields, value: commonNameField, valueAllowUnset: true"></select>
                        </label>

                        <h5><span class="req-field">Selected lists</span></h5>
                        <ol>
                            <!-- ko foreach: speciesLists -->
                            <li>
                                <a class="btn btn-link" target="_blank"
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

                <!-- Group species -->
                <div class="species-modal-body"
                     data-bind="visible: groupInfoVisible() && (transients.showAddSpeciesLists() || transients.showExistingSpeciesLists())">
                    <span>
                        <g:render template="/projectActivity/addSpecies"/>

                        <g:render template="/projectActivity/chooseSpecies"/>
                    </span>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-primary-dark" data-bind="click:accept"><i
                        class="fas fa-check"></i> Apply</button>
                <button class="btn btn-dark" data-bind="click:cancel"><i class="far fa-times-circle"></i> Cancel
                </button>
            </div>
        </div>
    </div>
</div>

