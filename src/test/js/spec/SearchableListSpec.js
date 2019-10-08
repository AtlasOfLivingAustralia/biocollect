describe("SearchableList Spec", function () {
    beforeAll(function() {
        window.fcConfig = {
            imageLocation:'/'
        }
    });
    afterAll(function() {
        delete window.fcConfig;
    });

    var organisations = [
        { name:'Org 1'},
        { name:'Org 2'},
        { name:'Org 3'},
        { name:'Org 4'},
        { name:'Org 5'},
        { name:'Org 6'},
        { name:'Org 7'}
    ];

    it("should update search results when a term is supplied", function () {

        var searchableList = new SearchableList(organisations, ['name']);
        searchableList.term('1');

        expect(searchableList.results()).toEqual([{name:'Org 1'}]);

        searchableList.term('Org');
        expect(searchableList.results()).toEqual(organisations);

        searchableList.term('Org 3');
        expect(searchableList.results()[0]).toEqual({name:'Org 3'});

    });

    it("should return all results when no term is supplied", function() {

        var searchableList = new SearchableList(organisations, ['name']);
        expect(searchableList.results()).toEqual(organisations);

        searchableList.term('1');
        searchableList.term('');
        expect(searchableList.results()).toEqual(organisations);
    });

    it("should maintain a selection based on the supplied search keys", function() {
        var searchableList = new SearchableList(organisations, ['name']);
        searchableList.select({name:'Org 5'});

        expect(searchableList.isSelected({name:'Org 5'})).toBe(true);
        expect(searchableList.isSelected({name:'Org 1'})).toBe(false);

    });

});
