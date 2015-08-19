/*
 * Copyright (C) 2014 Atlas of Living Australia
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

package au.org.ala.biocollect.sightings.marshaller

import au.org.ala.biocollect.sightings.command.Sighting
import grails.converters.JSON

/**
 * Custom JSON marshaller
 *
 * @author "Nick dos Remedios <Nick.dosRemedios@csiro.au>"
 */
class SightingMarshaller {
    void register() {
        JSON.registerObjectMarshaller(Sighting) { Sighting sighting ->
            return [
                    "occurrenceID" : sighting.occurrenceID,
                    "userId" : sighting.userId,
                    "recordedBy" : sighting.recordedBy,
                    "scientificName" : sighting.scientificName,
                    "family" : sighting.family,
                    "kingdom" : sighting.kingdom,
                    "commonName" : sighting.commonName,
                    "tags": sighting.tags,
                    "identificationVerificationStatus": sighting.identificationVerificationStatus,
                    "requireIdentification": sighting.requireIdentification,
                    "individualCount": sighting.individualCount,
                    "multimedia": sighting.multimedia,
                    "eventDate": sighting.eventDate,
                    "decimalLatitude": sighting.decimalLatitude,
                    "decimalLongitude": sighting.decimalLongitude,
                    "coordinateUncertaintyInMeters": sighting.coordinateUncertaintyInMeters,
                    "geodeticDatum": sighting.geodeticDatum,
                    "georeferenceProtocol": sighting.georeferenceProtocol,
                    "locality": sighting.locality,
                    "locationRemark": sighting.locationRemark,
                    "occurrenceRemarks": sighting.occurrenceRemarks,
                    "submissionMethod": sighting.submissionMethod
            ]
        }
    }
}
