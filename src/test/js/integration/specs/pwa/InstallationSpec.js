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
        console.log("before each");
        await pwaAppPage.open();
        console.log("before each - open");
        await pwaAppPage.loginAsPwaUser();
        console.log("before each - login");
        await pwaAppPage.open();
        console.log("before each - open again");
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
        console.log("number of records checked again");

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

        console.log("offlineListPage.at:", await offlineListPage.at());
        console.log("uploadAllButton exists before:", await offlineListPage.uploadAllButton.isExisting());
        console.log("uploadAllButton enabled before:", await offlineListPage.uploadAllButton.isEnabled());
        console.log("firstUploadButton exists before:", await offlineListPage.firstUploadButton.isExisting());
        console.log("firstUploadButton enabled before:", await offlineListPage.firstUploadButton.isEnabled());
        console.log("alert exists before:", await offlineListPage.alert.isExisting());

        expect(await offlineListPage.at()).toEqual(true);
        await expect(offlineListPage.uploadAllButton).toBeEnabled();
        await expect(offlineListPage.firstUploadButton).toBeEnabled();

        console.log("calling uploadRecords");
        await offlineListPage.uploadRecords();
        console.log("uploadRecords completed");

        await addBioActivityPage.takeScreenShot("openProjectAndTakeItOfflinePublishedRecords");
        await browser.pause(5000);

        console.log("uploadAllButton exists:", await offlineListPage.uploadAllButton.isExisting());
        console.log("uploadAllButton enabled:", await offlineListPage.uploadAllButton.isEnabled());
        const firstUploadButtonExists = await offlineListPage.firstUploadButton.isExisting();
        console.log("firstUploadButton exists:", firstUploadButtonExists);

        if (firstUploadButtonExists) {
            console.log("firstUploadButton enabled:", await offlineListPage.firstUploadButton.isEnabled());
        }
        const alertExists = await offlineListPage.alert.isExisting();
        console.log("alert exists:", alertExists);
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
        console.log("test2: view project");
        await pwaAppPage.viewProject(project);
        console.log("test2: view project done");

        await stopServer();
        console.log("test2: stop server done");

        console.log("test2: add record");
        await pwaAppPage.addRecord(pa);

        console.log("test2: switch iframe");
        await browser.pause(5000);
        let iframe = $('iframe');
        let contextId = await browser.switchFrame(iframe);
        console.log("iframe context id- " +contextId);
        console.log("test2: before dropPin");
        await addBioActivityPage.dropPin();

        console.log("test2: before uploadImage");
        await addBioActivityPage.uploadImage(`${addBioActivityPage.testConfig.resourceDir}/images/10_years.png`, true);

        console.log("test2: before setDate");
        await addBioActivityPage.setDate('01/01/2020');

        console.log("test2: before setSpecies");
        await addBioActivityPage.setSpecies('Fungi', true);

        console.log("test2: before saveActivity");
        await addBioActivityPage.saveActivity();

        console.log("test2: after saveActivity");
        await addBioActivityPage.takeScreenShot("pinSubmitRecordOfflineAndChooseSiteOnMapAfterSave");
        contextId = await browser.switchFrame(null);
        console.log("main frame context id- " +contextId);
        await pwaAppPage.closeModal();
        console.log("number of records checked again");

        await startServer();
        await pwaAppPage.open();
        await pwaAppPage.viewProject(project);
        await pwaAppPage.viewRecords(pa);
        await pwaAppPage.viewUnpublishedRecords(pa);
        await addBioActivityPage.takeScreenShot("pinSubmitRecordOfflineAndChooseSiteOnMapUnpublishedRecords");

        contextId = await browser.switchFrame($('iframe'));
        console.log("iframe context id- " +contextId);

        offlineListPage = new OfflineListPage();

        console.log("offlineListPage.at:", await offlineListPage.at());
        console.log("uploadAllButton exists before:", await offlineListPage.uploadAllButton.isExisting());
        console.log("uploadAllButton enabled before:", await offlineListPage.uploadAllButton.isEnabled());
        console.log("firstUploadButton exists before:", await offlineListPage.firstUploadButton.isExisting());
        console.log("firstUploadButton enabled before:", await offlineListPage.firstUploadButton.isEnabled());
        console.log("alert exists before:", await offlineListPage.alert.isExisting());

        expect(await offlineListPage.at()).toEqual(true);
        await expect(offlineListPage.uploadAllButton).toBeEnabled();
        await expect(offlineListPage.firstUploadButton).toBeEnabled();

        console.log("calling uploadRecords");
        await offlineListPage.uploadRecords();
        console.log("uploadRecords completed");

        await addBioActivityPage.takeScreenShot("pinSubmitRecordOfflineAndChooseSiteOnMapPublishedRecords");
        await browser.pause(5000);

        console.log("uploadAllButton exists:", await offlineListPage.uploadAllButton.isExisting());
        console.log("uploadAllButton enabled:", await offlineListPage.uploadAllButton.isEnabled());
        const firstUploadButtonExists = await offlineListPage.firstUploadButton.isExisting();
        console.log("firstUploadButton exists:", firstUploadButtonExists);

        if (firstUploadButtonExists) {
            console.log("firstUploadButton enabled:", await offlineListPage.firstUploadButton.isEnabled());
        }
        const alertExists = await offlineListPage.alert.isExisting();
        console.log("alert exists:", alertExists);
        if (alertExists) {
            console.log("alert text:", await offlineListPage.alert.getText());
        }

        console.log("test2: upload button disabled assertion");
        await expect(offlineListPage.uploadAllButton).toBeDisabled();

        // await expect(await offlineListPage.alert).toHaveText("Unpublished records not found");
        await browser.switchFrame(null);
        await pwaAppPage.closeModal();

        // check if the record is uploaded
        console.log("test2: view records");
        await pwaAppPage.viewRecords(pa);

        console.log("test2: wait after view records");
        await browser.pause(5000);

        console.log("test2: view nth record");
        await pwaAppPage.viewNthRecord();

        console.log("test2: wait after view nth record");
        await browser.pause(3000);

        console.log("test2: switch to view record iframe");
        iframe = $("iframe");
        contextId = await browser.switchFrame(iframe);
        console.log("test2: iframe context id- " + contextId);

        let viewBioActivityPage = new ViewBioActivityPage();
        var speciesEl = viewBioActivityPage.speciesSelector("Fungi");

        console.log("test2: wait for species");
        await speciesEl.waitForExist({ timeout: 20000 });

        console.log("test2: species exists");
        await speciesEl.scrollIntoView();

        console.log("test2: species scrolled");
        await expect(speciesEl).toBeDisplayed();

        console.log("test2: species displayed");

        const pin = await $('.leaflet-marker-icon');

        console.log("test2: wait for pin exists");
        await pin.waitForExist({ timeout: 20000 });

        console.log("test2: pin exists");
        await pin.waitForDisplayed({ timeout: 20000 });

        console.log("test2: pin displayed");
        await expect(pin).toBeDisplayed();

        console.log("test2: switch to main frame");
        await browser.switchFrame(null);

        console.log("test2: close final modal");
        await pwaAppPage.closeModal(null);

        console.log("test2: finished");
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