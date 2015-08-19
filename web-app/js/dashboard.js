// lat lon are added always as the first two columns.
defaultAttributes = ['Project_ID', 'Project_Name', 'Project_Funding', 'Project_orgName', 'Location_State', 'Project_Description', 'T1_projectArea', 'T1_area', 'T1_plantNo', 'T1_plantSurvivaltube', 'T2_projectArea', 'T2_area', 'T2_plantNo', 'T2_plantSurvivaltube', 'T3_projectArea', 'T3_area', 'Stakeholders_totalParticipants', 'Stakeholders_indigenousEmployment', 'Stakeholders_indigenousVolunteers', 'stakeholdersNo', 'Fencing_totalPTD'];
columnHeaders = ['lat', 'lon', 'Project_ID', 'Project Name', 'Funding', 'Organisation', 'State', 'Project Description', 'T1_projectArea', 'T1_area', 'T1_plantNumber', 'T1_plantSurvivaltube', 'T2_projectArea', 'T2_area', 'T2_plantNumber', 'T1_plantSurvivaltube', 'T3_projectArea', 'T3_area', 'Participants', '', '', '', 'Fencing_totalPTD'];
theme1TargetAreaColumn = 8;
theme1AreaToDateColumn = 9;
theme2TargetAreaColumn = 12;
theme2AreaToDateColumn = 13;
theme3TargetAreaColumn = 16;
theme3AreaToDateColumn = 17;
totalParticipantsColumn = 18;
indigenousEmployedColumn = 19;
indigenousVolunteersColumn = 20;
otherStakeholdersColumn = 21;
fencingColumn = 22;
t1PlantsColumn = 10;
t2PlantsColumn = 14;

fundingColumn = 4;
stateColumn = 6;
projectIdColumn = 3;

// Load the Visualization API and the piechart package.
google.load('visualization', '1.0', {'packages':['corechart']});
// Set a callback to run when the Google Visualization API is loaded.
google.setOnLoadCallback(createViewModel);

function plantingData(data) {

    var plantingData = [];
    for (var i=0; i<data.length; i++) {
        if (data[i][10] && data[i][11]) {
            plantingData.push([data[i][10], data[i][11]]);
        }
        if (data[i][14] && data[i][15]) {
            plantingData.push([data[i][14], data[i][15]]);
        }
    }

    var table = google.visualization.arrayToDataTable(plantingData, true);
    var summaryData = google.visualization.data.group(table, [1],
        [
            {column: 0, aggregation: google.visualization.data.sum, type: 'number', label: 'Plants planted'}
        ]);
//
//    var flattenedSummary = new google.visualization.DataTable();
//    flattenedSummary.addColumn("string", "Plants Planted");
//
//    flattenedSummary.addColumn("number", "0 - 25%");
//    flattenedSummary.addColumn("number", "26 - 50%");
//    flattenedSummary.addColumn("number", "51 - 75%");
//    flattenedSummary.addColumn("number", "76 - 100%");
//    var p1 = summaryData.getValue(0, 1)?summaryData.getValue(0, 1):0;
//    var p2 = summaryData.getValue(1,1);
//    var p3 = summaryData.getValue(2,1);
//    var p4 = summaryData.getValue(3, 1);
//    flattenedSummary.addRows([['', p1, p2, p3, p4]]);
//
//
//    return flattenedSummary;
    return summaryData;
}

function themeData(data) {
    var themeCount = [0,0,0];
    var themeColumns = [theme1TargetAreaColumn, theme2TargetAreaColumn, theme3TargetAreaColumn];
    for (var i=0; i<data.length; i++) {
        for (var j=0; j<themeColumns.length; j++) {
            if (data[i][themeColumns[j]] && data[i][themeColumns[j]] > 0) {
                themeCount[j] ++;
            }
        }

    }
    var themedData = [['Theme', 'Number of projects'], ['Biodiverse Plantings', themeCount[0]], ['Protecting and enhancing existing native vegetation', themeCount[1]], ['Managing threats to biodiversity', themeCount[2]]];
    return google.visualization.arrayToDataTable(themedData);
}

function engagementData(dataTable) {

    var engagementView = google.visualization.data.group(dataTable, [stateColumn],
        [
            {column: indigenousEmployedColumn, aggregation: google.visualization.data.sum, type: 'number', label: 'Indigenous Australians employed'},
            {column: indigenousVolunteersColumn, aggregation: google.visualization.data.sum, type: 'number', label: 'Indigenous Australians volunteers'},
            {column: otherStakeholdersColumn, aggregation: google.visualization.data.sum, type: 'number', label: 'Stakeholders engaged'}
        ]);

    return engagementView;
}

function fencingData(dataTable) {

    var fencingView = google.visualization.data.group(dataTable, [stateColumn],
        [
            {column: fencingColumn, aggregation: google.visualization.data.sum, type: 'number', label: 'Fence length (km)'}
        ]);

    return fencingView;
}



function buildCharts(plantingData, themeData, engagementData, fencingData) {
    var options = {
        colors: [{color: 'red'},{color: 'orange'}, {color: 'yellow'}, {color: 'green'}],
        //chartArea: {left: 10, right: 0, top: 20},
        chartArea: {top: 20},
        legend: {
            position: 'top'

        },
        is3D:true
    }
    var chart = new google.visualization.PieChart(document.getElementById('plantingData'));
    chart.draw(plantingData, options);

    options = {
        //backgroundColor: '#f7f4eb'
        legend: {
            position: 'top'
        }
    }

    chart = new google.visualization.ColumnChart(document.getElementById('themeData'));
    options = {
        legend: {
            position: 'top'
        },
        vAxes: {0: {title: 'Number of projects targeting theme', minValue: 0}}
    }
    chart.draw(themeData, options);

    chart = new google.visualization.ColumnChart(document.getElementById('engagementData'));

    var engagementOptions = {
        //backgroundColor: '#f7f4eb',
        legend : {
            position: 'top'
        },
        vAxes: {0: {title: 'Number of stakeholders', minValue: 0}}
    }
    chart.draw(engagementData, engagementOptions);

    options = {
        legend: {
            position: 'top'
        },
        vAxes: {0: {title: 'Total length of fencing (km)', minValue: 0}}
    }
    chart = new google.visualization.ColumnChart(document.getElementById('fencingData'));
    chart.draw(fencingData, options);


}
function removePrefix(dataTable, rowNum) {
    var group = dataTable.getValue(rowNum, 5);
    if (group.indexOf("Weeds_") == 0) {
        group = group.substring(6);
    }
    return group;
}

function isWeed(dataTable, rowNum) {
    var group = dataTable.getValue(rowNum, 5);
    return group.indexOf("Weeds_") == 0 ? 0 : 1;
}

function addSpeciesCharts(data) {
    var table = google.visualization.arrayToDataTable(data, true);
    var view = new google.visualization.DataView(table);
    view.setColumns([3,
        {calc: removePrefix, type: 'string', label: "Category"},
        {calc: isWeed, type: 'number', label: "Category"}
    ]);

    var weeds = new google.visualization.DataView(view);
    weeds.setRows(view.getFilteredRows([{column: 2, value: 0}]));
    weeds.setColumns([1, 2]);
    weeds = google.visualization.data.group(weeds, [0],
        [
            {column: 1, aggregation: google.visualization.data.count, type: 'number', label: 'Number of projects targeting category'}
        ]);

    var options = {
        //backgroundColor: '#f7f4eb',
        height: 200,
        legend : {
            position: 'top'
        },
        vAxes: {0: {title: 'Number of projects', minValue: 0, format: '0'}}
    }
    var chart = new google.visualization.ColumnChart(document.getElementById('weedsByCategory'));
    chart.draw(weeds, options);


    var pests = new google.visualization.DataView(view);
    pests.setRows(view.getFilteredRows([{column: 2, value: 1}]));
    pests.setColumns([0, 2]);

    pests = google.visualization.data.group(pests, [0],
        [
            {column: 1, aggregation: google.visualization.data.count, type: 'number', label: 'Number of projects targeting category'}
        ]);

    var options = {
        //backgroundColor: '#f7f4eb',
        legend : {
            position: 'top'
        },
        vAxes: {0: {title: 'Number of projects', minValue: 0}},
        hAxis: {slantedTextAngle:60},
        chartArea: {height: '50%', top:30}
    }
    chart = new google.visualization.ColumnChart(document.getElementById('pestsByCategory'));
    chart.draw(pests, options);
}

function buildRule(value, colour) {
    return new OpenLayers.Rule( {
        filter: new OpenLayers.Filter.Comparison({
            type: OpenLayers.Filter.Comparison.EQUAL_TO,
            property: "survivalRate",
            value: value
        }),
        symbolizer: {pointRadius: 5, fillColor: colour}
    });
}

function addPlantsLayer(data) {
    var latLongProj = new OpenLayers.Projection("EPSG:4326");

    var style = new OpenLayers.Style();
    var r1 = buildRule("51 - 75%", "yellow");
    var r2 = buildRule("76 - 100%", "green");
    var r3 = buildRule("26 - 50%", "orange");
    var r4 = buildRule("0 - 25%", "red");

    style.addRules([r1, r2, r3, r4]);
    var styleMap = new OpenLayers.StyleMap(style);

    var plantingLayer = new OpenLayers.Layer.Vector("Plants", {
        styleMap: styleMap,
        isBaseLayer:false
    });


    var plants = [];
    for (resultKey in data) {

        var result = data[resultKey];

        var location = new OpenLayers.LonLat(parseFloat(result[1]), parseFloat(result[0]));
        location.transform(latLongProj, map.getProjectionObject());

        var point = new OpenLayers.Geometry.Point(location.lon, location.lat);

        if (result[10] && result[11]) {
            var marker = new OpenLayers.Feature.Vector(point, {index: resultKey, survivalRate:result[10], number: result[11]});
            plants.push(marker);

        }

        if (result[14] && result[15]) {
            var marker = new OpenLayers.Feature.Vector(point, {index: resultKey, survivalRate:result[15], number: result[14]});
            plants.push(marker);

        }

    }
    plantingLayer.addFeatures(plants);
    plantingLayer.id = "Plants";

    map.addLayer(plantingLayer);

}

function loadWMSLayer(name, opacity) {

    var wmsLayer = new OpenLayers.Layer.WMS(name, "http://spatial.ala.org.au/geoserver/gwc/service/wms/reflect", {
        layers: 'ALA:' + name,
        srs: 'EPSG:900913',
        format: 'image/png',
        transparent: true
    });

    if (opacity) {
        wmsLayer.setOpacity(opacity);
    }

    map.addLayer(wmsLayer);

}

function initMap(data) {

    var extent = new OpenLayers.Bounds(
        11805603.158865,
        -5497723.392896,
        17871645.722733,
        -899271.77189995
    );
    var options = {
        projection: "EPSG:900913",
        units: "m"
    };

    map = new OpenLayers.Map('plantingDataMap', options);

    map.addControl(new OpenLayers.Control.LayerSwitcher());

    var gphy = new OpenLayers.Layer.Google(
        "Google Physical",
        {type: google.maps.MapTypeId.TERRAIN}
    );

    map.addLayers([gphy]);

    map.zoomToExtent(extent, true);

    loadWMSLayer("nrm_regions_2010", 0.5);
    addPlantsLayer(data);

}


