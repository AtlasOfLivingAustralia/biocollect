var ActivitiesAndRecordsViewModel = function (placeHolder, view, user, ignoreMap, doNotInit) {
    var self = this;

    var features, featureType = 'record', alaMap, results;
    self.view = view ? view : 'allrecords';
    var DEFAULT_EMAIL_DOWNLOAD_THRESHOLD = 500;

    // These parameters are used when activity is instantiated from sites page.
    // It is used to disable certain aspects like map and auto load feature
    ignoreMap = !!ignoreMap;
    doNotInit = !!doNotInit;

    self.sortOptions = [
        {id: 'lastUpdated', name: 'Date', order: 'DESC'},
        {id: 'activityOwnerName', name: 'Owner name', order: 'ASC'}];

    var index = 0;

    self.availableFacets = [
        {name: 'projectNameFacet', displayName: 'Project', order: index++},
        {name: 'organisationNameFacet', displayName: 'Organisation', order: index++},
        {name: 'projectActivityNameFacet', displayName: 'Survey', order: index++},
        {name: 'recordNameFacet', displayName: 'Species', order: index++},
        {name: 'activityOwnerNameFacet', displayName: 'Owner', order: index++},
        {name: 'embargoedFacet', displayName: 'Access', order: index++},
        {name: 'activityLastUpdatedMonthFacet', displayName: 'Month', order: index++},
        {name: 'activityLastUpdatedYearFacet', displayName: 'Year', order: index++}];

    index=0;

    self.projectAvailableFacets = [
        {name: 'projectActivityNameFacet', displayName: 'Survey', order: index++},
        {name: 'recordNameFacet', displayName: 'Species', order: index++},
        {name: 'activityOwnerNameFacet', displayName: 'Owner', order: index++},
        {name: 'embargoedFacet', displayName: 'Access', order: index++},
        {name: 'activityLastUpdatedMonthFacet', displayName: 'Month', order: index++},
        {name: 'activityLastUpdatedYearFacet', displayName: 'Year', order: index++}]

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
        $('#search-spinner').hide();
    };

    self.searchTerm = ko.observable('');
    self.order = ko.observable('DESC');
    self.sort = ko.observable('lastUpdated');
    self.selectedFilters = ko.observableArray(); // User selected facet filters.
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
    
    self.searchTerm.subscribe(function (newValue) {
        self.refreshPage();
    });

    self.search = function () {
        self.refreshPage();
    };

    self.clearData = function() {
        self.searchTerm('');
        self.order('DESC');
        self.sort('lastUpdated');
        alaMap.resetMap();
    };

    self.reset = function () {
        self.clearData();
        self.selectedFilters([]);
        self.refreshPage(0);
    };

    var facetsLocalStorageHandler = function (cmd) {
        var orgTerm = fcConfig.organisationName;
        if (!orgTerm) {
            var key = self.view.toUpperCase() + '_DATA_PAGE_FACET_KEY';
            switch (cmd) {
                case 'store':
                    var facets = [];
                    ko.utils.arrayForEach(self.selectedFilters(), function (filter) {
                        var value = {};
                        value.term = filter.term();
                        value.facetDisplayName = filter.facetDisplayName();
                        value.facetName = filter.facetName();
                        facets.push(value);
                    });
                    amplify.store(key, facets);
                    break;

                case 'restore':
                default:
                    return amplify.store(key);
            }
        }
    };

    self.selectFacetTerm = function (term, facetGroup) {
        self.resetFacetsAndSelect(term, facetGroup);
    };

    self.addUserSelectedFacet = function (facet) {
        self.selectedFilters.push(facet);
        self.refreshPage();
    };

    self.removeUserSelectedFacet = function () {
        self.selectedFilters.removeAll();
        self.refreshPage(0);
    };

    self.removeFilter = function (filter) {
        self.selectedFilters.remove(filter);
        self.refreshPage();
    };

    self.canFacetBeDisplayed = function(facetModel, whiteList){
        var found = $.grep(whiteList, function (obj, i) {
            return (obj.name == facetModel.name());
        });

        return found.length > 0;
    }

    self.load = function (data, page) {
        var activities = data.activities;
        var facets = data.facets;
        var total = data.total;

        self.activities([]);

        activities = $.map(activities ? activities : [], function (activity, index) {
            activity.parent = self;
            return new ActivityRecordViewModel(activity);
        });
        self.activities(activities);

        facets = $.map(facets ? facets : [], createFacetModelAndSetVisibility);
        self.facets(facets);

        self.facets.sort(function (left, right) {
            return left.order() == right.order() ? 0 : (left.order() < right.order() ? -1 : 1)
        });

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
                $('#search-spinner').show();
            },
            success: function (data) {
                self.load(data, Math.ceil(offset / self.pagination.resultsPerPage()));
                facetsLocalStorageHandler('store');
            },
            error: function (data) {
                alert('An unhandled error occurred: ' + data);
            },
            complete: function () {
                $('#search-spinner').hide();
                $('.main-content').show();
                self.transients.loading(false);
            }
        });
    };

    self.refineSearch = function() {
        var terms = getSelectedTermsForRefinement();
        terms.forEach(function (term) {
            self.selectedFilters.push(term);
        });
        self.refreshPage();
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

    self.resetFacetsAndSelect = function(term, facetGroup) {
        var url = constructQueryUrl(fcConfig.searchProjectActivitiesUrl, 0, true);

        self.transients.loading(true);
        $.ajax({
            url: url,
            type: 'GET',
            contentType: 'application/json',
            beforeSend: function () {
                $('#search-spinner').show();
            },
            success: function (data) {
                var facets = data.facets;

                facets = $.map(facets ? facets : [], createFacetModelAndSetVisibility);
                facets.sort(function (left, right) {
                    return left.order() == right.order() ? 0 : (left.order() < right.order() ? -1 : 1)
                });

                self.facets(facets);

                var selectedFacet = null;

                self.facets().forEach(function (facet) {
                    var match = facet.findTerm(term);

                    if (match != null) {
                        selectedFacet = match;
                    }
                });

                if (selectedFacet == null) {
                    selectedFacet = new TermFacetVM({
                        term: term,
                        facetName: facetGroup,
                        facetDisplayName: facetGroup
                    })
                }

                self.selectedFilters([selectedFacet]);

                self.refreshPage();
            },
            error: function (data) {
                alert('An unhandled error occurred: ' + data);
            },
            complete: function () {
                $('#search-spinner').hide();
                $('.main-content').show();
                self.transients.loading(false);
            }
        });
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

        if(projectName){
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
        self.plotOnMap(null);

        if(fcConfig.projectId){
            url += '&projectId=' + fcConfig.projectId;
        }

        ko.utils.arrayForEach(self.selectedFilters(), function (term) {
            facetFilters.push(term.facetName() + ':' + term.term());
        });

        if (facetFilters && facetFilters.length > 0) {
            url += "&fq=" + facetFilters.join("&fq=");
        }
        alaMap.startLoading();
        $.getJSON(url, function(data) {
            results = data;
            self.generateDotsFromResult(data);
            alaMap.finishLoading();
            self.transients.loadingMap(false)
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
        ko.utils.arrayForEach(activitiesAndRecordsViewModel.selectedFilters(), function (term) {
            facetFilters.push(term.facetName() + ':' + term.term());
        });
        return facetFilters;
    };

    function constructQueryUrl(prefix, offset, facetOnly) {
        if (!offset) offset = 0;

        var params = {
            max: self.pagination.resultsPerPage(),
            offset: offset,
            sort: self.sort(),
            order: self.order(),
            flimit: 1000,
            view: self.view
        };

        var filters = '';
        if (_.isUndefined(facetOnly) || !facetOnly) {
            params.searchTerm = self.searchTerm().trim();

            ko.utils.arrayForEach(self.selectedFilters(), function (term) {
                filters = filters + '&fq=' + term.facetName() + ':' + term.term();
            });
        }

        url = prefix + ((prefix.indexOf('?') > -1) ? '&' : '?') + $.param(params);

        return url + filters;
    }

    function createFacetModelAndSetVisibility(facet, index) {
        var displayableFacets, facetModel;
        switch (self.view){
            case 'project':
                displayableFacets = self.projectAvailableFacets;
                break;
            default :
                displayableFacets = self.availableFacets;
                break;
        }

        facetModel = new DataFacetsVM(facet, displayableFacets);
        self.canFacetBeDisplayed(facetModel, displayableFacets) ? facetModel.visible(true) : facetModel.visible(false);
        return facetModel
    }

    // listen to facet change event so that map can be updated.
    self.selectedFilters.subscribe(self.getDataAndShowOnMap);
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
        self.selectedFilters.push(new TermFacetVM({
            term: orgTerm,
            facetName: "organisationNameFacet",
            facetDisplayName: 'Organisation'
        }));
        self.refreshPage();
    } else if (restored && restored.length > 0) {
        $.each(restored, function (index, value) {
            self.selectedFilters.push(new TermFacetVM({
                term: value.term ? value.term : '',
                facetName: value.facetName ? value.facetName : '',
                facetDisplayName: value.facetDisplayName ? value.facetDisplayName : ''
            }));
        });

        !doNotInit && self.refreshPage();
    }
    else {
        !doNotInit && self.refreshPage();
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
    self.transients.viewUrl = ko.observable(fcConfig.activityViewUrl + "/" + self.activityId()).extend({returnTo: fcConfig.returnTo, dataVersion: fcConfig.version});
    self.transients.editUrl = ko.observable(fcConfig.activityEditUrl + "/" + self.activityId()).extend({returnTo: fcConfig.returnTo});
    self.transients.addUrl = ko.observable(fcConfig.activityAddUrl + "/" + self.projectActivityId()).extend({returnTo: fcConfig.returnTo});
    self.transients.parent = activity.parent;
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

var DataFacetsVM = function (facet, availableFacets) {
    var self = this;
    var LIMIT = 15;
    if (!facet) facet = {};

    self.name = ko.observable(facet.name);
    self.total = ko.observable(facet.total);
    self.terms = ko.observableArray();
    self.filter = ko.observable(false);
    self.visible = ko.observable(true);

    self.toggleFilter = function () {
        self.filter(!self.filter())
    };

    self.displayText = ko.pureComputed(function () {
        return getFacetName(self.name()) + " (" + self.total() + ")";
    });

    self.order = ko.pureComputed(function () {
        return getFacetOrder(self.name());
    });

    self.searchTerm = ko.observable('');
    /**
     * search for a token and show terms matching the token.
     */
    self.search = function(){
        var terms = self.terms(), text, regex;
        regex = new RegExp(self.searchTerm(), 'i');
        terms.forEach(function(term){
            text = term.displayText();
            if(text && text.match(regex, 'i')){
                term.showTerm() || term.showTerm(true);
            } else {
                term.showTerm(false);
            }
        });
    };

    self.findTerm = function(termName) {
        var match = null;

        self.terms().forEach(function(term) {
            if (term.term() == termName) {
                match = term;
            }
        });

        return match;
    };

    self.searchTerm.subscribe(self.search);

    /**
     * show filter input box only when facet terms are more than the specified limit.
     * @returns {boolean}
     */
    self.showFilter = function(){
        if(self.terms().length > LIMIT){
            return true;
        }

        return false;
    };

    var getFacetName = function (name) {
        var found = $.grep(availableFacets, function (obj, i) {
            return (obj.name == name);
        });
        return found.length > 0 ? found[0].displayName : 'Not Categorized';
    };

    var getFacetOrder = function (name) {
        var found = $.grep(availableFacets, function (obj, i) {
            return (obj.name == name);
        });
        return found.length > 0 ? found[0].order : 0;

    };

    var terms = $.map(facet.terms ? facet.terms : [], function (term, index) {
        term.facetName = self.name();
        term.facetDisplayName = getFacetName(self.name());
        return new TermFacetVM(term);
    });

    self.terms(terms);
};

var TermFacetVM = function (term) {
    var self = this;
    if (!term) term = {};

    self.id = ko.observable(generateTermId(term));
    self.selected = ko.observable(false);
    self.facetName = ko.observable(term.facetName);
    self.facetDisplayName = ko.observable(term.facetDisplayName);
    self.count = ko.observable(term.count);
    self.term = ko.observable(term.term);
    self.showTerm = ko.observable(term.showTerm || true);
    self.displayText = ko.pureComputed(function () {
        return self.term() + " (" + self.count() + ")";
    });
};

function generateTermId(term) {
    if (_.isFunction(term.facetName)) {
        return term.facetName().replace(/[^a-zA-Z0-9]/g, "") + term.term().replace(/[^a-zA-Z0-9]/g, "")
    } else {
        return term.facetName.replace(/[^a-zA-Z0-9]/g, "") + term.term.replace(/[^a-zA-Z0-9]/g, "")
    }
}