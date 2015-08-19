var PhotoPoint = function(data) {
    this.name = data.name;
    this.lat = data.geometry.decimalLatitude;
    this.lon = data.geometry.decimalLongitude;
    this.bearing = data.geometry.bearing;
    this.description = data.description;
};

self.hasPhotos = function() {
     var photos = $.grep(self.data.photoPoints(), function(photoPoint) {
        return photoPoint.photo().length > 0;
    });
    return photos.length > 0;
};

self.transients.previousSiteId = site ? site.siteId : null;

self.transients.selectedSite.subscribe(function(site) {

    if (!site || self.transients.previousSiteId != site.siteId) {
        // The site has changed, so reload our photopoints.
        self.data.photoPoints([]);
        self.loadphotoPoints([]);
        if (site) site.photoPointData = self.data.photoPoints;
    }
    self.transients.previousSiteId = site ? site.siteId : null;
});


self.loadphotoPoints = function(data) {

    var site = self.transients.selectedSite();

    var photoPointByName = function(name, data) {
        var photoPoint;
        if (data !== undefined) {
            $.each(data, function(index, obj) {
                if (obj.name === name) {
                    photoPoint = obj;
                    return false;
                }
            });
        }
        return photoPoint;
    };


    if (site !== undefined && site.poi !== undefined) {

        $.each(site.poi, function(index, obj) {
            var photoPoint = new PhotoPoint(obj);
            var photoPointData = photoPointByName(obj.name, data);
            if (photoPointData === undefined) {
                photoPointData = {comment:"", photo:[]};
            }
            var row = new PhotoPointsRow(photoPointData);
            $.extend(row, photoPoint);

            self.data.photoPoints.push(row);
        });
    }
};

self.removePhotoPoint = function(photoPoint) {
   self.data.${model.name}.remove(photoPoint);
};

