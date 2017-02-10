<!-- data-table select species list -->
<span data-bind="visible: transients.showExistingSpeciesLists">
    <button type="button" class="close margin-right-10 margin-top-10"  data-bind="click:transients.toggleShowExistingSpeciesLists">&times;</button>
    <div class="well">
        <h4>Choose from existing species lists</h4>
        <div class="row-fluid margin-bottom-1">
            <div class="input-append">
                <label for="speciesNameSearch">Enter a list name or select a species name to search for</label>
                <input id="speciesNameSearch" class="input-xxlarge" type="text" placeholder="Search list or species"
                       data-bind="value:allSpeciesLists.searchName,
                                            fusedAutocomplete:{
                                                source: transients.bioSearch,
                                                name: allSpeciesLists.searchName,
                                                guid: allSpeciesLists.searchGuid
                                            }">
                <button id="clear" class="btn btn-default" data-bind="click: allSpeciesLists.clearSearch"><i class="icon-remove"></i></button>
                <span class="margin-left-10">
                <button id="search" class="btn btn-primary" data-bind="click: allSpeciesLists.refreshPage(0)">Search</button>

            </div>
        </div>

        <div class="row-fluid" data-bind="with: allSpeciesLists">
            <div class="span12 text-left" data-bind="visible: !pagination.info()">
                <p class="hidden-xs pull-left nomargin">
                    <span data-bind="visible: searchGuid()">No lists found containing species <b data-bind="text: searchName"></b></span>
                    <span data-bind="visible: !searchGuid()">No lists containing text <b class="text-" data-bind="text: searchName"></b></span>
                </p>
            </div>
            <g:render template="/shared/pagination"/>
        </div>

        <div data-bind="visible: allSpeciesLists.listCount() > 0 " class="row-fluid">
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
                                <span class="icon-check"> </span> Added
                            </span>
                            <span data-bind="visible: !transients.check()">
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

        <div class="row-fluid" data-bind="with: allSpeciesLists">
            <g:render template="/shared/pagination"/>
        </div>
    </div>
</span>

<!-- /end of data-table -->
