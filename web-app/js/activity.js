var ActivitiesAndRecordsViewModel = function (placeHolder, view, user, ignoreMap, doNotInit, doNotStoreFacetFiltering) {
    var self = this;

    var features, featureType = 'record', alaMap, results;
    self.view = view ? view : 'allrecords';
    var DEFAULT_EMAIL_DOWNLOAD_THRESHOLD = 500;

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

    self.version = ko.observable(fcConfig.version)
    
    self.toggleFilter = function () {
        self.filter(!self.filter())
    };

    self.searchView = ko.observable(true);

    self.toggleSearchView = function () {
        self.searchView(!self.searchView());
    };

    self.searchTerm = ko.observable('');
    self.order = ko.observable('DESC');
    self.sort = ko.observable('lastUpdated');

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

    self.sort.subscribe(function (newValue) {
        self.refreshPage();
    });

    self.search = function () {
        self.refreshPage();
        self.getDataAndShowOnMap();
        self.imageGallery && self.imageGallery.fetchRecordImages()
    };

    self.clearData = function() {
        self.searchTerm('');
        self.order('DESC');
        self.sort('lastUpdated');
        alaMap.resetMap();
    };

    self.reset = function () {
        self.clearData();
        self.filterViewModel.selectedFacets.removeAll();
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
                            var value = {};
                            value.term = filter.term();
                            value.title = filter.facet.title;
                            value.name = filter.facet.name();
                            value.exclude = filter.exclude;
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
    }

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

    self.delete = function (activity) {
        bootbox.confirm("Are you sure you want to delete the survey and records?", function (result) {
            if (result) {
                var url = fcConfig.activityDeleteUrl + "/" + activity.activityId();
                $.ajax({
                    url: url,
                    type: 'DELETE',
                    contentType: 'application/json',
                    success: function (data) {
                        if (data.text == 'deleted') {
                            showAlert("Successfully deleted. Indexing is in process, search result will be updated in few minutes.", "alert-success", self.transients.placeHolder);
                            setTimeout(function () {
                                location.reload();
                            }, 3000);
                        } else {
                            showAlert("Error deleting the survey, please try again later.", "alert-error", self.transients.placeHolder);
                        }
                    },
                    error: function (data) {
                        if (data.status == 401) {
                            var message = $.parseJSON(data.responseText);
                            bootbox.alert(message.error);
                        } else if (data.status == 404) {
                            showAlert("Record not available. Indexing might be in process, refreshing the page now..", "alert-error", self.transients.placeHolder);
                            setTimeout(function () {
                                location.reload();
                            }, 3000);
                        } else {
                            alert('An unhandled error occurred: ' + data);
                        }
                    }
                });
            }
        });
    };

    /**
     * creates popup on the map
     * @param projectLinkPrefix
     * @param projectId
     * @param projectName
     * @param activityUrl
     * @param surveyName
     * @param speciesName
     * @returns {string}
     */
    self.generatePopup = function (projectLinkPrefix, projectId, projectName, activityUrl, surveyName, speciesName){
        var html = "<div class='projectInfoWindow'>";
        var version = fcConfig.version === undefined ? "" : "?version=" + fcConfig.version

        if (activityUrl && surveyName) {
            html += "<div><i class='icon-home'></i> <a target='_blank' href='" +
                activityUrl + version +"'>" +surveyName + " (record)</a></div>";
        }

        if(projectName && !fcConfig.hideProjectAndSurvey){
            html += "<div><a target='_blank' href="+projectLinkPrefix+projectId+version+"><i class='icon-map-marker'></i>&nbsp;" +projectName + " (project)</a></div>";
        }

        if(speciesName){
            html += "<div><i class='icon-camera'></i>&nbsp;"+ speciesName + "</div>";
        }

        return html;
    };

    /**
     * function used to create map and plot the fetched points
     */
    self.getDataAndShowOnMap = function () {
        // do not execute code if ignoreMap is set. helpful in situations where map is not included
        if(ignoreMap){
            return;
        }

        var searchTerm = self.searchTerm() || '';
        var view = self.view;
        var url =fcConfig.getRecordsForMapping + '&max=10000&searchTerm='+ searchTerm+'&view=' + view;
        var facetFilters = [];
        var fq;

        self.plotOnMap(null);

        if(fcConfig.projectId){
            url += '&projectId=' + fcConfig.projectId;
        }

        fq = self.urlFacetParameter();

        if(fq.length){
            url += '&fq=' + fq.join('&fq=');
        }

        alaMap.startLoading();
        $.getJSON(url, function(data) {
            self.transients.loadingMap(false)
            results = data;
            self.generateDotsFromResult(data);
            alaMap.finishLoading();
        }).error(function (request, status, error) {
            console.error("AJAX error", status, error);
            alaMap.finishLoading();
        });
    };

    /**
     * converts ajax data to activities or records according to selection.
     * @param data
     */
    self.generateDotsFromResult = function (data){
        features = [];
        var geoPoints = data;

        if (geoPoints.activities) {
            $.each(geoPoints.activities, function(index, activity) {
                var projectId = activity.projectId;
                var projectName = activity.name;
                var activityUrl = fcConfig.activityViewUrl+'/'+activity.activityId;

                switch (featureType){
                    case 'record':
                        if (activity.records && activity.records.length > 0) {
                            $.each(activity.records, function(k, el) {
                                if(el.coordinates && el.coordinates.length && el.coordinates[1] && !isNaN(el.coordinates[1]) && el.coordinates[0] && !isNaN(el.coordinates[0])){
                                    features.push({
                                        // the ES index always returns the coordinate array in [lat, lng] order
                                        lat: el.coordinates[0],
                                        lng: el.coordinates[1],
                                        popup: self.generatePopup(fcConfig.projectLinkPrefix,projectId,projectName, activityUrl, activity.name, el.name)
                                    });
                                }
                            });
                        }
                        break;
                    case 'activity':
                        if(activity.coordinates && activity.coordinates.length && activity.coordinates[1] && !isNaN(activity.coordinates[1]) && activity.coordinates[0] && !isNaN(activity.coordinates[0])){
                            features.push({
                                // the ES index always returns the coordinate array in [lat, lng] order
                                lng: activity.coordinates[0],
                                lat: activity.coordinates[1],
                                popup: self.generatePopup(fcConfig.projectLinkPrefix,projectId,projectName, activityUrl, activity.name)
                            });
                        }
                        break;
                }
            });
            self.plotOnMap(features);
        }
    };

    /**
     * creates the map and plots the points on map
     * @param features
     */
    self.plotOnMap = function (features){
        var radio;

        var mapOptions = {
            drawControl: false,
            showReset: false,
            draggableMarkers: false,
            useMyLocation: false,
            allowSearchLocationByAddress: false,
            allowSearchRegionByAddress: false,
        };

        if(!alaMap){
            self.transients.alaMap = alaMap = new ALA.Map("recordOrActivityMap", mapOptions);
            radio = new L.Control.Radio({
                name: 'activityOrRecrodsTEST',
                potion: 'topright',
                radioButtons:[{
                    displayName: 'Records',
                    value: 'record',
                    checked: true
                },{
                    displayName: 'Activity',
                    value: 'activity'
                }],
                onClick: self.getActivityOrRecords
            });
            alaMap.addControl(radio);
            alaMap.addButton("<span class='fa fa-refresh reset-map' title='Reset zoom'></span>", alaMap.fitBounds, "bottomleft");
        }

        self.transients.totalPoints(features && features.length ? features.length : 0);
        features && features.length && alaMap.addClusteredPoints(features);
        alaMap.redraw()
    };

    /**
     * function called when  radio button selection changes.
     * @param value
     */
    self.getActivityOrRecords = function(value){
        featureType = value;
        self.generateDotsFromResult(results);
    };

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

    function constructQueryUrl(prefix, offset, facetOnly, flimit) {
        if (!offset) offset = 0;

        var params = {
            max: self.pagination.resultsPerPage(),
            offset: offset,
            sort: self.sort(),
            order: self.order(),
            flimit: flimit || fcConfig.flimit,
            view: self.view
        },
            fq = [];


        var filters = '';
        if (_.isUndefined(facetOnly) || !facetOnly) {
            params.searchTerm = self.searchTerm().trim();

            fq = self.urlFacetParameter();

            if(fq.length){
                filters = '&fq=' + fq.join('&fq=');
            }
        }

        url = prefix + ((prefix.indexOf('?') > -1) ? '&' : '?') + $.param(params);

        return url + filters;
    }

    function fetchDataForTabs(){
        self.refreshPage();
        self.getDataAndShowOnMap();
        self.imageGallery && self.imageGallery.fetchRecordImages()
    }

    self.filterViewModel.selectedFacets.subscribe(fetchDataForTabs);

    // listen to facet change event so that map can be updated.
    self.searchTerm.subscribe(self.getDataAndShowOnMap);

    self.sortButtonClick = function(data){
        // remove subscribe event on order so that we can set it and page will not refresh. will only refresh when
        // sort is set.
        self.order(data.order);
        self.sort(data.id);
    };

    var restored = facetsLocalStorageHandler("restore");
    var orgTerm = fcConfig.organisationName;
    if (orgTerm) {
        self.filterViewModel.selectedFacets.push(new FacetTermViewModel({
            term: orgTerm,
            facet: {
                name: ko.observable( "organisationNameFacet" ),
                title: ko.observable( 'Organisation' ),
                ref: self.filterViewModel
            }
        }));
    } else if (restored && restored.length > 0) {
        var selectedFacets = []
        $.each(restored, function (index, value) {
            selectedFacets.push(new FacetTermViewModel({
                term: value.term || '',
                exclude: value.exclude,
                facet: {
                    name: ko.observable(value.name || ''),
                    title: ko.observable(value.title || ''),
                    ref: self.filterViewModel
                }
            }));
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

    self.activityId = ko.observable(activity.activityId);
    self.showCrud = ko.observable(activity.showCrud);
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
    self.records = ko.observableArray();
    self.siteUrl = fcConfig.siteViewUrl + '/' + self.siteId();
    var projectActivityOpen = true;
    if (activity.endDate) {
        projectActivityOpen = moment(activity.endDate).isAfter(moment());
    }
    self.showAdd = ko.observable(projectActivityOpen);
    self.readOnly = ko.observable(fcConfig.version.length > 0)//183,238,252

    var allRecords = $.map(activity.records ? activity.records : [], function (record, index) {
        return new RecordVM(record);
    });
    self.records(allRecords);

    self.transients = {};
    self.transients.viewUrl = ko.observable((self.isWorksProject() ? fcConfig.worksActivityViewUrl : fcConfig.activityViewUrl) + "/" + self.activityId()).extend({returnTo: fcConfig.returnTo, dataVersion: fcConfig.version});
    self.transients.editUrl = ko.observable((self.isWorksProject() ? fcConfig.worksActivityEditUrl : fcConfig.activityEditUrl) + "/" + self.activityId()).extend({returnTo: fcConfig.returnTo});
    self.transients.addUrl = ko.observable(fcConfig.activityAddUrl + "/" + self.projectActivityId()).extend({returnTo: fcConfig.returnTo});
    self.transients.parent = activity.parent;
    self.transients.thumbnailUrl = ko.observable(activity.thumbnailUrl ||  fcConfig.imageLocation + "/no-image-2.png");
    self.transients.imageTitle = ko.observable(activity.thumbnailUrl? '' : 'No image' );
};

var RecordVM = function (record) {
    var self = this;
    if (!record) record = {};

    self.occurrenceID = ko.observable(record.occurrenceID);
    self.guid = ko.observable(record.guid);
    self.name = ko.observable(record.name);
    self.commonName = record.commonName;
    self.coordinates = record.coordinates;
    self.multimedia = record.multimedia || [];
    self.eventTime = record.eventTime;
    self.eventDate =  ko.observable(record.eventDate).extend({simpleDate: false});
};

function generateTermId(term) {
    if (_.isFunction(term.facetName)) {
        return term.facetName().replace(/[^a-zA-Z0-9]/g, "") + term.term().replace(/[^a-zA-Z0-9]/g, "")
    } else {
        return term.facetName.replace(/[^a-zA-Z0-9]/g, "") + term.term.replace(/[^a-zA-Z0-9]/g, "")
    }
}