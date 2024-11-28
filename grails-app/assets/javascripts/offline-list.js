function ActivitiesViewModel (config) {
    var self = this;
    var projectActivityId = config.projectActivityId;
    var projectId = config.projectId,
        calledFromContext = projectActivityId === undefined ? "global" : "survey",
        cancelOfflineCheck;
    self.activities = ko.observableArray();
    self.pagination = new PaginationViewModel({}, self);
    self.online = ko.observable(true);
    self.disableUpload = ko.computed(function () {
        return self.activities().length === 0 || !self.online();
    });


    self.init = function() {
        document.addEventListener("online", function() {
            self.online(true);
        });
        document.addEventListener("offline", function() {
            self.online(false);
        });

        cancelOfflineCheck = checkOfflineForIntervalAndTriggerEvents();
    }

    self.load = function(offset) {
        if (projectActivityId) {
            return self.getActivitiesOfProjectActivity(self.pagination.resultsPerPage() ,offset);
        }
        else if (projectId) {
            return  self.getActivitiesForProject(self.pagination.resultsPerPage(), offset);
        }
        else {
            return self.getAllActivities(self.pagination.resultsPerPage(), offset);
        }
    };

    self.refreshPage  = function (offset) {
        self.load(offset);
    }

    self.getAllActivities = function(max, offset) {
        return entities.offlineGetAllActivities(max, offset).then(function(result) {
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
        return entities.offlineGetActivitiesForProject(projectId, max, offset).then(function(result) {
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
        return entities.getActivitiesForProjectActivity(projectActivityId, max, offset).then(function(result) {
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
        var activities = self.activities(),
            index = 0;

        self.uploadAnActivity(activities, index);
    }

    self.uploadAnActivity = function (activities, index) {
        if (index < activities.length) {
            activities[index].upload().then(function () {
                self.uploadAnActivity(activities, index + 1);
            }, function (error) {
                console.error(error);
                self.uploadAnActivity(activities, index + 1);
            });
        } else {
            // calling load with offset 0 will load the next batch of activities since current batch of activities are
            // deleted from db.
            if (self.pagination.totalResults() !== 0)
                self.load(0).then(self.uploadAllHandler, function (error) {
                    console.error("Error loading next page of activities" + error);
                });
        }
    }

    /**
     * Soft delete an activity from list
     * @param activity
     */
    self.remove = function(activity) {
        self.activities.remove(activity);
    }

    self.transients = {
        addActivityUrl: function() {
            return fcConfig.addActivityUrl + "/" + projectActivityId + "?context=" + calledFromContext;
        },
        isProjectActivity: !!projectActivityId
    }

    self.init();
    self.pagination.first();
};

function ActivityViewModel (activity, parent) {
    const IMAGE_DELETED_STATUS = 'deleted'
    var self = this, images, loadPromise,
        calledFromContext = getParameters().projectActivityId === undefined ? "global" : "survey";
    self.activityId = activity.activityId;
    self.projectId = activity.projectId;
    self.projectActivityId = activity.projectActivityId;
    self.featureImage = ko.observable();
    self.species = ko.observableArray();
    self.surveyDate = ko.observable().extend({simpleDate: false});
    self.uploading = ko.observable(false);
    self.disableUpload = ko.computed(function () {
        return self.uploading() || !parent.online();
    });
    self.metaModel;
    self.imageViewModels = [];
    self.transients = {
        viewActivityUrl: function() {
            return fcConfig.activityViewUrl + "/" + self.projectActivityId + "?projectId=" + self.projectId + "&activityId=" + self.activityId + "&context=" + calledFromContext;
        },
        editActivityUrl: function() {
            return fcConfig.activityEditUrl + "/" + self.projectActivityId + "?unpublished=true&projectId=" + self.projectId + "&activityId=" + self.activityId + "&context=" + calledFromContext;
        }
    }

    self.load = function() {
        loadPromise = entities.offlineGetMetaModel(activity.type).done(function(result) {
            var metaModel = result.data,
                imageViewModel, surveyDate;
            self.metaModel = new MetaModel(metaModel);
            self.species(self.metaModel.getDataForType("species", activity));
            surveyDate = self.metaModel.getDataForType("date", activity)
            surveyDate = surveyDate && surveyDate[0]
            if (surveyDate) {
                self.surveyDate(surveyDate);
            }

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
        var promises = [],
            deferred = $.Deferred(),
            forceOnline = false;
        isOffline().then(function () {
            alert("You are offline. Please connect to the internet and try again.");
            deferred.reject();
        }, function () {
            loadPromise.then(function (){
                try {
                    self.uploading(true);
                    promises.push(self.uploadImages());
                    promises.push(self.uploadSite().then(self.updateActivityWithSiteId).then(self.saveAsNewSite));
                    $.when.apply($, promises).then(function (imagesToDelete, oldSitesToDelete) {
                        self.saveActivityToDB().then(self.uploadActivity).then(self.deleteActivityFromDB).then(self.removeMeFromList).then(async function () {
                            self.uploading(false);
                            await self.deleteImages(imagesToDelete);
                            await self.deleteOldSite(oldSitesToDelete);
                            deferred.resolve({data: {activityId: activity.activityId}});
                        });
                    }, function (error) {
                        self.saveActivityToDB().then(function () {
                            self.uploading(false);
                            deferred.reject({
                                data: {activityId: activity.activityId},
                                message: "There was an error uploading activity",
                                error: error
                            });
                        });
                    });
                }
                catch (error) {
                    console.error(error);
                    deferred.reject();
                    alert("There was an error uploading activity");
                }
            }, function () {
                deferred.reject();
                alert("There was an error fetching metadata for activity");
            });
        });

        return deferred.promise();
    }

    /**
     * Hard delete an activity from the database
     */
    self.deleteActivity = function() {
        bootbox.confirm("This operation cannot be reversed. Are you sure you want to delete this activity?", function (result) {
            if (result) {
                self.uploading(true);
                images = images || [];
                var documentIds = images.map(image => image.documentId);
                self.deleteImages({data:documentIds}).then(self.deleteSite).then(self.deleteActivityById).then(function (){
                    parent.refreshPage(0);
                }).then(function () {
                    self.uploading(false);
                }, function () {
                    self.uploading(false);
                });
            }
        })
    }

    self.deleteSite = function () {
        return entities.deleteSites([activity.siteId]);
    }

    self.deleteActivityById = function () {
        return self.deleteActivityFromDB({data: {oldActivityId: activity.activityId}});
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
            site['asyncUpdate'] = true;  // aysnc update site metadata for performance improvement
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
                // if site update fails, reject the promise only if it is a new site.
                // if existing site is update is reject, resolve the promise with the site id. This helps sync the activity.
                // update can be rejected if user does not have permission on all the project the site is associated.
                if (entities.utils.isDexieEntityId(site.siteId)) {
                    deferred.reject({error : error});
                }
                else {
                    deferred.resolve({data: {siteId: siteId, oldSiteId: siteId, site: site}});
                }
            });

            return deferred.promise();
        });
    }

    self.uploadImages = async function() {
        var uploadedImages = [],
            promises = [], deferred = $.Deferred();

        for (var index = 0 ; index < self.imageViewModels.length; index++) {
            var imageVM = self.imageViewModels[index];
            if (imageVM.isBlobDocument()) {
                var image = images[index], promise;
                if (image.documentId && entities.utils.isDexieEntityId(image.documentId)) {
                    if (imageVM.status() !== IMAGE_DELETED_STATUS)
                        uploadedImages.push(image.documentId);
                }

                if (imageVM.status() !== IMAGE_DELETED_STATUS)
                    promise = self.uploadImage(imageVM).then(self.updateImageMetadata.bind(self, imageVM, image))
                promises.push(promise)
                await promise;
            }

        }

        $.when.apply($, promises).then(function () {
            deferred.resolve({data:uploadedImages});
        }, function (){
            deferred.reject({error: "Image upload failed."});
        });

        return deferred.promise();
    }

    self.updateImageMetadata = function(imageVM, image, stagedMetadata) {
        $.extend(image, stagedMetadata);
        imageVM.load(image, true);
        if (entities.utils.isDexieEntityId(image.documentId)) {
            // clear documentId so that BioCollect will create a new document for the image
            image.documentId = undefined;
        }

        return image;
    }

    self.uploadImage = function(image) {
        var formData = new FormData();
        var blob = image.getBlob();
        var file = new File([blob], image.filename, {type: image.contentType()});
        formData.append("files", file);
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
    setTimeout(startInitialising, 2000);
    // two event attributes for backward compatibility
    window.parent && window.parent.postMessage({eventName: 'viewmodelloadded', event: 'viewmodelloadded', data: {}}, "*");
});

function startInitialising () {
    window.uninitialised = window.uninitialised || false;
    entities.getCredentials().then(function (result) {
        var config = getParameters(),
            activitiesViewModel = new ActivitiesViewModel(config);

        !window.uninitialised && ko.applyBindings(activitiesViewModel);
        window.uninitialised = true;
    })
}