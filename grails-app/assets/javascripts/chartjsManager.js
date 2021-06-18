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
        return self.chartjsList().length > 0;
    });

    /**
     * The options for number of charts to show per line.
     */
    self.chartjsPerRowOptions = ko.observableArray(['2', '3', '4']);

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
        return 'span' + perRow.toString();
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
        const mainTitle = self.getValueFromChartContainer(chartConfig, 'mainTitle', 'string', ' items for ' + facetTitle);
        const insertTotalAt = self.getValueFromChartContainer(chartConfig, 'mainTitleInsertTotalAt', 'int', 0);

        let result = '';
        if (mainTitle) {
            if (insertTotalAt >= 0 && mainTitle.length > insertTotalAt) {
                result = [
                    mainTitle.slice(0, insertTotalAt),
                    totalRecords + ' ',
                    mainTitle.slice(insertTotalAt)
                ].join('');
            } else {
                console.warn("[Chart] Did not modify main title '" + mainTitle + "' insertTotalAt: '" + insertTotalAt.toString() + "'.")
            }
        }
        return result;
    };

    /**
     * Keep a subset or all of an array.
     * @param items {*[]} The array of items.
     * @param keepAll {boolean} Whether to keep all items.
     * @param maxItems {?int} An optional maximum count.
     * @returns {*[]} The selected items from the array.
     */
    self.getArraySubset = function (items, keepAll, maxItems) {
        if (items === undefined || items === null) {
            return [];
        }
        const result = [];
        for (let index = 0; index < items.length; index++) {
            const label = items[index];
            if (keepAll || !maxItems) {
                result.push(label);
            } else if (index < maxItems) {
                result.push(label);
            }
        }
        return result;
    };

    self.buildChartDataItem = function (facet, value, rangeFrom, rangeTo, count, title) {
        if (value === undefined && facet && facet.term) {
            value = facet.term();
        }
        // use the upper bound for the value for range facets
        if (value === undefined && facet && facet.to) {
            value = facet.to();
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
            } else if (facet.displayName) {
                title = facet.displayName();
            } else if (facet.title) {
                title = facet.title();
            } else if (facet.name) {
                title = facet.name();
            } else {
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
            return self.buildChartDataItem(undefined, 0, minVal, maxVal, 0, maxVal);
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
                    JSON.parse(JSON.stringify(chartData)),
                    JSON.parse(JSON.stringify(data)),
                    JSON.parse(JSON.stringify(ranges)),
                );
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
                    totalRecords,
                    JSON.parse(JSON.stringify(rawData)));
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
     * Parse facet terms in 'unique count' format: 'CustomChartDataItem|||[key]|||[count]'
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

    /*
     * Create chart.js data and options structures for different chart types.
     */

    /**
     * Create the data for a bar chart.
     * @param facet {object} The facet data.
     * @param chartConfig {object} The chart config.
     * @param chartRawData {object} the raw chart data.
     * @returns {{datasets: *[]}} The chart data.
     */
    self.createChartBarData = function (facet, chartConfig, chartRawData) {
        const borderColors = self.getValueFromChartContainer(chartConfig, 'borderColorsAvailable', 'array', chartRawData.labels);
        const borderWidth = self.getValueFromChartContainer(chartConfig, 'borderWidth', 'int', null);

        const optTitleText = self.getMainTitle(chartConfig, chartRawData.totalRecords);

        const mainLabels = self.getValueFromChartContainer(chartConfig, 'mainLabels', 'array', null);
        const showAllLabels = self.getValueFromChartContainer(chartConfig, 'mainLabelsShowAll', 'bool', true);
        const chartLabels = self.getArraySubset(mainLabels, showAllLabels, chartRawData.totalTerms);

        const bgColorsAvailable = self.getValueFromChartContainer(chartConfig, 'bgColorsAvailable', 'array', null);
        const bgColors = self.getArraySubset(bgColorsAvailable, showAllLabels, chartRawData.totalTerms);

        const result = {datasets: []};
        self.setContainerValue(result, ['labels'], chartLabels);

        const dataset = {};
        self.setContainerValue(dataset, ['label'], optTitleText);
        self.setContainerValue(dataset, ['data'], chartRawData.data);
        self.setContainerValue(dataset, ['backgroundColor'], bgColors);
        self.setContainerValue(dataset, ['borderColor'], borderColors);
        self.setContainerValue(dataset, ['borderWidth'], borderWidth);
        result.datasets.push(dataset);

        console.warn(JSON.parse(JSON.stringify(result)));

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

        const optTitlePosition = self.getValueFromChartContainer(chartConfig, 'mainTitlePosition', 'string', null);
        const optYScaleTitle = self.getValueFromChartContainer(chartConfig, 'yTitle', 'string', null);
        const optXScaleTitle = self.getValueFromChartContainer(chartConfig, 'xTitle', 'string', null);
        const optXScaleType = self.getValueFromChartContainer(chartConfig, 'xType', 'string', null);
        const optXScaleLabels = self.getValueFromChartContainer(chartConfig, 'xLabels', 'array', null);
        const optLegendPosition = self.getValueFromChartContainer(chartConfig, 'legendPosition', 'string', null);
        const optYScaleBeginAtZero = self.getValueFromChartContainer(chartConfig, 'yBeginAtZero', 'bool', null);
        const optYScaleDisplay = self.getValueFromChartContainer(chartConfig, 'yDisplay', 'bool', null);
        const optYScaleTitleDisplay = self.getValueFromChartContainer(chartConfig, 'yTitleDisplay', 'bool', null);
        const optXScaleDisplay = self.getValueFromChartContainer(chartConfig, 'xDisplay', 'bool', null);
        const optXScaleTitleDisplay = self.getValueFromChartContainer(chartConfig, 'xTitleDisplay', 'bool', null);
        const optLegendDisplay = self.getValueFromChartContainer(chartConfig, 'legendDisplay', 'bool', null);
        const optTitleDisplay = self.getValueFromChartContainer(chartConfig, 'mainTitleDisplay', 'bool', null);

        const options = {};
        self.setContainerValue(options, ['plugins', 'legend', 'display'], optLegendDisplay);
        self.setContainerValue(options, ['plugins', 'legend', 'position'], optLegendPosition);

        self.setContainerValue(options, ['plugins', 'title', 'display'], optTitleDisplay);
        self.setContainerValue(options, ['plugins', 'title', 'text'], optTitleText);
        self.setContainerValue(options, ['plugins', 'title', 'position'], optTitlePosition);

        self.setContainerValue(options, ['scales', 'y', 'beginAtZero'], optYScaleBeginAtZero);
        self.setContainerValue(options, ['scales', 'y', 'display'], optYScaleDisplay);
        self.setContainerValue(options, ['scales', 'y', 'title', 'display'], optYScaleTitleDisplay);
        self.setContainerValue(options, ['scales', 'y', 'title', 'text'], optYScaleTitle);

        // Work around to avoid RangeError: minimumFractionDigits value is out of range
        // https://github.com/chartjs/Chart.js/issues/8092
        self.setContainerValue(options, ['scales', 'y', 'ticks', 'callback'], function (value) {
            return value;
        });

        self.setContainerValue(options, ['scales', 'x', 'display'], optXScaleDisplay);
        self.setContainerValue(options, ['scales', 'x', 'type'], optXScaleType);
        self.setContainerValue(options, ['scales', 'x', 'labels'], optXScaleLabels);
        self.setContainerValue(options, ['scales', 'x', 'title', 'display'], optXScaleTitleDisplay);
        self.setContainerValue(options, ['scales', 'x', 'title', 'text'], optXScaleTitle);

        // Work around to avoid RangeError: minimumFractionDigits value is out of range
        // https://github.com/chartjs/Chart.js/issues/8092
        self.setContainerValue(options, ['scales', 'x', 'ticks', 'callback'], function (value) {
            return value;
        });

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
        const mainLabels = self.getValueFromChartContainer(chartConfig, 'mainLabels', 'array', chartRawData.labels);
        const showAllLabels = self.getValueFromChartContainer(chartConfig, 'mainLabelsShowAll', 'bool', true);
        const chartLabels = self.getArraySubset(mainLabels, showAllLabels, chartRawData.totalTerms);

        const optTitleText = self.getMainTitle(chartConfig, chartRawData.totalRecords);

        const bgColorsAvailable = self.getValueFromChartContainer(chartConfig, 'bgColorsAvailable', 'array', null);
        const bgColors = self.getArraySubset(bgColorsAvailable, showAllLabels, chartRawData.totalTerms);

        const chartHoverOffset = self.getValueFromChartContainer(chartConfig, 'hoverOffset', 'int', null);

        const result = {datasets: []};
        self.setContainerValue(result, ['labels'], chartLabels);

        const dataset = {};
        self.setContainerValue(dataset, ['label'], optTitleText);
        self.setContainerValue(dataset, ['data'], chartRawData.data);
        self.setContainerValue(dataset, ['backgroundColor'], bgColors);
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

        const optPosition = self.getValueFromChartContainer(chartConfig, 'mainTitlePosition', 'string', 'top');
        const optDisplay = self.getValueFromChartContainer(chartConfig, 'mainTitleDisplay', 'bool', true);
        const optResponsive = self.getValueFromChartContainer(chartConfig, 'responsive', 'bool', null);

        const result = {};
        self.setContainerValue(result, ['responsive'], optResponsive);
        self.setContainerValue(result, ['plugins', 'legend', 'position'], optPosition);
        self.setContainerValue(result, ['plugins', 'title', 'display'], optDisplay);
        self.setContainerValue(result, ['plugins', 'title', 'text'], optTitleText);

        return result;
    };

    /**
     * Get line chart data.
     * @param facet {object} The facet.
     * @param chartConfig {object} The chart config.
     * @param chartRawData {object} The raw chart data.
     * @returns {{datasets: *[]}} The chart data.
     */
    self.createChartLineData = function (facet, chartConfig, chartRawData) {
        const chartFill = self.getValueFromChartContainer(chartConfig, 'lineChartFill', 'bool', null);
        const chartTension = self.getValueFromChartContainer(chartConfig, 'lineChartTension', 'float', null);

        const optTitleText = self.getMainTitle(chartConfig, chartRawData.totalRecords);

        const mainLabels = self.getValueFromChartContainer(chartConfig, 'mainLabels', 'array', null);
        const showAllLabels = self.getValueFromChartContainer(chartConfig, 'mainLabelsShowAll', 'bool', true);
        const chartLabels = self.getArraySubset(mainLabels, showAllLabels, chartRawData.totalTerms);

        const bgColorsAvailable = self.getValueFromChartContainer(chartConfig, 'bgColorsAvailable', 'array', null);
        const borderColors = self.getArraySubset(bgColorsAvailable, showAllLabels, chartRawData.totalTerms);

        const result = {datasets: []};
        self.setContainerValue(result, ['labels'], chartLabels || chartRawData.labels);

        const dataset = {};
        self.setContainerValue(dataset, ['label'], optTitleText);
        self.setContainerValue(dataset, ['data'], chartRawData.data);
        self.setContainerValue(dataset, ['fill'], chartFill);
        self.setContainerValue(dataset, ['borderColor'], borderColors);
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
        const optStacked = self.getValueFromChartContainer(chartConfig, 'yStacked', 'bool', null);

        const result = {};
        self.setContainerValue(result, ['scales', 'y', 'stacked'], optStacked);
        return result;
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

        if (facet && chartConfig && chartRawData && builder) {
            return builder.data(facet, chartConfig, chartRawData);
        } else {
            // console.error("[Chart] Could not build chart data.",
            //     JSON.parse(JSON.stringify(facet)),
            //     JSON.parse(JSON.stringify(chartConfig)),
            //     JSON.parse(JSON.stringify(chartRawData)),
            //     JSON.parse(JSON.stringify(builder))
            // );
            return null;
        }
    });
    self.chartOptions = ko.pureComputed(function () {
        const facet = self.transients.facet();
        const chartConfig = self.transients.chartConfig();
        const chartRawData = self.transients.chartRawData();
        const builder = self.transients.getChartBuilder();

        if (facet && chartConfig && chartRawData && builder) {
            return builder.options(facet, chartConfig, chartRawData);
        } else {
            // console.error("[Chart] Could not build chart options.",
            //     JSON.parse(JSON.stringify(facet)),
            //     JSON.parse(JSON.stringify(chartConfig)),
            //     JSON.parse(JSON.stringify(chartRawData)),
            //     JSON.parse(JSON.stringify(builder))
            //     );
            return null;
        }
    });

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
     * Extract the chart data from the facet and config data.
     */
    self.transients.chartRawData = ko.computed(function () {
        const facet = self.transients.facet();
        const facetType = facet.type;
        const facetName = facet.name();
        const chartConfig = self.transients.chartConfig();
        const facetAllTerms = facet.allTermsList();
        let facetItems = facet.terms() || [];
        const facetTermCountLimit = facet.ref.flimit;

        const isTypeTerms = facetType === 'terms'
        const isTypeRange = facetType === 'range'

        // A term facet that has more terms needs to load them first
        // When the full term list has loaded, this computed should be re-evaluated because
        // it depends on the observable that holds the full list: 'showMoreTermList'.

        // if (facetType === 'terms' && facetItems.length >= facetTermCountLimit) {

        // TODO: finish building the load more terms functionality
        if (isTypeTerms && facetAllTerms.length < 1) {
            console.log("[Chart] Retrieving all terms for facet '" + facetName + "'. Not providing chart data.");
            facet.getAllFacetTerms();
            return null;
        } else if (isTypeTerms && facetAllTerms.length > 1) {
            console.log("[Chart] Obtained full list of terms for facet '" + facetName + "'. The chart data will be provided.");
            facetItems = facetAllTerms;
        }

        // get settings for processing chart data
        let useCount = self.getValueFromChartContainer(chartConfig, 'dataUseCount', 'bool', false);
        let applyRanges = self.getValueFromChartContainer(chartConfig, 'dataApplyRanges', 'array', []);
        let shouldApplyRanges = applyRanges.length > 0
        const toPercentages = self.getValueFromChartContainer(chartConfig, 'dataToPercentage', 'bool', false);
        let isCustomChartData = self.getValueFromChartContainer(chartConfig, 'dataIsCustomChartData', 'bool', false);

        // check settings make sense
        // range facet can only use dataToPercentage. Note that ranges use the count as the value.
        // term facet can do useCount (first), applyRange (second), toPercentages (third), all optional, if specified are applied in this order.
        if (!isTypeTerms && isCustomChartData) {
            console.error("[Chart] Custom chart data must be provided by term facet only, given '" + facetType + "' for facet '" + facetName + "'. " +
                "Will set isCustomChartData to false.");
            isCustomChartData = false;
        }

        if (isTypeRange && shouldApplyRanges) {
            console.error("[Chart] Cannot apply ranges to range facet '" + facetName + "'. Will set applyRanges to empty array.");
            applyRanges = [];
            shouldApplyRanges = false;
        }

        if (isTypeRange && useCount) {
            console.error("[Chart] Cannot use count for range facet '" + facetName + "'. Will set useCount to false.");
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
            });
            console.warn("[Chart] Converted to counts for facet '" + facetName + "'.", JSON.parse(JSON.stringify(rawData)));
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
            return previous + current.count;
        }, 0);

        // convert to percentages
        if (toPercentages) {
            console.log("[Chart] Obtaining data percentages for facet '" + facetName + "'.");
            rawData = self.getChartDataPercentages(rawData, totalRecords);
        }

        // get the chart labels
        const chartLabels = [];
        for (let index = 0; index < rawData.length; index++) {
            const rawDataItem = rawData[index];
            let chartLabel = rawDataItem.title;
            chartLabels.push(chartLabel);
        }

        // convert raw data to chart data
        const chartData = rawData.map(function (item) {
            return item.value;
        });

        // validate output items
        if (!chartLabels || chartLabels.length < 1 || !chartData || chartData.length < 1 || totalTerms < 1 || totalRecords < 1) {
            console.warn("[Chart] Some data not available for chart for facet '" + facetName + "' " +
                "with chart type '" + chartType + "'.",
                JSON.parse(JSON.stringify(chartLabels)),
                JSON.parse(JSON.stringify(chartData)),
                JSON.parse(JSON.stringify(totalTerms)),
                JSON.parse(JSON.stringify(totalRecords)));
        }
        return {
            labels: chartLabels,
            data: chartData,
            totalTerms: totalTerms,
            totalRecords: totalRecords,
        };
    });
}
