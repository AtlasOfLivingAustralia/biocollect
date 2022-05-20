describe("AllDocListViewModel Spec", function () {
    beforeAll(function() {
        window.fcConfig = {
            imageLocation:'/',
            useExistingModel:false,
            projectId:""
        }
    });

    it("should map user supplied document type to role defined in database", function () {
        var allDocListViewModel = new AllDocListViewModel("");

        expect(allDocListViewModel.mapDocumentForSearch('Journal Articles')).toEqual('journalArticles');
    });
});
