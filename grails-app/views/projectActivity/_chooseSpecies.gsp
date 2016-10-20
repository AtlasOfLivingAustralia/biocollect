<!-- data-table select species list -->
<span data-bind="if: species.transients.showExistingSpeciesLists">

        <div class="well">

            <div class="row-fluid margin-bottom-1">
                <label for="speciesNameSearch">Enter a list name or select a species name to search for</label>
                <input id="speciesNameSearch" class="input-xxlarge" type="text" placeholder="Search list or species"
                       data-bind="value:species.allSpeciesLists.searchName,
                                            fusedAutocomplete:{
                                                source: species.transients.bioSearch,
                                                name: species.allSpeciesLists.searchName,
                                                guid: species.allSpeciesLists.searchGuid
                                            }">
                <div class="input-append">
                    <button id="search" class="btn btn-primary" data-bind="click: species.allSpeciesLists.loadAllSpeciesLists(species.allSpeciesLists.transients.sortCol(), species.allSpeciesLists.transients.sortOrder())">Search</button>
                </div>
                <div class="input-append">
                    <button id="clear" class="btn btn-default" data-bind="click: species.allSpeciesLists.clearSearch">Clear</button>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span6 text-left">
                    <label> Found: <span data-bind="text: species.allSpeciesLists.listCount"></span> species lists </label>
                </div>

                <!-- ko if: species.allSpeciesLists.listCount() > 0 -->
                <div class="span6 text-right">
                    <span data-bind="if: species.allSpeciesLists.isPrevious"> <a class="btn btn-small" target="blank" data-bind="click: species.allSpeciesLists.previous"> << Previous </a></span>
                    <span data-bind="if: species.allSpeciesLists.isNext"> <a class="btn btn-small" target="blank" data-bind="click: species.allSpeciesLists.next"> Next >> </a></span>
                    <button class="btn btn-small" data-bind="click: species.transients.toggleShowExistingSpeciesLists">  Close</button>
                </div>
                <div class="margin-bottom-2"></div>
                <!-- /ko -->

            </div>

            <!-- ko if: species.allSpeciesLists.listCount() > 0 -->
            <div class="row-fluid">
                <div class="span12 text-left">
                    <table class="table table-striped" id="select-species-list">
                        <thead>
                        <th width="30%" style="color:steelblue"
                            data-bind="click: species.allSpeciesLists.sort('listName', species.allSpeciesLists.transients.sortOrder())">
                            List name
                            <span data-bind="css: species.allSpeciesLists.ascIconClass, visible: species.allSpeciesLists.transients.sortCol()=='listName' && species.allSpeciesLists.transients.sortOrder()=='asc'"></span>
                            <span data-bind="css: species.allSpeciesLists.descIconClass, visible: species.allSpeciesLists.transients.sortCol()=='listName' && species.allSpeciesLists.transients.sortOrder()=='desc'"></span>
                        </th>
                        <th width="10%" style="color:steelblue" data-bind="click: species.allSpeciesLists.sort('listType', species.allSpeciesLists.transients.sortOrder())">
                            List type
                            <span data-bind="css: species.allSpeciesLists.ascIconClass, visible: species.allSpeciesLists.transients.sortCol()=='listType' && species.allSpeciesLists.transients.sortOrder()=='asc'"></span>
                            <span data-bind="css: species.allSpeciesLists.descIconClass, visible: species.allSpeciesLists.transients.sortCol()=='listType' && species.allSpeciesLists.transients.sortOrder()=='desc'"></span>
                        </th>
                        <th width="20%" style="color:steelblue" data-bind="click: species.allSpeciesLists.sort('username', species.allSpeciesLists.transients.sortOrder())">
                            Owner
                            <span data-bind="css: species.allSpeciesLists.ascIconClass, visible: species.allSpeciesLists.transients.sortCol()=='username' && species.allSpeciesLists.transients.sortOrder()=='asc'"></span>
                            <span data-bind="css: species.allSpeciesLists.descIconClass, visible: species.allSpeciesLists.transients.sortCol()=='username' && species.allSpeciesLists.transients.sortOrder()=='desc'"></span>
                        </th>
                        <th width="10%" style="color:steelblue" data-bind="click: species.allSpeciesLists.sort('count', species.allSpeciesLists.transients.sortOrder())">
                            Item Count
                            <span data-bind="css: species.allSpeciesLists.ascIconClass, visible: species.allSpeciesLists.transients.sortCol()=='count' && species.allSpeciesLists.transients.sortOrder()=='asc'"></span>
                            <span data-bind="css: species.allSpeciesLists.descIconClass, visible: species.allSpeciesLists.transients.sortCol()=='username' && species.allSpeciesLists.transients.sortOrder()=='desc'"></span>
                        </th>
                        <th width="10%"></th>
                        <th width="10%"></th>

                        </thead>

                        <tbody>
                        <!-- ko foreach: species.allSpeciesLists.allSpeciesListsToSelect -->
                        <tr>
                            <td data-bind="text: listName"></td>
                            <td data-bind="text: listType"></td>
                            <td data-bind="text: fullName"></td>
                            <td data-bind="text: itemCount"></td>
                            <td> <a target="_blank" data-bind="attr:{href: transients.url}">
                                <span class="icon-eye-open"> </span> View
                            </a>
                            </td>
                            <td>
                                <span data-bind="if: transients.check() == true">
                                    <span class="icon-check"> </span> Added
                                </span>
                                <span data-bind="if: transients.check() == false">
                                    <button class="btn btn-link" data-bind="click: $parent.species.addSpeciesLists">
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

            <div class="row-fluid">
                <div class="span12 text-left">
                    <!-- ko if: species.allSpeciesLists.listCount() > 0 -->
                    <span data-bind="if: species.allSpeciesLists.isPrevious"> <a class="btn btn-small" target="blank" data-bind="click: species.allSpeciesLists.previous"> << Previous </a></span>
                    <span data-bind="if: species.allSpeciesLists.isNext"> <a class="btn btn-small" target="blank" data-bind="click: species.allSpeciesLists.next"> Next >> </a></span>
                    <!-- /ko -->
                    <button class="btn btn-small" data-bind="click: species.transients.toggleShowExistingSpeciesLists">  Close</button>
                </div>
            </div>

        </div>
</span>


<!-- /end of data-table -->
