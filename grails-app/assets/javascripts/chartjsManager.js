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
        chartList.forEach(function (item, index) {
            if (index % perRow === 0) {
                result.push([]);
            }
            result[result.length - 1].push(item);
        });
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
    const getValueFromChartContainer = function (container, propertyName, valueType, defaultValue) {
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
                result = value === undefined ? false : ((value || '').toString() === 'true');
                break;
            case 'array':
                result = value === undefined ? [] : value;
                break;
            case 'int':
                result = value === undefined ? 0 : parseInt((value || '0').toString(), 10);
                break;
            case 'float':
                result = value === undefined ? 0.0 : parseFloat((value || '0').toString());
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
    const setContainerValue = function (container, keys, value) {
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
        keys.forEach(function (key, index) {
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
        });
    }

    /**
     * Get the chart title, with addition of total record count if available.
     * @param chartConfig {object} The chart config.
     * @param totalRecords {?int} The total record count.
     * @returns {string} The new chart title.
     */
    const getMainTitle = function (chartConfig, totalRecords) {
        const facetTitle = (facet.displayName ? facet.displayName() : (facet.title ? ko.unwrap(facet.title) : facet.name));
        const mainTitle = getValueFromChartContainer(chartConfig, 'mainTitle', 'string', ' items for ' + facetTitle);
        const insertTotalAt = getValueFromChartContainer(chartConfig, 'mainTitleInsertTotalAt', 'int', 0);

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
    const getArraySubset = function (items, keepAll, maxItems) {
        if (items === undefined || items === null) {
            return [];
        }
        const result = [];
        (items || []).forEach(function (label, index) {
            if (keepAll || !maxItems) {
                result.push(label);
            } else if (index < maxItems) {
                result.push(label);
            }
        });
        return result;
    };

    const buildChartDataItem = function (value, rangeFrom, rangeTo, count) {
        return {
            value: value,
            rangeFrom: rangeFrom,
            rangeTo: rangeTo,
            count: count,
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
    const getChartDataRange = function (data, ranges) {
        const chartData = ranges.map(function (range) {
            const minVal = getValueFromChartContainer(range, 'minVal', 'float', null);
            const maxVal = getValueFromChartContainer(range, 'maxVal', 'float', null);
            let rangeValue = '';
            rangeValue += (minVal !== null ? 'from ' + minVal.toString() : ' ');
            rangeValue += (maxVal !== null ? 'to ' + maxVal.toString() : ' ');
            return buildChartDataItem(rangeValue.trim(), minVal, maxVal, 0);
        });

        for (let dataIndex = 0; dataIndex < data.length; dataIndex++) {
            const item = data[dataIndex];
            const termCount = getValueFromChartContainer(item, 'count', 'int', null);
            const termValue = getValueFromChartContainer(item, 'value', 'float', null);
            if (termCount === null || termValue === null) {
                console.warn("[Chart] Could not convert value '" + item.value + "' to float.");
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
                console.warn("[Chart] Value '" + termValue + "' did not fit any of the ranges.", ranges);
            }
        }
        return chartData;
    };

    /**
     * Update the chart data to be percentages if requested.
     * Converts chart data passed in as a list of values to percentage based on the total of records.
     * For example, for chart data: [3,2,1]
     * sums the total = 3 + 2 + 1 = 6 then calculates the percentage of what each value represents
     * Result: 3 = 50% of 6, 2 = 33.33% of 6 and 1 = 16.67% of 6.
     * @param data The chart data.
     * @param totalRecords The total number of records.
     * @returns {*[]} The updated chart data.
     */
    const getChartDataPercentages = function (data, totalRecords) {
        const chartData = [];
        for (let i = 0; i < data.length; i++) {
            const itemValue = parseFloat(data[i]);
            if (isNaN(itemValue)) {
                console.error("[Chart] Cannot convert non-numeric chart data to percentages.", data);
                return data;
            }
            let value = itemValue * 100 / totalRecords;
            value = Math.round((value + Number.EPSILON) * 100) / 100;
            chartData[i] = value;
        }
        return chartData;
    };

    /**
     * Parse facet terms in 'unique count' format: 'CustomChartDataItem|||[key]|||[count]'
     * @param facetTerms The facet terms.
     * @returns {*[]} Parsed terms matching the standard facet term array.
     */
    const getChartDataCustomTerms = function (facetTerms) {
        const rawData = [];
        const prefix = 'CustomChartDataItem';
        const sep = '|||';
        (facetTerms || []).forEach(function (term) {
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
                const newItem = buildChartDataItem(termKey, null, null, 0)
                rawData.push(newItem);
            }
            existingIndex = rawData.findIndex(function (element) {
                return element.value === termKey;
            });
            rawData[existingIndex].count += (termCount * termValue);
        });
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
    const createChartBarData = function (facet, chartConfig, chartRawData) {
        const borderColors = getValueFromChartContainer(chartConfig, 'borderColorsAvailable', 'array', chartRawData.labels);
        const borderWidth = getValueFromChartContainer(chartConfig, 'borderWidth', 'int', null);

        const optTitleText = getMainTitle(chartConfig, chartRawData.totalRecords);

        const mainLabels = getValueFromChartContainer(chartConfig, 'mainLabels', 'array', null);
        const showAllLabels = getValueFromChartContainer(chartConfig, 'mainLabelsShowAll', 'bool', true);
        const chartLabels = getArraySubset(mainLabels, showAllLabels, chartRawData.totalTerms);

        const bgColorsAvailable = getValueFromChartContainer(chartConfig, 'bgColorsAvailable', 'array', null);
        const bgColors = getArraySubset(bgColorsAvailable, showAllLabels, chartRawData.totalTerms);

        const datasets = {datasets: []};
        setContainerValue(datasets, ['labels'], chartLabels);

        const dataset = {};
        setContainerValue(dataset, ['label'], optTitleText);
        setContainerValue(dataset, ['data'], chartRawData.data);
        setContainerValue(dataset, ['backgroundColor'], bgColors);
        setContainerValue(dataset, ['borderColor'], borderColors);
        setContainerValue(dataset, ['borderWidth'], borderWidth);
        datasets.datasets.push(dataset);

        return datasets;
    };

    /**
     * Create the options for a bar chart.
     * @param facet {object} The facet data.
     * @param chartConfig {object} The chart config.
     * @param chartRawData {object} the raw chart data.
     * @returns {{}} The chart options.
     */
    const createChartBarOptions = function (facet, chartConfig, chartRawData) {
        const optTitleText = getMainTitle(chartConfig, chartRawData.totalRecords);

        const optTitlePosition = getValueFromChartContainer(chartConfig, 'mainTitlePosition', 'string', null);
        const optYScaleTitle = getValueFromChartContainer(chartConfig, 'yTitle', 'string', null);
        const optXScaleTitle = getValueFromChartContainer(chartConfig, 'xTitle', 'string', null);
        const optXScaleType = getValueFromChartContainer(chartConfig, 'xType', 'string', null);
        const optXScaleLabels = getValueFromChartContainer(chartConfig, 'xLabels', 'array', null);
        const optLegendPosition = getValueFromChartContainer(chartConfig, 'legendPosition', 'string', null);
        const optYScaleBeginAtZero = getValueFromChartContainer(chartConfig, 'yBeginAtZero', 'bool', null);
        const optYScaleDisplay = getValueFromChartContainer(chartConfig, 'yDisplay', 'bool', null);
        const optYScaleTitleDisplay = getValueFromChartContainer(chartConfig, 'yTitleDisplay', 'bool', null);
        const optXScaleDisplay = getValueFromChartContainer(chartConfig, 'xDisplay', 'bool', null);
        const optXScaleTitleDisplay = getValueFromChartContainer(chartConfig, 'xTitleDisplay', 'bool', null);
        const optLegendDisplay = getValueFromChartContainer(chartConfig, 'legendDisplay', 'bool', null);
        const optTitleDisplay = getValueFromChartContainer(chartConfig, 'mainTitleDisplay', 'bool', null);

        const options = {};
        setContainerValue(options, ['plugins', 'legend', 'display'], optLegendDisplay);
        setContainerValue(options, ['plugins', 'legend', 'position'], optLegendPosition);

        setContainerValue(options, ['plugins', 'title', 'display'], optTitleDisplay);
        setContainerValue(options, ['plugins', 'title', 'text'], optTitleText);
        setContainerValue(options, ['plugins', 'title', 'position'], optTitlePosition);

        setContainerValue(options, ['scales', 'y', 'beginAtZero'], optYScaleBeginAtZero);
        setContainerValue(options, ['scales', 'y', 'display'], optYScaleDisplay);
        setContainerValue(options, ['scales', 'y', 'title', 'display'], optYScaleTitleDisplay);
        setContainerValue(options, ['scales', 'y', 'title', 'text'], optYScaleTitle);

        // Work around to avoid RangeError: minimumFractionDigits value is out of range
        // https://github.com/chartjs/Chart.js/issues/8092
        setContainerValue(options, ['scales', 'y', 'ticks', 'callback'], function (value) {
            return value;
        });

        setContainerValue(options, ['scales', 'x', 'display'], optXScaleDisplay);
        setContainerValue(options, ['scales', 'x', 'type'], optXScaleType);
        setContainerValue(options, ['scales', 'x', 'labels'], optXScaleLabels);
        setContainerValue(options, ['scales', 'x', 'title', 'display'], optXScaleTitleDisplay);
        setContainerValue(options, ['scales', 'x', 'title', 'text'], optXScaleTitle);

        // Work around to avoid RangeError: minimumFractionDigits value is out of range
        // https://github.com/chartjs/Chart.js/issues/8092
        setContainerValue(options, ['scales', 'x', 'ticks', 'callback'], function (value) {
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
    const createChartPieData = function (facet, chartConfig, chartRawData) {
        const mainLabels = getValueFromChartContainer(chartConfig, 'mainLabels', 'array', chartRawData.labels);
        const showAllLabels = getValueFromChartContainer(chartConfig, 'mainLabelsShowAll', 'bool', true);
        const chartLabels = getArraySubset(mainLabels, showAllLabels, chartRawData.totalTerms);

        const optTitleText = getMainTitle(chartConfig, chartRawData.totalRecords);

        const bgColorsAvailable = getValueFromChartContainer(chartConfig, 'bgColorsAvailable', 'array', null);
        const bgColors = getArraySubset(bgColorsAvailable, showAllLabels, chartRawData.totalTerms);

        const chartHoverOffset = getValueFromChartContainer(chartConfig, 'hoverOffset', 'int', null);

        const result = {datasets: []};
        setContainerValue(result, ['labels'], chartLabels);

        const dataset = {};
        setContainerValue(dataset, ['label'], optTitleText);
        setContainerValue(dataset, ['data'], chartRawData.data);
        setContainerValue(dataset, ['backgroundColor'], bgColors);
        setContainerValue(dataset, ['hoverOffset'], chartHoverOffset);
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
    const createChartPieOptions = function (facet, chartConfig, chartRawData) {
        const optTitleText = getMainTitle(chartConfig, chartRawData.totalRecords);

        const optPosition = getValueFromChartContainer(chartConfig, 'mainTitlePosition', 'string', 'top');
        const optDisplay = getValueFromChartContainer(chartConfig, 'mainTitleDisplay', 'bool', true);
        const optResponsive = getValueFromChartContainer(chartConfig, 'responsive', 'bool', null);

        const result = {};
        setContainerValue(result, ['responsive'], optResponsive);
        setContainerValue(result, ['plugins', 'legend', 'position'], optPosition);
        setContainerValue(result, ['plugins', 'title', 'display'], optDisplay);
        setContainerValue(result, ['plugins', 'title', 'text'], optTitleText);
        return result;
    };

    /**
     * Get line chart data.
     * @param facet {object} The facet.
     * @param chartConfig {object} The chart config.
     * @param chartRawData {object} The raw chart data.
     * @returns {{datasets: *[]}} The chart data.
     */
    const createChartLineData = function (facet, chartConfig, chartRawData) {
        const chartFill = getValueFromChartContainer(chartConfig, 'lineChartFill', 'bool', null);
        const chartTension = getValueFromChartContainer(chartConfig, 'lineChartTension', 'float', null);

        const optTitleText = getMainTitle(chartConfig, chartRawData.totalRecords);

        const mainLabels = getValueFromChartContainer(chartConfig, 'mainLabels', 'array', null);
        const showAllLabels = getValueFromChartContainer(chartConfig, 'mainLabelsShowAll', 'bool', true);
        const chartLabels = getArraySubset(mainLabels, showAllLabels, chartRawData.totalTerms);

        const bgColorsAvailable = getValueFromChartContainer(chartConfig, 'bgColorsAvailable', 'array', null);
        const borderColors = getArraySubset(bgColorsAvailable, showAllLabels, chartRawData.totalTerms);

        const result = {datasets: []};
        setContainerValue(result, ['labels'], chartLabels || chartRawData.labels);

        const dataset = {};
        setContainerValue(dataset, ['label'], optTitleText);
        setContainerValue(dataset, ['data'], chartRawData.data);
        setContainerValue(dataset, ['fill'], chartFill);
        setContainerValue(dataset, ['borderColor'], borderColors);
        setContainerValue(dataset, ['tension'], chartTension);
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
    const createChartLineOptions = function (facet, chartConfig, chartRawData) {
        const optStacked = getValueFromChartContainer(chartConfig, 'yStacked', 'bool', null);

        const result = {};
        setContainerValue(result, ['scales', 'y', 'stacked'], optStacked);
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

        return facet && chartConfig && chartRawData && builder
            ? builder.data(facet, chartConfig, chartRawData)
            : null;
    });
    self.chartOptions = ko.pureComputed(function () {
        const facet = self.transients.facet();
        const chartConfig = self.transients.chartConfig();
        const chartRawData = self.transients.chartRawData();
        const builder = self.transients.getChartBuilder();

        return facet && chartConfig && chartRawData && builder
            ? builder.options(facet, chartConfig, chartRawData)
            : null;
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
                return {data: createChartPieData, options: createChartPieOptions};
            case 'bar':
                return {data: createChartBarData, options: createChartBarOptions};
            case 'line':
                return {data: createChartLineData, options: createChartLineOptions};
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
        const facetAllTerms = facet.ref.showMoreTermList();
        let facetItems = facet.terms() || [];
        const facetTermCountLimit = facet.ref.flimit;

        const isTypeTerms = facetType === 'terms'
        const isTypeRange = facetType === 'range'

        // A term facet that has more terms needs to load them first
        // When the full term list has loaded, this computed should be re-evaluated because
        // it depends on the observable that holds the full list: 'showMoreTermList'.

        if (facetType === 'terms' && facetItems.length >= facetTermCountLimit) {

            // TODO: finish building the load more terms functionality
            // if (isTypeTerms && facetAllTerms.length < 1) {
            console.warn("[Chart] Retrieving all facet terms for '" + facetName + "'.");
            facet.loadMoreTerms();
            return null;
        } else if (isTypeTerms && facetAllTerms.length > 1) {
            facetItems = facetAllTerms;
        }

        // get settings for processing chart data
        let useCount = getValueFromChartContainer(chartConfig, 'dataUseCount', 'bool', false);
        let applyRanges = getValueFromChartContainer(chartConfig, 'dataApplyRanges', 'array', []);
        const shouldApplyRanges = applyRanges.length > 0
        const toPercentages = getValueFromChartContainer(chartConfig, 'dataToPercentage', 'bool', false);
        let isCustomChartData = getValueFromChartContainer(chartConfig, 'dataIsCustomChartData', 'bool', false);

        // check settings make sense
        // TODO: how does useCount interact with ranges (either range facet or created from term facet)?
        // range facet can only use dataToPercentage
        // term facet can do useCount (first), applyRange (second), toPercentages (third), all optional.
        if (!isTypeTerms && isCustomChartData) {
            console.error("[Chart] Custom chart data must be provided by term facet only, given '" + facetType + "' for facet '" + facetName + "'. " +
                "Will set isCustomChartData to false.");
            isCustomChartData = false;
        }

        if (isTypeRange && shouldApplyRanges) {
            console.error("[Chart] Cannot apply ranges to range facet '" + facetName + "'. Will set applyRanges to empty array.");
            applyRanges = [];
        }

        if (isTypeRange && useCount){
            console.error("[Chart] Cannot use count for range facet '" + facetName + "'. Will set useCount to false.");
            useCount = false;
        }

        // obtain the raw data
        let rawData = [];

        // parse the raw data
        if (isTypeTerms && isCustomChartData) {
            console.log("[Chart] Parsing '" + facetItems.length + "' facet term custom chart items for facet '" + facetName + "'.");
            rawData = getChartDataCustomTerms(facetItems);

        } else if (isTypeTerms && !isCustomChartData) {
            console.log("[Chart] Parsing '" + facetItems.length + "' facet term items for facet '" + facetName + "'.");
            rawData = facetItems.map(function (item) {
                return buildChartDataItem(item.term(), null, null, item.count());
            });

        } else if (isTypeRange) {
            console.log("[Chart] Parsing '" + facetItems.length + "' facet range items for facet '" + facetName + "'.");
            rawData = facetItems.map(function (item) {
                return buildChartDataItem(null, item.from(), item.to(), item.count());
            });

        } else {
            console.error("[Chart] Did not parse '" + facetItems.length + "' facet items for facet '" + facetName + "'.");
        }

        // convert term facet to range if requested
        if (isTypeTerms && shouldApplyRanges) {
            console.log("[Chart] Converting term data to range for facet '" + facetName + "'.");
            // bucket values for a term facet
            rawData = getChartDataRange(rawData, applyRanges);
        }

        const totalTerms = rawData.length;
        const totalRecords = rawData.reduce(function (previous, current) {
            return previous + current.count;
        }, 0);

        // convert to chart data and chart labels
        let chartData = [];
        const chartLabels = [];
        console.log("[Chart] Obtaining data " + (useCount ? "counts" : "values") + " for facet '" + facetName + "'.");
        rawData.forEach(function (item, index) {
            const facetItem = facetItems[index];

            let chartLabel;
            if (facetItem.displayNameWithoutCount) {
                chartLabel = facetItem.displayNameWithoutCount();
            } else if (facetItem.displayName) {
                chartLabel = facetItem.displayName();
            } else {
                chartLabel = facetItem.title() || facetItem.name() || 'Item ' + (index + 1).toString();
            }
            chartLabel += (useCount ? "" : "(" + item.count.toString() + ")");
            chartLabels.push(chartLabel);

            chartData.push(useCount ? item.count : item.value);
        });

        // convert to percentages
        if (toPercentages) {
            console.log("[Chart] Obtaining data percentages for facet '" + facetName + "'.");
            chartData = getChartDataPercentages(chartData, totalRecords);
        }

        if (!chartLabels || chartLabels.length < 1 || !chartData || chartData.length < 1 || totalTerms < 1 || totalRecords < 1) {
            console.warn("[Chart] Some data not available for chart for facet '" + facetName + "' " +
                "with chart type '" + chartType + "'.", chartLabels, chartData, totalTerms, totalRecords);
        } else {
            console.log("Done");
        }
        return {
            labels: chartLabels,
            data: chartData,
            totalTerms: totalTerms,
            totalRecords: totalRecords,
        };
    });
}
