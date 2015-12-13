function SiteSelectModel(config, projectId, currentProjectSites) {
    var self = this;

    self.config = config;

    self.projectId = projectId;
    self.projects = [projectId];
    self.currentSearch = ko.observable('');
    self.sites = ko.observableArray([]);
    self.matchingSiteCount = ko.observable(0);
    self.currentProjectSites = ko.observableArray(currentProjectSites);

    self.currentPage = ko.observable(0);
    self.totalPages = ko.observable();
    self.perPage = 10;

    var mapOptions = {
        drawControl: false,
        singleMarker: false,
        useMyLocation: false,
        allowSearchByAddress: false,
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
        var max = 10;
        var offset = 0;

        queryForSites(self.currentSearch(), max, offset, function (data) {
            $('#total').html(data.hits.total);
            $('#offset').html(0);

            if (data.hits.total > 10) {
                initialisePagination(self.currentSearch(), 10, 0, data.hits.total);
            } else {
                $('#paginateTable').hide();
            }
        });
    };

    self.submitSites = function () {
        alert('Not done - needs to save sites against the project.');
    };

    function initialisePagination(query, pageSize, offset, total) {
        var table = $('#paginateTable');
        table.show();
        table.data('query', query);
        table.data('max', pageSize);
        table.data('offset', offset);
        table.data('total', total);
        $('#paginateTable .prev').addClass("disabled");

        $('#paginateTable .next').click(paginateNext)
        $('#paginateTable .prev').click(paginatePrev)
    }

    function paginateNext() {
        var table = $('#paginateTable');
        if (table.data('offset') + table.data('max') > table.data('total')) {
            return;
        }

        var query = table.data('query');
        var max = table.data('max');
        var total = table.data('total');
        var newOffset = table.data('offset') + max;

        console.log('newOffset: ' + newOffset + ', total: ' + total + ', max: ' + max);
        //increment the stored offset
        table.data('offset', newOffset);

        //debug
        $('#offset').html(newOffset);

        queryForSites(query, max, newOffset, function (data) {
            if (newOffset > 0) {
                $('#paginateTable .prev').removeClass("disabled");
            }

            if (newOffset + max >= total) {
                $('#paginateTable .next').addClass("disabled");
            }
        });
    }

    function queryForSites(query, max, offset, callbackFcn) {
        $.ajax({
            url: self.config.siteQueryUrl + query + "&max=" + max + "&offset=" + offset,
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
                callbackFcn(data);
            },
            error: function () {
                alert('There was a problem searching for sites.');
            }
        });
    }

    function paginatePrev() {

        var offset = $('#paginateTable').data('offset') - $('#paginateTable').data('max');
        if ($('#paginateTable').data('offset') == 0) {
            return;
        }
        $('#paginateTable').data('offset', offset);

        var query = $('#paginateTable').data('query');
        var max = $('#paginateTable').data('max');

        queryForSites(query, max, offset, function () {
            if (offset <= 0) {
                $('#paginateTable .prev').addClass("disabled");
            }
            $('#paginateTable .next').removeClass("disabled");
        });
    }

    self.searchSites();
}