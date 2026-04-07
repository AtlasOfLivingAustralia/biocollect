const StubbedCasSpec = require('./StubbedCasSpec.js')
const ReloadablePage = require('./ReloadablePage.js')
class PwaAppPage extends ReloadablePage {
    url = browser.options.testConfig.pwaUrl;
    avatarSelector = 'header button.mantine-UnstyledButton-root, header .mantine-Avatar-root';

    get getStarted() {
        return $('#getStarted');
    }

    get avatar() {
        return $('.mantine-Avatar-root');
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

    get viewRecordBtn() {
        return $$('[data-testid="view-record"]');
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

    viewUnpublishedRecordsBtn(paId) {
        return $(`#${paId}UnpublishedRecords`);
    }
    get modalConfirmationButton() {
        return $('#confirmDownloadModal');
    }
    get modalCloseBtn() {
        return $('.mantine-Modal-close');
    }

    get rightDrawer() {
        return $('.mantine-Drawer-content');
    }

    async open() {
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
        if (await this.getStarted.isExisting() && await this.getStarted.isDisplayed()) {
            await this.getStarted.click();
            await browser.pause(3000);
            return true;
        }

        return false;
    }

    async start() {
        await this.maybeStart();
    }

    async logout() {
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
        await this.signIn.waitForDisplayed({ timeout: 15000 });
    }

    async viewProject(projectId) {
        await this.maybeStart();

        let projectElement = this.project(projectId);
        await projectElement.waitForExist({ timeout: 60000 });
        await projectElement.scrollIntoView();
        await browser.pause(500);
        await projectElement.click();
    }

    async viewRecords(paId) {
        await this.viewRecordsBtn(paId).click()
        await this.rightDrawer.waitForExist({ timeout: 10000 });
    }

    async viewUnpublishedRecords(paId) {
        var btn = this.viewUnpublishedRecordsBtn(paId)
        await btn.waitForEnabled({ timeout: 10000 });
        await this.viewUnpublishedRecordsBtn(paId).click()
        await this.modalCloseBtn.waitForExist({ timeout: 10000 });
    }
    async downloadProjectActivity(paId){
        await this.projectActivityDownload(paId).click();
    }

    async downloadComplete() {
        let btn = this.modalConfirmationButton
        await browser.waitUntil(() => btn.isClickable(), {timeout: 5 * 60 * 60 * 1000});
        await btn.click();
    }

    async addRecord(paId){
        let btn = this.addRecordBtn(paId);
        await btn.waitForExist({ timeout: 20000 });
        await btn.scrollIntoView();
        await btn.waitForClickable({ timeout: 10000 });
        await btn.click();
    }

    async closeModal(){
        let modal = this.modalCloseBtn;
        await modal.waitForEnabled({ timeout: 10000 });
        await modal.click();
    }

    async viewNthRecord(number= 0){
        await this.viewRecordBtn[number].click();
        await this.modalCloseBtn.waitForExist({ timeout: 10000 });
    }
}

module.exports = PwaAppPage;