//= require snap-svg-0.5.1/snap.svg.js
//= require self
var ActivitiesAndRecordsViewModel = function (placeHolder, view, user, ignoreMap, doNotInit, doNotStoreFacetFiltering, columnConfig) {
    var self = this;

    var features, featureType = 'record', alaMap, results,
        mapTabHeaderId = 'dataMapTab',
        updateMapOccurrences = true,
        activityLayer,
        pointStyleName = 'point_circle',
        heatmapStyleName = 'heatmap',
        clusterStyleName = 'cluster',
        polygonStyleName = 'polygon_sites',
        lineStyleName = 'line_sites',
        lineSelectorStyleName = 'line_selector',
        shapeRenderingLayers = [pointStyleName, polygonStyleName, lineStyleName],
        colourByControlId = "colour-by-select",
        sizeControlId = "size-slider",
        activityDisplayStyleId = "activity-display-style",
        selectedTimeSeriesIndex = fcConfig.timeSeriesOnIndex || 'dateCreated',
        colourByLabel = "Colour by:",
        filterByLabel = "Filter by:",
        selectedLayerID,
        selectedColourByIndex = '',
        selectedStyle = '',
        selectedSize = 5,
        selectedLayerName,
        currentlySelectedTab,
        legendControl,
        infoPanelControl,
        selectionControl,
        playerControl,
        opacity = 0.1,
        mapDisplays = [],
        layerNamesLookupRequests = {} ;

    self.view = view ? view : 'allrecords';
    var DEFAULT_EMAIL_DOWNLOAD_THRESHOLD = 500,
        MAX_FEATURE_COUNT = 1000,
        GENERAL_LAYER = '_general',
        INFO_LAYER = '_info',
        INDICES_LAYER = '_indices',
        INFO_LAYER_DEFAULT = 'default',
        TIMESERIES_LAYER = '_time',
        STATE_POINT = 'point',
        STATE_POLYGON = 'polygon',
        STATE_LINE = 'line',
        STATE_HEATMAP = 'heatmap',
        STATE_CLUSTER = 'cluster',
        STATE_POINT_INDEX = 'point+index',
        STATE_POLYGON_INDEX = 'polygon+index',
        STATE_LINE_INDEX = 'line+index',
        STATE_HEATMAP_INDEX = 'heatmap+index',
        STATE_CLUSTER_INDEX = 'cluster+index',
        STATE_POINT_TIME = 'point+time',
        STATE_POLYGON_TIME = 'polygon+time',
        STATE_LINE_TIME = 'line+time',
        STATE_HEATMAP_TIME = 'heatmap+time',
        STATE_CLUSTER_TIME = 'cluster+time',
        STATE_POINT_INDEX_TIME = 'point+index+time',
        STATE_POLYGON_INDEX_TIME = 'polygon+index+time',
        STATE_LINE_INDEX_TIME = 'line+index+time',
        STATE_HEATMAP_INDEX_TIME = 'heatmap+index+time',
        STATE_CLUSTER_INDEX_TIME = 'cluster+index+time';

    layerNamesLookupRequests[GENERAL_LAYER] =  undefined;
    layerNamesLookupRequests[TIMESERIES_LAYER] = {};
    layerNamesLookupRequests[INFO_LAYER] = {};
    layerNamesLookupRequests[INDICES_LAYER] = {};
    // These parameters are used when activity is instantiated from sites page.
    // It is used to disable certain aspects like map and auto load feature
    ignoreMap = !!ignoreMap;
    doNotInit = !!doNotInit;
    doNotStoreFacetFiltering = !!doNotStoreFacetFiltering;

    self.sortOptions = [
        {id: 'lastUpdated', name: 'Sort by Date', order: 'DESC'},
        {id: 'activityOwnerName', name: 'Sort by Owner', order: 'ASC'}];

    self.orderOptions = [{id: 'ASC', name: 'ASC'}, {id: 'DESC', name: 'DESC'}];
    self.activities = ko.observableArray();
    self.pagination = new PaginationViewModel({}, self);
    self.facets = ko.observableArray();
    self.total = ko.observable(0);
    self.filter = ko.observable(false);
    self.version = ko.observable(fcConfig.version);
    self.columnConfig = columnConfig || [];
    
    self.toggleFilter = function () {
        self.filter(!self.filter())
    };

    self.searchView = ko.observable(true);

    self.toggleSearchView = function () {
        self.searchView(!self.searchView());
    };

    self.searchTerm = ko.observable('');
    self.order = ko.observable();
    self.sort = ko.observable();

    self.filterViewModel = new FilterViewModel({
        parent: self,
        flimit: fcConfig.flimit
    });

    self.transients = {};
    self.transients.totalPoints = ko.observable(0);
    self.transients.loadingMap = ko.observable(true);
    self.transients.placeHolder = placeHolder;
    self.transients.bieUrl = fcConfig.bieUrl;
    self.transients.showEmailDownloadPrompt = ko.observable(false);
    self.transients.downloadEmail = ko.observable(user ? user.userName : null);
    self.transients.loading = ko.observable(false);
    self.transients.activitiesToDelete = ko.observableArray([]);
    self.transients.isBulkActionsEnabled = ko.pureComputed(function () {
        var activities = self.activities(), show = false;
        activities.forEach(function (item) {
            if (item.userCanModerate) {
                show = true;
            }
        });

        return show;
    });

    self.search = function () {
        fetchDataForTabs()
    };

    self.clearData = function() {
        self.searchTerm('');
        self.loadSortColumn(true, true);
        self.filterViewModel.selectedFacets.removeAll();
    };

    self.reset = function () {
        self.clearData();
    };

    self.getFacetTerms = function (facets) {
        var url = constructQueryUrl(fcConfig.searchProjectActivitiesUrl, null, false, -1);
        url = url + ((url.indexOf('?') > -1) ? '&' : '?') + '&max=0&facets=' + facets;

        return $.ajax({
            url: url
        });
    };

    var facetsLocalStorageHandler = function (cmd) {
        if(!doNotStoreFacetFiltering){
            var orgTerm = fcConfig.organisationName;
            if (!orgTerm) {
                var key = self.view.toUpperCase() + '_DATA_PAGE_FACET_KEY';
                switch (cmd) {
                    case 'store':
                        var facets = [];
                        ko.utils.arrayForEach(self.filterViewModel.selectedFacets(), function (filter) {
                            var value = ko.mapping.toJS(filter);
                            delete  value.facet.terms;
                            delete  value.facet.ref;
                            delete  value.facet.filter;
                            delete  value.facet.term;
                            facets.push(value);
                        });

                        amplify.store(key, facets);
                        break;

                    case 'restore':
                    default:
                        return amplify.store(key);
                }
            }
        }
    };

    self.canFacetBeDisplayed = function(facetModel, whiteList){
        var found = $.grep(whiteList, function (obj, i) {
            return (obj.name == facetModel.name());
        });

        return found.length > 0;
    };

    self.sortClass = function (column) {
        if( self.sort() === column.code ) {
            if (self.order() === 'asc') {
                return 'fa fa-sort-up'
            } else {
                return 'fa fa-sort-down'
            }
        } else  {
            return 'fa fa-sort'
        }
    };

    self.getSortColumn = function () {
        var result;
        self.columnConfig.forEach(function (column) {
            if(column.sort){
                result = column
            }
        });

        return result;
    };

    self.loadSortColumn = function (doNotRefresh, doNotChangeOrder) {
        var column = self.getSortColumn();
        if (column) {
            self.sortByColumn(column, null, doNotRefresh, doNotChangeOrder);
        }
    };

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

    /**
     * event handler
     */
    self.sortByColumn = function (data, event, doNotRefresh, doNotChangeOrder) {
        self.sortButtonClick({ id: data.code, order: data.order}, doNotRefresh);
        if(!doNotChangeOrder) {
            data.order = data.order === 'asc' ? 'desc' : 'asc';
        }
    };

    self.load = function (data, page) {
        var activities = data.activities;
        var total = data.total;

        self.activities([]);

        activities = $.map(activities ? activities : [], function (activity, index) {
            activity.parent = self;
            return new ActivityRecordViewModel(activity);
        });
        self.activities(activities);

        self.filterViewModel.setFacets(data.facets || []);

        // only initialise the pagination if we are on the first page load
        if (page == 0) {
            self.pagination.loadPagination(page, total);
        }

        self.total(total);

        var $loading = $('.loading-message');
        $loading.hide();
    };

    self.download = function(data, event) {
        var elem = event.target ? event.target : event.srcElement;
        var asyncDownloadThreshold = DEFAULT_EMAIL_DOWNLOAD_THRESHOLD;
        if (elem) {
                asyncDownloadThreshold = $(elem).attr("dataemailthreshold");
        }

        var url = constructQueryUrl(fcConfig.downloadProjectDataUrl, 0, false);

        if (self.total() > asyncDownloadThreshold) {
            self.transients.showEmailDownloadPrompt(!self.transients.showEmailDownloadPrompt());
        } else {
            $('#downloadStartedMsg').removeClass('hide');
            window.setTimeout(function(){
                $('#downloadStartedMsg').addClass('hide');
            }, 5000);
            window.location.href = url;
        }
    };

    self.asyncDownload = function() {
        var url = constructQueryUrl(fcConfig.downloadProjectDataUrl, 0, false);

        url += "&async=true&email=" + self.transients.downloadEmail();

        $.ajax({
            url: url,
            type: 'GET',
            complete: function() {
                self.transients.showEmailDownloadPrompt(false);

                bootbox.alert("Your download has been requested. You will receive an email when the download is ready.");
            }
        })
    };

    self.refreshPage = function (offset) {
        var url = constructQueryUrl(fcConfig.searchProjectActivitiesUrl, offset, false);
        // initialise offset
        offset = offset || 0;

        self.transients.loading(true);
        $.ajax({
            url: url,
            type: 'GET',
            contentType: 'application/json',
            beforeSend: function () {
                $('.search-spinner').show();
                $('.activities-search-panel').addClass('searching-opacity');
            },
            success: function (data) {
                self.load(data, Math.ceil(offset / self.pagination.resultsPerPage()));
                facetsLocalStorageHandler('store');
            },
            error: function (data) {
                alert('An error occurred: ' + data);
            },
            complete: function () {
                $('.search-spinner').hide();
                $('.main-content').show();
                self.transients.loading(false);
                $('.activities-search-panel').removeClass('searching-opacity');
            }
        });
    };

    function getSelectedTermsForRefinement() {
        return $.map(self.facets(), function (facet) {
            return $.map(facet.terms(), function (term) {
                return term.selected() ? term : null;
            });
        });
    }

    self.refinementSelected = function() {
        return getSelectedTermsForRefinement().length > 0;
    };

    self.bulkDelete = function (activity) {
        var activities = self.transients.activitiesToDelete(),
            numberOfActivities = activities.length;

        bootbox.confirm("Are you sure you want to delete " + numberOfActivities + (numberOfActivities === 1 ? " activity?": " activities?"), function (result) {
            if (result) {
                var projectIds = self.getProjectIdOfSelectedActivities(),
                    url = fcConfig.activityBulkDeleteUrl;

                $.ajax({
                    url: url,
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        'ids': activities.join(','),
                        'projectIds': projectIds.join(',')
                    },
                    success: function (data) {
                        if (data.message == 'deleted') {
                            bootbox.alert("Successfully deleted activities. Indexing is in process, search result will be updated in few minutes. Reloading this page in 3 seconds.");
                            setTimeout (function () {
                                location.reload();
                            }, 3000);
                            self.transients.activitiesToDelete.removeAll();
                        } else {
                            bootbox.alert("Error deleting activities.");
                        }
                    },
                    error: function (data) {
                        var message = data.responseText;
                        if (data.status == 401) {
                            bootbox.alert(message.error);
                        } else {
                            bootbox.alert('An unhandled error occurred: ' + message.message);
                        }
                    }
                });
            }
        });
    };

    self.bulkRelease = function (activity) {
        var activities = self.transients.activitiesToDelete(),
            numberOfActivities = activities.length;

        bootbox.confirm("Are you sure you want to release " + numberOfActivities + (numberOfActivities === 1 ? " activity?": " activities?"), function (result) {
            if (result) {
                var projectIds = self.getProjectIdOfSelectedActivities(),
                    url = fcConfig.activityBulkReleaseUrl;

                $.ajax({
                    url: url,
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        'ids': activities.join(','),
                        'projectIds': projectIds.join(',')
                    },
                    success: function (data) {
                        if (data.message == 'updated') {
                            bootbox.alert ("Successfully released activities. Search result will take a few minutes to update. This page will be automatically reloaded in 3 seconds.");
                            setTimeout (function () {
                                location.reload();
                            }, 3000);
                            self.transients.activitiesToDelete.removeAll();
                        } else {
                            bootbox.alert ("Error releasing activities.");
                        }
                    },
                    error: function (data) {
                        var message = data.responseText;
                        if (data.status == 401) {
                            bootbox.alert (message.error);
                        } else {
                            bootbox.alert ('An unhandled error occurred: ' + message.message);
                        }
                    }
                });
            }
        });
    };

    self.bulkEmbargo = function (activity) {
        var activities = self.transients.activitiesToDelete(),
            numberOfActivities = activities.length;

        bootbox.confirm("Are you sure you want to embargo " + numberOfActivities + (numberOfActivities === 1 ? " activity?": " activities?"), function (result) {
            if (result) {
                var projectIds = self.getProjectIdOfSelectedActivities(),
                    url = fcConfig.activityBulkEmbargoUrl;

                $.ajax({
                    url: url,
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        'ids': activities.join(','),
                        'projectIds': projectIds.join(',')
                    },
                    success: function (data) {
                        if (data.message == 'updated') {
                            bootbox.alert ("Successfully embargoed activities. Search result will take a few minutes to update. Reloading this page in 3 seconds.");
                            setTimeout (function () {
                                location.reload();
                            }, 3000);
                            self.transients.activitiesToDelete.removeAll();
                        } else {
                            bootbox.alert ("Error embargoing activities.");
                        }
                    },
                    error: function (data) {
                        var message = data.responseText;
                        if (data.status == 401) {
                            bootbox.alert(message.error);
                        } else {
                            bootbox.alert('An unhandled error occurred: ' + message.message);
                        }
                    }
                });
            }
        });
    };

    self.getProjectIdOfSelectedActivities = function () {
        var activityIds = self.transients.activitiesToDelete(),
            projects = {},
            activities = self.activities(),
            projectIds = [];

        activityIds.forEach(function (id) {
            var activity = $.grep(activities, function (act) {
                return act.activityId() === id
            })[0];

            projects[activity.projectId()] = true;
        });

        for ( var projectId in projects ) {
            projectIds.push(projectId);
        }

        return projectIds;
    };

    self.createOrUpdateMap = function (){
        if (ignoreMap)
            return;

        if (updateMapOccurrences && currentlySelectedTab && (currentlySelectedTab.id  == mapTabHeaderId)) {
            if(!alaMap){
                var baseLayersAndOverlays = Biocollect.MapUtilities.getBaseLayerAndOverlayFromMapConfiguration(fcConfig.mapLayersConfig);
                var mapOptions = {
                    drawControl: false,
                    showReset: false,
                    draggableMarkers: false,
                    useMyLocation: false,
                    allowSearchLocationByAddress: false,
                    allowSearchRegionByAddress: false,
                    trackWindowHeight: true,
                    loadingControlOptions: {
                        position: 'topleft'
                    },
                    overlayControlPosition: "topleft",
                    baseLayer: baseLayersAndOverlays.baseLayer,
                    otherLayers: baseLayersAndOverlays.otherLayers,
                    overlays: baseLayersAndOverlays.overlays,
                    overlayLayersSelectedByDefault: baseLayersAndOverlays.overlayLayersSelectedByDefault,
                };

                // Create map
                self.transients.alaMap = alaMap = new ALA.Map("recordOrActivityMap", mapOptions);

                // Control - reset
                alaMap.addButton("<span class='fa fa-refresh reset-map' title='Reset zoom'></span>", alaMap.fitBounds, "bottomright");

                playerControl = new L.Control.Player({
                    position: 'bottomright',
                    startYear: 2015,
                    endYear: 2020,
                    interval: 1,
                    timeout: 4
                });
                playerControl.on('play', self.play);
                playerControl.on('stop', self.stop);
                playerControl.on('forward', self.play);
                playerControl.on('backward', self.play);
                alaMap.addControl(playerControl);

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
                alaMap.addControl(selectionControl);

                selectionControl.on('change', function (data) {
                    switch (data.item.id) {
                        case activityDisplayStyleId:
                            changeActivityDisplayStyle(data.value);
                            break;
                        case colourByControlId:
                            changeColourByIndex(data.value);
                            break;
                        case sizeControlId:
                            changeSize(data.value);
                            break;
                    }
                });

                // update colour by when facets change
                self.filterViewModel.facets.subscribe(function() {
                    var options = self.filterViewModel.getColourByFields();
                    options = addEmptyOption(options);
                    selectionControl.setSelectOptions(colourByControlId, options);
                });

                // Control - legend
                legendControl = new L.Control.LegendImage({collapse: true, position: "topright"});
                alaMap.addControl(legendControl);

                // Control - display help text
                infoPanelControl = new L.Control.InfoPanel({
                    content: getHelpText(),
                    collapse: false,
                    title: "Help"
                });
                alaMap.addControl(infoPanelControl);

                alaMap.registerListener('click', mapClickEventHandler);
                alaMap.registerListener("zoomend dragend", getHeatmap);
            }


            selectedColourByIndex = undefined;
            var typeAndIndices = getLayerTypeAndIndices();
            getLayerNameRequest(typeAndIndices.type, typeAndIndices.indices).done(function (data) {
                var layerName = data.layerName;
                if (layerName) {
                    console.log('Setting layerName - ' + layerName);
                    selectedLayerName = layerName;
                    refreshMapComponents();
                }
            });

            updateDateRange();
            // init colour by control
            var options = self.filterViewModel.getColourByFields();
            options = addEmptyOption(options);
            selectionControl.setSelectOptions(colourByControlId, options);
            legendControl.clearLegend();

            // clear flag to disable adding occurrences layer to map
            updateMapOccurrences = false;
            setSelectionControlState();
        }
    };

    function setSelectionControlState() {
        setLabelForMapDisplay();
        enableDisableSizeControl();
    }

    function setLabelForMapDisplay() {
        selectionControl.changeLabel(getLabelForMapDisplay(), colourByControlId);
    };

    function getLabelForMapDisplay() {
        if (shapeRenderingLayers.indexOf(selectedLayerID) >= 0) {
            return colourByLabel;
        } else {
            return filterByLabel;
        }
    }

    function setTooltipForMapDisplay() {
        selectionControl.setPopover({
            id: colourByControlId,
            helpText: getTooltipForMapDisplay()
        });
    }

    function getTooltipForMapDisplay() {
        if (shapeRenderingLayers.indexOf(selectedLayerID) >= 0) {
            return fcConfig.mapDisplayColourByHelpText;
        } else {
            return fcConfig.mapDisplayFilterByHelpText;
        }
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
            case lineStyleName:
                return fcConfig.lineLegendTitle;
        }
    }

    function getHelpText() {
        switch (selectedLayerID) {
            case heatmapStyleName:
                return fcConfig.heatmapHelpText;
            case clusterStyleName:
                return fcConfig.clusterHelpText;
            case lineStyleName:
                return fcConfig.lineHelpText;
            case polygonStyleName:
                return fcConfig.polygonHelpText;
            case pointStyleName:
                return fcConfig.pointHelpText;
        }
    }

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


    function addEmptyOption(values) {
        values = values || [];
        values.unshift({key: ""});
        return values;
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

    function getCurrentState() {
        var isPlayerActive = playerControl.isPlayerActive();
        switch (selectedLayerID) {
            case clusterStyleName:
                if (selectedColourByIndex && isPlayerActive) {
                    return STATE_CLUSTER_INDEX_TIME;
                }
                else if (isPlayerActive) {
                    return STATE_CLUSTER_TIME;
                }
                else if (selectedColourByIndex) {
                    return STATE_CLUSTER_INDEX;
                }
                else {
                    return STATE_CLUSTER;
                }

                break;
            case heatmapStyleName:
                if (selectedColourByIndex && isPlayerActive) {
                    return STATE_HEATMAP_INDEX_TIME;
                }
                else if (isPlayerActive) {
                    return STATE_HEATMAP_TIME;
                }
                else if (selectedColourByIndex) {
                    return STATE_HEATMAP_INDEX;
                }
                else {
                    return STATE_HEATMAP;
                }

                break;
            case pointStyleName:
                if (selectedColourByIndex && isPlayerActive) {
                    return STATE_POINT_INDEX_TIME;
                }
                else if (isPlayerActive) {
                    return STATE_POINT_TIME;
                }
                else if (selectedColourByIndex) {
                    return STATE_POINT_INDEX;
                }
                else {
                    return STATE_POINT;
                }

                break;
            case polygonStyleName:
                if (selectedColourByIndex && isPlayerActive) {
                    return STATE_POLYGON_INDEX_TIME
                }
                else if (isPlayerActive) {
                    return STATE_POLYGON_TIME;
                }
                else if (selectedColourByIndex) {
                    return STATE_POLYGON_INDEX;
                }
                else {
                    return STATE_POLYGON;
                }

                break;
            case lineStyleName:
                if (selectedColourByIndex && isPlayerActive) {
                    return STATE_LINE_INDEX_TIME;
                }
                else if (isPlayerActive) {
                    return STATE_LINE_TIME;
                }
                else if (selectedColourByIndex) {
                    return STATE_LINE_INDEX;
                }
                else {
                    return STATE_LINE;
                }

                break;

        }
    }

    function getParametersForState(state) {
        var params = {};
        state = state || getCurrentState();
        addCommonParameters(params);

        switch (state) {
            case STATE_CLUSTER:
                params.styles = clusterStyleName;
                break;
            case STATE_CLUSTER_INDEX:
                params.styles = clusterStyleName;
                addCQLParameter(params);
                break;
            case STATE_CLUSTER_TIME:
                params.styles = clusterStyleName;
                addTimeParameter(params);
                break;
            case STATE_CLUSTER_INDEX_TIME:
                params.styles = clusterStyleName;
                addTimeParameter(params);
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
            case STATE_POINT_TIME:
                params.styles = pointStyleName;
                params.env = "size:" + selectedSize + ";";
                addTimeParameter(params);
                break;
            case STATE_POINT_INDEX_TIME:
                params.styles = selectedStyle;
                params.env = "size:" + selectedSize + ";";
                addTimeParameter(params);
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
            case STATE_POLYGON_TIME:
                params.styles = polygonStyleName;
                params.env = "size:" + selectedSize + ";";
                addTimeParameter(params);
                break;
            case STATE_POLYGON_INDEX_TIME:
                params.styles = selectedStyle;
                params.env = "size:" + selectedSize + ";";
                addTimeParameter(params);
                addCQLParameter(params);
                break;
            case STATE_LINE:
                params.styles = lineStyleName;
                params.env = "size:" + selectedSize + ";";
                break;
            case STATE_LINE_INDEX:
                params.styles = selectedStyle;
                params.env = "size:" + selectedSize + ";";
                addCQLParameter(params);
                break;
            case STATE_LINE_TIME:
                params.styles = lineStyleName;
                params.env = "size:" + selectedSize + ";";
                addTimeParameter(params);
                break;
            case STATE_LINE_INDEX_TIME:
                params.styles = selectedStyle;
                params.env = "size:" + selectedSize + ";";
                addTimeParameter(params);
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
            case STATE_HEATMAP_TIME:
                params.styles = heatmapStyleName;
                addTimeParameter(params);
                break;
            case STATE_HEATMAP_INDEX_TIME:
                params.styles = heatmapStyleName;
                addWeightParameter(params);
                addTimeParameter(params);
                addCQLParameter(params);
                break;
        }

        if (opacity) {
            params.env += "opacity:" + opacity + ";";
        }

        return params;
    }

    function addTimeParameter (params) {
        params = params || {};
        var playerState = playerControl.getCurrentDuration();
        params.time = playerState.interval[0] + "/" + playerState.interval[1];
        return params;
    }

    function getTimeRangeQuery() {
        var playerState = playerControl.getCurrentDuration();
        return selectedTimeSeriesIndex + ":[" + playerState.interval[0] + "-01-01 TO " + playerState.interval[1] + "-12-31]"
    }

    function addWeightParameter (params) {
        params = params || {};
        params.env = "weight:" + selectedColourByIndex + ";";
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

    function getBoundingBoxGeoJSON() {
        var map = alaMap.getMapImpl(),
            crs = map.options.crs,
            sw = map.getBounds().getSouthWest(),
            ne = map.getBounds().getNorthEast(),
            bbox = {
                type: "Polygon",
                coordinates: [[[sw.lng, sw.lat], [ne.lng, sw.lat], [ne.lng, ne.lat], [sw.lng, ne.lat], [sw.lng, sw.lat]]]
            };

        return bbox;
    }

    function getHeatmap() {
        if (selectedLayerID === heatmapStyleName) {
            activityLayer.fire('loading');
            var state = getCurrentState(),
                params = getParametersForState(state),
                url = constructQueryUrl(fcConfig.heatmapURL, 0, false, 0, false),
                boundingBoxGeoJSON = getBoundingBoxGeoJSON(),
                payload = {
                    geoSearchJSON: JSON.stringify(boundingBoxGeoJSON)
                };

            if (params.time) {
                payload.fq =  getTimeRangeQuery();
            }

            if (selectedColourByIndex) {
                payload.exists = selectedColourByIndex;
            }

            $.ajax({
                url: url,
                data: payload,
                success: function (data) {
                    if (!data.error) {
                        if (selectedLayerID === heatmapStyleName) {
                            activityLayer.clearLayers();
                            activityLayer.addData && activityLayer.addData(data);
                            updateLegendFromGeoJSON(data);
                        }
                    }

                    activityLayer.fire('load');
                }
            });
        }
    }

    function initMapOverlaysWithLayer () {
        var url;

        activityLayer && alaMap.removeOverlayLayer(activityLayer);
        switch (selectedLayerID) {
            case heatmapStyleName:
                activityLayer = L.geoJson(null, {
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
                url = constructQueryUrl(fcConfig.wmsActivityURL, 0, false, 0, false);
                activityLayer = L.nonTiledLayer.wms ( url, {
                    format: 'image/png',
                    transparent: true,
                    maxZoom: 21
                });
                break;

        }

        playerControl && activityLayer.on('load tileerror', playerControl.startTimerForNextFrame, playerControl);
    }

    function getIndicesForTimeSeries() {
        if (selectedColourByIndex) {
            return selectedTimeSeriesIndex + ',' + selectedColourByIndex;
        }

        return selectedTimeSeriesIndex;
    }

    self.play = function (state) {
        switch (state.intervalType) {
            case 'year':
                if (state.interval) {
                    switch (selectedLayerID) {
                        case heatmapStyleName:
                            getHeatmap();
                            break;
                        default:
                            getLayerNameRequest(TIMESERIES_LAYER, getIndicesForTimeSeries()).done(function(data){
                                if (data.layerName) {
                                    selectedLayerName = data.layerName;
                                    refreshMapComponents();
                                    activityLayer && activityLayer.fire('loading');
                                }
                            });
                    }
                }
                break;
        }
    }

    self.stop = function (state) {
        switch (state.intervalType) {
            case 'year':
                switch (selectedLayerID) {
                    case heatmapStyleName:
                        getHeatmap();
                        break;
                    default:
                        var typeAndIndices = getLayerTypeAndIndices();
                        getLayerNameRequest(typeAndIndices.type, typeAndIndices.indices).done(function (data) {
                            if (data.layerName) {
                                selectedLayerName = data.layerName;
                                refreshMapComponents();
                            }
                        });
                        break;
                }
                break;
        }
    }

    /**
     * when map is updated on invisible, this function is used to redraw the map.
     */
    self.invalidateSize = function(){
        alaMap.getMapImpl().invalidateSize();
    };


    /**
     * gets the list of selected filters to a format easy enough to construct an URL.
     */
    self.urlFacetParameter = function(){
        var facetFilters = [];
        self.filterViewModel.selectedFacets().forEach(function (facet) {
            facetFilters.push(facet.getQueryText())
        });

        return facetFilters;
    };

    /**
     * translate the current facet selection to biocache url format.
     */
    self.biocacheUrl = ko.computed(function () {
        var fqs = self.filterViewModel.getALACompatibleQuery() || [],
            query = fqs.join("&fq="),
            url = fcConfig.occurrenceUrl || '',
            questionMark = false;

        if(url.indexOf('?') < 0){
            questionMark = true
        }

        if(query){
            var prefix = questionMark?'?':'&';
            return url + prefix + "fq=" + query
        }

        return url
    });

    /**
     * translate the current facet selection to spatial portal url format.
     */
    self.spatialUrl = ko.computed(function () {
        var fqs = self.filterViewModel.getALACompatibleQuery() || [],
            query = fqs.join("&fq="),
            url = fcConfig.spatialUrl || '',
            questionMark = false;

        if(url.indexOf('?') < 0){
            questionMark = true
        }

        if(query){
            var prefix = questionMark?'?':'&';
            return url + prefix + "fq=" + query
        }

        return url
    });

    function constructQueryUrl(prefix, offset, facetOnly, flimit, addPaginationParams) {
        if (!offset) offset = 0;
        addPaginationParams = addPaginationParams == undefined ? true : !!addPaginationParams;

        var params = {
                view: self.view,
                spotterId: fcConfig.spotterId,
                projectActivityId: fcConfig.projectActivityId,
                clientTimezone : moment.tz.guess()
            },
            fq = [],
            rfq;

        if (addPaginationParams) {
            params.max = self.pagination.resultsPerPage();
            params.offset = offset;
            params.sort= self.sort();
            params.order= self.order();
            params.flimit= flimit || fcConfig.flimit;
        }

        var filters = '', rfilters = '';
        if (_.isUndefined(facetOnly) || !facetOnly) {
            params.searchTerm = self.searchTerm().trim();

            fq = self.urlFacetParameter();

            fq.forEach(function (filter, index) {
                fq[index] = encodeURI(filter)
            });

            if(fq.length){
                filters = '&fq=' + fq.join('&fq=');
            }
        }

        url = prefix + ((prefix.indexOf('?') > -1) ? '&' : '?') + $.param(params);
        return url + filters + rfilters;
    }

    function fetchDataForTabs(){
        if(self.filterViewModel.switchOffSearch()) return;

        updateMapOccurrences = true;
        self.refreshPage();
        self.createOrUpdateMap();
        self.imageGallery && self.imageGallery.fetchRecordImages()
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
                        styleName = activityLayer.wmsParams.styles == lineStyleName ? lineSelectorStyleName : activityLayer.wmsParams.styles,
                        params = {
                            request: 'GetFeatureInfo',
                            service: 'WMS',
                            srs: crs.code,
                            version: activityLayer.wmsParams.version,
                            layers: data.layerName,
                            query_layers: data.layerName,
                            styles: styleName,
                            bbox:  sw.x + ',' + sw.y + ',' + ne.x + ',' + ne.y,
                            height: size.y,
                            width: size.x,
                            feature_count: MAX_FEATURE_COUNT,
                            info_format: 'application/json'
                        };

                    if (activityLayer.wmsParams.cql_filter) {
                        params.cql_filter = activityLayer.wmsParams.cql_filter;
                    }

                    if (playerControl.isPlayerActive()) {
                        params.cql_filter = params.cql_filter || "";
                        var time = playerControl.getCurrentDuration(),
                            timeCQL = selectedTimeSeriesIndex + " >= '" + time.interval[0] + "-01-01' AND " + selectedTimeSeriesIndex + " <= '" + time.interval[1] + "-12-31'";

                        params.cql_filter = params.cql_filter ? params.cql_filter + " AND " + timeCQL : timeCQL;
                    }

                    params[params.version === '1.3.0' ? 'i' : 'x'] = Math.round(event.containerPoint.x);
                    params[params.version === '1.3.0' ? 'j' : 'y'] = Math.round(event.containerPoint.y);
                    var url = activityLayer._wmsUrl + L.Util.getParamString(params, activityLayer._wmsUrl, true);
                    // show loading GIF
                    activityLayer.fire && activityLayer.fire('loading');
                    $.get(url , function (data) {
                        var features = data.features;

                        if (features && features.length) {
                            L.popup({
                                maxWidth: 400,
                                minWidth: 200
                            })
                                .setLatLng(event.latlng)
                                .setContent('<div id="template-map-popup-record" style="width: 400px; height: auto" data-bind="template: { name: \'script-popup-template\' }"></div>')
                                .openOn(alaMap.getMapImpl());

                            ko.applyBindings({features: features, index: ko.observable(0)}, document.getElementById('template-map-popup-record'))
                        }
                    }).done(function() {
                        // remove loading GIF
                        activityLayer.fire && activityLayer.fire('load');
                    });
                }
            })
        }
    };
    // todo: cql not cleared properly
    function changeColourByIndex(index) {
        var typeAndIndices;

        selectedColourByIndex = index;
        updateDateRange();
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

    function createStyleForMapDisplayAndColourByIndex(mapDisplay, index) {
        var terms = self.filterViewModel.getTermsForFacet(index);
        if (canMapDisplayBeColoured(mapDisplay)) {
            terms.style = mapDisplay;
        }

        createStyleFromTerms(terms).done(function (data) {
            selectedStyle = data.name;
            self.filterViewModel.setStyleName(index, selectedStyle);
            refreshMapComponents();
        });
    };

    function changeSize(size) {
        selectedSize = size;
        refreshMapComponents();
    }

    function setDefaultSizeForStyle (style) {
        if (canMapDisplayBeColoured(style)) {
            var settings = self.getSettingsForStyle(style),
                size = (settings && settings.size) || 1;
            selectionControl.setSize('slider', 'size-slider', size);
        }
    };

    /**
     * Update map depending on colour by selection and rendering (point, heatmap etc.) selection.
     */
    function refreshMapComponents () {
        var state = getCurrentState(),
            params = getParametersForState(state),
            legendURL;

        initMapOverlaysWithLayer();
        activityLayer && activityLayer.setParams && activityLayer.setParams(params);
        alaMap.addOverlayLayer(activityLayer, 'Activity', true);
        legendURL = Biocollect.MapUtilities.getLegendURL(activityLayer, params.styles);
        !legendURL && legendControl.clearLegend();
        legendURL && legendControl.updateLegend(legendURL, getLegendTitle());
    }

    function createStyleFromTerms(terms) {
        return $.ajax({
            url: fcConfig.createStyleURL,
            method: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(terms)
        });
    }

    function changeActivityDisplayStyle (value) {
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
    };

    function getDateRange() {
        var url = constructQueryUrl(fcConfig.dateRangeURL, 0, true, 0, false),
            params = {
                dateFields: selectedTimeSeriesIndex
            };

        if (selectedColourByIndex) {
            params.exists = selectedColourByIndex;
        }

        return $.get({
            url: url,
            data: params
        });
    };

    function updateDateRange() {
        getDateRange().done(function (range) {
            if (range[selectedTimeSeriesIndex]) {
                playerControl && playerControl.setYearRange(range[selectedTimeSeriesIndex]);
            }
        })
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
            case TIMESERIES_LAYER:
                if (indices == undefined) {
                    indices = [];
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
                    type: type,
                    indices: indicesConcat || ''
                }
            }).fail(function () {
                setLayerNameRequest(type, indices, undefined);
            });

            setLayerNameRequest(type, indices, request);
        }

        return request;
    };

    function getStyleNameForIndicesLayer() {
        if (canMapDisplayBeColoured(selectedLayerID)) {
            return selectedLayerID+selectedColourByIndex;
        }
    };

    function canMapDisplayBeColoured (index) {
        return shapeRenderingLayers.indexOf(index) >= 0;
    };

    function setLayerNameRequest(type, indices, request) {
        var indicesConcat, styleCode;
        switch (type) {
            case GENERAL_LAYER:
                layerNamesLookupRequests[type] = request;
                break;
            case INFO_LAYER:
                if (!indices) {
                    indices = [INFO_LAYER_DEFAULT];
                }
            case INDICES_LAYER:
            case TIMESERIES_LAYER:
                if (indices === undefined) {
                    return;
                }
                else if (typeof indices === 'string') {
                    indices = [indices];
                }

                indicesConcat = indices.join(',');
                styleCode = getStyleNameForIndicesLayer()
                if (!styleCode) {
                    styleCode = indicesConcat;
                }

                layerNamesLookupRequests[type][styleCode] = request;
                break;
        }
    };

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

    function getSVGForLegend(legend) {
        var svg = Snap("100%", "auto"),
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

    function updateLegendFromGeoJSON (geoJSON) {
        var legend = getLegendFromGeoJSON(geoJSON);
        var svg = getSVGForLegend(legend);
        updateLegendWithSVG(svg);
    }

    self.filterViewModel.selectedFacets.subscribe(fetchDataForTabs);

    self.sortButtonClick = function(data, doNotRefersh){
        // remove subscribe event on order so that we can set it and page will not refresh. will only refresh when
        // sort is set.
        self.order(data.order);
        self.sort(data.id);
        !doNotRefersh && self.refreshPage();
    };

    $("#tabDifferentViews a").on('show', function (event) {
        currentlySelectedTab = event.target;
        console.log(currentlySelectedTab);
    }).on('shown', self.createOrUpdateMap);

    var restored = facetsLocalStorageHandler("restore");
    var orgTerm = fcConfig.organisationName;
    self.loadSortColumn(true);
    self.loadMapDisplays(fcConfig.mapDisplays);
    if (orgTerm) {
        self.filterViewModel.selectedFacets.push(new FacetTermViewModel({
            term: orgTerm,
            facet: new FacetViewModel({
                name: "organisationNameFacet",
                title: 'Organisation',
                ref: self.filterViewModel,
                type: 'terms'
            })
        }));
    } else if (restored && restored.length > 0) {
        var selectedFacets = [];
        $.each(restored, function (index, value) {
            // using name for backward compatibility
            if(!value.facet && value.name){
                value.facet = {
                    name: value.name,
                    type: value.type || 'terms'
                }
            }

            value.facet = self.filterViewModel.createFacetViewModel(value.facet);

            switch (value.type){
                case 'range':
                    selectedFacets.push(new FacetRangeViewModel(value));
                    break;
                case 'term':
                default:
                    selectedFacets.push(new FacetTermViewModel(value));
                    break;
            }
        });

        !doNotInit && self.filterViewModel.selectedFacets.push.apply(self.filterViewModel.selectedFacets, selectedFacets);
    }
    else {
        !doNotInit && fetchDataForTabs();
    }
};

var ActivityRecordViewModel = function (activity) {
    var self = this;
    if (!activity) activity = {};

    self.rawData = activity;
    self.activityId = ko.observable(activity.activityId);
    self.showCrud = ko.observable(activity.showCrud);
    self.userCanModerate = activity.userCanModerate;
    self.projectActivityId = ko.observable(activity.projectActivityId);
    self.name = ko.observable(activity.name);
    self.type = ko.observable(activity.type);
    self.lastUpdated = ko.observable(activity.lastUpdated).extend({simpleDate: true});
    self.ownerName = ko.observable(activity.activityOwnerName);
    self.userId = ko.observable(activity.userId);
    self.siteId = ko.observable(activity.siteId);
    self.embargoed = ko.observable(activity.embargoed);
    self.embargoUntil = ko.observable(activity.embargoUntil).extend({simpleDate: false});
    self.projectName = ko.observable(activity.projectName);
    self.projectId = ko.observable(activity.projectId);
    self.projectType = ko.observable(activity.projectType);
    self.isWorksProject = ko.pureComputed(function () {
        return self.projectType() === "works"
    });

    self.projectUrl = ko.pureComputed(function () {
        return fcConfig.projectIndexUrl + '/' + self.projectId() +
            (fcConfig.version !== undefined ? "?version=" + fcConfig.version : '');
    });

    self.delete = function () {

        bootbox.confirm("Are you sure you want to delete the record?", function (result) {
            if (result) {
                var url = fcConfig.activityDeleteUrl + "/" + self.activityId();
                // Don't allow another save to be initiated.
                blockUIWithMessage("Deleting...");
                $.ajax({
                    url: url,
                    type: 'DELETE',
                    contentType: 'application/json',
                    success: function (data) {
                        if (data.text == 'deleted') {
                            blockUIWithMessage("Successfully deleted, after indexing record will be removed. <br>Reloading the page...");
                        } else {
                            blockUIWithMessage("Error deleting the record, please try again later.");
                        }
                    },
                    error: function (data) {
                        if (data.status == 401) {
                            var message = $.parseJSON(data.responseText);
                            blockUIWithMessage(message.error);
                        } else if (data.status == 404) {
                            blockUIWithMessage("Record not available. Indexing might be in process, reloading the page...");
                        } else {
                            blockUIWithMessage('An unhandled error occurred, please try again later.');
                        }
                    },
                    complete: function() {
                        setTimeout(function () {
                            //$.unblockUI(); Don't unblock this, let the reload do the work.
                            location.reload();
                        }, 2500);
                    }
                });
            }
        });
    };
    self.transients = {};
    self.transients.viewUrl = ko.observable((self.isWorksProject() ? fcConfig.worksActivityViewUrl : fcConfig.activityViewUrl) + "/" + self.activityId()).extend({returnTo: fcConfig.returnTo, dataVersion: fcConfig.version});
    self.transients.editUrl = ko.observable((self.isWorksProject() ? fcConfig.worksActivityEditUrl : fcConfig.activityEditUrl) + "/" + self.activityId()).extend({returnTo: fcConfig.returnTo});
    self.transients.addUrl = ko.observable(fcConfig.activityAddUrl + "/" + self.projectActivityId()).extend({returnTo: fcConfig.returnTo});
    self.transients.parent = activity.parent;
    self.transients.thumbnailUrl = ko.observable(activity.thumbnailUrl ||  fcConfig.imageLocation + "no-image-2.png");
    self.transients.imageTitle = ko.observable(activity.thumbnailUrl? '' : 'No image' );

    self.records = ko.observableArray();
    self.siteUrl = fcConfig.siteViewUrl + '/' + self.siteId();
    var projectActivityOpen = true;
    if (activity.endDate) {
        projectActivityOpen = moment(activity.endDate).isAfter(moment());
    }
    self.showAdd = ko.observable(projectActivityOpen);
    self.readOnly = ko.observable((fcConfig.version || '' ).length > 0)//183,238,252

    var allRecords = $.map(activity.records ? activity.records : [], function (record, index) {
        record.parent = self;
        record.thumbnailUrl = self.transients.thumbnailUrl();
        return new RecordVM(record);
    });
    self.records(allRecords);
};

var RecordVM = function (record) {
    var self = this;
    if (!record) record = {};
    self.rawData = record;
    self.parent = record.parent;
    self.occurrenceID = ko.observable(record.occurrenceID);
    self.guid = ko.observable(record.guid);
    self.name = ko.observable(record.name);
    self.commonName = record.commonName;
    self.coordinates = record.coordinates;
    self.multimedia = record.multimedia || [];
    self.eventTime = record.eventTime;
    self.individualCount = ko.observable(record.individualCount);
    self.eventDate =  ko.observable(record.eventDate).extend({simpleDate: false});
    self.thumbnailUrl = ko.observable(record.thumbnailUrl);
};

ActivityRecordViewModel.prototype.getPropertyValue = RecordVM.prototype.getPropertyValue = function (config) {
    var property = this['rawData'][config.propertyName];
    if(!property && this['parent']){
        property = this['parent']['rawData'][config.propertyName];
    }

    property = ko.unwrap(property);

    if (config.dataType == 'date' && ( property instanceof Array)) {
       return property[0]
    } else {
        return property
    }
};

function generateTermId(term) {
    if (_.isFunction(term.facetName)) {
        return term.facetName().replace(/[^a-zA-Z0-9]/g, "") + term.term().replace(/[^a-zA-Z0-9]/g, "")
    } else {
        return term.facetName.replace(/[^a-zA-Z0-9]/g, "") + term.term.replace(/[^a-zA-Z0-9]/g, "")
    }
}