<!-- data-table select species list -->
<span data-bind="if: transients.showExistingSpeciesLists">
    <button type="button" class="close margin-right-10 margin-top-10"  data-bind="click:transients.toggleShowExistingSpeciesLists">&times;</button>
    <div class="well">
        <div class="row-fluid margin-bottom-1">
            <label for="speciesNameSearch">Enter a list name or select a species name to search for</label>
            <input id="speciesNameSearch" class="input-xxlarge" type="text" placeholder="Search list or species"
                   data-bind="value:allSpeciesLists.searchName,
                                        fusedAutocomplete:{
                                            source: transients.bioSearch,
                                            name: allSpeciesLists.searchName,
                                            guid: allSpeciesLists.searchGuid
                                        }">
            <div class="input-append">
                <button id="search" class="btn btn-primary" data-bind="click: allSpeciesLists.refreshPage(0)">Search</button>
            </div>
            <div class="input-append">
                <button id="clear" class="btn btn-default" data-bind="click: allSpeciesLists.clearSearch">Clear</button>
            </div>
        </div>

        <div class="row-fluid" data-bind="with: allSpeciesLists">
            <g:render template="/shared/pagination"/>
        </div>


        <!-- ko if: allSpeciesLists.listCount() > 0 -->
        <div class="row-fluid">
            <div class="span12 text-left">
                <table class="table table-striped" id="select-species-list">
                    <thead>
                    <th width="40%">
                        <button class="btn btn-link"
                            data-bind="click: allSpeciesLists.sort('listName', allSpeciesLists.transients.sortOrder())">
                            List name
                            <span data-bind="css: allSpeciesLists.ascIconClass, visible: allSpeciesLists.transients.sortCol()=='listName' && allSpeciesLists.transients.sortOrder()=='asc'"></span>
                            <span data-bind="css: allSpeciesLists.descIconClass, visible: allSpeciesLists.transients.sortCol()=='listName' && allSpeciesLists.transients.sortOrder()=='desc'"></span>
                        </button>
                    </th>
                    <th width="10%" >
                        <button class="btn btn-link"
                                data-bind="click: allSpeciesLists.sort('listType', allSpeciesLists.transients.sortOrder())">
                            List type
                            <span data-bind="css: allSpeciesLists.ascIconClass, visible: allSpeciesLists.transients.sortCol()=='listType' && allSpeciesLists.transients.sortOrder()=='asc'"></span>
                            <span data-bind="css: allSpeciesLists.descIconClass, visible: allSpeciesLists.transients.sortCol()=='listType' && allSpeciesLists.transients.sortOrder()=='desc'"></span>
                        </button>
                    </th>
                    <th width="20%">
                        <button class="btn btn-link"
                                data-bind="click: allSpeciesLists.sort('username', allSpeciesLists.transients.sortOrder())">
                            Owner
                            <span data-bind="css: allSpeciesLists.ascIconClass, visible: allSpeciesLists.transients.sortCol()=='username' && allSpeciesLists.transients.sortOrder()=='asc'"></span>
                            <span data-bind="css: allSpeciesLists.descIconClass, visible: allSpeciesLists.transients.sortCol()=='username' && allSpeciesLists.transients.sortOrder()=='desc'"></span>
                        </button>
                    </th>
                    <th width="10%">
                        <button class="btn btn-link"
                                data-bind="click: allSpeciesLists.sort('count', allSpeciesLists.transients.sortOrder())">
                            Item Count&nbsp;
                            <span data-bind="css: allSpeciesLists.ascIconClass, visible: allSpeciesLists.transients.sortCol()=='count' && allSpeciesLists.transients.sortOrder()=='asc'"></span>
                            <span data-bind="css: allSpeciesLists.descIconClass, visible: allSpeciesLists.transients.sortCol()=='count' && allSpeciesLists.transients.sortOrder()=='desc'"></span>
                        </button>

                    </th>
                    <th width="20%"></th>

                    </thead>

                    <tbody>
                    <!-- ko foreach: allSpeciesLists.allSpeciesListsToSelect -->
                    <tr>
                        <td data-bind="text: listName"></td>
                        <td data-bind="text: listType"></td>
                        <td data-bind="text: fullName"></td>
                        <td data-bind="text: itemCount"></td>
                        <td>
                            <a target="_blank" data-bind="attr:{href: transients.url}">
                                <span class="icon-eye-open"> </span> View
                            </a>

                            <span data-bind="if: transients.check() == true">
                                <span class="icon-check"> </span> Added
                            </span>
                            <span data-bind="if: transients.check() == false">
                                <button class="btn btn-link" data-bind="click: $parent.addSpeciesLists">
                                    <span class="icon-plus-sign"> </span> Add
                                </button>
                            </span>
                        </td>
                    </tr>
                    <!-- /ko -->

                    </tbody>
                </table>
            </div>
        </div>
        <!-- /ko -->
        <div class="row-fluid" data-bind="with: allSpeciesLists">
            <g:render template="/shared/pagination"/>
        </div>
    </div>
</span>

<!-- /end of data-table -->
