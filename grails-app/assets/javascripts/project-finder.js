/**
 * Created by Temi Varghese on 22/10/15.
 */
//= require lz-string-1.4.4/lz-string.min.js
//= require button-toggle-events.js
//= require facets.js
// leaflet
//= require leaflet-manifest.js
//= require_self
// responsive table
//= require responsive-table-stacked/stacked.js

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
    var selectedProjectId = "";
    var spatialFilter = null;

    var geoSearch = {};

    var refreshSearch = false;
    var enablePartialSearch = config.enablePartialSearch || false;

    var filterQuery, lazyLoad;
    var GENERAL_LAYER = '_general',
        INFO_LAYER = '_info',
        INDICES_LAYER = '_indices',
        INFO_LAYER_DEFAULT = 'default',
        STATE_POINT = 'point',
        STATE_POLYGON = 'polygon',
        STATE_HEATMAP = 'heatmap',
        STATE_CLUSTER = 'cluster',
        STATE_POINT_INDEX = 'point+index',
        STATE_POLYGON_INDEX = 'polygon+index',
        STATE_HEATMAP_INDEX = 'heatmap+index',
        STATE_CLUSTER_INDEX = 'cluster+index',
        MAX_FEATURE_COUNT = 1000,
        MAP_VIEW = 'mapView',
        DATA_TYPE = 'project';

    var projectWMSLayer,
        lastMouseClickEvent,
        pointStyleName = 'point_circle_project',
        heatmapStyleName = 'heatmap',
        clusterStyleName = 'cluster_project',
        polygonStyleName = 'polygon_sites_project',
        lineStyleName = 'line_sites',
        lineSelectorStyleName = 'line_selector',
        shapeRenderingLayers = [pointStyleName, polygonStyleName, lineStyleName],
        selectedColourByIndex = '',
        selectedLayerID = polygonStyleName,
        layerNamesLookupRequests = {},
        colourByControlId = "colour-by-select",
        sizeControlId = "size-slider",
        activityDisplayStyleId = "activity-display-style",
        colourByLabel = "Colour by:",
        filterByLabel = "Filter by:",
        opacity = 0.1,
        selectedStyle,
        selectedLayerName,
        selectionControl,
        selectedSize = 5,
        legendControl,
        infoPanelControl,
        mapDisplays = [],
        lookupProjectOnClick = config.lookupProjectOnClick || true,
        lookupOverlaysOnClick = config.lookupOverlaysOnClick || true,
        colourByBlackList = ['status'];

    layerNamesLookupRequests[GENERAL_LAYER] =  undefined;
    layerNamesLookupRequests[INFO_LAYER] = {};
    layerNamesLookupRequests[INDICES_LAYER] = {};

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
        this.showPagination = ko.observable(true);
        self.columns = this.columns
        this.doSearch = function () {

            self.doSearch();
        }
        this.resetPageOffSet = function () {
            self.resetPageOffSet();
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
            var overlayLayersMapControlConfig = Biocollect.MapUtilities.getOverlayConfig();
            var baseLayersAndOverlays = Biocollect.MapUtilities.getBaseLayerAndOverlayFromMapConfiguration(fcConfig.mapLayersConfig);
            spatialFilter = new ALA.Map("mapFilter", {
                autoZIndex: false,
                preserveZIndex: true,
                addLayersControlHeading: true,
                allowSearchRegionByAddress: false,
                wmsLayerUrl: overlayLayersMapControlConfig.wmsLayerUrl,
                wmsFeatureUrl: overlayLayersMapControlConfig.wmsFeatureUrl,
                myLocationControlTitle: "Within " + fcConfig.defaultSearchRadiusMetersForPoint + " of my location",
                baseLayer: baseLayersAndOverlays.baseLayer,
                otherLayers: baseLayersAndOverlays.otherLayers,
                overlays: baseLayersAndOverlays.overlays,
                overlayLayersSelectedByDefault: baseLayersAndOverlays.overlayLayersSelectedByDefault
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
        var organisationName = fcConfig.organisationName || "";
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

        var queryString = '';

      //  if (pageWindow.filterViewModel.redefineFacet()) {

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
                fq.push(facet.getQueryText())
            });

      /*  } else {
            pageWindow.filterViewModel.selectedFacets().forEach(function (facet) {
                fq.push(facet.getQueryText())
            });
        }*/

        var query = this.getQuery(true);
        if (query.length > 0) {
            query = query + ((queryString.length > 0)? ' AND ' + queryString: "");
        } else {
            query = queryString;
        }

        var queryList = [];

        var selectedFacetList = pageWindow.filterViewModel.selectedFacets();

        selectedFacetList.forEach(function (facet) {
            queryList.push(facet.getQueryText())
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
            q: query,
            queryList: queryList,
            queryText: this.getQuery(true)
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
                if (total == 0 && pageWindow.filterViewModel.redefineFacet() && pageWindow.filterViewModel.origSelectedFacet().length > 0) {
                    bootbox.alert ("There are no projects that fulfil the filter condition. Please click 'Clear all' to redefine the search criteria. ")
                }
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
        checkButton($('#pt-sort'), 'nameSort');
        checkButton($('#pt-per-page'), '20');
        $('#pt-search').val('');
        if (spatialFilter) {
            spatialFilter.resetMap();
        }
        geoSearch = {};
        refreshGeofilterButtons();
        pageWindow.filterViewModel.selectedFacets.removeAll();
        pageWindow.filterViewModel.origSelectedFacet.removeAll();
        pageWindow.filterViewModel.redefineFacet(false);
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
            var start = parseInt(offset) + 1;
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
            overlayLayersSelectedByDefault: baseLayerOverlayConfig.overlayLayersSelectedByDefault,
            loadingControlOptions: {
                position: 'topleft'
            },
            overlayControlPosition: "topleft"
        };

        if(!self.pfMap){
            alaMap = self.pfMap = new ALA.Map("pfMap", mapOptions);
            lookupOverlaysOnClick && Biocollect.MapUtilities.intersectOverlaysAndShowOnPopup(self.pfMap,showIntersectsOnPopup);
            self.pfMap.addButton("<span class='fa fa-refresh reset-map' title='Reset zoom'></span>", self.pfMap.fitBounds, "bottomright");

            selectionControl = new L.Control.HorizontalMultiInput({
                id: 'display-style-colour-by-size-control',
                position: 'topright',
                items:  [{
                    type: "select",
                    id: activityDisplayStyleId,
                    name: activityDisplayStyleId + "-name",
                    label: "Display:",
                    values: mapDisplays,
                    helpText: fcConfig.mapDisplayHelpText
                },{
                    type: "select",
                    id: colourByControlId,
                    name: colourByControlId + "-name",
                    label: getLabelForMapDisplay(),
                    values: [],
                    helpText: getTooltipForMapDisplay
                }, {
                    type: "slider",
                    id: sizeControlId,
                    label: "Size:",
                    options: {
                        min: 1,
                        max: 9,
                        step: 1,
                        value: selectedSize,
                        length: '100px'
                    }
                }]
            });
            self.pfMap.addControl(selectionControl);

            selectionControl.on('change', function (data) {
                switch (data.item.id) {
                    case activityDisplayStyleId:
                        changeProjectDisplayStyle(data.value);
                        break;
                    case colourByControlId:
                        changeColourByIndex(data.value);
                        break;
                    case sizeControlId:
                        changeSize(data.value);
                        break;
                }
            });

            // Control - legend
            legendControl = new L.Control.LegendImage({collapse: true, position: "topright"});
            self.pfMap.addControl(legendControl);

            // Control - display help text
            infoPanelControl = new L.Control.InfoPanel({
                content: getHelpText(),
                collapse: false,
                title: "Help"
            });
            self.pfMap.addControl(infoPanelControl);

            lookupProjectOnClick && alaMap.registerListener('click', mapClickEventHandler);
            alaMap.registerListener("zoomend dragend", getHeatmap);
        }

        // clear colour by index
        selectedColourByIndex = '';

        var typeAndIndices = getLayerTypeAndIndices();
        getLayerNameRequest(typeAndIndices.type, typeAndIndices.indices).done(function (data) {
            var layerName = data.layerName;
            if (layerName) {
                console.log('Setting layerName - ' + layerName);
                selectedLayerName = layerName;
                refreshMapComponents();
            }
        });

        var options = pageWindow.filterViewModel.getColourByFields();
        options = sanitizeColourByList(options);
        options = addEmptyOption(options);
        selectionControl.setSelectOptions(colourByControlId, options);
        legendControl.clearLegend();
    };

    function initMapOverlaysWithLayer (noRedraw) {
        noRedraw = noRedraw || false;
        projectWMSLayer && self.pfMap.removeOverlayLayer(projectWMSLayer);
        switch (selectedLayerID) {
            case heatmapStyleName:
                projectWMSLayer = L.geoJson(null, {
                    style: function (feature) {
                        return {
                            stroke: false,
                            fill: true,
                            fillColor: feature.properties.colour,
                            fillOpacity: 0.7
                        };
                    },
                    onEachFeature: function (feature, layer) {
                        layer.bindPopup(String(feature.properties.count));
                    }
                });

                getHeatmap();
                break;
            default:
                var params = self.getParams(),
                    queryString = flattenArrayParameters(params),
                    url = fcConfig.wmsProjectURL.indexOf('?') > -1 ? fcConfig.wmsProjectURL + '&' + queryString : fcConfig.wmsProjectURL + '?' + queryString;

                projectWMSLayer = L.nonTiledLayer.wms (url, {
                    format: 'image/png',
                    transparent: true,
                    maxZoom: 21
                });
                params.dataType = DATA_TYPE;

                projectWMSLayer.setParams(params, noRedraw);
                break;
        }

        return projectWMSLayer;
    }

    function getHeatmap() {
        if (selectedLayerID === heatmapStyleName) {
            projectWMSLayer.fire('loading');
            var url = fcConfig.heatmapURL,
                boundingBoxGeoJSON = getBoundingBoxGeoJSON(),
                payload = self.getParams();

            payload.geoSearchJSON = JSON.stringify(boundingBoxGeoJSON);
            payload.dataType = DATA_TYPE;
            if (selectedColourByIndex) {
                payload.exists = selectedColourByIndex;
            }

            $.ajax({
                url: url,
                data: payload,
                success: function (data) {
                    if (!data.error) {
                        if (selectedLayerID === heatmapStyleName) {
                            projectWMSLayer.clearLayers();
                            projectWMSLayer.addData && projectWMSLayer.addData(data);
                            updateLegendFromGeoJSON(data);
                        }
                    }

                    projectWMSLayer && projectWMSLayer.fire('load');
                },
                fail: function () {
                    projectWMSLayer && projectWMSLayer.fire('load');
                }
            });
        }
    }

    function getLayerTypeAndIndices () {
        var result = {
            type: INDICES_LAYER,
            indices: selectedColourByIndex
        };

        if (!selectedColourByIndex) {
            result.type = GENERAL_LAYER;
            result.indices = undefined;
        }

        return result;
    }

    function getLayerNameRequest(type, indices) {
        var request, indicesConcat, styleCode;

        switch (type) {
            case GENERAL_LAYER:
                request = layerNamesLookupRequests[type];
                break;
            case INFO_LAYER:
                if (!indices) {
                    indices = [INFO_LAYER_DEFAULT];
                }
            case INDICES_LAYER:
                if (indices === undefined) {
                    return
                }
                else if (typeof indices === 'string') {
                    indices = [indices]
                }

                indicesConcat = indices.join(',');
                styleCode = getStyleNameForIndicesLayer();
                if (!styleCode) {
                    styleCode = indicesConcat;
                }

                request = layerNamesLookupRequests[type][styleCode];
                break;
        }

        if (!request) {
            if (!fcConfig.getLayerNameURL){
                console.warn("Property fcConfig.getLayerNameURL must be provided");
                return ;
            }

            var request = $.get({
                url: fcConfig.getLayerNameURL,
                data: {
                    dataType: DATA_TYPE,
                    type: type,
                    indices: indicesConcat || ''
                }
            }).fail(function () {
                setLayerNameRequest(type, styleCode, undefined);
            });

            setLayerNameRequest(type, styleCode, request);
        }

        return request;
    };

    function setLayerNameRequest(type, styleCode, request) {
        var cache = layerNamesLookupRequests[type];
        if (styleCode) {
            cache = cache[styleCode];
        }

        cache = request;
    };

    function getStyleNameForIndicesLayer() {
        if (canMapDisplayBeColoured(selectedLayerID)) {
            return selectedLayerID+selectedColourByIndex;
        }
    };

    function canMapDisplayBeColoured (index) {
        return shapeRenderingLayers.indexOf(index) >= 0;
    };

    function createStyleForMapDisplayAndColourByIndex(mapDisplay, index) {
        var terms = pageWindow.filterViewModel.getTermsForFacet(index);
        if (canMapDisplayBeColoured(mapDisplay)) {
            terms.style = mapDisplay;
            terms.dataType = "project";
        }

        return createStyleFromTerms(terms).done(function (data) {
            selectedStyle = data.name;
            pageWindow.filterViewModel.setStyleName(index, selectedStyle);
            refreshMapComponents();
        });
    };

    function createStyleFromTerms(terms) {
        terms.dataType = DATA_TYPE;

        return $.ajax({
            url: fcConfig.createStyleURL,
            method: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(terms)
        });
    };

    function getLabelForMapDisplay() {
        if (shapeRenderingLayers.indexOf(selectedLayerID) >= 0) {
            return colourByLabel;
        } else {
            return filterByLabel;
        }
    }

    function getTooltipForMapDisplay() {
        if (shapeRenderingLayers.indexOf(selectedLayerID) >= 0) {
            return fcConfig.mapDisplayColourByHelpText;
        } else {
            return fcConfig.mapDisplayFilterByHelpText;
        }
    }
    
    function getHelpText() {
        switch (selectedLayerID) {
            case heatmapStyleName:
                return fcConfig.heatmapHelpText;
            case clusterStyleName:
                return fcConfig.clusterHelpText;
            case polygonStyleName:
                return fcConfig.polygonHelpText;
            case pointStyleName:
                return fcConfig.pointHelpText;
        }
    }

    function changeProjectDisplayStyle (value) {
        var currentSettings = getLayerTypeAndIndices(),
            layerNameRequest = getLayerNameRequest(currentSettings.type, currentSettings.indices);

        selectedLayerID = value;
        setDefaultSizeForStyle(selectedLayerID);
        layerNameRequest && layerNameRequest.done(function (data) {
            if (data.layerName) {
                selectedLayerName = data.layerName;
                if (selectedColourByIndex) {
                    createStyleForMapDisplayAndColourByIndex(selectedLayerID, selectedColourByIndex);
                } else {
                    refreshMapComponents();
                }
            }
        });

        setSelectionControlState();
        infoPanelControl.setContent(getHelpText());
    };

    function changeColourByIndex(index) {
        var typeAndIndices;

        selectedColourByIndex = index;
        typeAndIndices = getLayerTypeAndIndices();
        getLayerNameRequest(typeAndIndices.type, typeAndIndices.indices).done(function (data) {
            var layerName = data.layerName;
            if (layerName) {
                console.log('Updating layerName - ' + layerName);
                selectedLayerName = layerName;
                if (index) {
                    createStyleForMapDisplayAndColourByIndex(selectedLayerID, index);
                } else {
                    selectedStyle = '';
                    refreshMapComponents();
                }
            }
        });
    };

    function changeSize(size) {
        if (selectedSize != size) {
            selectedSize = size;
            refreshMapComponents();
        }
    }

    function setDefaultSizeForStyle (style) {
        if (canMapDisplayBeColoured(style)) {
            var settings = self.getSettingsForStyle(style),
                size = (settings && settings.size) || 1;

            // to prevent map refresh when slide handler is called.
            selectedSize = size;
            selectionControl.setSize('slider', 'size-slider', size);
        }
    };

    self.getSettingsForStyle = function (style) {
        if (mapDisplays) {
            var displays = $.grep(mapDisplays, function(item){
                return item.key == style;
            });

            if (displays.length) {
                return displays[0];
            }
        }
    }

    function mapClickEventHandler(event) {
        if (selectedLayerID !== heatmapStyleName) {
            var map = this;
            getLayerNameRequest(INFO_LAYER, selectedColourByIndex).done(function(data){
                if(data.layerName) {
                    var size = map.getSize(),
                        // this crs is used to show layer added to map
                        crs = map.options.crs,
                        // these are the SouthWest and NorthEast points
                        // projected from LatLng into used crs
                        sw = crs.project(map.getBounds().getSouthWest()),
                        ne = crs.project(map.getBounds().getNorthEast()),
                        styleName = projectWMSLayer.wmsParams.styles == lineStyleName ? lineSelectorStyleName : projectWMSLayer.wmsParams.styles,
                        params = {
                            request: 'GetFeatureInfo',
                            service: 'WMS',
                            srs: crs.code,
                            version: projectWMSLayer.wmsParams.version,
                            layers: data.layerName,
                            query_layers: data.layerName,
                            styles: styleName,
                            bbox:  sw.x + ',' + sw.y + ',' + ne.x + ',' + ne.y,
                            height: size.y,
                            width: size.x,
                            feature_count: MAX_FEATURE_COUNT,
                            info_format: 'application/json',
                            dataType: DATA_TYPE
                        };

                    if (projectWMSLayer.wmsParams.cql_filter) {
                        params.cql_filter = projectWMSLayer.wmsParams.cql_filter;
                    }

                    params[params.version === '1.3.0' ? 'i' : 'x'] = Math.round(event.containerPoint.x);
                    params[params.version === '1.3.0' ? 'j' : 'y'] = Math.round(event.containerPoint.y);
                    params = $.extend(params, self.getParams());
                    var url = projectWMSLayer._wmsUrl + L.Util.getParamString(params, projectWMSLayer._wmsUrl, false);
                    // show loading GIF
                    projectWMSLayer.fire && projectWMSLayer.fire('loading');
                    $.get(url , function (data) {
                        var features = data.features;

                        if (features && features.length) {
                            var ePopup = document.getElementById('template-map-popup-record');
                            if (
                                !ePopup
                                || ( ePopup && lastMouseClickEvent
                                && (lastMouseClickEvent.containerPoint.x != event.containerPoint.x)
                                && (lastMouseClickEvent.containerPoint.y != event.containerPoint.y))
                            ) {
                                L.popup({
                                    maxWidth: 400,
                                    minWidth: 200
                                })
                                    .setLatLng(event.latlng)
                                    .setContent('<div id="template-map-popup-record" style="width: 400px; height: auto" data-bind="template: { name: \'script-project-popup-template\' }"></div>')
                                    .openOn(self.pfMap.getMapImpl());

                                ko.applyBindings(self.popupVM, document.getElementById('template-map-popup-record'));
                            }

                            self.popupVM.clearProjects();
                            self.popupVM.projects(features);
                            lastMouseClickEvent = event;
                        }
                    }).done(function() {
                        // remove loading GIF
                        projectWMSLayer.fire && projectWMSLayer.fire('load');
                    });
                }
            })
        }
    };

    function showIntersectsOnPopup(intersects, raw, event) {
        if (intersects && intersects.length) {
            if (!document.getElementById('template-map-popup-project')
                && lastMouseClickEvent
                && (lastMouseClickEvent.containerPoint.x != event.containerPoint.x)
                && (lastMouseClickEvent.containerPoint.y != event.containerPoint.y)) {
                L.popup({
                    maxWidth: 400,
                    minWidth: 200
                })
                    .setLatLng(event.latlng)
                    .setContent('<div id="template-map-popup-project" style="width: 400px; height: auto" data-bind="template: { name: \'script-project-popup-template\' }"></div>')
                    .openOn(self.pfMap.getMapImpl());
            }

            self.popupVM.intersects(intersects);
            ko.applyBindings(self.popupVM, document.getElementById('template-map-popup-project'));
            lastMouseClickEvent = event;
            projectWMSLayer.fire && projectWMSLayer.fire('load');
        }
    }

    /**
     * Update map depending on colour by selection and rendering (point, heatmap etc.) selection.
     */
    function refreshMapComponents () {
        var state = self.getCurrentState(),
            params = self.getParametersForState(state),
            legendURL;

        initMapOverlaysWithLayer(true);
        projectWMSLayer && projectWMSLayer.setParams && projectWMSLayer.setParams(params);
        self.pfMap.addOverlayLayer(projectWMSLayer, 'Projects', true);
        legendURL = Biocollect.MapUtilities.getLegendURL(projectWMSLayer, params.styles);
        !legendURL && legendControl.clearLegend();
        legendURL && legendControl.updateLegend(legendURL, getLegendTitle());
    }

    self.loadMapDisplays = function (displays) {
        displays.forEach(function (display) {
            display.selected = display.isDefault == display.key
            if (display.selected) {
                selectedLayerID = display.key;
                selectedSize = display.size || selectedSize;
            }

            mapDisplays.push(display);
        });

        if (!selectedLayerID) {
            selectedLayerID = mapDisplays[0].key;
            selectedSize = mapDisplays[0].size || selectedSize;
        }
    }

    self.getCurrentState = function() {
        switch (selectedLayerID) {
            case clusterStyleName:
                if (selectedColourByIndex) {
                    return STATE_CLUSTER_INDEX;
                }
                else {
                    return STATE_CLUSTER;
                }

                break;
            case heatmapStyleName:
                if (selectedColourByIndex) {
                    return STATE_HEATMAP_INDEX;
                }
                else {
                    return STATE_HEATMAP;
                }

                break;
            case pointStyleName:
                if (selectedColourByIndex) {
                    return STATE_POINT_INDEX;
                }
                else {
                    return STATE_POINT;
                }

                break;
            case polygonStyleName:
                if (selectedColourByIndex) {
                    return STATE_POLYGON_INDEX;
                }
                else {
                    return STATE_POLYGON;
                }

                break;
        }
    }

    self.getParametersForState = function(state) {
        var params = {};
        state = state || self.getCurrentState();
        addCommonParameters(params);

        switch (state) {
            case STATE_CLUSTER:
                params.styles = clusterStyleName;
                break;
            case STATE_CLUSTER_INDEX:
                params.styles = clusterStyleName;
                addCQLParameter(params);
                break;
            case STATE_POINT:
                params.styles = pointStyleName;
                params.env = "size:" + selectedSize + ";";
                break;
            case STATE_POINT_INDEX:
                params.styles = selectedStyle;
                params.env = "size:" + selectedSize + ";";
                addCQLParameter(params);
                break;
            case STATE_POLYGON:
                params.styles = polygonStyleName;
                params.env = "size:" + selectedSize + ";";
                break;
            case STATE_POLYGON_INDEX:
                params.styles = selectedStyle;
                params.env = "size:" + selectedSize + ";";
                addCQLParameter(params);
                break;
            case STATE_HEATMAP:
                params.styles = heatmapStyleName;
                break;
            case STATE_HEATMAP_INDEX:
                params.styles = heatmapStyleName;
                addWeightParameter(params);
                addCQLParameter(params);
                break;
        }

        if (opacity) {
            params.env = params.env || "";
            params.env += "opacity:" + opacity + ";";
        }

        return params;
    }

    function addCommonParameters (params) {
        params = params || {};
        params.layers = selectedLayerName;
        return params;
    }

    function addCQLParameter(params) {
        params = params || {};
        params.cql_filter = selectedColourByIndex + " IS NOT NULL";
        return params;
    }

    function addWeightParameter (params) {
        params = params || {};
        params.env = "weight:" + selectedColourByIndex + ";";
        return params;
    }

    function setSelectionControlState() {
        setLabelForMapDisplay();
        enableDisableSizeControl();
    }

    function setLabelForMapDisplay() {
        selectionControl.changeLabel(getLabelForMapDisplay(), colourByControlId);
    };

    function enableDisableSizeControl () {
        var item = {
            type: 'slider',
            id : sizeControlId
        };

        if (shapeRenderingLayers.indexOf(selectedLayerID) >= 0) {
            selectionControl.disableItem(false, item);
        } else {
            selectionControl.disableItem(true, item);
        }
    }

    function getBoundingBoxGeoJSON() {
        var map = self.pfMap.getMapImpl(),
            sw = map.getBounds().getSouthWest(),
            ne = map.getBounds().getNorthEast(),
            bbox = {
                type: "Polygon",
                coordinates: [[[sw.lng, sw.lat], [ne.lng, sw.lat], [ne.lng, ne.lat], [sw.lng, ne.lat], [sw.lng, sw.lat]]]
            };

        return bbox;
    }

    function getLegendTitle() {
        switch (selectedLayerID) {
            case clusterStyleName:
                return fcConfig.clusterLegendTitle;
            case heatmapStyleName:
                return fcConfig.heatmapLegendTitle;
            case pointStyleName:
                return fcConfig.pointLegendTitle;
            case polygonStyleName:
                return fcConfig.polygonLegendTitle;
        }
    }

    function getLegendFromGeoJSON (geoJSON) {
        var legendMapping = {},
            legends = [];
        switch (geoJSON.type) {
            case "FeatureCollection":
                geoJSON.features && geoJSON.features.forEach(function (feature) {
                    if (feature.properties) {
                        legendMapping[feature.properties.label] = feature.properties;
                    }
                });

                for(var label in legendMapping) {
                    legends.push(legendMapping[label]);
                }

                legends.sort(function (a, b) {
                    return b.max > a.max;
                });
                break;
        }

        return legends;
    }

    function updateLegendFromGeoJSON (geoJSON) {
        var legend = getLegendFromGeoJSON(geoJSON);
        var svg = getSVGForLegend(legend);
        updateLegendWithSVG(svg);
    }

    function getSVGForLegend(legend) {
        var svg = Snap("100%", "100%"),
            y = 0,
            yLineHeight = 20,
            padding = 10,
            baseline = 10;

        legend.forEach(function (item) {
            var shape = svg.rect(0 + padding, y + padding, 10, 10);
            shape.attr({fill: item.colour});
            var label = svg.text(20 + padding , y + baseline + padding, item.label);
            y += yLineHeight;
        });

        svg.attr({height:y + padding});

        var text = svg.outerSVG();
        // snap attaches svg to document. need to remove it.
        svg.remove();
        return text;

    }

    function updateLegendWithSVG(svgText) {
        var prefix = 'data:image/svg+xml,',
            svgText = encodeURIComponent(svgText),
            dataURI = prefix + svgText;

        legendControl && legendControl.updateLegend(dataURI, getLegendTitle());
    }

    function addEmptyOption(values) {
        values = values || [];
        values.unshift({key: ""});
        return values;
    }

    function sanitizeColourByList (colourBy) {
        var newList = [],
            blackList = colourByBlackList;

        if (colourBy) {
            colourBy.forEach(function (item) {
                if (blackList.indexOf(item.key) == -1) {
                    newList.push(item);
                }
            })
        }

        return newList;
    }

    /**
     * Leaflet WMS layer does not encoded array correctly in GET request.
     * This function flattens those parameters and remove it from parameter object.
     * @param params
     * @returns {string}
     */
    function flattenArrayParameters(params) {
        var output = [];
        for(var p in params) {
            if (params[p] instanceof Array) {
                for (var index in params[p]) {
                    output.push(encodeURIComponent(p) + "=" + encodeURIComponent(params[p][index]));
                }

                delete params[p];
            }
        }

        return output.join('&');
    }

    function PopupViewModel(data) {
        var self = this;

        data = data || {};
        self.intersects = ko.observableArray(data.intersects || []);
        self.projects = ko.observableArray(data.project||[]);
        self.index = ko.observable(0);

        self.clearIntersects = function () {
            self.intersects.removeAll();
        }

        self.clearProjects = function () {
            self.projects.removeAll();
            self.index(0);
        }

    }
    /** end of map related functions **/

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

        showHidePagination();
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
      //  pageWindow.filterViewModel.setFilterQuery(params.fq);
        pageWindow.filterViewModel.setFilterQuery(params.queryList);
        offset = params.offset || offset;
        selectedProjectId = params.projectId || "";

        if (fcConfig.associatedPrograms) {
            $.each(fcConfig.associatedPrograms, function (i, program) {
                toggleButton($('#pt-search-program-' + program.name.replace(/ /g, '-')), toBoolean(params["isProject" + program.name]));
            });
        }

        checkButton($("#pt-sort"), params.sort || 'dateCreatedSort');
        checkButton($("#pt-per-page"), params.max || '20');
        checkButton($("#pt-aus-world"), params.isWorldWide || 'false');
        
        $('#pt-search').val(params.queryText).focus();
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

    /**
     * Map show all projects. Therefore, hide pagination buttons and text (Showing 10 of xx projects).
     */
    function showHidePagination() {
        if(pageWindow && (pageWindow.viewMode() === MAP_VIEW)) {
            pageWindow.showPagination(false);
        } else {
            pageWindow.showPagination(true);
        }
    }


    if (fcConfig.hideWorldWideBtn) {
        $('#pt-aus-world').hide();
        $('#pt-aus-world-block').hide();
    }

    self.popupVM = new PopupViewModel();
    self.loadMapDisplays(fcConfig.projectMapDisplays);
    parseHash();
    self.doSearch();
    self.initViewMode();
    showHidePagination();
}

