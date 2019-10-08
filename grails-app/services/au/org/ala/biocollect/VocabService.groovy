package au.org.ala.biocollect

//import grails.plugin.cache.Cacheable
import org.springframework.cache.annotation.Cacheable
import groovy.json.JsonSlurper

class VocabService {

  @Cacheable('vocabListCache')
  def getVocabValues () {
      def model = [fieldsOfResearch: new JsonSlurper().parseText(getClass().getResourceAsStream("/data/FieldsOfResearch.json").getText()),
                   socioEconomicObjectives: new JsonSlurper().parseText(getClass().getResourceAsStream("/data/SocioEconomicObjectives.json").getText()),
                   ecologicalResearch: new JsonSlurper().parseText(getClass().getResourceAsStream("/data/EcologicalResearch.json").getText()),
                   anthropogenic: new JsonSlurper().parseText(getClass().getResourceAsStream("/data/AnthropogenicDisturbances.json").getText()),
                   conservationManagement: new JsonSlurper().parseText(getClass().getResourceAsStream("/data/ConservationManagement.json").getText()),
                   plantGroups: new JsonSlurper().parseText(getClass().getResourceAsStream("/data/PlantGroups.json").getText()),
                   animalGroups: new JsonSlurper().parseText(getClass().getResourceAsStream("/data/AnimalGroups.json").getText()),
                   environmentalFeatures: new JsonSlurper().parseText(getClass().getResourceAsStream("/data/EnvironmentalFeatures.json").getText()),
                   samplingDesign: new JsonSlurper().parseText(getClass().getResourceAsStream("/data/SamplingDesign.json").getText()),
                   observationMeasurements: new JsonSlurper().parseText(getClass().getResourceAsStream("/data/ObservationMeasurements.json").getText()),
                   observedAttributes: new JsonSlurper().parseText(getClass().getResourceAsStream("/data/ObservedAttributes.json").getText()),
                   identificationMethod: new JsonSlurper().parseText(getClass().getResourceAsStream("/data/IdentificationMethod.json").getText())
      ]
      return model
  }
}
