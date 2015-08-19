<div id="pActivitySurvey">

        <!-- ko foreach: projectActivities -->

            <!-- ko if: current -->

            <div class="well">
                <g:render template="/projectActivity/warning"/>

                <h5>You can constrain the species available for selection in this survey to:</h5>

                <div class="row-fluid">
                    <div class="span4 text-left">
                        <div class="controls">
                            <select style="width:98%;" data-validation-engine="validate[required]" data-bind="options: $root.speciesOptions, optionsText:'name', optionsValue:'id', value: species.type, optionsCaption: 'Please select'" ></select>
                        </div>
                    </div>

                    <div class="span4 text-left">

                        <div class="btn-group btn-group-vertical" data-bind="visible: species.groupInfoVisible, if: species.groupInfoVisible" >
                            <a class="btn btn-xs btn-default" data-bind="click: species.transients.toggleShowExistingSpeciesLists">Choose from existing species lists</a>
                            (OR)
                            <a class="btn btn-xs btn-default" target="blank" data-bind="click: species.transients.toggleShowAddSpeciesLists">Add new species lists</a>
                        </div>

                    </div>
                </div>

                <div class="row-fluid" data-bind="visible: species.singleInfoVisible" >
                    <div class="span4 text-left">
                        <div class="controls">
                            <span data-bind="if: species.singleSpecies.transients.guid">
                                <a data-bind="attr:{href: species.transients.bioProfileUrl}" target="_blank"><small data-bind="text:  species.singleSpecies.transients.name"></small></a>
                           </span>
                           </br>
                            <input style="width:80%;" type="text" placeholder="Search species"
                                data-bind="value:species.singleSpecies.name,
                                            event:{focusout: species.singleSpecies.focusLost},
                                            fusedAutocomplete:{
                                                source: species.transients.bioSearch,
                                                name: species.singleSpecies.transients.name,
                                                guid: species.singleSpecies.transients.guid
                                            }" data-validation-engine="validate[required]">

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


            </div>

            <!-- Group species -->
            <span data-bind="visible: species.groupInfoVisible">

                <span data-bind="if: species.groupInfoVisible">
                    <g:render template="/projectActivity/addSpecies" />

                    <g:render template="/projectActivity/chooseSpecies" />
                </span>

            </span>

        <!-- /ko -->

        <!-- /ko -->

    </br>
    <div class="row-fluid pull-right">

        <div class="span12">
            <button class="btn-primary btn block" data-bind="click: saveSpecies"> Save </button>
        </div>

    </div>

</div>


