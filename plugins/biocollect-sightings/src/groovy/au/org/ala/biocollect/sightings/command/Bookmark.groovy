/*
 * Copyright (C) 2015 Atlas of Living Australia
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

package au.org.ala.biocollect.sightings.command

/**
 * Bean for bookmark locations data (coming from ecodata)
 *
 * @author "Nick dos Remedios <Nick.dosRemedios@csiro.au>"
 */
@grails.validation.Validateable
class Bookmark {
    String userId
    String locality
    String locationId
    Double decimalLatitude
    Double decimalLongitude
    String geodeticDatum
    String georeferenceProtocol
    String dateCreated

    static constraints = {

    }

}
