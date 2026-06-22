describe('PwaSyncSpec', function () {
    function dispatchSyncMessage(event, payload, requestId) {
        window.dispatchEvent(new MessageEvent('message', {
            data: {
                event: event,
                payload: payload,
                requestId: requestId
            }
        }));
    }

    function waitForPostMessage(count) {
        count = count || 1;

        return new Promise(function (resolve, reject) {
            var started = Date.now();

            function poll() {
                if (window.parent.postMessage.calls.count() >= count) {
                    resolve();
                    return;
                }

                if (Date.now() - started > 1000) {
                    reject(new Error('Timed out waiting for PWA sync postMessage'));
                    return;
                }

                setTimeout(poll, 10);
            }

            poll();
        });
    }

    beforeEach(function () {
        spyOn(window.parent, 'postMessage');
    });

    it('replies with a correlated error when required parameters are missing', async function () {
        dispatchSyncMessage('offline-project-activity-activities', {
            projectActivityId: 'pa_1',
            max: 10,
            offset: 0
        }, 'request-missing-jwt');

        await waitForPostMessage();

        expect(window.parent.postMessage).toHaveBeenCalledWith(jasmine.objectContaining({
            event: 'offline-project-activity-activities',
            requestId: 'request-missing-jwt',
            payload: jasmine.objectContaining({
                error: jasmine.stringMatching(/jwt/)
            })
        }), '*');
    });

    it('echoes request ids on successful sync responses', async function () {
        dispatchSyncMessage('offline-project-activity-activities', {
            projectActivityId: 'pa_1',
            max: 10,
            offset: 0,
            jwt: 'test-jwt'
        }, 'request-list');

        await waitForPostMessage();

        expect(window.parent.postMessage).toHaveBeenCalledWith({
            event: 'offline-project-activity-activities',
            requestId: 'request-list',
            payload: {
                activities: [],
                total: 0
            }
        }, '*');

        expect(window.pwaSyncFixture.instances[0].jwt).toBe('test-jwt');
        expect(window.pwaSyncFixture.instances[0].config).toEqual({
            projectId: undefined,
            projectActivityId: 'pa_1'
        });
    });

    it('unwraps all activities responses', async () => {
        dispatchSyncMessage('offline-all-activities', {
            max: 10,
            offset: 0,
            jwt: 'test-jwt'
        }, 'request-all-list');

        await waitForPostMessage();

        expect(window.parent.postMessage).toHaveBeenCalledWith({
            event: 'offline-all-activities',
            requestId: 'request-all-list',
            payload: {
                activities: [],
                total: 0
            }
        }, '*');
    });

    it('echoes request ids on upload-all progress and final messages', async function () {
        dispatchSyncMessage('offline-upload-all-activities', {
            projectActivityId: 'pa_1',
            jwt: 'test-jwt'
        }, 'request-upload-all');

        await waitForPostMessage(2);

        var progressMessage = window.parent.postMessage.calls.argsFor(0)[0];
        var finalMessage = window.parent.postMessage.calls.argsFor(1)[0];

        expect(progressMessage).toEqual(jasmine.objectContaining({
            event: 'offline-upload-all-activities-progress',
            requestId: 'request-upload-all',
            payload: jasmine.objectContaining({
                currentActivityId: 'activity-1',
                phase: 'uploading'
            })
        }));

        expect(finalMessage).toEqual(jasmine.objectContaining({
            event: 'offline-upload-all-activities',
            requestId: 'request-upload-all',
            payload: jasmine.objectContaining({
                uploadedActivityIds: ['activity-1']
            })
        }));
    });
});
