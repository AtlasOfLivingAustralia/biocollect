<div id="pActivityAlert" class="well">

    <!-- ko foreach: projectActivities -->
        <!-- ko if: current -->
            <div class="row-fluid">
                <div class="span10 text-left">
                    <h2 class="strong">Step 6 of 7 - Set Alert</h2>
                </div>

                <div class="span2 text-right">
                    <g:render template="../projectActivity/status"/>
                </div>

            </div>

            <div class="row-fluid">
                <div class="span12 text-left">
                    <p>You can set an species alert by adding the species name.</p>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span12 text-left">
                    <div class="controls block">
                        <input class="input-xlarge" type="text" placeholder="Search species"
                               data-bind="value:alert.transients.species.name,
                                        event:{focusout: alert.transients.species.focusLost},
                                        fusedAutocomplete:{
                                            source: alert.transients.bioSearch,
                                            name: alert.transients.species.transients.name,
                                            guid: alert.transients.species.transients.guid
                                        }" data-validation-engine="validate[required]">
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span12 text-left">
                    <button class="btn-primary btn block btn-small"
                            data-bind="click: alert.add"><i class="icon-white  icon-plus" ></i>  Add</button>
                </div>
            </div>

            <div class="margin-bottom-2"></div>

            <!-- ko foreach: alert.allSpecies -->
                <div class="span12 text-left">
                    <a href="#"><span data-bind="text: name"></span></a>
                </div>
            <!-- /ko -->

        <!-- /ko -->
    <!-- /ko -->


</div>
