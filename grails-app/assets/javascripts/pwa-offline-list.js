function ActivitiesViewModel (config) {
    var self = this,
        cancelOfflineCheck,
        initialised = false;

    config = config || {};

    self.projectActivityId = ko.observable(null);
    self.projectId = ko.observable(null);
    self.jwt = ko.observable();
    self.uploadAllProgressCallback = null;

    self.activities = ko.observableArray();
    self.pagination = new PaginationViewModel({}, self);
    self.online = ko.observable(true);
    self.disableUpload = ko.computed(function () {
        var activities = self.activities();
        for (var i = 0; i < activities.length; i++) {
            if (activities[i].canUpload()) {
                return !self.online();
            }
        }

        return true;
    });
    // check if any activity is uploading
    self.isUploading = ko.computed(function () {
        var activities = self.activities();
        for (var i = 0; i < activities.length; i++) {
            if (activities[i].uploading()) {
                return true;
            }
        }
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
        if (self.projectActivityId()) {
            return self.getActivitiesOfProjectActivity(self.pagination.resultsPerPage() ,offset);
        }
        else if (self.projectId()) {
            return  self.getActivitiesForProject(self.pagination.resultsPerPage(), offset);
        }
        else {
            return self.getAllActivities(self.pagination.resultsPerPage(), offset);
        }
    };

    self.refreshPage  = function (offset) {
        return self.load(offset);
    }

    self.setJwt = function(jwt) {
        self.jwt(jwt);

        return $.Deferred().resolve({data: {jwt: jwt}}).promise();
    }

    self.authorizeAjaxRequest = function(ajaxRequestParams) {
        if (self.jwt()) {
            ajaxRequestParams.headers = ajaxRequestParams.headers || {};
            ajaxRequestParams.headers.Authorization = 'Bearer ' + self.jwt();
        }

        return ajaxRequestParams;
    }

    self.updateActivities = function(activities, total, offset) {
        var container = [],
            renderDataPromises = [];

        activities.forEach(function(activity) {
            var activityViewModel = new ActivityViewModel(activity, self);

            container.push(activityViewModel);
            renderDataPromises.push(activityViewModel.toPwaOfflineListJson());
        });

        self.activities(container);
        self.pagination.loadOffset(offset, total);

        return $.when.apply($, renderDataPromises).then(function() {
            var renderActivities = renderDataPromises.length === 1 ? [arguments[0]] : Array.prototype.slice.call(arguments);

            return {
                data: {
                    activities: renderActivities,
                    total: total
                }
            };
        });
    }

    self.configure = function(nextConfig) {
        nextConfig = nextConfig || {};

        self.projectActivityId(nextConfig.projectActivityId);
        self.projectId(nextConfig.projectId);

        if (!initialised) {
            self.init();
            initialised = true;
        }

        return $.Deferred().resolve({data: {configured: true}}).promise();
    }

    self.update = function(nextConfig) {
        nextConfig = nextConfig || {};

        if (initialised && nextConfig.projectActivityId === self.projectActivityId() && nextConfig.projectId === self.projectId()) {
            return $.Deferred().resolve({data: {refreshed: false}}).promise();
        }

        return self.configure(nextConfig).then(function() {
            return self.refreshPage(0);
        });
    }

    self.getAllActivities = function(max, offset) {
        return entities.offlineGetAllActivities(max, offset).then(function(result) {
            var activities = result.data.activities,
                total = result.data.total;

            return self.updateActivities(activities, total, offset);
        });
    }

    self.getActivitiesForProject = function(max, offset) {
        return entities.offlineGetActivitiesForProject(self.projectId(), max, offset).then(function(result) {
            var activities = result.data.activities,
                total = result.data.total;

            return self.updateActivities(activities, total, offset);
        });
    }

    self.getActivitiesOfProjectActivity = function(max, offset) {
        return entities.offlineGetAllActivities(10000, 0).then(function(result) {
            var matchingActivities = result.data.activities.filter(function(activity) {
                    return activity.projectActivityId === self.projectActivityId();
                }),
                total = matchingActivities.length,
                pagedActivities = matchingActivities.slice(offset, offset + max);

            return self.updateActivities(pagedActivities, total, offset);
        });
    }

    self.getMatchingActivities = function() {
        if (self.projectActivityId()) {
            return entities.offlineGetAllActivities(10000, 0).then(function(result) {
                var matchingActivities = result.data.activities.filter(function(activity) {
                    return activity.projectActivityId === self.projectActivityId();
                });

                return {
                    data: {
                        activities: matchingActivities,
                        total: matchingActivities.length
                    }
                };
            });
        }

        if (self.projectId()) {
            return entities.offlineGetActivitiesForProject(self.projectId(), 10000, 0);
        }

        return entities.offlineGetAllActivities(10000, 0);
    }

    self.uploadAllHandler = function() {
        return self.uploadAll();
    }

    self.emitUploadProgress = function(summary, currentActivityId) {
        if (!self.uploadAllProgressCallback) {
            return;
        }

        self.uploadAllProgressCallback({
            currentActivityId: currentActivityId,
            failed: summary.failedActivityIds.length,
            phase: summary.phase,
            processed: summary.processedActivities,
            skipped: summary.skippedActivityIds.length,
            total: summary.totalUploadableActivities,
            uploaded: summary.uploadedActivityIds.length
        });
    }

    self.uploadAll = function(progressCallback) {
        var summary = {
            uploadedActivityIds: [],
            failedActivityIds: [],
            skippedActivityIds: [],
            errors: [],
            phase: 'preparing',
            processedActivities: 0,
            totalActivities: 0,
            totalUploadableActivities: 0
        };

        self.uploadAllProgressCallback = progressCallback || null;

        return self.getMatchingActivities().then(function(result) {
            var activities = result.data.activities || [],
                activityViewModels = activities.map(function(activity) {
                    return new ActivityViewModel(activity, self);
                });

            summary.totalActivities = activities.length;
            summary.totalUploadableActivities = activityViewModels.filter(function(activityViewModel) {
                return activityViewModel.canUpload();
            }).length;
            summary.phase = 'uploading';
            self.emitUploadProgress(summary);

            return self.uploadActivityViewModels(activityViewModels, summary, 0);
        }).then(function() {
            summary.phase = 'refreshing';
            self.emitUploadProgress(summary);

            return self.load(0).then(function() {
                summary.phase = 'complete';
                return {data: summary};
            }, function(error) {
                summary.refreshError = error;
                summary.phase = 'complete';
                return {data: summary};
            });
        }).always(function() {
            self.uploadAllProgressCallback = null;
        });
    }

    self.uploadActivityViewModels = function(activityViewModels, summary, index) {
        summary = summary || {
            uploadedActivityIds: [],
            failedActivityIds: [],
            skippedActivityIds: [],
            errors: [],
            phase: 'uploading',
            processedActivities: 0,
            totalActivities: 0,
            totalUploadableActivities: 0
        };

        if (index >= activityViewModels.length) {
            return $.Deferred().resolve(summary).promise();
        }

        var activityViewModel = activityViewModels[index];

        if (!activityViewModel.canUpload()) {
            summary.skippedActivityIds.push(activityViewModel.activityId);
            return self.uploadActivityViewModels(activityViewModels, summary, index + 1);
        }

        self.emitUploadProgress(summary, activityViewModel.activityId);

        return activityViewModel.upload().then(function(result) {
            summary.uploadedActivityIds.push(result.data.activityId);
        }, function(error) {
            console.error(error);
            summary.failedActivityIds.push((error && error.data && error.data.activityId) || activityViewModel.activityId);
            summary.errors.push(error);
        }).then(function() {
            summary.processedActivities += 1;
            self.emitUploadProgress(summary, activityViewModel.activityId);
            return self.uploadActivityViewModels(activityViewModels, summary, index + 1);
        });
    }

    /**
     * Soft delete an activity from list
     * @param activity
     */
    self.remove = function(activity) {
        self.activities.remove(activity);
    }

    self.findActivityViewModel = function(activityId) {
        var existingActivityViewModel = ko.utils.arrayFirst(self.activities(), function(activityViewModel) {
                return activityViewModel.activityId === activityId;
            }),
            deferred = $.Deferred();

        if (existingActivityViewModel) {
            deferred.resolve(existingActivityViewModel);
            return deferred.promise();
        }

        entities.offlineGetAllActivities(10000, 0).then(function(result) {
            var rawActivity = ko.utils.arrayFirst(result.data.activities || [], function(activity) {
                return activity.activityId === activityId;
            });

            if (rawActivity) {
                deferred.resolve(new ActivityViewModel(rawActivity, self));
            }
            else {
                deferred.reject({message: 'Activity not found', data: {activityId: activityId}});
            }
        }, deferred.reject);

        return deferred.promise();
    }

    self.deleteActivity = function(activityId) {
        return self.findActivityViewModel(activityId).then(function(activityViewModel) {
            return activityViewModel.deleteActivity();
        });
    }

    self.uploadActivity = function(activityId) {
        return self.findActivityViewModel(activityId).then(function(activityViewModel) {
            return activityViewModel.upload();
        });
    }

    self.transients = {
        addActivityUrl: function() {
            return fcConfig.addActivityUrl + "/" + self.projectActivityId();
        },
        isProjectActivity: !!self.projectActivityId()
    }
};

function ActivityViewModel (activity, parent) {
    const IMAGE_DELETED_STATUS = 'deleted'
    var self = this, images, loadPromise;
    self.activityId = activity.activityId;
    self.projectId = activity.projectId;
    self.projectActivityId = activity.projectActivityId;
    self.featureImage = ko.observable();
    self.species = ko.observableArray();
    self.surveyDate = ko.observable().extend({simpleDate: false});
    self.uploading = ko.observable(false);
    self.isInvalidDraft = ko.pureComputed(function () {
        return activity.__valid === false || activity.__valid === undefined;
    });
    self.uploadFlag = ko.pureComputed(function () {
        return activity.__upload === true;
    });
    self.canUpload = ko.pureComputed(function () {
        return !self.isInvalidDraft();
    });
    self.disableUpload = ko.computed(function () {
        return self.uploading() || !parent.online() || !self.canUpload();
    });
    self.metaModel;
    self.imageViewModels = [];
    self.transients = {
        viewActivityUrl: function() {
            return fcConfig.activityViewUrl + "/" + self.projectActivityId + "?projectId=" + self.projectId + "&activityId=" + self.activityId;
        },
        editActivityUrl: function() {
            return fcConfig.activityEditUrl + "/" + self.projectActivityId + "?projectId=" + self.projectId + "&activityId=" + self.activityId + '&unpublished=true';
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

    self.toPwaOfflineListJson = function() {
        return loadPromise.then(function() {
            return ko.toJS({
                activityId: self.activityId,
                projectId: self.projectId,
                projectActivityId: self.projectActivityId,
                featureImage: self.featureImage() ? {
                    thumbnailUrl: self.featureImage().thumbnailUrl
                } : null,
                species: self.species(),
                surveyDate: self.surveyDate(),
                uploading: self.uploading(),
                isInvalidDraft: self.isInvalidDraft(),
                uploadFlag: self.uploadFlag(),
                canUpload: self.canUpload(),
                disableUpload: self.disableUpload(),
                transients: {
                    viewActivityUrl: self.transients.viewActivityUrl(),
                    editActivityUrl: self.transients.editActivityUrl()
                }
            });
        });
    }

    self.upload = function() {
        var promises = [],
            deferred = $.Deferred(),
            forceOnline = false;
        if (!self.canUpload()) {
            deferred.reject({message: "Activity is incomplete and must be edited before upload"});
            return deferred.promise();
        }

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
        var deferred = $.Deferred();

        self.uploading(true);
        loadPromise.then(function () {
            var documentIds = self.getImageDocumentIdsToDelete();

            self.deleteImages({data: documentIds})
                .then(self.deleteSite)
                .then(self.deleteActivityById)
                .then(function () {
                    return parent.refreshPage(0);
                })
                .then(function () {
                    self.uploading(false);
                    deferred.resolve({data: {activityId: self.activityId}});
                }, function (error) {
                    self.uploading(false);
                    deferred.reject(error);
                });
        }, function (error) {
            self.uploading(false);
            deferred.reject(error);
        });

        return deferred.promise();
    }

    self.getImageDocumentIdsToDelete = function() {
        images = images || [];

        return images
            .map(function(image) {
                return image.documentId;
            })
            .filter(function(documentId) {
                return !!documentId;
            });
    }

    self.deleteSite = function () {
        if (!activity.siteId) {
            return $.Deferred().resolve({data: {siteId: activity.siteId}}).promise();
        }

        return entities.deleteSites([activity.siteId]);
    }

    self.deleteActivityById = function () {
        return self.deleteActivityFromDB({data: {oldActivityId: activity.activityId}});
    }

    self.removeMeFromList = function() {
        parent.remove(self);
    }

    self.uploadActivity = function() {
        var oldActivityId = self.activityId,
            activityToUpload = $.extend(true, {}, activity);
        if (entities.utils.isDexieEntityId(activityToUpload.activityId)) {
            activityToUpload.activityId = undefined;
        }
        delete activityToUpload.__valid;
        delete activityToUpload.__upload;

        var toSave = JSON.stringify(activityToUpload),
            deferred = $.Deferred(),
            url = fcConfig.bioActivityUpdate + "?pActivityId=" + activity.projectActivityId,
            ajaxRequestParams = {
                url: url,
                type: 'POST',
                data: toSave,
                contentType: 'application/json',
                success: function success(data) {
                    if (data && data.resp && data.resp.activityId) {
                        deferred.resolve({data: {oldActivityId: oldActivityId, activityId: data.resp.activityId }});
                    }
                    else {
                        deferred.reject({data: {oldActivityId: oldActivityId, error: data.errors || data.error}});
                    }
                },
                error: function (jqXHR, status, error) {
                    deferred.reject({data: {activity: activity.activityId, error: error}})
                }
            };

        $.ajax(parent.authorizeAjaxRequest(ajaxRequestParams));
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

            $.ajax(parent.authorizeAjaxRequest({
                method: 'POST',
                url: id ? fcConfig.updateSiteUrl + "?id=" + id : fcConfig.updateSiteUrl,
                data: JSON.stringify(data),
                contentType: 'application/json',
                dataType: 'json'
            })).then(function (result) {
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
                if (entities.utils.isDexieEntityId(id)) {
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
        return $.ajax(parent.authorizeAjaxRequest({
            url: fcConfig.imageUploadUrl,
            type: "POST",
            data: formData,
            processData: false,
            contentType: false
        }))
        .then(function (result) {
            return (result.files && result.files[0]) || {};
        });
    }

    self.deleteImages = function(result) {
        var imageIds = result.data;

        if (!imageIds || imageIds.length === 0) {
            return $.Deferred().resolve(result).promise();
        }

        return entities.bulkDeleteDocuments(imageIds).then(function() {
            console.log("Successfully deleted images - " + imageIds.toString());
            return result;
        }, function () {
            console.error("Failed to delete images");
            return result;
        });
    }

    self.load();
}