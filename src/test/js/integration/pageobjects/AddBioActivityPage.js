// const StubbedCasSpec = require('./StubbedCasSpec.js')
const ReloadablePage = require('./ReloadablePage.js')
class AddBioActivityPage extends ReloadablePage {
    get addSiteInput() { return $("#siteLocation"); }
    get surveyDateInput() { return $('.inputDatePicker'); }
    get addSpeciesInput() { return $('.speciesInputTemplates'); }
    get speciesAutocomplete() { return $('.ui-autocomplete'); }
    get firstSpecies() { return $('.ui-autocomplete li a:nth-child(1)'); }
    get imageUploadInput() { return $("input[name=files][accept='image/*']"); }
    get imageTitleInput() { return $(".image-title-input"); }
    get saveButton() { return $("#save"); }
    get okButtonBootBoxDialog(){ return $(".btn.btn-primary.bootbox-accept")}
    get iframe() { return $("iframe"); }

    async open(projectActivityId) {
        console.log(`Opening ${this.baseUrl}/bioActivity/create/${projectActivityId}`);
        await browser.url(`${this.baseUrl}/bioActivity/create/${projectActivityId}`);
    }

    async at() {
        let title = await browser.getTitle();
        return /Create \| .* \| BioCollect/i.test(title);
    }

    async setSite(site) {
        await this.addSiteInput.selectByAttribute("value", site);
    }

    async setDate(date) {
        await this.surveyDateInput.setValue(date);
    }

    async setSpecies(species, iframe = false) {
        await this.addSpeciesInput.setValue(species);
        if (iframe) {
            // iframe has difficulty checking if element is available
            await browser.pause(5000);
        }
        else {
            await browser.waitUntil(async () => {
                return (await this.speciesAutocomplete.isDisplayed()) === true;
            }, { timeout: 10000 });
        }
        await this.firstSpecies.click();
    }

    async uploadImage(imagePath, iframe = false) {
        await this.imageUploadInput.addValue(imagePath);

        if (iframe) {
            // iframe has difficulty checking if element is available
            await browser.pause(5000);
        }
        else {
            await browser.waitUntil(async () => {
                return (await this.imageTitleInput.isDisplayed()) === true;
            }, { timeout: 10000 });
        }
    }

    async saveActivity() {
        await this.saveButton.click();
    }

    async dismissBootBoxDialog(){
        await this.okButtonBootBoxDialog.click();
    }
}

module.exports = AddBioActivityPage;