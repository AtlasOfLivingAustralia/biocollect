const StubbedCasSpec = require('./StubbedCasSpec.js')
const ReloadablePage = require('./ReloadablePage.js')
class PwaAppPage extends ReloadablePage {
    url = browser.options.testConfig.pwaUrl;
    avatarSelector = 'header button.mantine-UnstyledButton-root, header .mantine-Avatar-root';

    get getStarted() {
        return $('#getStarted');
    }

    get avatarTrigger() {
        return $(this.avatarSelector);
    }

    get signOut() {
        return $('#signOut');
    }

    get signIn() {
        return $('#signIn');
    }

    get unpublishedTab() {
        return $('#unpublishedTab');
    }

    get refreshUnpublishedBtn() {
        return $('#unpublishedRefresh');
    }

    get publishedTab() {
        return $('#publishedTab');
    }

    get refreshPublishedBtn() {
        return $('#publishedRefresh');
    }

    get viewPublishedRecordBtn() {
        return $$('[data-testid="view-published-record"]');
    }

    get nthPublishedRecord() {
        return $$('[data-testid="record-published"]');
    }

    get viewUnpublishedRecordBtn() {
        return $$('[data-testid="view-unpublished-record"]');
    }

    get editUnpublishedRecordBtn() {
        return $$('[data-testid="edit-unpublished-record"]');
    }

    get uploadUnpublishedRecordBtn() {
        return $$('[data-testid="upload-unpublished-record"]');
    }

    get invalidUnpublishedRecord() {
        return $$('[data-testid="unpublished-invalid-message"]');
    }

    get nthUnpublishedRecord() {
        return $$('[data-testid="record-unpublished"]');
    }

    project(projectId) {
        return $('#' + projectId);
    }

    projectActivityDownload(paId) {
        return $(`#${paId}Download`);
    }

    addRecordBtn(paId) {
        return $(`#${paId}AddRecord`);
    }

    viewRecordsBtn(paId) {
        return $(`#${paId}ViewRecord`);
    }

    get modalConfirmationButton() {
        return $('#confirmDownloadModal');
    }

    get modalCloseBtn() {
        return $('.mantine-Modal-close');
    }

    get modalConfirmCloseBtn() {
        return $('[data-testid="modal-confirm-close"]');
    }

    get redownloadConfirmBtn() {
        return $('[data-testid="redownload-confirm"]');
    }

    get redownloadConfirmBtnByText() {
        return $('button=Confirm');
    }

    get modalContents() {
        return $$('.mantine-Modal-content');
    }

    get rightDrawer() {
        return $('.mantine-Drawer-content');
    }

    get pwaFrame() {
        return $('#pwa-frame');
    }

    async switchToTopFrame() {
        await browser.switchFrame(null);
    }

    async open() {
        await this.switchToTopFrame();
        console.log(`Opening ${this.url}`);
        await this.saveAtCheckTime();
        await browser.url(this.url);
        await this.hasBeenReloaded();
    }

    async at() {
        return /BioCollect PWA/i.test(await browser.getTitle());
    }

    async atSignIn() {
        try {
            await this.signIn.waitForDisplayed({ timeout: 10000 });
            return await this.signIn.isDisplayed();
        }
        catch {
            return false;
        }
    }

    async clearAuthState() {
        let localStorageTokenKey = this.localStorageTokenKey;

        await browser.execute(function (localStorageTokenKey) {
            localStorage.removeItem(localStorageTokenKey);
            localStorage.removeItem('auth.offlineExpiryExtended');
        }, localStorageTokenKey);
    }

    async openUserMenu() {
        try {
            if (await this.signOut.isDisplayed()) {
                return true;
            }
        }
        catch {
            // Ignore, menu is not open yet.
        }

        let avatarTrigger = this.avatarTrigger;
        if (!await avatarTrigger.isExisting()) {
            return false;
        }

        await avatarTrigger.scrollIntoView();

        try {
            await avatarTrigger.click();
        }
        catch {
            await browser.execute(function (selector) {
                const element = document.querySelector(selector);
                if (element) {
                    element.click();
                }
            }, this.avatarSelector);
        }

        try {
            await this.signOut.waitForDisplayed({ timeout: 5000 });
            return true;
        }
        catch {
            return false;
        }
    }

    async maybeStart() {
        let getStarted = this.getStarted;
        if (await getStarted.isExisting() && await getStarted.isDisplayed()) {
            await getStarted.click();
            await getStarted.waitForDisplayed({ timeout: 30000, reverse: true });
            return true;
        }

        return false;
    }

    async start() {
        await this.maybeStart();
    }

    async logout() {
        await this.switchToTopFrame();

        if (await this.atSignIn()) {
            return;
        }

        if (await this.openUserMenu()) {
            try {
                await this.signOut.waitForEnabled({ timeout: 5000 });
                await this.signOut.click();
                await this.signIn.waitForDisplayed({ timeout: 15000 });
                return;
            }
            catch {
                // Fall back to clearing auth state directly.
            }
        }

        await this.clearAuthState();
        await browser.url(`${this.url}/signin`);
        try {
            await this.signIn.waitForDisplayed({ timeout: 15000 });
        }
        catch {
            await browser.url(this.url);
        }
    }

    async viewProject(projectId) {
        await this.maybeStart();

        let projectElement = this.project(projectId);
        try {
            await projectElement.waitForExist({ timeout: 30000 });
        }
        catch {
            await this.open();
            await this.maybeStart();
            await projectElement.waitForExist({ timeout: 30000 });
        }
        await projectElement.scrollIntoView();
        await projectElement.waitForClickable({ timeout: 10000 });
        await projectElement.click();
    }

    async waitForSurveyActions(paId) {
        await this.addRecordBtn(paId).waitForExist({ timeout: 30000 });
        await this.viewRecordsBtn(paId).waitForExist({ timeout: 30000 });
    }

    async viewRecords(paId) {
        await this.waitForSurveyActions(paId);
        const btn = this.viewRecordsBtn(paId);
        await btn.waitForDisplayed({ timeout: 30000 });
        await btn.waitForEnabled({ timeout: 30000 });
        await btn.scrollIntoView();
        try {
            await btn.waitForClickable({ timeout: 10000 });
            await btn.click();
        }
        catch {
            await browser.execute((selector) => {
                document.querySelector(selector).click();
            }, `#${paId}ViewRecord`);
        }
        await this.rightDrawer.waitForExist({ timeout: 10000 });
    }

    async downloadProjectActivity(paId){
        await this.waitForSurveyActions(paId);
        const btn = this.projectActivityDownload(paId);
        await btn.waitForDisplayed({ timeout: 30000 });
        await btn.waitForEnabled({ timeout: 30000 });
        await btn.scrollIntoView();
        try {
            await btn.waitForClickable({ timeout: 10000 });
            await btn.click();
        }
        catch {
            await browser.execute((selector) => {
                document.querySelector(selector).click();
            }, `#${paId}Download`);
        }

        let redownloadConfirmBtn = this.redownloadConfirmBtn;
        try {
            await redownloadConfirmBtn.waitForDisplayed({ timeout: 3000 });
        }
        catch {
            redownloadConfirmBtn = this.redownloadConfirmBtnByText;
        }

        if (await redownloadConfirmBtn.isExisting() && await redownloadConfirmBtn.isDisplayed()) {
            await redownloadConfirmBtn.waitForClickable({ timeout: 10000 });
            await redownloadConfirmBtn.click();
            await redownloadConfirmBtn.waitForDisplayed({ timeout: 10000, reverse: true });
        }
    }

    async downloadComplete() {
        let btn = this.modalConfirmationButton
        await browser.waitUntil(() => btn.isClickable(), {
            timeout: 5 * 60 * 1000,
            timeoutMsg: 'Timed out waiting for survey download confirmation'
        });
        await btn.click();
        await btn.waitForDisplayed({ timeout: 10000, reverse: true });
    }

    async addRecord(paId){
        let btn = this.addRecordBtn(paId);
        await btn.waitForExist({ timeout: 20000 });
        await btn.scrollIntoView();
        await btn.waitForClickable({ timeout: 10000 });
        await btn.click();
        await this.pwaFrame.waitForExist({ timeout: 20000 });
    }

    async closeModal(){
        await this.switchToTopFrame();
        let modal = this.modalCloseBtn;
        if (await modal.isExisting()) {
            await modal.waitForEnabled({ timeout: 10000 });
            await modal.click();

            let confirm = this.modalConfirmCloseBtn;
            await browser.waitUntil(async () => {
                return await confirm.isExisting() || !(await modal.isExisting()) || !(await modal.isDisplayed());
            }, { timeout: 10000, timeoutMsg: 'Modal close did not either close or ask for confirmation' });

            if (await confirm.isExisting()) {
                await confirm.waitForEnabled({ timeout: 10000 });
                await confirm.click();
            }

            await browser.waitUntil(async () => {
                let modalContents = await this.modalContents;
                for (let i = 0; i < modalContents.length; i++) {
                    if (await modalContents[i].isDisplayed()) {
                        return false;
                    }
                }

                return true;
            }, { timeout: 10000, timeoutMsg: 'Modal did not close' });
        }
    }

    async closeConfirmModal(){
        await this.switchToTopFrame();
        let modal = this.modalCloseBtn;
        if (await modal.isExisting()) {
            await modal.waitForEnabled({ timeout: 10000 });
            await modal.click();

            let confirm = this.modalConfirmCloseBtn;
            await confirm.waitForExist({ timeout: 10000 });
            await confirm.waitForEnabled({ timeout: 10000 });
            await confirm.click();
            await confirm.waitForDisplayed({ timeout: 10000, reverse: true });
        }
    }

    async switchToPublishedTab() {
        await this.publishedTab.waitForClickable({ timeout: 10000 });
        await this.publishedTab.click();
    }

    async waitForPublishedRecord(timeout = 60000) {
        let lastRefresh = 0;

        await browser.waitUntil(async () => {
            if ((await this.publishedCount()) > 0) {
                return true;
            }

            const now = Date.now();
            if (now - lastRefresh >= 3000) {
                lastRefresh = now;
                await this.refreshPublishedRecords();
            }

            return false;
        }, { timeout, interval: 1000, timeoutMsg: 'Expected at least one published record' });
    }

    async viewNthPublishedRecord(number= 0){
        let buttons = await this.viewPublishedRecordBtn;
        await buttons[number].waitForClickable({ timeout: 10000 });
        await buttons[number].click();
        await this.modalCloseBtn.waitForExist({ timeout: 10000 });
    }

    async viewPublishedRecordContainingSpecies(speciesName, timeout = 60000) {
        await browser.waitUntil(async () => {
            const buttons = await this.viewPublishedRecordBtn;
            for (let i = 0; i < buttons.length; i++) {
                const currentButtons = await this.viewPublishedRecordBtn;
                await currentButtons[i].waitForClickable({ timeout: 10000 });
                await currentButtons[i].click();
                await this.modalCloseBtn.waitForExist({ timeout: 10000 });
                await browser.switchFrame(this.pwaFrame);

                try {
                    await $(`span=${speciesName}`).waitForExist({ timeout: 5000 });
                    return true;
                }
                catch {
                    // This published record is not the one created by the current scenario.
                }

                await this.switchToTopFrame();
                await this.closeModal();
            }

            await this.refreshPublishedRecords();
            return false;
        }, { timeout, interval: 1000, timeoutMsg: `Expected a published record containing species ${speciesName}` });
    }

    async refreshPublishedRecords() {
        await this.refreshPublishedBtn.waitForClickable({ timeout: 10000 });
        await this.refreshPublishedBtn.click();
    }

    async viewNthUnpublishedRecord(number= 0){
        let buttons = await this.viewUnpublishedRecordBtn;
        await buttons[number].waitForClickable({ timeout: 10000 });
        await buttons[number].click();
        await this.modalCloseBtn.waitForExist({ timeout: 10000 });
    }

    async editNthUnpublishedRecord(number= 0){
        let buttons = await this.editUnpublishedRecordBtn;
        await buttons[number].waitForClickable({ timeout: 10000 });
        await buttons[number].click();
        await this.modalCloseBtn.waitForExist({ timeout: 10000 });
    }

    async uploadNthUnpublishedRecord(number= 0){
        let buttons = await this.uploadUnpublishedRecordBtn;
        await buttons[number].waitForClickable({ timeout: 10000 });
        await buttons[number].click();
    }

    async invalidNthUnpublishedRecord(number= 0){
        let invalidMessages = await this.invalidUnpublishedRecord;
        if (!invalidMessages[number]) {
            return false;
        }
        return await invalidMessages[number].isExisting();
    }

    async refreshUnpublishedRecords() {
        await this.refreshUnpublishedBtn.waitForClickable({ timeout: 10000 });
        await this.refreshUnpublishedBtn.click();
    }

    async unpublishedCount(){
        return (await this.nthUnpublishedRecord).length;
    }

    async publishedCount(){
        return (await this.nthPublishedRecord).length;
    }

    async waitForUnpublishedCount(count, timeout = 10000) {
        await browser.waitUntil(async () => {
            return (await this.unpublishedCount()) === count;
        }, { timeout, timeoutMsg: `Expected ${count} unpublished records` });
    }

    async waitForInvalidNthUnpublishedRecord(number = 0, expected = true, timeout = 10000) {
        await browser.waitUntil(async () => {
            return (await this.invalidNthUnpublishedRecord(number)) === expected;
        }, { timeout, timeoutMsg: `Expected unpublished record ${number} invalid state to be ${expected}` });
    }
}

module.exports = PwaAppPage;