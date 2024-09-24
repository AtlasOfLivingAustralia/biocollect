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
        return await browser.execute( async () => {
            return await navigator.serviceWorker.ready
                .then(() => {console.log("installed!"); return true})
                .catch(() => {console.log("not installed!"); return false});
        });
    }
}

module.exports = new PwaAppPage();