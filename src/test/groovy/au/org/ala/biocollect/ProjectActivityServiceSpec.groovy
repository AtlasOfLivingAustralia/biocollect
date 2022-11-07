package au.org.ala.biocollect

import grails.testing.spring.AutowiredTest
import spock.lang.Specification
import au.org.ala.biocollect.merit.ProjectService
import au.org.ala.biocollect.merit.WebService
import au.org.ala.biocollect.merit.MetadataService

import java.text.SimpleDateFormat

class ProjectActivityServiceSpec extends Specification implements AutowiredTest{
    Closure doWithSpring() {{ ->
        service ProjectActivityService
    }}

    ProjectActivityService service
    def projectActivity

    def setup() {
        service.grailsApplication = grailsApplication
        grailsApplication.config.ecodata.service.url = "http://test"
        service.projectService = Stub(ProjectService)
        service.projectService.get(_) >> [:]
        service.webService = Stub(WebService)
        service.webService.getJson(_) >> [:]
        service.metadataService = Stub(MetadataService)
        service.metadataService.activitiesModel() >> ["activities": [["name": "pActivityFormName"]]]

        projectActivity = [
                "projectId"                          : "abc",
                "status"                             : "active",
                "description"                        : "abc",
                "name"                               : "name",
                "attribution"                        : "attribution",
                "startDate"                          : "startDate",
                "pActivityFormName"                  : "pActivityFormName",
                "addCreatedSiteToListOfSelectedSites": false,
                "surveySiteOption"                   : "sitecreate",
                "allowPolygons"                      : false,
                "allowLine"                          : false,
                "defaultZoomArea"                    : "1315388a-968a-4a49-b2e6-773c6c953521",
                "allowPoints"                        : true,
                "restrictRecordToSites"              : false,
                "sites"                              : ["1315388a-968a-4a49-b2e6-773c6c953521"],
                "mapLayersConfig"                    : [
                        "baseLayers": [
                                [
                                        "displayText": "ESRI Topographic",
                                        "code"       : "topographic",
                                        "isSelected" : true,
                                        "transients" : ["changed": false]
                                ]
                        ],
                        "overlays"  : [
                                [
                                        "showPropertyName"     : true,
                                        "alaName"              : "ibra7_regions",
                                        "defaultSelected"      : true,
                                        "inLayerShapeList"     : true,
                                        "display"              : [
                                                "propertyName": "REG_NAME_7",
                                                "cqlFilter"   : ""
                                        ],
                                        "userAccessRestriction": "anyUser",
                                        "title"                : "Biogeographic regions",
                                        "changeLayerColour"    : true,
                                        "boundaryColour"       : "#000000",
                                        "textColour"           : null,
                                        "fillColour"           : null,
                                        "alaId"                : "cl1048",
                                        "style"                : [:],
                                        "layerName"            : "",
                                        "opacity"              : "1.0",
                                        "transients"           : [
                                                "changed": false
                                        ]
                                ]
                        ]
                ]
        ]
    }

    def cleanup() {
    }

    def "validate should check site configuration and show appropriate errors"() {
        def message
        when: "Do not check site configuration if survey is not published"
        projectActivity.published = false
        message = service.validate(projectActivity, 'abc')

        then:
        message == null

        when: "check validity for site creation setting when survey published"
        projectActivity.surveySiteOption = "sitecreate"
        projectActivity.allowPolygons = false
        projectActivity.allowLine = false
        projectActivity.allowPoints = false
        projectActivity.published = true
        message = service.validate(projectActivity, 'abc')

        then:
        message == "Location configuration is not valid. Either points, polygons or lines must be selected."

        when: "check validity for site creation setting when survey published"
        projectActivity.surveySiteOption = "sitecreate"
        projectActivity.allowPolygons = true
        projectActivity.allowLine = false
        projectActivity.allowPoints = false
        projectActivity.published = true
        message = service.validate(projectActivity, 'abc')

        then:
        message == null

        when: "check validity for site pick setting when survey published"
        projectActivity.surveySiteOption = "sitepick"
        projectActivity.sites = []
        projectActivity.allowPolygons = true
        projectActivity.allowLine = true
        projectActivity.allowPoints = true
        projectActivity.published = true
        message = service.validate(projectActivity, 'abc')

        then:
        message == "Location configuration is not valid. Must select one or more sites."

        when: "check validity for site pick setting when survey published"
        projectActivity.surveySiteOption = "sitepick"
        projectActivity.sites = ['abc']
        projectActivity.published = true
        message = service.validate(projectActivity, 'abc')

        then:
        message == null

        when: "check validity for site pick & create setting when survey published"
        projectActivity.surveySiteOption = "sitepickcreate"
        projectActivity.sites = []
        projectActivity.allowPolygons = false
        projectActivity.allowLine = false
        projectActivity.allowPoints = true
        projectActivity.published = true
        message = service.validate(projectActivity, 'abc')

        then:
        message == "Location configuration is not valid. Must select one or more sites."

        when: "check validity for site pick & create setting when survey published"
        projectActivity.surveySiteOption = "sitepickcreate"
        projectActivity.sites = ['abc']
        projectActivity.allowPolygons = false
        projectActivity.allowLine = false
        projectActivity.allowPoints = false
        projectActivity.published = true
        message = service.validate(projectActivity, 'abc')

        then:
        message == "Location configuration is not valid. Either points, polygons or lines must be selected."

        when: "check validity for site pick & create setting when survey published"
        projectActivity.surveySiteOption = "sitepickcreate"
        projectActivity.sites = ['abc']
        projectActivity.allowPolygons = true
        projectActivity.allowLine = false
        projectActivity.allowPoints = false
        projectActivity.published = true
        message = service.validate(projectActivity, 'abc')

        then:
        message == null
    }

    void "PA embargoed if embargoForDays is ahead of current date" () {
        setup:
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
        def pa =  [visibility: [alaAdminEnforcedEmbargo: true, embargoForDays: 100, embargoOption: "DAYS", embargoUntil: (new Date().plus(100)).format("yyyy-MM-dd'T'HH:mm:ssZ", TimeZone.getTimeZone("UTC"))]]

        when:
        def result = service.isEmbargoed(pa)

        then:
        result == true
    }


    void "PA not embargoed if embargoForDays is behind current date" () {
        setup:
        def pa =  [visibility: [alaAdminEnforcedEmbargo: false, embargoForDays: -10, embargoOption: "DAYS", embargoUntil: (new Date().plus(-10)).format("yyyy-MM-dd'T'HH:mm:ssZ", TimeZone.getTimeZone("UTC"))]]

        when:
        def result = service.isEmbargoed(pa)

        then:
        result == false
    }

    void "PA not embargoed if embargoUntil is behind current date" () {
        setup:
        def pa =  [visibility: [alaAdminEnforcedEmbargo: false, embargoOption: "DATE", embargoUntil: (new Date().plus(-10)).format("yyyy-MM-dd'T'HH:mm:ssZ", TimeZone.getTimeZone("UTC"))]]

        when:
        def result = service.isEmbargoed(pa)

        then:
        result == false
    }

    void "PA embargoed if embargoUntil is ahead of current date" () {
        setup:
        def pa =  [visibility: [alaAdminEnforcedEmbargo: false, embargoOption: "DATE", embargoUntil: (new Date().plus(10)).format("yyyy-MM-dd'T'HH:mm:ssZ", TimeZone.getTimeZone("UTC"))]]

        when:
        def result = service.isEmbargoed(pa)

        then:
        result == true
    }
}
