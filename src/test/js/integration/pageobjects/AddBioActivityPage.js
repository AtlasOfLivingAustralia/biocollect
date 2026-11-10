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
        await this.addSiteInput.waitForExist({ timeout: 30000 });
        console.log('Form diagnostics', await browser.execute(() => ({
            supportsSites: window.metaModel?.supportsSites,
            sites: window.pActivity?.sites,
            siteSelect: document.querySelector('#siteLocation')?.outerHTML,
            loading: document.querySelector('.fa-spinner')?.offsetParent !== null,
            siteMap: document.querySelector('#activitySiteMap')?.outerHTML
        })));

        let siteName;
        await browser.waitUntil(async () => {
            siteName = await browser.execute((siteId) => {
                const select = document.getElementById('siteLocation');
                const model = select && ko.dataFor(select);
                return model?.data?.locationSitesArray?.().find(item => item.siteId === siteId)?.name;
            }, site);
            return !!siteName;
        }, { timeout: 30000, timeoutMsg: `Site ${site} did not load` });

        const selection = $('#siteLocation + .select2 .select2-selection');
        await selection.scrollIntoView();
        await selection.waitForClickable({ timeout: 30000 });
        await selection.click();
        await $('.select2-container--open .select2-search__field').setValue(siteName);

        let option;
        await browser.waitUntil(async () => {
            option = await browser.execute((siteId) => {
                return Array.from(document.querySelectorAll('.select2-results__option'))
                    .find(element => jQuery.data(element, 'data')?.id === siteId) || null;
            }, site);
            return !!option;
        }, { timeout: 30000, timeoutMsg: `Site ${site} was not available in the picker` });
        await $(option).click();
        await browser.waitUntil(async () => await this.addSiteInput.getValue() === site, {
            timeout: 30000,
            timeoutMsg: `Site ${site} was not selected`
        });
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
                return (await $('.ui-autocomplete').isExisting()) === true;
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
                return (await $('.image-title-input').isExisting()) === true;
            }, { timeout: 10000 });
        }
    }

    async saveActivity() {
        await this.saveButton.isExisting();

        await this.saveButton.scrollIntoView();
        await this.saveButton.waitForClickable({timeout: 60000});
        await this.saveButton.click();
        await browser.pause(5000);
    }

    async saveActivityChanges() {
        await this.saveDraftButton.isExisting();

        await this.saveDraftButton.scrollIntoView();
        await this.saveDraftButton.waitForClickable({timeout: 60000});
        await this.saveDraftButton.click();
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