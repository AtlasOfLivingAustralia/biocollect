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

class Builder {

    /**
     * Build project data
     *
     * @param params*
     * @param projects list of projects
     * @return list of projects
     */
    static List build(GrailsParameterMap params, List projects, def grailsApplication, def messageSource) {
        List result = []
        switch (params.initiator) {
            case Initiator.scistarter.name():
                result = SciStarter.build(projects, params)
                break
            case Initiator.ala.name():
                result = ALA.build(projects, params)
                break
            case Initiator.seed.name():
                result = Seed.build(projects, params, grailsApplication, messageSource)
                break
            case Initiator.biocollect.name():
            default:
                result = BioCollect.build(projects, params)
                break
        }

        result
    }

    /**
     * Override parameter based upon initiator.
     *
     * @param params*
     * @return
     */
    static void override(GrailsParameterMap params) {

        switch (params.initiator) {
            case Initiator.scistarter.name():
                params.isCitizenScience = true
                params.isWorks = false
                params.isBiologicalScience = false
                params.isMERIT = false
                params.isUserPage = false
                params.query = "docType:project"
                break

            case Initiator.ala.name():
                params.isMERIT = false
                break
            case Initiator.biocollect.name():

            default:
                break
        }
    }
}
