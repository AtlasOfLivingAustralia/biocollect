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

            [
                projectId              : doc.projectId,
                aim                    : doc.aim,
                coverage               : doc.projectArea?.geoIndex,
                description            : doc.description,
                difficulty             : doc.difficulty,
                endDate                : doc.plannedEndDate,
                isExternal             : doc.isExternal?.toBoolean(),
                isSciStarter           : doc.isSciStarter?.toBoolean(),
                keywords               : doc.keywords,
                links                  : trimmedLinks,
                name                   : doc.name,
                organisationId         : doc.organisationId,
                organisationName       : doc.organisationName,
                scienceType            : doc.scienceType,
                ecoScienceType         : doc.ecoScienceType,
                startDate              : doc.plannedStartDate,
                urlImage               : doc.imageUrl,
                fullSizeImageUrl       : doc.fullSizeImageUrl,
                urlWeb                 : doc.urlWeb,
                plannedStartDate       : doc.plannedStartDate,
                plannedEndDate         : doc.plannedEndDate,
                projectType            : doc.projectType,
                isMERIT                : doc.isMERIT,
                tags                   : doc.tags,
                containsActivity       : doc.containsActivity,
                publicParticipation    : doc.publicParticipation,
                numberOfRecords        : doc.numberOfRecords
                containsActivity       : doc.containsActivity,
                projectEquipment       : doc.gear,
                projectHowToParticipate: doc.getInvolved,
                projectLogoImageCredit : doc.logoAttribution,
                projectLogoImage       : doc.imageUrl,
                projectTask            : doc.task,
                projectActivities      : doc.projectActivities,
                contactName            : doc.managerEmail,
                contactDetails         : doc.manager
            ]
        }
    }
}
