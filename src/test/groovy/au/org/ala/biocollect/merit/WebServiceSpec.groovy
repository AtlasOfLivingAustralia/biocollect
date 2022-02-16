package au.org.ala.biocollect.merit


import grails.test.mixin.TestFor
import grails.test.mixin.TestMixin
import grails.test.mixin.services.ServiceUnitTestMixin
import spock.lang.Specification

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
 * Created by Temi on 15/2/22.
 */

@TestFor(WebService)
@TestMixin(ServiceUnitTestMixin)
class WebServiceSpec extends Specification {

    def "hub header must be added to URL connection"() {
        given:
        grailsApplication.config.grails.serverURL = 'http://xyz.com'
        URLConnection connection = new URL("http://example.com").openConnection()

        when:
        service.addHubUrlPath(connection)

        then:
        connection.getRequestProperty(grailsApplication.config.app.http.header.hostName) == grailsApplication.config.grails.serverURL
    }

    def "hub header must be added to header map"() {
        given:
        grailsApplication.config.grails.serverURL = 'http://xyz.com'
        Map header = [:]

        when:
        service.addHubUrlPath(header)

        then:
        header[grailsApplication.config.app.http.header.hostName] == grailsApplication.config.grails.serverURL
    }
}
