
var HubSettingsViewModel = function(programsModel, options) {

    var self = this;
    self.selectedHub = ko.observable();
    self.hubs = ko.observableArray();
    self.selectedHubUrlPath = ko.observable();
    self.programsModel = programsModel;
    self.message = ko.observable();

    var programNames = $.map(programsModel.programs, function(program, i) {
        return program.name;
    });

    self.transients = {
        availableFacets:['status','organisationFacet','associatedProgramFacet','associatedSubProgramFacet','mainThemeFacet','stateFacet','nrmFacet','lgaFacet','mvgFacet','ibraFacet','imcra4_pbFacet','otherFacet', 'gerSubRegionFacet','electFacet','cmzFacet','meriPlanAssetFacet', 'partnerOrganisationTypeFacet'],
        availableMapFacets:['status', 'organisationFacet','associatedProgramFacet','associatedSubProgramFacet','stateFacet','nrmFacet','lgaFacet','mvgFacet','ibraFacet','imcra4_pbFacet','electFacet', 'cmzFacet'],
        adminFacets:['electFacet', 'cmzFacet','meriPlanAssetFacet', 'partnerOrganisationTypeFacet'],
        programNames:programNames,
        availableSkins:['nrm', 'ala2']
    };

    var config = $.extend({}, options, {message:self.message});

    self.newHub = function() {
        var hub = new HubSettings({urlPath:'newHub'}, config);

        self.selectedHub(hub);
        $(options.formSelector).validationEngine();
    };

    self.editHub = function() {
        $.get(config.getHubUrl, {id:self.selectedHubUrlPath(), format:'json'}, function(data) {
            self.message('');
            var hub = new HubSettings(data, config);
            self.selectedHub(hub);

        }, 'json').fail(function() {
            self.message('Error loading hub details');
        });
    };

    $.get(config.listHubsUrl, function(data) {
        self.hubs(data);
        if (self.hubs().indexOf(config.currentHub) >= 0) {
            self.selectedHubUrlPath(config.currentHub);
        }
    }, 'json');
};

var HubSettings = function(settings, config) {

    var self = this;

    self.hubId = ko.observable();
    self.urlPath = ko.observable();
    self.skin = ko.observable();
    self.title = ko.observable();
    self.supportedPrograms = ko.observableArray();
    self.availableFacets = ko.observableArray();
    self.adminFacets = ko.observableArray();
    self.availableMapFacets = ko.observableArray();
    self.defaultFacetQuery = ko.observableArray();
    self.homePagePath = ko.observable();
    self.bannerUrl = ko.observable();
    self.logoUrl = ko.observable();
    self.documents = ko.observableArray();

    self.documents.subscribe(function(documents) {
        $.each(documents, function(i, document) {
            if (document.role == 'banner') {
                self.bannerUrl(document.url);
            }
            else if (document.role == 'logo') {
                self.logoUrl(document.url);
            }
        });
    });

    self.removeLogo = function() {
        self.logoUrl(null);
        var document = findDocumentByRole(self.documents(), 'logo');
        self.documents.remove(document);
    };

    self.removeBanner = function() {
        self.bannerUrl(null);
        var document = findDocumentByRole(self.documents(), 'banner');
        self.documents.remove(document);
    };


    self.removeDefaultFacetQuery = function(data) {
        self.defaultFacetQuery.remove(data);
    };
    self.addDefaultFacetQuery = function() {
        self.defaultFacetQuery.push({query:ko.observable()});
    };
    self.facetOrder = function(facet) {
        var facetList = self.availableFacets ? self.availableFacets : [];
        var index = facetList.indexOf(facet);
        return index >= 0 ? '('+(index + 1)+')' : '';
    };

    self.facetAdminOrder = function(facet) {
        var facetList = self.adminFacets ? self.adminFacets : [];
        var index = facetList.indexOf(facet);
        return index >= 0 ? '('+(index + 1)+')' : '';
    };

    self.facetMapAdminOrder = function(facet) {
        var facetList = self.availableMapFacets ? self.availableMapFacets : [];
        var index = facetList.indexOf(facet);
        return index >= 0 ? '('+(index + 1)+')' : '';
    };

    self.loadSettings = function(settings) {
        self.hubId(settings.hubId);
        self.urlPath(settings.urlPath);
        self.skin(settings.skin);
        self.title(settings.title);
        self.supportedPrograms(self.orEmptyArray(settings.supportedPrograms));
        self.availableFacets(self.orEmptyArray(settings.availableFacets));
        self.adminFacets(self.orEmptyArray(settings.adminFacets));
        self.availableMapFacets(self.orEmptyArray(settings.availableMapFacets));
        self.bannerUrl(self.orBlank(settings.bannerUrl));
        self.logoUrl(self.orBlank(settings.logoUrl));
        self.homePagePath(self.orBlank(settings.homePagePath));
        self.defaultFacetQuery([]);
        if (settings.defaultFacetQuery && settings.defaultFacetQuery instanceof Array) {
            $.each(settings.defaultFacetQuery, function(i, obj) {
                self.defaultFacetQuery.push({query: ko.observable(obj)});
            });
        }
    };


    self.orEmptyArray = function(value) {
        if (value === undefined || value === null) {
            return [];
        }
        else if (!(value instanceof Array)) {
            value = [value];
        }
        return value;
    };
    self.orBlank = function(value) {
        if (value === undefined || value === null) {
            return '';
        }
        return value;
    };


    self.save = function() {
        if ($(config.formSelector).validationEngine('validate')) {
            var js = ko.mapping.toJS(self, {ignore:'transients'});
            // Unwrap the default facet query which we wrapped to allow binding to values in the array
            var defaultFacetQuery = [];
            $.each(js.defaultFacetQuery, function(i, query) {
                if (query.query) {
                    defaultFacetQuery.push(query.query);
                }
            });
            js.defaultFacetQuery = defaultFacetQuery;
            var json = JSON.stringify(js);

            $.ajax(config.saveHubUrl, {type:'POST', data:json, contentType:'application/json'}).done( function(data) {
                if (data.errors) {
                    config.message(data.errors);
                }
                else {
                    config.message('Hub saved!');
                }

            }).fail( function() {

                self.message('An error occurred saving the settings.');
            });
        }
    };

    self.loadSettings(settings);

};