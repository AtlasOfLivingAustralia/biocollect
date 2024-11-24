const StubbedCasSpec = require('./StubbedCasSpec.js')
class PwaAppPage extends StubbedCasSpec {
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
        await browser.url(this.url);
    }

    async at() {
        return /BioCollect PWA/i.test(await browser.getTitle());
    }

    async atSignIn() {
        return await this.signIn.isDisplayed();
    }

    async start() {
        await this.getStarted.waitForDisplayed({ timeout: 10000 });
        await this.getStarted.click();
    }

    async logout(){
        await this.avatar.click();
        await this.signOut.click();
    }

    async viewProject(projectId) {
        await this.project(projectId).click()
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
        await this.addRecordBtn(paId).click();
    }

    async closeModal(){
        let modal = this.modalCloseBtn;
        await modal.waitForEnabled({ timeout: 10000 });
        await modal.click();
    }

    async viewFirstRecord(){
        await this.viewRecordBtn[0].click();
        await this.modalCloseBtn.waitForExist({ timeout: 10000 });
    }
}

module.exports = PwaAppPage;