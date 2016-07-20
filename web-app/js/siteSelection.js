function SiteSelectModel(config, projectId, currentProjectSites) {
    var self = this;

    self.config = config;

    self.projectId = projectId;
    self.projects = [projectId];
    self.currentSearch = ko.observable('');
    self.myFavourites = ko.observable(false);
    self.sites = ko.observableArray([]);
    self.matchingSiteCount = ko.observable(0);
    self.currentProjectSites = ko.observableArray(currentProjectSites);

    self.currentPage = ko.observable(0);
    self.totalPages = ko.observable();
    self.perPage = 10;
    self.pagination = new PaginationViewModel({}, self);

    var mapOptions = {
        drawControl: false,
        singleMarker: false,
        useMyLocation: false,
        allowSearchLocationByAddress: false,
        allowSearchRegionByAddress: false,
        draggableMarkers: false,
        showReset: false,
        maxZoom: 100,
        wmsLayerUrl: config.spatialWms + "/wms/reflect?",
        wmsFeatureUrl: config.featureService + "?featureId="
    };

    self.map = new ALA.Map("siteMap", mapOptions);

    self.cancelUpdate = function () {
        document.location.href = config.returnTo;
    };

    self.sitesToAdd = ko.observableArray([]);

    self.addAllMatched = function () {
        $.each(self.sites(), function (idx, site) {
            self.currentProjectSites.push(site.siteId);
        });
    };

    self.clearSites = function () {
        self.currentProjectSites.removeAll();
        $.each(self.sites(), function (idx, site) {
            site.isProjectSite(false);
        });
    };

    self.useSelectedSites = function () {
        var dataToPost = {
            projectId: self.projectId,
            sites: self.currentProjectSites()
        };

        $.ajax({
            url: self.config.updateSitesUrl,
            type: 'POST',
            data: JSON.stringify(dataToPost),
            contentType: 'application/json',
            success: function (data) {
                document.location.href = self.config.returnTo;
            },
            error: function () {
                alert('There was a problem saving this site');
            }
        });
    };

    self.mapSite = function (site) {
        self.map.resetMap();
        self.map.setGeoJSON(Biocollect.MapUtilities.featureToValidGeoJson(site.extent.geometry));
    };

    self.cancel = function () {
        document.location.href = self.config.returnTo;
    };

    self.addSite = function (site) {
        var idxOfSite = self.sites.indexOf(site);
        var _site = self.sites()[idxOfSite];
        _site.isProjectSite(true);
        self.currentProjectSites.push(_site.siteId);
    };

    self.removeSite = function (site) {
        var idxOfSite = self.sites.indexOf(site);
        var _site = self.sites()[idxOfSite];
        _site.isProjectSite(false);
        self.currentProjectSites.remove(_site.siteId);
    };

    self.searchSites = function () {
        self.pagination.currentPage(0)
        self.refreshPage(0);
    };

    self.submitSites = function () {
        alert('Not done - needs to save sites against the project.');
    };


    self.refreshPage = function(offset){
        var query = self.currentSearch();
        var max = self.pagination.resultsPerPage();
        var newOffset = offset;
        var myFavourites = self.myFavourites();
        queryForSites(query, max, newOffset, myFavourites, null);
    }

    self.toggleMyFavourites = function () {
        self.myFavourites(!self.myFavourites());
        self.searchSites();
    }

    function queryForSites(query, max, offset, myFavourites, callbackFcn) {
        $.ajax({
            url: self.config.siteQueryUrl + query + "&max=" + max + "&offset=" + offset+"&myFavourites="+myFavourites,
            type: 'GET',
            contentType: 'application/json',
            success: function (data) {
                self.sites.removeAll();
                self.matchingSiteCount(data.hits.total);

                $.each(data.hits.hits, function (idx, hit) {
                    var isProjectSite = ($.inArray(hit._source.siteId, self.currentProjectSites()) >= 0 );
                    hit._source.isProjectSite = ko.observable(isProjectSite);
                    console.log(JSON.stringify(hit, undefined, 2))
                    console.log("----------")
                    self.sites.push(hit._source);
                });

                if(self.pagination.currentPage() == 0){
                    self.pagination.loadPagination(0, data.hits.total)
                }
                callbackFcn && callbackFcn(data);
            },
            error: function () {
                alert('There was a problem searching for sites.');
            }
        });
    }

    self.searchSites();
}