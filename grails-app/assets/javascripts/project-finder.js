/**
 * Created by Temi Varghese on 22/10/15.
 */
//= require lz-string-1.4.4/lz-string.min.js
//= require facets.js
// leaflet
//= require leaflet-manifest.js
//= require_self
// responsive table
//= require responsive-table-stacked/stacked.js
//= require pagination.js

function ProjectFinder(config) {

    var self = this;
    /* holds all projects */
    var allProjects = [];
    var projectContainerId = 'project-finder-container';

    /* holds current filtered list */
    var projects;

    /* pagination offset into the record set */
    var offset = 0;

    /* size of current filtered list */
    var total = 0;
    var projectsPerPage = 30;

    /* The map must only be initialised once, so keep track of when that has happened */
    var mapInitialised = false;

    /* Stores selected project id when a link is selected */
    var selectedProjectId;
    var spatialFilter = null;

    // boolean flag used to clear filter map after it is visible on a modal.
    var clearMapFilter = false;

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
    var pfMapId = "#map-tab";
    var mapFilterSelector = "#mapModal"

    /* window into current page */
    function PageVM(config) {
        var vm = this;                      // ✅ single alias for PageVM

        vm.sortBy = ko.observable("dateCreatedSort");
        vm.isWorldWide = ko.observable("false");
        vm.pageProjects = ko.observableArray();
        vm.facets = ko.observableArray();
        vm.isGeoSearchEnabled = ko.observable(false);
        vm.selectedFacets = ko.observableArray();
        vm.columns = ko.observable(2);

        vm.pagination = new PaginationViewModel({numberPerPage: projectsPerPage}, vm);
        self.columns = vm.columns;
        vm.clearGeoSearch = function () {
            vm.isGeoSearchEnabled(false);
            clearGeoSearch();
            self.doSearch();
        };
        vm.doSearch = function () {

            self.doSearch();
        };
        vm.resetPageOffSet = function () {
            self.resetPageOffSet();
        };

        vm.getFacetTerms = function (facets) {
            return self.getFacetTerms(facets);
        };

        vm.reset = function () {
            self.reset();
        };

        vm.sortBy.subscribe(function(){ self.doSearch(); });
        vm.isWorldWide.subscribe(function(){ self.doSearch(); });

        vm.availableProjectTypes = ko.observableArray(self.availableProjectTypes);
        vm.projectTypes = ko.observable(['citizenScience', 'works', 'survey', 'merit']);
        vm.sortKeys = ko.observableArray(self.sortKeys);
        vm.download = function () {
            bootbox.alert("The download may take several minutes to complete. Once it is complete, an email will be sent to your registered email address.");
            $.post(config.downloadWorksProjectsUrl, self.getParams()).fail(function () {
                bootbox.alert("There was an error attempting your download.  Please try again or contact support.");
            });
            return false;
        };

        vm.refreshPage = function (newOffset) {
            offset = newOffset;
            self.doSearch();
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
        vm.viewMode = ko.observable("tileView");

        vm.viewMode.subscribe(function (newValue) {
            if ((newValue === 'tileView' || newValue === 'listView')) {
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

        vm.partitioned = function (observableArray, countObservable) {
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

        vm.styleIndex = function (dataIndex, rowSize) {
            return dataIndex() % rowSize + 1 ;
        };

        vm.filterViewModel = new FilterViewModel({
            parent: self,
            flimit: fcConfig.flimit
        });

        vm.filterViewModel.selectedFacets.subscribe(function () {
            self.resetPageOffSet(); // pagination restarts at page 1
            self.doSearch();       //make the query
        });

        vm.removeNationwide = function () {
            vm.filterViewModel.nationwideProjectCheckbox(false);
            self.resetPageOffSet();
            self.doSearch();
        };
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

    function initialiseMap() {
        if (!mapInitialised) {
            var overlayLayersMapControlConfig = Biocollect.MapUtilities.getOverlayConfig();
            var baseLayersAndOverlays = Biocollect.MapUtilities.getBaseLayerAndOverlayFromMapConfiguration(fcConfig.mapLayersConfig);

            spatialFilter = new ALA.Map("mapFilter", {
                autoZIndex: false,
                preserveZIndex: true,
                addLayersControlHeading: true,
                allowSearchRegionByAddress: false,
                wmsLayerUrl: overlayLayersMapControlConfig.wmsLayerUrl,
                wmsFeatureUrl: overlayLayersMapControlConfig.wmsFeatureUrl,
                myLocationControlTitle: "Within " + fcConfig.defaultSearchRadiusMetersForPoint + " KM of my location",
                baseLayer: baseLayersAndOverlays.baseLayer,
                otherLayers: baseLayersAndOverlays.otherLayers,
                overlays: baseLayersAndOverlays.overlays,
                overlayLayersSelectedByDefault: baseLayersAndOverlays.overlayLayersSelectedByDefault
            });

            const regionSelector = Biocollect.MapUtilities.createKnownShapeMapControl(
                spatialFilter,
                fcConfig.featuresService,
                fcConfig.regionListUrl,
                {
                    iconClass: "fa fa-map-o"
                }
            );

            // Create the custom option above the leaflet draw toolbar
            setTimeout(() => {
                const drawControl = document.querySelector('.leaflet-draw.leaflet-control');
                const globeControl = regionSelector.onAdd(spatialFilter.getMapImpl());

                if (drawControl && globeControl) {
                    const drawParent = drawControl.parentElement;

                    // Inserting custom option before leaflet draw toolbar
                    drawParent.insertBefore(globeControl, drawControl);
                } else {
                    console.warn('Could not find drawControl or globeControl');
                }
            }, 100);

            mapInitialised = true;
        } else {
            spatialFilter.getMapImpl().invalidateSize();
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
    ko.applyBindings(pageWindow, document.getElementById(projectContainerId))   ;

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
            isWorldWide= pageWindow.isWorldWide() === "true";
        }

        var queryString = '';
        var selectedList = pageWindow.filterViewModel.selectedFacets();
        var origFacetList = pageWindow.filterViewModel.origSelectedFacet();

        // Separate AND from OR condtion
        var uniqueFacetTerm = [];
        selectedList.forEach(function (item) {
            if (item.facet.type == 'terms') {
                if (uniqueFacetTerm.indexOf(item.facet.name()) == -1) {
                    uniqueFacetTerm.push(item.facet.name())
                }
            }
        });
        var dupFacet = {};
        uniqueFacetTerm.forEach(function (name) {
            var tempList = [];
            var mixedTempList = [];
            selectedList.forEach(function(item) {
                // if this facet is part of the original OR condition, ignore it
                var found = origFacetList.find(function (orig) {
                    //if (item.facet.name() == orig.facet.name() && item.term() == orig.term()) {
                    if (item.type == 'term' && item.id() == orig.id()) {
                        return true;
                    }
                });
                if (!found) {
                    // if the facet name exist but not term, treat the others as AND condition
                    var nameFound = origFacetList.find(function (orig) {
                        if (item.facet.name() == orig.facet.name()) {
                            return true;
                        }
                    });
                    if (item.facet.name() == name) {
                        if (nameFound) {
                            mixedTempList.push(item);
                        } else
                            tempList.push(item);
                    }
                }
            });
            if (tempList.length > 1) {
                dupFacet[name] = tempList;
            } else if (mixedTempList.length > 0) {
                dupFacet[name] = mixedTempList;
            }
        });

        for (var term in dupFacet) {
            var andFacetTermList = [];
            var facetList = dupFacet[term];
            facetList.forEach(function (item) {
                selectedList = selectedList.filter(function(element) {
                    return !(element.type == "term" && element.id() == item.id())
                });
                andFacetTermList.push(item.exclude? '-"' + item.term() + '"': '"' + item.term() + '"');
            });


            var termStrList = '';
            if (andFacetTermList.length > 0) {
                termStrList = '(' + andFacetTermList.join(' AND ') + ')';
            }

            if (termStrList.length > 0) {
                if (queryString.length > 0) {
                    queryString = queryString +  ' AND ';
                }
                queryString = queryString + term + ':' + termStrList;
            }
        }

        selectedList.forEach(function (facet) {
            fq.push(facet.getQueryText());
        });

        var query = this.getQuery(true);
        if (query.length > 0) {
            query = query + ((queryString.length > 0)? ' AND ' + queryString: "");
        } else {
            query = queryString;
        }

        var queryList = [];
        pageWindow.filterViewModel.selectedFacets().forEach(function (facet) {
            queryList.push(facet.getQueryText());
        });

        // get the checkbox value
        var excludeNationwide = !!(pageWindow.filterViewModel.nationwideProjectCheckbox && pageWindow.filterViewModel.nationwideProjectCheckbox());

        // only add filter when checked
        if (excludeNationwide) {
            if (!fq.includes('nationwideFacet:true')) fq.push('nationwideFacet:true');
        }

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
            q: query,
            queryList: queryList,
            queryText: this.getQuery(true),
            // sending the value for logging use
            excludeNationwide: excludeNationwide
        };

        map.max =  pageWindow.pagination.resultsPerPage(); // Page size
        map.sort = pageWindow.sortBy();

        return map;
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
                $('.search-spinner').removeClass('d-none');

            },
            success: function (data) {
                var projectVMs = [], facets;
                total = data.total;
                if (total == 0 && pageWindow.filterViewModel.redefineFacet() && pageWindow.filterViewModel.origSelectedFacet().length > 0) {
                    bootbox.alert ("There are no projects that fulfil the filter condition. Please click 'Clear all' to redefine the search criteria. ")
                }
                $.each(data.projects, function (i, project) {
                    projectVMs.push(self.augmentVM(new ProjectViewModel(project, false)));
                });
                pageWindow.pagination.loadOffset(offset, total);
                pageWindow.pageProjects(projectVMs);
                pageWindow.filterViewModel.setFacets(data.facets || []);
                self.updateTotal();
                updateLazyLoad();
                setTimeout(scrollToProject, 500);
                // Issue map search in parallel to 'standard' search
                // standard search is required to drive facet display
                // todo : uncomment when all project area can be shown without pagination
                // self.doMapSearch(projectVMs);
            },
            error: function () {
                console.error("Could not load project data.");
                console.error(arguments)
            },
            complete: function () {
                $('.search-spinner').addClass('d-none');
                $("#" + projectContainerId).trigger('resizefilters');
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

    this.resetPageOffSet = function() {
        offset = 0;
    };

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
        pageWindow.filterViewModel.switchOffSearch(true);

        $('#pt-search').val('');
        if (spatialFilter && isMapFilterVisible()) {
            spatialFilter.resetMap();
            clearMapFilter = false;
        } else {
            clearMapFilter = true;
        }

        geoSearch = {};
        pageWindow.isGeoSearchEnabled(false);

        // clear the checkbox BEFORE clearing facets
        pageWindow.filterViewModel.nationwideProjectCheckbox(false);
        // Clear facets
        pageWindow.filterViewModel.selectedFacets.removeAll();
        pageWindow.filterViewModel.origSelectedFacet.removeAll();
        pageWindow.filterViewModel.redefineFacet(false);
        // Re-enable and perform a single fresh search
        pageWindow.filterViewModel.switchOffSearch(false);
        self.resetPageOffSet();
        self.doSearch();
    };

    /** display the current size of the filtered list **/
    this.updateTotal = function () {
        // $('#pt-resultsReturned').html("Found <strong>" + total + "</strong> " + (total == 1 ? 'project.' : 'projects.'));
        $('#pt-resultsReturned').html(this.paginationInfo());
    };

    this.paginationInfo = function () {
        if (total > 0) {
            var start = parseInt(offset) + 1;
            var end = Math.min(total, start + pageWindow.pagination.resultsPerPage() - 1);
            var message = fcConfig.paginationMessage || 'Showing XXXX to YYYY of ZZZZ projects';
            return message.replace('XXXX', start).replace('YYYY', end).replace('ZZZZ', total);
        } else {
            return "No projects found."
        }
    };

    this.augmentVM = function (vm) {
        var x;
        vm.transients.searchText = (vm.name() + ' ' + vm.aim() + ' ' + vm.description() + ' ' + vm.keywords() + ' ' + vm.transients.scienceTypeDisplay() + ' ' + vm.transients.locality + ' ' + vm.transients.state + ' ' + vm.organisationName()).toLowerCase();
        vm.transients.indexUrl = vm.isMERIT() ? fcConfig.meritProjectUrl + '/' + vm.transients.projectId : fcConfig.projectIndexBaseUrl + vm.transients.projectId;
        vm.transients.orgUrl = vm.organisationId() && (fcConfig.organisationBaseUrl + vm.organisationId());
        vm.transients.imageUrl = fcConfig.meritProjectLogo && vm.isMERIT() ? fcConfig.meritProjectLogo : vm.fullSizeImageUrl();
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
        savedViewMode = savedViewMode || "grid-tab"; //Default is the new map-popup view
        $('.project-finder-tab a#'+savedViewMode).tab('show');

        // Filters view
        var showPanel = amplify.store('pt-filter');
        // hide filter since by default it is shown
        !showPanel && $('.project-finder-filters-expander').trigger('click');
    };


    /**
     * creates the map and plots the points on map
     * @param features
     */
    self.doMapSearch = function (projects){
        var overlayLayersMapControlConfig = Biocollect.MapUtilities.getOverlayConfig();
        var baseLayerOverlayConfig = Biocollect.MapUtilities.getBaseLayerAndOverlayFromMapConfiguration(fcConfig.mapLayersConfig);
        var mapOptions = {
            autoZIndex: false,
            preserveZIndex: true,
            addLayersControlHeading: true,
            drawControl: false,
            showReset: false,
            draggableMarkers: false,
            useMyLocation: false,
            allowSearchLocationByAddress: false,
            allowSearchRegionByAddress: false,
            defaultLayersControl: true,
            trackWindowHeight: true,
            wmsLayerUrl: overlayLayersMapControlConfig.wmsLayerUrl,
            wmsFeatureUrl: overlayLayersMapControlConfig.wmsFeatureUrl,
            baseLayer: baseLayerOverlayConfig.baseLayer,
            otherLayers: baseLayerOverlayConfig.otherLayers,
            overlays: baseLayerOverlayConfig.overlays,
            overlayLayersSelectedByDefault: baseLayerOverlayConfig.overlayLayersSelectedByDefault
        };

        if(!self.pfMap){
            self.pfMap = new ALA.Map("pfMap", mapOptions);
            Biocollect.MapUtilities.intersectOverlaysAndShowOnPopup(self.pfMap);
            self.pfMap.addButton("<span class='fa fa-refresh reset-map' title='Reset zoom'></span>", self.pfMap.fitBounds, "bottomright");
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

    $(".project-finder-filters").on('shown.bs.collapse hidden.bs.collapse', function (event) {
        var active = event.target.classList.contains('show');
        amplify.store('pt-filter', active);
    });

    $(".project-finder-tab a[data-toggle='tab']").on('shown.bs.tab', function (event) {
        // var viewMode = getActiveButtonValues($("#pt-view"));
        // pageWindow.listView(viewMode[0] == "listView");
        // pageWindow.viewMode(viewMode[0])
        amplify.store('pt-view-state', event.target.id);

        // if(pageWindow.viewMode() == 'mapView') {
        //     self.pfMap.redraw()
        // }

    });

    $("#pt-aus-world").on('statechange', function(){
        var viewMode = getActiveButtonValues($("#pt-view"));
    })


    $(mapFilterSelector).on('shown.bs.modal', function () {
        initialiseMap();
        spatialFilter.getMapImpl().invalidateSize();
        clearMapFilter && spatialFilter.resetMap();
    });

    $(mapFilterSelector).on('hide.bs.modal', function () {
        geoSearchChanged();
        if (refreshSearch) {
            self.resetPageOffSet(); // pagination restarts at page 1
            self.doSearch();       //make the query
            refreshSearch = false;
        }
    });

    function isMapFilterVisible() {
        return !$(mapFilterSelector).is(":hidden");
    }

    function clearGeoSearch() {
        geoSearch = {};
        pageWindow.isGeoSearchEnabled(false);
        if(isMapFilterVisible()) {
            spatialFilter.resetMap();
            clearMapFilter = false;
        } else {
            clearMapFilter = true;
        }
    }

    $("#clearFilterByRegionButton").on('click',clearGeoSearch);


    $('#pt-search-link').on('click',function () {
        self.setTextSearchSettings();
        self.resetPageOffSet();
        self.doSearch();
    });

    $('#pt-search').keypress(function (event) {
        if (event.which == 13) {
            event.preventDefault();
            self.setTextSearchSettings();
            self.doSearch();
        }
    });

    $('#pt-reset').on('click',function () {
        self.reset()
    });

    $("#btnShowTileView").on('click',function () {
        pageWindow.showTileView();

    });

    $("#btnShowListView").on('click',function () {
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

    function constructHash() {
        var params = self.getParams();

        var hash = [];
        for (var param in params) {
            if (params.hasOwnProperty(param) && params[param] && params[param] != '') {
                if ((param != 'geoSearchJSON') && (param != 'fq') && (param != 'queryList')) {
                    hash.push(param + "=" + params[param]);
                }
            }
        }

        if (!_.isEmpty(geoSearch)) {
            hash.push('geoSearch=' + LZString.compressToBase64(JSON.stringify(geoSearch)));
        }

        if (!_.isEmpty(params.fq)) {
            params.fq.forEach(function (filter) {
                hash.push('fq=' + encodeURIComponent (filter))
            })
        }

        if (!_.isEmpty(params.queryList)) {
            params.queryList.forEach(function (filter) {
                hash.push('queryList=' + encodeURIComponent (filter))
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
        pageWindow.filterViewModel.setFilterQuery(params.queryList);
        offset = Number.parseInt(params.offset || offset);
        selectedProjectId = params.projectId;

        pageWindow.sortBy( params.sort || 'dateCreatedSort');
        pageWindow.pagination.resultsPerPage( Number.parseInt(params.max || '30'));
        pageWindow.isWorldWide( params.isWorldWide || 'false');

        $('#pt-search').val(params.queryText).focus();

        var excl = params.excludeNationwide;
        var excludeNationwide = (excl === 'true' || excl === true);
        pageWindow.filterViewModel.nationwideProjectCheckbox(!!excludeNationwide);

        pageWindow.filterViewModel.switchOffSearch(false);
    }

    function updateHash() {
        var hash = constructHash();
        window.location.hash = hash;
    }

    function setGeoSearch(geoSearchHash) {
        if (geoSearchHash && typeof geoSearchHash !== 'undefined') {
            var geoSearchString = LZString.decompressFromBase64(geoSearchHash);
            geoSearch = JSON.parse(geoSearchString);
            // Creating a clone since ALA.MapUtils.getStandardGeoJSONForCircleGeometry modifies the geoSearch object
            // making subsequent searches to malfunction. This only happens for Point GeoJSON type.
            var geoSearchCloned = JSON.parse(geoSearchString);

            var geoJson = ALA.MapUtils.wrapGeometryInGeoJSONFeatureCol(geoSearchCloned);
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

            spatialFilter && spatialFilter.setGeoJSON(geoJson);
            pageWindow.isGeoSearchEnabled(true);
        }
    }

    function toBoolean(str) {
        return str && str.toLowerCase() === 'true';
    }

    function geoSearchChanged() {
        readUpdatedGeographicFilters();
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
            if (refreshSearch) {
                pageWindow.isGeoSearchEnabled(true);
            }
        } else if (geoJSON.features.length == 0 && geoSearch) {
            refreshSearch = true;
            geoSearch = {};
            pageWindow.isGeoSearchEnabled(false);
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
        $('.projects-from-select').hide();
    }

    $(document).on("shown.bs.tab", pfMapId, function () {
        if (self.pfMap) {
            self.pfMap.getMapImpl().invalidateSize();
            self.pfMap.fitBounds();
        }
    });

    initialiseMap();
    parseHash();
    self.doSearch();
    self.initViewMode();
}

