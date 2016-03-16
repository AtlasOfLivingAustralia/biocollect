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

import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap

class BioCollect {

    /**
     * Build project data for biocollect home page.
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
                    siteGeom = site.extent?.geometry;
                }
            }

            [
                projectId              : doc.projectId,
                aim                    : doc.aim,
                coverage               : siteGeom,
                description            : doc.description,
                difficulty             : doc.difficulty,
                endDate                : doc.plannedEndDate,
                hasParticipantCost     : doc.hasParticipantCost?.toBoolean(),
                hasTeachingMaterials   : doc.hasTeachingMaterials?.toBoolean(),
                isDIY                  : doc.isDIY?.toBoolean(),
                isContributingDataToAla: doc.isContributingDataToAla?.toBoolean(),
                isExternal             : doc.isExternal?.toBoolean(),
                isSuitableForChildren  : doc.isSuitableForChildren?.toBoolean(),
                isSciStarter           : doc.isSciStarter?.toBoolean(),
                keywords               : doc.keywords,
                links                  : trimmedLinks,
                name                   : doc.name,
                organisationId         : doc.organisationId,
                organisationName       : doc.organisationName,
                scienceType            : doc.scienceType,
                startDate              : doc.plannedStartDate,
                urlImage               : doc.imageUrl,
                urlWeb                 : doc.urlWeb,
                plannedStartDate       : doc.plannedStartDate,
                plannedEndDate         : doc.plannedEndDate,
                isMERIT                : doc.isMERIT
            ]
        }
    }
}
