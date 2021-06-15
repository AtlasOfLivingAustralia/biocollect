/**
 * Knockout view model for managing multiple chart.js instances.
 * @constructor
 */
function ChartjsManagerViewModel() {
    const self = this;

    self.chartjsList = ko.observableArray();

    self.chartjsListShow = ko.computed(function () {
        return self.chartjsList().length > 0;
    });

    self.chartjsPerRowOptions = ko.observableArray(['1', '2', '3', '4']);
    self.chartjsPerRowSelected = ko.observable('2');
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
    self.chartjsPerRowSpan = ko.pureComputed(function () {
        const selected = self.chartjsPerRowSelected();
        const perRow = 12 / parseInt(selected || '2');
        const result = 'span' + perRow.toString();
        return result;
    });


    /*
     * Create chart.js dataset data structure for different chart types.
     */

    const initBarChart = function (chartLabels, bgColors, borderColors, borderWidth, chartData, datasetLabels) {
        const result = {datasets: []};
        setContainerValue(result, ['labels'], chartLabels || chartData.labels);

        const dataset = {};
        setContainerValue(dataset, ['label'], datasetLabels);
        setContainerValue(dataset, ['data'], chartData.data);
        setContainerValue(dataset, ['backgroundColor'], bgColors);
        setContainerValue(dataset, ['borderColor'], borderColors);
        setContainerValue(dataset, ['borderWidth'], borderWidth);
        result.datasets.push(dataset);

        return result;
    };

    const initPieChart = function (chartLabels, bgColors, chartHoverOffset, chartData, chartTitle) {
        const result = {datasets: []};
        setContainerValue(result, ['labels'], chartLabels || chartData.labels);

        const dataset = {};
        setContainerValue(dataset, ['label'], chartTitle);
        setContainerValue(dataset, ['data'], chartData.data);
        setContainerValue(dataset, ['backgroundColor'], bgColors);
        setContainerValue(dataset, ['hoverOffset'], chartHoverOffset);
        result.datasets.push(dataset);

        return result;
    };

    const initLineChart = function (chartLabels, chartFill, borderColors, chartTension, chartData, datasetLabels) {
        const result = {datasets: []};
        setContainerValue(result, ['labels'], chartLabels || chartData.labels);

        const dataset = {};
        setContainerValue(dataset, ['label'], datasetLabels);
        setContainerValue(dataset, ['data'], chartData.data);
        setContainerValue(dataset, ['fill'], chartFill);
        setContainerValue(dataset, ['borderColor'], borderColors);
        setContainerValue(dataset, ['tension'], chartTension);
        result.datasets.push(dataset);

        return result;
    };

    /*
     * Create chart.js options data structure for different chart types.
     */

    const initPieChartOpts = function (optResponsive, optPosition, optDisplay, optText) {
        const result = {};
        setContainerValue(result, ['responsive'], optResponsive);
        setContainerValue(result, ['plugins', 'legend', 'position'], optPosition);
        setContainerValue(result, ['plugins', 'title', 'display'], optDisplay);
        setContainerValue(result, ['plugins', 'title', 'text'], optText);
        return result;
    };

    const initBarChartOpts = function (optYScaleBeginAtZero, optYScaleDisplay, optYScaleTitleDisplay, optYScaleTitle,
                                       optXScaleDisplay, optXScaleType, optXScaleLabels, optXScaleTitleDisplay, optXScaleTitle,
                                       optLegendDisplay, optLegendPosition, optTitleDisplay, optTitleText, optTitlePosition) {
        const result = {};
        setContainerValue(result, ['plugins', 'legend', 'display'], optLegendDisplay);
        setContainerValue(result, ['plugins', 'legend', 'position'], optLegendPosition);

        setContainerValue(result, ['plugins', 'title', 'display'], optTitleDisplay);
        setContainerValue(result, ['plugins', 'title', 'text'], optTitleText);
        setContainerValue(result, ['plugins', 'title', 'position'], optTitlePosition);

        setContainerValue(result, ['scales', 'y', 'beginAtZero'], optYScaleBeginAtZero);
        setContainerValue(result, ['scales', 'y', 'display'], optYScaleDisplay);
        setContainerValue(result, ['scales', 'y', 'title', 'display'], optYScaleTitleDisplay);
        setContainerValue(result, ['scales', 'y', 'title', 'text'], optYScaleTitle);

        // Work around to avoid RangeError: minimumFractionDigits value is out of range
        // https://github.com/chartjs/Chart.js/issues/8092
        setContainerValue(result, ['scales', 'y', 'ticks', 'callback'], function (value) {
            return value;
        });

        setContainerValue(result, ['scales', 'x', 'display'], optXScaleDisplay);
        setContainerValue(result, ['scales', 'x', 'type'], optXScaleType);
        setContainerValue(result, ['scales', 'x', 'labels'], optXScaleLabels);
        setContainerValue(result, ['scales', 'x', 'title', 'display'], optXScaleTitleDisplay);
        setContainerValue(result, ['scales', 'x', 'title', 'text'], optXScaleTitle);

        // Work around to avoid RangeError: minimumFractionDigits value is out of range
        // https://github.com/chartjs/Chart.js/issues/8092
        setContainerValue(result, ['scales', 'x', 'ticks', 'callback'], function (value) {
            return value;
        });

        return result;
    };

    const initLineChartOpts = function (optStacked) {
        const result = {};
        setContainerValue(result, ['scales', 'y', 'stacked'], optStacked);
        return result;
    };

    /*
     * Functions to ease obtaining values for charts.
     */

    const getValueFromChartContainer = function (container, propertyName, valueType, defaultValue) {
        const hasProp = Object.prototype.hasOwnProperty.call(container, propertyName);
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
                throw new Error("Unrecognised value type '" + valueType + "' for value '" + value + "'.")
        }

        // console.warn("[Chart] Obtained '" + propertyName + "' value '" + result + "' of type '" + valueType + "'.");
        return result;
    };

    const setContainerValue = function (container, keys, value) {
        // value === undefined - don't set
        // value === null - don't set
        // anything else - do set
        if (value === undefined || value === null) {
            return;
        }
        if (!container) {
            throw new Error("Must provide container.");
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

    const getMainTitle = function (mainTitle, insertTotalAt, totalRecords) {
        if (!mainTitle) {
            mainTitle = '';
        }
        if (!insertTotalAt) {
            insertTotalAt = 0;
        }
        if (mainTitle) {
            if (insertTotalAt >= 0 && mainTitle.length > insertTotalAt) {
                mainTitle = [
                    mainTitle.slice(0, insertTotalAt),
                    totalRecords + ' ',
                    mainTitle.slice(insertTotalAt)
                ].join('');
            } else {
                console.warn("[Chart] Did not modify main title '" + mainTitle + "' insertTotalAt: '" + insertTotalAt.toString() + "'.")
            }
        }
        return mainTitle;
    };

    const getMainLabels = function (mainLabels, showAllLabels, totalTerms) {
        if (mainLabels === undefined || mainLabels === null) {
            return null;
        }
        const result = [];
        (mainLabels || []).forEach(function (label, index) {
            if (showAllLabels || !totalTerms) {
                result.push(label);
            } else if (index < totalTerms) {
                result.push(label);
            }
        });
        return result;
    };

    /**
     * Gets count value of each term in a given facet and returns a list of values that will be interpreted as data by chartjs.
     *
     * For example facet terms: [{term: name1, count: 3}, {term: name2, count: 2}, {term: name3, count: 1}]
     * will be converted to: [3, 2, 1].
     *
     * For example facet range: [{"from": 2,"to": 3,"count": 2},{"from": 4,"to": 5,"count": 2},{"from": 5,"to": 6,"count": 1}]
     * will be converted to: [3, 2, 1]
     *
     * @param data The raw chart data.
     * @returns {*[]} The chart data.
     */
    const getChartDataCount = function (data) {
        const chartData = [];
        data.forEach(function (term) {
            const termCount = getValueFromChartContainer(term, 'count', 'int', 0);
            chartData.push(termCount);
        });
        return chartData;
    };


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
     * @param facetType {string} The facet type.
     * @param data {array} The raw data.
     * @param ranges {array} The ranges to apply.
     * @returns {*[]} The chart data.
     */
    const getChartDataRange = function (facetType, data, ranges) {
        const chartData = [];
        if (facetType === 'terms') {
            for (let n = 0; n < ranges.length; n++) {
                let countRange = 0;
                const range = ranges[n];
                const minVal = getValueFromChartContainer(range, 'minVal', 'float', null);
                const maxVal = getValueFromChartContainer(range, 'maxVal', 'float', null);
                data.forEach(function (term) {
                    const termCount = getValueFromChartContainer(term, 'count', 'int', null);
                    const termValue = getValueFromChartContainer(term, 'term', 'float', null);
                    if (termCount !== null && termValue !== null) {
                        for (let i = 0; i < termCount; i++) {
                            if (termValue >= minVal && termValue <= maxVal) {
                                countRange++;
                            }
                        }
                    }
                });
                chartData.push(countRange);
            }
        } else if (facetType === 'range') {
            data.forEach(function (range) {
                const rangeCount = getValueFromChartContainer(range, 'count', 'int', null);
                if (rangeCount !== null) {
                    chartData.push(rangeCount);
                }
            });
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
            let value = data[i] * 100 / totalRecords;
            value = Math.round((value + Number.EPSILON) * 100) / 100;
            chartData[i] = value;
        }
        return chartData;
    };

    /**
     * Parse facet terms in 'unique count' format: 'CustomChartDataItem|||[key]|||[count]'
     * @param facetTerms The facet terms.
     * @returns {{totalTerms: number, totalRecords: *, rawData: *[]}} Parsed terms matching the standard facet term array.
     */
    const getChartDataCustomTerms = function (facetTerms) {
        const rawData = [];
        const prefix = 'CustomChartDataItem';
        const sep = '|||';
        (facetTerms || []).forEach(function (term) {
            const termCount = getValueFromChartContainer(term, 'count', 'int', 0);
            const termRaw = getValueFromChartContainer(term, 'term', 'string', '');
            let termKey = '';
            let termValue = 0;
            if (termRaw.startsWith(prefix) && termRaw.indexOf(sep) > -1) {
                const termSplit = termRaw.split(sep);
                termKey = termSplit[1];
                termValue = parseInt(termSplit[2], 10);
            } else {
                console.warn("[Chart] Could not parse custom chart data term: '" + termRaw + "'.")
            }

            // increment term key count
            let existingIndex = rawData.findIndex(function (element) {
                return element.term === termKey;
            });
            if (existingIndex < 0) {
                rawData.push({term: termKey, count: 0, title: null});
            }
            existingIndex = rawData.findIndex(function (element) {
                return element.term === termKey;
            });
            rawData[existingIndex].count += (termCount * termValue);
        });

        const totalTerms = rawData.length;
        const totalRecords = rawData.reduce(function (previous, current) {
            return previous + current.count;
        }, 0);
        return {
            rawData: rawData,
            totalTerms: totalTerms,
            totalRecords: totalRecords,
        }
    };

    /**
     * Extract the chart data from the facet and config data.
     * @param chartConfig The chart config object.
     * @param columnConfig The column config object.
     * @param facet The facet item from the search result.
     * @returns {{totalTerms: number, totalRecords: number, data: {}}}
     */
    const getChartData = function (chartConfig, columnConfig, facet) {
        let useCount = getValueFromChartContainer(chartConfig, 'dataUseCount', 'bool', false);
        const applyRanges = getValueFromChartContainer(chartConfig, 'dataApplyRanges', 'array', []);
        const toPercentages = getValueFromChartContainer(chartConfig, 'dataToPercentage', 'bool', false);
        const isCustomData = getValueFromChartContainer(chartConfig, 'dataIsCustomChartData', 'bool', false) || facet.name.endsWith('UniqueCount');

        if ((useCount && applyRanges.length > 0)) {
            throw new Error("Must choose one of use count or apply ranges. Cannot choose both.");
        } else if (!useCount && applyRanges.length < 1) {
            useCount = true;
        }

        // obtain the raw data
        let rawData = [];
        let totalTerms = 0;
        let totalRecords = 0;

        if (facet.type === 'terms' && isCustomData) {
            // parse the facet terms, if this is a term facet and if required
            const rawDataObj = getChartDataCustomTerms(facet.terms);
            rawData = rawDataObj.rawData;
            totalTerms = rawDataObj.totalTerms;
            totalRecords = rawDataObj.totalRecords;
        } else if (facet.type === 'terms' && !isCustomData) {
            // use the facet terms, if this is a term facet and if required
            rawData = (facet && facet.terms) || [];
            totalTerms = rawData.length;
            totalRecords = facet.terms.reduce(function (previous, current) {
                const termCount = getValueFromChartContainer(current, 'count', 'int', 0);
                return previous + termCount;
            }, 0);
        } else if (facet.type === 'range') {
            rawData = facet.ranges;
            totalTerms = rawData.length;
            totalRecords = facet.ranges.reduce(function (previous, current) {
                const termCount = getValueFromChartContainer(current, 'count', 'int', 0);
                return previous + termCount;
            }, 0);
        } else {
            console.warn("[Chart] Cannot obtain raw data from facet type '" + facet.type + "'.");
        }

        // obtain chart data
        let chartData = [];
        if (useCount) {
            chartData = getChartDataCount(rawData);
        } else if (applyRanges && applyRanges.length > 0) {
            chartData = getChartDataRange(facet.type, rawData, applyRanges);
        }

        // apply conversions to chart data
        if (toPercentages && totalRecords > 0) {
            chartData = getChartDataPercentages(chartData, totalRecords);
        } else if (toPercentages && totalRecords <= 0) {
            console.warn("[Chart] Could not convert to percentages because there are no records.")
        }

        return {
            labels: rawData.map(function (item, index) {
                return item.title || item.term || 'Item ' + (index + 1).toString();
            }),
            data: chartData,
            totalTerms: totalTerms,
            totalRecords: totalRecords,
        };
    };

    const getBGColors = function (bgColorsAvailable, showAllLabels, total) {
        if (bgColorsAvailable === undefined || bgColorsAvailable === null) {
            return null;
        }
        const result = [];
        (bgColorsAvailable || []).forEach(function (colourToUse, index) {
            if (showAllLabels || !total) {
                result.push(colourToUse);
            } else if (index < total) {
                result.push(colourToUse);
            }
        });
        return result;
    }

    const getFacetConfigByFacetName = function (facetConfigs, facetName) {
        for (let i = 0; i < facetConfigs.length; i++) {
            const facetConfig = facetConfigs[i];
            if (facetConfig.name === facetName) {
                return facetConfig;
            }
        }
        return {};
    };

    const createPieChartViewModel = function (facet, chartType, chartConfig, columnConfig) {
        const mainLabels = getValueFromChartContainer(chartConfig, 'mainLabels', 'array', null);
        const showAllLabels = getValueFromChartContainer(chartConfig, 'mainLabelsShowAll', 'bool', true);
        const mainTitle = getValueFromChartContainer(chartConfig, 'mainTitle', 'string', ' items for ' + (facet.title || facet.name));
        const insertTotalAt = getValueFromChartContainer(chartConfig, 'mainTitleInsertTotalAt', 'int', null);
        const bgColorsAvailable = getValueFromChartContainer(chartConfig, 'bgColorsAvailable', 'array', null);

        const optPiePosition = getValueFromChartContainer(chartConfig, 'mainTitlePosition', 'string', 'top');
        const optPieDisplayTitle = getValueFromChartContainer(chartConfig, 'mainTitleDisplay', 'bool', true);
        const pieChartHoverOffset = getValueFromChartContainer(chartConfig, 'hoverOffset', 'int', null);
        const optPieResponsive = getValueFromChartContainer(chartConfig, 'responsive', 'bool', null);

        const pieChartDistData = getChartData(chartConfig, columnConfig, facet);

        const pieChartBGColor = getBGColors(bgColorsAvailable, showAllLabels, pieChartDistData.totalTerms);
        const pieChartLabels = getMainLabels(mainLabels, showAllLabels, pieChartDistData.totalTerms);
        const pieChartTitle = getMainTitle(mainTitle, insertTotalAt, pieChartDistData.totalRecords);


        const pieChartOpts = initPieChartOpts(optPieResponsive, optPiePosition, optPieDisplayTitle, pieChartTitle);
        const pieChart = initPieChart(pieChartLabels, pieChartBGColor, pieChartHoverOffset, pieChartDistData, pieChartTitle);
        return new ChartjsViewModel(facet.name, chartType, pieChart, pieChartOpts)
    };

    const createBarChartViewModel = function (facet, chartType, chartConfig, columnConfig) {
        const mainLabels = getValueFromChartContainer(chartConfig, 'mainLabels', 'array', null);
        const showAllLabels = getValueFromChartContainer(chartConfig, 'mainLabelsShowAll', 'bool', true);
        const mainTitle = getValueFromChartContainer(chartConfig, 'mainTitle', 'string', ' items for ' + (facet.title || facet.name));
        const insertTotalAt = getValueFromChartContainer(chartConfig, 'mainTitleInsertTotalAt', 'int', null);
        const bgColorsAvailable = getValueFromChartContainer(chartConfig, 'bgColorsAvailable', 'array', null);

        const optTitlePosition = getValueFromChartContainer(chartConfig, 'mainTitlePosition', 'string', null);
        const barChartBorderColors = getValueFromChartContainer(chartConfig, 'borderColorsAvailable', 'array', null);
        const barChartBorderWidth = getValueFromChartContainer(chartConfig, 'borderWidth', 'int', null);
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

        const barChartData = getChartData(chartConfig, columnConfig, facet);

        const optTitleText = getMainTitle(mainTitle, insertTotalAt, barChartData.totalRecords);
        const lineChartLabels = getMainLabels(mainLabels, showAllLabels, barChartData.totalTerms);
        const barChartBGColors = getBGColors(bgColorsAvailable, showAllLabels, barChartData.totalTerms);


        const barChartOpts = initBarChartOpts(optYScaleBeginAtZero, optYScaleDisplay, optYScaleTitleDisplay, optYScaleTitle,
            optXScaleDisplay, optXScaleType, optXScaleLabels, optXScaleTitleDisplay, optXScaleTitle,
            optLegendDisplay, optLegendPosition, optTitleDisplay, optTitleText, optTitlePosition);
        const barChart = initBarChart(lineChartLabels, barChartBGColors, barChartBorderColors, barChartBorderWidth, barChartData,
            optTitleText);
        return new ChartjsViewModel(facet.name, chartType, barChart, barChartOpts);
    };

    const createLineChartViewModel = function (facet, chartType, chartConfig, columnConfig) {
        const mainLabels = getValueFromChartContainer(chartConfig, 'mainLabels', 'array', null);
        const showAllLabels = getValueFromChartContainer(chartConfig, 'mainLabelsShowAll', 'bool', true);
        const mainTitle = getValueFromChartContainer(chartConfig, 'mainTitle', 'string', ' items for ' + (facet.title || facet.name));
        const insertTotalAt = getValueFromChartContainer(chartConfig, 'mainTitleInsertTotalAt', 'int', null);
        const bgColorsAvailable = getValueFromChartContainer(chartConfig, 'bgColorsAvailable', 'array', null);

        const optStacked = getValueFromChartContainer(chartConfig, 'yStacked', 'bool', null);
        const chartFill = getValueFromChartContainer(chartConfig, 'lineChartFill', 'bool', null);
        const chartTension = getValueFromChartContainer(chartConfig, 'lineChartTension', 'float', null);

        const lineChartData = getChartData(chartConfig, columnConfig, facet);

        const optTitleText = getMainTitle(mainTitle, insertTotalAt, lineChartData.totalRecords);
        const lineChartLabels = getMainLabels(mainLabels, showAllLabels, lineChartData.totalTerms);
        const lineChartBGColors = getBGColors(bgColorsAvailable, showAllLabels, lineChartData.totalTerms);

        const lineChartOpts = initLineChartOpts(optStacked);
        const lineChart = initLineChart(lineChartLabels, chartFill, lineChartBGColors, chartTension, lineChartData, optTitleText);
        return new ChartjsViewModel(facet.name, chartType, lineChart, lineChartOpts);
    };

    self.setChartsFromFacets = function (facets, facetConfigs, columnConfig) {

        facets.forEach(function (facet) {
            if (['range', 'terms'].indexOf(facet.type) < 0) {
                console.warn("[Chart] Chart is not implemented for facet of type '" + facet.type + "'.");
                return;
            }

            const facetConfig = getFacetConfigByFacetName(facetConfigs, facet.name);
            if (!facetConfig) {
                return;
            }

            const chartType = getValueFromChartContainer(facetConfig, 'chartjsType', 'string', null);
            if (!chartType) {
                return;
            }

            // 'chartConfig' is using a pre defined and simplified config in JSON format stored in chartjsConfig that
            // has to be consistent with chartjsType which has been selected in the hub config for the facet.
            const chartConfig = getValueFromChartContainer(facetConfig, 'chartjsConfig', 'object');

            let chartViewModelCreateFunc = null;
            switch (chartType) {
                case 'pie':
                    chartViewModelCreateFunc = createPieChartViewModel;
                    break;
                case 'bar':
                    chartViewModelCreateFunc = createBarChartViewModel
                    break;
                case 'line':
                    chartViewModelCreateFunc = createLineChartViewModel
                    break;
                case 'none':
                    // none - don't create a chart
                    chartViewModelCreateFunc = null;
                    return;
                default:
                    console.warn("[Chart] Unrecognised chart type '" + chartType + "'.");
                    return;
            }

            if (!chartViewModelCreateFunc) {
                console.error("[Chart] No chart view model create function for facet '" + facet.name + "' chart type '" + chartType + "'.");
                return;
            }

            var chartViewModel = chartViewModelCreateFunc(facet, chartType, chartConfig, columnConfig);
            if (!chartViewModel) {
                console.error("[Chart] Could not create chart view model for facet '" + facet.name + "' chart type '" + chartType + "'.");
                return;
            }

            self.chartjsList.push(chartViewModel);
        });
    }
}

/**
 * Knockout view model for a Chart.js instance.
 * @param chartFacetName {string} The facet name.
 * @param chartType {string} The chart type.
 * @param chartData {object} The chart data.
 * @param chartOptions {object} The chart options.
 * @constructor
 */
function ChartjsViewModel(chartFacetName, chartType, chartData, chartOptions) {
    const self = this;

    console.log("[Chart] Created chart type '" + chartType + "' for facet '" + chartFacetName + "' with chart data: ", chartData);

    self.chartFacetName = ko.observable(chartFacetName);
    self.chartType = ko.observable(chartType);
    self.chartData = ko.observable(chartData);
    self.chartOptions = ko.observable(chartOptions);

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
}
