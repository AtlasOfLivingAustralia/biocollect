const StubbedCasSpec = require('./StubbedCasSpec.js')
class PwaAppPage extends StubbedCasSpec {
    url = browser.options.testConfig.pwaUrl;

    get getStarted() {
        return $('#getStarted');
    }

    async open() {
        await browser.url(this.url);
    }

    async at() {
        return /BioCollect PWA/i.test(await browser.getTitle());
    }


    async saveToken() {
        await browser.execute(function () {
            return localStorage
        });
    }

    async start() {
        await this.getStarted.click();
    }

    async serviceWorkerReady() {
        return await browser.executeAsync((done) => {
            console.log('Checking for Service Worker');
            if ('serviceWorker' in navigator) {
                console.log('Service Workers are supported');
                navigator.serviceWorker.getRegistration().then((registration) => {
                    console.log('Service Worker registration:', registration);
                    done(true);  // Service Worker is installed and controlling the page
                    // if (registration) {
                    //     console.log('Service Worker is registered');
                    //     resolve(true);  // Service Worker is registered
                    // } else {
                    //     resolve(true);  // Service Worker is installed and controlling the page
                    //     // // Listen for Service Worker to take control
                    //     // navigator.serviceWorker.oncontrollerchange = () => {
                    //     //     console.log('Service Worker is not registered');
                    //     //
                    //     // };
                    //
                    //     // Set a timeout for the check
                    //     setTimeout(() => resolve(false), 5000);  // Timeout after 5 seconds
                    // }
                });
            } else {
                done(false);  // Service Workers are not supported
            }
        });
    }
}

module.exports = new PwaAppPage();