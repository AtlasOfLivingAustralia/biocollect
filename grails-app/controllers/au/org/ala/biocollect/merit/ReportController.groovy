package au.org.ala.biocollect.merit

import grails.converters.JSON
import org.grails.web.json.JSONArray
import pl.touk.excel.export.WebXlsxExporter

class ReportController {

    static allowedMethods = ['downloadReport': 'POST']

    static defaultAction = "dashboard"
    def webService, cacheService, searchService, metadataService, reportService, userService, settingService

    @PreAuthorise(accessLevel='hubAdmin')
    def chartList() {}

    def loadReport() {
        forward action: params.report+'Report', params:params
    }

    def dashboardReport() {

        def defaultCategory = "Not categorized"
        def categories = metadataService.getReportCategories()
        // The _ parameter is appended by jquery ajax calls and will stop the report contents from being cached.
        params.remove("_")
        def results = searchService.dashboardReport(params)
        def scores = results.outputData

        def scoresByCategory = scores.groupBy{
            (it.score.category?:defaultCategory)
        }

        def doubleGroupedScores = [:]
        // Split the scores up into 2 columms for display.
        scoresByCategory.each { category, categoryScores ->

            categoryScores.sort{it.score.outputName}
            def previousOutput = ""
            def runningHeights = categoryScores.collect {
                def height = DashboardTagLib.estimateHeight(it.score)
                if (it.score.outputName != previousOutput) {
                    height += 60 // Account for the output name header, padding etc.
                    previousOutput = it.score.outputName
                }
                height
            }
            def totalHeight = runningHeights.sum()
            def columns = [[], []]

            def runningHeight = 0
            // Iterating backwards to bias the left hand column.
            for (int i=0 ; i<categoryScores.size(); i++) {

                def idx = runningHeight <= (totalHeight/2) ? 0 : 1
                runningHeight += runningHeights[i]

                columns[idx] << categoryScores[i]
            }


            def columnsGroupedByOutput = [columns[0].groupBy{it.score.outputName}, columns[1].groupBy{it.score.outputName}]
            doubleGroupedScores.put(category, columnsGroupedByOutput)
        }
        if (scoresByCategory.keySet().contains(defaultCategory)) {
            categories << defaultCategory
        }

        def sortedCategories = []
        sortedCategories.addAll(categories)
        sortedCategories.sort()

        def model = [categories:categories.sort(), scores:doubleGroupedScores, metadata:results.metadata]

        render view:'_dashboard', model:model

    }

    def programReport() {

        if (userService.doesUserHaveHubRole(RoleService.PROJECT_ADMIN_ROLE)) {

            // This needs to be improved to be program specific.
            reportService.programReport("")
        }
        else {
            render status:401, text: "Unauthorized"
        }

    }

    @PreAuthorise(accessLevel='hubAdmin')
    def getChartConfig() {
        String jsonStr = settingService.getSettingText(SettingPageType.DASHBOARD_CONFIG) as String

        def jsonSlurper = new groovy.json.JsonSlurper()
        def model = jsonSlurper.parseText(jsonStr)

        render model as JSON
    }

    def populateAssociatedPrograms() {
        JSONArray associatedPrograms = SettingService.getHubConfig().supportedPrograms
        render associatedPrograms as JSON
    }

    def populateElectorates() {
        def SPATIAL_URL = grailsApplication.config.spatial.baseURL

        String uniqueIdResponse = new URL(SPATIAL_URL + "/ws/objects/cl958")?.text

        def jsonResponse = new groovy.json.JsonSlurper()
        def model = jsonResponse.parseText(uniqueIdResponse)

        render model as JSON
    }

    @PreAuthorise(accessLevel='hubAdmin')
    def genericReport() {
        Map body = request.JSON

        if (body) {
            def result = reportService.genericReport(body)
            render text: result as JSON, contentType: 'application/json'
        } else {
            render text: [message: "Request body missing."] as JSON, status: 400, contentType: 'application/json'
        }
    }

    def downloadReport() {
        Map body = request.JSON
        if (body) {
            def headers = grailsApplication.config.report.download.collect { it.header }
            def withProperties = grailsApplication.config.report.download.collect { it.property }

            new WebXlsxExporter().with {
                setResponseHeaders(response, 'report.xlsx')
                body.each { String sheetName, List rows ->
                    sheet (sheetName).with {
                        fillHeader(headers)
                        add(rows, withProperties)
                    }
                }
                save(response.outputStream)
            }

            response.outputStream.flush()
        } else {
            render text: [message: "Request body missing."] as JSON, status: 400, contentType: 'application/json'
        }

    }
}
