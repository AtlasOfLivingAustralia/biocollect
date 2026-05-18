const AdminToolsPage = require('../../pageobjects/AdminToolsPage');
const PwaAppPage = require('../../pageobjects/PwaAppPage');
const AddBioActivityPage = require("../../pageobjects/AddBioActivityPage");
const ViewBioActivityPage = require("../../pageobjects/ViewBioActivityPage");
const HomePage = require("../../pageobjects/HomePage");
const OfflineListPage = require("../../pageobjects/OfflineListPage");
const {startServer, stopServer} = require('../../utils/proxy');
const {browser} = require("@wdio/globals");

describe("Application installation Spec", function () {
    var pa = 'pa_1', project = 'project_1', site = "ab9ec9af-241b-49f7-adcf-ca40e474d119", promises = [], url,
        adminToolsPage, pwaAppPage, addBioActivityPage, homePage, offlineListPage, timeout = 4000;


    beforeAll(async function () {
        adminToolsPage = new AdminToolsPage();
        homePage = new HomePage();
        pwaAppPage = new PwaAppPage();
        addBioActivityPage = new AddBioActivityPage();
        url = `${pwaAppPage.baseUrl}/pwa/bioActivity/edit/${pa}`;
        await startServer();
        await adminToolsPage.loadDataSet('dataset1');
        await adminToolsPage.setupTokenForSystem();
        await homePage.open();
        await adminToolsPage.loginAsAlaAdmin();
        await adminToolsPage.reindex();
    });

    beforeEach(async function () {
        await pwaAppPage.open();
        await pwaAppPage.loginAsPwaUser();
        await pwaAppPage.open();
        // await browser.pause(5000);
        // await pwaAppPage.start();
        // console.log("before each - start");
    });

    afterEach(async function () {
        try {
            await browser.switchFrame(null);
            await pwaAppPage.logout();
        }
        catch (e) {
            console.log("Logout failed:", e.message);
        }
    });

    afterAll(async function () {
        await stopServer();
    });

    it("submit record offline and publish it when network returns", async function () {
        await pwaAppPage.start();
        await addBioActivityPage.takeScreenShot("openProjectAndTakeItOffline");
        await pwaAppPage.viewProject(project);
        await pwaAppPage.downloadProjectActivity(pa);
        await addBioActivityPage.takeScreenShot("openProjectAndTakeItOfflineBeforeDownload");
        await pwaAppPage.downloadComplete();
        await stopServer();
        await pwaAppPage.addRecord(pa);
        await browser.pause(5000);
        let iframe = $('iframe');
        let contextId = await browser.switchFrame(iframe);
        console.log("iframe context id- " +contextId);
        await addBioActivityPage.setSite(site);
        await addBioActivityPage.uploadImage(`${addBioActivityPage.testConfig.resourceDir}/images/10_years.png`, true);

        await addBioActivityPage.setDate('01/01/2020');
        await addBioActivityPage.setSpecies('Acavomonidia', true)
        // Save the activity
        await addBioActivityPage.saveActivity();
        await addBioActivityPage.takeScreenShot("openProjectAndTakeItOfflineAfterSave");
        contextId = await browser.switchFrame(null);
        console.log("main frame context id- " +contextId);
        contextId = await browser.switchFrame(null);
        console.log("main frame context id- " +contextId);
        await pwaAppPage.closeModal();

        await startServer();
        await pwaAppPage.open();
        await pwaAppPage.viewProject(project);
        await pwaAppPage.viewRecords(pa);
        await pwaAppPage.viewUnpublishedRecords(pa);
        await addBioActivityPage.takeScreenShot("openProjectAndTakeItOfflineUnpublishedRecords");

        iframe = $('iframe');
        console.log("iframe url  - " + JSON.stringify(iframe));
        contextId = await browser.switchFrame(iframe);
        console.log("iframe context id- " +contextId);

        offlineListPage = new OfflineListPage();
        expect(await offlineListPage.at()).toEqual(true);
        await expect(offlineListPage.uploadAllButton).toBeEnabled();
        await expect(offlineListPage.firstUploadButton).toBeEnabled();

        await offlineListPage.uploadRecords();

        await addBioActivityPage.takeScreenShot("openProjectAndTakeItOfflinePublishedRecords");
        await browser.pause(5000);

        const firstUploadButtonExists = await offlineListPage.firstUploadButton.isExisting();
        if (firstUploadButtonExists) {
            console.log("firstUploadButton enabled:", await offlineListPage.firstUploadButton.isEnabled());
        }
        const alertExists = await offlineListPage.alert.isExisting();
        if (alertExists) {
            console.log("alert text:", await offlineListPage.alert.getText());
        }

        await expect(offlineListPage.uploadAllButton).toBeDisabled();

        // await expect(await offlineListPage.alert).toHaveText("Unpublished records not found");
        await browser.switchFrame(null);
        await pwaAppPage.closeModal();

        // check if the record is uploaded
        await pwaAppPage.viewRecords(pa);
        await pwaAppPage.viewNthRecord();
        await browser.pause(3000);
        iframe = $("iframe");
        contextId = await browser.switchFrame(iframe);
        console.log("iframe context id- " +contextId);
        let viewBioActivityPage = new ViewBioActivityPage();
        var speciesEl = viewBioActivityPage.speciesSelector("Acavomonidia");
        await addBioActivityPage.takeScreenShot("openProjectAndTakeItOfflineViewPublishedRecord");
        await speciesEl.scrollIntoView();
        await expect(speciesEl).toBeDisplayed();
        await browser.switchFrame(null);
        await pwaAppPage.closeModal();
    });

    it("submit record offline and choose a site on map and publish it when network returns", async function () {
        let getStarted = await pwaAppPage.getStarted;
        if (getStarted && (await getStarted.isDisplayed())) {
            await pwaAppPage.start();
        }
        await addBioActivityPage.takeScreenShot("pinSubmitRecordOfflineAndChooseSiteOnMap");
        await pwaAppPage.viewProject(project);
        const addRecordButton = pwaAppPage.addRecordBtn(pa);
        await addRecordButton.waitForExist({ timeout: 20000 });
        await addRecordButton.waitForDisplayed({ timeout: 20000 });
        await stopServer();
        await addRecordButton.click();
        await browser.pause(5000);
        let iframe = $('iframe');
        let contextId = await browser.switchFrame(iframe);
        await addBioActivityPage.dropPin();

        await addBioActivityPage.uploadImage(`${addBioActivityPage.testConfig.resourceDir}/images/10_years.png`, true);
        await addBioActivityPage.setDate('01/01/2020');
        await addBioActivityPage.setSpecies('Fungi', true);
        await addBioActivityPage.saveActivity();
        await addBioActivityPage.takeScreenShot("pinSubmitRecordOfflineAndChooseSiteOnMapAfterSave");
        contextId = await browser.switchFrame(null);
        await pwaAppPage.closeModal();

        await startServer();
        await pwaAppPage.open();
        await pwaAppPage.viewProject(project);
        await pwaAppPage.viewRecords(pa);
        await pwaAppPage.viewUnpublishedRecords(pa);
        await addBioActivityPage.takeScreenShot("pinSubmitRecordOfflineAndChooseSiteOnMapUnpublishedRecords");

        contextId = await browser.switchFrame($('iframe'));
        console.log("iframe context id- " +contextId);

        offlineListPage = new OfflineListPage();

        expect(await offlineListPage.at()).toEqual(true);
        await expect(offlineListPage.uploadAllButton).toBeEnabled();
        await expect(offlineListPage.firstUploadButton).toBeEnabled();

        await offlineListPage.uploadRecords();

        await addBioActivityPage.takeScreenShot("pinSubmitRecordOfflineAndChooseSiteOnMapPublishedRecords");
        await browser.pause(5000);

        const firstUploadButtonExists = await offlineListPage.firstUploadButton.isExisting();
        if (firstUploadButtonExists) {
            console.log("firstUploadButton enabled:", await offlineListPage.firstUploadButton.isEnabled());
        }
        const alertExists = await offlineListPage.alert.isExisting();
        if (alertExists) {
            console.log("alert text:", await offlineListPage.alert.getText());
        }

        await expect(offlineListPage.uploadAllButton).toBeDisabled();

        // await expect(await offlineListPage.alert).toHaveText("Unpublished records not found");
        await browser.switchFrame(null);
        await pwaAppPage.closeModal();

        // check if the record is uploaded
        await pwaAppPage.viewRecords(pa);
        await browser.pause(5000);
        await pwaAppPage.viewNthRecord();
        await browser.pause(3000);
        iframe = $("iframe");
        contextId = await browser.switchFrame(iframe);

        let viewBioActivityPage = new ViewBioActivityPage();
        var speciesEl = viewBioActivityPage.speciesSelector("Fungi");

        await speciesEl.waitForExist({ timeout: 20000 });
        await speciesEl.scrollIntoView();
        await expect(speciesEl).toBeDisplayed();

        const pin = await $('.leaflet-marker-icon');
        await pin.waitForExist({ timeout: 20000 });
        await pin.waitForDisplayed({ timeout: 20000 });
        await expect(pin).toBeDisplayed();

        await browser.switchFrame(null);
        await pwaAppPage.closeModal(null);
    });

    it("login with expired token", async function () {

        console.log("login with expired token - start");
        console.log("Current URL " + await browser.getUrl());
        console.log("Current title " + await browser.getTitle());
        await pwaAppPage.takeScreenShot("loginWithExpiredTokenBeforeLogout");
        await pwaAppPage.logout();
        console.log("login with expired token - logout");
        await pwaAppPage.atSignIn();
        console.log("login with expired token - at sign in page");
        await pwaAppPage.loginAsPwaUser(true);
        console.log("login with expired token - login as pwa user with expired token");
        await pwaAppPage.open();
        await browser.pause(2000);
        // await browser.getUrl();
        console.log("login with expired token - open");
        expect(await pwaAppPage.atSignIn()).toEqual(true);
        console.log("login with expired token - expect to be at sign in page");
        await pwaAppPage.loginAsPwaUser(false);
        console.log("login with expired token - login as pwa user not expired");
        await pwaAppPage.open();
        console.log("login with expired token - open again");
        await pwaAppPage.at();
        console.log("login with expired token - at pwa app page");
    });
});