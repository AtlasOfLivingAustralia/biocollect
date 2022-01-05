<!-- data-table select species list -->
<span data-bind="visible: transients.showExistingSpeciesLists">
    <button type="button" class="close mr-2 mt-2"  data-bind="click:transients.toggleShowExistingSpeciesLists">&times;</button>
    <div>
        <h4>Choose from existing species lists</h4>
        <div class="row mb-2">
            <div class="col-12">
                <div class="form-group row">
                    <label class="col-12 col-md-5 col-form-label" for="speciesNameSearch">Enter a list name or select a species name to search for</label>
                    <div class="input-group input-group-sm col-12 col-md-7">
                        <input id="speciesNameSearch" class="form-control" type="text" placeholder="Search list or species"
                               data-bind="value:allSpeciesLists.searchName,
                                                fusedAutocomplete:{
                                                    source: transients.bioSearch,
                                                    name: allSpeciesLists.searchName,
                                                    guid: allSpeciesLists.searchGuid
                                                }">
                        <div class="input-group-append">
                            <button id="search" class="btn btn-dark" data-bind="click: allSpeciesLists.refreshPage(0)"><i class="fas fa-search"></i> Search</button>
                            <button id="clear" class="btn btn-dark" data-bind="click: allSpeciesLists.clearSearch"><i class="far fa-times-circle"></i> Clear</button>
                        </div>
                    </div>

                </div>
            </div>
        </div>

        <div class="row" data-bind="with: allSpeciesLists">
            <div class="col-12" data-bind="visible: !pagination.info()">
                <p class="hidden-xs pull-left nomargin">
                    <span data-bind="visible: searchGuid()">No lists found containing species <b data-bind="text: searchName"></b></span>
                    <span data-bind="visible: !searchGuid()">No lists containing text <b class="text-" data-bind="text: searchName"></b></span>
                </p>
                <g:render template="/shared/pagination" model="[bs:4]"/>
            </div>
        </div>

        <div data-bind="visible: allSpeciesLists.listCount() > 0 " class="row">
            <div class="col-12 table-responsive">
                <table class="table table-striped not-stacked-table" id="select-species-list">
                    <thead>
                    <th width="40%">
                        <button class="btn btn-link"
                            data-bind="click: allSpeciesLists.sort('listName', allSpeciesLists.transients.sortOrder())">
                            List name
                            <span data-bind="css: allSpeciesLists.ascIconClass, visible: allSpeciesLists.transients.sortCol()=='listName' && allSpeciesLists.transients.sortOrder()=='asc'"></span>
                            <span data-bind="css: allSpeciesLists.descIconClass, visible: allSpeciesLists.transients.sortCol()=='listName' && allSpeciesLists.transients.sortOrder()=='desc'"></span>
                        </button>
                    </th>
                    <th width="15%" >
                        <button class="btn btn-link"
                                data-bind="click: allSpeciesLists.sort('listType', allSpeciesLists.transients.sortOrder())">
                            List type
                            <span data-bind="css: allSpeciesLists.ascIconClass, visible: allSpeciesLists.transients.sortCol()=='listType' && allSpeciesLists.transients.sortOrder()=='asc'"></span>
                            <span data-bind="css: allSpeciesLists.descIconClass, visible: allSpeciesLists.transients.sortCol()=='listType' && allSpeciesLists.transients.sortOrder()=='desc'"></span>
                        </button>
                    </th>
                    <th width="15%">
                        <button class="btn btn-link"
                                data-bind="click: allSpeciesLists.sort('username', allSpeciesLists.transients.sortOrder())">
                            Owner
                            <span data-bind="css: allSpeciesLists.ascIconClass, visible: allSpeciesLists.transients.sortCol()=='username' && allSpeciesLists.transients.sortOrder()=='asc'"></span>
                            <span data-bind="css: allSpeciesLists.descIconClass, visible: allSpeciesLists.transients.sortCol()=='username' && allSpeciesLists.transients.sortOrder()=='desc'"></span>
                        </button>
                    </th>
                    <th width="17%">
                        <button class="btn btn-link"
                                data-bind="click: allSpeciesLists.sort('count', allSpeciesLists.transients.sortOrder())">
                            Item Count&nbsp;
                            <span data-bind="css: allSpeciesLists.ascIconClass, visible: allSpeciesLists.transients.sortCol()=='count' && allSpeciesLists.transients.sortOrder()=='asc'"></span>
                            <span data-bind="css: allSpeciesLists.descIconClass, visible: allSpeciesLists.transients.sortCol()=='count' && allSpeciesLists.transients.sortOrder()=='desc'"></span>
                        </button>
                    </th>
                    <th width="13%"></th>

                    </thead>

                    <tbody>
                    <!-- ko foreach: allSpeciesLists.allSpeciesListsToSelect -->
                    <tr>
                        <td><a target="_blank" data-bind="attr:{href: transients.url, title: listName}">
                                <span data-bind="text: transients.truncatedListName"></span>
                            </a>
                        </td>
                        <td>
                            <small data-bind="text: listType"></small>
                        </td>
                        <td data-bind="text: fullName"></td>
                        %{--Why is bootstrap overriding any class element set here?--}%
                        %{--I have to use inline styles instead, ugly but otherwise it does not work--}%
                        <td style="text-align: right" data-bind="text: itemCount"></td>
                        <td style="text-align: right">
                            <span data-bind="visible: transients.check()">
                                <i class="far fa-check-square"></i> Added
                            </span>
                            <span data-bind="visible: !transients.check()">
                                <button class="btn btn-sm btn-dark" data-bind="click: $parent.addSpeciesLists">
                                    <i class="fas fa-plus"></i> Add
                                </button>
                            </span>
                        </td>
                    </tr>
                    <!-- /ko -->

                    </tbody>
                </table>
            </div>
        </div>

        <div data-bind="with: allSpeciesLists">
            <g:render template="/shared/pagination" model="[bs:4]"/>
        </div>
    </div>
</span>

<!-- /end of data-table -->
