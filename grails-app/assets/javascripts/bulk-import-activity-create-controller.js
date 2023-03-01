var parentWindow, origin, savePromise, asyncPromiseResolvedChecker, numberOfIntervalCheck = 0;
const MAX_INTERVAL_CHECK = 5;

function loadData(event) {
    debugger
    var data = event.data.data;
    for (var i = 0; i < data.length; i++) {
        var outputName = data[i].outputName,
            instance = ecodata.forms.utils.getInstanceForOutputName(outputName);

        instance && instance.loadData(data[i].data);
    }
}

window.addEventListener("message", (event) => {
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
                setInterval(saveAndInformParent, 2000);
            }
            break;
        case 'validate':
            loadData(event);
            if (master) {
                setTimeout(validateAndInformParent, 3000);
            }
            break;
        case 'fixinvalid':
            loadData(event);

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
    parentWindow.postMessage({eventName: 'validate', isValid: isFormValid()}, origin);
}

function isFormValid() {
    return $('#validation-container').validationEngine('validate');
}

function incrementAsyncCounter() {
    if (window.numberOfAjaxRequests == undefined) {
        window.numberOfAjaxRequests = ko.observable(0);
    }

    window.numberOfAjaxRequests(window.numberOfAjaxRequests() + 1);
    console.trace("increment - " + window.numberOfAjaxRequests());
}

function decreaseAsyncCounter() {
    window.numberOfAjaxRequests(window.numberOfAjaxRequests() - 1);
    console.trace("decrement - " + window.numberOfAjaxRequests());
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