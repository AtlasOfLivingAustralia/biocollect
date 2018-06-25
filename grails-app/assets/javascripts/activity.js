var ActivitiesAndRecordsViewModel = function (placeHolder, view, user, ignoreMap, doNotInit, doNotStoreFacetFiltering) {
    var self = this;

    var features, featureType = 'record', alaMap, results, radio;
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
        fetchDataForTabs()
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

    self.remove = function (activity) {
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
    self.generatePopup = function (projectLinkPrefix, projectId, projectName, activityUrl, surveyName, speciesName, imageUrl){
        var template =
            '    <div>' +
            '      IMAGE_TAG' +
            '      SPECIES_NAME' +
            '      ACTIVITY_LINK' +
            '      PROJECT_LINK' +
            '    </div>';

        var version = fcConfig.version === undefined ? "" : "?version=" + fcConfig.version
        var activityTemp = "";
        if (activityUrl && surveyName) {
            activityTemp = "<div><i class='icon-home'></i> <a target='_blank' href='" +
                activityUrl + version +"'>" +surveyName + " (record)</a></div>";
        }
        template = template.replace("ACTIVITY_LINK", activityTemp);

        var projectTemp = "";
        if(projectName && !fcConfig.hideProjectAndSurvey){
            projectTemp ="<div><a target='_blank' href="+projectLinkPrefix+projectId+version+"><i class='icon-map-marker'></i>&nbsp;" +projectName + " (project)</a></div>";
        }
        template = template.replace("PROJECT_LINK", projectTemp);

        var speciesTemp = "";
        if (speciesName) {
            speciesTemp = "<strong><i class='icon-camera'></i>&nbsp;" + speciesName + "</strong>";
        }
        template = template.replace("SPECIES_NAME", speciesTemp);

        var image = "";
        if(imageUrl) {
            image = "<div class='projectLogo'><img class='image-logo image-window' onload='findLogoScalingClass(this, 200, 150)' src='" + imageUrl + "'/></div>"
        }

        template = template.replace('IMAGE_TAG', image);
        return template;
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

        fq.forEach(function (filter, index) {
            fq[index] = encodeURI(filter)
        });

        if(fq.length){
            url += '&fq=' + fq.join('&fq=');
        }

        self.transients.loadingMap(true);
        alaMap.startLoading();
        $.getJSON(url, function(data) {
            self.transients.loadingMap(false);
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
        var geoPoints = data, type;

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
                                    var type = el.individualCount == 0 ? 'icon' : 'circle';
                                    var imageUrl = el.multimedia && el.multimedia[0] &&  el.multimedia[0].identifier;
                                    features.push({
                                        // the ES index always returns the coordinate array in [lat, lng] order
                                        lat: el.coordinates[0],
                                        lng: el.coordinates[1],
                                        popup: self.generatePopup(fcConfig.projectLinkPrefix,projectId,projectName, activityUrl, activity.name, el.name, imageUrl),
                                        type: type
                                    });
                                }
                            });
                        }
                        type = 'point';
                        break;
                    case 'activity':
                        if(activity.coordinates && activity.coordinates.length && activity.coordinates[1] && !isNaN(activity.coordinates[1]) && activity.coordinates[0] && !isNaN(activity.coordinates[0])){
                            // get image from records
                            var imageUrl;
                            activity.records = activity.records || [];
                            for(var i = 0; (i < activity.records.length) && !imageUrl; i++){
                                var el = activity.records[i];
                                imageUrl = el.multimedia && el.multimedia[0] &&  el.multimedia[0].identifier
                            }

                            features.push({
                                // the ES index always returns the coordinate array in [lat, lng] order
                                lng: activity.coordinates[0],
                                lat: activity.coordinates[1],
                                popup: self.generatePopup(fcConfig.projectLinkPrefix,projectId,projectName, activityUrl, activity.name, null, imageUrl)
                            });
                        }
                        type = 'cluster';
                        break;
                }
            });

            if(features.length > 0) {
                self.plotOnMap(features, type);
            }
            // if no records found, then display activities
            else if (featureType == 'record') {
                var type = 'activity';
                self.updateActivityRecordRadioButton(type, radio);
                self.getActivityOrRecords(type);
            }
        }
    };


    /**
     * A hack to update activity or record radio buttons.
     * @param value - value of radio button to be checked - 'activity' or 'record'
     * @param radio - leaflet radio button control
     */
    self.updateActivityRecordRadioButton = function (value, radio) {
        $(radio._container).find('input[value="' + value + '"]').prop('checked', true);
    };

    /**
     * creates the map and plots the points on map
     * @param features
     */
    self.plotOnMap = function (features, drawType){
        drawType = drawType || 'cluster';

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
                position: 'topleft',
                radioButtons:[{
                    displayName: 'Points ( Species occurrences )',
                    value: 'record',
                    checked: true
                },{
                    displayName: 'Cluster ( Site visits )',
                    value: 'activity'
                }],
                onClick: self.getActivityOrRecords
            });
            alaMap.addControl(radio);
            alaMap.addButton("<span class='fa fa-refresh reset-map' title='Reset zoom'></span>", alaMap.fitBounds, "bottomleft");
            self.addLegend()
        }

        self.transients.totalPoints(features && features.length ? features.length : 0);
        if(features && features.length){
            switch (drawType){
                case 'cluster':
                    alaMap.addClusteredPoints(features);
                    break;
                case 'point':
                    alaMap.addPointsOrIcons(features, {}, fcConfig.absenceIconUrl, {
                        iconSize:     [20, 18],
                        iconAnchor:   [10, 9],
                        popupAnchor:  [0, -9]
                    });
                    break;
            }
        }

        alaMap.redraw()
    };


    self.addLegend = function () {
        var Legend = L.Control.extend({
            options: {
                position: "bottomright",
                title: 'Legend'
            },
            onAdd: function (map) {
                var container = L.DomUtil.create("div", "leaflet-control-layers");
                this.container = container;
                $(container).html("<div style='padding:10px'>" + $('#map-legend').html() + "</div>");
                return container;
            }
        });

        alaMap.addControl(new Legend());
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

    function constructQueryUrl(prefix, offset, facetOnly, flimit) {
        if (!offset) offset = 0;

        var params = {
            max: self.pagination.resultsPerPage(),
            offset: offset,
            sort: self.sort(),
            order: self.order(),
            flimit: flimit || fcConfig.flimit,
            view: self.view,
            spotterId: fcConfig.spotterId,
            projectActivityId: fcConfig.projectActivityId,
            clientTimezone : moment.tz.guess()
        },
            fq = [],
            rfq;


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

        self.refreshPage();
        self.getDataAndShowOnMap();
        self.imageGallery && self.imageGallery.fetchRecordImages()
    }

    self.filterViewModel.selectedFacets.subscribe(fetchDataForTabs);

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
    self.transients.thumbnailUrl = ko.observable(activity.thumbnailUrl ||  fcConfig.imageLocation + "no-image-2.png");
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
    self.individualCount = ko.observable(record.individualCount);
    self.eventDate =  ko.observable(record.eventDate).extend({simpleDate: false});
};

function generateTermId(term) {
    if (_.isFunction(term.facetName)) {
        return term.facetName().replace(/[^a-zA-Z0-9]/g, "") + term.term().replace(/[^a-zA-Z0-9]/g, "")
    } else {
        return term.facetName.replace(/[^a-zA-Z0-9]/g, "") + term.term.replace(/[^a-zA-Z0-9]/g, "")
    }
}