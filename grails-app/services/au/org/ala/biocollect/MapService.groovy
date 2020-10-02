package au.org.ala.biocollect

import au.org.ala.biocollect.merit.SettingService
import au.org.ala.biocollect.merit.hub.HubSettings
import groovy.xml.StreamingMarkupBuilder

class MapService {

    def grailsApplication
    def userService
    def projectService

    /**
     * Gets base layer and overlay configuration. It can be stored in three places - Hub, Project, ProjectActivity or application config.
     * The configuration precedence is ProjectActivity, Project, Hub and application config. Therefore, if configuration is missing in
     * ProjectActivity then Project configuration is taken into account. If that is missing then Hub. Lastly, application
     * configuration.
     * @param project
     * @param projectActivity
     * @return
     * [
     *  baseLayers: [
     *  [
     *     'code': 'minimal',
     *     'displayText': 'Road map',
     *     'isSelected': false
     *  ]
     * ],
     *  overlays: [
     *  [
     *    alaId       : 'cl1059',
     *    alaName     : 'drainage_divisions_level2',
     *    layerName   : 'aust_river_basins',
     *    title         : 'River Basins',
     *    defaultSelected: false,
     *    boundaryColour  : '#005ce6',
     *    showPropertyName: false,
     *    fillColour      : '#bef7cf',
     *    textColour      : '#FFF',
     *    userAccessRestriction: 'anyUser',
     *    inLayerShapeList     : true,
     *    opacity: 0.5,
     *    changeLayerColour: false
     *    sld: "<xml></xml>"
     *    ....
     *  ]
     * ]
     */
    def getMapLayersConfig(Map project, Map projectActivity) {
        Map mapConfig = [baseLayers: [], overlays: []],
            defaultMapConfig = grailsApplication.config.map

        HubSettings hub = SettingService.getHubConfig()

        // projectActivity config
        if (!mapConfig.baseLayers && projectActivity && projectActivity.mapLayersConfig && projectActivity.mapLayersConfig.baseLayers) {
            mapConfig.baseLayers = projectActivity.mapLayersConfig.baseLayers
        }

        if (!mapConfig.overlays && projectActivity && projectActivity.mapLayersConfig && projectActivity.mapLayersConfig.overlays) {
            mapConfig.overlays = projectActivity.mapLayersConfig.overlays
        }

        // project config
        if (!mapConfig.baseLayers && project && project.mapLayersConfig && project.mapLayersConfig.baseLayers) {
            mapConfig.baseLayers = project.mapLayersConfig.baseLayers
        }

        if (!mapConfig.overlays && project && project.mapLayersConfig && project.mapLayersConfig.overlays) {
            mapConfig.overlays = project.mapLayersConfig.overlays
        }

        // hub config
        if (!mapConfig.baseLayers && hub && hub.mapLayersConfig && hub.mapLayersConfig.baseLayers) {
            mapConfig.baseLayers = hub.mapLayersConfig.baseLayers
        }

        if (!mapConfig.overlays && hub && hub.mapLayersConfig && hub.mapLayersConfig.overlays) {
            mapConfig.overlays = hub.mapLayersConfig.overlays
        }

        // default config
        if (!mapConfig.baseLayers && defaultMapConfig && defaultMapConfig.baseLayers) {
            mapConfig.baseLayers = defaultMapConfig.baseLayers
        }

        if (!mapConfig.overlays && defaultMapConfig && defaultMapConfig.overlays) {
            mapConfig.overlays = defaultMapConfig.overlays
        }

        // filter overlays to user
        mapConfig.overlays = getUserLayers(mapConfig.overlays)
        mapConfig.overlays = addLayerStyle(mapConfig.overlays)
        mapConfig.overlays = addOverlayDefaultSettings(mapConfig.overlays)
        mapConfig
    }

    List addOverlayDefaultSettings(List overlays) {
        List propertiesToCopy = ['display', 'bounds']
            overlays?.each { overlay ->
            def defaultOverlayValue = grailsApplication.config.map.overlays?.find { it.alaId == overlay.alaId }
                if (defaultOverlayValue) {
                    propertiesToCopy.each { overlay[it] = defaultOverlayValue[it] }
                }
        }

        overlays
    }

    List addLayerStyle(List overlays) {
        overlays?.each { layer ->
            layer.sld = buildXml(layer).toString()
        }

        overlays
    }

    List getMapDisplays(Map project) {
        def user = userService.getUser(),
            hub = SettingService.hubConfig

        String projectId = project?.projectId,
                SHOW_LOGGED_IN = 'showLoggedIn',
                SHOW_LOGGED_OUT = 'showLoggedOut',
                SHOW_PROJECT_MEMBERS = 'showProjectMembers',
                attributeToFilter = SHOW_LOGGED_OUT

        List mapDisplays
        // ALA admins can view everything
        if (userService.userIsAlaAdmin()) {
            return grailsApplication.config.map.data.displays
        }
        else if (project) {
            if (project?.mapDisplays) {
                mapDisplays = project?.mapDisplays
                if (user && userService.isUserAdminForProject(user.userId, projectId)) {
                    // project admins can view everything
                    return grailsApplication.config.map.data.displays
                }
                else if (user && (projectService.isUserParticipantForProject(user.userId, projectId)
                        || projectService.isUserEditorForProject(user.userId, projectId)
                        || projectService.isUserModeratorForProject(user.userId, projectId))) {
                    attributeToFilter = SHOW_PROJECT_MEMBERS
                }
                else if (user) {
                    attributeToFilter = SHOW_LOGGED_IN
                }
                else {
                    attributeToFilter = SHOW_LOGGED_OUT
                }
            }
            else if (hub?.mapDisplays) {
                mapDisplays = hub?.mapDisplays
                if (user) {
                    attributeToFilter = SHOW_LOGGED_IN
                }
                else {
                    attributeToFilter = SHOW_LOGGED_OUT
                }
            }
            else {
                mapDisplays = grailsApplication.config.map.data.displays
                if (user) {
                    attributeToFilter = SHOW_LOGGED_IN
                }
                else {
                    attributeToFilter = SHOW_LOGGED_OUT
                }
            }
        } else {
            mapDisplays = hub?.mapDisplays ?: grailsApplication.config.map.data.displays
            if (user) {
                attributeToFilter = SHOW_LOGGED_IN
            }
            else {
                attributeToFilter = SHOW_LOGGED_OUT
            }
        }

        mapDisplays.findAll { it[attributeToFilter] }
    }

    /**
     * Filter the list of layers based on the user.
     * @param layers
     * @return The layers available to the current user.
     */
    private List<Map<String, Object>> getUserLayers(List<Map<String, Object>> layers) {
        def user = userService.getUser()
        def layersForUser = layers.findAll { item ->
            (item.userAccessRestriction == 'anyUser') ||
                    (item.userAccessRestriction == 'loggedInUser' && user != null)
        }

        return layersForUser
    }

    def buildXml(Map<String, Object> layer) {
        // String layerName, String propertyName, String boundaryColour, String fillColour = null, String styleTextColour = null
        // http://docs.groovy-lang.org/docs/groovy-2.4.10/html/documentation/#_creating_xml

        def layerName = layer.alaName
        def fillColour = layer.fillColour ?: '#000000'
        def fillOpacity = layer.fillColour ? 1 : 0
        def boundaryColour = layer.boundaryColour ?: '#000000'
        def textColour = layer.textColour ?: '#000000'
        def showPropertyName = layer.showPropertyName ?: false
        def propertyName = layer.display?.propertyName ?: ''

        // http://docs.groovy-lang.org/docs/groovy-2.4.10/html/documentation/#_creating_xml
        def builder = new StreamingMarkupBuilder()
        builder.encoding = 'UTF-8'
        def style = builder.bind {
            mkp.xmlDeclaration()
            StyledLayerDescriptor("version": "1.0.0",
                    "xsi:schemaLocation": "http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd",
                    "xmlns": "http://www.opengis.net/sld",
                    "xmlns:ogc": "http://www.opengis.net/ogc",
                    "xmlns:xlink": "http://www.w3.org/1999/xlink",
                    "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance") {
                NamedLayer() {
                    Name("ALA:${layerName}")
                    UserStyle() {
                        Name("Style for layer ${layerName}")
                        Title("Style for layer ${layerName}")
                        FeatureTypeStyle() {
                            Rule() {
                                PolygonSymbolizer() {
                                    Fill() {
                                        CssParameter(name: "fill", fillColour)


                                        CssParameter(name: "fill-opacity", fillOpacity)

                                    }
                                    Stroke() {
                                        CssParameter(name: "stroke", boundaryColour)
                                        CssParameter(name: "stroke-opacity", 1)
                                        CssParameter(name: "stroke-width", 1)
                                    }
                                }
                                if (showPropertyName && propertyName) {
                                    TextSymbolizer() {
                                        Label() {
                                            'ogc:PropertyName'(propertyName)
                                        }
                                        Font() {
                                            CssParameter(name: "font-family", 'Arial')
                                            CssParameter(name: "font-weight", 'bold')
                                            CssParameter(name: "font-size", '8')
                                            CssParameter(name: "text-transform", 'capitalize')
                                        }
                                        Fill() {
                                            CssParameter(name: "fill", textColour)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return style
    }
}
