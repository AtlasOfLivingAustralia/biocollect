package au.org.ala.biocollect.sightings

import grails.converters.JSON

class SightingValidationService {

    static transactional = false

    def webserviceService

    def grailsApplication

    /**
     * Performs a set of validation checks on a record.
     *
     * @param name
     * @param lat
     * @param lon
     * @return
     */
    def validate(name, lat, lon){

        try {
            def resp = webserviceService.doPost(grailsApplication.config.biocache.baseURL + "/ws/process/adhoc", [
                    scientificName  : name,
                    decimalLatitude : lat,
                    decimalLongitude: lon
            ])

            def payload = resp.resp

            def scientificName = payload.values.find { it.name == "scientificName" }?.processed
            def taxonConceptID = payload.values.find { it.name == "taxonConceptID" }?.processed
            def decimalLatitude = payload.values.find { it.name == "decimalLatitude" }?.processed
            def decimalLongitude = payload.values.find { it.name == "decimalLongitude" }?.processed
            def dataGeneralizations = payload.values.find { it.name == "dataGeneralizations" }?.processed
            def originalDecimalLatitude = payload.values.find { it.name == "decimalLatitude" }?.raw
            def originalDecimalLongitude = payload.values.find { it.name == "decimalLongitude" }?.raw

            def globalConservation = payload.values.find { it.name == "globalConservation" }?.processed
            def countryConservation = payload.values.find { it.name == "countryConservation" }?.processed
            def stateProvinceConservation = payload.values.find { it.name == "stateProvinceConservation" }?.processed

            //habitat mismatch
            def habitatMismatch = false
            def habitatMismatchMessage = ""
            def habitatCheck = payload.assertions.find { it.code == 19 }
            if (habitatCheck) {
                habitatMismatch = habitatCheck.qaStatus == 0 ? true : false
                habitatMismatchMessage = habitatCheck.comment
            }

            def tests = [:]

            payload.assertions.each {
                tests.put(it.name, it.qaStatus == 1 ? false : true)
            }

            log.debug("Recognised taxonConceptID: " + taxonConceptID)

            def resp2 = webserviceService.doPostWithParams(
                    grailsApplication.config.spatial.baseURL + "/ws/distribution/outliers/" + taxonConceptID,
                    ["pointsJson": (["occurrence": [decimalLatitude: lat, decimalLongitude: lon]] as JSON).toString()]
            )

            def outlierForExpertDistribution = false
            def distanceFromExpertDistributionInMetres = ""
            def imageOfExpertDistribution = ""

            if (resp2.resp) {
                if (resp2.resp."occurrence") {
                    outlierForExpertDistribution = true
                    distanceFromExpertDistributionInMetres = resp2.resp."occurrence"
                }

                def expertDistro = webserviceService.getJson(grailsApplication.config.layers.service.url + "/distribution/map/" + URLEncoder.encode(scientificName, "UTF-8"))
                if (expertDistro.url) {
                    imageOfExpertDistribution = expertDistro.url
                }
            }

            return [
                    taxonConceptID                        : taxonConceptID,
                    scientificName                        : scientificName,
                    decimalLatitude                       : decimalLatitude,
                    decimalLongitude                      : decimalLongitude,
                    sensitive                             : payload.sensitive ?: false,
                    dataGeneralizations                   : dataGeneralizations,
                    originalDecimalLatitude               : originalDecimalLatitude,
                    originalDecimalLongitude              : originalDecimalLongitude,
                    outlierForExpertDistribution          : outlierForExpertDistribution,
                    distanceFromExpertDistributionInMetres: distanceFromExpertDistributionInMetres,
                    imageOfExpertDistribution             : imageOfExpertDistribution,
                    //            extinct: false,
                    conservationStatus                    : [
                            stateProvince: stateProvinceConservation,
                            country      : countryConservation,
                            global       : globalConservation
                    ],
                    habitatMismatch                       : habitatMismatch,
                    habitatMismatchDetail                 : habitatMismatchMessage,
                    //            hasNearestRecentSighting:true,
                    //            nearestRecentSighting: [
                    //                decimalLatitude:0,
                    //                decimalLongitude:0,
                    //            ],
                    otherTests                            : tests
            ]
        } catch (Exception e){
            log.error(e.getMessage(), e)
            return [:]
        }
    }
}
