const AdminToolsPage = require('../../pageobjects/AdminToolsPage');
const PwaAppPage = require('../../pageobjects/PwaAppPage');
const AddBioActivityPage = require("../../pageobjects/AddBioActivityPage");
const ViewBioActivityPage = require("../../pageobjects/ViewBioActivityPage");
const HomePage = require("../../pageobjects/HomePage");
const {startServer, stopServer} = require('../../utils/proxy');
const {browser} = require("@wdio/globals");

describe("Application installation Spec", function () {
    var pa = 'pa_1', project = 'project_1', site = "ab9ec9af-241b-49f7-adcf-ca40e474d119",
        adminToolsPage, pwaAppPage, addBioActivityPage, homePage;


    beforeAll(async function () {
        adminToolsPage = new AdminToolsPage();
        homePage = new HomePage();
        pwaAppPage = new PwaAppPage();
        addBioActivityPage = new AddBioActivityPage();
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
    });

    afterEach(async function () {
        await browser.switchFrame(null);
        await stopServer();
        await startServer();
        await pwaAppPage.logout();
    });

    afterAll(async function () {
        await stopServer();
    });

    it("submit record offline and publish it when network returns", async function () {
        // Start the PWA, download a survey & go offline
        console.log('Starting the PWA');
        await pwaAppPage.start();
        await addBioActivityPage.takeScreenShot("offlineRecordExistingSiteProjectList");
        await pwaAppPage.viewProject(project);

        console.log('Downloading project activity')
        await pwaAppPage.downloadProjectActivity(pa);
        await addBioActivityPage.takeScreenShot("offlineRecordExistingSiteDownloadProgress");
        await pwaAppPage.downloadComplete();

        console.log('Going offline');
        await stopServer();

        // Add a new record to the downloaded survey
        console.log('Opening add record page');
        await pwaAppPage.addRecord(pa);

        let iframe = pwaAppPage.pwaFrame;
        await browser.switchFrame(iframe);
        console.log(`Partially filling out form...`);

        await addBioActivityPage.setSite(site);
        await addBioActivityPage.uploadImage(`${addBioActivityPage.testConfig.resourceDir}/images/10_years.png`, true);
        await addBioActivityPage.setSpecies('Acavomonidia', true)

        // Save the activity
        console.log('Saving unfinished activity & closing modal...')
        await addBioActivityPage.saveActivity();
        await addBioActivityPage.takeScreenShot("offlineRecordExistingSiteIncompleteRecordSaved");

        await browser.switchFrame(null);
        await pwaAppPage.closeConfirmModal();

        // Ensure unpublished record has visual flag
        await pwaAppPage.waitForInvalidNthUnpublishedRecord(0, true, 20000);
        await addBioActivityPage.takeScreenShot("offlineRecordExistingSiteInvalidUnpublishedRecord");
        expect(await pwaAppPage.invalidNthUnpublishedRecord()).toBe(true);

        // Edit unpublished record and add date
        console.log('Editing unfinished record');
        await pwaAppPage.editNthUnpublishedRecord();
        await browser.switchFrame(pwaAppPage.pwaFrame);
        await addBioActivityPage.setDate('01/01/2020');

        // Save record and close modal
        console.log('Saving finished activity & closing modal...')
        await addBioActivityPage.saveActivity();
        await addBioActivityPage.takeScreenShot("offlineRecordExistingSiteCompleteRecordSaved");
        await browser.switchFrame(null);
        await pwaAppPage.closeModal();

        await pwaAppPage.waitForUnpublishedCount(1, 20000);
        await pwaAppPage.waitForInvalidNthUnpublishedRecord(0, false, 20000);
        await addBioActivityPage.takeScreenShot("offlineRecordExistingSiteValidUnpublishedRecord");
        expect(await pwaAppPage.invalidNthUnpublishedRecord()).toBe(false);

        // Go online again & view the unpublished records
        console.log('Going online again & viewing the complete unpublished record')
        await startServer();
        await pwaAppPage.open();
        await pwaAppPage.viewProject(project);
        await pwaAppPage.viewRecords(pa);
        await addBioActivityPage.takeScreenShot("offlineRecordExistingSiteUnpublishedDrawer");

        console.log('Viewing the first unpublished record');
        await pwaAppPage.viewNthUnpublishedRecord();
        await browser.switchFrame(pwaAppPage.pwaFrame);

        const unpublishedViewBioActivityPage = new ViewBioActivityPage();
        const unpublishedSpeciesEl = unpublishedViewBioActivityPage.speciesSelector("Acavomonidia");
        await addBioActivityPage.takeScreenShot("offlineRecordExistingSiteViewUnpublishedRecord");
        await unpublishedSpeciesEl.scrollIntoView();
        await expect(unpublishedSpeciesEl).toBeDisplayed();
        await browser.switchFrame(null);
        await pwaAppPage.closeModal();

        console.log('Uploading the record');
        await pwaAppPage.uploadNthUnpublishedRecord();
        await pwaAppPage.waitForUnpublishedCount(0, 30000);
        expect(await pwaAppPage.unpublishedCount()).toBe(0);

        console.log('Checking that the published record exists');
        await pwaAppPage.switchToPublishedTab();
        await pwaAppPage.refreshPublishedRecords();
        await pwaAppPage.waitForPublishedRecord();
        await addBioActivityPage.takeScreenShot("offlineRecordExistingSitePublishedDrawer");

        console.log('Viewing published record');
        await pwaAppPage.viewNthPublishedRecord();
        await browser.switchFrame(pwaAppPage.pwaFrame);

        const publishedViewBioActivityPage = new ViewBioActivityPage();
        const publishedSpeciesEl = publishedViewBioActivityPage.speciesSelector("Acavomonidia");
        await addBioActivityPage.takeScreenShot("offlineRecordExistingSiteViewPublishedRecord");
        await publishedSpeciesEl.scrollIntoView();
        await expect(publishedSpeciesEl).toBeDisplayed();
        await browser.switchFrame(null);
        await pwaAppPage.closeModal();
    });

    it("submit record offline and choose a site on map and publish it when network returns", async function () {
        // Start the PWA, download a survey & go offline
        await pwaAppPage.start();
        await addBioActivityPage.takeScreenShot("offlineRecordMapPinProjectList");
        await pwaAppPage.viewProject(project);

        console.log('Downloading project activity');
        await pwaAppPage.downloadProjectActivity(pa);
        await addBioActivityPage.takeScreenShot("offlineRecordMapPinDownloadProgress");
        await pwaAppPage.downloadComplete();

        console.log('Going offline');
        await stopServer();

        await pwaAppPage.addRecord(pa);
        await browser.switchFrame(pwaAppPage.pwaFrame);
        await addBioActivityPage.dropPin();
        await addBioActivityPage.uploadImage(`${addBioActivityPage.testConfig.resourceDir}/images/10_years.png`, true);
        await addBioActivityPage.setDate('01/01/2020');
        await addBioActivityPage.setSpecies('Fungi', true)
        await addBioActivityPage.takeScreenShot("offlineRecordMapPinCompletedForm");

        // Save the activity
        await addBioActivityPage.saveActivity();
        await addBioActivityPage.takeScreenShot("offlineRecordMapPinSavedRecord");
        await browser.switchFrame(null);
        await pwaAppPage.closeModal();

        console.log('Going online again & viewing the complete unpublished record');
        await startServer();
        await pwaAppPage.open();
        await pwaAppPage.viewProject(project);
        await pwaAppPage.viewRecords(pa);
        await addBioActivityPage.takeScreenShot("offlineRecordMapPinUnpublishedDrawer");

        console.log('Uploading the record');
        await pwaAppPage.uploadNthUnpublishedRecord();
        await pwaAppPage.waitForUnpublishedCount(0, 30000);
        expect(await pwaAppPage.unpublishedCount()).toBe(0);

        console.log('Checking that the published record exists');
        await pwaAppPage.switchToPublishedTab();
        await pwaAppPage.refreshPublishedRecords();
        await pwaAppPage.waitForPublishedRecord();
        await addBioActivityPage.takeScreenShot("offlineRecordMapPinPublishedDrawer");

        console.log('Viewing published record');
        await pwaAppPage.viewNthPublishedRecord();
        await browser.switchFrame(pwaAppPage.pwaFrame);
        const viewBioActivityPage = new ViewBioActivityPage();
        const speciesEl = viewBioActivityPage.speciesSelector("Fungi");
        await addBioActivityPage.takeScreenShot("offlineRecordMapPinViewPublishedRecord");
        await speciesEl.scrollIntoView();
        await expect(speciesEl).toBeDisplayed();
        // map pin should be displayed
        var pin =$('.leaflet-marker-icon');
        await pin.scrollIntoView();
        await expect(pin).toBeDisplayed();
        await browser.switchFrame(null);
        await pwaAppPage.closeModal();
    });

    it("login with expired token", async function () {

        console.log("login with expired token - start");
        console.log("Current URL " + await browser.getUrl());
        console.log("Current title " + await browser.getTitle());
        await pwaAppPage.takeScreenShot("loginWithExpiredTokenBeforeLogout");
        await pwaAppPage.logout();
        console.log("login with expired token - logout");
        await pwaAppPage.atSignIn();
        await pwaAppPage.takeScreenShot("loginWithExpiredTokenSignInPage");
        console.log("login with expired token - at sign in page");
        await pwaAppPage.loginAsPwaUser(true);
        console.log("login with expired token - login as pwa user with expired token");
        await pwaAppPage.open();
        console.log("login with expired token - open");
        expect(await pwaAppPage.atSignIn()).toEqual(false);
        await pwaAppPage.start();
        await pwaAppPage.project(project).waitForExist({ timeout: 30000 });
        await expect(pwaAppPage.project(project)).toExist();
        await pwaAppPage.takeScreenShot("loginWithExpiredTokenProjectListAfterExpiredLogin");
        console.log("login with expired token - expect to be at pwa app page");
        await pwaAppPage.loginAsPwaUser(false);
        console.log("login with expired token - login as pwa user not expired");
        await pwaAppPage.open();
        console.log("login with expired token - open again");
        await pwaAppPage.project(project).waitForExist({ timeout: 30000 });
        await expect(pwaAppPage.project(project)).toExist();
        await pwaAppPage.takeScreenShot("loginWithExpiredTokenProjectListAfterValidLogin");
        console.log("login with expired token - at pwa app page");
    });
});