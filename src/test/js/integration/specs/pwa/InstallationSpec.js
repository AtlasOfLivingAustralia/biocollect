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
        await browser.pause(30000);
    });

    afterAll(async function () {
        await stopServer();
    });

    it("submit record offline and publish it when network returns", async function () {
        console.log(url);
        await pwaAppPage.start();
        await addBioActivityPage.takeScreenShot("openProjectAndTakeItOffline");
        await pwaAppPage.viewProject(project);
        await pwaAppPage.downloadProjectActivity(pa);
        await addBioActivityPage.takeScreenShot("openProjectAndTakeItOfflineBeforeDownload");
        await pwaAppPage.downloadComplete();
        await stopServer();
        await pwaAppPage.addRecord(pa);
        await browser.pause(5000);
        let iframe =  await browser.findElement('tag name', 'iframe');
        let contextId = await browser.switchToFrame(iframe);
        console.log("iframe context id- " +contextId);
        await addBioActivityPage.setSite(site);
        await addBioActivityPage.uploadImage(`${addBioActivityPage.testConfig.resourceDir}/images/10_years.png`, true);
        // Wait for all promises to resolve
        await Promise.all(promises);
        await addBioActivityPage.setDate('01/01/2020');
        await addBioActivityPage.setSpecies('Acavomonidia', true)
        // Save the activity
        await addBioActivityPage.saveActivity();
        await addBioActivityPage.takeScreenShot("openProjectAndTakeItOfflineAfterSave");
        contextId = await browser.switchToFrame(null);
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

        iframe =  await browser.findElement('tag name', 'iframe');
        console.log("iframe url  - " + JSON.stringify(iframe));
        contextId = await browser.switchToFrame(iframe);
        console.log("iframe context id- " +contextId);

        offlineListPage = new OfflineListPage();
        expect(await offlineListPage.at()).toEqual(true);
        await expect(offlineListPage.uploadAllButton).toBeEnabled();
        await expect(offlineListPage.firstUploadButton).toBeEnabled();
        await offlineListPage.uploadRecords();
        await addBioActivityPage.takeScreenShot("openProjectAndTakeItOfflinePublishedRecords");
        await browser.pause(5000);
        await expect(offlineListPage.uploadAllButton).toBeDisabled();

        await expect(await offlineListPage.alert).toHaveText("Unpublished records not found");
        await browser.switchToFrame(null);
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
        await pwaAppPage.closeModal(null);
    });

    it("submit record offline, choose a site on map and publish it when network returns", async function () {
        console.log(url);
        let getStarted = await pwaAppPage.getStarted;
        if (getStarted && (await getStarted.isDisplayed())) {
            await pwaAppPage.start();
        }
        await addBioActivityPage.takeScreenShot("pinSubmitRecordOfflineAndChooseSiteOnMap");
        await pwaAppPage.viewProject(project);
        await stopServer();
        await pwaAppPage.addRecord(pa);
        await browser.pause(5000);
        let iframe =  await browser.findElement('tag name', 'iframe');
        let contextId = await browser.switchFrame($("iframe"));
        console.log("iframe context id- " +contextId);
        await addBioActivityPage.dropPin();
        await addBioActivityPage.uploadImage(`${addBioActivityPage.testConfig.resourceDir}/images/10_years.png`, true);
        // Wait for all promises to resolve
        await Promise.all(promises);
        await addBioActivityPage.setDate('01/01/2020');
        await addBioActivityPage.setSpecies('Acavomonidia', true)
        // Save the activity
        await addBioActivityPage.saveActivity();
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
        expect(await offlineListPage.at()).toEqual(true);
        await expect(offlineListPage.uploadAllButton).toBeEnabled();
        await expect(offlineListPage.firstUploadButton).toBeEnabled();
        await offlineListPage.uploadRecords();
        await addBioActivityPage.takeScreenShot("pinSubmitRecordOfflineAndChooseSiteOnMapPublishedRecords");
        await browser.pause(5000);
        await expect(offlineListPage.uploadAllButton).toBeDisabled();

        await expect(await offlineListPage.alert).toHaveText("Unpublished records not found");
        await browser.switchFrame(null);
        await pwaAppPage.closeModal();

        // check if the record is uploaded
        await pwaAppPage.viewRecords(pa);
        await pwaAppPage.viewNthRecord(1);
        await browser.pause(3000);
        iframe = $("iframe");
        contextId = await browser.switchFrame(iframe);
        console.log("iframe context id- " +contextId);
        let viewBioActivityPage = new ViewBioActivityPage();
        var speciesEl = viewBioActivityPage.speciesSelector("Acavomonidia");
        await addBioActivityPage.takeScreenShot("pinSubmitRecordOfflineAndChooseSiteOnMapViewPublishedRecord");
        await speciesEl.scrollIntoView();
        await expect(speciesEl).toBeDisplayed();
        // map pin should be displayed
        var pin =$('.leaflet-marker-icon');
        await pin.scrollIntoView();
        await expect(pin).toBeDisplayed();
        await browser.switchFrame(null);
        await pwaAppPage.closeModal(null);
    });

    it("login with expired token", async function () {
        await pwaAppPage.logout();
        await pwaAppPage.atSignIn();
        await pwaAppPage.loginAsPwaUser(true);
        await pwaAppPage.open();
        expect(await pwaAppPage.atSignIn()).toBeTrue();
        await pwaAppPage.loginAsPwaUser(false);
        await pwaAppPage.open();
        await pwaAppPage.at();
    });
});