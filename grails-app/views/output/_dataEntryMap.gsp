<div>
    <select data-bind='options: activityLevelData.pActivity.sites, optionsText: "name", optionsValue: "siteId", value: data.${source}, optionsCaption: "Choose a site..."'></select>

    <div id="${source}Map" style="width:100%; height: 512px;"></div>
</div>
