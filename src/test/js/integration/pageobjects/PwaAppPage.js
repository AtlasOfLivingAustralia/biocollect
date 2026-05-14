const StubbedCasSpec = require('./StubbedCasSpec.js')
const ReloadablePage = require('./ReloadablePage.js')
class PwaAppPage extends ReloadablePage {
    url = browser.options.testConfig.pwaUrl;

    get getStarted() {
        return $('#getStarted');
    }

    get avatar() {
        return $('.mantine-Avatar-placeholder');
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
        await this.signIn.waitForDisplayed({ timeout: 10000 });
        return await this.signIn.isDisplayed();
    }

    async start() {
        await this.getStarted.waitForDisplayed({ timeout: 10000 });
        await this.getStarted.click();
        // Wait for the projects to load after clicking Get Started
        // We'll wait for any element that looks like a project ID (starts with #project_)
        await browser.pause(3000);
    }

    async logout(){
        await this.closeModalIfOpen();
        await this.avatar.waitForDisplayed({ timeout: 60000 });
        await this.avatar.scrollIntoView();
        await this.avatar.waitForClickable({ timeout: 60000 });
        await this.avatar.click();
        await this.signOut.waitForClickable({ timeout: 60000 });
        await this.signOut.click();
        // wait for sign out to complete and sign in button to be visible again
        await this.signOut.waitForDisplayed({ timeout: 60000, reverse: true });
        await this.signIn.waitForDisplayed({ timeout: 60000 });
    }

    get modalHeader() {
        return $('.mantine-Modal-header');
    }

    async closeModalIfOpen() {
        if (await this.modalHeader.isExisting()) {
            await this.modalCloseBtn.waitForClickable({ timeout: 10000 });
            await this.modalCloseBtn.click();
            await browser.waitUntil(
                async () => !(await this.modalHeader.isExisting()),
                {
                    timeout: 10000,
                    timeoutMsg: 'Modal did not close before logout'
                }
            );
        }
    }

    async viewProject(projectId) {
        let projectElement = this.project(projectId);
        await projectElement.waitForExist({ timeout: 20000 });
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
        await browser.waitUntil(() => btn.isClickable(), {timeout: 5*60*60*1000});
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