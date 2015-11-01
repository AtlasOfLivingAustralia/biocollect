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
 * Provides the ability to search a user's organisations and other organisations at the same time.  The results
 * are maintained as separate lists for ease of display (so a users existing organisations can be prioritised).
 * @param organisations the organisations not belonging to the user.
 * @param userOrganisations the organisations that belong to the user.
 * @param (optional) if present, this value should contain the organisationId of an organisation to pre-select.
 */
OrganisationSelectionViewModel = function(organisations, userOrganisations, inititialSelection) {

    var self = this;
    var userOrgList = new SearchableList(userOrganisations, ['name']);
    var otherOrgList = new SearchableList(organisations, ['name']);

    self.term = ko.observable('');
    self.term.subscribe(function() {
        userOrgList.term(self.term());
        otherOrgList.term(self.term());
    });

    self.selection = ko.computed(function() {
        return userOrgList.selection() || otherOrgList.selection();
    });

    self.userOrganisationResults = userOrgList.results;
    self.otherResults = otherOrgList.results;

    self.clearSelection = function() {
        userOrgList.clearSelection();
        otherOrgList.clearSelection();
        self.term('');
    };

    self.isSelected = function(value) {
        return userOrgList.isSelected(value) || otherOrgList.isSelected(value);
    };

    self.select = function(value) {
        self.term(value['name']);

        userOrgList.select(value);
        otherOrgList.select(value);
    };

    self.allViewed = ko.observable(false);

    self.scrolled = function(blah, event) {
        var elem = event.target;
        var scrollPos = elem.scrollTop;
        var maxScroll = elem.scrollHeight - elem.clientHeight;

        if ((maxScroll - scrollPos) < 9) {
            self.allViewed(true);
        }
    };

    self.visibleRows = ko.computed(function() {
        var count = 0;
        if (self.userOrganisationResults().length) {
            count += self.userOrganisationResults().length+1; // +1 for the "user orgs" label.
        }
        if (self.otherResults().length) {
            count += self.otherResults().length;
            if (self.userOrganisationResults().length) {
                count ++; // +1 for the "other orgs" label (it will only show if the my organisations label is also showing.
            }
        }
        return count;
    });

    self.visibleRows.subscribe(function() {
        if (self.visibleRows() <= 4 && !self.selection()) {
            self.allViewed(true);
        }
    });
    self.visibleRows.notifySubscribers();


    self.organisationNotPresent = ko.observable();

    var findByOrganisationId = function(list, organisationId) {
        for (var i=0; i<list.length; i++) {
            if (list[i].organisationId === organisationId) {
                return list[i];
            }
        }
        return null;
    };

    if (inititialSelection) {
        var userOrg = findByOrganisationId(userOrganisations, inititialSelection);
        var orgToSelect = userOrg ? userOrg : findByOrganisationId(organisations, inititialSelection);
        if (orgToSelect) {
            self.select(orgToSelect);
        }
    }

    self.transients = {};
    self.transients.showOrganisationSearchPanel = ko.observable(true);

    self.toggleShowOrganisationSearchPanel = function() {
        self.transients.showOrganisationSearchPanel(!self.transients.showOrganisationSearchPanel());
    }
};

var OrganisationsViewModel = function(organisations, userOrgIds) {
    var self = this;

    var userOrgList = [], otherOrgList = [];
    for (var i=0; i<organisations.length; i++) {

        // Attach images to each organisations for display
        var orgView = new OrganisationViewModel(organisations[i]);
        orgView.searchableName = organisations[i].name;
        orgView.searchableDescription = organisations[i].description;

        if (userOrgIds && userOrgIds.indexOf(organisations[i].organisationId) >= 0) {
            userOrgList.push(orgView);
        }
        else {
            otherOrgList.push(orgView)
        }
    }

    var searchableUserList, searchableOtherList;

    self.searchTerm = ko.observable('');
    self.searchName = ko.observable(true);
    self.searchDescription = ko.observable(false);
    self.caseSensitive = ko.observable(false);

    var buildSearch = function() {
        var keys = [];
        if (self.searchName()) {
            keys.push('searchableName');
        }
        if (self.searchDescription()) {
            keys.push('searchableDescription');
        }

        var options = {keys:keys, caseSensitive:self.caseSensitive()};

        searchableUserList = new SearchableList(userOrgList, keys, options);
        searchableOtherList = new SearchableList(otherOrgList, keys, options);
    };

    buildSearch();

    self.delayedSearchTerm = ko.pureComputed(self.searchTerm).extend({rateLimit:{method:'notifyWhenChangesStop', timeout:400}});

    self.delayedSearchTerm.subscribe(function(term) {
        searchableUserList.term(term);
        searchableOtherList.term(term);
        self.pageNum(1);
        self.pageList(buildPageList());
    });

    this.userOrganisations = searchableUserList.results;
    this.otherOrganisations = searchableOtherList.results;

    this.pageNum = ko.observable(1);
    this.organisationsPerPage = 20;
    var maxPageButtons = 10;

    this.totalPages = ko.computed(function() {
        var count = self.userOrganisations().length + self.otherOrganisations().length;
        var pageCount = Math.floor(count / self.organisationsPerPage);
        return count % self.organisationsPerPage > 0 ? pageCount + 1 : pageCount;
    });

    this.currentPage = ko.computed(function() {
        var results = [].concat(self.userOrganisations(), self.otherOrganisations());
        var first = (self.pageNum()-1) * self.organisationsPerPage;
        return results.slice(first, first+self.organisationsPerPage);

    });

    function buildPageList() {
        var pages = [];
        var i;
        var currentPage = self.pageNum();
        var total = self.totalPages();
        if (total <= maxPageButtons) {
            for (i=1; i<=total; i++) {
                pages.push(i);
            }
            return pages;
        }

        if (currentPage <= (maxPageButtons / 2) + 1) {
            for (i=1; i<maxPageButtons; i++) {
                pages.push(i);
            }
            pages.push('..');
            pages.push(total);
            return pages;

        }

        if (currentPage > (total - (maxPageButtons / 2))) {
            pages.push(1);
            pages.push('..');
            for (i=total - maxPageButtons+2; i<=total; i++) {
                pages.push(i);
            }
            return pages;
        }

        pages.push(1);
        pages.push('..');
        var start = currentPage-(maxPageButtons/2)+1;
        for (i=start; i<start+maxPageButtons-2; i++) {
            pages.push(i);
        }
        pages.push('..');
        pages.push(total);
        return pages;
    };

    this.pageList = ko.observableArray(buildPageList());

    this.hasPrev = ko.computed(function() {
        return self.pageNum() > 1;
    });

    this.hasNext = ko.computed(function() {
        return self.pageNum() < self.totalPages();
    });

    this.next = function() {
        if (self.hasNext()) {
            self.gotoPage(self.pageNum()+1);
        }
    };
    this.prev = function() {
        if (self.hasPrev()) {
            self.gotoPage(self.pageNum()-1);
        }
    };

    this.gotoPage = function(page) {
        if (page != '..') {
            self.pageNum(page);
            self.pageList(buildPageList());
            self.pageList.notifySubscribers();
        }
    };

    this.addOrganisation = function() {
        window.location = fcConfig.createOrganisationUrl;
    };

};