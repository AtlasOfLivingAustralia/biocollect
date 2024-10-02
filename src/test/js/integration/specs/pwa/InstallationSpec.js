const adminToolsPage = require('../../pageobjects/AdminToolsPage');
const pwaAppPage = require('../../pageobjects/PwaAppPage');
const addBioActivityPage = require("../../pageobjects/AddBioActivityPage");
describe("Application installation Spec", function () {
    beforeAll(async function() {
        await adminToolsPage.loadDataSet('dataset1');
        await addBioActivityPage.setupTokenForSystem();
        await adminToolsPage.loginAsAlaAdmin();
        await adminToolsPage.reindex();
        await pwaAppPage.open();
        let token = await pwaAppPage.loginAsPwaUser();
        await pwaAppPage.open();
        await pwaAppPage.start();
    });

    beforeEach(async function() {
    });

   it("Install app", async function() {
        var result = await pwaAppPage.serviceWorkerReady();
        expect(result).toBe(true);
        await browser.pause(180000);
   });

   it("login with token", function() {

   });

    it("login with expired token", function() {

    });
});