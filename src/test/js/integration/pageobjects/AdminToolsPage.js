const ReloadablePage = require('./ReloadablePage');
class AdminToolsPage extends ReloadablePage {

    url = browser.options.testConfig.baseUrl + "/admin/tools";

    async open() {
        await browser.url(this.url);
    }
    async at ()  {
        let title = await browser.getTitle();
        return /Tools | Admin/i.test(title);
    }

    get reindexButton () { return $('#btnReindexAll'); }
    get clearMetaDataCacheButton () { return $("#btnClearMetadataCache"); }

    async clearMetadata() {
        await this.clearMetaDataCacheButton.click();
    }

    async reindex() {
        await browser.url(this.url)
        await this.reindexButton.click();
        await this.hasBeenReloaded();
    }

    async clearCache() {
        await this.clearMetadata();
    }
}

module.exports = new AdminToolsPage();