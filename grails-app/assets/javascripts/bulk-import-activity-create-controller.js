var parentWindow, origin, savePromise, asyncPromiseResolvedChecker, numberOfIntervalCheck = 0;
var MAX_INTERVAL_CHECK = 5,
    MAX_INITIAL_CHECK_DELAY_IN_MS = 4000,
    MAX_VALIDATE_DELAY_IN_MS = 4000;

function loadData(event) {
    var data = event.data.data;
    for (var i = 0; i < data.length; i++) {
        var outputName = data[i].outputName,
            instance = ecodata.forms.utils.getInstanceForOutputName(outputName);

        instance && instance.loadData(data[i].data);
    }
}

window.addEventListener("message", function (event) {
    console.log(event);

    if (event.origin !== fcConfig.originUrl)
        return

    origin = event.origin;
    parentWindow = event.source;

    switch (event.data.eventName) {
        case 'import':
            loadData(event);
            master.getViewModel().bulkImportId(event.data.bulkImportId);
            master.getViewModel().embargoed(true);

            if (master) {
                asyncPromiseResolvedChecker = setInterval(saveAndInformParent, MAX_INITIAL_CHECK_DELAY_IN_MS);
            }
            break;
        case 'validate':
            loadData(event);
            if (master) {
                asyncPromiseResolvedChecker = setInterval(validateAndInformParent, MAX_VALIDATE_DELAY_IN_MS);
            }
            break;
        case 'fixinvalid':
            loadData(event);
            master.getViewModel().bulkImportId(event.data.bulkImportId);
            master.getViewModel().embargoed(true);

            $(document).on('activitycreated', activityCreateHandler);
            $(document).on('activitycreatefailed', activityCreateFailedHandler);
            $(document).on('activitycreatecancelled', activityCreateCancelHandler)
            break;
    }
});

function activityCreateHandler(event, data) {
    parentWindow && parentWindow.postMessage({
        eventName: 'invalidfixed',
        activityId: data.activityId,
        isValid: data.isValid
    }, origin);
}

function activityCreateFailedHandler(event, data) {
    parentWindow && parentWindow.postMessage({
        eventName: 'invaliderrored',
        activityId: data.activityId,
        isValid: data.isValid
    }, origin);
}

function activityCreateCancelHandler(event) {
    parentWindow && parentWindow.postMessage({eventName: 'invalidcancel'}, origin);
}

function saveAndInformParent() {
    if ((getAsyncCounter() == 0) && !savePromise) {
        savePromise = master.save();
        if(savePromise) {
            savePromise.then(function (data) {
                if (parentWindow) {
                    setTimeout(function () {
                        parentWindow.postMessage({
                            eventName: 'next',
                            activityId: data.resp.activityId,
                            isValid: isFormValid()
                        }, origin);
                    }, 0);
                }
            }, function () {
                setTimeout(function () {
                    parentWindow.postMessage({eventName: 'error'}, origin);
                }, 0);
            });
        }
        else {
            setTimeout(function () {
                parentWindow.postMessage({eventName: 'error'}, origin);
            }, 0);
        }
    } else if (((getAsyncCounter() == 0) && !!savePromise)
    || isMaxIntervalCheck()) {
        // cancel set interval
        asyncPromiseResolvedChecker && clearInterval(asyncPromiseResolvedChecker);
    }

    incrementIntervalCheck();
}

function validateAndInformParent() {
    if ((getAsyncCounter() == 0)) {
        parentWindow.postMessage({eventName: 'validate', isValid: isFormValid()}, origin);
    } else if (isMaxIntervalCheck()) {
        // cancel set interval
        asyncPromiseResolvedChecker && clearInterval(asyncPromiseResolvedChecker);
        parentWindow.postMessage({eventName: 'validate', isValid: false}, origin);
    }

    incrementIntervalCheck();
}

function isFormValid() {
    return $('#validation-container').validationEngine('validate');
}

function incrementAsyncCounter() {
    if (window.numberOfAjaxRequests == undefined) {
        window.numberOfAjaxRequests = ko.observable(0);
    }

    window.numberOfAjaxRequests(window.numberOfAjaxRequests() + 1);
    console.log("increment - " + window.numberOfAjaxRequests());
}

function decreaseAsyncCounter() {
    window.numberOfAjaxRequests(window.numberOfAjaxRequests() - 1);
    console.log("decrement - " + window.numberOfAjaxRequests());
}

function getAsyncCounter() {
    return window.numberOfAjaxRequests();
}

function incrementIntervalCheck() {
    numberOfIntervalCheck++;
    console.log("increment interval check - " + numberOfIntervalCheck);
}

function isMaxIntervalCheck() {
    return numberOfIntervalCheck > MAX_INTERVAL_CHECK;
}