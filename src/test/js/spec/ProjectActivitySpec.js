describe("ProjectActivityViewModel Spec", function () {
    beforeAll(function() {
        window.fcConfig = {
            serverUrl: "http://devt.ala.org.au:8087/biocollect",
            activityUpdateUrl: "/biocollect/sightings/activity/ajaxUpdate",
            activityDeleteUrl: "/biocollect/sightings/activity/ajaxDelete",
            projectViewUrl: "/biocollect/sightings/project/index/",
            siteViewUrl: "/biocollect/sightings/site/index/",
            bieUrl: "https://bie.ala.org.au",
            bieWsUrl: "https://bie-ws.ala.org.au",
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
            searchBieUrl: "/biocollect/search/searchSpecies?projectActivityId=e61eb018-02a9-4e3b-a4b3-9d6be33d9cbb&limit=10&hub=sightings",
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

    it("species asJS('form') should return a map with form name, species and speciesFields", function () {

        var params = {
            pActivity: {
                pActivityFormName: "speciesForm1",
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
        expect(speciesVM.asJS("form")).toEqual(params.pActivity);
    });

    it("surveySiteOption change should clear selected sites and draw options", function () {
        var params = {
            sites: [{
                siteId: 'ghh',
                name: 'Test',
                extent: {
                    geometry: {
                        ibra: ""
                    }
                }
            }],
            pActivity: {
                sites : [
                    'ghh'
                ],
                allowPoints: true,
                allowPolygons: true,
                surveySiteOption: ''
            }
        };

        var pActivity = new ProjectActivity(params);
        expect(pActivity.getNumberOfSitesForSurvey()).toEqual(1);

        pActivity.surveySiteOption('sitepickcreate');
        expect(pActivity.getNumberOfSitesForSurvey()).toEqual(1);
        expect(pActivity.allowPoints()).toEqual(true);
        expect(pActivity.allowPolygons()).toEqual(true);

        pActivity.surveySiteOption('sitepick');
        expect(pActivity.getNumberOfSitesForSurvey()).toEqual(1);
        expect(pActivity.allowPoints()).toEqual(false);
        expect(pActivity.allowPolygons()).toEqual(false);

        pActivity.surveySiteOption('sitecreate');
        expect(pActivity.getNumberOfSitesForSurvey()).toEqual(0);
        expect(pActivity.allowPoints()).toEqual(false);
        expect(pActivity.allowPolygons()).toEqual(false);
    })

    it("isSiteConfigValid should check if site configuration is valid", function () {
        var params = {
            sites: [{
                siteId: 'ghh',
                name: 'Test',
                extent: {
                    geometry: {
                        ibra: ""
                    }
                }
            }],
            pActivity: {
                sites : [
                    'ghh'
                ],
                allowPoints: false,
                allowPolygons: false,
                surveySiteOption: 'sitecreate'
            }
        };

        var site = new SiteList({
            siteId: 'ghh',
            name: 'Test',
            extent: {
                geometry: {
                    ibra: ""
                }
            }
        });
        site.added(true);

        var pActivity = new ProjectActivity(params);
        expect(pActivity.isSiteConfigValid()).toEqual(false);

        pActivity.allowPoints(true);
        expect(pActivity.isSiteConfigValid()).toEqual(true);

        pActivity.surveySiteOption('sitepick');
        pActivity.sites([]);
        expect(pActivity.isSiteConfigValid()).toEqual(false);

        pActivity.sites([site]);
        expect(pActivity.isSiteConfigValid()).toEqual(true);


        pActivity.surveySiteOption('sitepickcreate');
        pActivity.sites([]);
        pActivity.allowPoints(false);
        expect(pActivity.isSiteConfigValid()).toEqual(false);

        pActivity.sites([site]);
        pActivity.allowPoints(true);
        expect(pActivity.isSiteConfigValid()).toEqual(true);
    })

    describe("data sharing licences", function () {
        var originalOptions, originalCatalogue, originalDefault, choices, select;

        beforeEach(function () {
            originalOptions = ecodataLicences.options();
            originalCatalogue = ecodataLicences.catalogue();
            originalDefault = ecodataLicences.defaultLicence();
            choices = [
                {acronym: "CC-BY 4.0 (Int)", name: "Attribution", url: "https://creativecommons.org/licenses/by/4.0/", imageUrl: "", version: "4.0"},
                {acronym: "CC-BY-NC 3.0 (Aus)", name: "Attribution-Noncommercial (Australia)", url: "https://creativecommons.org/licenses/by-nc/3.0/au/", imageUrl: "", version: "3.0"}
            ];
            ecodataLicences.options(choices);
            ecodataLicences.catalogue(choices);
            ecodataLicences.defaultLicence(choices[0].url);
            select = document.createElement("select");
            select.setAttribute("data-bind", "options: transients.licence.options, optionsText: 'acronym', optionsValue: 'url', value: transients.licence.selection, valueAllowUnset: true, optionsCaption: '-Please select the licence-'");
            document.body.appendChild(select);
        });

        afterEach(function () {
            ko.cleanNode(select);
            select.remove();
            ecodataLicences.options(originalOptions);
            ecodataLicences.catalogue(originalCatalogue);
            ecodataLicences.defaultLicence(originalDefault);
        });

        it("selects API licences by URL and excludes UI fields from saves", function () {
            var activity = new ProjectActivity({pActivity: {dataSharingLicense: choices[0].url}});
            ko.applyBindings(activity, select);

            expect(select.value).toBe(choices[0].url);
            expect(Array.from(select.options).map(function (option) { return option.text; }))
                .toEqual(["-Please select the licence-", "CC-BY 4.0 (Int)", "CC-BY-NC 3.0 (Aus)"]);
            expect(activity.transients.licence.description()).toBe("Attribution (CC-BY 4.0 (Int))");

            select.value = choices[1].url;
            select.dispatchEvent(new Event("change"));
            expect(activity.dataSharingLicense()).toBe(choices[1].url);
            expect(activity.transients.licence.url()).toBe(choices[1].url);
            var saved = activity.asJS("info");
            expect(saved.dataSharingLicense).toBe(choices[1].url);
            expect(saved.transients).toBeUndefined();
        });

        it("preserves an unlisted historic URL until another licence is selected", function () {
            var legacy = "https://creativecommons.org/licenses/by-nc/2.5/";
            var activity = new ProjectActivity({pActivity: {dataSharingLicense: legacy}});
            ko.applyBindings(activity, select);

            expect(select.value).toBe(legacy);
            expect(activity.dataSharingLicense()).toBe(legacy);
            expect(activity.transients.licence.url()).toBe(legacy);
            expect(activity.transients.licence.warning()).toContain("Unrecognised");
            expect(activity.asJS("info").dataSharingLicense).toBe(legacy);

            select.value = choices[0].url;
            select.dispatchEvent(new Event("change"));
            expect(activity.dataSharingLicense()).toBe(choices[0].url);
            expect(activity.transients.licence.options().length).toBe(choices.length);
        });

        it("keeps aliases unchanged and does not link unsafe unlisted values", function () {
            var activity = new ProjectActivity({pActivity: {dataSharingLicense: "CC BY"}});
            ko.applyBindings(activity, select);
            expect(select.value).toBe(choices[0].url);
            expect(activity.dataSharingLicense()).toBe("CC BY");
            expect(activity.transients.licence.url()).toBe(choices[0].url);
            expect(select.options.length).toBe(choices.length + 1);

            activity.dataSharingLicense(choices[0].acronym);
            expect(select.value).toBe(choices[0].url);
            expect(select.options.length).toBe(choices.length + 1);

            activity.dataSharingLicense("javascript:alert(1)");
            expect(select.value).toBe("javascript:alert(1)");
            expect(activity.transients.licence.url()).toBe("");
        });

        it("formats a historical survey licence without changing the saved value", function () {
            ecodataLicences.options([choices[0]]);
            var value = choices[1].url;
            var activity = new ProjectActivity({pActivity: {dataSharingLicense: value}});
            ko.applyBindings(activity, select);
            expect(select.value).toBe(value);
            expect(select.selectedOptions[0].text).toBe("CC-BY-NC 3.0 (Aus)");
            expect(activity.transients.licence.description()).toContain("3.0 (Aus)");
            expect(activity.transients.licence.warning()).toContain("not in the allowlist");
            expect(activity.asJS("info").dataSharingLicense).toBe(value);
            select.value = choices[0].url;
            select.dispatchEvent(new Event("change"));
            expect(activity.dataSharingLicense()).toBe(choices[0].url);
            expect(select.options.length).toBe(2);
        });

        it("uses the configured default only for new surveys", function () {
            var activity = new ProjectActivity();
            ko.applyBindings(activity, select);
            expect(select.value).toBe(choices[0].url);
            expect(activity.dataSharingLicense()).toBe(choices[0].url);
            var savedActivity = new ProjectActivity({pActivity: {projectActivityId: "saved"}});
            expect(savedActivity.dataSharingLicense()).toBe("");
        });

        it("preserves an unrecognised configured default in a new survey", function () {
            var value = "https://example.org/unrecognised-licence";
            ecodataLicences.defaultLicence(value);
            var activity = new ProjectActivity();
            ko.applyBindings(activity, select);
            expect(select.value).toBe(value);
            expect(select.selectedOptions[0].text).toBe(value);
            expect(activity.transients.licence.warning()).toContain("Unrecognised");
            expect(activity.asJS("info").dataSharingLicense).toBe(value);
        });

        it("retains a recognised configured default outside the allowlist", function () {
            ecodataLicences.options([choices[0]]);
            ecodataLicences.defaultLicence(choices[1].url);
            var activity = new ProjectActivity();
            ko.applyBindings(activity, select);
            expect(select.selectedOptions[0].text).toBe(choices[1].acronym);
            expect(activity.transients.licence.warning()).toContain("not in the allowlist");
            expect(activity.asJS("info").dataSharingLicense).toBe(choices[1].url);
        });
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
            searchBieUrl: "/biocollect/search/searchSpecies?projectActivityId=e61eb018-02a9-4e3b-a4b3-9d6be33d9cbb&limit=10&hub=sightings",
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
            searchBieUrl: "/biocollect/search/searchSpecies?projectActivityId=e61eb018-02a9-4e3b-a4b3-9d6be33d9cbb&limit=10&hub=sightings",
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
            searchBieUrl: "/biocollect/search/searchSpecies?projectActivityId=e61eb018-02a9-4e3b-a4b3-9d6be33d9cbb&limit=10&hub=sightings",
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
            searchBieUrl: "/biocollect/search/searchSpecies?projectActivityId=e61eb018-02a9-4e3b-a4b3-9d6be33d9cbb&limit=10&hub=sightings",
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