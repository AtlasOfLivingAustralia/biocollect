describe("AllDocListViewModel Spec", function () {
    beforeAll(function() {
        window.fcConfig = {
            imageLocation:'/',
            useExistingModel:false,
            projectId:""
        }
    });

    describe("Shared document, photo-point and species-list licence selectors", function () {
        var originalConfig, originalOptions, originalCatalogue, originalJson, originalCatalogueJson, originalDefault;
        var fixture, select;
        var choices = [
            {name: "Attribution", acronym: "CC-BY 4.0 (Int)", url: "https://creativecommons.org/licenses/by/4.0/", imageUrl: "", version: "4.0"},
            {name: "Public domain", acronym: "CC0", url: "https://creativecommons.org/publicdomain/zero/1.0/", imageUrl: "", version: "1.0"}
        ];
        var historical = {name: "Attribution-Noncommercial (Australia)", acronym: "CC-BY-NC 3.0 (Aus)",
            url: "https://creativecommons.org/licenses/by-nc/3.0/au/", imageUrl: "", version: "3.0"};

        beforeEach(function () {
            originalConfig = window.fcConfig;
            window.fcConfig = {imageLocation: "/", bieUrl: "", speciesListsServerUrl: "", searchBieUrl: "/species/search"};
            originalOptions = ecodataLicences.options();
            originalCatalogue = ecodataLicences.catalogue();
            originalJson = ecodataLicences.json;
            originalCatalogueJson = ecodataLicences.catalogueJson;
            originalDefault = ecodataLicences.defaultLicence();
            fixture = document.createElement("div");
            fixture.setAttribute("data-ecodata-licences", JSON.stringify(choices));
            fixture.setAttribute("data-ecodata-licence-catalogue", JSON.stringify(choices.concat([historical])));
            fixture.setAttribute("data-ecodata-default-licence", choices[1].url);
            document.body.appendChild(fixture);
            select = document.createElement("select");
            select.setAttribute("data-bind", "options: transients.licence.options, optionsText: 'name', optionsValue: 'acronym', value: transients.licence.selection, valueAllowUnset: true, optionsCaption: 'Please select'");
            fixture.appendChild(select);
        });

        afterEach(function () {
            ko.cleanNode(select);
            fixture.remove();
            window.fcConfig = originalConfig;
            ecodataLicences.options(originalOptions);
            ecodataLicences.catalogue(originalCatalogue);
            ecodataLicences.json = originalJson;
            ecodataLicences.catalogueJson = originalCatalogueJson;
            ecodataLicences.defaultLicence(originalDefault);
        });

        [
            {name: "documents", create: function(data) { return new DocumentViewModel(data); }, field: "license"},
            {name: "photo-point images", create: function(data) { return Photo(data); }, field: "licence"},
            {name: "species lists", create: function(data) { return new NewSpeciesListViewModel(data); }, field: "licence"}
        ].forEach(function (type) {
            it("uses the configured default and saves the selected catalogue acronym for new " + type.name, function () {
                var model = type.create({});
                ko.applyBindings(model, select);
                expect(select.value).toBe("CC0");
                select.value = choices[0].acronym;
                $(select).trigger("change");
                var saved = model.modelForSaving ? model.modelForSaving() : ko.mapping.toJS(model, {ignore: ["transients"]});
                expect(saved[type.field]).toBe(choices[0].acronym);
                expect(saved.transients).toBeUndefined();
                if (type.field === "licence") {
                    expect(saved.license).toBeUndefined();
                }
            });

            it("retains historical and unknown values when editing " + type.name, function () {
                [historical.url, "Custom licence terms"].forEach(function (value) {
                    var data = {documentId: "saved-record"};
                    data[type.field] = value;
                    var model = type.create(data);
                    ko.applyBindings(model, select);
                    expect(model[type.field]()).toBe(value);
                    expect(select.value).toBe(value === historical.url ? historical.acronym : value);
                    expect(select.options.length).toBe(choices.length + 2);
                    expect(model.transients.licence.warning()).not.toBe("");
                    ko.cleanNode(select);
                });
            });
        });

        it("does not assign a default licence to saved documents or photo-point images without one", function () {
            [new DocumentViewModel({documentId: "saved-document"}), Photo({documentId: "saved-photo"})].forEach(function (model) {
                ko.applyBindings(model, select);
                expect(model.transients.licence.value()).toBeUndefined();
                expect(select.value).toBe("");
                ko.cleanNode(select);
            });
        });

        it("retains the uploaded licence when creating a photo-point image", function () {
            var point = PhotoPoint({siteId: "site", name: "Site"}, null, "activity", []);
            point.files.push({contentType: ko.observable("image/jpeg"), licence: ko.observable("Uploaded terms"), filesize: 1});
            expect(point.photos()[0].licence()).toBe("Uploaded terms");
            expect(point.photos()[0].modelForSaving().licence).toBe("Uploaded terms");
        });
    });

    it("should map user supplied document type to role defined in database", function () {
        var allDocListViewModel = new AllDocListViewModel("");

        expect(allDocListViewModel.mapDocumentForSearch('Journal Articles')).toEqual('journalArticles');
    });
});
