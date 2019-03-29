/**
 * Created by Temi Varghese on 22/10/15.
 */
//= require lz-string-1.4.4/lz-string.min.js
//= require button-toggle-events.js
//= require facets.js
// leaflet
//= require leaflet-manifest.js
//= require_self

function ProjectFinder(config) {

    var self = this;
    /* holds all projects */
    var allProjects = [];

    /* holds current filtered list */
    var projects;

    /* pagination offset into the record set */
    var offset = 0;

    /* size of current filtered list */
    var total = 0;

    /* The map must only be initialised once, so keep track of when that has happened */
    var mapInitialised = false;

    /* Stores selected project id when a link is selected */
    var selectedProjectId;
    var spatialFilter = null;

    var geoSearch = {};

    var refreshSearch = false;
    var enablePartialSearch = config.enablePartialSearch || false;

    var filterQuery, lazyLoad;

    this.availableProjectTypes = new ProjectViewModel({}, false).transients.availableProjectTypes;

    this.sortKeys = [
        {name: 'Name', value: 'nameSort'},
        {name: 'Relevance', value: '_score'},
        {name: 'Organisation Name', value: 'organisationSort'},
        {name: 'Status', value: 'status'}
    ];

    var alaMap;

    /* window into current page */
    function PageVM(config) {
        this.self = this;
        this.pageProjects = ko.observableArray();
        this.facets = ko.observableArray();
        this.selectedFacets = ko.observableArray();
        this.columns = ko.observable(2);
        self.columns = this.columns
        this.doSearch = function () {

            self.doSearch();
        }
        this.getFacetTerms = function (facets) {
            return self.getFacetTerms(facets);
        }

        this.reset = function () {
            self.reset();
        }

        this.availableProjectTypes = ko.observableArray(self.availableProjectTypes);
        this.projectTypes = ko.observable(['citizenScience', 'works', 'survey', 'merit']);
        this.sortKeys = ko.observableArray(self.sortKeys);
        this.download = function (obj, e) {
            bootbox.alert("The download may take several minutes to complete.  Once it is complete, an email will be sent to your registered email address.");
            $.post(config.downloadWorksProjectsUrl, self.getParams()).fail(function() {
                bootbox.alert("There was an error attempting your download.  Please try again or contact support.");
            });
            return false;
        };

        self.resizeGrid = function () {
            var width = $( window ).width();
            if(width >= 1 && width <=480) {
                self.columns(1);
            } else if (width > 480 && width <768) {
                self.columns(2);
            } else if (width >= 768 && width <992) {
                self.columns(3);
            } else if (width >= 992) {
                self.columns(4);
            }

            updateLazyLoad();
        };

        $( window ).resize(function () {
            self.resizeGrid();
        });

        self.resizeGrid();

        // this.listView = ko.observable(true);
        this.viewMode = ko.observable("tileView");

        this.viewMode.subscribe(function (newValue) {
            if ((newValue === 'tileView') || (newValue === 'listView')) {
                setTimeout(updateLazyLoad, 0);
            }
        });

        /**
         * this function is used to tell project/index or citizenscience page that the traffic is coming from
         * project finder page. This flag is used to decide if about page of the project should be shown.
         * @returns {boolean}
         */
        this.setTrafficFromProjectFinderFlag = function(project){
            selectedProjectId = project.transients.projectId;
            updateHash();
            amplify.store('traffic-from-project-finder-page',true);
            // to execute default action of anchor tag, true must be returned.
            return true;
        }

        this.partitioned = function (observableArray, countObservable) {
            var rows, partIdx, i, j, arr;
            var count = countObservable();

            arr = observableArray();

            rows = [];
            for (i = 0, partIdx = 0; i < arr.length; i += count, partIdx += 1) {
                rows[partIdx] = [];
                for (j = 0; j < count; j += 1) {
                    if (i + j >= arr.length) {
                        break;
                    }
                    arr[i + j].transients.index(i+j);
                    rows[partIdx].push(arr[i + j]);
                }
            }
            return rows;
        };

        this.styleIndex = function (dataIndex, rowSize) {
            return dataIndex() % rowSize + 1 ;
        };

        this.filterViewModel = new FilterViewModel({
            parent: this,
            flimit: fcConfig.flimit
        });

        this.filterViewModel.selectedFacets.subscribe(this.doSearch)
    }
    
    /**
     * check if button has active flag
     * @param $button
     * @returns {boolean}
     */
    function isButtonChecked($button) {
        return $button.hasClass('active') ? true : false
    }

    /**
     * get values of data-value attribute for all active buttons
     * @param $button
     * @returns {Array}
     */
    function getActiveButtonValues($button) {
        var result = [];
        $button.find('.active').each(function (index, it) {
            result.push($(it).attr('data-value'));
        });
        return result
    }

    function setActiveButtonValues($button, values) {
        $button.children('button').each(function (index, child) {
            if (values && values.indexOf($(child).attr('data-value')) > -1) {
                $(child).addClass('active');
            } else {
                $(child).removeClass('active');
            }
        });
    }

    function uncheckButton($button) {
        $button.removeClass('active');
        // if button group
        $button.find('.active').removeClass('active');
        return $button;
    }

    function toggleButton($button, on) {
        if (on) {
            checkButton($button, 'button', 'data-toggle');
        } else {
            $button.removeClass('active');
        }
    }

    function initialiseMap() {
        if (!mapInitialised) {
            spatialFilter = new ALA.Map("mapFilter", {
                wmsLayerUrl: fcConfig.spatialWms + "/wms/reflect?",
                wmsFeatureUrl: fcConfig.featureService + "?featureId=",
                myLocationControlTitle: "Within " + fcConfig.defaultSearchRadiusMetersForPoint + " of my location"
            });

            var regionSelector = Biocollect.MapUtilities.createKnownShapeMapControl(spatialFilter, fcConfig.featuresService, fcConfig.regionListUrl);
            spatialFilter.addControl(regionSelector);
            spatialFilter.subscribe(geoSearchChanged);
            mapInitialised = true;
        }
    }

    function checkButton($button, value, attribute) {
        var attr = attribute || 'data-value';
        $button.removeClass('active').find('button.active').removeClass('active');
        if (value && $button.attr(attr) === value) {
            $button.addClass('active');
        }
        $button.find('[' + attr + '=' + value + ']').addClass('active')
    }

    /**
     * bring the selected element to view by animation.
     * @param selector
     */
    function scrollToView(selector) {
        var offset = $(selector).offset()
        if (offset) {
            $("html, body").animate({
                scrollTop: offset.top
            })
        }
    }

    function scrollToProject () {
        if (selectedProjectId) {
            scrollToView('#'+ selectedProjectId);
            // clear selected project id when viewing a page, or filter querying
            selectedProjectId = undefined;
        }
    }

    pageWindow = new PageVM(config);
    ko.applyBindings(pageWindow, document.getElementById('project-finder-container'));

    this.getParams = function () {
        var fq = [];
        var isUserPage = fcConfig.isUserPage || false;
        var isUserWorksPage = fcConfig.isUserWorksPage || false;
        var isUserEcoSciencePage = fcConfig.isUserEcoSciencePage || false;
        var organisationName = fcConfig.organisationName;
        var isCitizenScience = fcConfig.isCitizenScience || false;
        var isWorks = fcConfig.isWorks || false;
        var isBiologicalScience = fcConfig.isBiologicalScience || false;
        var isMERIT = fcConfig.isMERIT || false;
        var isWorldWide, hideWorldWideBtn = fcConfig.hideWorldWideBtn || false;
        if(!hideWorldWideBtn){
            isWorldWide= getActiveButtonValues($('#pt-aus-world'));
            isWorldWide = isWorldWide.length? isWorldWide[0] : false
        }

        var sortBy = getActiveButtonValues($("#pt-sort"));
        perPage = parseInt(getActiveButtonValues($("#pt-per-page"))[0]);

        pageWindow.filterViewModel.selectedFacets().forEach(function (facet) {
            fq.push(facet.getQueryText())
        });

        var map = {
            fq: fq,
            offset: offset,
            isCitizenScience: isCitizenScience,
            isWorks: isWorks,
            isBiologicalScience: isBiologicalScience,
            isMERIT: isMERIT,
            isUserPage: isUserPage,
            isUserWorksPage: isUserWorksPage,
            isUserEcoSciencePage: isUserEcoSciencePage,
            organisationName: organisationName,
            geoSearchJSON: JSON.stringify(geoSearch),
            skipDefaultFilters:fcConfig.showAllProjects,
            isWorldWide: isWorldWide,
            projectId: selectedProjectId,
            q: this.getQuery(true)
        };

        map.max =  perPage // Page size

        if(sortBy .length == 1) {
            map.sort = sortBy[0]
        }

        if (fcConfig.associatedPrograms) {
            $.each(fcConfig.associatedPrograms, function (i, program) {
                var checked = isButtonChecked($('#pt-search-program-' + program.name.replace(/ /g, '-')))
                if (checked) map["isProgram" + program.name.replace(/ /g, '-')] = true
            });
        }

        return map
    };

    this.getQuery = function (partialSearch) {
        var query = ($('#pt-search').val() || '' ).toLowerCase();
        if (enablePartialSearch) {
            if (partialSearch && ((query.length >= 3) && (query.indexOf('*') == -1))) {
                query = '*' + query + '*';
            }
        }

        return query;
    };

    this.santitizeQuery = function (query) {
        if (query) {
            query = query.replace(/^\*/g, '').replace(/\*$/g, '');
        }

        return query;
    };

    /**
     * this is the function calling server with the latest query.
     */
    this.doSearch = function () {
        if(pageWindow.filterViewModel.switchOffSearch()){
            return;
        }

        refreshSearch = false;
        var params = self.getParams();

        window.location.hash = constructHash();
        return $.ajax({
            url: fcConfig.projectListUrl,
            data: params,
            traditional: true,
            beforeSend: function () {
                $('#pt-result-heading').hide();
                $('.search-spinner').show();

            },
            success: function (data) {
                var projectVMs = [], facets;
                total = data.total;
                $.each(data.projects, function (i, project) {
                    projectVMs.push(new ProjectViewModel(project, false));
                });
                self.pago.init(projectVMs);
                pageWindow.filterViewModel.setFacets(data.facets || []);
                updateLazyLoad();
                setTimeout(scrollToProject, 500);
                // Issue map search in parallel to 'standard' search
                // standard search is required to drive facet display
                self.doMapSearch(projectVMs);
            },
            error: function () {
                console.error("Could not load project data.");
                console.error(arguments)
            },
            complete: function () {
                $('.search-spinner').hide();
                $('#pt-result-heading').fadeIn();
            }
        })
    };

    function updateLazyLoad() {
        if (!lazyLoad) {
            if (typeof LazyLoad !== 'undefined') {
                lazyLoad = new LazyLoad({
                    elements_selector: "img.lazy"
                });
            } else {
                setTimeout(updateLazyLoad, 100);
            }
        } else {
            lazyLoad.update();
        }
    }

    /**
     * this is the function calling server with the latest query.
     */
    this.getFacetTerms = function (facets) {
        refreshSearch = false;
        var params = self.getParams();
        params.flimit = -1;
        params.facets = facets;
        params.max = 0;

        return $.ajax({
            url: fcConfig.projectListUrl,
            data: params,
            traditional: true
        });
    };
    
    this.searchAndShowFirstPage = function () {
        self.pago.firstPage();
        return true
    };


    this.reset = function () {
        checkButton($('#pt-sort'), 'nameSort');
        checkButton($('#pt-per-page'), '20');
        $('#pt-search').val('');
        if (spatialFilter) {
            spatialFilter.resetMap();
        }
        geoSearch = {};
        refreshGeofilterButtons();
        pageWindow.filterViewModel.selectedFacets.removeAll();
    }
    /*************************************************\
     *  Show filtered projects on current page
     \*************************************************/
    this.populateTable = function () {
        pageWindow.pageProjects(projects);
        pageWindow.pageProjects.valueHasMutated();
        self.showPaginator();
    };

    /** display the current size of the filtered list **/
    this.updateTotal = function () {
        // $('#pt-resultsReturned').html("Found <strong>" + total + "</strong> " + (total == 1 ? 'project.' : 'projects.'));
        $('#pt-resultsReturned').html(this.paginationInfo());
    };

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

        var $pago = $("<div class='pagination margin-bottom-5 margin-top-5'></div>");
        $pago.append($ul);
        $('div#pt-navLinks').html($pago);
    };


    this.paginationInfo = function () {
        if (total > 0) {
            var start = offset + 1;
            var end = Math.min(total, start + perPage - 1);
            var message = fcConfig.paginationMessage || 'Showing XXXX to YYYY of ZZZZ projects';
            return message.replace('XXXX', start).replace('YYYY', end).replace('ZZZZ', total);
        } else {
            return "No projects found."
        }
    };

    this.augmentVM = function (vm) {
        var x, urls = [];
        if (vm.urlWeb()) urls.push('<a href="' + vm.urlWeb() + '">Website</a>');
        for (x = "", docs = vm.transients.mobileApps(), i = 0; i < docs.length; i++)
            x += '&nbsp;<a href="' + docs[i].link.url + '" class="do-not-mark-external"><img class="logo-small" src="' + docs[i].logo(fcConfig.logoLocation) + '"/></a>';
        if (x) urls.push("Mobile Apps&nbsp;" + x);
        for (x = "", docs = vm.transients.socialMedia(), i = 0; i < docs.length; i++)
            x += '&nbsp;<a href="' + docs[i].link.url + '" class="do-not-mark-external"><img class="logo-small" src="' + docs[i].logo(fcConfig.logoLocation) + '"/></a>';
        if (x) urls.push("Social Media&nbsp;" + x);
        vm.transients.links = urls.join('&nbsp;&nbsp;|&nbsp;&nbsp;') || '';
        vm.transients.searchText = (vm.name() + ' ' + vm.aim() + ' ' + vm.description() + ' ' + vm.keywords() + ' ' + vm.transients.scienceTypeDisplay() + ' ' + vm.transients.locality + ' ' + vm.transients.state + ' ' + vm.organisationName()).toLowerCase();
        vm.transients.indexUrl = vm.isMERIT() ? fcConfig.meritProjectUrl + '/' + vm.transients.projectId : fcConfig.projectIndexBaseUrl + vm.transients.projectId;
        vm.transients.orgUrl = vm.organisationId() && (fcConfig.organisationBaseUrl + vm.organisationId());
        vm.transients.imageUrl = fcConfig.meritProjectLogo && vm.isMERIT() ? fcConfig.meritProjectLogo : vm.imageUrl();
        if (!vm.transients.imageUrl) {
            x = vm.primaryImages();
            if (x && x.length > 0) vm.transients.imageUrl = x[0].url;
        }
        return vm;
    };


    /**
     * Initialises user default (saved) view for filter and results
     * Filter can be shown/hidden
     * Results can be displayed as list or map-popup (grid)
     */
    this.initViewMode = function () {

        // Results view
        var savedViewMode = amplify.store('pt-view-state');
        savedViewMode = savedViewMode || "tileView"; //Default is the new map-popup view
        checkButton($("#pt-view"), savedViewMode);
        var viewMode = getActiveButtonValues($("#pt-view"));
        pageWindow.viewMode(viewMode[0]);

        // Filters view
        var showPanel = amplify.store('pt-filter');
        showPanel = showPanel === undefined ? true : showPanel;
        toggleFilterPanel(showPanel);
    };


    /**
     * creates the map and plots the points on map
     * @param features
     */
    self.doMapSearch = function (projects){

        var mapOptions = {
            drawControl: false,
            showReset: false,
            draggableMarkers: false,
            useMyLocation: false,
            allowSearchLocationByAddress: false,
            allowSearchRegionByAddress: false,
        };

        if(!self.pfMap){
            self.pfMap = new ALA.Map("pfMap", mapOptions);

            self.pfMap.addButton("<span class='fa fa-refresh reset-map' title='Reset zoom'></span>", self.pfMap.fitBounds, "bottomleft");
        }

        var features = [];
        // var geoPoints = data;

        if (projects) {
            $.each(projects, function (j, project) {
                var projectId = project.projectId;
                var projectName = project.name;

                if (project.coverage) {

                        var point = {
                            geometry: Biocollect.MapUtilities.featureToValidGeoJson(project.coverage),
                            popup: generatePopup(project)
                        };

                        if (project.coverage.centre && project.coverage.centre.length == 2) {
                            point.lat = parseFloat(project.coverage.centre[1]);
                            point.lng = parseFloat(project.coverage.centre[0]);
                        } else {
                            point.lat = parseFloat(project.coverage.decimalLatitude);
                            point.lng = parseFloat(project.coverage.decimalLongitude);
                        }

                        if (isValidPoint(point)) {
                            features.push(point);
                        } else {
                            console.warn('Project ' + project.name() + 'does not have valid coordinates');
                        }
                }
            });
        }

        features && features.length && self.pfMap.addClusteredPoints(features);
        self.pfMap.redraw()

    };

    function generatePopup(project) {
        var imageUrl = project.transients.imageUrl || fcConfig.noImageUrl
        var html =

            "<div class='map-popups'>" +
            "<div class='map-popup'>" +
            "            <div>" +
            "            <div class='text-center'>" +
            "            <a href='transients.indexUrl' click='setTrafficFromProjectFinderFlag()'>" +
            "            <img class='map-popup-image' alt='No image provided' title='" + project.transients.truncatedName() + "' src='" + imageUrl + "' " +
            "onerror='imageError(this, fcConfig.noImageUrl);' />" +
            "            </a>"

        if (project.isSciStarter()) {

            html = html +
            "        <img class='display-inline-block logo-small'" +
            "        src='" + fcConfig.sciStarterImageUrl  + "'" +
            "        title='Project is sourced from SciStarter'>"
        }

        html = html +
        "            </div>" +
        "            </div>"


        html = html +
            "        <div "+
            "         click='setTrafficFromProjectFinderFlag()'>"+
            "            <a class='map-popup-title'" +
            " href='"+project.transients.indexUrl + "'  click='setTrafficFromProjectFinderFlag()'>"+
            "            <span>" + project.transients.truncatedName() +
            "</span>"+
            "            </a>"+
            "            </div>"


        if(project.transients.daysSince() >= 0) {
            html = html +
            "            <div class='map-popup-small'>"+
            "            <span>Started "+project.transients.since() + "&nbsp;</span>"+
            "        </div>"

        }

        html = html +

            "<div>" +
                "<a class='map-popup-organisation' href='"+ project.transients.orgUrl +"'>" +
                 project.transients.truncatedOrganisationName() +
                "</a>" +
            "</div>" +



            "   <div>"+ project.transients.truncatedAim() + "</div>"+

            "   <div class='map-popup-small'>"+ daysToGoHtml(project) + "</div>"+
            "</div>" +
            "</div>"


        return html;
    }

    function daysToGoHtml(project) {

        var html = "<div class='dayscount'>"

        if(project.transients.daysSince() >= 0 && project.transients.daysRemaining() > 0) {
            html = html + "<strong>Status: </strong> <span>"+ project.transients.daysRemaining() +  "days to go</span>"
        } else if (project.transients.daysSince() >= 0 && project.transients.daysRemaining() == 0) {
            html = html + "<strong>Status: </strong> <span>Project Ended</span>"
        } else if(project.transients.daysSince() >= 0 && project.transients.daysRemaining() < 0) {
            html = html + "<strong>Status: </strong> <span>Project Ongoing</span>"
        } else if(project.transients.daysSince() < 0) {
            html = html + "<strong>Status: </strong> <span>Starts in </span> <span>"+ -project.transients.daysSince() +" </span><span> days</span> "
        }

        html = html + "</div>"

        if(project.plannedStartDate()) {
            html = html +
                "<span class='dayscount'>" +
                "   <small>Start date: " +  moment(project.plannedStartDate()).format('DD MMMM, YYYY') +"</small>" +
                "</span>"
        }

        if(project.plannedEndDate()) {
            html = html +
                "<span class='dayscount'>" +
                "<br/><small>End date: " + moment(project.plannedEndDate()).format('DD MMMM, YYYY') + "</small> " +
                "</span>"
        }

        return html
    }


    function isValidPoint(point) {
        return !isNaN(point.lat) && !isNaN(point.lng) && point.lat >= -90 && point.lat <= 90 && point.lng >= -180 && point.lng <= 180
    }

    function toggleFilterPanel(showPanel) {
        if(showPanel) {

            $('#pt-table').removeClass('span11 no-sidebar');
            $('#pt-table').addClass('span9');
            $('#filterPanel').show();
            $('#pt-filter').addClass('active');

        } else {
            $('#filterPanel').hide();
            $('#pt-table').removeClass('span9');
            $('#pt-table').addClass('span11 no-sidebar');
        }
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

    this.setTextSearchSettings = function () {
        checkButton($('#pt-sort '), '_score')
    };

    $("#pt-filter").on('statechange', function () {
        var active = isButtonChecked($("#pt-filter"));
        amplify.store('pt-filter', active);
        toggleFilterPanel(active);
        //toggleFilterPanel();

    });

    $("#pt-view").on('statechange', function () {
        var viewMode = getActiveButtonValues($("#pt-view"));
        // pageWindow.listView(viewMode[0] == "listView");
        pageWindow.viewMode(viewMode[0])
        amplify.store('pt-view-state', viewMode[0]);

        if(pageWindow.viewMode() == 'mapView') {
            self.pfMap.redraw()
        }

    });
    
    $("#pt-aus-world").on('statechange', function(){
        var viewMode = getActiveButtonValues($("#pt-view"));
    })


    $("#mapModal").on('shown', function () {
        initialiseMap();
    });

    $("#mapModal").on('hide', function () {
        geoSearchChanged();
        if(refreshSearch) {
            self.doSearch();
        }
    });

    $("#clearFilterByRegionButton").click(function () {
        geoSearch = {};
        spatialFilter.resetMap();
        refreshGeofilterButtons();
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
        self.reset()
    });

    $("#btnShowTileView").click(function () {
        pageWindow.showTileView();
        
    });

    $("#btnShowListView").click(function () {
        pageWindow.showListView();

    });

    // check for statechange event on all buttons in filter panel.
    $('#pt-searchControls').on('statechange', self.searchAndShowFirstPage);

    $('#pt-sort').on('statechange', self.searchAndShowFirstPage);

    $('#pt-per-page').on('statechange', function() {
        perPage = parseInt(getActiveButtonValues($("#pt-per-page"))[0]);
        self.searchAndShowFirstPage()
        });

    $('#pt-aus-world').on('statechange', self.searchAndShowFirstPage);




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
            self.doSearch().done(function () {
                scrollToView("#heading");
            });
        },
        prevPage: function () {
            offset -= perPage;
            self.doSearch().done(function () {
                scrollToView("#heading");
            });
        },
        nextPage: function () {
            offset += perPage;
            self.doSearch().done(function () {
                scrollToView("#heading");
            });
        },
        firstPage: function () {
            offset = 0;
            self.doSearch();
        }
    };

    function constructHash() {
        var params = self.getParams();

        var hash = [];
        for (var param in params) {
            if (params.hasOwnProperty(param) && params[param] && params[param] != '') {
                if ((param != 'geoSearchJSON') && (param != 'fq')) {
                    hash.push(param + "=" + params[param]);
                }
            }
        }

        if (!_.isEmpty(geoSearch)) {
            hash.push('geoSearch=' + LZString.compressToBase64(JSON.stringify(geoSearch)));
        }

        if (!_.isEmpty(params.fq)) {
            params.fq.forEach(function (filter) {
                hash.push('fq=' + filter)
            })
        }

        return encodeURIComponent(hash.join("&"));
    }

    function parseHash() {
        pageWindow.filterViewModel.switchOffSearch(true);
        var hash = decodeURIComponent(window.location.hash.substr(1)).split("&");

        var params = {
            fq: []
        };
        for (var i = 0; i < hash.length; i++) {
            var keyAndValue = hash[i].split("=");
            //sometimes it is possible to have more than one = symbol eg. fq=plannedStartDate:>=2017-12-20
            if(keyAndValue.length > 2){
                keyAndValue = [hash[i].substr(0,hash[i].indexOf('=')), hash[i].substr(hash[i].indexOf('=')+1)]
            }

            if (keyAndValue.indexOf(",") > -1) {
                params[keyAndValue[0]] = keyAndValue.split(",");
            } else {
                if(typeof params[keyAndValue[0]] == 'string'){
                    params[keyAndValue[0]] = [params[keyAndValue[0]], keyAndValue[1]]
                } else if( params[keyAndValue[0]] == undefined) {
                    params[keyAndValue[0]] = keyAndValue[1]
                } else {
                    params[keyAndValue[0]].push( keyAndValue[1] );
                }
            }
        }

        params.q = self.santitizeQuery(params.q);
        setGeoSearch(params.geoSearch);
        pageWindow.filterViewModel.setFilterQuery(params.fq);
        offset = params.offset || offset;
        selectedProjectId = params.projectId;

        if (fcConfig.associatedPrograms) {
            $.each(fcConfig.associatedPrograms, function (i, program) {
                toggleButton($('#pt-search-program-' + program.name.replace(/ /g, '-')), toBoolean(params["isProject" + program.name]));
            });
        }

        checkButton($("#pt-sort"), params.sort || 'dateCreatedSort');
        checkButton($("#pt-per-page"), params.max || '20');
        checkButton($("#pt-aus-world"), params.isWorldWide || 'false');
        
        $('#pt-search').val(params.q).focus();
        pageWindow.filterViewModel.switchOffSearch(false);
    }

    function updateHash() {
        var hash = constructHash();
        window.location.hash = hash;
    }

    function setGeoSearch(geoSearchHash) {
        if (geoSearchHash && typeof geoSearchHash !== 'undefined') {
            geoSearch = JSON.parse(LZString.decompressFromBase64(geoSearchHash));

            toggleButton($('#pt-map-filter'), true);

            var geoJson = ALA.MapUtils.wrapGeometryInGeoJSONFeatureCol(geoSearch);
            geoJson = ALA.MapUtils.getStandardGeoJSONForCircleGeometry(geoJson);
            if (geoSearch.pointSearch) {
                geoJson.features[0].properties = {};
                delete geoJson.features[0].geometry.pointSearch;
            } else if (geoSearch.pid) {
                // Special case for WMS layers: need to move the PID attribute to the properties object in the GeoJSON
                // The pid was stored in the geometry in the url hash, but that is not valid GeoJSON, so it needs to be
                // moved. The ALA Map's setGeoJSON method will look for a pid in the properties and create a WMS layer.
                geoJson.features[0].properties.pid = geoSearch.pid;
            }

            spatialFilter.setGeoJSON(geoJson);
        }
    }

    function toBoolean(str) {
        return str && str.toLowerCase() === 'true';
    }

    function refreshGeofilterButtons() {
        if ($.isEmptyObject(geoSearch)) {
            $('#clearFilterByRegionButton').removeClass('active');
            $('#filterByRegionButton').removeClass('active');
        } else {
            $('#clearFilterByRegionButton').addClass('active');
            $('#filterByRegionButton').addClass('active');
        }
    }

    function geoSearchChanged() {
        readUpdatedGeographicFilters();
        refreshGeofilterButtons();

    }
     function readUpdatedGeographicFilters() {

        var geoJSON = ALA.MapUtils.getGeometryWithCirclesFromGeoJSON(spatialFilter.getGeoJSON());

        if (geoJSON && geoJSON.features.length == 1) {
            var geoCriteriaChanged = false;

            var geometry = geoJSON.features[0].geometry;

            // if the user has selected a point, we need to convert it into a circle query to find all sites close to that point
            if (geometry.type === ALA.MapConstants.DRAW_TYPE.POINT_TYPE) {
                var circleSearch = {
                    type: ALA.MapConstants.DRAW_TYPE.CIRCLE_TYPE,
                    radius: fcConfig.defaultSearchRadiusMetersForPoint,
                    coordinates: geometry.coordinates,
                    pointSearch: true
                };

                if (!_.isEqual(geoSearch, circleSearch)) {
                    geoSearch = circleSearch;
                    geoCriteriaChanged = true;
                }
            } else {
                // store the pid of a wms layer in the geometry object that is saved in the url has so it can be used
                // to rebuild a WMS layer on the map.
                if (geoJSON.features[0].properties.pid) {
                    geometry.pid = geoJSON.features[0].properties.pid;
                }
                geoSearch = geometry;
                geoCriteriaChanged = true;
            }

            refreshSearch = geoCriteriaChanged && validSearchGeometry(geoSearch);

        } else if (geoJSON.features.length == 0 && geoSearch) {
            refreshSearch = true;
            geoSearch = {};
            self.doSearch();
        }
    }

    function validSearchGeometry(geometry) {
        var valid = false;

        if (geometry.type === "Polygon") {
            valid = geometry.coordinates && geometry.coordinates.length == 1 && geometry.coordinates[0].length > 1
        } else if (geometry.type == "Circle") {
            valid = geometry.coordinates && geometry.coordinates.length == 2 && geometry.radius
        } else if (geometry.type == "Point") {
            valid = geometry.coordinates && geometry.coordinates.length == 2
        }

        return valid
    }


    if (fcConfig.hideWorldWideBtn) {
        $('#pt-aus-world').hide();
        $('#pt-aus-world-block').hide();
    }

    parseHash();
    self.doSearch();
    self.initViewMode();
}

