var ActivitiesAndRecordsViewModel = function (placeHolder, view) {
    var self = this;
    var features, featureType = 'record', alaMap, results;
    self.view = view ? view : 'allrecords';

    self.sortOptions = [
        {id: 'lastUpdated', name: 'Date'},
        {id: 'name', name: 'Survey name'},
        {id: 'activityOwnerName', name: 'Owner name'}];

    var index = 0;
    self.availableFacets = [
        {name: 'projectNameFacet', displayName: 'Project', order: index++},
        {name: 'projectActivityNameFacet', displayName: 'Survey', order: index++},
        {name: 'recordNameFacet', displayName: 'Species', order: index++},
        {name: 'activityOwnerNameFacet', displayName: 'Owner', order: index++},
        {name: 'embargoedFacet', displayName: 'Access', order: index++},
        {name: 'activityLastUpdatedMonthFacet', displayName: 'Month', order: index++},
        {name: 'activityLastUpdatedYearFacet', displayName: 'Year', order: index++}];

    self.orderOptions = [{id: 'ASC', name: 'ASC'}, {id: 'DESC', name: 'DESC'}];
    self.activities = ko.observableArray();
    self.pagination = new PaginationViewModel({}, self);
    self.facets = ko.observableArray();
    self.total = ko.observable(0);
    self.filter = ko.observable(false);
    self.toggleFilter = function () {
        self.filter(!self.filter())
    };
    self.searchView = ko.observable(true);
    self.toggleSearchView = function () {
        self.searchView(!self.searchView())
        $('#search-spinner').hide();
    };
    self.searchTerm = ko.observable();
    self.order = ko.observable('DESC');
    self.sort = ko.observable('lastUpdated');
    self.selectedFilters = ko.observableArray(); // User selected facet filters.
    self.transients = {};
    self.transients.placeHolder = placeHolder;
    self.transients.bieUrl = fcConfig.bieUrl;

    self.sort.subscribe(function (newValue) {
        self.refreshPage();
    });
    self.order.subscribe(function (newValue) {
        self.refreshPage();
    });
    self.searchTerm.subscribe(function (newValue) {
        self.refreshPage();
    });
    self.search = function () {
        self.refreshPage();
    };
    self.reset = function () {
        self.searchTerm('');
        self.order('DESC');
        self.sort('lastUpdated');
        self.refreshPage();
    };
    self.addUserSelectedFacet = function (facet) {
        self.selectedFilters.push(facet);
        self.refreshPage();
    };
    self.removeUserSelectedFacet = function () {
        self.selectedFilters.removeAll();
        self.refreshPage();
    };
    self.removeFilter = function (filter) {
        self.selectedFilters.remove(filter);
        self.refreshPage();
    };
    self.load = function (data, page) {
        var activities = data.activities;
        var facets = data.facets;
        var total = data.total;

        self.activities([]);

        var activities = $.map(activities ? activities : [], function (activity, index) {
            return new ActivityRecordViewModel(activity);
        });
        self.activities(activities);

        var facets = $.map(facets ? facets : [], function (facet, index) {
            return new DataFacetsVM(facet, self.availableFacets);
        });
        self.facets(facets);

        self.facets.sort(function (left, right) {
            return left.order() == right.order() ? 0 : (left.order() < right.order() ? -1 : 1)
        });

        // only initialise the pagination if we are on the first page load
        if (page == 0) {
            self.pagination.loadPagination(page, total);
        }

        self.total(total);
    };
    self.refreshPage = function (offset) {
        if (!offset) offset = 0;

        var params = {
            max: self.pagination.resultsPerPage(),
            offset: offset,
            sort: self.sort(),
            order: self.order(),
            searchTerm: self.searchTerm(),
            flimit: 20,
            view: self.view
        };
        var url = fcConfig.searchProjectActivitiesUrl;
        url = url + ((fcConfig.searchProjectActivitiesUrl.indexOf('?') > -1) ? '&' : '?') + $.param(params);
        var filters = '';
        ko.utils.arrayForEach(self.selectedFilters(), function (term) {
            filters = filters + '&fq=' + term.facetName() + ':' + term.term();
        });
        url = url + filters;

        $.ajax({
            url: url,
            type: 'GET',
            contentType: 'application/json',
            beforeSend: function () {
                $('#search-spinner').show();
            },
            success: function (data) {
                self.load(data, Math.ceil(offset / self.pagination.resultsPerPage()));
            },
            error: function (data) {
                alert('An unhandled error occurred: ' + data);
            },
            complete: function () {
                $('#search-spinner').hide();
                $('.main-content').show();
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

        if (activityUrl && surveyName) {
            html += "<div><i class='icon-home'></i> <a target='_blank' href='" +
                activityUrl + "'>" +surveyName + "</a></div>";
        }

        if(projectName){
            html += "<div><a target='_blank' href="+projectLinkPrefix+projectId+"><i class='icon-map-marker'></i>&nbsp;" +projectName + "</a></div>";
        }

        if(speciesName){
            html += "<div><i class='icon-camera'></i>&nbsp;"+ speciesName + "</div>";
        }

        return html;
    }
    /**
     * function used to create map and plot the fetched points
     */
    self.getDataAndShowOnMap = function () {
        var searchTerm = activitiesAndRecordsViewModel.searchTerm() || '';
        var view = activitiesAndRecordsViewModel.view;
        var url =fcConfig.getRecordsForMapping + '?max=10000&searchTerm='+ searchTerm+'&view=' + view;
        var facetFilters = []
        self.plotOnMap(null);

        if(fcConfig.projectId){
            url += '&projectId=' + fcConfig.projectId;
        }

        ko.utils.arrayForEach(activitiesAndRecordsViewModel.selectedFilters(), function (term) {
            facetFilters.push(term.facetName() + ':' + term.term());
        });

        if (facetFilters && facetFilters.length > 0) {
            url += "&fq=" + facetFilters.join("&fq=");
        }
        alaMap.startLoading();
        $.getJSON(url, function(data) {
            results = data;
            self.generateDotsFromResult(data)
            alaMap.finishLoading();
        }).error(function (request, status, error) {
            console.error("AJAX error", status, error);
            alaMap.finishLoading();
        });
    }

    /**
     * converts ajax data to activities or records according to selection.
     * @param data
     */
    self.generateDotsFromResult = function (data){
        features = [];
        var geoPoints = data;

        if (geoPoints.activities) {
            $.each(geoPoints.activities, function(index, activity) {
                var projectId = activity.projectId
                var projectName = activity.name
                var activityUrl = fcConfig.activityViewUrl+'/'+activity.activityId;

                switch (featureType){
                    case 'record':
                        if (activity.records && activity.records.length > 0) {
                            $.each(activity.records, function(k, el) {
                                if(el.coordinates && el.coordinates.length){
                                    features.push({
                                        lat: el.coordinates[1],
                                        lng: el.coordinates[0],
                                        popup: self.generatePopup(fcConfig.projectLinkPrefix,projectId,projectName, activityUrl, activity.name, el.name)
                                    });
                                }
                            });
                        }
                        break;
                    case 'activity':
                        if(activity.coordinates && activity.coordinates.length){
                            features.push({
                                lat: activity.coordinates[1],
                                lng: activity.coordinates[0],
                                popup: self.generatePopup(fcConfig.projectLinkPrefix,projectId,projectName, activityUrl, activity.name)
                            });
                        }
                        break;
                }
            });
            self.plotOnMap(features);
        }
    }

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
            allowSearchByAddress: false
        }


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
            })
            alaMap.addControl(radio);
            alaMap.addButton("<span class='fa fa-refresh' title='Reset zoom'></span>", alaMap.fitBounds, "bottomleft");
        } else {
            alaMap.resetMap();
        }

        features && features.length && alaMap.addClusteredPoints(features)
    }

    /**
     * function called when  radio button selection changes.
     * @param value
     */
    self.getActivityOrRecords = function(value){
        featureType = value;
        self.generateDotsFromResult(results);
    }

    /**
     * when map is updated on invisible, this function is used to redraw the map.
     */
    self.invalidateSize = function(){
        alaMap.getMapImpl().invalidateSize();
    }


    // listen to facet change event so that map can be updated.
    self.selectedFilters.subscribe(self.getDataAndShowOnMap)
    self.searchTerm.subscribe(self.getDataAndShowOnMap)

    self.refreshPage();
};

var ActivityRecordViewModel = function (activity) {
    var self = this;
    if (!activity) activity = {};

    self.activityId = ko.observable(activity.activityId);
    self.showCrud = ko.observable(activity.showCrud);
    self.projectActivityId = ko.observable(activity.projectActivityId);
    self.name = ko.observable(activity.name);
    self.type = ko.observable(activity.type);
    self.lastUpdated = ko.observable(activity.lastUpdated).extend({simpleDate: false});
    self.ownerName = ko.observable(activity.activityOwnerName);
    self.userId = ko.observable(activity.userId);
    self.siteId = ko.observable(activity.siteId);
    self.embargoed = ko.observable(activity.embargoed);
    self.embargoUntil = ko.observable(activity.embargoUntil).extend({simpleDate: false});
    self.projectName = ko.observable(activity.projectName);
    self.projectId = ko.observable(activity.projectId);
    self.projectUrl = ko.pureComputed(function () {
        return fcConfig.projectIndexUrl + '/' + self.projectId();
    });
    self.records = ko.observableArray();
    self.siteUrl = fcConfig.siteViewUrl + '/' + self.siteId();
    var projectActivityOpen = true;
    if (activity.endDate) {
        projectActivityOpen = moment(activity.endDate).isAfter(moment());
    }
    self.showAdd = ko.observable(projectActivityOpen);

    var allRecords = $.map(activity.records ? activity.records : [], function (record, index) {
        return new RecordVM(record);
    });
    self.records(allRecords);

    self.transients = {};
    self.transients.viewUrl = ko.observable(fcConfig.activityViewUrl + "/" + self.activityId()).extend({returnTo: fcConfig.returnTo});
    self.transients.editUrl = ko.observable(fcConfig.activityEditUrl + "/" + self.activityId()).extend({returnTo: fcConfig.returnTo});
    self.transients.addUrl = ko.observable(fcConfig.activityAddUrl + "/" + self.projectActivityId()).extend({returnTo: fcConfig.returnTo});
};

var RecordVM = function (record) {
    var self = this;
    if (!record) record = {};

    self.occurrenceID = ko.observable(record.occurrenceID);
    self.guid = ko.observable(record.guid);
    self.name = ko.observable(record.name);
};

var DataFacetsVM = function (facet, availableFacets) {
    var self = this;
    if (!facet) facet = {};

    self.name = ko.observable(facet.name);
    self.total = ko.observable(facet.total);
    self.terms = ko.observableArray();
    self.filter = ko.observable(false);
    self.toggleFilter = function () {
        self.filter(!self.filter())
    };
    self.displayText = ko.pureComputed(function () {
        return getFacetName(self.name()) + " (" + self.total() + ")";
    });
    self.order = ko.pureComputed(function () {
        return getFacetOrder(self.name());
    });

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

    self.facetName = ko.observable(term.facetName);
    self.facetDisplayName = ko.observable(term.facetDisplayName);
    self.count = ko.observable(term.count);
    self.term = ko.observable(term.term);
    self.displayText = ko.pureComputed(function () {
        return self.term() + " (" + self.count() + ")";
    });
};