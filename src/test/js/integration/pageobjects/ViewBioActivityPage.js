const StubbedCasSpec = require('./StubbedCasSpec.js')
class ViewBioActivityPage extends StubbedCasSpec {
    async at() {
        var title = await browser.getTitle();
        return /View \\| .* \\| BioCollect/i.test(title);
    }
}

module.exports = new ViewBioActivityPage();
