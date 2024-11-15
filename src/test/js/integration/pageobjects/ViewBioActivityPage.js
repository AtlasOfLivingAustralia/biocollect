const StubbedCasSpec = require('./StubbedCasSpec.js')
class ViewBioActivityPage extends StubbedCasSpec {
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
