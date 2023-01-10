package pages

import geb.Module
import geb.Page
import geb.navigator.Navigator
import org.openqa.selenium.Keys

class BioActivityPage extends Page {

    def setDate(Navigator dateField, String date) {
        dateField.value(date)
        dateField << Keys.chord(Keys.ENTER) // Dismisses the popup calendar
    }

}

class AddBioActivityPage extends BioActivityPage {
    static url = 'bioActivity/create'
    static at = { title ==~ /Create \| .* \| BioCollect/ }
    static content = {
        image { $("input[name=files][accept='image/*']") }
        imageTitleInput { $(".image-title-input") }
        addSite { $("#siteLocation") }
        addSpecies {$('.speciesInputTemplates')}
        speciesAutocomplete(required: false) {$('.ui-autocomplete')}
        firstSpecies(required: false) { $('.ui-autocomplete li a', 0)}
        surveyDate {$('.inputDatePicker')}
        save { $("#save") }
        cancel { $("#cancel") }
    }

    /** Attaches a file from the classpath and presses the Upload Shapefile button */
    void uploadImage(String filename) {
        URL file = getClass().getResource(filename)
        File toAttach = new File(file.toURI())
        image = toAttach
    }
}

class ViewBioActivityPage extends BioActivityPage {
    static url = 'bioActivity/index'
    static at = { title ==~ /View \| .* \| BioCollect/ }
}

class BioActivityDetails extends Module {
    static content = {

    }
}