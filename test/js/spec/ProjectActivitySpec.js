describe("ProjectActivityViewModel Spec", function () {
    beforeAll(function() {
        window.fcConfig = {
            serverUrl: "http://devt.ala.org.au:8087/biocollect",
            activityUpdateUrl: "/biocollect/sightings/activity/ajaxUpdate",
            activityDeleteUrl: "/biocollect/sightings/activity/ajaxDelete",
            projectViewUrl: "/biocollect/sightings/project/index/",
            siteViewUrl: "/biocollect/sightings/site/index/",
            bieUrl: "https://bie.ala.org.au",
            imageLocation:"/biocollect/assets/",
            createCommentUrl : "/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            commentListUrl:"/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            updateCommentUrl:"/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            deleteCommentUrl:"/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            imageLeafletViewer: 'http://devt.ala.org.au:8087/biocollect/sightings/resource/imageviewer',
            projectIndexUrl: "/biocollect/sightings/project/index",
            activityViewUrl: "/biocollect/sightings/bioActivity/index",
            getGuidForOutputSpeciesUrl : "/biocollect/sightings/record/getGuidForOutputSpeciesIdentifier",
            uploadImagesUrl: "/biocollect/ws/attachment/upload?hub=sightings",
            searchBieUrl: "/biocollect/search/searchSpecies/e61eb018-02a9-4e3b-a4b3-9d6be33d9cbb?limit=10&hub=sightings",
            speciesListUrl: "/biocollect/sightings/proxy/speciesItemsForList",
            speciesProfileUrl: "/biocollect/sightings/proxy/speciesProfile",
            noImageUrl: '/biocollect/assets/no-image-2-14a0a809823b65b821d14e1b5f6e2e9f.png',
            speciesImageUrl:"/biocollect/sightings/species/speciesImage"
        }
    });
    afterAll(function() {
        delete window.fcConfig;
    });

    it("should be able to be initialised from an object literal", function () {
        var projectActivity = new ProjectActivity();
        expect(projectActivity.projectId()).toEqual("");
        expect(projectActivity.sites()).toEqual([]);
        expect(projectActivity.speciesFields()).toEqual([]);
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

    it("species asJS('species') should return a map with species and speciesFields", function () {

        var params = {
            pActivity: {
                speciesFields: [
                    {
                        label: "species field 1",
                        output: "output 1",
                        dataFieldName: "data field name 1",
                        context: "",
                        config: {
                            type: "ALL_SPECIES",
                            speciesDisplayFormat: "COMMONNAME"
                        }
                    },
                    {
                        label: "species field 2",
                        output: "output 2",
                        dataFieldName: "data field name 2",
                        context: "",
                        config: {
                            type: "ALL_SPECIES",
                            speciesDisplayFormat: "SCIENTIFICNAME"
                        }
                    }
                ]
            }
        }

        var speciesVM = new ProjectActivity(params);
        expect(speciesVM.asJS("species")).toEqual(params.pActivity);
    });

});

describe("pActivityInfo Spec", function () {
    beforeAll(function() {
        window.fcConfig = {
            serverUrl: "http://devt.ala.org.au:8087/biocollect",
            activityUpdateUrl: "/biocollect/sightings/activity/ajaxUpdate",
            activityDeleteUrl: "/biocollect/sightings/activity/ajaxDelete",
            projectViewUrl: "/biocollect/sightings/project/index/",
            siteViewUrl: "/biocollect/sightings/site/index/",
            bieUrl: "https://bie.ala.org.au",
            imageLocation:"/biocollect/assets/",
            createCommentUrl : "/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            commentListUrl:"/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            updateCommentUrl:"/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            deleteCommentUrl:"/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            imageLeafletViewer: 'http://devt.ala.org.au:8087/biocollect/sightings/resource/imageviewer',
            projectIndexUrl: "/biocollect/sightings/project/index",
            activityViewUrl: "/biocollect/sightings/bioActivity/index",
            getGuidForOutputSpeciesUrl : "/biocollect/sightings/record/getGuidForOutputSpeciesIdentifier",
            uploadImagesUrl: "/biocollect/ws/attachment/upload?hub=sightings",
            searchBieUrl: "/biocollect/search/searchSpecies/e61eb018-02a9-4e3b-a4b3-9d6be33d9cbb?limit=10&hub=sightings",
            speciesListUrl: "/biocollect/sightings/proxy/speciesItemsForList",
            speciesProfileUrl: "/biocollect/sightings/proxy/speciesProfile",
            noImageUrl: '/biocollect/assets/no-image-2-14a0a809823b65b821d14e1b5f6e2e9f.png',
            speciesImageUrl:"/biocollect/sightings/species/speciesImage"
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
        expect(projectActivity.publicAccess()).toEqual(false);
        expect(projectActivity.published()).toEqual(false);
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
            serverUrl: "http://devt.ala.org.au:8087/biocollect",
            activityUpdateUrl: "/biocollect/sightings/activity/ajaxUpdate",
            activityDeleteUrl: "/biocollect/sightings/activity/ajaxDelete",
            projectViewUrl: "/biocollect/sightings/project/index/",
            siteViewUrl: "/biocollect/sightings/site/index/",
            bieUrl: "https://bie.ala.org.au",
            imageLocation:"/biocollect/assets/",
            createCommentUrl : "/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            commentListUrl:"/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            updateCommentUrl:"/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            deleteCommentUrl:"/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            imageLeafletViewer: 'http://devt.ala.org.au:8087/biocollect/sightings/resource/imageviewer',
            projectIndexUrl: "/biocollect/sightings/project/index",
            activityViewUrl: "/biocollect/sightings/bioActivity/index",
            getGuidForOutputSpeciesUrl : "/biocollect/sightings/record/getGuidForOutputSpeciesIdentifier",
            uploadImagesUrl: "/biocollect/ws/attachment/upload?hub=sightings",
            searchBieUrl: "/biocollect/search/searchSpecies/e61eb018-02a9-4e3b-a4b3-9d6be33d9cbb?limit=10&hub=sightings",
            speciesListUrl: "/biocollect/sightings/proxy/speciesItemsForList",
            speciesProfileUrl: "/biocollect/sightings/proxy/speciesProfile",
            noImageUrl: '/biocollect/assets/no-image-2-14a0a809823b65b821d14e1b5f6e2e9f.png',
            speciesImageUrl:"/biocollect/sightings/species/speciesImage"
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

    it("invalid species options should return and empty type configuration but default display format", function () {
        var speciesVM = new SpeciesConstraintViewModel();
        speciesVM.type("XYZ");
        var map = {
            speciesDisplayFormat: 'SCIENTIFICNAME(COMMONNAME)'
        };
        expect(speciesVM.asJson()).toEqual(map);

        speciesVM.type("SINGLE_SPECIES");
        var map = {};
        expect(speciesVM.asJson()).not.toEqual(map);
    });

});

describe("SpeciesListsViewModel Spec", function () {
    beforeAll(function() {
        window.fcConfig = {
            serverUrl: "http://devt.ala.org.au:8087/biocollect",
            activityUpdateUrl: "/biocollect/sightings/activity/ajaxUpdate",
            activityDeleteUrl: "/biocollect/sightings/activity/ajaxDelete",
            projectViewUrl: "/biocollect/sightings/project/index/",
            siteViewUrl: "/biocollect/sightings/site/index/",
            bieUrl: "https://bie.ala.org.au",
            imageLocation:"/biocollect/assets/",
            createCommentUrl : "/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            commentListUrl:"/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            updateCommentUrl:"/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            deleteCommentUrl:"/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            imageLeafletViewer: 'http://devt.ala.org.au:8087/biocollect/sightings/resource/imageviewer',
            projectIndexUrl: "/biocollect/sightings/project/index",
            activityViewUrl: "/biocollect/sightings/bioActivity/index",
            getGuidForOutputSpeciesUrl : "/biocollect/sightings/record/getGuidForOutputSpeciesIdentifier",
            uploadImagesUrl: "/biocollect/ws/attachment/upload?hub=sightings",
            searchBieUrl: "/biocollect/search/searchSpecies/e61eb018-02a9-4e3b-a4b3-9d6be33d9cbb?limit=10&hub=sightings",
            speciesListUrl: "/biocollect/sightings/proxy/speciesItemsForList",
            speciesProfileUrl: "/biocollect/sightings/proxy/speciesProfile",
            noImageUrl: '/biocollect/assets/no-image-2-14a0a809823b65b821d14e1b5f6e2e9f.png',
            speciesImageUrl:"/biocollect/sightings/species/speciesImage"
        }
    });
    afterAll(function() {
        delete window.fcConfig;
    });

    it("default offset value should be 0", function () {
        var listsVM = new SpeciesListsViewModel();
        expect(listsVM.offset()).toEqual(0);
    });

});


describe("SurveyVisibilityViewModel Spec", function () {
    beforeAll(function() {
        window.fcConfig = {
            serverUrl: "http://devt.ala.org.au:8087/biocollect",
            activityUpdateUrl: "/biocollect/sightings/activity/ajaxUpdate",
            activityDeleteUrl: "/biocollect/sightings/activity/ajaxDelete",
            projectViewUrl: "/biocollect/sightings/project/index/",
            siteViewUrl: "/biocollect/sightings/site/index/",
            bieUrl: "https://bie.ala.org.au",
            imageLocation:"/biocollect/assets/",
            createCommentUrl : "/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            commentListUrl:"/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            updateCommentUrl:"/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            deleteCommentUrl:"/biocollect/bioActivity/ba30ab70-a126-44e6-ac23-31774acd7144/comment",
            imageLeafletViewer: 'http://devt.ala.org.au:8087/biocollect/sightings/resource/imageviewer',
            projectIndexUrl: "/biocollect/sightings/project/index",
            activityViewUrl: "/biocollect/sightings/bioActivity/index",
            getGuidForOutputSpeciesUrl : "/biocollect/sightings/record/getGuidForOutputSpeciesIdentifier",
            uploadImagesUrl: "/biocollect/ws/attachment/upload?hub=sightings",
            searchBieUrl: "/biocollect/search/searchSpecies/e61eb018-02a9-4e3b-a4b3-9d6be33d9cbb?limit=10&hub=sightings",
            speciesListUrl: "/biocollect/sightings/proxy/speciesItemsForList",
            speciesProfileUrl: "/biocollect/sightings/proxy/speciesProfile",
            noImageUrl: '/biocollect/assets/no-image-2-14a0a809823b65b821d14e1b5f6e2e9f.png',
            speciesImageUrl:"/biocollect/sightings/species/speciesImage"
        }
    });
    afterAll(function() {
        delete window.fcConfig;
    });

    it("should be able to be initialised from an object literal", function () {
        var visibility = new SurveyVisibilityViewModel();
        expect(visibility.embargoForDays()).not.toEqual(0);
        expect(visibility.embargoOption()).not.toEqual("");
    });

    it("default visibility should be public", function () {
        var visibility = new SurveyVisibilityViewModel();
        expect(visibility.embargoOption()).toEqual("NONE");
    });
    it("default set date should be 10", function () {
        var visibility = new SurveyVisibilityViewModel();
        expect(visibility.embargoForDays()).toEqual(10);
    });

});