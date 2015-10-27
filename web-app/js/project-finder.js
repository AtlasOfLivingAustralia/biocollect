/**
 * Created by Temi Varghese on 22/10/15.
 */
function ProjectFinder() {
    var self = this;
    /* holds all projects */
    var allProjects = [];

    /* holds current filtered list */
    var projects;

    /* pagination offset into the record set */
    var offset = 0;

    /* size of current filtered list */
    var total = 0;

    var searchTerm = '', perPage = 20, sortBy = 'nameSort', sortOrder = 1;

    // flag to check if program/sub program sort fields are added to drop down list
    this.programAdded = false;

    this.availableProjectTypes = new ProjectViewModel({}, false, []).transients.availableProjectTypes;

    this.sortKeys = [
        {name: 'Name', value: 'nameSort'},
        {name: 'Relevance', value: '_score'},
        {name: 'Organisation Name', value: 'organisationSort'},
        {name: 'Status', value: 'status'}
    ]

    /* window into current page */
    function pageVM() {
        this.pageProjects = ko.observableArray();
        this.availableProjectTypes = ko.observableArray(self.availableProjectTypes);
        this.projectTypes = ko.observable(['citizenScience','works','survey']);
        this.sortKeys = ko.observableArray(self.sortKeys);
        this.hideshow = function () {
            $("#pt-selectors").toggle();
        }
        this.download = function (obj, e) {
            var params = $.param(self.getParams(), true);
            var href = $(e.target).attr('href');
            var domain = href.slice(0, href.indexOf('?'))
            $(e.target).attr('href', domain + '?' + 'download=true&' + params)
            return true;
        }
    }

    var pageWindow = new pageVM();
    ko.applyBindings(pageWindow, document.getElementById('pt-table'));

    this.getParams = function () {
        var fq = [];
        var isSuitableForChildren = $('#pt-search-children').prop('checked');
        var isDIY = $('#pt-search-diy').prop('checked')
        var status = $('#pt-search-active').prop('checked') // active check field status
        var hasParticipantCost = $('#pt-search-noCost').prop('checked') // no cost
        var hasTeachingMaterials = $('#pt-search-teach').prop('checked') // teaching material
        var isMobile = $('#pt-search-mobile').prop('checked') // mobile uses links to find it out
        var difficulty = $('#pt-search-difficulty').val()
        var sortOrderCode = sortOrder > 0 ? 'ASC' : 'DESC';
        var isCitizenScience = fcConfig.isCitizenScience,
            isWorks = false,
            isSurvey = false;
        var isUserPage = fcConfig.isUserPage || false;
        var organisationName = fcConfig.organisationName;

        if (fcConfig.isOrganisationPage) {
            var values = pageWindow.projectTypes();
            for (var i in values) {
                switch (values[i]) {
                    case 'citizenScience':
                        isCitizenScience = true;
                        break;
                    case "survey":
                        isSurvey = true;
                        break;
                    case 'works':
                        isWorks = true;
                        break;
                }
            }
        }

        var params = {
            fq: fq,
            offset: offset,
            status: status,
            isCitizenScience: isCitizenScience,
            isWorks: isWorks,
            isSurvey: isSurvey,
            isUserPage: isUserPage,

            hasParticipantCost: hasParticipantCost,
            isSuitableForChildren: isSuitableForChildren,
            isDIY: isDIY,
            hasTeachingMaterials: hasTeachingMaterials,
            isMobile: isMobile,
            difficulty: difficulty,
            organisationName: organisationName,

            max: perPage, // page size
            sort: sortBy,
            order: sortOrderCode, // sort order
            q: $('#pt-search').val().toLowerCase()
        }

        return params;
    }

    /**
     * this is the function calling server with the latest query.
     */
    this.doSearch = function () {
        var params = self.getParams();
        $.ajax({
            url: fcConfig.projectListUrl,
            data: params,
            traditional: true,
            success: function (data) {
                var projectVMs = [];
                var organisation = fcConfig.organisation || []
                total = data.total;
                $.each(data.projects, function (i, project) {
                    projectVMs.push(new ProjectViewModel(project, false, organisation));
                });
                self.pago.init(projectVMs);
            },
            error: function () {
                console.error("Could not load project data.")
                console.log(arguments)
            }
        })
    }

    this.searchAndShowFirstPage = function () {
        self.pago.firstPage();
    }

    /*************************************************\
     *  Show filtered projects on current page
     \*************************************************/
    this.populateTable = function () {
        pageWindow.pageProjects(projects);
        pageWindow.pageProjects.valueHasMutated();
        self.showPaginator();
    }

    /** display the current size of the filtered list **/
    this.updateTotal = function () {
        $('#pt-resultsReturned').html("Found <strong>" + total + "</strong> " + (total == 1 ? 'project.' : 'projects.'));
    }

    /*************************************************\
     *  Pagination
     \*************************************************/
    /** build and append the pagination widget **/
    this.showPaginator = function () {
        if (total <= perPage) {
            // no pagination required
            $('div#pt-navLinks').html("");
            return;
        }
        var currentPage = Math.floor(offset / perPage) + 1;
        var maxPage = Math.ceil(total / perPage);
        var $ul = $("<ul></ul>");
        // add prev
        if (offset > 0)
            $ul.append('<li><a href="javascript:pago.prevPage();">&lt;</a></li>');
        for (var i = currentPage - 3, n = 0; i <= maxPage && n < 7; i++) {
            if (i < 1) continue;
            n++;
            if (i == currentPage)
                $ul.append('<li><a href="#" class="currentStep">' + i + '</a></li>');
            else
                $ul.append('<li><a href="javascript:pago.gotoPage(' + i + ');">' + i + '</a></li>');
        }
        // add next
        if ((offset + perPage) < total)
            $ul.append('<li><a href="javascript:pago.nextPage();">&gt;</a></li>');

        var $pago = $("<div class='pagination'></div>");
        $pago.append($ul);
        $('div#pt-navLinks').html($pago);
    }

    this.augmentVM = function (vm) {
        var x, urls = [];
        if (vm.urlWeb()) urls.push('<a href="' + vm.urlWeb() + '">Website</a>');
        for (x = "", docs = vm.transients.mobileApps(), i = 0; i < docs.length; i++)
            x += '&nbsp;<a href="' + docs[i].link.url + '"><img class="logo-small" src="' + docs[i].logo(fcConfig.logoLocation) + '"/></a>';
        if (x) urls.push("Mobile Apps&nbsp;" + x);
        for (x = "", docs = vm.transients.socialMedia(), i = 0; i < docs.length; i++)
            x += '&nbsp;<a href="' + docs[i].link.url + '"><img class="logo-small" src="' + docs[i].logo(fcConfig.logoLocation) + '"/></a>';
        if (x) urls.push("Social Media&nbsp;" + x);
        vm.transients.links = urls.join('&nbsp;&nbsp;|&nbsp;&nbsp;') || '';
        vm.transients.searchText = (vm.name() + ' ' + vm.aim() + ' ' + vm.description() + ' ' + vm.keywords() + ' ' + vm.transients.scienceTypeDisplay() + ' ' + vm.transients.locality + ' ' + vm.transients.state + ' ' + vm.organisationName()).toLowerCase();
        vm.transients.indexUrl = fcConfig.projectIndexBaseUrl + vm.transients.projectId;
        vm.transients.orgUrl = vm.organisationId() && (fcConfig.organisationBaseUrl + vm.organisationId());
        vm.transients.imageUrl = fcConfig.meritProjectLogo && vm.isMERIT() ? fcConfig.meritProjectLogo : vm.imageUrl();
        if (!vm.transients.imageUrl) {
            x = vm.primaryImages();
            if (x && x.length > 0) vm.transients.imageUrl = x[0].url;
        }
        return vm;
    }

    /* comparator for data projects */
    function comparator(a, b) {
        var va = a[sortBy](), vb = b[sortBy]();
        va = va ? va.toLowerCase() : '';
        vb = vb ? vb.toLowerCase() : '';
        if (va == vb && sortBy != 'name') { // sort on name
            va = a.name().toLowerCase();
            vb = b.name().toLowerCase();
        }
        return (va < vb ? -1 : (va > vb ? 1 : 0)) * sortOrder;
    }

    this.setTextSearchSettings = function(){
        sortBy = '_score'
        $('#pt-sort').val('_score');
        sortOrder = -1
        $('#pt-dir').val(sortOrder);
    }

    $('#pt-per-page').change(function () {
        perPage = $(this).val();
        offset = 0;
        self.doSearch();
    });
    $('#pt-sort').change(function () {
        sortBy = $(this).val();
        self.doSearch();
    });
    $('#pt-dir').change(function () {
        sortOrder = $(this).val();
        self.doSearch();
    });
    $('#pt-search-link').click(function () {
        self.setTextSearchSettings();
        self.doSearch();
    });
    $('#pt-search').keypress(function (event) {
        if (event.which == 13) {
            event.preventDefault();
            self.setTextSearchSettings();
            self.doSearch();
        }
    });
    $('#pt-reset').click(function () {
        $('#pt-search').val('');
        self.pago.firstPage();
    });
    $('#pt-search-active').on('change', self.searchAndShowFirstPage);
    $('#pt-search-children').on('change', self.searchAndShowFirstPage);
    $('#pt-search-difficulty').change(self.searchAndShowFirstPage);
    $('#pt-search-projecttype').change(self.searchAndShowFirstPage);
    $('#pt-search-diy').on('change', self.searchAndShowFirstPage);
    $('#pt-search-noCost').on('change', self.searchAndShowFirstPage);
    $('#pt-search-teach').on('change', self.searchAndShowFirstPage);
    $('#pt-search-mobile').on('change', self.searchAndShowFirstPage);

    if (!fcConfig.isOrganisationPage) {
        $('#pt-selectors').show();
    }

    pago = this.pago = {
        init: function (projs) {
            var hasPrograms = false;
            projects = allProjects = [];
            $.each(projs, function (i, project) {
                allProjects.push(self.augmentVM(project));
                if (project.associatedProgram()) hasPrograms = true;
            });

            self.populateTable();
            self.updateTotal();
            self.showPaginator();
        },
        gotoPage: function (pageNum) {
            offset = (pageNum - 1) * perPage;
            self.doSearch();
            $('html,body').scrollTop(0);
        },
        prevPage: function () {
            offset -= perPage;
            self.doSearch();
            $('html,body').scrollTop(0);
        },
        nextPage: function () {
            offset += perPage;
            self.doSearch();
            $('html,body').scrollTop(0);
        },
        firstPage: function () {
            offset = 0;
            self.doSearch();
            $('html,body').scrollTop(0);
        }
    }


    this.doSearch();
}