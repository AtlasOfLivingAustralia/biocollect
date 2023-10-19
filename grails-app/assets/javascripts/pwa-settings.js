function StorageViewModel() {
    var self = this,
        deleteSteps = ['cache', 'db'];
    self.maximum = ko.observable();
    self.used = ko.observable();
    self.free = ko.observable();
    self.percentage = ko.computed(function () {
        return Math.round(self.used() / self.maximum() * 100);
    });
    self.isOffline = ko.observable(false);
    self.deleteProgress = ko.observable(0);
    self.deleteSteps = ko.observable(deleteSteps.length);
    self.deletePercentage = ko.computed(function () {
        return Math.round(self.deleteProgress() / self.deleteSteps() * 100);
    });
    self.supported = ko.observable(true);
    self.refresh = function () {
        if (navigator.storage && navigator.storage.estimate) {
            navigator.storage.estimate().then(
                ({ usage, quota }) => {
                    var gbUnit = 1024 * 1024 * 1024;
                    self.maximum(quota / gbUnit);
                    self.used(usage / gbUnit);
                    self.free(self.maximum() - self.used());
                },
                error => console.warn(`error estimating quota: ${error.name}: ${error.message}`)
            );
        }
        else {
            self.supported(false);
        }
    }

    self.clearAll = function () {
        self.deleteProgress(0);
        bootbox.confirm("This operation cannot be reversed. Are you sure you want to delete?", function (result) {
            if (result) {
                self.deleteCache().then(self.deleteDBEntries).then(function () {
                    self.deleteProgress(self.deleteSteps());
                    notifyParent();
                });
            }
        });
    }

    self.deleteCache = function () {
        return caches.keys().then(function (cacheNames) {
            return Promise.all(
                cacheNames.map(function (cacheName) {
                    return caches.delete(cacheName);
                })
            );
        }).then(function () {
            self.refresh();
            self.deleteProgress(self.deleteProgress() + 1);
        });
    }

    self.deleteDBEntries = function () {
        return entities.deleteTable('offlineMap').then(function () {
            return entities.deleteTable('taxon').then(function () {
                self.deleteProgress(self.deleteProgress() + 1);
            });
        });
    }

    function notifyParent() {
        window.parent && window.parent.postMessage({event: "surveys-removed"}, "*");
    }

    document.addEventListener('offline', function () {
        self.isOffline(true);
    });

    document.addEventListener('online', function () {
        self.isOffline(false);
    });

    self.refresh();
}

function initialise() {
    var storageViewModel = new StorageViewModel();
    ko.applyBindings(storageViewModel, document.getElementById('storage-settings'));
    checkOfflineForIntervalAndTriggerEvents(5000);
}

$(document).ready(initialise);