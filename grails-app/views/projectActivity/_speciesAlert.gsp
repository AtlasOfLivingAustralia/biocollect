<div class="row-fluid">
    <div class="span12 text-left">
        <h4>a. Add species name and get notified when the species is recorded.</h4>
    </div>
</div>

<div class="margin-bottom-1"></div>

<div class="row-fluid">
    <div class="span6 text-left">
        <div class="controls block">
            <label for="alertSpecies">Species name:
                <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.alert.species"/>', content:'<g:message code="project.survey.alert.species.content"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
            <input id="alertSpecies" class="input-xlarge" type="text" placeholder="Search species"
                   data-bind="value:alert.transients.species.name,
                                        event:{focusout: alert.transients.species.focusLost},
                                        fusedAutocomplete:{
                                            source: alert.transients.bioSearch,
                                            name: alert.transients.species.transients.name,
                                            guid: alert.transients.species.transients.guid
                                        }" >
         <div class="margin-bottom-5"></div>
         <button class="btn-default btn block btn-small" data-toggle="tooltip" title="Enter valid species name"
                    data-bind="click: alert.add, disable: alert.transients.disableSpeciesAdd"><i class="icon-plus" ></i>  Add</button>
        </div>
    </div>

    <!-- ko if: alert.allSpecies().length > 0 -->
    <div class="span6 text-left">
        <label>Species list:</label>
        <!-- ko foreach: alert.allSpecies -->
        <div class="span10 text-left">
            <div class="span6 text-left">
                <a data-bind="attr:{ 'href': $parent.alert.transients.bioProfileUrl + guid()}" target="_blank">
                    <span data-bind="text: $index()+1">.</span>
                    <span data-bind="text: name"></span>
                </a>
            </div>

            <div class="span2 text-left">
                <a href="#" data-bind="click: $parent.alert.remove"><span class="fa fa-close"></span></a>
            </div>
        </div>
        <!-- /ko -->
    </div>
    <!-- /ko -->

</div>

<div class="margin-bottom-2"></div>
