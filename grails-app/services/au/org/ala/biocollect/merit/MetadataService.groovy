package au.org.ala.biocollect.merit

import org.springframework.web.multipart.MultipartFile

import java.text.DateFormat
import java.text.SimpleDateFormat

import static org.apache.http.HttpStatus.*

class MetadataService {
    static DateFormat ISO8601 = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ")

    def grailsApplication, webService, cacheService, settingService, modelService

    def activitiesModel() {
        return cacheService.get('activity-model',{
            webService.getJson(grailsApplication.config.ecodata.service.url +
                '/metadata/activitiesModel')
        })
    }

    def annotatedOutputDataModel(type) {
        return cacheService.get('annotated-output-model'+type,{
            Collections.unmodifiableList(webService.getJson(grailsApplication.config.ecodata.service.url +
                    '/metadata/annotatedOutputDataModel?type='+type.encodeAsURL()))
        })
    }

    def updateActivitiesModel(model) {
        def result = webService.doPost(grailsApplication.config.ecodata.service.url +
                '/metadata/updateActivitiesModel', [model: model])
        cacheService.clear('activity-model')
        result
    }

    def programsModel() {
        def allPrograms = cacheService.get('programs-model',{
            webService.getJson(grailsApplication.config.ecodata.service.url +
                '/metadata/programsModel')
        })

        def programs = allPrograms
        def hubPrograms = SettingService.getHubConfig().supportedPrograms?:allPrograms.programs.findAll { !it.isMeritProgramme }.collect { it.name }

        if (hubPrograms) {
            programs = [programs:[]]
            allPrograms.programs.each { program ->
                if (!(program.name in hubPrograms)) {
                    def newProgram = new HashMap(program)
                    newProgram.readOnly = true
                    programs.programs << newProgram
                }
                else {
                    programs.programs << program
                }
            }
        }
        programs

    }

    def programModel(program) {
        return programsModel().programs.find {it.name == program}
    }

    def updateProgramsModel(model) {
        def result = webService.doPost(grailsApplication.config.ecodata.service.url +
                '/metadata/updateProgramsModel', [model: model])
        cacheService.clear('programs-model')
        result
    }

    def getThemesForProject(project) {
        def programMD = programsModel().programs.find { it.name == project.associatedProgram }
        if (programMD) {
            def subprogramMD = programMD.subprograms.find {it.name == project.associatedSubProgram }
            if (subprogramMD) {
                return subprogramMD.themes
            }
        }
        return []
    }

    def getActivityModel(name) {
        return activitiesModel().activities.find { it.name == name }
    }

    def getMainScoresForActivity(name) {
        return activitiesModel().find({ it.name = name })?.outputs?.collect { it.scoreName }
    }

    def getDataModelFromOutputName(outputName) {
        def activityName = getActivityModelName(outputName)
        return activityName ? getDataModel(activityName) : null
    }

    def getDataModel(template) {
        return cacheService.get(template + '-model',{
            webService.getJson(grailsApplication.config.ecodata.service.url +
                    "/metadata/dataModel/${template}")
        })
    }

    def updateOutputDataModel(model, template) {
        log.debug "updating template ${template}"
        //log.debug "model class is ${model.getClass()}"
        def result = webService.doPost(grailsApplication.config.ecodata.service.url +
                '/metadata/updateOutputDataModel/' + template, [model: model])
        cacheService.clear(template + '-model')
        result
    }

    def getActivityModelName(outputName) {
        return activitiesModel().outputs.find({it.name == outputName})?.template
    }

    def getModelNameFromType(type) {
        log.debug "Getting model name for ${type}"
        log.debug activitiesModel()
        return activitiesModel().activities.find({it.name == type})?.template
    }

    def activityTypesList(program = '') {
        cacheService.get('activitiesSelectList'+program, {
            String url = grailsApplication.config.ecodata.service.url + '/metadata/activitiesList'
            if (program) {
                url += '?program='+program.encodeAsURL()
            }
            def activityTypes = webService.getJson(url)
            activityTypes.collect {key, value -> [name:key, list:value]}.sort{it.name}

        })
    }

    /**
     * Returns a Map with key: activityName and value: <list of score definitions for the outputs that make up the activity>
     * Used to support the nomination of project output targets for various activity types.
     */
    def getOutputTargetsByActivity() {
        def activityScores = [:]
        def activitiesModel = activitiesModel()

        activitiesModel.activities.each { activity ->
            def scores = []

            activityScores[activity.name] = scores
            activity.outputs.each { outputName ->
                def matchedOutput = activitiesModel.outputs.find {
                    output -> outputName == output.name
                }
                if (matchedOutput && matchedOutput.scores) {
                    matchedOutput.scores.each {
                        if (it.isOutputTarget) {
                            scores << (it << [outputName : outputName])
                        }
                    }
                }
            }
        }
        return activityScores
    }

    /**
     * Returns a 3 level hierarchy given by:
     *  a map keyed by activityName where each value is:
     *      a map keyed by outputName where each value is:
     *          a list of score definitions that are output targets
     * Only includes activities and outputs if they contain output targets.
     * Used to support the nomination of project output targets for various activity types.
     */
    def getOutputTargetsByOutputByActivity() {
        def outputTargetMetadata = [:]
        def activitiesModel = activitiesModel()

        activitiesModel.activities.each { activity ->
            def outputs = [:]

            activity.outputs.each { outputName ->
                def scores = []

                def matchedOutput = activitiesModel.outputs.find {
                    output -> outputName == output.name
                }
                if (matchedOutput && matchedOutput.scores) {
                    matchedOutput.scores.each {
                        if (it.isOutputTarget && (it.aggregationType in ['SUM', 'AVERAGE', 'COUNT'])) {
                            scores << it
                        }
                    }
                    // only add the output if it has targets
                    if (scores) {
                        outputs[outputName] = scores
                    }
                }
            }
            // only add the activity if it has outputs that have targets
            if (outputs) {
                outputTargetMetadata[activity.name] = outputs
            }
        }
        return outputTargetMetadata
    }



    def clearEcodataCache() {
        webService.get(grailsApplication.config.ecodata.service.url + "/admin/clearMetadataCache")
    }

    def outputTypesList() {
        outputTypes
    }

    def getAccessLevels() {
        return cacheService.get('accessLevels',{
            webService.getJson(grailsApplication.config.ecodata.service.url +  "/permissions/getAllAccessLevels?baseLevel="+RoleService.PROJECT_PARTICIPANT_ROLE)
        })
    }

    def getLocationMetadataForPoint(lat, lng) {
        cacheService.get("spatial-point-${lat}-${lng}", {
            webService.getJson(grailsApplication.config.ecodata.service.url + "/metadata/getLocationMetadataForPoint?lat=${lat}&lng=${lng}")
        })
    }

    def getReportCategories() {
        return cacheService.get('report-categories',{
            def categories = new LinkedHashSet()
            activitiesModel().outputs.each { output ->
                output.scores.each { score ->
                    def cat = score.category?.trim()
                    if (cat) {
                        categories << cat
                    }
                }
            }
            categories
        })
    }

    def getGeographicFacetConfig() {
        cacheService.get("geographic-facets", {

            def results = [:].withDefault{[:]}

            def facetConfig = webService.getJson(grailsApplication.config.ecodata.service.url + "/metadata/getGeographicFacetConfig")
            facetConfig.grouped.each { k, v ->
                v.each { name, fid ->
                    def objects = webService.getJson(grailsApplication.config.spatial.baseURL + '/ws/objects/'+fid)
                    results[k] << [(objects[0].fieldname):objects[0]] // Using the fieldname instead of the name for grouped facets is a temp workaround for the GER.
                }

            }

            facetConfig.contextual.each { name, fid ->
                def objects = webService.getJson(grailsApplication.config.spatial.baseURL + '/ws/objects/'+fid)
                objects.each {
                    results[name] << [(it.name):it]
                }
            }

            results
        })
    }

    /**
     * Delegates to the ecodata extractOutputDataFromExcelOutputTemplate service to convert an excel workbook into
     * a Map of output data property value pairs.
     * @return returns a map with [status:statusCode, error:errorMessage (if there was an error), data:the data (if there was no error)]
     */
    Map extractOutputDataFromExcelOutputTemplate(Map params, MultipartFile file) {
        def url = grailsApplication.config.ecodata.service.url + '/metadata/extractOutputDataFromExcelOutputTemplate'
        def data = webService.postMultipart(url, params, file, 'data')

        def result
        if (data.error || data.status != SC_OK) {
            result = [status:data.status, error:data.error?:'No data was found that matched the columns in this table, please check the template you used to upload the data. ']
        }
        else {
            result = [status:SC_OK, data:data.content.data]
        }
        result
    }

    List<Map> getOutputTargetScores() {
        cacheService.get('output-targets', {
            List<Map> scores = getScores(false)
            scores.findAll { it.isOutputTarget }.collect {
                [scoreId: it.scoreId, label: it.label, entityTypes: it.entityTypes, description: it.description, outputType: it.outputType]
            }
        })
    }

    List<Map> getScores(boolean includeConfig) {
        cacheService.get("scores-${includeConfig}", {
            String url = grailsApplication.config.ecodata.service.url + "/metadata/scores"
            if (includeConfig) {
                url+='?view=config'
            }
            webService.getJson(url)
        })
    }

    /**
     * Get a map of default values for a model.
     * <p>
     * Default values can be
     *
     * @param model
     * @return
     */
    Map getDefaultData(outputModels) {
        def defaults = [:]
        outputModels.each { name, model ->
            model?.dataModel.each { dm ->
                def value = modelService.evaluateDefaultDataForDataModel(dm)
                if(value){
                    defaults[dm.name] = value
                }
            }
        }
        return defaults
    }

    boolean isOptionalContent(String contentName, String program, String subProgram = '') {
        Map config = getProgramConfiguration(program, subProgram)
        return contentName in (config.optionalProjectContent?:[])
    }

    Map getProgramConfiguration(String programName, String subProgramName = null) {
        def program = programModel(programName)
        if (!program) {
            throw new IllegalArgumentException("No program exists with name ${programName}")
        }
        def config = new HashMap(program)
        config.remove('subprograms')

        if (subProgramName) {
            def subProgram = program.subprograms?.find{it.name == subProgramName}
            if (!subProgram) {
                throw new IllegalArgumentException("No subprogram exists for program ${programName} with name ${subProgramName}")
            }

            if (subProgram.overridesProgramData) {
                config.putAll(subProgram)
            }
        }

        config
    }

}
