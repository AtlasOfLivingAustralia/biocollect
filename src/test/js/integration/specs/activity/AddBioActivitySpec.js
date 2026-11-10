const AddBioActivityPage = require('../../pageobjects/AddBioActivityPage.js');
const ViewBioActivityPage = require('../../pageobjects/ViewBioActivityPage.js');
const projectActivityId = 'pa_1'
const site = "ab9ec9af-241b-49f7-adcf-ca40e474d119"

async function waitForViewBioActivityPage(viewBioActivityPage) {
    await browser.waitUntil(async () => {
        return await viewBioActivityPage.at()
    }, {
        timeout: 120000,
        interval: 1000,
        timeoutMsg: 'Expected the View BioActivity page to load after saving the activity'
    })
}

describe('Add BioActivity Spec', () => {
    let addBioActivityPage, viewBioActivityPage;
    beforeAll(async () => {
        addBioActivityPage = new AddBioActivityPage();
        viewBioActivityPage = new ViewBioActivityPage();
        await addBioActivityPage.loadDataSet('dataset1');
        await addBioActivityPage.setupTokenForSystem();
    });

    afterAll(async () => {
    });

    afterEach(async () => {
        await addBioActivityPage.takeScreenShot("afterEachAddBioActivitySpec");
        await addBioActivityPage.logout();
    });

    it('should add an activity', async () => {
        await addBioActivityPage.loginAsUser('1');
        // Navigate to the Add Bio Activity page
        await addBioActivityPage.open(projectActivityId);
        await addBioActivityPage.takeScreenShot("shouldAddAnActivitySurvey");
        // Set the site, date, and species
        await addBioActivityPage.setSite(site);
        await addBioActivityPage.setDate('01/01/2020');

        // Upload an image
        await addBioActivityPage.uploadImage(`${addBioActivityPage.testConfig.resourceDir}/images/10_years.png`);

        await addBioActivityPage.setSpecies('acacia')
        await addBioActivityPage.takeScreenShot("shouldAddAnActivityBeforeSave");
        // Save the activity
        await addBioActivityPage.saveActivity();
        // Verify that the ViewBioActivityPage is loaded
        await waitForViewBioActivityPage(viewBioActivityPage);
        await addBioActivityPage.takeScreenShot("shouldAddAnActivityAtViewBioActivityPage");
    });

    it("should not be able to submit an activity when no network", async () => {
        await addBioActivityPage.loginAsUser('1');
        // Navigate to the Add Bio Activity page
        await addBioActivityPage.open(projectActivityId);
        await addBioActivityPage.takeScreenShot("shouldNotBeAbleToSubmitAnActivityWhenNoNetworkSurvey");
        // Set the site, date, and species
        await addBioActivityPage.setSite(site);
        await addBioActivityPage.setDate('01/01/2020');

        // Upload an image
        await addBioActivityPage.uploadImage(`${addBioActivityPage.testConfig.resourceDir}/images/10_years.png`);

        await addBioActivityPage.setSpecies('acacia')
        await addBioActivityPage.setOffline();
        // Save the activity
        await addBioActivityPage.saveActivity();
        await addBioActivityPage.takeScreenShot("shouldNotBeAbleToSubmitAnActivityWhenNoNetworkBeforeSave");
        // await browser.dismissAlert();
        await addBioActivityPage.dismissBootBoxDialog();
        await addBioActivityPage.takeScreenShot("shouldNotBeAbleToSubmitAnActivityWhenNoNetworkAfterDismiss");
        // Verify that the ViewBioActivityPage is loaded
        expect(await addBioActivityPage.at()).toBeTrue();

        // go online
        await addBioActivityPage.setOnline()
        await addBioActivityPage.saveActivity();
        await waitForViewBioActivityPage(viewBioActivityPage);
        await addBioActivityPage.takeScreenShot("shouldNotBeAbleToSubmitAnActivityWhenNoNetworkAfterSuccessfullSave");
    })

});