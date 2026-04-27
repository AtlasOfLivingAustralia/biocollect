window.pwaSyncFixture = {
    instances: []
};

window.ActivitiesViewModel = function () {
    window.pwaSyncFixture.instances.push(this);
};

window.ActivitiesViewModel.prototype.configure = function (config) {
    this.config = config;
    return Promise.resolve();
};

window.ActivitiesViewModel.prototype.setJwt = function (jwt) {
    this.jwt = jwt;
    return Promise.resolve();
};

window.ActivitiesViewModel.prototype.getActivitiesOfProjectActivity = function () {
    return Promise.resolve({
        data: {
            activities: [],
            total: 0
        }
    });
};

window.ActivitiesViewModel.prototype.getAllActivities = () => {
    return Promise.resolve({
        data: {
            activities: [],
            total: 0
        }
    });
};

window.ActivitiesViewModel.prototype.deleteActivity = function (activityId) {
    return Promise.resolve({
        data: {
            activityId: activityId
        }
    });
};

window.ActivitiesViewModel.prototype.uploadActivity = function (activityId) {
    return Promise.resolve({
        data: {
            activityId: activityId
        }
    });
};

window.ActivitiesViewModel.prototype.uploadAll = function (progressCallback) {
    progressCallback({
        currentActivityId: 'activity-1',
        failed: 0,
        phase: 'uploading',
        processed: 1,
        skipped: 0,
        total: 1,
        uploaded: 1
    });

    return Promise.resolve({
        data: {
            failedActivityIds: [],
            skippedActivityIds: [],
            totalActivities: 1,
            totalUploadableActivities: 1,
            uploadedActivityIds: ['activity-1']
        }
    });
};
