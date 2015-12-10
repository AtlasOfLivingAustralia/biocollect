<div class="span6">
    <m:map id="${source}Map" />
</div>

<div class="span6">
    <div class="well">
        <div class="row-fluid">
            <div class="span3">
                <label for="siteLocation">${readonly ? 'Location:' : 'Select a location'}</label>
            </div>

            <div class="span9">
                <g:if test="${readonly}">
                    <span class="output-text" data-bind="text: data.${source}Name() "></span>
                </g:if>
                <g:else>
                    <select id="siteLocation"
                            data-bind='options: activityLevelData.pActivity.sites, optionsText: "name", optionsValue: "siteId", value: data.${source}, optionsCaption: "Choose a site...", disable: ${readonly}'></select>
                </g:else>
            </div>
        </div>
    </div>

    <div class="well">
        <div class="row-fluid">
            <div class="span3">
                <label for="${source}Latitude">Latitude</label>
            </div>

            <div class="span9">
                <g:if test="${readonly}">
                    <span data-bind="text: data.${source}Latitude"></span>
                </g:if>
                <g:else>
                    <input id="${source}Latitude" type="text" data-bind="value: data.${source}Latitude" data-validation-engine="validate[required]">
                </g:else>
            </div>
        </div>

        <div class="row-fluid">
            <div class="span3">
                <label for="${source}Longitude">Longitude</label>
            </div>

            <div class="span9">
                <g:if test="${readonly}">
                    <span data-bind="text: data.${source}Longitude"></span>
                </g:if>
                <g:else>
                    <input id="${source}Longitude" type="text" data-bind="value: data.${source}Longitude" data-validation-engine="validate[required]">
                </g:else>
            </div>
        </div>
    </div>

    <g:if test="${!readonly}">
        <div class="row-fluid">
            <div class="span12">
                <button class="btn btn-primary" data-bind="click: data.reset${source}Map">Reset map</button>
            </div>
        </div>
    </g:if>
</div>
