<span data-bind="visible: transients.showAddSpeciesLists">
    <button type="button" class="close margin-right-10 margin-top-10"
            data-bind="click: transients.toggleShowAddSpeciesLists">&times;</button>

    <div>
        <h4>Create new species lists</h4>

        <div class="row">
            <div class="col-6">
                <label>New species lists name:</label>
                <input class="form-control" data-bind="value: newSpeciesLists.listName" type="text"
                       data-validation-engine="validate[required]"/>
            </div>

            <div class="col-6">
                <label>List Type</label>
                <select class="form-control" data-validation-engine="validate[required]"
                        data-bind="options: transients.allowedListTypes, optionsText:'name', optionsValue:'id', value: newSpeciesLists.listType, optionsCaption: 'Please select'"></select>
            </div>
        </div>


        <div class="row">
            <div class="col-12">
                <label>Description</label>
                <textarea class="form-control" data-bind="value: newSpeciesLists.description"></textarea>
            </div>
        </div>

        <div data-bind="visible: newSpeciesLists.allSpecies().length == 0">
            <h5 class="mt-2">No species added</h5>
        </div>

        <div data-bind="visible: newSpeciesLists.allSpecies().length > 0">
            <h5 class="mt-2">Selected species</h5>

            <div class="row">
                <div class="col-12">
                    <!-- ko foreach: newSpeciesLists.allSpecies -->
                    <small data-bind="text: $index()+1">&nbsp;</small>
                    <a class="" target="_blank" data-bind="attr:{href: transients.bieUrl, title: name }">
                        <small data-bind="text: name"></small>
                    </a>
                    <button data-bind="click: $parent.newSpeciesLists.removeNewSpeciesName"
                            class="btn btn-link"><small>&times;</small></button>
                </br>
                    <!-- /ko -->
                </div>
            </br>
            </div>
        </div>

        <!-- ko with: newSpeciesLists.inputSpeciesViewModel -->
        <div class="row">

            <div class="col-12">
                <div class="form-group row">
                    <label class="col-form-label col-4" for="newspeciesNameSearch">Start typing a species name and select one to add it</label>
                    <div class="col-8">
                        <div class="input-group">
                            <input id="newspeciesNameSearch" type="text" placeholder="Search species"
                                   data-bind="value: transients.searchValue,
                                                            fusedAutocomplete:{
                                                                source: $parent.transients.bioSearch,
                                                                name: transients.name,
                                                                guid: transients.guid,
                                                                scientificName:transients.scientificName,
                                                                commonName:transients.commonName,
                                                                matchUnknown: true,
                                                                classes: {'ui-autocomplete': 'modal-zindex'}
                                                            }">
                            <div class="input-group-append">
                                <button class="btn btn-danger" data-bind="click: $parent.newSpeciesLists.clearSearchValue ">
                                    <i class="far fa-trash-alt"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- /ko -->

        <div class="row mt-3">
            <div class="col-8">
                <button class="btn btn-sm btn-primary-dark"
                        data-bind="click: saveNewSpeciesName"><i class="fas fa-plus"></i> Create new species list</button>
                <span id="addNewSpecies-status" style="display:none;" class="spinner margin-left-1"><i
                        class='fa fa-spin fa-spinner'></i>&nbsp;Working...</span>
            </div>
        </div>

    </div>
</span>
