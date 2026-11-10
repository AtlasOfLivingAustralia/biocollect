const AdminToolsPage = require('../../pageobjects/AdminToolsPage');
const PwaAppPage = require('../../pageobjects/PwaAppPage');
const AddBioActivityPage = require("../../pageobjects/AddBioActivityPage");
const ViewBioActivityPage = require("../../pageobjects/ViewBioActivityPage");
const HomePage = require("../../pageobjects/HomePage");
const {startServer, stopServer} = require('../../utils/proxy');
const {browser} = require("@wdio/globals");

/**
 * Waits for an element to be scrolled into view and displayed, re-resolving a
 * fresh element handle on every poll.
 *
 * On CI (Linux + WebDriver BiDi) a stale element handle passed to `isDisplayed`
 * surfaces as a fatal "invalid argument - Invalid input in arguments/0" error
 * rather than a clean stale-element error, and `expect(el).toBeDisplayed()`
 * rethrows it instead of retrying. Re-querying the element each poll (and
 * swallowing transient stale/invalid-argument errors) avoids that flakiness.
 */
async function waitForDisplayedStable(getElement, description, timeout = 30000) {
    await browser.waitUntil(async () => {
        try {
            const element = await getElement();
            if (!await element.isExisting()) {
                return false;
            }

            await element.scrollIntoView({ block: 'center' });
            return await element.isDisplayed();
        }
        catch {
            return false;
        }
    }, { timeout, interval: 500, timeoutMsg: `${description} still not displayed after ${timeout}ms` });
}

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
        await pwaAppPage.closeDrawerIfOpen();
        await pwaAppPage.logout();
    });

    afterAll(async function () {
        await stopServer();
    });

    it("submit record offline and publish it when network returns", async function () {
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
        await addBioActivityPage.saveActivityChanges();
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
        await addBioActivityPage.saveActivityChanges();
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
        await addBioActivityPage.takeScreenShot("offlineRecordExistingSiteViewUnpublishedRecord");
        await waitForDisplayedStable(() => unpublishedViewBioActivityPage.speciesSelector("Acavomonidia"), 'unpublished species Acavomonidia');
        await browser.switchFrame(null);
        await pwaAppPage.closeModal();

        console.log('Uploading the record');
        await pwaAppPage.uploadNthUnpublishedRecord();
        // The PWA upload bridge uses a 30-second attempt timeout and may retry.
        // Polling with a refresh also observes uploads that complete after the
        // parent page's original request has timed out on a slower CI runner.
        await pwaAppPage.waitForUnpublishedCount(0, 120000, true);
        expect(await pwaAppPage.unpublishedCount()).toBe(0);

        console.log('Checking that the published record exists');
        await pwaAppPage.switchToPublishedTab();
        await pwaAppPage.refreshPublishedRecords();
        await pwaAppPage.waitForPublishedRecord();
        await addBioActivityPage.takeScreenShot("offlineRecordExistingSitePublishedDrawer");

        console.log('Viewing published record');
        await pwaAppPage.viewPublishedRecordContainingSpecies("Acavomonidia");

        const publishedViewBioActivityPage = new ViewBioActivityPage();
        await addBioActivityPage.takeScreenShot("offlineRecordExistingSiteViewPublishedRecord");
        await waitForDisplayedStable(() => publishedViewBioActivityPage.speciesSelector("Acavomonidia"), 'published species Acavomonidia');
        await browser.switchFrame(null);
        await pwaAppPage.closeModal();
        await pwaAppPage.closeDrawer();
    }, 360000);

    it("submit record offline and choose a site on map and publish it when network returns", async function () {
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
        await addBioActivityPage.saveActivityChanges();
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
        await pwaAppPage.waitForUnpublishedCount(0, 120000, true);
        expect(await pwaAppPage.unpublishedCount()).toBe(0);

        console.log('Checking that the published record exists');
        await pwaAppPage.switchToPublishedTab();
        await pwaAppPage.refreshPublishedRecords();
        await pwaAppPage.waitForPublishedRecord();
        await addBioActivityPage.takeScreenShot("offlineRecordMapPinPublishedDrawer");

        console.log('Viewing published record');
        await pwaAppPage.viewPublishedRecordContainingSpecies("Fungi");
        const viewBioActivityPage = new ViewBioActivityPage();
        await addBioActivityPage.takeScreenShot("offlineRecordMapPinViewPublishedRecord");
        await waitForDisplayedStable(() => viewBioActivityPage.speciesSelector("Fungi"), 'published species Fungi');
        // map pin should be displayed
        await waitForDisplayedStable(() => $('.leaflet-marker-icon'), 'map pin');
        await browser.switchFrame(null);
        await pwaAppPage.closeModal();
        await pwaAppPage.closeDrawer();
    }, 360000);

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