package pages

import geb.Page

/**
 * The ALA login page
 */
class LoginPage extends Page {

    static url = "https://auth.ala.org.au/cas/login"

    static at = { title == "Login | Atlas of Living Australia"}

    static content = {
        username { $('#username') }
        password { $('#password') }


        submitButton() {
            $("input", class:"btn-submit")
        }
    }

    // Pressing submit actually does an ajax call then changes the page using JavaScript.
    def submit() {
        submitButton.click()

    }
}
