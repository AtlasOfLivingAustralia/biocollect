package au.org.ala.biocollect

import au.org.ala.biocollect.merit.MetadataService
import au.org.ala.biocollect.merit.ProjectService
import au.org.ala.biocollect.merit.SiteService
import au.org.ala.biocollect.merit.SpeciesService
import au.org.ala.biocollect.merit.WebService
import org.springframework.context.MessageSource
import java.nio.file.Files
//import org.springframework.util.FileCopyUtils
import java.nio.file.StandardCopyOption;

class ProjectActivityService {

    def grailsApplication
    WebService webService
    SpeciesService speciesService
    SiteService siteService
    ProjectService projectService
    MetadataService metadataService
    MessageSource messageSource
    UtilService utilService

    def getAllByProject(projectId, levelOfDetail = "", version = null){
        def params = '?'
        params += levelOfDetail ? "view=${levelOfDetail}&" : ''
        params += version ? "version=${version}&" : ''
        webService.getJson(grailsApplication.config.ecodata.service.url + '/projectActivity/getAllByProject/'+ projectId + params).list
    }

    def get(projectActivityId, levelOfDetail = "", version = null){
        def params = '?'
        params += levelOfDetail ? "view=${levelOfDetail}&" : ''
        params += version ? "version=${version}&" : ''
        webService.getJson(grailsApplication.config.ecodata.service.url + '/projectActivity/get/'+ projectActivityId + params)
    }

    def validate(props, projectActivityId) {
        def error = null
        def creating = !projectActivityId
        def published = props?.published.toString().toBoolean()

        def attributesAdded = []
        if (!creating) {
            def act = get(projectActivityId)
            if (act?.error) {
                return "invalid projectActivityId"
            }

            //when publishing always validate species, sites and pActivityFormName
            if (published) {
                if (!props?.species) {
                    attributesAdded.add("species")
                    props.species = act.species
                }
                if (!props?.speciesFields) {
                    attributesAdded.add("speciesFields")
                    props.speciesFields = act.speciesFields
                }
                if (!props?.sites) {
                    attributesAdded.add("sites")
                    props.sites = act.sites
                }
                if (!props?.pActivityFormName) {
                    attributesAdded.add("pActivityFormName")
                    props.pActivityFormName = act.pActivityFormName
                }
            }
        }

        if (props?.projectId) {
            def proj = projectService.get(props.projectId)
            if (proj?.error) {
                return "\"${props.projectId}\" is not a valid projectId"
            }
        } else if (creating) {
            //error, no description
            return "projectId is missing"
        }

        if (creating && !props?.status) {
            //error, no status
            return "status is missing"
        }

        if (creating && !props?.description) {
            //error, no description
            return "description is missing"
        }

        if (creating && !props?.name) {
            //error, no name
            return "name is missing"
        }

        if (creating && !props?.attribution) {
            //error, no attribution
            return "attribution is missing"
        }

        if (creating && !props?.startDate) {
            //error, no start date
            return "startDate is missing"
        }

        if(props?.speciesFields) {
            if(!props.speciesFields instanceof List ) {
                return "speciesFields is not a list"
            }

            for(Object speciesField : props.speciesFields) {
                if(!speciesField instanceof Map) {
                    return "At least one speciesField is not a Map"
                }

                if(!speciesField?.dataFieldName){
                    return "dataFieldName not set for speciesField " + speciesField?.label
                }

                if(!speciesField?.output){
                    return "output not set for speciesField " + speciesField?.label
                }

                String speciesTypeErrorMessage = validateSpeciesType(speciesField?.config);
                if(speciesTypeErrorMessage) {
                    return speciesTypeErrorMessage
                }
            }
        }

        if (props?.pActivityFormName) {
            def match = metadataService.activitiesModel().activities.findAll {
                it.name == props.pActivityFormName
            }
            if (match.size() == 0) {
                return "\"${props.pActivityFormName}\" is not a valid pActivityFormName"
            }
        } else if (published) {
            //error, no pActivityFormName
            return "pActivityFormName is missing"
        }

        if (props?.sites) {
            if (!(props.sites instanceof List)) {
                return "sites is not a list"
            } else if (props.sites.size() == 0) {
                return "no sites defined"
            } else {
                props.sites.each {
                    def site = siteService.get(it)
                    if (site?.error) {
                        error = "\"${it}\" is not a valid siteId"
                    }
                }
            }
        } else if (published) {
            //error, no sites
            return "sites are missing"
        }

        attributesAdded.each {
            props.remove(it)
        }

        error
    }

    String validateSpeciesType(species) {
        if (!(species instanceof Map)) {
            return "species is not a map"
        }

        if (species?.type) {
            if (species.type == 'SINGLE_SPECIES') {
                if (!species?.singleSpecies ||
                        !(species.singleSpecies instanceof Map) ||
                        !species.singleSpecies?.guid ||
                        !species.singleSpecies?.name) {
                    return "invalid single_species for species type SINGLE_SPECIES"
                }
            } else if (species.type == 'GROUP_OF_SPECIES'){
                if (!species?.speciesLists ||
                        !(species.speciesLists instanceof List)) {
                    return "invalid speciesLists for species type GROUP_OF_SPECIES"
                }
                if (species.speciesLists.size() == 0) {
                    return "no speciesLists defined for GROUP_OF_SPECIES"
                }
                species.speciesLists.each {
                    if (!(it instanceof Map) || !it?.listName || !it?.dataResourceUid) {
                        error = "invalid speciesLists item for species type GROUP_OF_SPECIES"
                    }
                }
            } else if (species.type != 'ALL_SPECIES' /*&& species.type != 'DEFAULT_SPECIES' */
            ) {
                return "\"${species.type}\" is not a vaild species type"
            }
        }
        // No return value, everything went ok
        return null;
    }

    def create(pActivity) {
        update('', pActivity)
    }

    def update(id, body) {
        def result = [:]

        def error = validate(body, id)
        if (error) {
            result.error = error
            result.detail = ''
        } else {
            result = webService.doPost(grailsApplication.config.ecodata.service.url + '/projectActivity/' + id, body)
        }

        result
    }

    def delete(id) {
        webService.doDelete(grailsApplication.config.ecodata.service.url + '/projectActivity/' + id)
    }

    /**
     * Get the species config for a field from project activity.
     * @param pActivity project activity instance
     * @param output Identity of field for specific configuration.
     * @param dataFieldName Identity of field for specific configuration.
     * @return Map - species config
     */
    Map getSpeciesConfigForProjectActivity(Map pActivity, String output, String dataFieldName){
        def specificFieldDefinition = pActivity?.speciesFields.find {
            it.dataFieldName == dataFieldName && it.output == output
        }

        (specificFieldDefinition) ?
                //New species per field configuration
                specificFieldDefinition.config :
                // Legacy per survey species configuration
                pActivity?.species
    }

    /**
     * Searches for a species name taking into account the species constraints setup for the survey.
     * @param id the id of the ProjectActivity (survey) being completed
     * @param q query string to search for
     * @param limit the maximum number of results to return
     * @param output Identity of field for specific configuration.
     * @param dataFieldName Identity of field for specific configuration.
     * @return json structure containing search results suitable for use by the species autocomplete widget on a survey form.
     */
    def searchSpecies(String id, String q, Integer limit, String output, String dataFieldName){
        def pActivity = get(id)
        Map speciesConfig =  getSpeciesConfigForProjectActivity(pActivity, output, dataFieldName)
        def result = searchSpeciesForConfig(speciesConfig, q, limit)
        formatSpeciesNameForSurvey(speciesConfig.speciesDisplayFormat , result)
        result
    }

    private Object searchSpeciesForConfig(Map speciesConfig, String q, Integer limit) {
        def result
        switch (speciesConfig?.type) {
            case 'SINGLE_SPECIES':
                result = speciesService.searchForSpecies(speciesConfig?.singleSpecies?.name, 1)
                break

            case 'ALL_SPECIES':
                result = speciesService.searchForSpecies(q, limit)
                break

            case 'GROUP_OF_SPECIES':
                def lists = speciesConfig?.speciesLists
                result = speciesService.searchSpeciesInLists(q, lists, limit)
                break
            default:
                result = [autoCompleteList: []]
                break
        }
        return result
    }

    List formatSpeciesNameForSurvey(String speciesDisplayFormat, Map data){
        data?.autoCompleteList?.each{
            it.name = formatSpeciesName(speciesDisplayFormat?:'SCIENTIFICNAME(COMMONNAME)', it)
        }
    }

    /**
     * formats a name into the specified format
     * if species does not match to a taxon, then mention it in name.
     * @param displayType
     * @param data
     * @return
     */
    String formatSpeciesName(String displayType, Map data){
        String name
        if(data.guid){
            switch (displayType){
                case 'COMMONNAME(SCIENTIFICNAME)':
                    if(data.commonName){
                        name = "${data.commonName} (${data.scientificName})"
                    } else {
                        name = "${data.scientificName}"
                    }
                    break;
                case 'SCIENTIFICNAME(COMMONNAME)':
                    if(data.commonName){
                        name = "${data.scientificName} (${data.commonName})"
                    } else {
                        name = "${data.scientificName}"
                    }

                    break;
                case 'COMMONNAME':
                    if(data.commonName){
                        name = "${data.commonName}"
                    } else {
                        name = "${data.scientificName}"
                    }
                    break;
                case 'SCIENTIFICNAME':
                    name = "${data.scientificName}"
                    break;
            }
        } else {
            // when no guid, append unmatched taxon string
            name = "${data.name} (Unmatched taxon)"
        }

        name
    }

    /**
     * Look for SINGLE_SPECIES for the given project activity
     * @param projectActivityId project activity identifier
     * @param output Identity of field for specific configuration.
     * @param dataFieldName Identity of field for specific configuration.
     * @return map containing species name, guid and isSingle field to indicate whether it's of a 'SINGLE_SPECIES' category.
     */

    Map getSingleSpecies(String projectActivityId, String output, String dataFieldName) {
        def pActivity = get(projectActivityId)

        def specificFieldDefinition = pActivity?.speciesFields.find {
            it.dataFieldName == dataFieldName && it.output == output
        }

        Map speciesFieldConfig =  (specificFieldDefinition) ?
                //New species per field configuration
                specificFieldDefinition.config :
                // Legacy per survey species configuration
                pActivity?.species


        Map result = [isSingle: false]

        switch (speciesFieldConfig?.type) {
            case 'SINGLE_SPECIES':
                result.isSingle = true

                if (speciesFieldConfig?.singleSpecies?.guid) {
                    result.name = formatSpeciesName(speciesFieldConfig.speciesDisplayFormat, speciesFieldConfig.singleSpecies)
                    result.guid = speciesFieldConfig.singleSpecies?.guid
                    result.scientificName = speciesFieldConfig.singleSpecies?.scientificName
                    result.commonName = speciesFieldConfig.singleSpecies?.commonName
                }
                break
        }

        result
    }

    boolean isEmbargoed(Map projectActivity) {
        projectActivity?.visibility?.embargoUntil && Date.parse("yyyy-MM-dd", projectActivity.visibility.embargoUntil).after(new Date())
    }

    /**
     * Convert facet names and terms to a human understandable text.
     * @param facets
     * @return
     */
    List getDisplayNamesForFacets(facets){
        facets?.each { facet ->
            facet.title = messageSource.getMessage("projectActivity.facets."+facet.name, [].toArray(), facet.name, Locale.default)
            facet.helpText = messageSource.getMessage("projectActivity.facets."+facet.name +".helpText", [].toArray(), "", Locale.default)
            facet.terms?.each{ term ->
                term.title = messageSource.getMessage("projectActivity.facets."+facet.name+"."+term.term, [].toArray(), term.name, Locale.default)
            }
        }
    }

    def sendAekosDataset(String downloadUrl, String jsonSubmissionPayload) {

        log.info "aekosSubmission downloading data from: " + downloadUrl

        URLConnection conn = new URL(downloadUrl).openConnection()
        conn.setConnectTimeout(10*1000);

        log.info ("Set read timeout: " + grailsApplication.config.aekos?.downloadReadTimeout?:20*1000)
        conn.setReadTimeout(grailsApplication.config.aekos?.downloadReadTimeout?:20*1000);

        def status = conn.responseCode

        // Instead of storing download in memory, it is now writing to physical file
   /*     BufferedInputStream bufferedInputStream = new BufferedInputStream(conn.getInputStream());

        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        FileCopyUtils.copy(bufferedInputStream, byteArrayOutputStream);*/


        def result = [:]
        if (status == 200 && grailsApplication.config.aekosSubmission?.url) {
            File tempFile = new File("/data/biocollect/temp/dataset-${UUID.randomUUID()}.zip")

            try {
                long readLen = Files.copy(conn.getInputStream(), tempFile.toPath(), StandardCopyOption.REPLACE_EXISTING)

                while (readLen > tempFile.length()) {
                    Thread.sleep(2000);
                }
                //  def is = StreamUtils.copyToByteArray(conn.getInputStream())
                //  def is = byteArrayOutputStream.toByteArray() //conn.getInputStream().getBytes()

                // External Aekos Submission Url
                def aekosUrl = grailsApplication.config.aekosSubmission?.url
                //?: "http://shared-uat.ecoinformatics.org.au:8080/shared-web/api/submission/create"

                log.info("Sending data to SHaRED url: " + aekosUrl)

                Map aekosParamMap = [:]
                List<Map> contentListMap = new ArrayList<Map>()

                Map jsonInputStreamMap = [:]
                //jsonInputStreamMap.put("contentIn", new ByteArrayInputStream(jsonSubmissionPayload.getBytes()))
                jsonInputStreamMap.put("contentIn", jsonSubmissionPayload)
                Map jsonInputInfo = [:]
                jsonInputInfo.put("contentType", "application/json")
                jsonInputInfo.put("contentName", "submissionJson")
                jsonInputStreamMap.put("contentInfo", jsonInputInfo)

                Map fileInputStreamMap = [:]
                Map fileInputStreamInfo = [:]
                fileInputStreamInfo.put("contentType", "application/zip")
                fileInputStreamInfo.put("contentName", "datasetZipFile")
                // fileInputStreamMap.put("contentIn", is)
                fileInputStreamMap.put("contentIn", tempFile)
                fileInputStreamMap.put("contentInfo", fileInputStreamInfo)

                contentListMap.add(jsonInputStreamMap)
                contentListMap.add(fileInputStreamMap)

                result = utilService.postMultipart(aekosUrl, aekosParamMap, contentListMap, null)

                log.info("Result from service: " + result)

                tempFile.delete()
            } catch (IOException e) {
                log.error("IO Exception has occurred.", e)
            } catch (Exception e) {
                log.error ("Exception occurred while trying to send data to AEKOS. ${e.getClass()} ${e.getMessage()}", e)
            }

        } else if (grailsApplication.config.aekosSubmission?.url) {
            result = [status: 504, error: "Timeout downloading data.zip."]
            log.info("Error occurred while downloading data: " + result + " Download status error: " + status)
        } else {
            result = [status: 404, error: "Aekos Submission Url is not configured"]
            log.info(result)
        }
        result
    }

}
