describe("ProjectActivityViewModel Spec", function () {
    beforeAll(function() {
        window.fcConfig = {
            imageLocation:'/'
        }
    });
    afterAll(function() {
        delete window.fcConfig;
    });

    it("should be able to be initialised from an object literal", function () {
        var projectActivity = new ProjectActivity();
        expect(projectActivity.projectId()).toEqual("");
        expect(projectActivity.sites()).toEqual([]);
        expect(projectActivity.species).toEqual(jasmine.any(SpeciesConstraintViewModel));
        expect(projectActivity.visibility).toEqual(jasmine.any(SurveyVisibilityViewModel));
    });

    it("Survey should have a default survey name", function () {
        var pActivity = new ProjectActivity([],[],[],[]);
        expect(pActivity.name()).toEqual("Survey name");
    });

    it("default survey status should be active", function () {
        var pActivity = new ProjectActivity([],[],[],[]);
        expect(pActivity.status()).toEqual("active");
    });

});

describe("pActivityInfo Spec", function () {
    beforeAll(function() {
        window.fcConfig = {
            imageLocation:'/'
        }
    });
    afterAll(function() {
        delete window.fcConfig;
    });

    it("should be able to be initialised from an object literal", function () {
        var projectActivity = new pActivityInfo();
        expect(projectActivity.projectActivityId()).toEqual(undefined);
        expect(projectActivity.name()).toEqual("Survey name");
        expect(projectActivity.description()).toEqual(undefined);
        expect(projectActivity.status()).toEqual("active");
        expect(projectActivity.startDate()).toEqual("");
        expect(projectActivity.endDate()).toEqual("");
        expect(projectActivity.commentsAllowed()).toEqual(false);
        expect(projectActivity.published()).toEqual(false);
        expect(projectActivity.logoUrl()).toEqual("//no-image-2.png");
        expect(projectActivity.current()).toEqual(undefined);
        expect(projectActivity.transients.status()).toEqual("Active, Not yet started");
        expect(projectActivity.transients.daysTotal()).toEqual(-1);
        expect(projectActivity.transients.daysRemaining()).toEqual(-1);
    });

    it("check daysTotal and daysRemaining for given start and end date", function () {
        var info = {};
        var today = new Date();
        var past = new Date(today);
        var future = new Date(today);
        future.setDate(today.getDate()-10);
        past.setDate(today.getDate()-30);
        info.startDate = past;
        info.endDate = future;
        var projectActivity = new pActivityInfo(info);
        expect(projectActivity.transients.daysTotal()).toEqual(20);
        expect(projectActivity.transients.daysRemaining()).toEqual(0);
        expect(projectActivity.transients.daysSince()).toEqual(30);
        expect(projectActivity.transients.status()).toEqual("Inactive, Completed");
    });

});


describe("SpeciesConstraintViewModel Spec", function () {
    beforeAll(function() {
        window.fcConfig = {
            imageLocation:'/'
        }
    });
    afterAll(function() {
        delete window.fcConfig;
    });

    it("should be able to be initialised from an object literal", function () {
        var speciesVM = new SpeciesConstraintViewModel();
        expect(speciesVM.transients.allowedListTypes.length).toBeGreaterThan(0);
    });

    it("by default both add lists and pick lists should not be visible", function () {
        var speciesVM = new SpeciesConstraintViewModel();
        expect(speciesVM.transients.showAddSpeciesLists()).toBe(false);
        expect(speciesVM.transients.showExistingSpeciesLists()).toBe(false);
    });

    it("single species selection should make single species option visible", function () {
        var speciesVM = new SpeciesConstraintViewModel();
        speciesVM.type("SINGLE_SPECIES");
        expect(speciesVM.singleInfoVisible()).toBe(true);
        speciesVM.type("GROUP_OF_SPECIES");
        expect(speciesVM.groupInfoVisible()).toBe(true);
    });

    it("invalid species options should return empty map", function () {
        var speciesVM = new SpeciesConstraintViewModel();
        speciesVM.type("XYZ");
        var map = {};
        expect(speciesVM.asJson()).toEqual(map);

        speciesVM.type("SINGLE_SPECIES");
        var map = {};
        expect(speciesVM.asJson()).not.toEqual(map);
    });

});

describe("SpeciesListsViewModel Spec", function () {
    beforeAll(function() {
        window.fcConfig = {
            imageLocation:'/'
        }
    });
    afterAll(function() {
        delete window.fcConfig;
    });

    it("default offset value should be 0", function () {
        var listsVM = new SpeciesListsViewModel();
        expect(listsVM.offset()).toEqual(0);
    });

    it("previous selection should be available when offset is greater than 0", function () {
        var listsVM = new SpeciesListsViewModel();
        listsVM.offset(0);
        expect(listsVM.isPrevious ()).toEqual(false);
        listsVM.offset(2);
        expect(listsVM.isPrevious ()).toEqual(true);
    });

    it("next selection should not be available when total species count is 0", function () {
        var listsVM = new SpeciesListsViewModel();
        listsVM.listCount(0);
        expect(listsVM.isNext ()).toEqual(false);
    });
});


describe("SurveyVisibilityViewModel Spec", function () {
    beforeAll(function() {
        window.fcConfig = {
            imageLocation:'/'
        }
    });
    afterAll(function() {
        delete window.fcConfig;
    });

    it("should be able to be initialised from an object literal", function () {
        var visibility = new SurveyVisibilityViewModel();
        expect(visibility.setDate()).not.toEqual(0);
        expect(visibility.constraint()).not.toEqual("");
    });

    it("default visibility should be public", function () {
        var visibility = new SurveyVisibilityViewModel();
        expect(visibility.constraint()).toEqual("PUBLIC");
    });
    it("default set date should be 60", function () {
        var visibility = new SurveyVisibilityViewModel();
        expect(visibility.setDate()).toEqual(60);
    });

});