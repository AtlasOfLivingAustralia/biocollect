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

    /* The map must only be initialised once, so keep track of when that has happened */
    var mapInitialised = false;
    var spatialFilter = null;

    var geoSearch = {};

    var refreshSearch = false;

    var filterQuery

    this.availableProjectTypes = new ProjectViewModel({}, false, []).transients.availableProjectTypes;

    this.sortKeys = [
        {name: 'Name', value: 'nameSort'},
        {name: 'Relevance', value: '_score'},
        {name: 'Organisation Name', value: 'organisationSort'},
        {name: 'Status', value: 'status'}
    ];

    /* window into current page */
    function PageVM() {
        this.self = this;
        this.pageProjects = ko.observableArray();
        this.facets = ko.observableArray();
        this.selectedFacets = ko.observableArray();
        this.columns = ko.observable(2);
        self.columns = this.columns;

        this.availableProjectTypes = ko.observableArray(self.availableProjectTypes);
        this.projectTypes = ko.observable(['citizenScience', 'works', 'survey', 'merit']);
        this.sortKeys = ko.observableArray(self.sortKeys);
        this.download = function (obj, e) {
            var params = $.param(self.getParams(), true);
            var href = $(e.target).attr('href');
            var domain = href.slice(0, href.indexOf('?'));
            $(e.target).attr('href', domain + '?' + 'download=true&' + params);
            return true;
        }

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
        };

        $( window ).resize(function () {
            self.resizeGrid();
        });

        self.resizeGrid();

        this.listView = ko.observable(true);

        /**
         * this function is used to tell project/index or citizenscience page that the traffic is coming from
         * project finder page. This flag is used to decide if about page of the project should be shown.
         * @returns {boolean}
         */
        this.setTrafficFromProjectFinderFlag = function(){
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
    }

    self.addToRefineList = function (term) {
        pageWindow.selectedFacets.push(term)
    }

    self.removeFromRefineList = function (term) {
        var facets = pageWindow.selectedFacets()
        var remove = []
        facets.forEach(function (item) {
            if((item.facet.name() == term.facet.name()) && item.term() == term.term()){
                remove.push(item)
            }
        })

        pageWindow.selectedFacets.removeAll(remove)
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
        $("html, body").animate({
            scrollTop: $(selector).offset().top
        })
    }

    pageWindow = new PageVM();
    ko.applyBindings(pageWindow, document.getElementById('wrapper'));

    this.getParams = function () {
        var fq = [];
        var isSuitableForChildren = isButtonChecked($('#pt-search-children'));
        var isDIY = isButtonChecked($('#pt-search-diy'));
        var status = getActiveButtonValues($('#pt-status')); // active check field status
        var hasParticipantCost = isButtonChecked($('#pt-search-noCost')); // no cost
        var hasTeachingMaterials = isButtonChecked($('#pt-search-teach')); // teaching material
        var isMobile = isButtonChecked($('#pt-search-mobile')); // mobile uses links to find it out
        var isContributingDataToAla = isButtonChecked($('#pt-search-dataToAla')); // the project contributes data to the ALA
        var difficulty = getActiveButtonValues($('#pt-search-difficulty'));
        var isUserPage = fcConfig.isUserPage || false;
        var isUserWorksPage = fcConfig.isUserWorksPage || false;
        var isUserEcoSciencePage = fcConfig.isUserEcoSciencePage || false;
        var organisationName = fcConfig.organisationName;
        var isCitizenScience = fcConfig.isCitizenScience;
        var isWorks = false;
        var isBiologicalScience = false;
        var isMERIT = false;
        var isWorldWide = getActiveButtonValues($('#pt-aus-world'));
        isWorldWide = isWorldWide.length? isWorldWide[0] : false

        sortBy = getActiveButtonValues($("#pt-sort"));
        perPage = getActiveButtonValues($("#pt-per-page"));


        if (fcConfig.showAllProjects) {
            var values = getActiveButtonValues($('#pt-search-projecttype'));
            for (var i in values) {
                switch (values[i]) {
                    case 'citizenScience':
                        isCitizenScience = true;
                        break;
                    case "biologicalScience":
                        isBiologicalScience = true;
                        break;
                    case 'merit':
                        isMERIT = true;
                        break;
                    case 'works':
                        isWorks = true;
                        break;
                }
            }
        }

        pageWindow.selectedFacets().forEach(function (facet) {
            fq.push(facet.getQueryText())
        })

        var map = {
            fq: fq,
            offset: offset,
            status: status,
            isCitizenScience: isCitizenScience,
            isWorks: isWorks,
            isBiologicalScience: isBiologicalScience,
            isMERIT: isMERIT,
            isUserPage: isUserPage,
            isUserWorksPage: isUserWorksPage,
            isUserEcoSciencePage: isUserEcoSciencePage,
            hasParticipantCost: hasParticipantCost,
            isSuitableForChildren: isSuitableForChildren,
            isDIY: isDIY,
            hasTeachingMaterials: hasTeachingMaterials,
            isMobile: isMobile,
            isContributingDataToAla: isContributingDataToAla,
            difficulty: difficulty,
            organisationName: organisationName,
            max: perPage, // page size
            sort: sortBy,
            geoSearchJSON: JSON.stringify(geoSearch),
            skipDefaultFilters:fcConfig.showAllProjects,
            isWorldWide: isWorldWide,
            q: $('#pt-search').val().toLowerCase()
        };

        if (fcConfig.associatedPrograms) {
            $.each(fcConfig.associatedPrograms, function (i, program) {
                var checked = isButtonChecked($('#pt-search-program-' + program.name.replace(/ /g, '-')))
                if (checked) map["isProgram" + program.name.replace(/ /g, '-')] = true
            });
        }

        return map
    };

    /**
     * this is the function calling server with the latest query.
     */
    this.doSearch = function () {
        refreshSearch = false;
        var params = self.getParams();

        window.location.hash = constructHash();

        return $.ajax({
            url: fcConfig.projectListUrl,
            data: params,
            traditional: true,
            beforeSend: function () {
                $('#search-spinner').show();
            },
            success: function (data) {
                var projectVMs = [], facets;
                var organisation = fcConfig.organisation || [];
                total = data.total;
                $.each(data.projects, function (i, project) {
                    projectVMs.push(new ProjectViewModel(project, false, organisation));
                });
                self.pago.init(projectVMs);

                facets = data.facets
                pageWindow.facets($.map(facets, function (facet) {
                    facet.ref = self;
                    var facetVm = new FacetViewModel(facet)
                    self.setFacetTerm(facetVm)
                    return facetVm;
                }))
            },
            error: function () {
                console.error("Could not load project data.");
                console.error(arguments)
            },
            complete: function () {
                $('#search-spinner').hide();
            }
        })
    };

    this.setFacetTerm = function(facet){
        var selectedFacets = pageWindow.selectedFacets()
        selectedFacets.forEach(function (term) {
            if (facet.name() == term.facet.name()) {
                facet.setTermState (term.term())
            }
        })
    }

    this.searchAndShowFirstPage = function () {
        self.pago.firstPage();
        return true
    };

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
        $('#pt-resultsReturned').html("Found <strong>" + total + "</strong> " + (total == 1 ? 'project.' : 'projects.'));
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

        var $pago = $("<div class='pagination'></div>");
        $pago.append($ul);
        $('div#pt-navLinks').html($pago);
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
     * Results can be displayed as list or tile (grid)
     */
    this.initViewMode = function () {

        // Results view
        var savedViewMode = amplify.store('pt-view-state');
        savedViewMode = savedViewMode || "tileView"; //Default is the new tile view
        checkButton($("#pt-view"), savedViewMode);
        var viewMode = getActiveButtonValues($("#pt-view"));
        pageWindow.listView(viewMode[0] == "listView");

        // Filters view
        var showPanel = amplify.store('pt-filter');
        showPanel = showPanel === undefined ? true : showPanel;
        toggleFilterPanel(showPanel);
    };

    function toggleFilterPanel(showPanel) {
        if(showPanel) {

            $('#pt-table').removeClass('span12 no-sidebar');
            $('#pt-table').addClass('span10');
            $('#filterPanel').show();
            $('#pt-filter').addClass('active');

        } else {
            $('#filterPanel').hide();
            $('#pt-table').removeClass('span10');
            $('#pt-table').addClass('span12 no-sidebar');
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
        pageWindow.listView(viewMode[0] == "listView");
        amplify.store('pt-view-state', viewMode[0]);
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
        uncheckButton($('#pt-tags'));
        uncheckButton($('#pt-status'));
        uncheckButton($('#pt-search-difficulty'));
        checkButton($('#pt-sort'), 'dateCreatedSort');
        checkButton($('#pt-per-page'), '20');
        $('#pt-search').val('');
        if (spatialFilter) {
            spatialFilter.resetMap();
        }
        geoSearch = {};
        refreshGeofilterButtons();
        pageWindow.selectedFacets.removeAll();

        self.pago.firstPage();
        self.doSearch();

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

    $('#pt-per-page').on('statechange', self.searchAndShowFirstPage);
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
        var hash = decodeURIComponent(window.location.hash.substr(1)).split("&");

        var params = {};
        for (var i = 0; i < hash.length; i++) {
            var keyAndValue = hash[i].split("=");
            if (keyAndValue.indexOf(",") > -1) {
                params[keyAndValue[0]] = keyAndValue.split(",");
            } else {
                if(typeof params[keyAndValue[0]] == 'string'){
                    params[keyAndValue[0]] = [params[keyAndValue[0]], keyAndValue[1]]
                } if( params[keyAndValue[0]] == undefined) {
                    params[keyAndValue[0]] = keyAndValue[1]
                } else {
                    params[keyAndValue[0]].push( keyAndValue[1] );
                }
            }
        }

        toggleButton($('#pt-search-diy'), toBoolean(params.isDIY));
        setActiveButtonValues($('#pt-status'), params.status);
        toggleButton($('#pt-search-noCost'), toBoolean(params.hasParticipantCost));
        toggleButton($('#pt-search-teach'), toBoolean(params.hasTeachingMaterials));
        toggleButton($('#pt-search-mobile'), toBoolean(params.isMobile));
        toggleButton($('#pt-search-dataToAla'), toBoolean(params.isContributingDataToAla));
        toggleButton($('#pt-search-children'), toBoolean(params.isSuitableForChildren));
        setActiveButtonValues($('#pt-search-difficulty'), params.difficulty);
        setGeoSearch(params.geoSearch);
        setFilterQuery(params.fq)

        if (fcConfig.associatedPrograms) {
            $.each(fcConfig.associatedPrograms, function (i, program) {
                toggleButton($('#pt-search-program-' + program.name.replace(/ /g, '-')), toBoolean(params["isProject" + program.name]));
            });
        }

        checkButton($("#pt-sort"), params.sort || 'dateCreatedSort');
        checkButton($("#pt-per-page"), params.max || '20');
        checkButton($("#pt-aus-world"), params.isWorldWide || 'false');
        
        $('#pt-search').val(params.q).focus()
    }

    function setFilterQuery(fqs) {
        if(fqs){
            if(typeof fqs  == 'string'){
                fqs = [fqs]
            }

            fqs.forEach(function (fq) {
                var nameAndValue = fq.split(':')
                var facet = new FacetViewModel({ name: nameAndValue[0], terms: [{term:nameAndValue[1]}]})
                var term = facet.terms()[0]
                self.addToRefineList (term)
            })
        }
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



    parseHash();
    self.doSearch();
    self.initViewMode();
}

