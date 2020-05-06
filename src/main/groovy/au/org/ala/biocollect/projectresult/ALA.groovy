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

class ALA {

    /**
     * Build project data for ALA Search index.
     *
     * @param projects list of projects
     * @param params
     * @return
     */
    static List build(List projects, GrailsParameterMap params) {

        projects.collect {
            Map doc = it._source;

            [
                name       : doc.name,
                projectId  : doc.projectId,
                description: doc.description,
                keywords   : doc.keywords,
                projectType: doc.projectType,
                lastUpdated: doc.lastUpdated,
                dateCreated: doc.dateCreated,
                urlWeb     : doc.urlWeb,
                urlImage   : doc.imageUrl,
                url        : params.url + "/project/index/" + doc.projectId
            ]
        }
    }
}
