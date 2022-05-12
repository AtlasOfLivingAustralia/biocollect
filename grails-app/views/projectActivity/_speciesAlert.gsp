<div class="row">
    <div class="col-12">
        <h6>a. Add species name and get notified when the species is recorded.</h6>
    </div>
</div>

<div class="row mt-2">
    <div class="col-12">
        <div class="row form-group">
            <label class="col-form-label col-12 col-md-4" for="alertSpecies">Species name:
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="project.survey.alert.species"/>', content:'<g:message
                           code="project.survey.alert.species.content"/>'}">
                    <i class="fas fa-info-circle"></i>
                </a>
            </label>

            <div class="col-12 col-md-8">
                <input id="alertSpecies" class="form-control" type="text" placeholder="Search species"
                       data-bind="value:alert.transients.species.name,
                                            event:{focusout: alert.transients.species.focusLost},
                                            fusedAutocomplete:{
                                                source: alert.transients.bioSearch,
                                                name: alert.transients.species.transients.name,
                                                guid: alert.transients.species.transients.guid,
                                                scientificName: alert.transients.species.transients.scientificName,
                                                commonName: alert.transients.species.transients.commonName
                                            }">
                <button class="btn-dark btn block btn-sm mt-1" data-toggle="tooltip" title="Enter valid species name"
                        data-bind="click: alert.add, disable: alert.transients.disableSpeciesAdd"><i
                        class="fas fa-plus"></i>  Add</button>
            </div>
        </div>
    </div>

    <!-- ko if: alert.allSpecies().length > 0 -->
    <div class="col-12">
        <div class="row">
            <label class="col-12 col-md-4">Species list:</label>

            <div class="col-12 col-md-8">
                <!-- ko foreach: alert.allSpecies -->
                <div class="row mt-1">
                    <div class="col-10">
                        <span data-bind="text: $index()+1">.</span>
                        <a data-bind="attr:{ 'href': $parent.alert.transients.bioProfileUrl + guid()}" target="_blank">
                            <span data-bind="text: name"></span>
                        </a>
                    </div>

                    <div class="col-2">
                        <button class="btn btn-sm btn-danger" data-bind="click: $parent.alert.remove"
                                title="<g:message code="projectActivity.email.delete"/>"><i
                                class="far fa-trash-alt"></i></button>
                    </div>
                </div>
                <!-- /ko -->
            </div>
        </div>
    </div>
    <!-- /ko -->

</div>
