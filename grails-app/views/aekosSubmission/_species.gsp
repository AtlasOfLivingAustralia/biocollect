<style>
div.speciesClassDiv {
    border: 1px solid lightgrey;
}
</style>

<div id="datasetSpecies" >

    <div class="row-fluid">
        <div class="span12">
            <h4 class="strong">Step 5 of 9 - Dataset Species</h4>
        </div>
    </div>

    <div class="speciesClassDiv">

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="containPlantsSpecies"><g:message code="aekos.dataset.species.plants"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.species.plants"/>',
                              content:'<g:message code="aekos.dataset.species.plants.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>

            </label>
        </div>

        <div class="span8">
           <span id="containPlantsSpecies" data-bind="text: plantSpecies().length > 0 ? 'Yes' : 'No'"></span>
        </div>
    </div>

    <!-- ko if: plantSpecies().length > 0 -->
    <br>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label"><g:message code="aekos.dataset.species.plants.scientificNames"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.species.plants.scientificNames"/>',
                              content:'<g:message code="aekos.dataset.species.plants.scientificNames.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a></label>
        </label>
        </div>

        <div class="span8">
            <!-- ko foreach: plantSpecies() -->
            <span data-name="plantsScientificNames" class="datasetList" data-bind="text: scientificName"></span>
            <br>
            <!-- /ko -->
        </div>
    </div>

    <br>
    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" name="plantsCommonNames"><g:message code="aekos.dataset.species.plants.commonNames"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.species.plants.commonNames"/>',
                              content:'<g:message code="aekos.dataset.species.plants.commonNames.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </label>
        </div>

        <div class="span8">
            <!-- ko foreach: plantSpecies() -->
            <!-- ko if: commonName -->
            <span data-name="plantsCommonNames" class="datasetList" data-bind="text: commonName"></span>
            <br>
            <!-- /ko -->
            <!-- /ko -->
        </div>
    </div>

    <br>

        <div class="row-fluid">
            <div class="span4 text-right">
                <label class="control-label"><g:message code="aekos.dataset.species.plantGroup"/>
                    <a href="#" class="helphover"
                       data-bind="popover: {title:'',
                             content:'<g:message code="aekos.dataset.species.plantGroup.help"/>'}">
                        <i class="icon-question-sign"></i>
                    </a>
                    <span class="req-field"></span>
                </label>
            </div>

            <div class="span8">
                <div data-bind="treeView: {data: transients.plantGroups,
                                          extraFieldLabel: '<g:message code="aekos.dataset.species.plantGroup.extra"/>'}" ></div>
            </div>
        </div>

        <br>

        <!-- /ko -->
</div>
    <br>
<div class="speciesClassDiv">
    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="containAnimalSpecies"><g:message code="aekos.dataset.species.animals"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.species.animals"/>',
                              content:'<g:message code="aekos.dataset.species.animals.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
        </label>
        </div>

        <div class="span8">
           <span id="containAnimalSpecies" data-bind="text: animalSpecies().length > 0 ? 'Yes' : 'No'"></span>
        </div>
    </div>

    <!-- ko if: animalSpecies().length > 0 -->

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" ><g:message code="aekos.dataset.species.animals.scientificNames"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.species.animals.scientificNames"/>',
                              content:'<g:message code="aekos.dataset.species.animals.scientificNames.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </label>
        </div>

        <div class="span8">
            <!-- ko foreach: animalSpecies() -->
            <span data-name="animalsScientificNames" class="datasetList" data-bind="text: scientificName"></span>
            <br>
            <!-- /ko -->
        </div>
    </div>

    <br>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" ><g:message code="aekos.dataset.species.animals.commonNames"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.species.animals.commonNames"/>',
                              content:'<g:message code="aekos.dataset.species.animals.commonNames.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </label>
        </div>

        <div class="span8">
            <!-- ko foreach: animalSpecies() -->
            <!-- ko if: commonName -->
            <span data-name="animalsCommonNames" class="datasetList" data-bind="text: commonName"></span>
            <br>
            <!-- /ko -->
            <!-- /ko -->
        </div>
    </div>

    <br>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label"><g:message code="aekos.dataset.species.animalGroup"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'',
                             content:'<g:message code="aekos.dataset.species.animalGroup.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a><span class="req-field"></span>
            </label>
        </div>

        <div class="span8">
            <div data-bind="treeView: {data: transients.animalGroups,
                                          extraFieldLabel: '<g:message code="aekos.dataset.species.animalGroup.extra"/>'}" ></div>
        </div>
    </div>

    <br>

    <!-- /ko -->

</div>
</div>