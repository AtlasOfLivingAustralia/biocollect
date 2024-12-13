const SubbedCasSpec = require("./StubbedCasSpec");

class OfflineListPage extends SubbedCasSpec {
    url = browser.options.testConfig.pwaUrl;
    get frame () {
        return $("iframe");
    }

    get heading () {
        return $("h1=Unpublished records");
    }

    get offlineList() {
        return $$('table#offlineList tbody tr');
    }

    get alert() {
        return $('div.alert.alert-info');
    }

    get uploadAllButton() {
        return $('.upload-records');
    }

    get uploadButton() {
        return $$('.upload-record');
    }
    get firstUploadButton() {
        return $('.upload-record');
    }
    async open() {
        console.log(`Opening ${this.url}`);
        await browser.url(`${this.url}`);
    }

    async at() {
        // let frame = await this.frame
        // await browser.switchFrame(frame);
        let h1 = await this.heading;
        // await h1.waitForExist({timeout: 30000});
        let title = await h1.getText();
        return /Unpublished records/i.test(title);
    }

    async getNumberOfRecords() {
        let records = await this.offlineList;
        return records.length;
    }

    async uploadRecords() {
        // await this.uploadButton.waitForClickable({timeout: 3000});
        // await browser.pause(5000);
        // while (await this.uploadButton.isClickable() === false) {
        //     let resolve;
        //     let promise = new Promise((res)=>{resolve = res;});
        //     setTimeout(() => {
        //         resolve();
        //     }, 1000);
        //     await promise;
        // }
        await this.uploadAllButton.click();
        // await this.alert.waitForExist({timeout: 30000});
        // return records[index];
    }
}

module.exports = OfflineListPage;