/*
 * Copyright (C) 2016 Atlas of Living Australia
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
 */

package au.org.ala.biocollect.projectresult

import grails.web.servlet.mvc.GrailsParameterMap

class SciStarter {

    /**
     * Build project data for SciStarter system.
     *
     * @param projects list of projects
     * @param params
     * @return
     */
    static List build(List projects, GrailsParameterMap params) {

        projects.collect {
            Map doc = it._source;

            // no need to ship the whole link object down to browser
            def trimmedLinks = doc.links.collect {
                [
                        role: it.role,
                        url : it.url
                ]
            }

            Map siteGeom;
            doc?.sites?.each { site ->
                if (doc?.projectSiteId == site.siteId) {
                    siteGeom = site.geoIndex
                }
            }

            [
                projectId              : doc.projectId,
                name                   : doc.name,
                keywords               : doc.keywords,
                aim                    : doc.aim,
                task                   : doc.task,
                dateCreated            : doc.dateCreated,
                lastUpdated            : doc.lastUpdated,
                status                 : doc.status,
                managerEmail           : doc.manager,
                organisationName       : doc.organisationName,
                description            : doc.description,
                getInvolved            : doc.getInvolved,
                urlWeb                 : doc.urlWeb,
                urlImage               : doc.imageUrl,
                logoCredit             : doc.logoAttribution,
                difficulty             : doc.difficulty,
                scienceType            : doc.scienceType,
                ecoScienceType         : doc.ecoScienceType,
                isDIY                  : doc.isDIY?.toBoolean(),
                isSciStarter           : doc.isSciStarter?.toBoolean(),
                hasParticipantCost     : doc.hasParticipantCost?.toBoolean(),
                equipment              : doc.gear,
                plannedStartDate       : doc.plannedStartDate,
                plannedEndDate         : doc.plannedEndDate,
                endDate                : doc.plannedEndDate,
                coverage               : siteGeom,
                links                  : trimmedLinks,
                startDate              : doc.plannedStartDate,
                url                    : params.url + "/acsa/project/index/" + doc.projectId
            ]
        }
    }
}
