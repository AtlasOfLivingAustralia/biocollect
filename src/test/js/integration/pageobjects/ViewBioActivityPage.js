const StubbedCasSpec = require('./StubbedCasSpec.js')
class ViewBioActivityPage extends StubbedCasSpec {
    async at() {
        return await super.at('View \\| .* \\| BioCollect');
    }
}

module.exports = new ViewBioActivityPage();
