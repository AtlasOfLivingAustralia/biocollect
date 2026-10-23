package au.org.ala.biocollect.merit

import grails.testing.spring.AutowiredTest
import org.grails.plugins.converters.ConvertersGrailsPlugin
import org.grails.web.converters.configuration.ConvertersConfigurationHolder
import spock.lang.Specification

/*
 * Copyright (C) 2020 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 * 
 * Created by Temi on 24/6/20.
 */
class SiteServiceSpec extends Specification implements AutowiredTest{
    Closure doWithSpring() {{ ->
        service SiteService
    }}

    SiteService service
    Map projectSite, projectSiteWithPid

    def setup() {
        service.grailsApplication = grailsApplication
        service.grailsApplication.config.spatial.baseURL = ""
        service.grailsApplication.config.ecodata.service.url = ""
        service.grailsApplication.config.google.api.key = ""
        service.projectService = Mock(ProjectService)
        service.webService = Mock(WebService)
        service.commonService = Mock(CommonService)
        projectSite = [
                geoIndex: [
                        "type"       : "Polygon",
                        "coordinates": [[[0, 0], [0, 3], [1, 10], [5, 10], [0, 0]]]
                ]
        ]
        projectSiteWithPid = [
                        "type"       : "Polygon",
                        "coordinates": [[[0, 0], [0, 3], [1, 10], [5, 10], [0, 0]]]
                ]
        defineBeans(new ConvertersGrailsPlugin())
    }

    def tearDown(){
        ConvertersConfigurationHolder.clear()
    }

    def "checkPointInsideProjectAreaAndAddress should detect if point falls inside or outside project area"() {
        when:
        Map response = service.checkPointInsideProjectAreaAndAddress('9', '1', 'abc')

        then:
        1 * service.commonService.buildUrlParamsFromMap(_) >> ""
        1 * service.projectService.get(_) >> [projectSiteId: 'site1']
        1 * service.webService.getJson(_) >> projectSite
        response.isPointInsideProjectArea == true
        response.address == null

        when:
        response = service.checkPointInsideProjectAreaAndAddress('100', '9', 'abc')

        then:
        1 * service.commonService.buildUrlParamsFromMap(_) >> ""
        1 * service.projectService.get(_) >> [projectSiteId: 'site1']
        1 * service.webService.getJson(_) >> projectSite

        response.isPointInsideProjectArea == false
        response.address == null
    }

    def "checkPointInsideProjectAreaAndAddress should get geoJSON of pid"() {
        when:
        Map response = service.checkPointInsideProjectAreaAndAddress('9', '1', 'abc')

        then:
        1 * service.commonService.buildUrlParamsFromMap(_) >> ""
        1 * service.projectService.get(_) >> [projectSiteId: 'site1']
        1 * service.webService.getJson("/site/site1.geojson") >> projectSiteWithPid
        response.isPointInsideProjectArea == true
        response.address == null
    }

    def "getMapFeatures draws stored features when present, otherwise the extent"() {
        given:
        def pointCoordinates = [149.1, -35.3]
        def pointGeometry = [type: 'Point', decimalLatitude: -35.3, decimalLongitude: 149.1, coordinates: pointCoordinates]
        def circleGeometry = [type: 'Circle', radius: 25, coordinates: pointCoordinates]
        def ring = [[0, 0], [1, 0], [1, 1], [0, 0]]
        def polygonGeometry = [type: 'Polygon', coordinates: [ring]]
        def lineCoordinates = [[149, -35], [150, -36]]
        def lineGeometry = [type: 'LineString', coordinates: lineCoordinates]
        def pidGeometry = [type: 'pid', pid: 'cl123', name: 'Park']
        def storedFeature = [type: 'Feature', geometry: [type: 'Point', coordinates: [1, 2]], properties: [type: 'Point']]
        def storedFeatures = [storedFeature]

        when:
        def point = service.getMapFeatures([extent: [source: 'point', geometry: pointGeometry]])

        then:
        point.features.size() == 1
        point.features[0].type == 'Point'
        point.features[0].coordinates == pointCoordinates

        when:
        def circle = service.getMapFeatures([extent: [source: 'drawn', geometry: circleGeometry]])

        then:
        circle.features[0].type == 'Circle'
        circle.features[0].radius == 25
        circle.features[0].coordinates == pointCoordinates

        when:
        def polygon = service.getMapFeatures([extent: [source: 'drawn', geometry: polygonGeometry]])

        then:
        polygon.features[0].type == 'Polygon'
        polygon.features[0].coordinates == [ring]

        when:
        def line = service.getMapFeatures([extent: [source: 'drawn', geometry: lineGeometry]])

        then:
        line.features[0].type == 'LineString'
        line.features[0].coordinates == lineCoordinates

        when:
        def pid = service.getMapFeatures([extent: [source: 'pid', geometry: pidGeometry]])

        then:
        pid.features.size() == 1
        pid.features[0].type == 'pid'
        pid.features[0].pid == 'cl123'
        pid.features[0].coordinates == null

        when:
        def empty = service.getMapFeatures([extent: [source: 'none']])

        then:
        empty == [:]

        when:
        def withFeatures = service.getMapFeatures([features: storedFeatures, extent: [source: 'drawn', geometry: polygonGeometry]])

        then:
        withFeatures.zoomToBounds == true
        withFeatures.features == storedFeatures
        withFeatures.features.size() == 1
    }
}
