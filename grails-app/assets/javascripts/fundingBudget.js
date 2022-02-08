function findInContainer(container, props) {
    const foundProps = [];
    let current = container;
    for (let i = 0; i < props.length; i++) {
        const prop = props[i] || "";
        current = current[prop];
        if (!current) {
            console.warn(`[ProjectFundingBudget] Could not find '${prop}' in '${foundProps.join('.')}'.`);
            return null;
        }
        foundProps.push(prop);
    }
    return current;
}

// add an option for anything set, or nothing set
const totalFilterOptionSetValue = "__set__";
const totalFilterOptionSetText = "with value";


/**
 * Build the list of options for a total filter dropdown.
 * @param {object[]} availableOptions - The complete list of options or empty array if the options are not limited.
 * @param {string[]} enteredValues - The values selected or entered by the user.
 * @return {object[]} - The list of options.
 */
function buildTotalFilterOptions(availableOptions, enteredValues) {
    if (!availableOptions) availableOptions = [];
    if (!enteredValues) enteredValues = [];

    enteredValues.push(totalFilterOptionSetValue);

    const result = [];
    enteredValues.forEach(function (enteredValue) {
        if (!enteredValue) {
            enteredValue = totalFilterOptionSetValue;
        }
        let option = availableOptions.find(function (el) {
            return el.value === enteredValue;
        });
        // account for 'value set' option
        if (!option && enteredValue === totalFilterOptionSetValue) {
            option = {'text': totalFilterOptionSetText, 'value': totalFilterOptionSetValue};
        }
        // include entered values that are not in the available options
        if (!option && enteredValue !== totalFilterOptionSetValue) {
            option = {'text': enteredValue, 'value': enteredValue};
        }
        const include = {'text': `only ${option.text}`, 'value': `${option.value}(+)`};
        const exclude = {'text': `not ${option.text}`, 'value': `${option.value}(-)`};
        if (!result.some(el => el.value === include.value)) {
            result.push(include);
            result.push(exclude);
        }
    });
    return result.sort(function (a, b) {
        const nameA = a.value.toUpperCase();
        const nameB = b.value.toUpperCase();
        if (nameA < nameB) return -1;
        if (nameA > nameB) return 1;
        return 0;
    });
}

/**
 * Assess whether the row value should be included or not based on the select value.
 * @param {string} selectedValue - the selected value in the filter dropdown
 * @param {object} rowValue - the row value to compare
 * @return {boolean} - whether the selected value equals the row value
 */
function totalFilterAssess(selectedValue, rowValue) {
    if (!selectedValue) return true;
    if (!rowValue) rowValue = '';
    rowValue = rowValue.toString();

    const isInclude = selectedValue.endsWith('(+)');
    const isExclude = selectedValue.endsWith('(-)');
    const selectedValueForMatch = selectedValue.substring(0, selectedValue.length - 3);

    // account for the 'value set' option
    if (selectedValueForMatch === totalFilterOptionSetValue) {
        // 'only with value' = row value is truthy and selected value is include
        // 'not with value' = row value is falsy and select value is exclude
        return rowValue && isInclude || !rowValue && isExclude;
    }

    const isMatch = selectedValueForMatch === rowValue;
    console.log('totalFilterAssess');
    if (isInclude && isMatch) {
        return true;
    } else if (isExclude && !isMatch) {
        return true;
    }
    return false;
}

function riskLevelHighlight(value) {
    if (!value) {
        return '';
    }
    switch (value.toUpperCase()) {
        case 'HIGH':
            return 'badge badge-spend-critical';
        case 'SIGNIFICANT':
            return 'badge badge-spend-high';
        case 'MEDIUM':
            return 'badge badge-spend-medium';
        case 'LOW':
            return 'badge badge-spend-low';
        case 'OPERATIONAL':
            return 'badge badge-spend-operational';
        default:
            return 'badge';
    }
}

/**
 * A model to ease displaying dollar amounts.
 * @param {object} o - The data for the instance.
 * @constructor
 */
function FloatViewModel(o) {
    const self = this;
    if (!o) o = {};
    self.transients = o.transients || {};

    /**
     * The dollar amount.
     * @type {Observable<number|*>}
     */
    self.dollar = ko.observable(o.dollar ? o.dollar : 0.0)
        .extend({numericString: 2})
        .extend({currency: {}});
    self.transients.isNonZeroValue = ko.computed(function () {
        return self.dollar().toString() !== '0';
    });
}

/**
 * Create a new funding knockout view model.
 * @param {object } o - The source data for an instance.
 * @constructor
 */
function FundingViewModel(o) {
    const self = this;
    if (!o) o = {};
    self.transients = self.transients || {};

    /**
     * Array of funding item view models.
     * The property is created separately from populating the array because each item needs to reference the property.
     * @type {ObservableArray<any>}
     */
    self.fundings = ko.observableArray();
    (o.fundings || []).forEach(function (funding) {
        self.fundings.push(new FundingItemViewModel(funding, self.fundings));
    });

    /**
     * The available funding types from the app config.
     * @returns {object[]}
     */
    self.transients.availableFundingTypes = ko.observableArray(
        (findInContainer(fcConfig, ['financeDataDisplay', 'funding', 'options', 'fundingType']) || []).map(function (element) {
            return {'text': element.title, 'value': element.name};
        })
    );

    /**
     * The available funding classes from the app config.
     * @returns {object[]}
     */
    self.transients.availableFundingClasses = ko.observableArray(
        (findInContainer(fcConfig, ['financeDataDisplay', 'funding', 'options', 'fundClass']) || []).map(function (element) {
            return {'text': element.title, 'value': element.name};
        })
    );

    /**
     * Total amount for all funding items.
     * @type {Computed<number>}
     */
    self.funding = ko.computed(function () {
        return self.fundings().reduce(function (prev, current) {
            if (current && current.fundingSourceAmount()) {
                return prev + parseFloat(current.fundingSourceAmount() || "0");
            } else {
                return prev;
            }

        }, 0.0);
    }).extend({currency: {}});

    /**
     * Total amount for internal funding items.
     * @type {Computed<number>}
     */
    self.fundingInternalTotal = ko.computed(function () {
        return self.fundings().reduce(function (prev, current) {
            if (current && current.fundingInternalAmount()) {
                return prev + parseFloat(current.fundingInternalAmount() || "0");
            } else {
                return prev;
            }

        }, 0.0);
    }).extend({currency: {}});

    /**
     * Total amount for external funding items.
     * @type {Computed<number>}
     */
    self.fundingExternalTotal = ko.computed(function () {
        return self.fundings().reduce(function (prev, current) {
            if (current && current.fundingExternalAmount()) {
                return prev + parseFloat(current.fundingExternalAmount() || "0");
            } else {
                return prev;
            }

        }, 0.0);
    }).extend({currency: {}});

    /**
     * Create a new funding item.
     */
    self.createFundingItem = function () {
        return new FundingItemViewModel({}, self.fundings);
    };

    self.transients.fundingViewRows = new EditableTableViewModel(
        'fundingViewTable', self.fundings, null, {
            enableAdd: false, enableMove: false, enableDelete: false, enablePaging: true, enableColumnSelection: true
        });
    self.transients.fundingEditRows = new EditableTableViewModel(
        'fundingEditTable', self.fundings, self.createFundingItem, {
            enableAdd: true, enableMove: true, enableDelete: true, enablePaging: true, enableColumnSelection: true
        });

    self.transients.totalFilterFundingTypeSelected = ko.observable();
    self.transients.totalFilterFundingTypeOptions = ko.computed(function () {
        return buildTotalFilterOptions(
            self.transients.availableFundingTypes(),
            self.fundings().map(function (el) {
                return el.fundingType();
            }));
    });
    self.transients.totalFilterFundClassSelected = ko.observable();
    self.transients.totalFilterFundClassOptions = ko.computed(function () {
        return buildTotalFilterOptions(
            self.transients.availableFundingClasses(),
            self.fundings().map(function (el) {
                return el.fundClass();
            }));
    });
    self.transients.totalFilterRow = function totalFilterRow(rowItem) {
        return totalFilterAssess(self.transients.totalFilterFundingTypeSelected(), rowItem.fundingType()) &&
            totalFilterAssess(self.transients.totalFilterFundClassSelected(), rowItem.fundClass());
    };
    self.transients.totalFilterInternal = ko.computed(function () {
        return self.fundings().reduce(function (prev, current) {
            if (!current || !current.fundingInternalAmount()) {
                return prev;
            }
            if (self.transients.totalFilterRow(current)) {
                return prev + parseFloat(current.fundingInternalAmount() || "0");
            } else {
                return prev;
            }
        }, 0.0);
    }).extend({currency: {}});
    self.transients.totalFilterExternal = ko.computed(function () {
        return self.fundings().reduce(function (prev, current) {
            if (!current || !current.fundingExternalAmount()) {
                return prev;
            }
            if (self.transients.totalFilterRow(current)) {
                return prev + parseFloat(current.fundingExternalAmount() || "0");
            } else {
                return prev;
            }
        }, 0.0);
    }).extend({currency: {}});
    self.transients.totalFilterOverall = ko.computed(function () {
        return self.fundings().reduce(function (prev, current) {
            if (!current || !current.fundingSourceAmount()) {
                return prev;
            }
            if (self.transients.totalFilterRow(current)) {
                return prev + parseFloat(current.fundingSourceAmount() || "0");
            } else {
                return prev;
            }
        }, 0.0);
    }).extend({currency: {}});
}

/**
 * Create a new funding item knockout view model.
 * @param {object } o - The source data for an instance.
 * @param {ObservableArray} observableArrayContainer - The array holding this item.
 * @constructor
 */
function FundingItemViewModel(o, observableArrayContainer) {
    const self = this;
    if (!o) o = {};
    self.transients = self.transients || {};

    self.fundingDate = ko.observable(o.fundingDate)
        .extend({simpleDate: false});

    self.fundingSource = ko.observable(o.fundingSource);
    self.fundingType = ko.observable(o.fundingType);
    self.fundClass = ko.observable(o.fundClass);
    self.description = ko.observable(o.description);

    self.fundingInternalAmount = ko.observable(o.fundingInternalAmount || 0)
        .extend({numericString: 2})
        .extend({currency: {}});

    self.fundingExternalAmount = ko.observable(o.fundingExternalAmount || 0)
        .extend({numericString: 2})
        .extend({currency: {}});

    /**
     * Funding source amount is the total of internal and external funding.
     * @type {Computed<number>}
     */
    self.fundingSourceAmount = ko.computed(function () {
        var total = 0.0;
        total += parseFloat(self.fundingInternalAmount() || "0");
        total += parseFloat(self.fundingExternalAmount() || "0");
        return total;
    }).extend({currency: {}});

    self.transients.observableArrayContainer = observableArrayContainer;
    self.transients.displayedRowNumber = ko.computed(function () {
        if (!self.transients.observableArrayContainer) {
            throw "observableArrayContainer is not set";
        }
        const index = self.transients.observableArrayContainer.indexOf(self);
        return (index >= 0) ? (index + 1).toString() : "(unknown)";
    });
}

/**
 * Create a new budget knockout view model.
 * @param {object } o - The source data for an instance.
 * @param {string|date} projectStartDate - The project start date.
 * @param {string|date} projectEndDate - The project end date.
 * @constructor
 */
function BudgetViewModel(o, projectStartDate, projectEndDate) {
    const self = this;
    if (!o) o = {};
    self.transients = self.transients || {};

    /**
     * Get the financial year headers for the budget table.
     *
     * NOTE: This works while the project start/end dates are modified on a different page.
     *       If the project start/end dates can be changed on the project model,
     *       this approach must be changed to use the observables instead of the raw values.
     *
     * @param {string|date} projectStartDate - The project start date.
     * @param {string|date} projectEndDate - The project end date.
     * @return {string[]}
     */
    self.getBudgetHeaders = function getBudgetHeaders(projectStartDate, projectEndDate) {
        const headers = [];

        const startDate = moment(projectStartDate);
        let startYr = startDate.year();
        const startMonth = startDate.month();

        const endDate = moment(projectEndDate);
        let endYr = endDate.year();
        const endMonth = endDate.month();

        // Note: Months are zero indexed, so January is month 0.
        // https://momentjs.com/docs/#/get-set/month/

        // If startMonth is between jan (0) to june (5),
        // startYr must be the previous year to cover the july to june financial year.
        if (startMonth <= 5) {
            startYr -= 1;
        }

        // If endMonth is between july (6) to dec (11),
        // endYr must be the next year to cover the july to june financial year.
        if (endMonth >= 6) {
            endYr += 1;
        }

        // Generate the financial years between the start (inclusive) and end year (exclusive, to account for the half and half years).
        for (let i = startYr; i < endYr; i++) {
            headers.push(i.toString() + '/' + (i + 1).toString());
        }

        return headers;
    }

    const currentHeaders = (o.headers || []).map(function (element) {
        return new BudgetHeaderViewModel(element.data || '');
    });
    const newHeaders = self.getBudgetHeaders(projectStartDate, projectEndDate).map(function (element) {
        return new BudgetHeaderViewModel(element);
    });

    // Check whether any financial year headers have been added or removed.
    // A new project will not have any stored budget headers (oldHeaders).
    // So, if oldHeaders is empty, that is not a budget header change.
    const budgetHeadersChangeHasLength = currentHeaders.length > 0;
    const budgetHeadersChangeMatchLength = newHeaders.length === currentHeaders.length;
    const budgetHeadersChangeCompare = compareDataObjects(currentHeaders, newHeaders, null);
    const haveBudgetHeadersChanged = budgetHeadersChangeHasLength && (
        !budgetHeadersChangeMatchLength || budgetHeadersChangeCompare.different !== 0
    );
    self.transients.showBudgetHeadersChangedWarning = ko.observable(haveBudgetHeadersChanged);
    if (haveBudgetHeadersChanged) {
        const info = JSON.parse(JSON.stringify({
            'currentLength': currentHeaders.length,
            'newLength': newHeaders.length,
            'comparison': budgetHeadersChangeCompare,
        }));
        console.warn("[ProjectFundingBudget] Budget table headers have changed.", info);
    }

    self.transients.availableCategories = ko.observableArray(
        (findInContainer(fcConfig, ['financeDataDisplay', 'budget', 'options', 'budgetCategory']) || []).map(function (element) {
            return {'text': element.title, 'value': element.name};
        })
    );
    self.transients.availableClasses = ko.observableArray(
        (findInContainer(fcConfig, ['financeDataDisplay', 'budget', 'options', 'budgetClass']) || []).map(function (element) {
            return {'text': element.title, 'value': element.name};
        })
    );
    self.transients.availablePaymentStatuses = ko.observableArray(
        (findInContainer(fcConfig, ['financeDataDisplay', 'budget', 'options', 'budgetPaymentStatus']) || []).map(function (element) {
            return {'text': element.title, 'value': element.name};
        })
    );
    self.transients.availableRiskStatuses = ko.observableArray(
        (findInContainer(fcConfig, ['financeDataDisplay', 'budget', 'options', 'budgetRiskStatus']) || []).map(function (element) {
            return {'text': element.title, 'value': element.name};
        })
    );

    self.headers = ko.observableArray(newHeaders);

    /**
     * Array of budget item view models.
     * The property is created separately from populating the array because each item needs to reference the property.
     * @type {ObservableArray<any>}
     */
    self.rows = ko.observableArray();
    (o.rows || []).forEach(function (element) {
        self.rows.push(new BudgetItemViewModel(element, currentHeaders, newHeaders, self.rows));
    });

    self.overallTotal = ko.computed(function () {
        return self.rows().reduce(function (prev, current) {
            if (current && current.rowTotal()) {
                return prev + parseFloat(current.rowTotal() || "0");
            } else {
                return prev;
            }
        }, 0.0);
    }).extend({currency: {}});

    self.columnTotal = ko.observableArray(
        $.map(newHeaders, function (element, index) {
            return new BudgetTotalViewModel(self.rows, index);
        })
    );
    self.budgetOverallProfile = ko.observable(o.budgetOverallProfile);
    self.transients.displayedBudgetOverallProfile = ko.computed(function () {
        const name = self.budgetOverallProfile();
        const found = findInContainer(fcConfig, ['financeDataDisplay', 'budget', 'optionsByName', 'budgetRiskStatus', name]);
        return found ? found.title : '';
    });
    self.transients.displayedBudgetOverallProfileHighlight = ko.computed(function () {
        return riskLevelHighlight(self.budgetOverallProfile());
    });

    self.createBudgetItem = function addBudget() {
        return new BudgetItemViewModel({}, currentHeaders, newHeaders, self.rows);
    };

    self.transients.viewRows = new EditableTableViewModel(
        'budgetViewTable', self.rows, null, {
            enableAdd: false, enableMove: false, enableDelete: false, enablePaging: true, enableColumnSelection: true
        });
    self.transients.editRows = new EditableTableViewModel(
        'budgetEditTable', self.rows, self.createBudgetItem, {
            enableAdd: true, enableMove: true, enableDelete: true, enablePaging: true, enableColumnSelection: true
        });

    self.transients.totalFilterShortLabelSelected = ko.observable();
    self.transients.totalFilterShortLabelOptions = ko.computed(function () {
        return buildTotalFilterOptions(
            self.transients.availableCategories(),
            self.rows().map(el => el.shortLabel()));
    });
    self.transients.totalFilterPaymentNumberSelected = ko.observable();
    self.transients.totalFilterPaymentNumberOptions = ko.computed(function () {
        return buildTotalFilterOptions(
            [],
            self.rows().map(el => el.paymentNumber()));
    });
    self.transients.totalFilterFundClassSelected = ko.observable();
    self.transients.totalFilterFundClassOptions = ko.computed(function () {
        return buildTotalFilterOptions(
            self.transients.availableClasses(),
            self.rows().map(el => el.fundClass()));
    });
    self.transients.totalFilterFundingSourceSelected = ko.observable();
    self.transients.totalFilterFundingSourceOptions = ko.computed(function () {
        return buildTotalFilterOptions(
            [],
            self.rows().map(el => el.fundingSource()));
    });
    self.transients.totalFilterPaymentStatusSelected = ko.observable();
    self.transients.totalFilterPaymentStatusOptions = ko.computed(function () {
        return buildTotalFilterOptions(
            self.transients.availablePaymentStatuses(),
            self.rows().map(el => el.paymentStatus()));
    });
    self.transients.totalFilterRiskStatusSelected = ko.observable();
    self.transients.totalFilterRiskStatusOptions = ko.computed(function () {
        return buildTotalFilterOptions(
            self.transients.availableRiskStatuses(),
            self.rows().map(function (el) {
                return el.riskStatus();
            }));
    });
    self.transients.totalFilterRow = function totalFilterRow(rowItem) {
        return totalFilterAssess(self.transients.totalFilterShortLabelSelected(), rowItem.shortLabel()) &&
            totalFilterAssess(self.transients.totalFilterPaymentNumberSelected(), rowItem.paymentNumber()) &&
            totalFilterAssess(self.transients.totalFilterFundClassSelected(), rowItem.fundClass()) &&
            totalFilterAssess(self.transients.totalFilterFundingSourceSelected(), rowItem.fundingSource()) &&
            totalFilterAssess(self.transients.totalFilterPaymentStatusSelected(), rowItem.paymentStatus()) &&
            totalFilterAssess(self.transients.totalFilterRiskStatusSelected(), rowItem.riskStatus());
    };
    self.transients.totalFilterColumns = ko.computed(function () {
        const result = [];
        const rows = self.rows();
        rows.forEach(function (row, rowIndex) {
            const costs = row.costs();
            costs.forEach(function (cost, costIndex) {
                let dollar = parseFloat(cost.dollar() || "0");
                if (!self.transients.totalFilterRow(row)) {
                    dollar = 0.0;
                }
                if (result.length <= costIndex) {
                    result.push(dollar);
                } else {
                    result[costIndex] += dollar;
                }
            });
        });
        return result.map(function (value) {
            return new FloatViewModel({dollar: value});
        });
    });
    self.transients.totalFilterOverall = ko.computed(function () {
        return self.rows().reduce(function (prev, current) {
            if (!current || !current.rowTotal()) {
                return prev;
            }
            if (self.transients.totalFilterRow(current)) {
                return prev + parseFloat(current.rowTotal() || "0");
            } else {
                return prev;
            }
        }, 0.0);
    }).extend({currency: {}});
}

/**
 * Create a financial year budget header knockout view model.
 * @param {string} o - The financial year text for the header.
 * @constructor
 */
function BudgetHeaderViewModel(o) {
    const self = this;
    if (!o) o = '';

    if (!o || typeof o !== 'string') {
        throw `[ProjectFundingBudget] Must provide valid financial year string to BudgetHeaderViewModel '${o}' (${typeof o}).`;
    }

    // self.data is not an observable on purpose.
    // Once set on page load, it must not change.
    self.data = o;
}

/**
 * Create a row in the budget table.
 * Represented as a budget item knockout view model.
 * @param {object} o - The data for this instance.
 * @param {BudgetHeaderViewModel[]} currentFyHeaders - The current headers.
 * @param {BudgetHeaderViewModel[]} newFyHeaders - The new headers.
 * @param {ObservableArray} observableArrayContainer - The array holding this item.
 * @constructor
 */
function BudgetItemViewModel(o, currentFyHeaders, newFyHeaders, observableArrayContainer) {
    const self = this;
    if (!o) o = {};
    self.transients = self.transients || {};

    const unknown = '-';

    if (!newFyHeaders) {
        throw "[ProjectFundingBudget] Cannot continue without 'newFyHeaders'. Check projectStartDate and projectEndDate."
    }

    self.transients.observableArrayContainer = observableArrayContainer;
    self.transients.displayedRowNumber = ko.computed(function () {
        if (!self.transients.observableArrayContainer) {
            throw "observableArrayContainer is not set";
        }
        const index = self.transients.observableArrayContainer.indexOf(self);
        return (index >= 0) ? (index + 1).toString() : unknown;
    });

    self.shortLabel = ko.observable(o.shortLabel);
    self.description = ko.observable(o.description);
    self.dueDate = ko.observable(o.dueDate).extend({simpleDate: false});
    self.paymentStatus = ko.observable(o.paymentStatus);
    self.paymentNumber = ko.observable(o.paymentNumber || o.glCode);
    self.fundingSource = ko.observable(o.fundingSource);
    self.fundClass = ko.observable(o.fundClass);
    self.riskStatus = ko.observable(o.riskStatus);

    // Adjust the columns to match the financial year headers.
    // WARNING: If the financial year headers have changed,
    //          any data in columns that do not match the new headers will be deleted.
    self.costs = ko.observableArray(
        newFyHeaders.map(function (newHeader) {
            const newHeaderText = newHeader.data;
            const currentHeaderIndex = currentFyHeaders.findIndex(function (currentHeader) {
                return currentHeader.data === newHeaderText;
            });

            // Build the costs for this row, using the new f/y header index.
            if (currentHeaderIndex >= 0 && o.costs && currentHeaderIndex < o.costs.length) {
                // if there is a costs entry, use it
                return new FloatViewModel(o.costs[currentHeaderIndex]);
            } else {
                // if there are no costs or there is no matching costs entry, use the defaults
                return new FloatViewModel({});
            }
        })
    );

    self.rowTotal = ko.computed(function () {
        return self.costs().reduce(function (prev, current) {
            if (current && current.dollar()) {
                return prev + parseFloat(current.dollar() || "0");
            } else {
                return prev;
            }
        }, 0.0);
    }).extend({currency: {}});

    self.transients.displayedRiskStatusHighlight = ko.computed(function () {
        return riskLevelHighlight(self.riskStatus());
    });

    self.transients.displayedCategory = ko.computed(function () {
        const name = self.shortLabel();
        const found = findInContainer(fcConfig, ['financeDataDisplay', 'budget', 'optionsByName', 'budgetCategory', name]);
        return found ? found.title : unknown;
    });
    self.transients.displayedClass = ko.computed(function () {
        const name = self.fundClass();
        const found = findInContainer(fcConfig, ['financeDataDisplay', 'budget', 'optionsByName', 'budgetClass', name]);
        return found ? found.title : unknown;
    });
    self.transients.displayedPaymentStatus = ko.computed(function () {
        const name = self.paymentStatus();
        const found = findInContainer(fcConfig, ['financeDataDisplay', 'budget', 'optionsByName', 'budgetPaymentStatus', name]);
        return found ? found.title : unknown;
    });
    self.transients.displayedRiskStatus = ko.computed(function () {
        const name = self.riskStatus();
        const found = findInContainer(fcConfig, ['financeDataDisplay', 'budget', 'optionsByName', 'budgetRiskStatus', name]);
        return found ? found.title : unknown;
    });
}

/**
 * Create a budget total knockout view model.
 * @param {Observable<BudgetItemViewModel[]>} rows - The rows for this instance.
 * @param {number} index - The index of this budget total instance.
 * @constructor
 */
function BudgetTotalViewModel(rows, index) {
    const self = this;

    self.transients = self.transients || {};
    self.transients.rows = rows;
    self.transients.index = index;

    self.data = ko.computed(function () {
        const dataRows = self.transients.rows();
        const dataIndex = self.transients.index;
        return dataRows.reduce(function (prev, current) {
            if (!current) {
                return prev;
            }

            // add this row's costs.dollar
            if (current && current.costs() && dataIndex < current.costs().length && current.costs()[dataIndex].dollar()) {
                return prev + parseFloat(current.costs()[dataIndex].dollar() || "0");
            }

            return prev;
        }, 0.0);
    }).extend({currency: {}});
}
