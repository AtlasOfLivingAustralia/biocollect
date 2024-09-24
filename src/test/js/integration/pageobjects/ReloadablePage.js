const StubbedCasSpec = require('./StubbedCasSpec.js')
class ReloadablePage extends StubbedCasSpec {

    atCheckTime = 0

    /**
     * Extends the standard at check to set a javascript variable that can later be
     * checked to detect a pageload.
     */
    async verifyAt() {
        let result = await this.at();
        if (result) {
            await this.saveAtCheckTime()
        }
        return result
    }

    async saveAtCheckTime() {
        this.atCheckTime = Date.now().toString()
        let self = this;
        await browser.execute(() => {
            window.atCheckTime = self.atCheckTime;
        });
    }

    async getAtCheckTime() {
        return await browser.execute(() => {
            return window.atCheckTime;
        });
    }


    /** Returns true if the page has been reloaded since the most recent "at" check */
    async hasBeenReloaded() {
        return browser.waitUntil(async() => {
                return ! await this.getAtCheckTime();
            },
            {
                timeout: browser.options.testConfig.waitforTimeout,
                timeoutMsg: "Page did not reload after reindexing"
        });
    }
}

module.exports = ReloadablePage;