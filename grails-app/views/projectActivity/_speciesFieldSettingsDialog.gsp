%{--<div id="configureSpeciesField" >--}%
<div class="container">
    <div id="configureSpeciesField" class="species-modal fade" role="dialog" >
        <div class="species-modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close"  data-bind="click:species.cancelConfigWindow">&times;</button>
                    <h4 class="modal-title">Configure Species</h4>
                </div>
                <div class="modal-body">
                    <div class="row-fluid">
                        <div class="span4 text-left">
                            <div class="controls">
                                <span class="req-field">
                                    <select data-validation-engine="validate[required]" data-bind="options: $root.speciesOptions, optionsText:'name', optionsValue:'id', value: species.type, optionsCaption: 'Please select'" ></select>
                                </span>
                            </div>

                            <div class="btn-group btn-group-vertical margin-top-2" data-bind="visible: species.groupInfoVisible, if: species.groupInfoVisible" >
                                <a class="btn btn-xs btn-default" data-bind="click: species.transients.toggleShowExistingSpeciesLists">Choose from existing species lists</a>
                                (OR)
                                <a class="btn btn-xs btn-default" target="blank" data-bind="click: species.transients.toggleShowAddSpeciesLists">Add new species lists</a>
                            </div>

                            <div data-bind="visible: species.singleInfoVisible" class="margin-top-2">
                                <div class="controls block">
                                    <span data-bind="if: species.singleSpecies.transients.guid">
                                        <a data-bind="attr:{href: species.transients.bioProfileUrl}" target="_blank"><small data-bind="text:  species.singleSpecies.transients.name"></small></a>
                                    </span>

                                    <input class="input-xlarge" type="text" placeholder="Search species"
                                           data-bind="value:species.singleSpecies.name,
                                                    event:{focusout: species.singleSpecies.focusLost},
                                                    fusedAutocomplete:{
                                                        source: species.transients.bioSearch,
                                                        name: species.singleSpecies.transients.name,
                                                        guid: species.singleSpecies.transients.guid,
                                                        scientificName: species.singleSpecies.transients.scientificName,
                                                        commonName: species.singleSpecies.transients.commonName
                                                    }" data-validation-engine="validate[required]">

                                </div>
                            </div>
                        </div>

                        <div class="span8 text-left">
                            <div class="">
                                <!-- ko if: species.allSpeciesInfoVisible() -->
                                <fc:getSettingContent settingType="${au.org.ala.biocollect.merit.SettingPageType.SURVEY_SPECIES_ALL}"/>
                                <!-- /ko-->
                                <!-- ko if: species.singleInfoVisible() -->
                                <fc:getSettingContent settingType="${au.org.ala.biocollect.merit.SettingPageType.SURVEY_SPECIES_SINGLE}"/>
                                <!-- /ko-->
                                <!-- ko if: species.groupInfoVisible() -->
                                <fc:getSettingContent settingType="${au.org.ala.biocollect.merit.SettingPageType.SURVEY_SPECIES_GROUP}"/>
                                <!-- /ko-->
                            </div>


                        </div>
                    </div>
                    <span data-bind="visible: species.groupInfoVisible, if: species.speciesLists().length > 0">
                        <div class="row-fluid">
                            <div class="span12 text-left">

                                <!-- ko foreach: species.speciesLists -->
                                <span data-bind="text: $index()+1"></span>
                                <a class="btn btn-link" target="_blank" data-bind="attr:{href: transients.url}">
                                    <small data-bind="text: listName"></small>
                                </a>
                                <button data-bind="click: $parent.species.removeSpeciesLists" class="btn btn-link"><small>X</small></button>
                            </br>
                                <!-- /ko -->
                            </div>
                        </br>
                        </div>
                    </span>

                    <!-- Group species -->
                    <span data-bind="visible: species.groupInfoVisible">

                        <span data-bind="if: species.groupInfoVisible">
                            <g:render template="/projectActivity/addSpecies"/>

                            <g:render template="/projectActivity/chooseSpecies"/>
                        </span>

                    </span>
                </div>
                <div class="modal-footer control-group">
                    <div class="controls">
                        <button type="button" class="btn btn-success">Apply</button>
                        <button class="btn" data-bind="click:species.cancelConfigWindow">Cancel</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>