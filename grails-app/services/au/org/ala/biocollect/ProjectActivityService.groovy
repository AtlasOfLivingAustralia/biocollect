package au.org.ala.biocollect

import au.org.ala.biocollect.merit.*
import au.org.ala.biocollect.merit.hub.HubSettings
import au.org.ala.web.AuthService
import org.springframework.context.MessageSource

import java.nio.file.Files
import java.nio.file.StandardCopyOption
//import org.springframework.util.FileCopyUtils
class ProjectActivityService {

    public static final SPECIAL_FACETS = [
            GeoMap: [
                    type : 'geoMap',
                    total: 0,
                    terms: [[term: 'active', count: 0], [term: 'completed', count: 0]]
            ],
            Date: [
                    type : 'date',
                    total: 0,
                    terms: [[fromDate: '', toDate: '']]
            ]
    ]


    def grailsApplication
    WebService webService
    SpeciesService speciesService
    SiteService siteService
    ProjectService projectService
    MetadataService metadataService
    MessageSource messageSource
    UtilService utilService
    AuthService authService
    CacheService cacheService
    SettingService settingService

    def getAllByProject(projectId, levelOfDetail = "", version = null, stats = false) {
        def params = '?'
        params += levelOfDetail ? "view=${levelOfDetail}&" : ''
        params += version ? "version=${version}&" : ''
        params += "stats=${stats}"
        webService.getJson(grailsApplication.config.ecodata.service.url + '/projectActivity/getAllByProject/' + projectId + params).list
    }

    def get(projectActivityId, levelOfDetail = "", version = null) {
        def params = '?'
        params += levelOfDetail ? "view=${levelOfDetail}&" : ''
        params += version ? "version=${version}&" : ''
        webService.getJson(grailsApplication.config.ecodata.service.url + '/projectActivity/get/' + projectActivityId + params)
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

        if (props?.speciesFields) {
            if (!props.speciesFields instanceof List) {
                return "speciesFields is not a list"
            }

            for (Object speciesField : props.speciesFields) {
                if (!speciesField instanceof Map) {
                    return "At least one speciesField is not a Map"
                }

                if (!speciesField?.dataFieldName) {
                    return "dataFieldName not set for speciesField " + speciesField?.label
                }

                if (!speciesField?.output) {
                    return "output not set for speciesField " + speciesField?.label
                }

                String speciesTypeErrorMessage = validateSpeciesType(speciesField?.config);
                if (speciesTypeErrorMessage) {
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
            } else if (species.type == 'GROUP_OF_SPECIES') {
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
    Map getSpeciesConfigForProjectActivity(Map pActivity, String output, String dataFieldName) {
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
    def searchSpecies(String id, String q, Integer limit, String output, String dataFieldName) {
        def pActivity = get(id)
        Map speciesConfig = getSpeciesConfigForProjectActivity(pActivity, output, dataFieldName)
        def result = speciesService.searchSpeciesForConfig(speciesConfig, q, limit)
        speciesService.formatSpeciesNameInAutocompleteList(speciesConfig.speciesDisplayFormat, result)
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

        Map speciesFieldConfig = (specificFieldDefinition) ?
                //New species per field configuration
                specificFieldDefinition.config :
                // Legacy per survey species configuration
                pActivity?.species


        Map result = [isSingle: false]

        switch (speciesFieldConfig?.type) {
            case 'SINGLE_SPECIES':
                result.isSingle = true

                if (speciesFieldConfig?.singleSpecies?.guid) {
                    result.name = speciesService.formatSpeciesName(speciesFieldConfig.speciesDisplayFormat, speciesFieldConfig.singleSpecies)
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
     * This function translates view name to page name. Page name is then used in hub configuration to get the facet
     * configuration for that page.
     * @param view
     * @return
     */
    String getDataPagePropertyFromViewName(String view) {
        String name
        switch (view) {
            case 'myrecords':
                name = 'myRecords'
                break

            case 'project':
                name = 'project'
                break

            case 'projectrecords':
                name = 'projectRecords'
                break

            case 'myprojectrecords':
                name = 'myProjectRecords'
                break

            case 'userprojectactivityrecords':
                name = 'userProjectActivityRecords'
                break

            case 'allrecords':
                name = 'allRecords'
                break
        }

        name
    }

    def sendAekosDataset(String downloadUrl, String jsonSubmissionPayload) {

        log.info "aekosSubmission downloading data from: " + downloadUrl

        URLConnection conn = new URL(downloadUrl).openConnection()
        conn.setConnectTimeout(10 * 1000);

        log.info("Set read timeout: " + grailsApplication.config.aekos?.downloadReadTimeout ?: 20 * 1000)
        conn.setReadTimeout(grailsApplication.config.aekos?.downloadReadTimeout ?: 20 * 1000);

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
                log.error("Exception occurred while trying to send data to AEKOS. ${e.getClass()} ${e.getMessage()}", e)
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

    /**
     * Add facets that has special function like date, geoMap etc.
     * @param facets
     * @return
     */
    List addSpecialFacets(List facets, List facetConfig) {
        facetConfig?.eachWithIndex{ Map config, int i ->
            if(HubSettings.isFacetConfigSpecial(config)){
                Map facet = SPECIAL_FACETS[config.facetTermType].clone()
                facet.name = config.name
                if(i >= 0  && i <= facets.size()){
                    facets.add(i, facet)
                } else {
                    facets.add(facet)
                }
            }
        }

        facets
    }

    /**
     *
     * @return
     */
    List getDefaultActivity(){
        cacheService.get('default-facets-for-data-pages', {
            webService.getJson(grailsApplication.config.ecodata.service.url + '/activity/getDefaultFacets')
        })
    }

    /**
     * Get survey methods from settings page. This function converts comma separated content stored in settings page to a list.
     * @return
     */
    List getSurveyMethods(){
        String urlPath = grailsApplication.config.app.default.hub ?: "ala"
        String key = grailsApplication.config.settings.surveyMethods
        String content = settingService.getSettingText(urlPath, key)
        content = utilService.removeHTMLTags(content)
        List entries = []
        if(content?.trim()){
            entries = content?.split(',')
            entries = entries?.collect { it.trim() }
        }

        entries
    }
}