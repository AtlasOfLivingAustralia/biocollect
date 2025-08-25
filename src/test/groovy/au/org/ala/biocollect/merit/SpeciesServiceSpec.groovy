package au.org.ala.biocollect.merit


import grails.testing.services.ServiceUnitTest
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

class SpeciesServiceSpec extends Specification implements ServiceUnitTest<SpeciesService> {

    def setup() {
        service.grailsApplication = grailsApplication
        service.grailsApplication.config.lists.baseURL = "xyz"

        service.webService = Mock(WebService)
    }

    def "formatTaxonName should format name based on displayType"() {
        setup:
        Map data = [commonName: commonName, scientificName: scientificName]

        when:
        String result = service.formatTaxonName(data, displayType)

        then:
        result == expectedName

        where:
        commonName         | scientificName       | displayType                         | expectedName
        'Blackbird'        | 'Turdus merula'      | service.COMMON_NAME_SCIENTIFIC_NAME       | 'Blackbird (Turdus merula)'
        'Blackbird'        | 'Turdus merula'      | service.SCIENTIFIC_NAME_COMMON_NAME       | 'Turdus merula (Blackbird)'
        'Blackbird'        | 'Turdus merula'      | service.COMMON_NAME                       | 'Blackbird'
        null               | 'Turdus merula'      | service.COMMON_NAME                       | 'Turdus merula'
        'Blackbird'        | 'Turdus merula'      | service.SCIENTIFIC_NAME                   | 'Turdus merula'
        null               | 'Turdus merula'      | service.SCIENTIFIC_NAME                   | 'Turdus merula'
        null               | 'Turdus merula'      | service.COMMON_NAME_SCIENTIFIC_NAME       | 'Turdus merula'
        null               | 'Turdus merula'      | service.SCIENTIFIC_NAME_COMMON_NAME       | 'Turdus merula'
        'Blackbird'        | null                 | service.COMMON_NAME_SCIENTIFIC_NAME       | 'Blackbird'
        'Blackbird'        | null                 | service.SCIENTIFIC_NAME_COMMON_NAME       | 'Blackbird'
        'Blackbird'        | null                 | service.COMMON_NAME                       | 'Blackbird'
        null               | null                 | service.COMMON_NAME                       | ''
        null               | null                 | service.SCIENTIFIC_NAME                   | ''
        null               | null                 | service.COMMON_NAME_SCIENTIFIC_NAME       | ''
        null               | null                 | service.SCIENTIFIC_NAME_COMMON_NAME       | ''
    }
}
