describe("OrganisationViewModel Spec", function () {
    const koToJSON = function koToJSON(obj) {
        return ko.mapping.toJS(obj, {'ignore': ['transients']});
    };

    it("should be able to create and manipulate rows", function () {
        // arrange
        const name = 'myTable';
        const row1 = new FloatViewModel({dollar: 1.0});
        const row2 = new FloatViewModel({dollar: 2.0});
        const row3 = new FloatViewModel({dollar: 3.0});
        const rowNew = new FloatViewModel({});
        const initialRows = ko.observableArray([row1, row2, row3]);
        const newRowFunc = function newRowFunc() {
            return new FloatViewModel({});
        };
        const config = {
            enableAdd: true,
            enableMove: true,
            enableDelete: true,
            enablePaging: true,
            enableColumnSelection: true
        }

        // act
        const et = new EditableTableViewModel(name, initialRows, newRowFunc, config);

        // assert
        expect(et.config).toEqual(config);
        expect(koToJSON(et.rows())).toEqual(koToJSON(initialRows()));

        // act
        et.moveRowDown(row2);

        // asert
        expect(koToJSON(et.rows())).toEqual(koToJSON([row1, row3, row2]));

        // act
        et.deleteRow(row1);
        $('button.bootbox-accept').click();

        // assert
        expect(koToJSON(et.rows())).toEqual(koToJSON([row3, row2]));

        // act
        et.addRow();

        // assert
        expect(koToJSON(et.rows())).toEqual(koToJSON([row3, row2, rowNew]));

        // act
        et.displayedRowsSelected(2);

        // assert
        expect(koToJSON(et.displayedRows())).toEqual(koToJSON([row3, row2]));
    });

});