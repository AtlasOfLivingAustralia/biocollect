describe("OrganisationViewModel Spec", function () {
    beforeAll(function() {
        window.fcConfig = {
            imageLocation:'/'
        }
    });
    afterAll(function() {
        delete window.fcConfig;
    });

    it("should serialize into JSON which does not contain any fields that are only useful to the view", function() {
        var organisation = { organisationId:'1', name:"Org 1", description:'Org 1 description', collectoryInstitutionId:'dr123', newsAndEvents:'this is the latest news', documents:[], links:[]};

        var model = new OrganisationViewModel(organisation);

        var json = model.modelAsJSON(true);

        var expectedJS = jQuery.extend({}, organisation);
        delete expectedJS.collectoryInstitutionId;  // This field shouldn't be updated.

        expect(JSON.parse(json)).toEqual(expectedJS);

    });

});