/**
 * Create an editable table view model.
 *
 * NOTE: Create the EditableTableViewModel set to a `transients` property,
 * so that the properties in the editable table model aren't included on save.
 *
 * @param {string} tableName - The name of the table.
 * @param {array|observableArray} initialRows - The initial rows for the table.
 * @param {Function} newRowFunction - The function to call when a new row is added. Takes no arguments and returns a new row item that is not yet in the observable array.
 * @param {Object} config - Configuration for the table.
 * @param {boolean} config.enableAdd - Whether to allow rows to be added. Default false.
 * @param {boolean} config.enableMove - Whether to allow rows to be moved up and down. Default false.
 * @param {boolean} config.enableDelete - Whether to allow rows to be deleted. Default false.
 * @param {boolean} config.enablePaging - Whether to allow rows to be paged. Default true.
 * @param {boolean} config.enableColumnSelection - Whether to allow columns to be hidden. Default false.
 * @constructor
 */
function EditableTableViewModel(tableName, initialRows, newRowFunction, config) {
    const self = this;

    const defaultAllText = 'All';
    const logPrefix = '[EditableTable]';

    self.config = Object.assign({}, {
        enableAdd: false,
        enableMove: false,
        enableDelete: false,
        enablePaging: true,
        enableColumnSelection: false
    }, config);

    self.newRowFunction = newRowFunction;

    /**
     * The complete array of rows tracked by this model.
     * @type {ObservableArray<any>}
     */
    if (ko.isObservable(initialRows)) {
        self.rows = initialRows;
    } else {
        throw `${logPrefix} Editable table initial rows must be an observable array.`;
    }

    /**
     * The unfiltered total number of rows.
     * @type {PureComputed<number>}
     */
    self.countRows = ko.pureComputed(function () {
        return self.rows().length;
    });

    /**
     * The next row number after the unfiltered total number of rows.
     * There is no existing row with this number.
     * @type {PureComputed<any>}
     */
    self.nextRow = ko.pureComputed(function () {
        return self.countRows() + 1;
    });

    /**
     * Move a row by the given number of rows.
     * @param {number} rowIndex - Index of the row to be moved. Equal or greater than 0.
     * @param {number} count - Number of rows to move. Positive moves towards end of table, negative moves towards start of table. Must not be 0.
     */
    self.moveRowCount = function moveRowCount(rowIndex, count) {
        if (!self.config.enableMove) {
            console.warn(`${logPrefix} Row move is disabled for table '${tableName}', 
            so cannot move row index '${rowIndex}' by '${count}'.`);
            return;
        }
        const newIndex = rowIndex + count;
        return self.moveRowIndex(rowIndex, newIndex);
    };

    /**
     * Move a row to a new index.
     * @param {number} rowIndex - Index of the row to be moved. Equal or greater than 0.
     * @param {number} newIndex - New index of row. Equal or greater than 0.
     */
    self.moveRowIndex = function moveRowIndex(rowIndex, newIndex) {
        if (!self.config.enableMove) {
            console.warn(`${logPrefix} Row move is disabled for table '${tableName}', 
            so cannot move row index '${rowIndex}' to index '${newIndex}'.`);
            return;
        }

        const arr = self.rows;
        const arrLength = arr().length;
        if (arrLength < 1 || rowIndex < 0 || newIndex < 0 || rowIndex > arrLength - 1 || rowIndex === newIndex) {
            console.error(`${logPrefix} Table ${tableName} cannot move index '${rowIndex}' to '${newIndex}' for array with '${arrLength}' items.`);
            return;
        }

        // move the item
        const element = arr()[rowIndex];

        // use the knockout js splice
        arr.splice(rowIndex, 1);
        arr.splice(newIndex, 0, element);

        // update the selected item in the add row dropdown
        self.addRowSelected(self.nextRow());

        console.info(`${logPrefix} Table '${tableName}' row moved from index '${rowIndex}' to index '${newIndex}'.`);
    }

    /**
     * Move a row up one.
     * @param rowItem - The row model to move.
     * @return {*}
     */
    self.moveRowUp = function moveRowUp(rowItem) {
        const rowIndex = self.rows.indexOf(rowItem);
        if (rowIndex < 0) {
            console.error(`${logPrefix} 'Table ${tableName} could not get index for row item '${rowItem}'.`);
            return;
        }
        return self.moveRowCount(rowIndex, -1);
    };

    /**
     * Move a row down one.
     * @param rowItem - The row model to move.
     * @return {*}
     */
    self.moveRowDown = function moveRowUp(rowItem) {
        const rowIndex = self.rows.indexOf(rowItem);
        if (rowIndex < 0) {
            console.error(`${logPrefix} 'Table ${tableName} could not get index for row item '${rowItem}'.`);
            return;
        }
        return self.moveRowCount(rowIndex, 1);
    };

    /**
     * Delete the row at the given index.
     * @param {any} rowItem - The row item to delete.
     */
    self.deleteRow = function deleteRow(rowItem) {
        if (!self.config.enableDelete) {
            console.warn(`${logPrefix} Row deletion is disabled for table '${tableName}', 
            so cannot delete row.`);
            return;
        }

        const message = "<div class='alert alert-error'>" +
            "<span class='label label-important'>Important</span>" +
            "<br>" +
            "<b>WARNING: This deletion cannot be undone.</b>" +
            "<br>" +
            "Are you sure you want to delete this row?" +
            "</div>";

        bootbox.confirm(message, function (result) {
            // if the response was true
            if (result) {
                const rowIndex = self.rows.indexOf(rowItem);

                // delete the row item
                self.rows.remove(rowItem);

                console.info(`${logPrefix} Table '${tableName}' row deleted at index '${rowIndex}'.`);

                // update the selected item in the add row dropdown
                self.addRowSelected(self.nextRow());
            }
        });

    };

    /**
     * Add a new row at the given index.
     */
    self.addRow = function addRow() {
        if (!self.config.enableAdd) {
            console.warn(`${logPrefix} Row addition is disabled for table '${tableName}', 
            so cannot add row.`);
            return;
        }
        const rowIndex = self.addRowSelected() - 1;

        console.info(`${logPrefix} Table '${tableName}' row inserted at index '${rowIndex}'.`);
        const newItem = self.newRowFunction();
        self.rows.splice(rowIndex, 0, newItem);

        // update the selected item in the add row dropdown
        self.addRowSelected(self.nextRow());
    };

    /**
     * Get the observable options for the add row dropdown.
     * @type {PureComputed<*[]>}
     * @return {array<number>}
     */
    self.addRowOptions = ko.pureComputed(function () {
        const positions = [];

        if (self.config.enableAdd) {
            const rowsCount = self.nextRow();
            for (let i = 1; i <= rowsCount; i++) {
                positions.push(i);
            }
        }

        return positions;
    });

    /**
     * Get the observable selected option for the add row dropdown.
     * @type {Observable<*>}
     * @return {number}
     */
    self.addRowSelected = ko.observable(/* default value: */ self.countRows() + 1);

    /**
     * Get the observable number of rows currently displayed.
     * @type {PureComputed<number>}
     */
    self.displayedRowsCount = ko.pureComputed(function () {
        return self.displayedRows().length;
    });

    /**
     * Get the observable options for number of table rows to display.
     * @type {PureComputed<(number|string)[]>}
     * @return {number|string}
     */
    self.displayedRowsOptions = ko.pureComputed(function () {
        return self.config.enablePaging ? [defaultAllText, 5, 10, 25, 50, 100] : [defaultAllText];
    });

    /**
     * Get the observable selected number of rows to display (or all).
     * @type {Observable<string>}
     * @return {number|string}
     */
    self.displayedRowsSelected = ko.observable(/* default value: */ defaultAllText);
    self.displayedRowsSelected.subscribe(function () {
        // when the number of rows to display is change, reset the page number to 1
        self.displayedPage(1);
    });

    /**
     * Get the observable current page of displayed rows. Page numbers start at 1.
     * @type {Observable<number>}
     */
    self.displayedPage = ko.observable(/* default value: */ 1);

    /**
     * Get the observable rows currently displayed.
     * @type {Computed<any>}
     * @return {array}
     */
    self.displayedRows = ko.computed(function () {
        // NOTE: A ko computed must return the actual array, not the observable array

        // if the rows cannot be paged, just return the rows
        if (!self.config.enablePaging) {
            console.info(`${logPrefix} 'enablePaging' is not true for table '${tableName}'.`);
            return self.rows();
        }

        const displayedRowsSelected = self.displayedRowsSelected();
        const totalRows = self.countRows();

        // if the selected number of rows to show is not valid, just return the rows
        if (!displayedRowsSelected) {
            console.warn(`${logPrefix} Cannot enable paging for table '${tableName}' 
            because '${displayedRowsSelected}' is not a valid number of rows.`);
            return self.rows();
        }
        if (totalRows < 1 || displayedRowsSelected === defaultAllText) {
            return self.rows();
        }

        // return the slice of rows that matches the selected number of rows to display and the current page
        const displayedPageIndex = self.displayedPage() - 1;
        const sliceStartInclusive = displayedPageIndex * displayedRowsSelected;
        const sliceEndExclusive = Math.min(totalRows, sliceStartInclusive + displayedRowsSelected);
        return self.rows.slice(sliceStartInclusive, sliceEndExclusive);
    });

    /**
     * Get the computed options for page numbers to display.
     * @type {PureComputed<any>}
     */
    self.displayedPages = ko.pureComputed(function () {
        const totalRows = self.countRows();
        const rowsPerPage = self.displayedRowsSelected();

        // no paging needed if all pages are displayed
        if (rowsPerPage === defaultAllText) {
            return [
                new EditableTablePageViewModel({
                    itemNumber: 1,
                    itemClass: 'disabled',
                    itemEnabled: false,
                    itemTitle: 'Previous Page',
                    itemHtml: '&laquo;'
                }),
                new EditableTablePageViewModel({
                    itemNumber: 1,
                    itemClass: 'active',
                    itemEnabled: false,
                    itemTitle: 'Current Page',
                    itemHtml: `1 - ${totalRows}`
                }),
                new EditableTablePageViewModel({
                    itemNumber: 1,
                    itemClass: 'disabled',
                    itemEnabled: false,
                    itemTitle: 'Next Page',
                    itemHtml: '&raquo;'
                }),
            ];
        }

        if (!self.config.enablePaging) {
            throw `${logPrefix} Row paging is disabled for table '${tableName}'. 
            Please check why paging was attempted.`;
        }

        // calculate the total rows and max page number
        // build and return the pagination items
        const currentPage = self.displayedPage();

        const minPage = 1;
        const maxPage = Math.ceil(totalRows / rowsPerPage);
        const previousPage = (currentPage > minPage) ? (currentPage - 1) : minPage;
        const nextPage = (currentPage < maxPage) ? (currentPage + 1) : maxPage;

        const hasPreviousPage = previousPage < currentPage;
        const hasNextPage = nextPage > currentPage;

        const range = (start, end) => Array.from({length: (end - start)}, (v, k) => k + start);

        const numbered = range(minPage, maxPage + 1).map(function (element) {
            const isCurrentPage = element === currentPage;
            const rowNumStart = (element - 1) * rowsPerPage + 1;
            const rowNumEnd = Math.min(element * rowsPerPage, totalRows);
            return new EditableTablePageViewModel({
                itemNumber: element,
                itemClass: isCurrentPage ? 'active' : '',
                itemEnabled: !isCurrentPage,
                itemTitle: 'Page ' + element.toString() + (isCurrentPage ? '(current)' : ''),
                itemHtml: `${rowNumStart} - ${rowNumEnd}`
            });
        });

        return [].concat([
            new EditableTablePageViewModel({
                itemNumber: previousPage,
                itemClass: hasPreviousPage ? '' : 'disabled',
                itemEnabled: hasPreviousPage,
                itemTitle: 'Previous Page',
                itemHtml: '&laquo;'
            }),
        ]).concat(numbered).concat([
            new EditableTablePageViewModel({
                itemNumber: nextPage,
                itemClass: hasNextPage ? '' : 'disabled',
                itemEnabled: hasNextPage,
                itemTitle: 'Next Page',
                itemHtml: '&raquo;'
            }),
        ]);
    });

    /**
     * Set the displayed page.
     * @param pageItem
     */
    self.setDisplayedPage = function setDisplayedPage(pageItem) {
        self.displayedPage(pageItem.itemNumber);
    };
}

function EditableTablePageViewModel(o) {
    const self = this;
    if (!o) o = {};

    if (!o.itemNumber || o.itemNumber <= 0) {
        throw "The editable table page number must be supplied, and must be greater than 0.";
    }

    self.itemNumber = o.itemNumber;
    self.itemClass = o.itemClass || ''; // options: 'disabled', 'active', ''
    self.itemEnabled = o.itemEnabled || false; // options: true, false
    self.itemTitle = o.itemTitle || self.itemNumber || '';
    self.itemHtml = o.itemHtml || self.itemNumber || '';
}