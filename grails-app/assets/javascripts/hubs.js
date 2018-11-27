var hubConfigs = {
    availableProjectFacets: [],
    availableDataFacets: [],
    availableDataColumns: []
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

    $.get(config.listDynamicFacetsUrl, function (data) {
        var facets = $.map(data.facets, function (facet) {
            return new FacetViewModel(facet);
        });
        hubConfigs.availableDataFacets = facets;
    }, 'json');

    $.get(config.listDataColumnsUrl, function (data) {
        hubConfigs.availableDataColumns = data.columns;
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

/**
 * Wraps an array of links in LinkViewModels
 * @param links the links to wrap.
 */
function mapLinks(links) {
    return $.map(links || [], function(link) {
        return new LinkViewModel(link);
    });
}

var HubSettings = function (settings, config) {

    var self = this;
    settings.pages = settings.pages || {};

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
    self.content = ko.observable();
    self.quickLinks = ko.observableArray();
    self.customBreadCrumbs = ko.observableArray();
    self.pages = {
        allRecords : new FacetConfigurationViewModel(settings.pages.allRecords, hubConfigs.availableDataFacets),
        myRecords : new FacetConfigurationViewModel(settings.pages.myRecords, hubConfigs.availableDataFacets),
        project : new FacetConfigurationViewModel(settings.pages.project, hubConfigs.availableDataFacets),
        projectRecords : new FacetConfigurationViewModel(settings.pages.projectRecords, hubConfigs.availableDataFacets),
        userProjectActivityRecords : new FacetConfigurationViewModel(settings.pages.userProjectActivityRecords, hubConfigs.availableDataFacets),
        myProjectRecords : new FacetConfigurationViewModel(settings.pages.myProjectRecords, hubConfigs.availableDataFacets),
        projectFinder: new FacetConfigurationViewModel(settings.pages.projectFinder, hubConfigs.availableProjectFacets)
    };
    self.dataColumns = ko.observableArray();
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

    self.removeLink = function (data) {
        self.quickLinks.remove(data);
    };

    self.addCustomBreadCrumb = function () {
        self.customBreadCrumbs.push(new CustomBreadCrumbsViewModel({}));
    };

    self.removeCustomBreadCrumb = function (data) {
        self.customBreadCrumbs.remove(data);
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
        dataFacetList: ko.observableArray(hubConfigs.availableDataFacets.slice()),
        selectedValue: ko.observable(),
        selectedDataFacet: ko.observable(),
        selectedDataColumn: ko.observable(),
        defaultDataColumns: ko.observableArray(),
        sortColumn: ko.observable()
    };

    self.transients.sortColumn.subscribe(self.setSortColumn, self);

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
        self.content(new ContentViewModel(settings.content || {}));
        self.quickLinks(mapLinks(settings.quickLinks));
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
        settings.customBreadCrumbs = settings.customBreadCrumbs || [];
        settings.customBreadCrumbs.forEach(function (breadcrumb) {
            self.customBreadCrumbs.push(new CustomBreadCrumbsViewModel(breadcrumb));
        });
        self.loadDefaultDataColumns(hubConfigs.availableDataColumns);
        self.loadDataColumns(settings.dataColumns || []);
        self.loadSortColumn();
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
        self.addAndRemoveFromArrays(facet, self.facets, self.transients.facetList);
    };

    self.addDataFacet = function () {
        var facet = self.transients.selectedDataFacet();
        self.addAndRemoveFromArrays(facet, self.dataFacets, self.transients.dataFacetList);
    };

    self.removeFacet = function (facet) {
        self.removeFacetFromSelectionAndAddToList(facet, self.facets, self.transients.facetList);
    };

    self.removeDataFacet = function (facet) {
        self.removeFacetFromSelectionAndAddToList(facet, self.dataFacets, self.transients.dataFacetList);
    };

    self.removeFacetFromSelectionAndAddToList = function (facet, remove, add) {
        var modified = self.removeAndAddToArrays(facet, remove, add);
        if (modified) {
            add.sort(function (a,b) {
                return a.title() < b.title()? - 1 : 1;
            });
        }
    };

    self.removeDataColumn = function (column) {
        var modified = self.removeAndAddToArrays(column, self.dataColumns, self.transients.defaultDataColumns);
        if (modified) {
            self.sortUnselectedColumns();
        }
    };

    self.addDataColumn = function () {
        var columnModel = self.transients.selectedDataColumn();
        self.addAndRemoveFromArrays(columnModel, self.dataColumns, self.transients.defaultDataColumns);
    };

    self.save = function () {
        if ($(config.formSelector).validationEngine('validate')) {
            var js = ko.mapping.toJS(self, {ignore: ['transients', 'disableRoles']});
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

HubSettings.prototype.sortUnselectedColumns = function () {
    this.transients.defaultDataColumns.sort(function (a,b) {
        return a.name().toLowerCase() < b.name().toLowerCase() ? - 1 : 1;
    });
};

HubSettings.prototype.loadDefaultDataColumns = function (columns) {
    var self = this;
    columns.forEach(function (column) {
        self.transients.defaultDataColumns.push(new ColumnViewModel(column));
    });
};

HubSettings.prototype.loadDataColumns = function (columns) {
    var self = this;
    columns.forEach(function (column) {
        var columnModels = $.grep(self.transients.defaultDataColumns(), function (defaultColumn) {
                if(column.type === 'property') {
                    return (column.type === defaultColumn.type) && (column.propertyName === defaultColumn.propertyName);
                } else {
                    return (column.type === defaultColumn.type);
                }
            }),
            columnModel = columnModels[0];

        if (!columnModel) {
            columnModel = new ColumnViewModel(column);
        } else {
            columnModel.load(column);
        }

        self.addAndRemoveFromArrays(columnModel, self.dataColumns, self.transients.defaultDataColumns);
    });

    self.sortUnselectedColumns();
};

HubSettings.prototype.removeAndAddToArrays =  function (item, remove, add) {
    var index = remove.indexOf(item),
        addArrayModified = false;
    if (index >= 0) {
        remove.splice(index, 1);
        index = add.indexOf(item);
        if (index == -1) {
            add.push(item);
            addArrayModified = true;
        }
    }

    return addArrayModified;
};

/**
 * Add value to array and remove that value from another array.
 * @param facet - value to add
 * @param add
 * @param remove
 */
HubSettings.prototype.addAndRemoveFromArrays = function (facet, add, remove) {
    add.push(facet);
    var index = remove.indexOf(facet);
    if (index >= 0) {
        remove.splice(index, 1);
    }
};

/**
 * Get current sort column and update model. Model is bound to UI radio button.
 */
HubSettings.prototype.loadSortColumn = function () {
    var self = this,
        columns = self.dataColumns() || [];
    columns.forEach(function (column) {
        if(column.sort()){
            self.transients.sortColumn(column.code());
        }
    });
};

/**
 * Update the sort flag on all columns based on the passed value.
 * @param selectedColumn - ColumnViewModel.code
 */
HubSettings.prototype.setSortColumn = function (selectedColumn) {
    var self = this,
        columns = self.dataColumns();

    columns.forEach(function (column) {
         if (column.code() === selectedColumn) {
            column.sort(true);
        } else {
            column.sort(false);
        }
    });
};

var TemplateConfigurationViewModel = function (config) {
    var self = this;

    self.styles = ko.observable(new StyleViewModel(config.styles || colorScheme));
    self.header = ko.observable(new HeaderViewModel( config.header || {}));
    self.footer = ko.observable(new FooterViewModel( config.footer || {}));
    self.banner = ko.observable(new BannerViewModel(config.banner || {}));
    self.homePage = ko.observable(new HomePageViewModel(config.homePage || {}));
};

function ContentViewModel(config) {
    var self = this;
    self.hideBreadCrumbs = ko.observable(config.hideBreadCrumbs || false);
    self.hideProjectAndSurvey = ko.observable(config.hideProjectAndSurvey || false);
    self.hideCancelButtonOnForm = ko.observable(config.hideCancelButtonOnForm || false);
    self.isContainer = ko.observable(config.isContainer || false);
    self.showNote = ko.observable(config.showNote || false);
    self.recordNote = ko.observable(config.recordNote || '');
    self.industries = ko.observable(config.industries || false);
}

var HeaderViewModel = function (config) {
    var self = this;
    config.links = mapLinks(config.links);
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
    config.links = mapLinks(config.links);

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
    self.role = ko.observable(config.role || '');
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
    self.breadCrumbBackGroundColour = ko.observable(config.breadCrumbBackGroundColour || '');
};

var SocialMediaViewModel = function (config) {
    var self = this;

    self.contentType = ko.observable(config.contentType || 'youtube');
    self.href = ko.observable(config.href || '');
};

var ButtonsHomePageViewModel = function (config) {
    var self = this;

    self.buttons = ko.observableArray(mapLinks(config.buttons));
    self.numberOfColumns = ko.observable(config.numberOfColumns || 3);

    self.addButton = function () {
        self.buttons.push(new LinkViewModel({}));
    };

    self.removeLink = function (data) {
        self.buttons.remove(data);
    };
};

var ProjectFinderHomePageViewModel = function (config) {
    var self = this;
    self.defaultView = ko.observable(config.defaultView || 'grid');
    self.showProjectRegionSwitch = ko.observable(config.showProjectRegionSwitch || false);
    self.showProjectDownloadButton = ko.observable(config.showProjectDownloadButton || false);
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

function ImageViewModel (config) {
    var self = this;

    self.url = ko.observable(config.url || '')
    self.caption = ko.observable(config.caption || '')
};

function FacetConfigurationViewModel(config, availableFacets) {
    var self = this;
    config = config || {};
    self.facets = ko.observableArray();
    self.transients = {
        facetList : ko.observableArray(availableFacets.slice()),
        selectedFacet: ko.observable()
    };

    self.add = function () {
        var facet = self.transients.selectedFacet();
        self.addAndRemoveFromArrays(facet, self.facets, self.transients.facetList);
    };

    self.addAndRemoveFromArrays = function (facet, add, remove) {
        add.push(facet);
        var index = remove.indexOf(facet);
        if (index >= 0) {
            remove.splice(index, 1);
        }
    };

    self.remove = function (facet) {
        self.removeFacetFromSelectionAndAddToList(facet, self.facets, self.transients.facetList);
    };

    self.removeFacetFromSelectionAndAddToList = function (facet, remove, add) {
        var index = remove.indexOf(facet);
        if(index >= 0){
            remove.splice(index, 1);
            index = add.indexOf(facet);
            if(index == -1){
                add.push(facet);
                add.sort(function (a,b) {
                    return a.title() < b.title()? - 1 : 1;
                })
            }
        }
    };

    var facets = $.map(config.facets|| [], function (facet) {
        var facetVMs =  $.grep(self.transients.facetList(), function (f) {
            return f.name() == facet.name
        });
        var facetVM = facetVMs[0];

        if(!facetVM){
            facetVM = new FacetViewModel(facet);
        } else {
            facetVM.state(facet.state);
            facetVM.title(facet.title);
            facetVM.facetTermType(facet.facetTermType || facetVM.facetTermType());
            facetVM.helpText(facet.helpText || facetVM.helpText());
            facetVM.interval(facet.interval || facetVM.interval());

            var index = self.transients.facetList.indexOf(facetVM);
            if(index >= 0){
                self.transients.facetList.splice(index, 1);
            }
        }

        return facetVM;
    });

    self.facets(facets);
}

function FacetViewModel(config){
    var self = this;

    self.title = ko.observable(config.title || '');
    self.state = ko.observable(config.state || 'Collapsed');
    self.name = ko.observable(config.name || '');
    self.helpText = ko.observable(config.helpText||'');
    self.facetTermType = ko.observable(config.facetTermType||'Default');
    self.interval = ko.observable(config.interval || 10);

    self.formattedName = ko.computed(function () {
        return self.title() + ' (' + self.name() + ')'
    });

    self.isNotHistogram = ko.computed(function () {
        return self.facetTermType() != 'Histogram';
    });
};

function CustomBreadCrumbsViewModel(config) {
    var self = this;
    self.controllerName = ko.observable(config.controllerName || '');
    self.actionName = ko.observable(config.actionName || '');
    self.breadCrumbs = ko.observableArray(mapLinks(config.breadCrumbs));

    self.addBreadCrumb = function () {
        self.breadCrumbs.push(new LinkViewModel({}));
    };

    self.removeLink = function (data) {
        self.breadCrumbs.remove(data);
    };
};

function ColumnViewModel(data) {
    var self = this;
    self.type = data.type;
    self.displayName = ko.observable(data.displayName);
    self.propertyName = data.propertyName;
    self.dataType = data.dataType || '';
    self.sort = ko.observable(data.sort || false);
    self.order = ko.observable(data.order || 'asc');
    self.code = ko.pureComputed(function () {
        if (self.type === 'property') {
            return self.propertyName;
        } else {
            return self.type;
        }
    });

    self.name = ko.pureComputed(function () {
        var displayName = self.displayName(),
            name ;
        if (self.type === 'property') {
            name = self.propertyName;
        } else {
            name = self.type;
        }

        if (displayName) {
            return displayName + ' ( ' + name + ' )';
        }

        return name;
    });

    self.isSortable = ko.pureComputed(function () {
        var exceptions, index, inclusions;
        if (self.dataType) {
            // If column is a dynamic facet, then not all dataType is sortable e.g. stringList.
            // ES throws exception if sorted on those fields.
            // Below is the list of dataTypes that are sortable.
            inclusions = ['text', 'number', 'boolean', 'date'];
            index = inclusions.indexOf(self.dataType);
            return index >= 0;
        } else {
            // The below type cannot be sorted.
            exceptions = ['image', 'details', 'checkbox', 'action', 'symbols'];
            index = exceptions.indexOf(self.code());
            return !(index >= 0);
        }
    });
};

ColumnViewModel.prototype.load = function (data) {
    this.displayName(data.displayName || this.displayName());
    this.sort(data.sort || this.sort());
    this.order(data.order || this.order());
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
    defaultButtonBackgroundColorActive: '#000',
    breadCrumbBackGroundColour: '#E7E7E7'
};