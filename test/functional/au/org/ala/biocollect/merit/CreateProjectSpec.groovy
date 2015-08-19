package au.org.ala.biocollect.merit

import pages.CreateOrganisation
import pages.CreateProject
import pages.ProjectIndex
import pages.EntryPage

import spock.lang.Stepwise

@Stepwise
class CreateProjectSpec extends FieldcaptureFunctionalTest {

    def setup() {
        useDataSet("data-set-1")
    }

    def "The user must be logged in to create a project"() {

        logout(browser)

        when: "attempt to create a project"
        via CreateProject

        then: "redirected to the home page with an error"
        at EntryPage
    }

    def "If the user is not a member of an organisation then they must select one via a search"() {
        logout(browser)
        login(browser, "fc-te@outlook.com", "testing!")

        given: "navigate to the create project page"
        to CreateProject, citizenScience:true

        expect:
        at CreateProject
        organisation.organisationName == ''

        when: "search for an organisation"
        organisation.organisationName = "Test"

        then: "The available organisations have been narrowed"


        when: "an organisation is selected"
        organisation.selectOrganisation("Test organisation 1")

        then: "The search field is disabled and updated to match the organisation name"

        organisation.organisationName == "Test organisation 1"
        organisation.organisationName.@disabled == 'true'

    }

    def "If the user is a member of exactly one organisation it should be preselected"() {
        logout(browser)
        login(browser, "fc-ta@outlook.com", "testing!")

        given: "navigate to the create project page"
        to CreateProject, citizenScience:true

        expect: "the user's organisation is selected"
        at CreateProject

        organisation.organisationName == "Test organisation 3"
        organisation.organisationName.@disabled == 'true'
    }

    def "The user can register an organisation during project creation"() {
        logout(browser)
        login(browser, "fc-te@outlook.com", "testing!")

        given: "navigate to the create project page"
        to CreateProject, citizenScience:true

        expect: "the user's organisation is selected"
        at CreateProject

        organisation.notOnList.displayed == true

        when: "the user indicates their organisation is not on the list"
        organisation.notOnList = 'organisationNotOnList' // check the checkbox

        then: "the user is given the option to register a new organsation"
        organisation.registerButton.displayed == true

        when: "the user selects to register a new organisation"
        organisation.registerButton.click()

        then: "the user is sent to the create organisation page"
        at CreateOrganisation

        when: "enter the details of the new organisation"
        name = "Test organisation 4"
        description = "Test organisation 4 description"
        type = "Government"
        create()

        then: "the user should be returned to the create project page without loss of data and with the new organisation pre-selected"
        waitFor {at CreateProject}



    }


    def "The user can register an external citizen science project"() {

        logout(browser)
        login(browser, "fc-ta@outlook.com", "testing!")

        given: "navigate to the create project page"
        to CreateProject, citizenScience:true

        expect:
        at CreateProject
        projectType == 'citizenScience' // The field should be pre-selected and disabled - note the selector returns the value, not the text.

        when: "enter project details"
        recordUsingALA = 'No'
        name = 'External project'
        description = 'External project description'
        setDate(plannedStartDate, '01/01/2015')
        site.extentType = 'point'

        save()

        then: "at the newly created project page"

        waitFor { at ProjectIndex }


    }
}
