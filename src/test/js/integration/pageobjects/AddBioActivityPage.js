const StubbedCasSpec = require('./StubbedCasSpec.js')
class AddBioActivityPage extends StubbedCasSpec {
    get addSiteInput() { return $("#siteLocation"); }
    get surveyDateInput() { return $('.inputDatePicker'); }
    get addSpeciesInput() { return $('.speciesInputTemplates'); }
    get speciesAutocomplete() { return $('.ui-autocomplete'); }
    get firstSpecies() { return $('.ui-autocomplete li a:nth-child(1)'); }
    get imageUploadInput() { return $("input[name=files][accept='image/*']"); }
    get imageTitleInput() { return $(".image-title-input"); }
    get saveButton() { return $("#save"); }

    async open(projectActivityId) {
        await browser.url(`${this.baseUrl}/bioActivity/create/${projectActivityId}`);
    }

    async at() {
        return super.at('Create \| .* \| BioCollect');
    }

    async setSite(site) {
        await this.addSiteInput.selectByAttribute("value", site);
    }

    async setDate(date) {
        await this.surveyDateInput.setValue(date);
    }

    async setSpecies(species) {
        await this.addSpeciesInput.setValue(species);
        await browser.waitUntil(async () => {
            return (await this.speciesAutocomplete.isDisplayed()) === true;
        }, { timeout: 10000 });
        await this.firstSpecies.click();
    }

    async uploadImage(imagePath) {
        await this.imageUploadInput.addValue(imagePath);
        await browser.waitUntil(async () => {
            return (await this.imageTitleInput.isDisplayed()) === true;
        }, { timeout: 10000 });
    }

    async saveActivity() {
        await this.saveButton.click();
    }
}

module.exports = new AddBioActivityPage();