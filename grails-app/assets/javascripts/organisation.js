/**
 * Knockout view model for organisation pages.
 * @param props JSON/javascript representation of the organisation.
 * @constructor
 */
OrganisationViewModel = function (props) {
    var self = $.extend(this, new Documents());
    var orgTypesMap = {
    aquarium:'Aquarium',
    archive:'Archive',
    botanicGarden:'Botanic Garden',
    conservation:'Conservation',
    fieldStation:'Field Station',
    government:'Government',
    governmentDepartment:'Government Department',
    herbarium:'Herbarium',
    historicalSociety:'Historical Society',
    horticulturalInstitution:'Horticultural Institution',
    independentExpert:'Independent Expert',
    industry:'Industry',
    laboratory:'Laboratory',
    library:'Library',
    management:'Management',
    museum:'Museum',
    natureEducationCenter:'Nature Education Center',
    nonUniversityCollege:'Non-University College',
    park:'Park',
    repository:'Repository',
    researchInstitute:'Research Institute',
    school:'School',
    scienceCenter:'Science Center',
    society:'Society',
    university:'University',
    voluntaryObserver:'Voluntary Observer',
    zoo:'Zoo'
    };
    
    self.organisationId = props.organisationId;
    self.orgType = ko.observable(props.orgType);
    self.orgTypeDisplayOnly = ko.computed(function() {
        return orgTypesMap[self.orgType()] || "Unspecified";
    });
    self.name = ko.observable(props.name);
    self.description = ko.observable(props.description).extend({markdown:true});
    self.url = ko.observable(props.url);
    self.newsAndEvents = ko.observable(props.newsAndEvents).extend({markdown:true});;
    self.collectoryInstitutionId = props.collectoryInstitutionId;
    self.breadcrumbName = ko.computed(function() {
        return self.name()?self.name():'New Organisation';
    });

    self.projects = props.projects;

    self.deleteOrganisation = function() {
        if (window.confirm("Delete this organisation?  Are you sure?")) {
            $.post(fcConfig.organisationDeleteUrl).complete(function() {
                    window.location = fcConfig.organisationListUrl;
                }
            );
        };
    };

    self.editDescription = function() {
        editWithMarkdown('Edit organisation description', self.description);
    };

    self.editOrganisation = function() {
       window.location = fcConfig.organisationEditUrl;
    };

    self.transients = self.transients || {};
    self.transients.orgTypes = [];
    for (var ot in orgTypesMap) {
        if (orgTypesMap.hasOwnProperty(ot))
            self.transients.orgTypes.push({orgType:ot, name:orgTypesMap[ot]});
    }

    self.toJS = function(includeDocuments) {
        var ignore = self.ignore.concat(['breadcrumbName', 'orgTypeDisplayOnly', 'collectoryInstitutionId']);
        var js = ko.mapping.toJS(self, {include:['documents'], ignore:ignore} );
        if (includeDocuments) {
            js.documents = ko.toJS(self.documents);
            js.links = ko.mapping.toJS(self.links());
        }
        return js;
    };

    self.modelAsJSON = function(includeDocuments) {
        var orgJs = self.toJS(includeDocuments);
        return JSON.stringify(orgJs);
    };

    self.save = function() {
        if ($('.validationEngineContainer').validationEngine('validate')) {

            var orgData = self.modelAsJSON(true);
            $.ajax(fcConfig.organisationSaveUrl, {type:'POST', data:orgData, contentType:'application/json'}).done( function(data) {
                if (data.errors) {

                }
                else {
                    var orgId = self.organisationId?self.organisationId:data.organisationId;
                    window.location = fcConfig.organisationViewUrl+'/'+orgId;
                }

            }).fail( function() {

            });
        }
    };

    if (props.documents !== undefined && props.documents.length > 0) {
        $.each(['logo', 'banner', 'mainImage'], function(i, role){
            var document = self.findDocumentByRole(props.documents, role);
            if (document) {
                self.documents.push(document);
            }
        });
    }

    // links
    if (props.links) {
        $.each(props.links, function(i, link) {
            self.addLink(link.role, link.url);
        });
    }

    return self;

};

/**
 * Provides the ability to search and navigate through organisations.
 * @param inititialOrganisationId (optional) if present, this value should contain the organisation Id of an organisation to pre-select.
 * @param inititialOrganisationName (optional) if present, this value should contain the organisation name of an organisation to pre-select.
 */
OrganisationSelectionViewModel = function(inititialOrganisationId, initialOrganisationName) {

    var self = $.extend(this, new OrganisationsViewModel());

    self.selectedOrganisation = ko.observable({});

    self.isSelected = function(value) {
        return self.selectedOrganisation()['name'] == value['name']();
    };

    self.select = function(value) {
        self.selectedOrganisation(value);
        self.searchTerm(value['name']());
    };

    self.clearSelection = function() {
        self.selectedOrganisation({});
        self.searchTerm('');
    };

    self.selection = ko.computed(function() {
        return self.selectedOrganisation()['name'] !== undefined;
    });

    self.navigationShouldBeVisible = ko.observable(false);
    self.searchHasFocus.subscribe(function(){
        self.navigationShouldBeVisible(true);
    });

    self.displayNavigationControls = ko.computed(function() {
        return !self.selection() && self.navigationShouldBeVisible();
    });

    self.organisationNotPresent = ko.observable();

    self.allViewed = ko.observable(false);

    self.loading.subscribe(function() {
        if(!self.loading()) { // Update allViewed only after results have been refreshed
            if (self.pagination.currentPage() === self.pagination.lastPage() ||
                self.pagination.totalResults() <= self.pagination.resultsPerPage() // Only one page to display
            ) {
                self.allViewed(true);
            }
        }
    });

    if (inititialOrganisationId && initialOrganisationName) {
        self.searchTerm(initialOrganisationName);
        self.selectedOrganisation({organisationId: inititialOrganisationId, name:initialOrganisationName});
    }

};

var OrganisationsViewModel = function(eagerLoad) {
    var self = this;

    eagerLoad = (eagerLoad !== undefined) ? eagerLoad : true;

    self.pagination = new PaginationViewModel({}, self);
    self.loading = ko.observable(false);
    self.searchHasFocus = ko.observable(false);
    self.organisations = ko.observableArray([]);
    self.searchTerm = ko.observable('').extend({throttle:400});
    self.searchTerm.subscribe(function(term) {
        self.refreshPage(0);
    });

    self.refreshPage = function(offset) {
        var url = fcConfig.organisationSearchUrl;
        var params = {offset:offset, max:self.pagination.resultsPerPage()};
        if (self.searchTerm()) {
            params.searchTerm = self.searchTerm();
        }
        else {
            params.sort = "nameSort"; // Sort by name unless there is a search term, in which case we sort by relevence.
        }

        $.ajax({
            url:url,
            data:params,
            beforeSend: function () {
                self.loading(true);
            },
            success:function(data) {
                if (data.hits) {
                    var orgs = data.hits.hits || [];
                    self.organisations($.map(orgs, function(hit) {
                        if (hit._source.logoUrl) {
                            hit._source.documents = [{
                                role:'logo',
                                status:'active',
                                thumbnailUrl: hit._source.logoUrl
                            }]
                        }
                        return new OrganisationViewModel(hit._source);
                    }));
                }
                if (offset == 0) {
                    self.pagination.loadPagination(0, data.hits.total);
                }
            },
            complete: function () {
                self.loading(false);
            }
        });
    };

    self.refreshPage(0);
};