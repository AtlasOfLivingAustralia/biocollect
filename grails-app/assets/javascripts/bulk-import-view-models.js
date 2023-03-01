const STATE_INVALID = 'invalid',
    STATE_ITERATION = 'iteration',
    STATE_VIEW = 'view',
    STATE_IMPORT =  'import',
    STATE_VALIDATE =  'validate',
    STATE_FIXINVALID =  'fixinvalid';

function message (msg) {
    alert(msg);
}

function showLoading() {
    $(document.body).css('opacity',0.5)
}

function hideLoading() {
    $(document.body).css('opacity',1)
}

function BulkUploadViewModel(activityImport) {
    var self = this;
    var createWindow, data, index = 0, viewIndex = 0, createdActivities = [];
    var createRequest, updateRequest, nextData, convertExcelToJSONRequest, iframeMessageSubscriber,
        iframeId = 'createIframe', iframeContainer = 'iframeContainer', iframeHeading = 'iframeTitle', iframeBlocked = false;
    self.file = ko.observable();
    self.activityImport = activityImport;
    self.phase = ko.observable(STATE_VIEW);
    const PHASE_STATES = [STATE_VIEW, STATE_IMPORT, STATE_VALIDATE, STATE_FIXINVALID],
        Y_BUFFER = 20;

    self.iframeMessage = ko.observable("");

    self.deleteButtonHandler = function () {
        if (self.activityImport.bulkImportId()) {
            self.deleteActivitiesImported().then(function (resp){
                if (resp.success) {
                    message( "Successfully deleted activities");
                } else {
                    message("Could not delete all imported activities. Click view activity button to see activities that failed delete operation.");
                }
            })
        }
        else {
            message("You have not imported any activity.");
        }
    };

    self.viewButtonHandler = function () {
        if (self.activityImport.bulkImportId()) {
            window.location = fcConfig.bulkImportUrl + '/' + self.activityImport.bulkImportId() + '/activity/list'
        }
        else {
            message("You have not imported any activity.");
        }
    };

    self.importButtonHandler = function () {
        var promise;
        self.phase(STATE_IMPORT);

        if(activityImport.transients.numberOfActivitiesLoaded() > 0) {
            promise = self.importAfterDeleting(function (){
                self.activityImport.transients.reset();
            });
        }
        else {
            self.activityImport.transients.reset();
            promise = self.saveBulkImport();
        }

        promise.then(function () {
            self.iterateData();
        });
    };

    self.validateButtonHandler = function () {
        self.phase(STATE_VALIDATE);
        self.activityImport.transients.reset();
        self.iterateData();
    };

    self.invalidButtonHandler = function () {
        self.phase(STATE_FIXINVALID);
        self.nextButtonHandler();
    };

    self.previousButtonHandler = function () {
        self.iterateData(STATE_INVALID);
    };

    self.nextButtonHandler = function () {
        self.iterateData(STATE_INVALID);
    };

    self.publishButtonHandler = function () {
        self.publishBulkImportActivities();
    };

    self.embargoButtonHandler = function () {
        self.embargoBulkImportActivities();
    };

    self.submitButtonHandler = function () {
        self.saveBulkImport();
    }

    self.showEmbargoBtn = self.showPublishBtn = self.showDeleteBtn = self.showViewBtn = ko.pureComputed(function () {
        return !!self.activityImport.bulkImportId();
    });

    self.showFixInvalid = ko.pureComputed(function () {
        return self.activityImport.invalidActivities().length > 0;
    });

    self.showValidateBtn = self.showImportBtn = ko.pureComputed(function () {
        return self.activityImport.dataToLoad() && (self.activityImport.dataToLoad().length > 0);
    });

    self.showIframe = ko.pureComputed(function () {
        return [STATE_FIXINVALID, STATE_IMPORT, STATE_VALIDATE].indexOf(self.phase()) != -1;
    });

    self.iframeMessage.subscribe(function () {
        self.showIframeMessage();
    });

    self.showIframeMessage = function (status) {
        if (self.showIframe()) {
            if (iframeBlocked) {
                self.hideIframeMessage({
                    onUnblock: self.blockIframeWithMessage
                });
            }
            else {
                self.blockIframeWithMessage()
            }

            self.scrollIframeToView();
        }
    };

    self.blockIframeWithMessage = function () {
        var message = self.iframeMessage();
        if (message) {
            $("#" + iframeContainer).block({
                message: message,
                fadeOut: 700,
                centerY: true,
                centerX: true,
                showOverlay: true,
                css: $.blockUI.defaults.growlCSS
            });

            iframeBlocked = true;
        }
    }

    self.hideIframeMessage = function (options) {
        options ? $("#" + iframeContainer).unblock(options) : $("#" + iframeContainer).unblock();
        iframeBlocked = false;
    };

    self.scrollIframeToView = function () {
        var offset = $("#" + iframeHeading).offset();

        if (offset) {
            $("html, body").animate({
                scrollTop: offset.top + 'px'
            });
        }
    };

    self.previousButtonEnabled = ko.pureComputed(function () {
        return self.activityImport.transients.hasPrevious(STATE_INVALID);
    });

    self.nextButtonEnabled = ko.pureComputed(function () {
        return self.activityImport.transients.hasNext(STATE_INVALID);
    });

    self.fileInputChangeHandler = function (data, event) {
        var file = event.target.files && event.target.files[0];
        self.file(file);
    }
// add a function to update iframe url
    self.updateIframeUrl = function (url) {
        $('#iframe').attr('src', url);
    }

    self.adjustIframeHeight = adjustIframeHeight;

    // add a function to get a reference to the iframe and listen to load event
    self.loadIframe = function (message) {
        message = message || "Loading next row... Please wait...";
        // get a reference to the iframe window object
        if (!createWindow) {
            var iframe = document.getElementById('createIframe');
            iframe.src = fcConfig.createActivityUrl;
            createWindow = iframe.contentWindow;
        }
        else {
            createWindow.location.reload();
        }

        self.iframeMessage(message);
    }

    self.openWindow = function (onLoad) {
        // todo: check if window has been closed and a new window is needed
        if (!createWindow) {
            createWindow = window.open(fcConfig.createActivityUrl, "_blank", {
                "popup": true,
                "noopener": true
            });

            createWindow.addEventListener("load", function () {
                console.log("window is loaded");
                onLoad && onLoad();
            });
        }

        return createWindow;
    }

    self.postData = function (data) {
        createWindow && createWindow.postMessage({data: data, eventName: self.phase(), bulkImportId: self.activityImport.bulkImportId()}, fcConfig.createActivityUrl);
    };

    self.addCreatedActivity = function (activityId, isValid) {
        activityId && self.activityImport.transients.addCreatedActivity(activityId, isValid);
    };

    self.updateActivityValidity = function (isValid) {
        self.activityImport.transients.updateActivityValidity(isValid);
    };

    self.fixedInvalidActivity = function () {
        self.activityImport.transients.fixedInvalidActivity();
    };

    self.addErroredActivity = function () {
        self.activityImport.transients.addErroredActivity();
    };


    self.iterateData = function (indexType, message) {
        switch (indexType) {
            case STATE_ITERATION:
            default:
                nextData = activityImport.transients.getNext(indexType);
                break;
            case STATE_INVALID:
                var serial = activityImport.transients.getNext(indexType);
                nextData = activityImport.transients.findBySerialNumber(serial);
                break;
        }

        if (nextData) {
            self.loadIframe(message);
        } else {
            self.saveBulkImport();
            self.phase(STATE_VIEW);
            createWindow = null;
        }
    }

    self.messageHandler = function (event) {
        if (event.origin !== fcConfig.originUrl)
            return

        var message = event.data.eventName;
        switch (message) {
            case 'next':
                self.addCreatedActivity(event.data.activityId, event.data.isValid);
                self.iterateData(undefined, "Uploaded data successfully. Loading next row...");
                break;
            case 'error':
                self.iframeMessage();
                self.addErroredActivity();
                self.iterateData(undefined, "Could not save data due to an error. You can try fixing it later. Loading next row...");
                break;
            case STATE_VALIDATE:
                self.updateActivityValidity(event.data.isValid)
                self.iterateData(undefined, "Successfully validated data. Loading next row...");
                break;
            case 'invalidfixed':
                self.fixedInvalidActivity(event.data.activityId, true);
                self.loadIframe("Successfully fixed invalid data. Click next button to fix the next row...");
                break;
            case 'invalidnotfixed':
                self.addErroredActivity();
                self.loadIframe("Could not fix invalid data. Loading next row...");
                break;
            case 'invalidcancel':
                self.loadIframe("Cancelled fixing invalid data. Loading next row...");
                break;
            case 'viewmodelloadded':
                if (nextData) {
                    self.postData(nextData);
                }

                self.hideIframeMessage();
                break;
        }
    }

    self.isBulkImportCreated = function () {
        return !!self.activityImport.bulkImportId();
    }

    self.convertExcelToJSON = function () {
        var formData = new FormData();
        formData.append('data', self.file());
        formData.append('type', activityImport.formName());
        formData.append('pActivityId', activityImport.projectActivityId());
        convertExcelToJSONRequest = $.ajax({
            url: fcConfig.convertExcelToDataUrl,
            method: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            dataType: "json",
            success: function (response) {
                activityImport.dataToLoad(response.data);
            }
        });
        return convertExcelToJSONRequest;
    }

    self.deleteActivitiesImported = function (doBefore) {
        return $.ajax({
            url: getDeleteActivitiesBulkImportUrl(),
            method: 'DELETE',
            dataType: 'json'
        });
    };

    self.createBulkImport = function () {
        createRequest = $.ajax({
            url: getCreateBulkImportUrl(),
            method: 'POST',
            data: self.activityImport.transients.toJSON(),
            contentType: 'application/json',
            success: function (data) {
                self.activityImport.bulkImportId(data.bulkImportId);
                updateUrl();
            },
            error: function (jqXHR, status, error) {
                alert('Failed to save data - ' + error.error);
            }
        });

        return createRequest;
    }

    self.updateBulkImport = function () {
        showLoading();
        updateRequest = $.ajax({
            url: getBulkImportUpdateUrl(),
            method: 'PUT',
            data: self.activityImport.transients.toJSON(),
            contentType: 'application/json',
            success: function (data) {
                hideLoading();
            },
            error: function (jqXHR, status, error) {
                alert('Failed to save data - ' + error.error);
                hideLoading();
            }
        });

        return updateRequest;
    }

    self.saveBulkImport = function () {
        if (self.isBulkImportCreated()) {
            return self.updateBulkImport();
        }
        else {
            return self.createBulkImport();
        }
    }

    self.importAfterDeleting = function (callback) {
        var deleteAjax = self.deleteActivitiesImported();
        var whenImportSaved = $.Deferred();

        deleteAjax.then(function() {
            callback && callback();
            self.saveBulkImport().then(function (data) {
                whenImportSaved.resolveWith(data);
            });
        });

        return  whenImportSaved.promise();
    }


    self.getBulkImport = function (bulkImportId) {
        return $.ajax({
            url: getBulkImportDetailsUrl(),
            method: 'GET',
            success: function (data) {
                if (data) {
                    self.activityImport.transients.load(data);
                }
                else {
                    message('Could not fetch value for ' + self.activityImport.bulkImportId());
                }
            },
            error: function (jqXHR, status, error) {
                message('Failed to fetch bulk import data - ' + error.error);
            }
        });
    };

    self.publishBulkImportActivities = function () {
        return $.ajax({
            url: getPublishActivitiesBulkImportUrl(),
            method: 'PUT',
            success: function (data) {
                if (data.success) {
                    message('Successfully published activities');
                }
                else {
                    message('Could not publish activities for bulk import - ' + self.activityImport.bulkImportId());
                }
            },
            error: function (jqXHR, status, error) {
                message('Failed to publish activities with error message - ' + error.error);
            }
        });
    }

    self.embargoBulkImportActivities = function () {
        return $.ajax({
            url: getEmbargoActivitiesBulkImportUrl(),
            method: 'PUT',
            success: function (data) {
                if (data.success) {
                    message('Successfully embargoed activities');
                }
                else {
                    message('Could not embargo activities for bulk import - ' + self.activityImport.bulkImportId());
                }
            },
            error: function (jqXHR, status, error) {
                message('Failed to embargo activities with error message - ' + error.error);
            }
        });
    }

    function getProjectId () {
        return self.activityImport.projectId() || fcConfig.projectId;
    }

    function getCreateBulkImportUrl() {
        return fcConfig.bulkImportUrl + '?projectId=' + getProjectId();
    }

    function getBulkImportUpdateUrl () {
        return getBulkImportDetailsUrl();
    }

    function getBulkImportIndexUrl () {
        return fcConfig.bulkImportUrl + "/index/" + self.activityImport.bulkImportId() + '?projectId=' + getProjectId();
    }

    function getBulkImportDetailsUrl () {
        return fcConfig.bulkImportUrl + "/" + self.activityImport.bulkImportId() + '?projectId=' + getProjectId();
    }

    function getPublishActivitiesBulkImportUrl () {
        return fcConfig.bulkImportUrl + "/" + self.activityImport.bulkImportId() + '/activity/publish?projectId=' + getProjectId();
    }

    function getEmbargoActivitiesBulkImportUrl () {
        return fcConfig.bulkImportUrl + "/" + self.activityImport.bulkImportId() + '/activity/embargo?projectId=' + getProjectId();
    }

    function getDeleteActivitiesBulkImportUrl () {
        return fcConfig.bulkImportUrl + "/" + self.activityImport.bulkImportId() + "/activity?projectId=" + getProjectId();
    }

    function updateUrl () {
        if(window.history.replaceState) {
            var url = getBulkImportIndexUrl();
            window.history.replaceState(self.activityImport.bulkImportId(), self.activityImport.description(), url);
        }
    }

    function adjustIframeHeight() {
        var height = $(window).height() - Y_BUFFER, currentHeight = $('#' + iframeId).height();
        if (height != currentHeight) {
            $('#' + iframeId).height(height);
            self.scrollIframeToView();
        }
    }

    function initActivityImport() {
        if (fcConfig.bulkImportId) {
            self.activityImport.bulkImportId(fcConfig.bulkImportId);
            self.getBulkImport();
        }
    }


    function init() {
        self.file.subscribe(function () {
            self.convertExcelToJSON();
        });

        iframeMessageSubscriber = self.iframeMessage.subscribe(function (value) {
            if (value) {
                self.showIframeMessage();
            }
        });

        window.addEventListener('resize', adjustIframeHeight, true);
        window.addEventListener("message", self.messageHandler, true);
        initActivityImport();
    }

    init();
}

function ActivityImport(activityImport) {
    activityImport = activityImport || {};
    var self = this,
        index = -1,
        viewIndex = -1;

    self.bulkImportId = ko.observable();
    self.projectActivityId = ko.observable();
    self.projectId = ko.observable();
    self.formName = ko.observable();
    self.dataToLoad = ko.observableArray();
    self.createdActivities = ko.observableArray();
    self.validActivities = ko.observableArray();
    self.invalidActivities = ko.observableArray();
    self.description = ko.observable();
    self.userId = ko.observable();
    var numberOfActivities = ko.computed(function () {
            var dataToLoad = self.dataToLoad() || [];
            return dataToLoad.length;
        }),
        numberOfActivitiesLoaded = ko.computed(function () {
            var createdActivities = self.createdActivities() || [];
            return createdActivities.length;
        }),
        numberOfActivitiesNotLoaded = ko.computed(function () {
            var createdActivities = self.createdActivities() || [],
                dataToLoad = self.dataToLoad() || [];
            return dataToLoad.length - createdActivities.length;
        }),
        numberOfActivitiesValid = ko.computed(function () {
            var validActivities = self.validActivities() || [];
            return validActivities.length;
        }),
        numberOfActivitiesInvalid = ko.computed(function () {
            var invalidActivities = self.invalidActivities() || [];
            return invalidActivities.length;
        }),
        numberOfActivitiesValidated = ko.computed(function () {
            return numberOfActivitiesValid() + numberOfActivitiesInvalid();
        });

    self.transients = {
        numberOfActivities: numberOfActivities,
        numberOfActivitiesLoaded: numberOfActivitiesLoaded,
        numberOfActivitiesNotLoaded: numberOfActivitiesNotLoaded,
        numberOfActivitiesValid: numberOfActivitiesValid,
        numberOfActivitiesInvalid: numberOfActivitiesInvalid,
        numberOfActivitiesValidated: numberOfActivitiesValidated,
        projectName: undefined,
        projectActivityName: undefined,
        userName: undefined,
        toJSON: function (){
            return ko.mapping.toJSON(self, {ignore: 'transients'})
        },
        peek: function (indexType) {
            switch (indexType) {
                default:
                case STATE_ITERATION:
                    if ((index + 1) < self.dataToLoad().length) {
                        return self.dataToLoad()[index + 1]
                    }
                    break;
                case STATE_INVALID:
                    if ((viewIndex + 1) < self.invalidActivities().length) {
                        return self.invalidActivities()[viewIndex + 1];
                    }
                    break;
            }
        },
        getNext: function (indexType) {
            switch (indexType) {
                default:
                case STATE_ITERATION:
                    if((index + 1) < self.dataToLoad().length) {
                        index++;
                        var next = self.transients.getCurrent(indexType);
                        return next;
                    }
                    break;
                case STATE_INVALID:
                    if((viewIndex + 1) < self.invalidActivities().length) {
                        viewIndex++;
                        return  self.transients.getCurrent(indexType);
                    }
                    break;
            }
        },
        getPrevious: function (indexType) {
            switch (indexType) {
                default:
                case STATE_ITERATION:
                    if ((index - 1) >= 0) {
                        return self.dataToLoad()[index - 1];
                    }
                    break;
                case STATE_INVALID:
                    if ((viewIndex - 1) >= 0) {
                        return self.invalidActivities()[viewIndex - 1];
                        // return self.transients.findBySerialNumber(serial);
                    }
                    break;
            }
        },
        getCurrent: function (indexType) {
            switch (indexType) {
                default:
                case STATE_ITERATION:
                    return self.dataToLoad()[index];
                case STATE_INVALID:
                    return self.invalidActivities()[viewIndex];
                    // return self.transients.findBySerialNumber(serial);
            }
        },
        hasNext: function (indexType) {
            switch (indexType) {
                default:
                case STATE_ITERATION:
                    var nextIndex = index + 1;
                    return (nextIndex >= 0) && (nextIndex < self.dataToLoad().length);
                case STATE_INVALID:
                    var nextViewIndex = viewIndex + 1;
                    return (nextViewIndex >= 0) && (nextViewIndex < self.invalidActivities().length);
            }
        },
        hasPrevious: function (indexType) {
            switch (indexType) {
                default:
                case STATE_ITERATION:
                    var prevIndex = index - 1;
                    return (prevIndex  >= 0) && (prevIndex < self.dataToLoad().length);
                case STATE_INVALID:
                    var prevViewIndex = viewIndex - 1;
                    return (prevViewIndex  >= 0) && (prevViewIndex < self.invalidActivities().length);
            }
        },
        addCreatedActivity: function (activityId) {
            if (activityId) {
                var data = self.transients.getCurrent();
                data.forEach(function (output) {
                    output.activityId = activityId;
                });
                self.createdActivities.push(activityId);
            }

            self.transients.updateActivityValidity(true);
        },
        fixedInvalidActivity: function (activityId) {
            removeItemFromInvalidActivities()
            self.transients.addCreatedActivity(activityId);
        },
        addErroredActivity: function () {
            self.transients.updateActivityValidity(false);
        },
        updateActivityValidity: function (valid) {
            var data = self.transients.getCurrent();
            if (!data || ((valid != true) && (valid != false)))
                return;

            if ( valid ) {
                if (self.transients.canAddActivityToValid(data[0].data.serial)) {
                    self.validActivities.push(data[0].data.serial);
                }
            }
            else {
                if (self.transients.canAddActivityToInvalid(data[0].data.serial)) {
                    self.invalidActivities.push(data[0].data.serial);
                }
            }
        },
        canAddActivityToValid: function (value) {
            return self.validActivities.indexOf(value) == -1;
        },
        canAddActivityToInvalid: function (value) {
            return self.invalidActivities.indexOf(value) == -1;
        },
        updateValidity: function (isValid) {
            if (isValid) {
                if (self.transients.canAddActivityToValid(self.transients.getSerialNumber())) {
                    self.validActivities.push(self.transients.getSerialNumber());
                }
            }
            else {
                if (self.transients.canAddActivityToInvalid(self.transients.getSerialNumber())) {
                    self.invalidActivities.push(self.transients.getSerialNumber());
                }
            }
        },
        getSerialNumber: function (outputs) {
            outputs = outputs || self.transients.getCurrent();
            var output = outputs[0];

            return output && output.data.serial;
        },
        findBySerialNumber: function (serial) {
            var found;
            self.dataToLoad().forEach(function (outputs) {
                if ((outputs.length > 0) && (outputs[0].data.serial == serial)) {
                    found = outputs;
                }
            });

            return found;
        },
        reset: function () {
            viewIndex = index = -1;
            self.createdActivities.removeAll();
            self.validActivities.removeAll();
            self.invalidActivities.removeAll();
        },
        getViewIndex: function () {
            return viewIndex;
        },
        getIndex: function () {
            return index;
        },
        load: function (bulkImport) {
            self.bulkImportId(bulkImport.bulkImportId);
            self.projectActivityId(bulkImport.projectActivityId);
            self.projectId(bulkImport.projectId);
            self.formName(bulkImport.formName);
            self.dataToLoad(bulkImport.dataToLoad || []);
            self.createdActivities(bulkImport.createdActivities || []);
            self.validActivities(bulkImport.validActivities || []);
            self.invalidActivities(bulkImport.invalidActivities || []);
            self.description(bulkImport.description || "");
            self.userId(bulkImport.userId);
            self.transients.projectName = bulkImport.projectName;
            self.transients.projectActivityName = bulkImport.projectActivityName;
            self.transients.userName = bulkImport.userName;
        }
    };

    // private functions
    function removeItemFromInvalidActivities () {
        var current = self.transients.getCurrent(STATE_INVALID),
            next = self.transients.peek(STATE_INVALID),
            previous = self.transients.getPrevious(STATE_INVALID);

        // Subtract by 2 since array is updated later.
        // Remove from array after updating index so that subscriber that need index value calculate state correctly.
        if (next != undefined)
            viewIndex = self.invalidActivities.indexOf(next) - 2;
        else if (previous != undefined)
            viewIndex = self.invalidActivities.indexOf(previous) - 2;
        else
            viewIndex = -1;
        self.invalidActivities.remove(current);
    }

    self.transients.load(activityImport)
}

function BulkImportListingViewModel() {
    var self = this, nextOffset = 0;

    self.bulkImports = ko.observableArray([]);
    self.search = ko.observable("");
    self.pagination = new PaginationViewModel({numberPerPage: 20}, self);
    self.refreshPage = function (newOffset  ) {
        nextOffset = newOffset;
        showLoading();
        var promise = self.transients.get();
        promise.done(hideLoading);
    };
    self.transients = {
        get: function () {
            return $.ajax({
                url: getBulkImportsUrl(),
                success: function (data) {
                    self.transients.load(data);
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    message("An error occurred while loading bulk imports. Please try again later.", "error");
                }
            });
        },
        convertToActivityImport: function (bulkImports) {
            var items = [];
            bulkImports.forEach(function (item) {
                items.push(new ActivityImport(item));
            });
            return items;
        },
        load: function (data) {
            var items = data.items, total = data.total;
            self.pagination.loadPagination(self.pagination.currentPage(), total);
            items = self.transients.convertToActivityImport(items);
            self.bulkImports(items);
        },
        searchHandler: function (data, event) {
            self.pagination.first();
        },
        getBulkImportViewUrl: getBulkImportViewUrl,
        getProjectActivityUrl: getProjectActivityUrl,
        getProjectUrl: getProjectUrl,
        getProjectAboutTabUrl: getProjectAboutTabUrl
    };

    function getBulkImportsUrl () {
        return fcConfig.bulkImportUrl + "?offset=" + nextOffset + "&max=" + self.pagination.resultsPerPage() + "&query=" + self.search()
    };

    function getBulkImportViewUrl(data) {
        return fcConfig.bulkImportUrl + "/index/" + data.bulkImportId() + '?projectId=' + data.projectId();
    };

    function getProjectActivityUrl(data) {
        return getProjectUrl(data)  + "?tab=activities-tab";
    }

    function getProjectAboutTabUrl(data){
        return getProjectUrl(data)  + "?tab=about-tab";
    }

    function getProjectUrl(data) {
        return fcConfig.projectUrl + "/" + data.projectId();
    }
    // pretty print the json
    self.prettyPrint = function (data) {

    }


    self.pagination.first();
}