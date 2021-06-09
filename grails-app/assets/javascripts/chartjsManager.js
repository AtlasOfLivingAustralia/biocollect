function ChartjsManagerViewModel() {
    var self = this;
    
    self.chartjsList = ko.observableArray();

    var initBarChart = function (chartLabels, bgColors, borderColors, borderWidth, chartData, datasetLabels ) {
        var myChartData = { 
            labels: chartLabels,
            datasets: [{
                label: datasetLabels,
                data: chartData,
                backgroundColor: bgColors,
                borderColor: borderColors,
                borderWidth: borderWidth
            }]
        };
        return myChartData;
    }

    var initPieChart = function (chartLabels, bgColors, chartHoverOffset, chartData, chartTitle ) {
        var myChartData = {
            labels: chartLabels,
            datasets: [{
                label: chartTitle,
                data: chartData,
                backgroundColor: bgColors,
                hoverOffset: chartHoverOffset
            }]
        };
        return myChartData;
    }

    var initLineChart = function (chartLabels, chartFill, borderColors, chartTension, chartData, datasetLabels ) {
        var myChartData = { 
            labels: chartLabels,
            datasets: [{
                label: datasetLabels,
                data: chartData,
                fill: chartFill,
                borderColor: borderColors,
                tension: chartTension
            }]
        };
        return myChartData;
    }

    var initPieChartOpts = function (optResponsive, optPosition, optDisplay, optText) {
        var myChartOpts = {
            responsive: optResponsive,
            plugins: {
                legend: {
                    position: optPosition,
                },
                title: {
                    display: optDisplay,
                    text: optText
                }
            }
        };
        return myChartOpts;
    }

    var initBarChartOpts = function(optYScaleBeginAtZero, optYScaleDisplay, optYScaleTitleDisplay, optYScaleTitle, 
                                    optXScaleDisplay, optXScaleType, optXScaleLabels, optXScaleTitleDisplay, optXScaleTitle,
                                    optLegendDisplay, optLegendPosition, optTitleDisplay, optTitleText, optTitlePosition) {
        var myChartOpts = { 
            plugins: {
                legend: {
                    display: optLegendDisplay,
                    position: optLegendPosition
                },
                title: {
                    display: optTitleDisplay,
                    text: optTitleText,
                    position: optTitlePosition
                }
            },
            scales: { 
                y: { 
                    beginAtZero: optYScaleBeginAtZero, 
                    display: optYScaleDisplay, 
                    title: {
                        display: optYScaleTitleDisplay, 
                        text: optYScaleTitle 
                    },
                    ticks: {
                        // Work around to avoid RangeError: minimumFractionDigits value is out of range
                        // https://github.com/chartjs/Chart.js/issues/8092
                        callback: function(value, index, values) {
                            return value;
                        }
                    }
                },
                x: {
                    display: optXScaleDisplay, 
                    type: optXScaleType, 
                    labels: optXScaleLabels, 
                    title: {
                        display:optXScaleTitleDisplay, 
                        text: optXScaleTitle 
                    },
                    ticks: {
                        // Work around to avoid RangeError: minimumFractionDigits value is out of range
                        // https://github.com/chartjs/Chart.js/issues/8092
                        callback: function(value, index, values) {
                            return value;
                        }
                    }
                }
            }
        };
        return myChartOpts;
    }

    var initLineChartOpts = function (optStacked) {
        var myChartOpts = {
            scales: {
                y: {
                    stacked: optStacked
                }
            }
        };
        return myChartOpts;
    }

    var getMainTitle = function (chartConfig, totalRecords) {
        var mainTitle = '';
        if (typeof(chartConfig.mainTitle) != 'undefined' && chartConfig.mainTitle != null)
        {
            mainTitle = chartConfig.mainTitle;
            var insertTotalAt = chartConfig.mainTitleInsertTotalAt;
            if(insertTotalAt > 0 && mainTitle.length > insertTotalAt) {
                var title = [mainTitle.slice(0, insertTotalAt), totalRecords+' ', mainTitle.slice(insertTotalAt)].join('');
                mainTitle = title;
            }
        }
        return mainTitle;
    }

    var getMainTitlePosition = function (chartConfig) {
        var mainTitlePos = '';
        if (typeof(chartConfig.mainTitlePosition) != 'undefined' && chartConfig.mainTitlePosition != null)
        {
            mainTitlePos = chartConfig.mainTitlePosition;
        }
        return mainTitlePos;
    }

    var getMainLabels = function (chartConfig, totalTerms) {
        var mainLabels = '';
        if (typeof(chartConfig.mainLabels) != 'undefined' && chartConfig.mainLabels != null)
        {
            mainLabels = chartConfig.mainLabels;
            var showAllLabels = chartConfig.mainLabelsShowAll;
            if(showAllLabels == 'false') {
                var mainLabelsLimited = [];
                var i = 0;
                mainLabels.forEach(function (label) {
                    if(i < totalTerms) {
                        mainLabelsLimited.push(label);
                        i++;
                    } else {
                        mainLabels = mainLabelsLimited;
                    }
                });
            }
        }
        return mainLabels;
    }

    var getBGColorsAvailable = function (chartConfig) {
        var bgColors = '';
        if (typeof(chartConfig.bgColorsAvailable) != 'undefined' && chartConfig.bgColorsAvailable != null)
        {
            bgColors = chartConfig.bgColorsAvailable;
        }
        return bgColors;
    }

    var getBorderColors = function (chartConfig) {
        var borderColors = '';
        if (typeof(chartConfig.borderColorsAvailable) != 'undefined' && chartConfig.borderColorsAvailable != null)
        {
            borderColors = chartConfig.borderColorsAvailable;
        }
        return borderColors;
    }

    var getBorderWidth = function (chartConfig) {
        var borderWidth = '';
        if (typeof(chartConfig.borderWidth) != 'undefined' && chartConfig.borderWidth != null)
        {
            borderWidth = chartConfig.borderWidth;
        }
        return borderWidth;
    }

    var getXLabels = function (chartConfig) {
        var xLabels = '';
        if (typeof(chartConfig.xLabels) != 'undefined' && chartConfig.xLabels != null)
        {
            xLabels = chartConfig.xLabels;
        }
        return xLabels;
    }

    var getXType = function (chartConfig) {
        var xType = '';
        if (typeof(chartConfig.xType) != 'undefined' && chartConfig.xType != null)
        {
            xType = chartConfig.xType;
        }
        return xType;
    }

    var getYTitleDisplay = function (chartConfig) {
        var yTitleDisplay = '';
        if (typeof(chartConfig.yTitleDisplay) != 'undefined' && chartConfig.yTitleDisplay != null)
        {
            yTitleDisplay = chartConfig.yTitleDisplay;
        }
        return yTitleDisplay;
    }

    var getXTitleDisplay = function (chartConfig) {
        var xTitleDisplay = '';
        if (typeof(chartConfig.xTitleDisplay) != 'undefined' && chartConfig.xTitleDisplay != null)
        {
            xTitleDisplay = chartConfig.xTitleDisplay;
        }
        return xTitleDisplay;
    }

    var getYBeginAtZero = function (chartConfig) {
        var yBeginAtZero = '';
        if (typeof(chartConfig.yBeginAtZero) != 'undefined' && chartConfig.yBeginAtZero != null)
        {
            yBeginAtZero = chartConfig.yBeginAtZero;
        }
        return yBeginAtZero;
    }

    var getYDisplay = function (chartConfig) {
        var yDisplay = '';
        if (typeof(chartConfig.yDisplay) != 'undefined' && chartConfig.yDisplay != null)
        {
            yDisplay = chartConfig.yDisplay;
        }
        return yDisplay;
    }

    var getXDisplay = function (chartConfig) {
        var xDisplay = '';
        if (typeof(chartConfig.xDisplay) != 'undefined' && chartConfig.xDisplay != null)
        {
            xDisplay = chartConfig.xDisplay;
        }
        return xDisplay;
    }

    var getLegendPosition = function (chartConfig) {
        var legendPosition = '';
        if (typeof(chartConfig.legendPosition) != 'undefined' && chartConfig.legendPosition != null)
        {
            legendPosition = chartConfig.legendPosition;
        }
        return legendPosition;
    }
    
    var getLegendDisplay = function (chartConfig) {
        var legendDisplay = '';
        if (typeof(chartConfig.legendDisplay) != 'undefined' && chartConfig.legendDisplay != null)
        {
            legendDisplay = chartConfig.legendDisplay;
        }
        return legendDisplay;
    }

    var getMainTitleDisplay = function (chartConfig) {
        var mainTitleDisplay = '';
        if (typeof(chartConfig.mainTitleDisplay) != 'undefined' && chartConfig.mainTitleDisplay != null)
        {
            mainTitleDisplay = chartConfig.mainTitleDisplay;
        }
        return mainTitleDisplay;
    }
    
    var getResponsive = function (chartConfig) {
        var responsive = '';
        if (typeof(chartConfig.responsive) != 'undefined' && chartConfig.responsive != null)
        {
            responsive = chartConfig.responsive;
        }
        return responsive;
    }

    var getXTitle = function (chartConfig) {
        var xTitle = '';
        if (typeof(chartConfig.xTitle) != 'undefined' && chartConfig.xTitle != null)
        {
            xTitle = chartConfig.xTitle;
        }
        return xTitle;
    }

    var getYTitle = function (chartConfig) {
        var yTitle = '';
        if (typeof(chartConfig.yTitle) != 'undefined' && chartConfig.yTitle != null)
        {
            yTitle = chartConfig.yTitle;
        }
        return yTitle;
    }

    var getHoverOffset = function (chartConfig) {
        var hoverOffset = '';
        if (typeof(chartConfig.hoverOffset) != 'undefined' && chartConfig.hoverOffset != null)
        {
            hoverOffset = chartConfig.hoverOffset;
        }
        return hoverOffset;
    }

    var getTotalRecords = function (facet) {
        var totalCoralsSurveyed = 0;
        totalCoralsSurveyed = facet.total;
        return totalCoralsSurveyed;
    }

    var getTotalTermsInFacet = function (facet) {
        var totalTerms = 0;
        facet.terms.forEach(function (term) {
            totalTerms++;
        });
        return totalTerms;
    }

    var myRoundFunction = function(aDecNum) {
        return Math.round((aDecNum + Number.EPSILON) * 100) / 100;
    }

    //This method will count how many of the values in the term.term value fall within the passed in list of ranges
    var applyDataRanges = function (ranges, facet) {
        var frequencyList = [];
        var totalRanges = ranges.length;
        for(n=0; n < totalRanges; n++) {
            var countRange = 0;
            var range = ranges[n];
            var minVal = range.minVal;
            var maxVal = range.maxVal;
            facet.terms.forEach(function (term) {
                for(i = 0; i < term.count; i++) {
                    var termValue = term.term;
                    if(termValue >= minVal && termValue <= maxVal) {
                        countRange++;
                    } 
                }
            }); 
            frequencyList.push(countRange);
        }

        return frequencyList;
    }

    //Converts chart data passed in as a list of values to percentage based on the total of records
    //in example receives [3,2,1] sums the total = 3 + 2 + 1 = 6 then calculates the percentage of
    //what each value represents 3 = 50% of 6, 2 = 33.33% of 6 and 1 = 16.67% of 6  
    var convertDataToPercentage = function (totalRecords, chartData) {
        var colourPercentList = [];
        if (chartData != 'undefined' && chartData != null) {
            chartData.forEach(function (countRange) {
                var colourPercent = countRange * 100 / totalRecords;
                colourPercent = myRoundFunction(colourPercent);
                colourPercentList.push(colourPercent);
            });
        }
        return colourPercentList;
    }
    
    //gets count value of each term in a given facet and returns a list of values that will be interpreted 
    //as data by chartjs. In example termCountlList = [3, 2, 1] derived from a facet that has an array of 
    //terms [{term: name1, count: 3}, {term: name2, count: 2}, {term: name3, count: 1}]
    var getTermCountForFacet = function (facet) {
        var termCountlList = [];
        facet.terms.forEach(function (term) {
            termCountlList.push(term.count);
        });
        return termCountlList;
    }

    //TODO this may need to be changed to derive total count from a new field to be implemented 
    //in the facets elastic search that will include count at record level 
    var getChartData = function (chartConfig, columnConfig, facet, totalRecords) {
        var chartData; 
        if(chartConfig.dataUseCount == 'true') {
            chartData = getTermCountForFacet(facet);
        } else if (chartConfig.dataApplyRanges != 'undefined' && chartConfig.dataApplyRanges != null && chartConfig.dataApplyRanges.length > 0) {
            chartData = applyDataRanges(chartConfig.dataApplyRanges, facet);
        }

        if(chartConfig.dataToPercentage = 'true') {
            chartData = convertDataToPercentage(totalRecords, chartData);
        }

        return chartData;
    }

    var getBGColors = function (chartConfig, total) {
        var pieChartBGColors = [];
        var pieChartBGColorsAvail= getBGColorsAvailable(chartConfig);
        var showAllLabels = chartConfig.mainLabelsShowAll;
        if(showAllLabels == 'false') {
            for(i = 0; i < total; i++) {
                pieChartBGColors.push(pieChartBGColorsAvail[i]);
            }
        } else {
            pieChartBGColorsAvail.forEach(function (colourToUse) {
                pieChartBGColors.push(colourToUse);
            }); 
        }

        return pieChartBGColors;
    }

    var findChartTypeByFacetName = function (facetConfig, facetName) {
        var chartType = 'none';

        facetConfig.forEach(function (facetRowConf) {
            if(facetRowConf.name == facetName) {
                chartType = facetRowConf.chartjsType;
            }
        });
        return chartType;
    }

    var findChartConfigByFacetName = function (facetConfig, facetName) {
        var facetRowChartConf;

        facetConfig.forEach(function (facetRowConf) {
            if(facetRowConf.name == facetName) {
                facetRowChartConf = facetRowConf.chartjsConfig;
            }
        });
        return facetRowChartConf;
    }

    self.setChartsFromFacets = function (facets, facetConfig, columnConfig) {

        facets.forEach(function (facet) {

            var chartType = findChartTypeByFacetName(facetConfig, facet.name);

            if(chartType != 'none') {

                var totalRecords = getTotalRecords(facet);
                var totalTerms = getTotalTermsInFacet(facet);
                if(chartType == 'pie') {

                    //This option is using a pre defined and simplified config in JSON format stored in chartjsConfig that  
                    //has to be consistent with chartjsType which has been selected as "pie" in the hub config for the facet
                    var chartConfig = findChartConfigByFacetName(facetConfig, facet.name);

                    if (typeof(chartConfig) != 'undefined' && chartConfig != null)
                    {
                        var pieChartLabels = getMainLabels(chartConfig, totalTerms);
                        var pieChartTitle = getMainTitle(chartConfig, totalRecords);
                        var pieChartBGColor = getBGColors(chartConfig, totalTerms);
                        var pieChartHoverOffset = getHoverOffset(chartConfig);
                        var optPiePosition = getMainTitlePosition(chartConfig);
                        var optPieDisplayTitle = getMainTitleDisplay(chartConfig);
                        var optPieResponsive = getResponsive(chartConfig);
                        
                        var pieChartDistData = getChartData(chartConfig, columnConfig, facet, totalRecords); 

                        var pieChartOpts = initPieChartOpts(optPieResponsive, optPiePosition, optPieDisplayTitle, pieChartTitle);
                
                        var pieChart = initPieChart(pieChartLabels, pieChartBGColor, pieChartHoverOffset, pieChartDistData, pieChartTitle);
                        
                        self.chartjsList.push(new ChartjsViewModel(facet.name, chartType,pieChart, pieChartOpts));
                    } 

                } else if (chartType == 'bar') {

                    //This option is using a pre defined and simplified config in JSON format stored in chartjsConfig that  
                    //has to be consistent with chartjsType which has been selected as "bar" in the hub config for the facet
                    var chartConfig = findChartConfigByFacetName(facetConfig, facet.name);
                    
                    if (typeof(chartConfig) != 'undefined' && chartConfig != null)
                    {
                        var optTitleText = getMainTitle(chartConfig, totalRecords);
                        var lineChartLabels = getMainLabels(chartConfig, totalTerms);
                        var barChartBGColors = getBGColors(chartConfig, totalTerms);
                        var barChartBorderColors = getBorderColors(chartConfig);
                        var barChartBorderWidth = getBorderWidth(chartConfig);
                        var optTitlePosition = getMainTitlePosition(chartConfig); 
                        var optYScaleTitle = getYTitle(chartConfig); 
                        var optXScaleTitle = getXTitle(chartConfig);
                        var optXScaleType = getXType(chartConfig); 
                        var optXScaleLabels = getXLabels(chartConfig); 
                        var optLegendPosition = getLegendPosition(chartConfig);
                        var optYScaleBeginAtZero = getYBeginAtZero(chartConfig); 
                        var optYScaleDisplay = getYDisplay(chartConfig);
                        var optYScaleTitleDisplay = getYTitleDisplay(chartConfig) 
                        var optXScaleDisplay = getXDisplay(chartConfig); 
                        var optXScaleTitleDisplay = getXTitleDisplay(chartConfig); 
                        var optLegendDisplay = getLegendDisplay(chartConfig);
                        var optTitleDisplay = getMainTitleDisplay(chartConfig);;

                        var barChartData = getChartData(chartConfig, columnConfig, facet, totalRecords);

                        var barChartOpts = initBarChartOpts(optYScaleBeginAtZero, optYScaleDisplay, optYScaleTitleDisplay, optYScaleTitle, 
                                                            optXScaleDisplay, optXScaleType, optXScaleLabels, optXScaleTitleDisplay, optXScaleTitle,
                                                            optLegendDisplay, optLegendPosition, optTitleDisplay, optTitleText, optTitlePosition);

                        var barChart = initBarChart(lineChartLabels, barChartBGColors, barChartBorderColors, barChartBorderWidth, barChartData, 
                                                    optTitleText);
                                                            
                        self.chartjsList.push(new ChartjsViewModel(facet.name, chartType, barChart, barChartOpts));
                    } 

                } else if (chartType == 'line') {

                    //This option is using a pre defined and simplified config in JSON format stored in chartjsConfig that  
                    //has to be consistent with chartjsType which has been selected as "line" in the hub config for the facet 
                    var chartConfig = findChartConfigByFacetName(facetConfig, facet.name);

                    if (typeof(chartConfig) != 'undefined' && chartConfig != null)
                    {
                        var lineChartData = getChartData(chartConfig, columnConfig, facet, totalRecords);
                        var optTitleText = getMainTitle(chartConfig, totalRecords);
                        var lineChartLabels = getMainLabels(chartConfig, totalTerms);
                        var lineChartBGColors = getBGColors(chartConfig, 1);

                        var lineChartOpts = initLineChartOpts(true);
                        
                        var lineChart = initLineChart(lineChartLabels, true, lineChartBGColors, '0.1', lineChartData, optTitleText);

                        self.chartjsList.push(new ChartjsViewModel(facet.name, chartType, lineChart, lineChartOpts));
                    }
                }
            }
        });
    }
}

var ChartjsViewModel = function (chartFacetName, chartType, chartData, chartOptions) {
    var self = this;

    self.chartFacetName = ko.observable(chartFacetName);
    self.chartType = ko.observable(chartType);
    self.chartData = ko.observable(chartData);
    self.chartOptions = ko.observable(chartOptions);

    self.chartInstance; //Placeholder for the chart instance that needs to be accessible by the custom knockout binding. This instance reference 
                        //is required to be accessible by the update method to be able to call destroy() directly on the given chartjs instance 
                        //otherwise chartjs throws an exception "Canvas is already in use. Chart with ID 'n' must be destroyed before the canvas 
                        //can be reused." and calling the destroy() method on the canvas doesn't work. See below SO question for more details:
                        //https://stackoverflow.com/questions/40056555/destroy-chart-js-bar-graph-to-redraw-other-graph-in-same-canvas 

    self.setChartInstance = function(chartInstance) {
        self.chartInstance = chartInstance;
    }

}