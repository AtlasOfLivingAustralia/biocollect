package au.org.ala.biocollect.merit

import pages.EditProject
import pages.CreateOrganisation
import spock.lang.Stepwise

/**
 * Specification for the edit project use case.
 */
@Stepwise
class EditProjectSpec extends FieldcaptureFunctionalTest {

    def setup() {
        useDataSet("data-set-1")
    }

    def "When editing a project, the project data should be pre-populated"() {

        setup:
        logout(browser)
        login(browser, "fc-ta@outlook.com", "testing!")
        def projectId = '9c99e298-1af3-4d46-aef2-470f9ec0277a' // From data-set-1

        when: "navigate to the edit project page"
        to EditProject, id:projectId

        then: "the project data is pre-populated on the form"
        projectTypeSelectedText == 'Citizen Science Project'
        recordUsingALASelectedText == 'No'
        organisation.organisationName == 'Test organisation 3'
        organisation.notOnList.displayed == false
        organisation.registerButton.displayed == false
        name == "External project 1"
        description == "External project 1 description"
        plannedStartDate == '01-01-2015'

    }

    def "The user can register an organisation while editing a project"() {
        logout(browser)
        login(browser, "fc-ta@outlook.com", "testing!")
        def projectId = '9c99e298-1af3-4d46-aef2-470f9ec0277a' // From data-set-1

        given: "navigate to the edit project page"
        to EditProject, id:projectId

        expect: "the project's organisation is selected"
        organisation.organisationName == 'Test organisation 3'
        organisation.notOnList.displayed == false

        when: "the user clears the organisation selection"
        organisation.clearButton.click()

        then: "the user can now search for an organisation"
        organisation.results.size() > 0

        when: "the user indicates their organisation is not on the list"
        organisation.organisationName = 'not in list'
        organisation.notOnList = 'organisationNotOnList' // check the checkbox

        then: "the user is given the option to register a new organisation"
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

        then: "the user should be returned to the edit project page without loss of data and with the new organisation pre-selected"
        waitFor {at EditProject}
        organisation.organisationName == 'Test organisation 4'


    }
}
