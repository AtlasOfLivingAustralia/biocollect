package au.org.ala.biocollect.merit

import grails.test.mixin.TestFor
import grails.test.mixin.TestMixin
import grails.test.mixin.services.ServiceUnitTestMixin
import spock.lang.Specification

/*
 * Copyright (C) 2021 Atlas of Living Australia
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
 * Created by Temi on 3/8/21.
 */

@TestFor(SpeciesService)
@TestMixin(ServiceUnitTestMixin)
class SpeciesServiceSpec extends Specification {
    def setup() {
        service.grailsApplication = [
                "config": [
                        "lists": [
                                "baseURL": "xyz"
                        ]
                ]
        ]

        service.webService = Mock(WebService)
    }

    void "should call list tool with empty search term" () {
        String searchTerm = null
        String url = "xyz/ws/speciesList?sort=listName&max=10&offset=0&order=asc&q="

        when:
        service.searchSpeciesList('listName', 10, 0, null, 'asc', searchTerm)

        then:
        1 * service.webService.getJson(url) >> [:]
    }

    void "should call list tool with passed search term"() {
        String searchTerm = 'abc'
        String url = "xyz/ws/speciesList?sort=listName&max=10&offset=0&order=asc&q=abc"

        when:
        service.searchSpeciesList('listName', 10, 0, null, 'asc', searchTerm)

        then:
        1 * service.webService.getJson(url) >> [:]

    }
}
