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
package au.org.ala.biocollect.sightings.command

import groovy.util.logging.Log4j
import org.joda.time.DateTime
import org.joda.time.format.DateTimeFormat
import org.joda.time.format.DateTimeFormatter;

/**
 * Command class for the sighting (based on DarwinCore terms)
 *
 * @author "Nick dos Remedios <Nick.dosRemedios@csiro.au>"
 */
@Log4j
@grails.validation.Validateable
class Sighting {
    String userId
    String userDisplayName
    String recordedBy
    String taxonConceptID
    String scientificName
    String family
    String kingdom
    String commonName
    List<String> tags = [].withDefault { new String() } // taxonomic tags
    String identificationVerificationStatus // identification confidence
    Boolean requireIdentification
    Integer individualCount
    List<Media> multimedia = [].withDefault { new Media() }
    String dateStr // date part that is copied into eventDate
    String timeStr // time part that is copied into eventDate
    String eventDate // output - ISO date with time
    String timeZoneOffset = (((TimeZone.getDefault().getRawOffset() / 1000) / 60) / 60)
    BigDecimal decimalLatitude
    BigDecimal decimalLongitude
    String geodeticDatum = "WGS84"
    Integer coordinateUncertaintyInMeters
    String georeferenceProtocol
    String usingReverseGeocodedLocality
    String locality
    String locationRemark
    String occurrenceRemarks
    String submissionMethod = "website"
    // Properties needed to un-marshall from ecodata
    Boolean offensiveFlag
    String offensiveReason
    String taxonoverflowID
    String taxonoverflowURL
    String identifiedBy
    String identifiedByUserId
    String occurrenceID
    String dateCreated
    String lastUpdated
    String lastUpdatedFromTaxonoverflow
    String dateIdentified
    String error // fromm webservice failures
    String projectId
    String dataResourceUid
    String coordinatePrecision
    String device
    String eventTime

    static constraints = {
        userId(nullable: true)
        userDisplayName(nullable: true)
        recordedBy(nullable: true)
        taxonConceptID(nullable: true)
        scientificName(nullable: true, validator: { val, obj ->
            // one of scientificName or (tags + image) must be specified
            if (!val) {
                if (!obj.tags || !obj.multimedia) {
                    return ['sighting.sciname.validation']
                }
            }
        })
        kingdom(nullable: true)
        family(nullable: true)
        commonName(nullable: true)
        tags(nullable: true)
        identificationVerificationStatus(nullable: true)
        requireIdentification(nullable: true)
        multimedia(nullable: true)
        timeZoneOffset(nullable: true)
        eventDate(nullable: false)
        coordinateUncertaintyInMeters(nullable: true, range: 1..10000)
        decimalLatitude(nullable: true, scale: 8, range: -90..90)
        decimalLongitude(nullable: true,  scale: 8, range: -180..180)
        geodeticDatum(nullable: true)
        usingReverseGeocodedLocality(nullable: true)
        locality(nullable: true)
        locationRemark(nullable: true)
        occurrenceRemarks(nullable: true)
        offensiveFlag(nullable: true)
        lastUpdatedFromTaxonoverflow(nullable: true)
        taxonoverflowURL(nullable: true)
        identifiedBy(nullable: true)
        offensiveReason(nullable: true)
        dateIdentified(nullable: true)
        taxonoverflowID(nullable: true)
        identifiedByUserId(nullable: true)
        submissionMethod(nullable: true)
        occurrenceID(nullable: true)
        dateCreated(nullable: true)
        lastUpdated(nullable: true)
        error(nullable: true)
        dateStr(nullable: true)
        timeStr(nullable: true)
        projectId(nullable: true)
        dataResourceUid(nullable: true)
        coordinatePrecision(nullable: true)
        device(nullable:true)
        eventTime(nullable:true)
    }

    public void setDateStrZ(String dateInputStr) {
        if (dateInputStr) {
            DateTimeFormatter format = DateTimeFormat.forPattern("yyyy-MM-dd'T'HH:mm:ssZ");
            String input = "${dateInputStr}T${timeStr?:'00:00'}:00${timeZoneOffset?:'Z+10:00'}"
            DateTime dateTime = format.withOffsetParsed().parseDateTime(input)
            Date date = dateTime.toDate()
            log.error "input date = ${date} || ${input}"
            eventDate = date
            dateStr = dateInputStr
        }
    }
}
