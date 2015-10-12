<div class="span6">
    <div id="${source}Map" class="data-entry-map-container"></div>
</div>

<div class="span6">
    <div class="well">
        <div class="row-fluid">
            <div class="span3">
                <label for="siteLocation">Select a location</label>
            </div>

            <div class="span9">
                <select id="siteLocation"
                        data-bind='options: activityLevelData.pActivity.sites, optionsText: "name", optionsValue: "siteId", value: data.${source}, optionsCaption: "Choose a site..."'></select>
            </div>
        </div>

    </div>

    <div class="well">
        <div class="row-fluid">
            <div class="span3">
                <label for="latitude">Latitude</label>
            </div>

            <div class="span9">
                <input id="latitude" type="text" data-bind="value: data.decimalLatitude">
            </div>
        </div>

        <div class="row-fluid">
            <div class="span3">
                <label for="longitude">Longitude</label>
            </div>

            <div class="span9">
                <input id="longitude" type="text" data-bind="value: data.decimalLongitude">
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span12">
            <button class="btn btn-primary" data-bind="click: data.resetMap">Reset map</button>
        </div>
    </div>
</div>
