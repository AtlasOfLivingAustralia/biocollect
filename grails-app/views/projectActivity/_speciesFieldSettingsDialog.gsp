<r:require module="speciesFieldsSettings"/>

<div id="configureSpeciesFieldModal" class="species-modal fade" role="dialog" >
    <div class="species-modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close"  data-bind="click:cancel">&times;</button>
                <h4 class="modal-title">Configure <span data-bind="visible: transients.fieldName, text: transients.fieldName()" > </span></h4>
                <div id="species-dialog-alert-placeholder"></div>
            </div>
            <div class="modal-body">
                <div class="row-fluid">
                    <div class="span4 text-left">
                        <div class="controls">
                            <span class="req-field">
                                <select data-validation-engine="validate[required]" data-prompt-position="centerRight" data-bind="options: speciesOptions, optionsText:'name', optionsValue:'id', value: type, optionsCaption: 'Please select'" ></select>
                            </span>
                        </div>

                        <div class="btn-group btn-group-vertical margin-top-2" data-bind="visible: groupInfoVisible" >
                            <a class="btn btn-xs btn-default" data-bind="click: transients.toggleShowExistingSpeciesLists">Choose from existing species lists</a>
                            (OR)
                            <a class="btn btn-xs btn-default" target="blank" data-bind="click: transients.toggleShowAddSpeciesLists">Create new species lists</a>
                        </div>

                        <div data-bind="visible: singleInfoVisible" class="margin-top-2">
                            <div class="controls block">
                                <span data-bind="visible: singleSpecies.transients.guid" class="req-field">
                                    <a data-bind="attr:{href: transients.bioProfileUrl}" target="_blank"><small data-bind="text:  singleSpecies.transients.name"></small></a>
                                </span>
                                <span data-bind="visible: !singleSpecies.transients.guid()" class="req-field">
                                    <small>Search and select a species below</small>
                                </span>

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

                            </div>
                        </div>
                    </div>

                    <div class="span8 text-left">
                        <div data-bind="visible: type() == 'ALL_SPECIES'">
                            <fc:getSettingContent settingType="${au.org.ala.biocollect.merit.SettingPageType.SURVEY_SPECIES_ALL}"/>
                        </div>
                        <div data-bind="visible: singleInfoVisible">
                            <fc:getSettingContent settingType="${au.org.ala.biocollect.merit.SettingPageType.SURVEY_SPECIES_SINGLE}"/>
                        </div>
                        <div data-bind="visible: groupInfoVisible">
                            <fc:getSettingContent settingType="${au.org.ala.biocollect.merit.SettingPageType.SURVEY_SPECIES_GROUP}"/>
                        </div>
                        <div data-bind="visible: type() == 'DEFAULT_SPECIES'">
                            <fc:getSettingContent settingType="${au.org.ala.biocollect.merit.SettingPageType.SURVEY_DEFAULT}"/>
                        </div>
                    </div>
                </div>

                <div data-bind="visible: groupInfoVisible, if: speciesLists().length == 0">
                    <h5><span class="req-field">No lists selected</span></h5>
                </div>
                <div data-bind="visible: groupInfoVisible, if: speciesLists().length > 0">
                    <h5><span class="req-field">Selected lists</span></h5>
                    <div class="row-fluid">
                        <div class="span12 text-left">
                            <!-- ko foreach: speciesLists -->
                            <small data-bind="text: $index()+1">&nbsp;</small>
                            <a class="" target="_blank" data-bind="attr:{href: transients.url, title: listName }">
                                <small data-bind="text: transients.truncatedListName"></small>
                            </a>
                            <button data-bind="click: $parent.removeSpeciesLists" class="btn btn-link"><small>&times;</small></button>
                            </br>
                            <!-- /ko -->
                        </div>
                    </br>
                    </div>
                </div>

                <!-- Group species -->
                <span data-bind="visible: groupInfoVisible">
                    <span>
                        <g:render template="/projectActivity/addSpecies"/>

                        <g:render template="/projectActivity/chooseSpecies"/>
                    </span>

                </span>
            </div>
            <div class="modal-footer control-group">
                <div class="controls">
                    <button type="button" class="btn btn-success" data-bind="click:accept">Apply</button>
                    <button class="btn" data-bind="click:cancel">Cancel</button>
                </div>
            </div>
        </div>
    </div>
</div>

