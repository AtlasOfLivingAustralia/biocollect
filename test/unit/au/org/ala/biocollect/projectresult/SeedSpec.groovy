package au.org.ala.biocollect.projectresult


import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import spock.lang.Specification

/*
 * Copyright (C) 2019 Atlas of Living Australia
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
 * Created by Temi on 2/12/19.
 */

class SeedSpec extends Specification {
    def grailsApplication
    def messageSource
    def results
    def params
    def instance
    def apiProperties

    def setup() {
        results = [[
                           "_source": [
                                   projectActivities: [[name: "x", description: "y", dataAccessMethods: ["oasrdfs"], datasetExternalURL: "http://xyx.com", projectActivityId: 'b']],
                                   projectId        : 'a',
                                   aim              : 'b',
                                   managerEmail     : 'bbb',
                                   manager          : 'bc@ala.org.au',
                                   description      : 'b',
                                   difficulty       : 'difficult',
                                   sites            : [[siteId: 'a', extent: [geometry: [:]]]],
                                   plannedEndDate   : new Date(),
                                   isExternal       : false,
                                   isSciStarter     : false,
                                   keywords         : 'p',
                                   links            : [],
                                   name             : 'n',
                                   organisationId   : '1',
                                   organisationName : 'org1',
                                   scienceType      : ['a'],
                                   ecoScienceType   : ['b'],
                                   plannedStartDate : new Date().minus(1),
                                   imageUrl         : 'a',
                                   urlWeb           : "http://abc.com",
                                   plannedStartDate : new Date().minus(1),
                                   plannedEndDate   : new Date(),
                                   projectType      : 'g',
                                   isMERIT          : false,
                                   tags             : ['n'],
                                   gear             : "g",
                                   getInvolved      : "g",
                                   logoAttribution  : "s",
                                   imageUrl         : "d",
                                   task             : "t",
                                   projectSiteId    : "a"
                           ]]]

        apiProperties = ["projectId",
                         "aim",
                         "coverage",
                         "description",
                         "difficulty",
                         "endDate",
                         "isExternal",
                         "isSciStarter",
                         "keywords",
                         "links",
                         "name",
                         "organisationId",
                         "organisationName",
                         "scienceType",
                         "ecoScienceType",
                         "startDate",
                         "urlImage",
                         "urlWeb",
                         "plannedStartDate",
                         "plannedEndDate",
                         "projectType",
                         "isMERIT",
                         "tags",
                         "projectEquipment",
                         "projectHowToParticipate",
                         "projectLogoImageCredit",
                         "projectLogoImage",
                         "contactName",
                         "contactDetails",
                         "projectTask",
                         "datasets"
        ]
        params = Mock(GrailsParameterMap.class)
    }

    def "api should return correct properties"() {
        def projects
        setup:
        instance = new Seed()

        when:
        projects = instance.build(results, params, grailsApplication, messageSource)

        then:
        projects.size() == 1
        def project = projects[0]
        apiProperties.each {
            assert project[it] != null
        }

        project.projectId == 'a'
        project.aim == 'b'
        project.contactName == 'bbb'
        project.contactDetails == 'bc@ala.org.au'
        project.datasets.size() == 1
        def dataset = project.datasets[0]
        dataset.dataAccessMethod[0] == 'oasrdfs'
        dataset.name == 'x'
        dataset.datasetExternalURL == "/bioActivity/projectRecords/b"
    }
}
