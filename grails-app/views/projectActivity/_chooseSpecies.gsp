<!-- data-table select species list -->
<span data-bind="if: species.transients.showExistingSpeciesLists">

        <div class="well">

            <div class="row-fluid">
                <div class="span6 text-left">
                    <label> Found: <span data-bind="text: species.allSpeciesLists.listCount"></span> species lists </label>
                </div>
                <div class="span6 text-right">
                    <span data-bind="if: species.allSpeciesLists.isPrevious"> <a class="btn btn-small" target="blank" data-bind="click: species.allSpeciesLists.previous"> << Previous </a></span>
                    <span data-bind="if: species.allSpeciesLists.isNext"> <a class="btn btn-small" target="blank" data-bind="click: species.allSpeciesLists.next"> Next >> </a></span>
                    <button class="btn btn-small" data-bind="click: species.transients.toggleShowExistingSpeciesLists">  Close</button>
                </div>
                </br>
            </div>

            <div class="row-fluid">
                <div class="span12 text-left">
                    <table class="table table-striped" id="select-species-list">
                        <thead>
                        <th width="30%">List name</th>
                        <th width="10%">List type</th>
                        <th width="20%">Owner</th>
                        <th width="10%">Item Count</th>
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

            <div class="row-fluid">
                <div class="span12 text-left">
                    <span data-bind="if: species.allSpeciesLists.isPrevious"> <a class="btn btn-small" target="blank" data-bind="click: species.allSpeciesLists.previous"> << Previous </a></span>
                    <span data-bind="if: species.allSpeciesLists.isNext"> <a class="btn btn-small" target="blank" data-bind="click: species.allSpeciesLists.next"> Next >> </a></span>
                    <button class="btn btn-small" data-bind="click: species.transients.toggleShowExistingSpeciesLists">  Close</button>
                </div>
            </div>

        </div>
</span>


<!-- /end of data-table -->
