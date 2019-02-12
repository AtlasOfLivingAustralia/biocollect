<span data-bind="visible: transients.showAddSpeciesLists">
    <button type="button" class="close margin-right-10 margin-top-10"  data-bind="click: transients.toggleShowAddSpeciesLists">&times;</button>
    <div class="well">
    <h4>Create new species lists</h4>
        <div class="row-fluid">
            <div class="span4 text-left">
                <label>New species lists name:</label>
                <input style="width:100%;" data-bind="value: newSpeciesLists.listName" type="text" data-validation-engine="validate[required]" />
            </div>
            <div class="span4 text-left">
                <label>List Type</label>
                <select style="width:100%;" data-validation-engine="validate[required]" data-bind="options: transients.allowedListTypes, optionsText:'name', optionsValue:'id', value: newSpeciesLists.listType, optionsCaption: 'Please select'"></select>
            </div>
        </div>


        <div class="row-fluid">
            <div class="span8 text-left">
                <label>Description</label>
                <textarea style="width:100%;" data-bind="value: newSpeciesLists.description"></textarea>
            </div>
        </div>

        <div data-bind="visible: newSpeciesLists.allSpecies().length == 0">
            <h5>No species added</h5>
        </div>
        <div data-bind="visible: newSpeciesLists.allSpecies().length > 0">
            <h5>Selected species</h5>
            <div class="row-fluid">
                <div class="span12 text-left">
                    <!-- ko foreach: newSpeciesLists.allSpecies -->
                    <small data-bind="text: $index()+1">&nbsp;</small>
                    <a class="" target="_blank" data-bind="attr:{href: transients.bieUrl, title: name }">
                        <small data-bind="text: name"></small>
                    </a>
                    <button data-bind="click: $parent.newSpeciesLists.removeNewSpeciesName" class="btn btn-link"><small>&times;</small></button>
                </br>
                    <!-- /ko -->
                </div>
            </br>
            </div>
        </div>

        <!-- ko with: newSpeciesLists.inputSpeciesViewModel -->
        <div class="row-fluid">

            <div class="span6 text-left">
                <div class="input-append">
                    <label for="newspeciesNameSearch">Start typing a species name and select one to add it</label>
                    <input id="newspeciesNameSearch" style="width:80%;" type="text" placeholder="Search species"
                                             data-bind="value: transients.searchValue,
                                                    fusedAutocomplete:{
                                                        source: $parent.transients.bioSearch,
                                                        name: transients.name,
                                                        guid: transients.guid,
                                                        scientificName:transients.scientificName,
                                                        commonName:transients.commonName,
                                                        matchUnknown: true
                                                    }" >
                    <button class="btn" data-bind="click: $parent.newSpeciesLists.clearSearchValue "><i class="icon-remove"></i></button>
                </div>
            </div>
        </div>
        <!-- /ko -->
        </br>
        <div class="row-fluid">
            <div class="span8 text-left">
                <button class="btn btn-small btn-primary" data-bind="click: saveNewSpeciesName">Create new species list</button>
                <span id="addNewSpecies-status" style="display:none;" class="spinner margin-left-1"> <i class='fa fa-spin fa-spinner'></i>&nbsp;Working...</span>
            </div>
        </div>

    </div>
</span>