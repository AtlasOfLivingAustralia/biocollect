const addBioActivityPage = require('../../pageobjects/AddBioActivityPage.js');
const viewBioActivityPage = require('../../pageobjects/ViewBioActivityPage.js');
const projectId = "project_1"
const projectActivityId = 'pa_1'
const site = "site_1"

describe('Add BioActivity Spec', function () {
    beforeAll(async function() {
        await addBioActivityPage.loadDataSet('dataset1');
        await addBioActivityPage.setupTokenForSystem();
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
        await viewBioActivityPage.at();
    });

});