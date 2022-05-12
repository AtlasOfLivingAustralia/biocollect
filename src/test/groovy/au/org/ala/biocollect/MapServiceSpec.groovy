package au.org.ala.biocollect

import au.org.ala.biocollect.merit.SettingService
import au.org.ala.biocollect.merit.UserService
import au.org.ala.biocollect.merit.hub.HubSettings
import grails.testing.spring.AutowiredTest
import spock.lang.Specification

class MapServiceSpec extends Specification implements AutowiredTest{
    Closure doWithSpring() {{ ->
        service MapService
    }}

    MapService service
    def projectActivity
    def project
    def userService = Stub(UserService)

    def setup() {
        SettingService.setHubConfig(new HubSettings([
                mapLayersConfig: [
                        baseLayers: [
                                [
                                        'code'       : 'hub',
                                        'displayText': 'Satellite',
                                        'isSelected' : true
                                ]
                        ],
                        overlays  : [[
                                             alaId                : 'cl1',
                                             alaName              : 'hub',
                                             layerName            : 'hub',
                                             title                : 'hub title',
                                             defaultSelected      : false,
                                             boundaryColour       : '#fdb863',
                                             showPropertyName     : false,
                                             fillColour           : '',
                                             textColour           : '',
                                             userAccessRestriction: 'anyUser',
                                             inLayerShapeList     : true,
                                             opacity              : 0.5,

                                             display              : [
                                                     cqlFilter   : "",
                                                     propertyName: 'NAME_1',
                                             ],
                                             style                : [:],
                                             bounds               : [],
                                             restrictions         : [:]
                                     ]]
                ]
        ]))

        projectActivity = [
                mapLayersConfig: [
                        baseLayers: [
                                [
                                        'code'       : 'projectactivity',
                                        'displayText': 'Satellite',
                                        'isSelected' : true
                                ]
                        ],
                        overlays  : [[
                                             alaId                : 'cl2',
                                             alaName              : 'pa',
                                             layerName            : 'pa',
                                             title                : 'pa title',
                                             defaultSelected      : false,
                                             boundaryColour       : '#b2abd2',
                                             showPropertyName     : false,
                                             fillColour           : '',
                                             textColour           : '',
                                             userAccessRestriction: 'anyUser',
                                             inLayerShapeList     : true,
                                             opacity              : 0.5,
                                             changeLayerColour    : false,
                                             display              : [
                                                     cqlFilter   : "",
                                                     propertyName: 'ABB_NAME',
                                             ],
                                             style                : [:],
                                             bounds               : [],
                                             restrictions         : [:]
                                     ]]
                ]
        ]

        project = [
                mapLayersConfig: [
                        baseLayers: [
                                [
                                        'code'       : 'project',
                                        'displayText': 'Satellite',
                                        'isSelected' : true
                                ]
                        ],
                        overlays  : [[
                                             alaId                : 'cl3',
                                             alaName              : 'project',
                                             layerName            : 'project',
                                             title                : 'project title',
                                             defaultSelected      : false,
                                             boundaryColour       : '#005ce6',
                                             showPropertyName     : false,
                                             fillColour           : '#bef7cf',
                                             textColour           : '#FFF',
                                             userAccessRestriction: 'anyUser',
                                             inLayerShapeList     : true,
                                             opacity              : 0.5,
                                             changeLayerColour    : false,
                                             display              : [
                                                     cqlFilter   : "",
                                                     propertyName: 'Level2Name',
                                             ],
                                             style                : [:],
                                             bounds               : [],
                                             restrictions         : [:]
                                     ]]
                ]
        ]

        service.userService = userService
        service.grailsApplication = [config: [
                map: [
                        baseLayers: [
                                [
                                        'code'       : 'minimal',
                                        'displayText': 'Road map',
                                        'isSelected' : false
                                ]
                        ],
                        overlays  : [
                                [
                                        alaId                : 'cl4',
                                        alaName              : 'default',
                                        layerName            : 'default',
                                        title                : 'default title',
                                        defaultSelected      : false,
                                        boundaryColour       : '#e66101',
                                        showPropertyName     : false,
                                        fillColour           : '',
                                        textColour           : '',
                                        userAccessRestriction: 'anyUser',
                                        inLayerShapeList     : true,
                                        opacity              : 0.5,
                                        changeLayerColour    : false,
                                        display              : [
                                                cqlFilter   : "",
                                                propertyName: 'ECONAME',
                                        ],
                                        style                : [:],
                                        bounds               : [],
                                        restrictions         : [:]
                                ]
                        ]
                ]
        ]]
    }

    def cleanup() {
    }

    void "getMapLayersConfig will return baseLayers respecting the hierarchy rule"() {
        when: "Pick project activity configuration when hub and project configs are present"
        def config = service.getMapLayersConfig(project, projectActivity)

        then:
        config.baseLayers.size() == 1
        config.baseLayers[0].code == 'projectactivity'

        when: "Pick project configuration when project activity config is missing"
        config = service.getMapLayersConfig(project, null)

        then:
        config.baseLayers.size() == 1
        config.baseLayers[0].code != 'projectactivity'
        config.baseLayers[0].code == 'project'

        when: "Pick hub configuration when project and project activity configs are missing"
        config = service.getMapLayersConfig(null, null)

        then:
        config.baseLayers.size() == 1
        config.baseLayers[0].code != 'projectactivity'
        config.baseLayers[0].code != 'project'
        config.baseLayers[0].code == 'hub'

        when: "Pick default configuration when hub, project or project activity configuration is missing"
        SettingService.setHubConfig(new HubSettings([
                mapLayersConfig: null
        ]))
        config = service.getMapLayersConfig(null, null)

        then:
        config.baseLayers[0].code != 'projectactivity'
        config.baseLayers[0].code != 'project'
        config.baseLayers[0].code != 'hub'
        config.baseLayers[0].code == 'minimal'

    }

    void "getMapLayersConfig will return overlays respecting the hierarchy rule"() {
        when: "Pick project activity configuration when hub and project configs are present"
        def config = service.getMapLayersConfig(project, projectActivity)

        then:
        config.overlays.size() == 1
        config.overlays[0].alaId == 'cl2'

        when: "Pick project configuration when project activity config is missing"
        config = service.getMapLayersConfig(project, null)

        then:
        config.overlays.size() == 1
        config.overlays[0].alaId != 'cl2'
        config.overlays[0].alaId == 'cl3'

        when: "Pick hub configuration when project and project activity configs are missing"
        config = service.getMapLayersConfig(null, null)

        then:
        config.overlays.size() == 1
        config.overlays[0].alaId != 'cl3'
        config.overlays[0].alaId != 'cl2'
        config.overlays[0].alaId == 'cl1'

        when: "Pick default configuration when hub, project or project activity configuration is missing"
        SettingService.setHubConfig(new HubSettings([
                mapLayersConfig: null
        ]))
        config = service.getMapLayersConfig(null, null)

        then:
        config.overlays.size() == 1
        config.overlays[0].alaId != 'cl1'
        config.overlays[0].alaId != 'cl2'
        config.overlays[0].alaId != 'cl3'
        config.overlays[0].alaId == 'cl4'

        when: "Style property is added"
        config = service.getMapLayersConfig(project, projectActivity)

        then:
        config.overlays.size() == 1
        config.overlays[0].sld != null
        config.overlays[0].sld.contains('#b2abd2')


        when: "Hides restricted overlays"
        userService.getUser() >> null
        config = service.getMapLayersConfig(project, [
                mapLayersConfig: [
                        baseLayers: [],
                        overlays  : [[
                                             alaId                : 'cl3',
                                             userAccessRestriction: 'loggedInUser',
                                     ]]
                ]
        ])

        then:
        config.overlays.size() == 0
    }
}
