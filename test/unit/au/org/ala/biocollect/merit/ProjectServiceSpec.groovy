package au.org.ala.biocollect.merit

import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * Specification for the ProjectService
 */
@TestFor(ProjectService)
class ProjectServiceSpec extends Specification {
    def metadataServiceStub = Mock(MetadataService)
    def webServiceStub = Mock(WebService)

    void setup() {
        service.metadataService = metadataServiceStub
        service.webService = webServiceStub
    }

    void "activity types should be contained by the project program"() {
        given:
        def project = [projectId: 'test', associatedProgram: 'test program']

        when:
        List activityTypes = service.supportedActivityTypes(project)

        then:
        1 * metadataServiceStub.activityTypesList('test program') >> [[category: 'testing', list: [[name: '1'], [name: '2']]], [category: 'cat 2', list: [[name: '3']]]]
        activityTypes == [[name: '1'], [name: '2'], [name: '3']]
    }

    void "activity types already in use by a project should always be returned"() {
        given:
        def project = [projectId: 'test', associatedProgram: 'test program']
        def projectActivities = [[pActivityForm: '4']]

        when:
        List activityTypes = service.supportedActivityTypes(project, projectActivities)

        then:
        1 * metadataServiceStub.activityTypesList('test program') >> [[category: 'testing', list: [[name: '1'], [name: '2']]], [category: 'cat 2', list: [[name: '3']]]]
        activityTypes == [[name: '1'], [name: '2'], [name: '3'], [name: '4']]
    }

    void "duplicate types already should not be returned"() {
        given:
        def project = [projectId: 'test', associatedProgram: 'test program']
        def projectActivities = [[pActivityForm: '3']]

        when:
        List activityTypes = service.supportedActivityTypes(project, projectActivities)

        then:
        1 * metadataServiceStub.activityTypesList('test program') >> [[category: 'testing', list: [[name: '1'], [name: '2']]], [category: 'cat 2', list: [[name: '3']]]]
        activityTypes == [[name: '1'], [name: '2'], [name: '3']]
    }

    void "use all species as default species configuration"() {
        given:
        Map project = ["speciesFieldsSettings": [:]]

        when:
        service.webService.getJson(_) >> project
        Map multipleSightings = service.findSpeciesFieldConfig('1', "Multiple Sightings", "species1", "Multiple species sightings");

        then:
        assert multipleSightings.type== "ALL_SPECIES"
    }

    /**
     * Test to ensure if species configuration is not set for a field, then default configuration is used.
     */
    void "ensure compatibility of old species configuration"() {
        given:
        Map project = ["speciesFieldsSettings": [
                "defaultSpeciesConfig": [
                        "type"                : "ALL_SPECIES",
                        "speciesDisplayFormat": "SCIENTIFICNAME(COMMONNAME)"
                ],
                "surveysConfig"       : [
                        [
                                "name"         : "Multiple Sightings",
                                "speciesFields": [
                                        [
                                                "context"      : "",
                                                "config"       : [
                                                    "singleSpecies" : [
                                                        "guid" : "urn:lsid:biodiversity.org.au:afd.taxon:e6aff6af-ff36-4ad5-95f2-2dfdcca8caff",
                                                        "commonName" : "Red Kangaroo",
                                                        "scientificName" : "Osphranter rufus",
                                                        "name" : "Osphranter rufus"
                                                    ],
                                                    "type" : "SINGLE_SPECIES",
                                                    "speciesDisplayFormat" : "SCIENTIFICNAME(COMMONNAME)"
                                                ],
                                                "label"        : "Species name",
                                                "output"       : "Multiple species sightings",
                                                "dataFieldName": "species1"
                                        ],
                                        [
                                                "context"      : "multiSightingTable",
                                                "config"       : [
                                                        "type"                : "DEFAULT_SPECIES",
                                                        "speciesDisplayFormat": "SCIENTIFICNAME(COMMONNAME)"
                                                ],
                                                "label"        : "Species name",
                                                "output"       : "Multiple species sightings",
                                                "dataFieldName": "species2"
                                        ]
                                ]
                        ], [
                                "name"         : "Floristic survey - plot and transect",
                                "speciesFields": [
                                        [
                                                "context"      : "surveyResultsFlora",
                                                "config"       : [:],
                                                "label"        : "Species:",
                                                "output"       : "Floristic Survey - Plot and Transect",
                                                "dataFieldName": "species"
                                        ]
                                ]
                        ]
                ]
        ]]

        when:
        service.webService.getJson(_) >> project
        Map multipleSightings = service.findSpeciesFieldConfig('1', "Multiple Sightings", "species1", "Multiple species sightings");
        Map multipleSightingsDefaultConfig = service.findSpeciesFieldConfig('1', "Multiple Sightings", "species2", "Multiple species sightings");
        Map noSpeciesConfig = service.findSpeciesFieldConfig('1', "Floristic survey - plot and transect", "species", "Floristic Survey - Plot and Transect");

        then:
        assert multipleSightings.type == "SINGLE_SPECIES"
        assert multipleSightingsDefaultConfig.type== "ALL_SPECIES"
        assert noSpeciesConfig.type== "ALL_SPECIES"
    }

}