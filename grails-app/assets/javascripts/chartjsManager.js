/**
 * Knockout view model for managing multiple chart.js instances.
 * @constructor
 */
function ChartjsManagerViewModel() {
    const self = this;

    self.chartjsList = ko.observableArray();

    /**
     * Whether to show the list of charts.
     */
    self.chartjsListShow = ko.computed(function () {
        var ifChartjsListShow = self.chartjsList().length > 0
        if(ifChartjsListShow){
            $('#data-chart-tab').show()
        }
        else {
            $('#data-chart-tab').hide()
        }
        return ifChartjsListShow;
    });

    /**
     * The options for number of charts to show per line.
     */
    self.chartjsPerRowOptions = ko.observableArray(['1', '2', '3', '4']);

    /**
     * The selected number of charts to show per line.
     */
    self.chartjsPerRowSelected = ko.observable('2');

    /**
     * The charts in groups of the selected number to ease displaying in rows.
     */
    self.chartjsPerRowGroupedItems = ko.pureComputed(function () {
        const selected = self.chartjsPerRowSelected();
        const chartList = self.chartjsList();
        const perRow = parseInt(selected || '2');
        const result = [];
        for (let index = 0; index < chartList.length; index++) {
            const item = chartList[index];
            if (index % perRow === 0) {
                result.push([]);
            }
            result[result.length - 1].push(item);
        }
        return result;
    });

    /**
     * The bootstrap span class for the rows.
     */
    self.chartjsPerRowSpan = ko.pureComputed(function () {
        const selected = self.chartjsPerRowSelected();
        const perRow = 12 / parseInt(selected || '2');
        return 'col-sm-' + perRow.toString();
    });

    /**
     * Create charts from facets.
     * @param facets {FacetViewModel[] | DatePickerViewModel[]} The facet view model.
     * @param facetConfigs {object} The facet config.
     */
    self.setChartsFromFacets = function (facets, facetConfigs) {
        for (let i = 0; i < facets.length; i++) {
            const facet = facets[i];
            const facetName = facet.name();
            const facetType = facet.type;

            let facetConfig;
            for (let i = 0; i < facetConfigs.length; i++) {
                const facetConfigMaybe = facetConfigs[i];
                if (facetConfigMaybe.name === facetName) {
                    facetConfig = facetConfigMaybe;
                    break;
                }
            }
            if (!facetConfig) {
                console.error("[Chart] Could not get facet config for facet '" + facetName + "'.");
                continue;
            }

            const chartType = facetConfig.chartjsType;
            if (!chartType || chartType === 'none') {
                continue;
            }

            const chartConfig = facetConfig.chartjsConfig;

            if (['range', 'terms'].indexOf(facetType) < 0) {
                console.error("[Chart] Chart is not implemented for facet of type '" + facetType + "'.");
                continue;
            }

            // create chart js view model
            console.log("[Chart] Building chart for facet '" + facetName + "' with chart type '" + chartType + "'.");
            const chartViewModel = new ChartjsViewModel(facet, chartType, chartConfig);
            self.chartjsList.push(chartViewModel);
        }
    }
}

function ReportChartjsViewModel() {
    var self = this;

    self.chartInstance = null;
    self.setChartInstance = function (chartInstance) {
        self.chartInstance = chartInstance;
    }

    self.chartjsList = ko.observableArray([]);

    self.chartjsType = ko.observable('');
    self.data = ko.observable('');
    self.options = ko.observable('');

    self.chartjsPerRowSelected = ko.observable('');
    //self.chartjsConfig = ko.observable('');

    self.chartjsPerRowSpan = ko.pureComputed(function () {
        const selected = self.chartjsPerRowSelected();
        const perRow = 12 / parseInt(selected || '2');
        return 'col-sm-' + perRow.toString();
    });

    self.populateCharts = function() {
        var params = {};

        $.ajax({
            url:fcConfig.chartPopulateUrl,
            data:params,
            success:function(data) {
                if (data) {
                    self.chartjsPerRowSelected(data.chartjsPerRowSelected)

                    for (let i = 0; i < data.chartList.length; i++)
                    {
                        var chart = data.chartList[i]

                        const dashboardViewModel = new DashboardViewModel(chart);
                        self.chartjsList.push(dashboardViewModel);
                    }
                }
            }
        });
    }

    self.populateCharts();

    self.chartjsPerRowGroupedItems = ko.pureComputed(function () {
        const selected = self.chartjsPerRowSelected();

        const chartList = self.chartjsList();
        const perRow = parseInt(selected || '2');
        const result = [];
        for (let index = 0; index < chartList.length; index++) {
            const item = chartList[index];
            if (index % perRow === 0) {
                result.push([]);
            }
            result[result.length - 1].push(item);
        }
        return result;
    });
}

function DashboardViewModel(config) {
    var self = this;

    self.name = ko.observable(config.formattedName)
    self.chartType = ko.observable(config.chartjsType)
    self.data = ko.observable()
    self.options = ko.observable(config.options)

    self.chartInstance = null;
    self.setChartInstance = function (chartInstance) {
        self.chartInstance = chartInstance;
    }

    var params = {};
    params.config = config

    $.ajax({
        type: 'POST',
        contentType: 'application/json',
        dataType: 'JSON',
        url:fcConfig.reportConfigUrl,
        data:JSON.stringify(params.config),
        success:function(data) {
            if (data) {
                self.data(data)
                //CONFIG EKA GANIN DATA PUROPAN! EKEN EKATA..STATIC TEXT JSON EKE REPORT CONFIG DAPU EKAI ANITH EWAI COMPARE KARAPAN
            }
        }
    });
}

/**
 * Knockout view model for a Chart.js instance.
 * @param facet {object} The facet data.
 * @param chartType {string} The chart type.
 * @param chartConfig {object} The chart config.
 * @constructor
 */
function ChartjsViewModel(facet, chartType, chartConfig) {
    const self = this;

    /*
     * Functions to ease obtaining values for charts.
     */

    /**
     * Get the value of the given type, from a property in a container
     * @param container {object} The container.
     * @param propertyName {string} The property name.
     * @param valueType {string} The type of the value.
     * @param defaultValue {any|undefined} The value to use if the property is not set.
     * @returns {any} The obtained value or the default or undefined.
     */
    self.getValueFromChartContainer = function (container, propertyName, valueType, defaultValue) {
        const hasProp = Object.prototype.hasOwnProperty.call(container || {}, propertyName);
        let value = undefined;
        if (hasProp) {
            value = container[propertyName];
        } else if (defaultValue !== undefined) {
            value = defaultValue
        }

        if (value === null) {
            return value;
        }

        let result;
        switch (valueType) {
            case 'bool':
                result = value === undefined ? false : (value.toString() === 'true');
                break;
            case 'array':
                result = value === undefined ? [] : value;
                break;
            case 'int':
                try {
                    result = value === undefined ? 0 : parseInt(value.toString(), 10);
                } catch (e) {
                    console.error("[Chart] Could not convert '" + value + "' to int for property '" + propertyName + "'.", JSON.parse(JSON.stringify(e)));
                    return value;
                }
                break;
            case 'float':
                try {
                    result = value === undefined ? 0.0 : parseFloat(value.toString());
                } catch (e) {
                    console.error("[Chart] Could not convert '" + value + "' to float for property '" + propertyName + "'.", JSON.parse(JSON.stringify(e)));
                    return value;
                }
                break;
            case 'string':
                result = value === undefined ? '' : (value || '').toString();
                break;
            case 'object':
                result = value === undefined ? {} : value;
                break;
            default:
                console.error("[Chart] Unrecognised value type '" + valueType + "' for value '" + value + "'.");
                return value;
        }

        // console.warn("[Chart] Obtained '" + propertyName + "' value '" + result + "' of type '" + valueType + "'.");
        return result;
    };

    /**
     * Set the path of keys on a container to the given value.
     * The keys indicated nested properties on the container.
     * @param container {object} The container.
     * @param keys {string[]} The nested keys.
     * @param value {any} The value to set.
     */
    self.setContainerValue = function (container, keys, value) {
        if (value === undefined || value === null) {
            return;
        }
        if (!container) {
            console.error("[Chart] Must provide container to set a value.");
            return;
        }

        if (!keys) {
            keys = [];
        }
        const keysCount = keys.length;
        let currentContainer = container;
        for (let index = 0; index < keys.length; index++) {
            const key = keys[index];
            const hasProp = Object.prototype.hasOwnProperty.call(currentContainer, key);
            const isLast = index === (keysCount - 1);
            if (!hasProp && !isLast) {
                currentContainer[key] = {};
            }
            if (isLast) {
                currentContainer[key] = value;
            }
            if (!isLast) {
                currentContainer = currentContainer[key];
            }
        }
    }

    /**
     * Get the chart title, with addition of total record count if available.
     * @param chartConfig {object} The chart config.
     * @param totalRecords {?int} The total record count.
     * @returns {string} The new chart title.
     */
    self.getMainTitle = function (chartConfig, totalRecords) {
        const facetTitle = (facet.displayName ? facet.displayName() : (facet.title ? ko.unwrap(facet.title) : facet.name));
        const mainTitle = self.getValueFromChartContainer(chartConfig, 'mainTitle', 'string', facetTitle);
        const insertTotalAt = self.getValueFromChartContainer(chartConfig, 'mainTitleInsertTotalAt', 'int', null);

        let result = mainTitle;
        if (mainTitle && insertTotalAt !== null && insertTotalAt < mainTitle.length) {
            result = [
                mainTitle.slice(0, insertTotalAt),
                totalRecords + ' ',
                mainTitle.slice(insertTotalAt)
            ].join('');
        } else {
            console.log("[Chart] Did not modify main title: '" + mainTitle + "'. No valid value for insertTotalAt: '" + insertTotalAt + "'.")
        }
        return result;
    };

    self.buildChartDataItem = function (facet, value, rangeFrom, rangeTo, count, title) {

        if (value === undefined && facet && facet.type === 'term' && facet.term) {
            value = facet.term();
        }
        // use the count for the value for range facets
        if (value === undefined && facet && facet.type === 'range' && facet.count) {
            value = facet.count();
        }

        if (rangeFrom === undefined && facet && facet.from) {
            rangeFrom = facet.from();
        }
        if (rangeTo === undefined && facet && facet.to) {
            rangeTo = facet.to();
        }
        if (count === undefined && facet && facet.count) {
            count = facet.count();
        }
        if (title === undefined && facet) {
            if (facet.displayNameWithoutCount) {
                title = facet.displayNameWithoutCount();
            }
            if (!title && facet.displayName) {
                title = facet.displayName();
            }
            if (!title && facet.title) {
                title = facet.title();
            }
            if (!title && facet.name) {
                title = facet.name();
            }
            if (!title) {
                title = 'Unknown Item';
            }
        }

        return {
            value: value,
            rangeFrom: rangeFrom,
            rangeTo: rangeTo,
            count: count,
            title: title,
        }
    }

    /**
     * Count how many of the values in the term value fall within the passed in list of ranges.
     *
     * For example facet terms: [{term: 1, count: 3}, {term: 2, count: 2}, {term: 3, count: 1}]
     * and ranges: [{minVal:1,maxVal:2},{minVal:2.1,maxVal:3}]
     * will be converted to: [5, 1].
     *
     * For example facet range: [{"from": 2,"to": 3,"count": 2},{"from": 4,"to": 5,"count": 2},{"from": 5,"to": 6,"count": 1}]
     * (will override the provided range)
     * will be converted to: [2, 2, 1]
     *
     * @param data {array} The raw data.
     * @param ranges {array} The ranges to apply.
     * @returns {*[]} The chart data.
     */
    self.getChartDataRange = function (data, ranges) {
        const chartData = ranges.map(function (range) {
            const minVal = self.getValueFromChartContainer(range, 'minVal', 'float', null);
            const maxVal = self.getValueFromChartContainer(range, 'maxVal', 'float', null);
            return self.buildChartDataItem(undefined, 0, minVal, maxVal, 0, maxVal.toString());
        });

        for (let dataIndex = 0; dataIndex < data.length; dataIndex++) {
            const item = data[dataIndex];
            const termCount = self.getValueFromChartContainer(item, 'count', 'int', null);
            const termValue = self.getValueFromChartContainer(item, 'value', 'float', null);
            if (termCount === null || termValue === null) {
                console.error("[Chart] Could not convert value '" + item.value + "' to float.");
                continue;
            }

            let isAdded = false;
            for (let chartDataIndex = 0; chartDataIndex < chartData.length; chartDataIndex++) {
                const chartDataItem = chartData[chartDataIndex];
                if (termValue >= chartDataItem.rangeFrom && termValue <= chartDataItem.rangeTo) {
                    chartDataItem.count += termCount;
                    isAdded = true;
                    break;
                }
            }
            if (!isAdded) {
                console.warn("[Chart] Value '" + termValue + "' did not fit any of the ranges.",
                    JSON.parse(JSON.stringify({chartData: chartData, data: data, ranges: ranges})));
            }
        }

        // update values to be the counts
        chartData.forEach(function (item) {
            item.value = item.count;
        });

        return chartData;
    };

    /**
     * Update the chart data to be percentages if requested.
     * Converts chart data passed in as a list of values to percentage based on the total of records.
     * For example, for chart data: [3,2,1]
     * sums the total = 3 + 2 + 1 = 6 then calculates the percentage of what each value represents
     * Result: 3 = 50% of 6, 2 = 33.33% of 6 and 1 = 16.67% of 6.
     * @param rawData The raw data.
     * @param totalRecords The total number of records.
     * @returns {*[]} The updated chart data.
     */
    self.getChartDataPercentages = function (rawData, totalRecords) {
        const chartData = [];
        for (let i = 0; i < rawData.length; i++) {
            const item = rawData[i];
            const itemValue = parseFloat(item.value.toString());
            if (isNaN(itemValue)) {
                console.error("[Chart] Cannot convert non-numeric chart data to percentages.",
                    JSON.parse(JSON.stringify({rawData: rawData, totalRecords: totalRecords})));
                return rawData;
            }
            let value = itemValue * 100 / totalRecords;
            value = Math.round((value + Number.EPSILON) * 100) / 100;
            item.value = value;
            chartData.push(item);
        }
        return chartData;
    };

    /**
     * Parse facet terms in 'record level count' format: 'CustomChartDataItem|||[key]|||[count]'
     * @param facetTerms The facet terms.
     * @returns {*[]} Parsed terms matching the standard facet term array.
     */
    self.getChartDataCustomTerms = function (facetTerms) {
        const rawData = [];
        if (!facetTerms || facetTerms.length < 1) {
            return rawData;
        }
        const prefix = 'CustomChartDataItem';
        const sep = '|||';
        for (let i = 0; i < facetTerms.length; i++) {
            const term = facetTerms[i];
            const termCount = term.count();
            const termRaw = term.term();
            let termKey = '';
            let termValue = 0;
            if (termRaw.startsWith(prefix) && termRaw.indexOf(sep) > -1) {
                const termSplit = termRaw.split(sep);
                termKey = termSplit[1];
                termValue = parseInt(termSplit[2], 10);
            } else {
                console.error("[Chart] Could not parse custom chart data term '" + termRaw + "'.");
            }

            // increment term key count
            let existingIndex = rawData.findIndex(function (element) {
                return element.value === termKey;
            });
            if (existingIndex < 0) {
                const newItem = self.buildChartDataItem(undefined, termKey, null, null, 0, termKey);
                rawData.push(newItem);
            }
            existingIndex = rawData.findIndex(function (element) {
                return element.value === termKey;
            });
            rawData[existingIndex].count += (termCount * termValue);
        }

        return rawData;
    };

    /**
     * To change the tick marks to include information about the data type.
     *
     * For example, adding a dollar sign ('$').
     * To do this, you need to override the ticks.callback method in the axis configuration.
     *
     * The call to the method is scoped to the scale. this inside the method is the scale object.
     *
     * If the callback returns null or undefined the associated grid line will be hidden.
     *
     * Tick formatting: https://www.chartjs.org/docs/latest/axes/labelling.html#creating-custom-tick-formats
     *
     *
     * Notes:
     * - The category axis, which is the default x-axis for line and bar charts,
     *   uses the index as internal data format. For accessing the label, use this.getLabelForValue(value).
     * - Used as work around to avoid RangeError: minimumFractionDigits value is out of range:
     *   https://github.com/chartjs/Chart.js/issues/8092
     *
     * @param value {any} the tick value in the internal data format of the associated scale.
     * @param index {int}  the tick index in the ticks array.
     * @param ticks {Tick} the array containing all of the tick objects.
     * @returns {*}
     */
    self.getTickLabel = function (value, index, ticks) {
        return this.getLabelForValue(value);
    };

    /*
     * Create chart.js data and options structures for different chart types.
     *
     * A future optimisation could be to reduce the duplication here and build common config once,
     * then add any config specific to a chart type.
     */

    /**
     * Create the data for a bar chart.
     * @param facet {object} The facet data.
     * @param chartConfig {object} The chart config.
     * @param chartRawData {object} the raw chart data.
     * @returns {{datasets: *[]}} The chart data.
     */
    self.createChartBarData = function (facet, chartConfig, chartRawData) {
        const totalRecords = chartRawData.totalRecords;
        const chartData = chartRawData.data;
        const chartLabels = chartRawData.labels;
        const bgColors = chartRawData.bgColors;
        const borderColors = chartRawData.borderColors;

        const optTitleText = self.getMainTitle(chartConfig, totalRecords);
        const borderWidth = self.getValueFromChartContainer(chartConfig, 'borderWidth', 'int', null);

        const result = {datasets: []};
        self.setContainerValue(result, ['labels'], chartLabels);

        const dataset = {};
        self.setContainerValue(dataset, ['label'], optTitleText);
        self.setContainerValue(dataset, ['data'], chartData);
        self.setContainerValue(dataset, ['backgroundColor'], bgColors);
        self.setContainerValue(dataset, ['borderColor'], borderColors);
        self.setContainerValue(dataset, ['borderWidth'], borderWidth);
        result.datasets.push(dataset);

        return result;
    };

    /**
     * Create the options for a bar chart.
     * @param facet {object} The facet data.
     * @param chartConfig {object} The chart config.
     * @param chartRawData {object} the raw chart data.
     * @returns {{}} The chart options.
     */
    self.createChartBarOptions = function (facet, chartConfig, chartRawData) {
        const optTitleText = self.getMainTitle(chartConfig, chartRawData.totalRecords);

        const optLegendDisplay = self.getValueFromChartContainer(chartConfig, 'legendDisplay', 'bool', null);
        const optLegendPosition = self.getValueFromChartContainer(chartConfig, 'legendPosition', 'string', null);

        const optTitleDisplay = self.getValueFromChartContainer(chartConfig, 'mainTitleDisplay', 'bool', true);
        const optTitlePosition = self.getValueFromChartContainer(chartConfig, 'mainTitlePosition', 'string', null);
        const optTitleFontSize = self.getValueFromChartContainer(chartConfig, 'mainTitleFontSize', 'float', null);

        const optYScaleBeginAtZero = self.getValueFromChartContainer(chartConfig, 'yBeginAtZero', 'bool', null);

        const optYScaleDisplay = self.getValueFromChartContainer(chartConfig, 'yDisplay', 'bool', null);
        const optYScaleType = self.getValueFromChartContainer(chartConfig, 'yType', 'string', null);
        const optYScaleTitleDisplay = self.getValueFromChartContainer(chartConfig, 'yTitleDisplay', 'bool', null);
        const optYScaleTitle = self.getValueFromChartContainer(chartConfig, 'yTitle', 'string', null);

        const optXScaleDisplay = self.getValueFromChartContainer(chartConfig, 'xDisplay', 'bool', null);
        const optXScaleType = self.getValueFromChartContainer(chartConfig, 'xType', 'string', null);
        const optXScaleTitleDisplay = self.getValueFromChartContainer(chartConfig, 'xTitleDisplay', 'bool', null);
        const optXScaleTitle = self.getValueFromChartContainer(chartConfig, 'xTitle', 'string', null);

        const options = {};
        self.setContainerValue(options, ['plugins', 'legend', 'display'], optLegendDisplay);
        self.setContainerValue(options, ['plugins', 'legend', 'position'], optLegendPosition);

        self.setContainerValue(options, ['plugins', 'title', 'display'], optTitleDisplay);
        self.setContainerValue(options, ['plugins', 'title', 'text'], optTitleText);
        self.setContainerValue(options, ['plugins', 'title', 'position'], optTitlePosition);
        self.setContainerValue(options, ['plugins', 'title', 'font', 'size'], optTitleFontSize);

        self.setContainerValue(options, ['scales', 'y', 'beginAtZero'], optYScaleBeginAtZero);

        self.setContainerValue(options, ['scales', 'y', 'display'], optYScaleDisplay);
        self.setContainerValue(options, ['scales', 'y', 'type'], optYScaleType);
        self.setContainerValue(options, ['scales', 'y', 'title', 'display'], optYScaleTitleDisplay);
        self.setContainerValue(options, ['scales', 'y', 'title', 'text'], optYScaleTitle);

        self.setContainerValue(options, ['scales', 'y', 'ticks', 'callback'], self.getTickLabel);

        self.setContainerValue(options, ['scales', 'x', 'display'], optXScaleDisplay);
        self.setContainerValue(options, ['scales', 'x', 'type'], optXScaleType);
        self.setContainerValue(options, ['scales', 'x', 'title', 'display'], optXScaleTitleDisplay);
        self.setContainerValue(options, ['scales', 'x', 'title', 'text'], optXScaleTitle);

        self.setContainerValue(options, ['scales', 'x', 'ticks', 'callback'], self.getTickLabel);

        return options;
    };

    /**
     * Create the data for a pie chart.
     * @param facet {object} The facet data.
     * @param chartConfig {object} The chart config.
     * @param chartRawData {object} the raw chart data.
     * @returns {{datasets: *[]}} The chart data.
     */
    self.createChartPieData = function (facet, chartConfig, chartRawData) {
        const totalRecords = chartRawData.totalRecords;
        const chartData = chartRawData.data;
        const chartLabels = chartRawData.labels;
        const bgColors = chartRawData.bgColors;
        const borderColors = chartRawData.borderColors;

        const optTitleText = self.getMainTitle(chartConfig, totalRecords);
        const borderWidth = self.getValueFromChartContainer(chartConfig, 'borderWidth', 'int', null);
        const chartHoverOffset = self.getValueFromChartContainer(chartConfig, 'hoverOffset', 'int', null);

        const result = {datasets: []};
        self.setContainerValue(result, ['labels'], chartLabels);

        const dataset = {};
        self.setContainerValue(dataset, ['label'], optTitleText);
        self.setContainerValue(dataset, ['data'], chartData);
        self.setContainerValue(dataset, ['backgroundColor'], bgColors);
        self.setContainerValue(dataset, ['borderColor'], borderColors);
        self.setContainerValue(dataset, ['borderWidth'], borderWidth);
        self.setContainerValue(dataset, ['hoverOffset'], chartHoverOffset);
        result.datasets.push(dataset);

        return result;
    };

    /**
     * Create the options for a pie chart.
     * @param facet {object} The facet data.
     * @param chartConfig {object} The chart config.
     * @param chartRawData {object} the raw chart data.
     * @returns {{}} The chart options.
     */
    self.createChartPieOptions = function (facet, chartConfig, chartRawData) {
        const optTitleText = self.getMainTitle(chartConfig, chartRawData.totalRecords);

        const optTitlePosition = self.getValueFromChartContainer(chartConfig, 'mainTitlePosition', 'string', null);
        const optTitleDisplay = self.getValueFromChartContainer(chartConfig, 'mainTitleDisplay', 'bool', true);
        const optResponsive = self.getValueFromChartContainer(chartConfig, 'responsive', 'bool', null);
        const optTitleFontSize = self.getValueFromChartContainer(chartConfig, 'mainTitleFontSize', 'float', null);
        const optLegendPosition = self.getValueFromChartContainer(chartConfig, 'legendPosition', 'bool', null);
        const optLegendDisplay = self.getValueFromChartContainer(chartConfig, 'legendDisplay', 'bool', null);

        const options = {};
        self.setContainerValue(options, ['responsive'], optResponsive);

        self.setContainerValue(options, ['plugins', 'legend', 'display'], optLegendDisplay);
        self.setContainerValue(options, ['plugins', 'legend', 'position'], optLegendPosition);

        self.setContainerValue(options, ['plugins', 'title', 'display'], optTitleDisplay);
        self.setContainerValue(options, ['plugins', 'title', 'text'], optTitleText);
        self.setContainerValue(options, ['plugins', 'title', 'position'], optTitlePosition);
        self.setContainerValue(options, ['plugins', 'title', 'font', 'size'], optTitleFontSize);

        return options;
    };

    /**
     * Get line chart data.
     * @param facet {object} The facet.
     * @param chartConfig {object} The chart config.
     * @param chartRawData {object} The raw chart data.
     * @returns {{datasets: *[]}} The chart data.
     */
    self.createChartLineData = function (facet, chartConfig, chartRawData) {
        const totalRecords = chartRawData.totalRecords;
        const chartData = chartRawData.data;
        const chartLabels = chartRawData.labels;
        const bgColors = chartRawData.bgColors;
        const borderColors = chartRawData.borderColors;

        const optTitleText = self.getMainTitle(chartConfig, totalRecords);
        const borderWidth = self.getValueFromChartContainer(chartConfig, 'borderWidth', 'int', null);
        const chartFill = self.getValueFromChartContainer(chartConfig, 'lineChartFill', 'bool', null);
        const chartTension = self.getValueFromChartContainer(chartConfig, 'lineChartTension', 'float', null);

        const result = {datasets: []};
        self.setContainerValue(result, ['labels'], chartLabels);

        const dataset = {};
        self.setContainerValue(dataset, ['label'], optTitleText);
        self.setContainerValue(dataset, ['data'], chartData);
        self.setContainerValue(dataset, ['backgroundColor'], bgColors);
        self.setContainerValue(dataset, ['borderColor'], borderColors);
        self.setContainerValue(dataset, ['borderWidth'], borderWidth);
        self.setContainerValue(dataset, ['fill'], chartFill);
        self.setContainerValue(dataset, ['tension'], chartTension);
        result.datasets.push(dataset);

        return result;
    };

    /**
     * Get the options for a line chart.
     * @param facet {object} The facet.
     * @param chartConfig {object} The chart config.
     * @param chartRawData {object} The raw chart data.
     * @returns {{}} The chart options.
     */
    self.createChartLineOptions = function (facet, chartConfig, chartRawData) {
        const optTitleText = self.getMainTitle(chartConfig, chartRawData.totalRecords);

        const optStacked = self.getValueFromChartContainer(chartConfig, 'yStacked', 'bool', null);

        const optTitlePosition = self.getValueFromChartContainer(chartConfig, 'mainTitlePosition', 'string', null);
        const optTitleDisplay = self.getValueFromChartContainer(chartConfig, 'mainTitleDisplay', 'bool', true);
        const optTitleFontSize = self.getValueFromChartContainer(chartConfig, 'mainTitleFontSize', 'float', null);
        const optLegendPosition = self.getValueFromChartContainer(chartConfig, 'legendPosition', 'bool', null);
        const optLegendDisplay = self.getValueFromChartContainer(chartConfig, 'legendDisplay', 'bool', null);

        const optYScaleDisplay = self.getValueFromChartContainer(chartConfig, 'yDisplay', 'bool', null);
        const optYScaleType = self.getValueFromChartContainer(chartConfig, 'yType', 'string', null);
        const optYScaleTitleDisplay = self.getValueFromChartContainer(chartConfig, 'yTitleDisplay', 'bool', null);
        const optYScaleTitle = self.getValueFromChartContainer(chartConfig, 'yTitle', 'string', null);

        const optXScaleDisplay = self.getValueFromChartContainer(chartConfig, 'xDisplay', 'bool', null);
        const optXScaleType = self.getValueFromChartContainer(chartConfig, 'xType', 'string', null);
        const optXScaleTitleDisplay = self.getValueFromChartContainer(chartConfig, 'xTitleDisplay', 'bool', null);
        const optXScaleTitle = self.getValueFromChartContainer(chartConfig, 'xTitle', 'string', null);

        const options = {};
        self.setContainerValue(options, ['scales', 'y', 'stacked'], optStacked);

        self.setContainerValue(options, ['plugins', 'legend', 'display'], optLegendDisplay);
        self.setContainerValue(options, ['plugins', 'legend', 'position'], optLegendPosition);

        self.setContainerValue(options, ['plugins', 'title', 'display'], optTitleDisplay);
        self.setContainerValue(options, ['plugins', 'title', 'text'], optTitleText);
        self.setContainerValue(options, ['plugins', 'title', 'position'], optTitlePosition);
        self.setContainerValue(options, ['plugins', 'title', 'font', 'size'], optTitleFontSize);

        self.setContainerValue(options, ['scales', 'y', 'display'], optYScaleDisplay);
        self.setContainerValue(options, ['scales', 'y', 'type'], optYScaleType);
        self.setContainerValue(options, ['scales', 'y', 'title', 'display'], optYScaleTitleDisplay);
        self.setContainerValue(options, ['scales', 'y', 'title', 'text'], optYScaleTitle);

        self.setContainerValue(options, ['scales', 'y', 'ticks', 'callback'], self.getTickLabel);

        self.setContainerValue(options, ['scales', 'x', 'display'], optXScaleDisplay);
        self.setContainerValue(options, ['scales', 'x', 'type'], optXScaleType);
        self.setContainerValue(options, ['scales', 'x', 'title', 'display'], optXScaleTitleDisplay);
        self.setContainerValue(options, ['scales', 'x', 'title', 'text'], optXScaleTitle);

        self.setContainerValue(options, ['scales', 'x', 'ticks', 'callback'], self.getTickLabel);

        return options;
    };

    /*
     * Observables
     */

    // base data used to build everything else
    self.transients = {};
    self.transients.facet = ko.observable(facet);

    // 'chartConfig' is using a pre defined and simplified config in JSON format stored in chartjsConfig that
    // has to be consistent with chartjsType which has been selected in the hub config for the facet.
    self.transients.chartConfig = ko.observable(chartConfig);

    // observables for ko custom binding
    self.chartFacetName = ko.pureComputed(function () {
        const facet = self.transients.facet();
        return facet.name();
    });
    self.chartType = ko.observable(chartType);
    self.chartData = ko.pureComputed(function () {
        const facet = self.transients.facet();
        const chartConfig = self.transients.chartConfig();
        const chartRawData = self.transients.chartRawData();
        const builder = self.transients.getChartBuilder();

        if (facet && chartRawData && builder) {
            return builder.data(facet, chartConfig, chartRawData);
        } else {
            console.error("[Chart] Could not build chart data.",
                JSON.parse(JSON.stringify({
                    facet: facet,
                    chartConfig: chartConfig,
                    chartRawData: chartRawData,
                    builder: builder
                })));
            return null;
        }
    });
    self.chartOptions = ko.pureComputed(function () {
        const facet = self.transients.facet();
        const chartConfig = self.transients.chartConfig();
        const chartRawData = self.transients.chartRawData();
        const builder = self.transients.getChartBuilder();

        if (facet && chartRawData && builder) {
            return builder.options(facet, chartConfig, chartRawData);
        } else {
            console.error("[Chart] Could not build chart options.",
                JSON.parse(JSON.stringify({
                    facet: facet,
                    chartConfig: chartConfig,
                    chartRawData: chartRawData,
                    builder: builder
                })));
            return null;
        }
    });

    self.transients.haveRequestedAllTerms = ko.observable(false);

    /*
     * self.chartInstance:
     * Placeholder for the chart instance that needs to be accessible by the custom knockout binding. This instance reference
     * is required to be accessible by the update method to be able to call destroy() directly on the given chartjs instance
     * otherwise chartjs throws an exception "Canvas is already in use. Chart with ID 'n' must be destroyed before the canvas
     * can be reused." and calling the destroy() method on the canvas doesn't work. See below SO question for more details:
     * https://stackoverflow.com/questions/40056555/destroy-chart-js-bar-graph-to-redraw-other-graph-in-same-canvas
     */
    self.chartInstance = null;
    self.setChartInstance = function (chartInstance) {
        self.chartInstance = chartInstance;
    }

    self.transients.getChartBuilder = ko.pureComputed(function () {
        const chartType = self.chartType();
        switch (chartType) {
            case 'pie':
                return {data: self.createChartPieData, options: self.createChartPieOptions};
            case 'bar':
                return {data: self.createChartBarData, options: self.createChartBarOptions};
            case 'line':
                return {data: self.createChartLineData, options: self.createChartLineOptions};
            default:
                console.error("[Chart] Unrecognised chart type '" + chartType + "'.");
                return null;
        }
    });

    /**
     * Build the chart data and labels using the provided labels and order.
     * If mainLabels is provided, use it to modify the chart data and labels.
     * @param chartDataRaw {[]} All available chart data.
     * @param chartLabelsRaw {[{originalLabel: string, newLabel: string|undefined}]} The labels built from the facet.
     * @param mainLabels {[{originalLabel: string, newLabel: string|undefined}]} The label modifications from the chart config.
     * @param showAllLabels {boolean} True to include labels that have no data, false to exclude data that is 0 (and associated label).
     * @returns {{data: *[], labels: string[]}} The data and labels for the chart.
     */
    self.orderDataFromLabels = function (chartDataRaw, chartLabelsRaw,
                                         mainLabels, showAllLabels) {
        const chartLabels = [];
        const chartData = [];
        const missingMainLabels = [];
        const missingFacetLabels = [];

        // The format of mainLabels is an optional array of objects, where:
        // - the array order defines the desired order of the labels and data
        // - each item is an object: { originalLabel: '', newLabel: ''}
        // The originalLabel must match one of the labels from the facet data.

        // This allows for two things: changing the order of the labels, and changing the labels.

        // If mainLabels is defined, the data and labels will be ordered accordingly.
        // If mainLabels is not defined, the labels and order will be drawn from the facets data and
        // in the order that the facets data is retrieved from the elastic search.
        let mainLabelsInvalidFormat = false;
        if (mainLabels === null) {
            chartLabelsRaw.forEach(function (value) {
                chartLabels.push(value.originalLabel);
            });
            chartDataRaw.forEach(function (value) {
                chartData.push(value);
            });

        } else {

            chartLabelsRaw.forEach(function (chartLabelRaw) {
                const foundIndex = mainLabels.findIndex(function (mainLabel) {
                    return chartLabelRaw.originalLabel === mainLabel.originalLabel;
                })
                if (foundIndex < 0) {
                    missingFacetLabels.push(chartLabelRaw.originalLabel)
                }
            });

            for (let i = 0; i < mainLabels.length; i++) {
                const mainLabelItem = mainLabels[i];

                if (mainLabelItem.originalLabel === undefined) {
                    mainLabelsInvalidFormat = true;
                }

                const originalLabel = mainLabelItem.originalLabel;
                let newLabel = mainLabelItem.newLabel;

                if (newLabel === null || newLabel === undefined) {
                    newLabel = originalLabel;
                }

                // find the index of the original label
                const originalIndex = chartLabelsRaw.findIndex(function (value) {
                    return value.originalLabel === originalLabel;
                });

                if (originalIndex < 0 && !showAllLabels) {
                    missingMainLabels.push(mainLabelItem);

                } else if (originalIndex < 0 && showAllLabels) {
                    // add the label and chart data of 0
                    chartLabels.push(newLabel);
                    chartData.push(0);

                } else {
                    // add the label item and data item
                    const dataItem = chartDataRaw[originalIndex];
                    if (showAllLabels || dataItem !== 0) {
                        chartLabels.push(newLabel);
                        chartData.push(dataItem);
                    }
                }
            }
        }

        if (mainLabels && mainLabelsInvalidFormat) {
            console.error("[Chart] The chart config for mainLabels is not in the expected format: '[{originalLabel: 'label', newLabel: 'label'}, ...]'.",
                JSON.parse(JSON.stringify(mainLabels)));
        }

        if (missingMainLabels.length > 0) {
            console.warn("[Chart] Some originalLabel items in mainLabels were not found in the facet labels. " +
                "This might be because there is no data for the label, which is fine.",
                JSON.parse(JSON.stringify({facetLabels: chartLabelsRaw, missingMainLabels: missingMainLabels})));
        }

        if (missingFacetLabels.length > 0) {
            console.error("[Chart] Some facet labels were not found in mainLabels. " +
                "The data items for the missing labels have been excluded.",
                JSON.parse(JSON.stringify({mainLabels: mainLabels, missingFacetLabels: missingFacetLabels})));
        }

        const result = {labels: chartLabels, data: chartData};

        console.log("[Chart] Processed chart data and labels ordering.",
            JSON.parse(JSON.stringify({
                chartDataRaw: chartDataRaw,
                chartLabelsRaw: chartLabelsRaw,
                mainLabels: mainLabels,
                showAllLabels: showAllLabels,
                chartLabels: chartLabels,
                chartData: chartData,
            }))
        );

        return result;
    }

    /**
     * Extract the chart data from the facet and config data.
     */
    self.transients.chartRawData = ko.computed(function () {
        const facet = self.transients.facet();
        const facetType = facet.type;
        const facetName = facet.name();
        const chartConfig = self.transients.chartConfig();
        const facetAllTerms = facet.allTermsList();
        const facetTermCountLimit = facet.ref.flimit;
        const haveRequestedAllTerms = self.transients.haveRequestedAllTerms();
        const hasFacetAllTerms = facetAllTerms.length > 0;

        let facetItems = facet.terms() || [];

        const isTypeTerms = facetType === 'terms';
        const isTypeRange = facetType === 'range';

        // A term facet that has more terms needs to load them first
        // When the full term list has loaded, this computed should be re-evaluated because
        // it depends on the observable that holds the full list: 'allTermsList'.
        if (isTypeTerms && facetItems.length >= facetTermCountLimit && !haveRequestedAllTerms && !hasFacetAllTerms) {
            console.log("[Chart] Retrieving all terms for facet '" + facetName + "'. Not providing chart data.");
            self.transients.haveRequestedAllTerms(true);
            facet.getAllFacetTerms();
            return null;
        } else if (isTypeTerms && hasFacetAllTerms) {
            console.log("[Chart] Obtained full list of terms for facet '" + facetName + "'. The chart data will be provided.");
            facetItems = facetAllTerms;
        } else {
            console.log("[Chart] Number of facet items '" + facetItems.length.toString() + "' " +
                "is less than the limit '" + facetTermCountLimit.toString() + "' " +
                "for facet '" + facetName + "'. The chart data will be provided.");
        }

        // get settings for processing chart data
        let useCount = self.getValueFromChartContainer(chartConfig, 'dataUseCount', 'bool', false);
        let applyRanges = self.getValueFromChartContainer(chartConfig, 'dataApplyRanges', 'array', []);
        let shouldApplyRanges = applyRanges.length > 0;
        const toPercentages = self.getValueFromChartContainer(chartConfig, 'dataToPercentage', 'bool', false);
        let isCustomChartData = self.getValueFromChartContainer(chartConfig, 'dataIsCustomChartData', 'bool', false);

        // check settings make sense
        // range facet can only use dataToPercentage. Note that ranges use the count as the value.
        // term facet can do useCount (first), applyRange (second), toPercentages (third), all optional, if specified are applied in this order.
        if (!isTypeTerms && isCustomChartData) {
            console.error("[Chart] Custom chart data must be provided by term facet only, facet '" + facetName + "' is '" + facetType + "' type. " +
                "Will set dataIsCustomChartData to false.");
            isCustomChartData = false;
        }

        if (isTypeRange && shouldApplyRanges) {
            console.error("[Chart] Cannot apply ranges to range facet '" + facetName + "'. Will set dataApplyRanges to empty array.");
            applyRanges = [];
            shouldApplyRanges = false;
        }

        if (isTypeRange && useCount) {
            console.error("[Chart] Cannot use count for range facet '" + facetName + "'. Will set dataUseCount to false.");
            useCount = false;
        }

        // obtain the raw data
        let rawData = [];

        // parse the raw data
        if (isTypeTerms && isCustomChartData) {
            console.log("[Chart] Parsing '" + facetItems.length + "' facet term custom chart items for facet '" + facetName + "'.");
            rawData = self.getChartDataCustomTerms(facetItems);

        } else if (isTypeTerms && !isCustomChartData) {
            console.log("[Chart] Parsing '" + facetItems.length + "' facet term items for facet '" + facetName + "'.");
            rawData = facetItems.map(function (item) {
                return self.buildChartDataItem(item);
            });

        } else if (isTypeRange) {
            console.log("[Chart] Parsing '" + facetItems.length + "' facet range items for facet '" + facetName + "'.");
            rawData = facetItems.map(function (item) {
                return self.buildChartDataItem(item);
            });

        } else {
            console.error("[Chart] Did not parse '" + facetItems.length + "' facet items for facet '" + facetName + "'.");
        }

        // convert term facet to use counts if requested
        if (useCount) {
            console.log("[Chart] Converting to counts for facet '" + facetName + "'.");
            rawData.forEach(function (item) {
                item.value = item.count;
                item.count = 1;
            });
        } else {
            // check that item.value can be parsed to floats, as the values must be numbers to be properly displayed
            const rawDataIsNumbers = rawData.every(function (item) {
                return !isNaN(parseFloat(item.value));
            });
            if (!rawDataIsNumbers) {
                console.warn("[Chart] The values to be used as chart data do not look like numbers. " +
                    "Consider setting 'dataUseCount': 'true'.",
                    JSON.parse(JSON.stringify(rawData)));
            }
        }

        // convert term facet to range if requested
        if (shouldApplyRanges) {
            console.log("[Chart] Converting term data to range for facet '" + facetName + "'.");
            // bucket values for a term facet
            rawData = self.getChartDataRange(rawData, applyRanges);
        }

        // get total term count and total record count
        const totalTerms = rawData.length;
        const totalRecords = rawData.reduce(function (previous, current) {
            return previous + (useCount ? current.value : current.count);
        }, 0);

        // convert to percentages
        if (toPercentages) {
            console.log("[Chart] Obtaining data percentages for facet '" + facetName + "'.");
            rawData = self.getChartDataPercentages(rawData, totalRecords);
        }

        // get the chart labels
        const mainLabels = self.getValueFromChartContainer(chartConfig, 'mainLabels', 'array', null);
        const chartLabelsRaw = rawData.map(function (item) {
            return {originalLabel: item.title};
        });

        // get the chart data
        const chartDataRaw = rawData.map(function (item) {
            return item.value;
        });

        // check that array settings match the number of chart labels
        const chartLabelsLength = mainLabels !== null ? mainLabels.length : chartLabelsRaw.length;

        const borderColorsAvailable = self.getValueFromChartContainer(chartConfig, 'borderColorsAvailable', 'array', null);
        const borderColorsLength = borderColorsAvailable ? borderColorsAvailable.length : 0;

        const bgColorsAvailable = self.getValueFromChartContainer(chartConfig, 'bgColorsAvailable', 'array', null);
        const bgColorsLength = bgColorsAvailable ? bgColorsAvailable.length : 0;

        if (borderColorsAvailable && borderColorsLength > 0 && borderColorsLength < chartLabelsLength) {
            console.error("[Chart] Length of borderColorsAvailable (" + borderColorsLength.toString() + ") " +
                "is less than length of chart labels (" + chartLabelsLength.toString() + ").",
                JSON.parse(JSON.stringify({chartLabelsRaw: chartLabelsRaw, mainLabels: mainLabels})));
        }
        if (bgColorsAvailable && bgColorsLength > 0 && bgColorsLength < chartLabelsLength) {
            console.error("[Chart] Length of bgColorsAvailable (" + bgColorsLength.toString() + ") " +
                "is less than length of chart labels (" + chartLabelsLength.toString() + ").",
                JSON.parse(JSON.stringify({chartLabelsRaw: chartLabelsRaw, mainLabels: mainLabels})));
        }
        if (shouldApplyRanges && applyRanges.length !== chartLabelsLength) {
            console.error("[Chart] Length of dataApplyRanges (" + applyRanges.length.toString() + ") " +
                "does not match length of chart labels (" + chartLabelsLength.toString() + ").",
                JSON.parse(JSON.stringify({chartLabelsRaw: chartLabelsRaw, mainLabels: mainLabels})));
        }

        // Build the chart info by reordering the data and labels or replacing the labels.
        const showAllLabels = self.getValueFromChartContainer(chartConfig, 'mainLabelsShowAll', 'bool', true);
        const chartInfo = self.orderDataFromLabels(chartDataRaw, chartLabelsRaw, mainLabels, showAllLabels);

        const result = {
            labels: chartInfo.labels,
            data: chartInfo.data,
            totalTerms: totalTerms,
            totalRecords: totalRecords,
            bgColors: bgColorsAvailable,
            borderColors: borderColorsAvailable,
        };

        // validate output items
        if (!chartInfo.labels || chartInfo.labels.length < 1 ||
            !chartInfo.data || chartInfo.data.length < 1 ||
            totalTerms < 1 || totalRecords < 1) {
            console.warn("[Chart] Some data not available for chart for facet '" + facetName + "' " +
                "with chart type '" + chartType + "'.", JSON.parse(JSON.stringify(result)));
        }
        return result;
    });
}
