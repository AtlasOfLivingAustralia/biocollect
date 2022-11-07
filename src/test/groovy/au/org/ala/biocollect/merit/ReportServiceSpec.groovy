package au.org.ala.biocollect.merit

import au.org.ala.biocollect.merit.hub.HubSettings
import grails.testing.spring.AutowiredTest
import spock.lang.Specification
import org.springframework.context.MessageSource
/*
 * Copyright (C) 2022 Atlas of Living Australia
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
 * Created by Temi on 25/5/22.
 */

class ReportServiceSpec extends Specification implements AutowiredTest{
    Closure doWithSpring() {{ ->
        service ReportService
    }}

    ReportService service
    def settingServiceStub = Mock(SettingService)
    def webServiceStub = Mock(WebService)
    def messageSourceStub = Mock(MessageSource)

    void setup() {
        service.grailsApplication = grailsApplication
        service.webService = webServiceStub
        service.messageSource = messageSourceStub
    }

    void "Report items should be returned as provided" () {
        given:
        grailsApplication.config.ecodata.baseURL = ""
        SettingService.setHubConfig(new HubSettings([defaultFacetQuery: ["className:abc"]]))
        def config = [fq:[], reportConfig: [groups:[property: 'grp1']], index: "homepage"]
        def resp = [resp: [ results: [count:451, groups:[[count:31, results:[], group:"group 1"], [count:94, results:[], group:"group 2"]], label:"label 1"], metadata: [:]]]

        when:
        def result = service.genericReport(config)

        then:
        1 * webServiceStub.doPost("/ws/search/genericReport", _) >> resp
        2 * messageSourceStub.getMessage(_, _, _, _) >> { code, args, defaultMessage, locale -> defaultMessage }
        result == resp.resp.results
    }

    void "Report items should be grouped further into provided categories" () {
        given:
        grailsApplication.config.ecodata.baseURL = ""
        SettingService.setHubConfig(new HubSettings([defaultFacetQuery: ["className:abc"]]))
        def config = [fq:[], reportConfig: [groups:[property: 'grp1']], index: "homepage", resultGrouping: [[label: "group", items: ["group 1", 'group 2']]]]
        def resp = [resp: [ results: [count:125, groups:[[count:31, results:[], group:"group 1"], [count:94, results:[], group:"group 2"]], label:"label 1"], metadata: [:]]]

        when:
        def result = service.genericReport(config)

        then:
        1 * webServiceStub.doPost("/ws/search/genericReport", _) >> resp
        1 * messageSourceStub.getMessage(_, _, _, _) >> { code, args, defaultMessage, locale -> defaultMessage }
        result == [count:125, groups:[[count:125, group:"group"]], label:"label 1"]
    }

    void "Report should return empty Map during webservice failure" () {
        given:
        grailsApplication.config.ecodata.baseURL = ""
        SettingService.setHubConfig(new HubSettings([defaultFacetQuery: ["className:abc"]]))
        def config = [fq:[], reportConfig: [groups:[property: 'grp1']], index: "homepage", resultGrouping: [[label: "group", items: ["group 1", 'group 2']]]]
        def resp = [error: "An error occurred", statusCode: 500]

        when:
        def result = service.genericReport(config)

        then:
        1 * webServiceStub.doPost("/ws/search/genericReport", _) >> resp
        0 * messageSourceStub.getMessage(_, _, _, _) >> { code, args, defaultMessage, locale -> defaultMessage }
        result == [:]
    }
}
