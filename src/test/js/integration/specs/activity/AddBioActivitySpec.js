const AddBioActivityPage = require('../../pageobjects/AddBioActivityPage.js');
const ViewBioActivityPage = require('../../pageobjects/ViewBioActivityPage.js');
const projectId = "project_1"
const projectActivityId = 'pa_1'
const site = "ab9ec9af-241b-49f7-adcf-ca40e474d119"

describe('Add BioActivity Spec', function () {
    let addBioActivityPage, viewBioActivityPage;
    beforeAll(async function() {
        addBioActivityPage = new AddBioActivityPage();
        viewBioActivityPage = new ViewBioActivityPage();
        await addBioActivityPage.loadDataSet('dataset1');
        await addBioActivityPage.setupTokenForSystem();
    });

    afterAll(async function() {
    });

    afterEach(async function() {
        await addBioActivityPage.logout();
    });

    it('should add an activity', async () => {
        await addBioActivityPage.loginAsUser('1');
        let promises = [];
        // Navigate to the Add Bio Activity page
        await addBioActivityPage.open(projectActivityId);
        // Set the site, date, and species
        promises.push(addBioActivityPage.setSite(site));
        promises.push(addBioActivityPage.setDate('01/01/2020'));

        // Upload an image
        promises.push(addBioActivityPage.uploadImage(`${addBioActivityPage.testConfig.resourceDir}/images/10_years.png`));

        // Wait for all promises to resolve
        await Promise.all(promises);
        await addBioActivityPage.setSpecies('acacia')

        // Save the activity
        await addBioActivityPage.saveActivity();

        // Verify that the ViewBioActivityPage is loaded
        expect(await viewBioActivityPage.at()).toBeTrue();
    });

    it("should not be able to submit an activity when no network", async () => {
        await addBioActivityPage.loginAsUser('1');
        let promises = [];
        // Navigate to the Add Bio Activity page
        await addBioActivityPage.open(projectActivityId);
        // Set the site, date, and species
        promises.push(addBioActivityPage.setSite(site));
        promises.push(addBioActivityPage.setDate('01/01/2020'));

        // Upload an image
        promises.push(addBioActivityPage.uploadImage(`${addBioActivityPage.testConfig.resourceDir}/images/10_years.png`));

        // Wait for all promises to resolve
        await Promise.all(promises);
        await addBioActivityPage.setSpecies('acacia')
        await addBioActivityPage.setOffline();
        // Save the activity
        await addBioActivityPage.saveActivity();
        // await browser.dismissAlert();
        await addBioActivityPage.dismissBootBoxDialog();
        // Verify that the ViewBioActivityPage is loaded
        expect(await addBioActivityPage.at()).toBeTrue();

        // go online
        await addBioActivityPage.setOnline()
        await addBioActivityPage.saveActivity();
        expect(await viewBioActivityPage.at()).toBeTrue();
    })

});