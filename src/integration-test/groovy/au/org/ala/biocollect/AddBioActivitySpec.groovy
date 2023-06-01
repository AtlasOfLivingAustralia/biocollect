package au.org.ala.biocollect


import pages.AddBioActivityPage
import pages.ViewBioActivityPage
import spock.lang.Ignore
import spock.lang.Stepwise

@Stepwise
@Ignore
class AddBioActivitySpec extends StubbedCasSpec {

    def setupSpec() {
        useDataSet('dataset1')
    }

    def cleanupSpec() {
        logout(browser, ViewBioActivityPage)
    }

    def projectId = "project_1"
    def projectActivityId = 'pa_1'
    def site = "site_1"

    def "Add an activity"() {

        loginAsUser('1', browser)

        when: "go to new activity page"

        to AddBioActivityPage, projectActivityId
        waitFor {at AddBioActivityPage}
        addSite = site
        setDate(surveyDate,'01/01/2020')
        addSpecies = "acacia"
        waitFor {
            speciesAutocomplete.displayed
        }

        firstSpecies.click()

        uploadImage("/images/10_years.png")
        waitFor { imageTitleInput.displayed }
        save.click()

        then:
        waitFor 20, {at ViewBioActivityPage}

    }

}

