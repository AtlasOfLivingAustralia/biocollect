function ActivitiesViewModel (config) {
    var self = this;
    var projectActivityId = config.projectActivityId;
    var projectId = config.projectId;
    self.activities = ko.observableArray();
    self.pagination = new PaginationViewModel({}, self);
    self.online = ko.observable(true);

    self.init = function() {
        window.addEventListener("online", function() {
            self.online(true);
        });

        window.addEventListener("offline", function() {
            self.online(false);
        });
    }

    self.load = function(offset) {
        if (projectActivityId) {
            self.getActivitiesOfProjectActivity(self.pagination.resultsPerPage() ,offset);
        }
        else if (projectId) {
            self.getActivitiesForProject(self.pagination.resultsPerPage(), offset);
        }
        else {
            self.getAllActivities(self.pagination.resultsPerPage(), offset);
        }
    };

    self.refreshPage  = function (offset) {
        self.load(offset);
    }

    self.getAllActivities = function(max, offset) {
        entities.offlineGetAllActivities(max, offset).then(function(result) {
            var activities = result.data.activities,
                total = result.data.total,
                container = [];

            activities.forEach(function(activity) {
                container.push(new ActivityViewModel(activity, self));
            });

            self.activities(container);
            self.pagination.loadOffset(offset, total);
        });
    }

    self.getActivitiesForProject = function(max, offset) {
        entities.offlineGetActivitiesForProject(projectId, max, offset).then(function(result) {
            var activities = result.data.activities,
                total = result.data.total,
                container = [];

            activities.forEach(function(activity) {
                container.push(new ActivityViewModel(activity, self));
            });

            self.activities(container);
            self.pagination.loadOffset(offset, total);
        });
    }

    self.getActivitiesOfProjectActivity = function(max, offset) {
        entities.getActivitiesForProjectActivity(projectActivityId, max, offset).then(function(result) {
            var activities = result.data.activities,
                total = result.data.total,
                container = [];

            activities.forEach(function(activity) {
                container.push(new ActivityViewModel(activity, self));
            });

            self.activities(container);
            self.pagination.loadPagination(offset, total);
        });
    }

    self.uploadAllHandler = function() {
        // todo
    }

    self.remove = function(activity) {
        self.activities.remove(activity);
    }

    self.transients = {
        addActivityUrl: function() {
            return fcConfig.addActivityUrl + "/" + projectActivityId;
        },
        isProjectActivity: !!projectActivityId
    }

    self.init();
    self.pagination.first();
};

function ActivityViewModel (activity, parent) {
    var self = this, images;
    self.activityId = activity.activityId;
    self.projectId = activity.projectId;
    self.projectActivityId = activity.projectActivityId;
    self.featureImage = ko.observable();
    self.species = ko.observableArray();
    self.metaModel;
    self.imageViewModels = [];
    self.transients = {
        viewActivityUrl: function() {
            return fcConfig.activityViewUrl + "/" + self.projectActivityId + "?projectId=" + self.projectId + "&activityId=" + self.activityId;
        },
        editActivityUrl: function() {
            return fcConfig.activityEditUrl + "/" + self.projectActivityId + "?projectId=" + self.projectId + "&activityId=" + self.activityId;
        }
    }

    self.load = function() {
        entities.offlineGetMetaModel(activity.type).done(function(result) {
            var metaModel = result.data,
                imageViewModel;
            self.metaModel = new MetaModel(metaModel);
            self.species(self.metaModel.getDataForType("species", activity));
            self.imageViewModels = [];
            images = self.metaModel.getDataForType("image", activity);

            if (images && images.length > 0) {
                images.forEach(function(image) {
                    imageViewModel = new ImageViewModel(image, true);
                    self.imageViewModels.push(imageViewModel);
                    if (!self.featureImage()) {
                        self.featureImage(imageViewModel);
                    }
                });
            }
        });
    }

    self.upload = function() {
        var forceOnline = false;
        if (!isOffline() || forceOnline) {
            var promises = [],
                deferred = $.Deferred();
            promises.push(self.uploadImages().then(self.deleteImages));
            promises.push(self.uploadSite().then(self.updateActivityWithSiteId).then(self.saveAsNewSite).then(self.deleteOldSite));
            $.when.apply($, promises).then(function () {
                self.saveActivityToDB().then(self.uploadActivity).then(self.deleteActivityFromDB).then(self.removeMeFromList).then(function () {
                    deferred.resolve({data: { activityId: activity.activityId} });
                });
            }, function (error) {
                self.saveActivityToDB().then(function () {
                    deferred.reject({data: { activityId: activity.activityId}, message: "There was an error uploading activity", error: error});
                });
            })
        }
        else {
            alert("You are offline. Please connect to the internet and try again.");
            deferred.reject();
        }

        return deferred.promise();
    }

    self.removeMeFromList = function() {
        parent.remove(self);
    }

    self.uploadActivity = function() {
        var oldActivityId = self.activityId;
        if (entities.utils.isDexieEntityId(activity.activityId)) {
            activity.activityId = undefined;
        }

        var toSave = JSON.stringify(activity),
            deferred = $.Deferred(),
            url = fcConfig.bioActivityUpdate + "?pActivityId=" + activity.projectActivityId,
            ajaxRequestParams = {
                url: url,
                type: 'POST',
                data: toSave,
                contentType: 'application/json',
                success: function success(data) {
                    if (data.errors || data.error) {
                        deferred.reject({data: {oldActivityId: oldActivityId, error: data.errors || data.error}});
                    }
                    else {
                        deferred.resolve({data: {oldActivityId: oldActivityId, activityId: data.resp.activityId }});
                    }
                },
                error: function (jqXHR, status, error) {
                    deferred.reject({data: {activity: activity.activityId, error: error}})
                }
            };

        // todo: add user credentials to ajax request

        $.ajax(ajaxRequestParams);
        return deferred.promise();
    }

    self.saveActivityToDB = function() {
        return entities.saveActivity(activity);
    }

    self.deleteActivityFromDB = function(result) {
        var activityId = result.data.oldActivityId;
        return entities.deleteActivities([activityId]);
    }

    self.updateActivityWithSiteId = function(result) {
        var siteId = result.data.siteId;
        activity.siteId = siteId;
        var sourceNames = self.metaModel.getNamesForDataType("geoMap");
        self.metaModel.updateDataForSources(sourceNames, activity, siteId);
        return result;
    }

    self.saveAsNewSite = function(result) {
        var site = result.data.site;
        if (site && isUuid(site.siteId)) {
            entities.saveSite(site);
        }

        return result;
    }

    self.deleteOldSite = function(result) {
        var siteId = result.data.oldSiteId;
        if(entities.utils.isDexieEntityId(siteId)) {
            return entities.deleteSites([siteId]);
        }
        else {
            return $.Deferred().resolve(result);
        }
    }

    self.uploadSite = function() {
        var siteId = self.metaModel.getDataForType("geoMap", activity)[0] || activity.siteId;
        return entities.getSite(siteId).then(function(result) {
            var site = result.data,
                data = {
                    site: site,
                    pActivityId: activity.projectActivityId
                },
                id = siteId,
                deferred = $.Deferred();
            site['asyncUpdate'] = true;  // aysnc update Metadata service for performance improvement
            if (entities.utils.isDexieEntityId(site.siteId)) {
                id = site.siteId = undefined;
            }

            $.ajax({
                method: 'POST',
                url: id ? fcConfig.updateSiteUrl + "?id=" + id : fcConfig.updateSiteUrl,
                data: JSON.stringify(data),
                contentType: 'application/json',
                dataType: 'json'
            }).then(function (result) {
                if (result.id) {
                    deferred.resolve({data: {siteId: result.id, oldSiteId: siteId, site: site}});
                }
                else {
                    deferred.reject({data: result, error : "Site update failed."});
                }
            }, function (jqXHR, status, error) {
                deferred.reject({error : error});
            });

            return deferred.promise();
        });
    }

    self.uploadImages = function() {
        var uploadedImages = [],
            promises = [], deferred = $.Deferred();

        self.imageViewModels.forEach(function (imageVM, index) {
            if (imageVM.isBlobDocument()) {
                var image = images[index];
                if (image.documentId && entities.utils.isDexieEntityId(image.documentId)) {
                    uploadedImages.push(image.documentId);
                }

                promises.push(self.uploadImage(imageVM).then(self.updateImageMetadata.bind(self, imageVM, image)))
            }
        });

        $.when.apply($, promises).then(function () {
            deferred.resolve({data:uploadedImages});
        }, function (){
            deferred.reject({error: "Image upload failed."});
        });

        return deferred.promise();
    }

    self.updateImageMetadata = function(imageVM, image, stagedMetadata) {
        $.extend(image, stagedMetadata);
        imageVM.load(image);
        if (entities.utils.isDexieEntityId(image.documentId)) {
            // clear documentId so that BioCollect will create a new document for the image
            image.documentId = undefined;
        }

        return image;
    }

    self.uploadImage = function(image) {
        var formData = new FormData();
        formData.append("files", image.getBlob());
        return $.ajax({
            url: fcConfig.imageUploadUrl,
            type: "POST",
            data: formData,
            processData: false,
            contentType: false
        })
        .then(function (result) {
            return (result.files && result.files[0]) || {};
        });
    }

    self.deleteImages = function(result) {
        var imageIds = result.data;
        return entities.bulkDeleteDocuments(imageIds).then(function() {
            console.log("Successfully deleted images - " + imageIds.toString());
        }, function () {
            console.error("Failed to delete images");
        });
    }

    self.load();
}

function getParameters (activity) {
    var url = new URL(window.location.href);
    return {
        projectId: url.searchParams.get("projectId"),
        projectActivityId: url.searchParams.get("projectActivityId")
    }
}

document.addEventListener("credential-saved", startInitialising);
document.addEventListener("credential-failed", function () {
    alert("Error occurred while saving credentials. Please close modal and try again.");
});

window.addEventListener('load', function (){
    setTimeout(startInitialising, 2000)
    // two event attributes for backward compatibility
    if (fcConfig.isCaching) {
        window.parent && window.parent.postMessage({eventName: 'viewmodelloadded', event: 'viewmodelloadded', data: {}}, fcConfig.originUrl);
    }
    else if (fcConfig.isPWA) {
        window.parent && window.parent.postMessage({eventName: 'viewmodelloadded', event: 'viewmodelloadded', data: {}}, fcConfig.pwaAppUrl);
    }
});

function startInitialising () {
    entities.getCredentials().then(function (result) {
        var config = getParameters(),
            activitiesViewModel = new ActivitiesViewModel(config);

        ko.applyBindings(activitiesViewModel);
    })
}