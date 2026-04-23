// const StubbedCasSpec = require('./StubbedCasSpec.js')
const path = require('node:path')
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
    get saveDraftButton() { return $("#saveChanges"); }
    get okButtonBootBoxDialog(){ return $(".bootbox-accept")}
    get iframe() { return $("#pwa-frame"); }

    async open(projectActivityId) {
        console.log(`Opening ${this.baseUrl}/bioActivity/create/${projectActivityId}`);
        await browser.url(`${this.baseUrl}/bioActivity/create/${projectActivityId}`);
    }

    async at() {
        let title = await browser.getTitle();
        return /Create \| .* \| BioCollect/i.test(title);
    }

    async setSite(site) {
        // Select2 hides the original select element and creates its own UI
        // We need to click on the Select2 container, not the hidden select element
        const select2Container = $('.select2-selection');
        await select2Container.waitForDisplayed({ timeout: 5000 });
        await select2Container.scrollIntoView();
        await browser.pause(500);
        await select2Container.click();
        await $('.select2-results__options').waitForDisplayed({ timeout: 5000 });
        await $('.select2-results__option').click();
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
        const uploadInput = this.imageUploadInput;
        const localImagePath = path.resolve(imagePath);
        const remoteImagePath = await browser.uploadFile(localImagePath);

        await uploadInput.waitForExist({ timeout: 10000 });

        await uploadInput.setValue(remoteImagePath);

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

    async resolveSaveButton() {
        if (await this.saveButton.isExisting()) {
            return this.saveButton;
        }

        if (await this.saveDraftButton.isExisting()) {
            return this.saveDraftButton;
        }

        throw new Error('Could not find a save button on the bio activity form');
    }

    async saveActivity() {
        const saveButton = await this.resolveSaveButton();

        await saveButton.scrollIntoView();
        await saveButton.waitForClickable({timeout: 60000});
        await saveButton.click();
        await browser.pause(5000);
    }

    async dismissBootBoxDialog(){
        await this.okButtonBootBoxDialog.waitForClickable({ timeout: 60000 });
        await this.okButtonBootBoxDialog.click();
        // wait for the dialog to be dismissed
        await this.okButtonBootBoxDialog.waitForClickable({ timeout: 20000, reverse: true });
    }
}

module.exports = AddBioActivityPage;