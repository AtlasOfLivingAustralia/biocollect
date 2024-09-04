const AddBioActivityPage = require('../../pageobjects/AddBioActivityPage.js');
const ViewBioActivityPage = require('../../pageobjects/ViewBioActivityPage.js');
const projectId = "project_1"
const projectActivityId = 'pa_1'
const site = "site_1"

describe('Add BioActivity Spec', function () {
    beforeAll(async function() {
        await AddBioActivityPage.loadDataSet('dataset1');
        await AddBioActivityPage.setupTokenForSystem();
    });

    it('should add an activity', async () => {
        await AddBioActivityPage.loginAsUser('1');
        let promises = [];
        // Navigate to the Add Bio Activity page
        await AddBioActivityPage.open(projectActivityId);
        // Set the site, date, and species
        promises.push(AddBioActivityPage.setSite(site));
        promises.push(AddBioActivityPage.setDate('01/01/2020'));

        // Upload an image
        promises.push(AddBioActivityPage.uploadImage(`${AddBioActivityPage.testConfig.resourceDir}/images/10_years.png`));

        // Wait for all promises to resolve
        await Promise.all(promises);
        await AddBioActivityPage.setSpecies('acacia')

        // Save the activity
        await AddBioActivityPage.saveActivity();

        // Verify that the ViewBioActivityPage is loaded
        await ViewBioActivityPage.at();
    });

});