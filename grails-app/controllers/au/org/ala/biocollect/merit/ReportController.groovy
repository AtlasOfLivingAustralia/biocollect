package au.org.ala.biocollect.merit

class ReportController {

    static defaultAction = "dashboard"
    def webService, cacheService, searchService, metadataService, reportService, userService

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


}
