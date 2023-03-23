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
}
