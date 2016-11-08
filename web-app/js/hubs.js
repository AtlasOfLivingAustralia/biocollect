var HubSettingsViewModel = function (programsModel, options) {

    var self = this;
    self.selectedHub = ko.observable();
    self.hubs = ko.observableArray();
    self.selectedHubUrlPath = ko.observable();
    self.programsModel = programsModel;
    self.message = ko.observable();

    var programNames = $.map(programsModel.programs, function (program, i) {
        return program.name;
    });

    self.transients = {
        availableFacets: ['status', 'organisationFacet', 'associatedProgramFacet', 'associatedSubProgramFacet', 'mainThemeFacet', 'stateFacet', 'nrmFacet', 'lgaFacet', 'mvgFacet', 'ibraFacet', 'imcra4_pbFacet', 'otherFacet', 'gerSubRegionFacet', 'electFacet', 'cmzFacet', 'meriPlanAssetFacet', 'partnerOrganisationTypeFacet'],
        availableMapFacets: ['status', 'organisationFacet', 'associatedProgramFacet', 'associatedSubProgramFacet', 'stateFacet', 'nrmFacet', 'lgaFacet', 'mvgFacet', 'ibraFacet', 'imcra4_pbFacet', 'electFacet', 'cmzFacet'],
        adminFacets: ['electFacet', 'cmzFacet', 'meriPlanAssetFacet', 'partnerOrganisationTypeFacet'],
        programNames: programNames,
        availableSkins: ['nrm', 'ala2', 'mdba', 'ala', 'configurableHubTemplate1'],
        configurableTemplates: ['configurableHubTemplate1']
    };

    var config = $.extend({root: self}, options, {message: self.message});

    self.newHub = function () {
        var hub = new HubSettings({urlPath: 'newHub'}, config);

        self.selectedHub(hub);
        $(options.formSelector).validationEngine();
    };

    self.editHub = function () {
        $.get(config.getHubUrl, {id: self.selectedHubUrlPath(), format: 'json'}, function (data) {
            self.message('');
            var hub = new HubSettings(data, config);
            self.selectedHub(hub);

        }, 'json').fail(function () {
            self.message('Error loading hub details');
        });
    };

    $.get(config.listHubsUrl, function (data) {
        self.hubs(data);
        if (self.hubs().indexOf(config.currentHub) >= 0) {
            self.selectedHubUrlPath(config.currentHub);
        }
    }, 'json');

    self.selectedHubUrlPath.subscribe(function () {
        self.selectedHub(undefined);
    });
};

var HubSettings = function (settings, config) {

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
    self.defaultProgram = ko.observable();
    self.templateConfiguration = ko.observable();

    self.transients = {

        /**
         * check if skin layout can be configured
         * @param skin
         * @returns {boolean}
         */
        isSkinAConfigurableTemplate: ko.computed(function () {
            if (config.root.transients.configurableTemplates.indexOf(self.skin()) != -1) {
                return true;
            }

            return false;
        }),
        showTemplateSettings: ko.observable(false)
    };

    self.documents.subscribe(function (documents) {
        $.each(documents, function (i, document) {
            if (document.role == 'banner') {
                self.bannerUrl(document.url);
            }
            else if (document.role == 'logo') {
                self.logoUrl(document.url);
            }
        });
    });

    self.removeLogo = function () {
        self.logoUrl(null);
        var document = findDocumentByRole(self.documents(), 'logo');
        self.documents.remove(document);
    };

    self.removeBanner = function () {
        self.bannerUrl(null);
        var document = findDocumentByRole(self.documents(), 'banner');
        self.documents.remove(document);
    };


    self.removeDefaultFacetQuery = function (data) {
        self.defaultFacetQuery.remove(data);
    };
    self.addDefaultFacetQuery = function () {
        self.defaultFacetQuery.push({query: ko.observable()});
    };
    self.facetOrder = function (facet) {
        var facetList = self.availableFacets ? self.availableFacets : [];
        var index = facetList.indexOf(facet);
        return index >= 0 ? '(' + (index + 1) + ')' : '';
    };

    self.facetAdminOrder = function (facet) {
        var facetList = self.adminFacets ? self.adminFacets : [];
        var index = facetList.indexOf(facet);
        return index >= 0 ? '(' + (index + 1) + ')' : '';
    };

    self.facetMapAdminOrder = function (facet) {
        var facetList = self.availableMapFacets ? self.availableMapFacets : [];
        var index = facetList.indexOf(facet);
        return index >= 0 ? '(' + (index + 1) + ')' : '';
    };

    self.toggleTemplateSettings = function () {
        self.transients.showTemplateSettings(!self.transients.showTemplateSettings());
    }

    self.loadSettings = function (settings) {
        self.hubId(settings.hubId);
        self.urlPath(settings.urlPath);
        self.skin(settings.skin);
        self.title(settings.title);
        self.supportedPrograms(self.orEmptyArray(settings.supportedPrograms));
        self.defaultProgram(settings.defaultProgram);
        self.availableFacets(self.orEmptyArray(settings.availableFacets));
        self.adminFacets(self.orEmptyArray(settings.adminFacets));
        self.availableMapFacets(self.orEmptyArray(settings.availableMapFacets));
        self.bannerUrl(self.orBlank(settings.bannerUrl));
        self.logoUrl(self.orBlank(settings.logoUrl));
        self.homePagePath(self.orBlank(settings.homePagePath));
        self.defaultFacetQuery([]);
        self.templateConfiguration(new TemplateConfigurationViewModel(settings.templateConfiguration));
        if (settings.defaultFacetQuery && settings.defaultFacetQuery instanceof Array) {
            $.each(settings.defaultFacetQuery, function (i, obj) {
                self.defaultFacetQuery.push({query: ko.observable(obj)});
            });
        }
    };


    self.orEmptyArray = function (value) {
        if (value === undefined || value === null) {
            return [];
        }
        else if (!(value instanceof Array)) {
            value = [value];
        }
        return value;
    };
    self.orBlank = function (value) {
        if (value === undefined || value === null) {
            return '';
        }
        return value;
    };


    self.save = function () {
        if ($(config.formSelector).validationEngine('validate')) {
            var js = ko.mapping.toJS(self, {ignore: 'transients'});
            // Unwrap the default facet query which we wrapped to allow binding to values in the array
            var defaultFacetQuery = [];
            $.each(js.defaultFacetQuery, function (i, query) {
                if (query.query) {
                    defaultFacetQuery.push(query.query);
                }
            });
            js.defaultFacetQuery = defaultFacetQuery;
            var json = JSON.stringify(js);

            $.ajax(config.saveHubUrl, {
                type: 'POST',
                data: json,
                contentType: 'application/json'
            }).done(function (data) {
                if (data.errors) {
                    config.message(data.errors);
                }
                else {
                    config.message('Hub saved!');
                }

            }).fail(function () {

                self.message('An error occurred saving the settings.');
            });
        }
    };

    self.loadSettings(settings);

};

var TemplateConfigurationViewModel = function (config) {
    var self = this;

    self.styles = ko.observable(new StyleViewModel(config.styles || colorScheme));
    self.header = ko.observable(new HeaderViewModel( config.header || {}));
    self.footer = ko.observable(new FooterViewModel( config.footer || {}));
    self.homePage = ko.observable();
    self.buttonsHomePage = ko.observable(new ButtonsHomePageViewModel(config.buttonsHomePage || {}));
    self.projectFinderHomePage = ko.observable(new ProjectFinderHomePageViewModel(config.projectFinderHomePage || {}));
    self.logo = ko.observable();
    self.title = ko.observable();
};

var HeaderViewModel = function (config) {
    var self = this;
    config.links = $.map(config.links || [], function (link) {
        return new LinkViewModel(link);
    });

    self.links = ko.observableArray(config.links);
    self.logo = ko.observable();
    self.style = ko.observable(config.style);

    self.addLink = function () {
      self.links.push(new LinkViewModel({}));
    };
};

var FooterViewModel = function (config) {
    var self = this;
    config.links = $.map(config.links || [], function (link) {
        return new LinkViewModel(link);
    });

    config.socials = $.map(config.socials || [], function (social) {
        return new SocialMediaViewModel(social);
    });

    self.links = ko.observableArray(config.links);
    self.socials = ko.observableArray(config.socials);
    self.style = ko.observable(config.style);

    self.addLink = function () {
        self.links.push(new LinkViewModel({}));
    };

    self.addSocialMedia = function () {
        self.socials.push(new SocialMediaViewModel({}))
    }
};

var LinkViewModel = function (config) {
    var self = this;

    self.displayName = ko.observable(config.displayName || '');
    self.contentType = ko.observable(config.contentType || 'static');
    self.href = ko.observable(config.href || '');
};

var StyleViewModel = function (config) {
    var self = this;

    self.menuBackgroundColor = ko.observable(config.menuBackgroundColor || '');
    self.menuTextColor = ko.observable(config.menuTextColor || '');
    self.bannerBackgroundColor = ko.observable(config.bannerBackgroundColor || '');
    self.insetBackgroundColor = ko.observable(config.insetBackgroundColor || '');
    self.insetTextColor = ko.observable(config.insetTextColor || '');
    self.bodyBackgroundColor = ko.observable(config.bodyBackgroundColor || '');
    self.bodyTextColor = ko.observable(config.bodyTextColor || '');
    self.footerBackgroundColor = ko.observable(config.footerBackgroundColor || '');
    self.footerTextColor = ko.observable(config.footerTextColor || '');
    self.socialTextColor = ko.observable(config.socialTextColor || '');
};

var SocialMediaViewModel = function (config) {
    var self = this;

    self.contentType = ko.observable(config.contentType || 'youtube');
    self.href = ko.observable(config.href || '');
};

var ButtonsHomePageViewModel = function (config) {
    var self = this;

    self.buttons = ko.observableArray(config.buttons || []);
    self.numberOfColumns = ko.observable(config.numberOfColumns || 3);

    self.addButtton = function () {
        self.buttons.push(new LinkViewModel({}));
    }
};

var ProjectFinderHomePageViewModel = function (config) {
    var self = this;

    self.buttons = ko.observableArray(config.buttons || []);
    self.numberOfColumns = ko.observable(config.numberOfColumns || 3);
};

var colorScheme = {
    menuBackgroundColor: "#009080",
    menuTextColor: "#efefef",
    bannerBackgroundColor: "#323334",
    insetBackgroundColor: "",
    insetTextColor: "",
    bodyBackgroundColor: "#ffffff",
    bodyTextColor: "",
    footerBackgroundColor: "#323334",
    footerTextColor: "#efefef",
    socialTextColor: "#000"
}