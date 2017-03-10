var hubConfigs = {
    availableProjectFacets: []
};

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
        programNames: programNames,
        availableSkins: ['nrm', 'ala2', 'mdba', 'ala', 'configurableHubTemplate1'],
        configurableTemplates: ['configurableHubTemplate1'],
        defaultHomePage: '/project/citizenScience',
        hubHomePage: '/hub/index'
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
    $.get(config.listProjectFacetUrl, function (data) {
        var facets = $.map(data.facets, function (facet) {
             return new FacetViewModel(facet);
        });
        hubConfigs.availableProjectFacets = facets;
    }, 'json');

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
    self.defaultFacetQuery = ko.observableArray();
    self.homePagePath = ko.observable();
    self.bannerUrl = ko.observable();
    self.logoUrl = ko.observable();
    self.documents = ko.observableArray();
    self.defaultProgram = ko.observable();
    self.templateConfiguration = ko.observable();
    self.hideBreadCrumbs = ko.observable();
    self.quickLinks = ko.observableArray();
    self.facets = ko.observableArray();

    /**
     * Set home page only if the configurable template is chosen. Otherwise, do nothing. If user had previously chosen
     * configurable template but not anymore, then do not change homepage.
     */
    self.skin.subscribe(function (skin) {
        if(self.transients.isSkinAConfigurableTemplate()){
            if(self.skin() !== config.root.transients.hubHomePage){
                self.homePagePath(config.root.transients.hubHomePage);
            }
        }
    });

    self.documents.subscribe(function (documents) {
        $.each(documents, function (i, document) {
            if (document.role == 'banner') {
                var duplicate = self.templateConfiguration().banner().images().find(function (item) {
                    return item.url() == document.url;
                });

                if(!duplicate){
                    self.templateConfiguration().banner().images.push(new ImageViewModel({
                        url: document.url,
                        caption: ''
                    }));
                }
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
        var document = findDocumentByRole(self.documents(), 'logo');
        self.documents.remove(document);
    };

    self.removeDefaultFacetQuery = function (data) {
        self.defaultFacetQuery.remove(data);
    };
    self.addDefaultFacetQuery = function () {
        self.defaultFacetQuery.push({query: ko.observable()});
    };

    self.toggleTemplateSettings = function () {
        self.transients.showTemplateSettings(!self.transients.showTemplateSettings());
    }

    self.isParameterConfigurableTemplate = function (skin) {
        if (config.root.transients.configurableTemplates.indexOf(skin) != -1) {
            return true;
        }

        return false;
    };

    self.addLink = function () {
        self.quickLinks.push(new LinkViewModel({}));
    };

    self.transients = {

        /**
         * check if skin layout can be configured
         * @param skin
         * @returns {boolean}
         */
        isSkinAConfigurableTemplate: ko.computed(function () {
            return self.isParameterConfigurableTemplate(self.skin());
        }),
        showTemplateSettings: ko.observable(false),
        facetList: ko.observableArray(hubConfigs.availableProjectFacets.slice()),
        selectedValue: ko.observable()
    };

    self.loadSettings = function (settings) {
        self.hubId(settings.hubId);
        self.urlPath(settings.urlPath);
        self.skin(settings.skin);
        self.title(settings.title);
        self.supportedPrograms(self.orEmptyArray(settings.supportedPrograms));
        self.defaultProgram(settings.defaultProgram);
        self.bannerUrl(self.orBlank(settings.bannerUrl));
        self.logoUrl(self.orBlank(settings.logoUrl));
        self.homePagePath(self.orBlank(settings.homePagePath));
        self.defaultFacetQuery([]);
        self.hideBreadCrumbs(settings.hideBreadCrumbs);
        self.quickLinks(settings.quickLinks || []);
        self.templateConfiguration(new TemplateConfigurationViewModel(settings.templateConfiguration || {}));
        if (settings.defaultFacetQuery && settings.defaultFacetQuery instanceof Array) {
            $.each(settings.defaultFacetQuery, function (i, obj) {
                self.defaultFacetQuery.push({query: ko.observable(obj)});
            });
        }

        self.templateConfiguration().banner().transients.removeBanner.subscribe(function (banner) {
            if(banner){
                var document = (self.documents() || []).find(function (item) {
                    return item.url == banner.url()
                });

                self.documents.remove(document);
            }
        });

        var facets = $.map(settings.facets || [], function (facet) {
            var facetVMs =  $.grep(self.transients.facetList(), function (f) {
                return f.name() == facet.name
            });
            var facetVM = facetVMs[0];

            if(!facetVM){
                facetVM = new FacetViewModel(facet);
            } else {
                facetVM.state(facet.state);
                var index = self.transients.facetList.indexOf(facetVM);
                if(index >= 0){
                    self.transients.facetList.splice(index, 1);
                }
            }

            return facetVM;
        });

        self.facets(facets);
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


    self.addFacet = function () {
        var facet = self.transients.selectedValue();
        self.facets.push(facet);
        var index = self.transients.facetList.indexOf(facet);
        if(index >= 0){
            self.transients.facetList.splice(index, 1);
        }
    };

    self.removeFacet = function (facet ) {
        var facets = self.facets();
        var index = facets.indexOf(facet);
        if(index >= 0){
            facets.splice(index, 1);
            self.facets(facets);
            index = self.transients.facetList.indexOf(facet);
            if(index == -1){
                self.transients.facetList.push(facet);
                self.transients.facetList.sort(function (a,b) {
                    return a.title() < b.title()? - 1 : 1;
                })
            }
        }
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
                    if(self.documents().length){
                        config.root.editHub();
                    };
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
    self.banner = ko.observable(new BannerViewModel(config.banner || {}));
    self.homePage = ko.observable(new HomePageViewModel(config.homePage || {}));
};

var HeaderViewModel = function (config) {
    var self = this;
    config.links = $.map(config.links || [], function (link) {
        return new LinkViewModel(link);
    });

    self.links = ko.observableArray(config.links);
    self.logo = ko.observable();
    self.style = ko.observable(config.style);
    self.type = ko.observable(config.type||'');

    self.addLink = function () {
      self.links.push(new LinkViewModel({}));
    };

    self.removeLink = function (data) {
        self.links.remove(data);
    }
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
    self.type = ko.observable(config.type||'');

    self.addLink = function () {
        self.links.push(new LinkViewModel({}));
    };

    self.addSocialMedia = function () {
        self.socials.push(new SocialMediaViewModel({}))
    };

    self.removeLink = function (data) {
        self.links.remove(data);
        self.socials.remove(data);
    };
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
    self.titleTextColor = ko.observable(config.titleTextColor || '');
    self.headerBannerBackgroundColor = ko.observable(config.headerBannerBackgroundColor || '');
    self.navBackgroundColor = ko.observable(config.navBackgroundColor || '');
    self.navTextColor = ko.observable(config.navTextColor || '');
    self.primaryButtonBackgroundColor= ko.observable(config.primaryButtonBackgroundColor || '');
    self.primaryButtonTextColor= ko.observable(config.primaryButtonTextColor || '');
    self.defaultButtonBackgroundColor= ko.observable(config.defaultButtonBackgroundColor || '');
    self.defaultButtonTextColor= ko.observable(config.defaultButtonTextColor || '');
    self.hrefColor= ko.observable(config.hrefColor || '');
    self.facetBackgroundColor= ko.observable(config.facetBackgroundColor || '');
    self.tileBackgroundColor= ko.observable(config.tileBackgroundColor || '');
    self.wellBackgroundColor= ko.observable(config.wellBackgroundColor || '');
    self.defaultButtonColorActive= ko.observable(config.defaultButtonColorActive || '');
    self.defaultButtonBackgroundColorActive= ko.observable(config.defaultButtonBackgroundColorActive || '');
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

    self.removeLink = function (data) {
        self.buttons.remove(data);
    }
};

var ProjectFinderHomePageViewModel = function (config) {
    var self = this;
    self.defaultView = ko.observable(config.defaultView || 'grid');
    self.showProjectRegionSwitch = ko.observable(config.showProjectRegionSwitch || false);
};

var HomePageViewModel = function (config) {
    var self = this;

    self.homePageConfig = ko.observable(config.homePageConfig || '');
    self.projectFinderConfig = ko.observable(new ProjectFinderHomePageViewModel(config.projectFinderConfig || {}));
    self.buttonsConfig = ko.observable(new ButtonsHomePageViewModel(config.buttonsConfig || {}));
};

var BannerViewModel = function (config) {
    var self = this;
    var images = config.images || [];
    images = $.map(images, function (image) {
        return new ImageViewModel(image);
    });

    self.transitionSpeed = ko.observable(config.transitionSpeed || 3000);
    self.images = ko.observableArray(images);

    self.transients = {
        removeBanner: ko.observable()
    }

    self.removeBanner = function (banner) {
        self.images.remove(banner);
        self.transients.removeBanner(banner);
    };
};

var ImageViewModel = function (config) {
    var self = this;

    self.url = ko.observable(config.url || '')
    self.caption = ko.observable(config.caption || '')
};

var FacetViewModel = function(config){
    var self = this;

    self.title = ko.observable(config.title || '');
    self.state = ko.observable(config.state || 'Collapsed');
    self.name = ko.observable(config.name || '');

    self.displayName = ko.computed(function () {
        return self.title() + ' (' + self.name() + ')'
    });
};

var colorScheme = {
    menuBackgroundColor: "#009080",
    menuTextColor: "#efefef",
    bannerBackgroundColor: "#323334",
    insetBackgroundColor: "",
    insetTextColor: "",
    bodyBackgroundColor: "#ffffff",
    bodyTextColor: "#637073",
    footerBackgroundColor: "#323334",
    footerTextColor: "#efefef",
    socialTextColor: "#000",
    titleTextColor: "#5f5d60",
    headerBannerBackgroundColor: '#ffffff',
    navBackgroundColor: '#e5e6e7',
    navTextColor: '#5f5d60',
    primaryButtonBackgroundColor: '#009080',
    primaryButtonTextColor: '#fff',
    defaultButtonBackgroundColor: '#f5f5f5',
    defaultButtonTextColor: '#000',
    hrefColor:'#009080',
    facetBackgroundColor: '#f5f5f5',
    tileBackgroundColor: '#f5f5f5',
    wellBackgroundColor: '#f5f5f5',
    defaultButtonColorActive: '#fff',
    defaultButtonBackgroundColorActive: '#000'
};