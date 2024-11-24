// const StubbedCasSpec = require('./StubbedCasSpec.js')
const ReloadablePage = require('./ReloadablePage.js')
class ViewBioActivityPage extends ReloadablePage {
    get backBtn() {
        return $('#backButton');
    }
    async at() {
        var title = await browser.getTitle();
        return /View \\| .* \\| BioCollect/i.test(title);
    }

    speciesSelector(name) {
        return $(`span=${name}`);
    }
}

module.exports = ViewBioActivityPage;
