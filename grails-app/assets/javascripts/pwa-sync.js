const activitiesViewModel = new ActivitiesViewModel();

const SYNC_EVENTS = {
    allActivities: 'offline-all-activities',
    projectActivities: 'offline-project-activities',
    projectActivityActivities: 'offline-project-activity-activities',
    deleteActivity: 'offline-delete-activity',
    uploadActivity: 'offline-upload-activity',
    uploadAllActivities: 'offline-upload-all-activities',
    uploadAllActivitiesProgress: 'offline-upload-all-activities-progress'
};

function hasValue(value) {
    return value !== undefined && value !== null && value !== '';
}

function serializeForPostMessage(value) {
    if (value === undefined || value === null) {
        return value;
    }

    if (typeof ko !== 'undefined' && ko.toJS) {
        return ko.toJS(value);
    }

    return JSON.parse(JSON.stringify(value));
}

function sendMessage(event, payload, requestId) {
    var message;

    if (window.parent) {
        message = {
            event,
            payload: serializeForPostMessage(payload)
        };
        if (requestId) {
            message.requestId = requestId;
        }

        window.parent.postMessage(message, '*');
        return;
    }

    console.warn('Could not find parent in PWA sync DOM!');
}

function getMissingFields(payload, requiredFields) {
    return requiredFields.filter(function(field) {
        return !hasValue(payload[field]);
    });
}

function warnMissingParameters(eventName, missingFields, requestId) {
    var message = 'Missing parameters in ' + eventName + ' request: ' + missingFields.join(', ');
    console.warn(message);
    sendError(eventName, message, requestId);
}

function sendError(eventName, message, requestId) {
    sendMessage(eventName, { error: message }, requestId);
}

function sendResult(eventName, result, unwrapData, requestId) {
    sendMessage(eventName, unwrapData && result ? result.data : result, requestId);
}

async function configureActivitiesViewModel(config) {
    await activitiesViewModel.configure(config);
}

const eventHandlers = {};

eventHandlers[SYNC_EVENTS.allActivities] = {
    requiredFields: ['max'],
    configure: function() {
        return {
            projectId: undefined,
            projectActivityId: undefined
        };
    },
    handle: function(payload) {
        return activitiesViewModel.getAllActivities(payload.max, payload.offset || 0);
    },
    unwrapData: true
};

eventHandlers[SYNC_EVENTS.projectActivities] = {
    requiredFields: ['projectId', 'max', 'offset'],
    configure: function(payload) {
        return {
            projectId: payload.projectId,
            projectActivityId: undefined
        };
    },
    handle: function(payload) {
        return activitiesViewModel.getActivitiesForProject(payload.max, payload.offset);
    },
    unwrapData: true
};

eventHandlers[SYNC_EVENTS.projectActivityActivities] = {
    requiredFields: ['projectActivityId', 'max', 'offset'],
    configure: function(payload) {
        return {
            projectId: undefined,
            projectActivityId: payload.projectActivityId
        };
    },
    handle: function(payload) {
        return activitiesViewModel.getActivitiesOfProjectActivity(payload.max, payload.offset);
    },
    unwrapData: true
};

eventHandlers[SYNC_EVENTS.deleteActivity] = {
    requiredFields: ['activityId'],
    handle: function(payload) {
        return activitiesViewModel.deleteActivity(payload.activityId);
    },
    unwrapData: true
};

eventHandlers[SYNC_EVENTS.uploadActivity] = {
    requiredFields: ['activityId'],
    handle: function(payload) {
        return activitiesViewModel.uploadActivity(payload.activityId);
    },
    unwrapData: true
};

eventHandlers[SYNC_EVENTS.uploadAllActivities] = {
    configure: function(payload) {
        if (!hasValue(payload.projectId) && !hasValue(payload.projectActivityId)) {
            return null;
        }

        return {
            projectId: hasValue(payload.projectId) ? payload.projectId : undefined,
            projectActivityId: hasValue(payload.projectActivityId) ? payload.projectActivityId : undefined
        };
    },
    handle: function(_payload, requestId) {
        return activitiesViewModel.uploadAll(function(progress) {
            sendMessage(SYNC_EVENTS.uploadAllActivitiesProgress, progress, requestId);
        });
    },
    unwrapData: true
};

window.addEventListener('message', async function(message) {
    var data = message.data || {},
        payload = data.payload || {},
        eventName = data.event,
        requestId = data.requestId,
        handler = eventHandlers[eventName],
        missingFields,
        config,
        result;

    if (!handler) {
        return;
    }

    if (!hasValue(payload.jwt)) {
        warnMissingParameters(eventName, ['jwt'], requestId);
        return;
    }

    missingFields = getMissingFields(payload, handler.requiredFields || []);
    if (missingFields.length) {
        warnMissingParameters(eventName, missingFields, requestId);
        return;
    }

    try {
        await activitiesViewModel.setJwt(payload.jwt);

        config = handler.configure ? handler.configure(payload) : null;
        if (config) {
            await configureActivitiesViewModel(config);
        }

        result = await handler.handle(payload, requestId);
        sendResult(eventName, result, handler.unwrapData, requestId);
    }
    catch (error) {
        console.error('PWA sync request failed for ' + eventName, error);
        sendError(eventName, error?.message ? error.message : 'PWA sync request failed.', requestId);
    }
});