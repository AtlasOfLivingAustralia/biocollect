<span data-bind="if: transients.showAddSpeciesLists">

<div class="well">

    <div class="row-fluid">
        <div class="span4 text-left">
            <label>Species lists name:</label>
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

    <div class="row-fluid">
        <div class="span8 text-left">
            <label>Species name (Comma separated)</label>
            <textarea rows="10" style="width:100%;" data-bind="value: newSpeciesLists.transients.bulkSpeciesNames" data-validation-engine="validate[required]"></textarea>
        </div>
    </div>

    <!-- ko foreach: newSpeciesLists.allSpecies -->
    <div class="row-fluid">

        <div class="span6 text-left">
            <span data-bind="if: transients.guid">
                <a data-bind="attr:{href: $parent.transients.bioProfileUrl}" target="_blank"><small data-bind="text:  transients.name"></small></a>
            </span>
            </br>
            <input style="width:80%;" type="text" placeholder="Search species"
                                     data-bind="value: name,
                                            event:{focusout: focusLost},
                                            fusedAutocomplete:{
                                                source: $parent.transients.bioSearch,
                                                name: transients.name,
                                                guid: transients.guid
                                            }" data-validation-engine="validate[required]">
            <button class="btn btn-small" data-bind="click: $parent.newSpeciesLists.removeNewSpeciesName">&times;</button>
        </div>


    </div>
    <!-- /ko -->
    </br>
     <div class="row-fluid">
        <div class="span8 text-left">
            <button class="btn btn-small" data-bind="click: newSpeciesLists.addNewSpeciesName"> <i class="icon icon-search"></i> Search and add species name</button>
        </div>
    </div>
     </br>
    <div class="row-fluid">
        <div class="span8 text-left">
            <span style="display:none;" id="addNewSpecies-status">
                <r:img dir="images"  width="23" height="23" file="loading-1.gif" alt="saving icon"/>
            </span>
            <button class="btn btn-small btn-primary" data-bind="click: saveNewSpeciesName">  Add new species list</button>
            <button class="btn btn-small" data-bind="click: transients.toggleShowAddSpeciesLists">  Close</button>
        </div>
    </div>

</div>

</span>