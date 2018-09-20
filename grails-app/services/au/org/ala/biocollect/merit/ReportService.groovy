package au.org.ala.biocollect.merit

import au.org.ala.biocollect.DateUtils
import grails.converters.JSON
import org.joda.time.DateTime
import org.joda.time.DateTimeZone
import org.joda.time.Period
import org.springframework.cache.annotation.Cacheable


class ReportService {

    public static final String REPORT_APPROVED = 'published'
    public static final String REPORT_SUBMITTED = 'pendingApproval'
    public static final String REPORT_NOT_APPROVED = 'unpublished'

    public static final String REEF_2050_PLAN_ACTION_REPORTING_ACTIVITY_TYPE = 'Reef 2050 Plan Action Reporting'

    def grailsApplication
    def webService
    def userService
    def projectService
    def authService
    def searchService
    def commonService
    def documentService
    def metadataService
    def activityService
    def messageSource

    private static int DEFAULT_REPORT_DAYS_TO_COMPLETE = 43

    /**
     * This method supports automatically creating reporting activities for a project that re-occur at defined intervals.
     * e.g. a stage report once every 6 months or a green army monthly report once per month.
     * Activities will only be created when no reporting activity of the correct type exists within each period.
     * @param projectId identifies the project.

     */
    def regenerateAllStageReportsForProject(String projectId, Integer periodInMonths = 6, boolean alignToCalendar = false, Integer weekDaysToCompleteReport = null) {

        def project = projectService.get(projectId, 'all')
        log.info("Processing project "+project.name)
        def period = Period.months(periodInMonths)

        def reports = (project.reports?:[]).sort{it.toDate}

        DateTime startDate = DateUtils.parse(project.plannedStartDate).withZone(DateTimeZone.default)
        DateTime endDate = DateUtils.parse(project.plannedEndDate).withZone(DateTimeZone.default)

        DateTime periodStartDate = null
        int stage = 1
        for (int i=reports.size()-1; i>=0; i--) {
            if (isSubmittedOrApproved(reports[i])) {
                periodStartDate = DateUtils.parse(reports[i].toDate).withZone(DateTimeZone.default)
                stage = i+2 // Start at the stage after the submitted or approved one
                break
            }
        }

        if (!periodStartDate) {
            periodStartDate = startDate
        }

        // The first period start date  (to be modified) should be aligned to the end date of the previous report or
        // the project start date if it is the first report.
        DateTime reportFromDate = periodStartDate

        if (alignToCalendar) {
            periodStartDate = DateUtils.alignToPeriod(periodStartDate, period)
        }

        log.info "Regenerating stages starting from stage: "+stage+ ", starting from: "+periodStartDate+" ending at: "+endDate
        while (periodStartDate < endDate.minusDays(1)) {
            def periodEndDate = periodStartDate.plus(period)

            def report = [
                    fromDate:DateUtils.format(reportFromDate.withZone(DateTimeZone.UTC)),
                    toDate:DateUtils.format(periodEndDate.withZone(DateTimeZone.UTC)),
                    type:'Activity',
                    projectId:projectId,
                    name:'Stage '+stage,
                    description:'Stage '+stage+' for '+project.name
            ]
            if (weekDaysToCompleteReport) {
                report.dueDate = DateUtils.format(periodEndDate.plusDays(weekDaysToCompleteReport).withZone(DateTimeZone.UTC))
            }

            if (reports.size() >= stage) {
                report.reportId = reports[stage-1].reportId
                // Only do the update if the report details have changed.
                if (!report.equals(reports[stage-1])) {
                    log.info("Updating report " + report.name + " for project " + project.projectId)
                    log.info("name: " + reports[stage - 1].name + " - " + report.name)
                    log.info("fromDate: " + reports[stage - 1].fromDate + " - " + report.fromDate)
                    log.info("toDate: " + reports[stage - 1].toDate + " - " + report.toDate)
                    update(report)
                }
            }
            else {
                log.info("Creating report "+report.name+" for project "+project.projectId)
                create(report)
            }
            stage++
            periodStartDate = periodEndDate
            reportFromDate = periodStartDate
        }

        // Delete any left over reports.
        for (int i=stage-1; i<reports.size(); i++) {
            log.info("Deleting report "+reports[i].name+" for project "+project.projectId)
            delete(reports[i].reportId)
        }
        log.info("***********")
    }

    /**
     * Returns the latest date at which a period exists that is covered by an approved or submitted stage report.
     * @param reports the reports to check.
     * @return a ISO 8601 formatted date string
     */
    public String latestSubmittedOrApprovedReportDate(List<Map> reports) {
        String lastSubmittedOrApprovedReportEndDate = null
        reports?.each { report ->
            if (isSubmittedOrApproved(report)) {
                if (report.toDate > lastSubmittedOrApprovedReportEndDate) {
                    lastSubmittedOrApprovedReportEndDate = report.toDate
                }
            }
        }
        return lastSubmittedOrApprovedReportEndDate
    }


    /**
     * Returns true if any report in the supplied list has been submitted or approval or approved.
     * @param reports the List of reports to check
     * @return true if any report in the supplied list has been submitted or approval or approved.
     */
    boolean includesSubmittedOrApprovedReports(List reports) {
        return (reports?.find {isSubmittedOrApproved(it)} != null)
    }

    boolean isSubmittedOrApproved(Map report) {
        return report.publicationStatus == REPORT_SUBMITTED || report.publicationStatus == REPORT_APPROVED
    }

    Map get(String reportId) {
        if (!reportId) {
            throw new IllegalArgumentException("Missing parameter reportId")
        }
        def resp = webService.getJson(grailsApplication.config.ecodata.baseURL+"/ws/report/${reportId}")
        resp
    }

    def delete(String reportId) {
        if (!reportId) {
            throw new IllegalArgumentException("Missing parameter reportId")
        }
        webService.doDelete(grailsApplication.config.ecodata.baseURL+"/ws/report/${reportId}")
    }

    def getReportsForProject(String projectId) {
        webService.getJson(grailsApplication.config.ecodata.baseURL+"/ws/project/${projectId}/reports")
    }

    def getReportingHistoryForProject(String projectId) {
        def reports = getReportsForProject(projectId)

        def history = []
        reports.each { report ->

            report.statusChangeHistory.each { change ->
                def changingUser = authService.getUserForUserId(change.changedBy, false)
                def displayName = changingUser?changingUser.displayName:'unknown'
                history << [name:report.name, date:change.dateChanged, who:displayName, status:change.status]
            }
        }
        history.sort {it.dateChanged}
        history
    }

    Map findMostRecentlySubmittedOrApprovedReport(List reports) {
        reports.max{ isSubmittedOrApproved(it) ? it.toDate : ''}
    }

    def submit(String reportId) {
        webService.doPost(grailsApplication.config.ecodata.baseURL+"/ws/report/submit/${reportId}", [:])
    }

    def approve(String reportId, String reason) {
        webService.doPost(grailsApplication.config.ecodata.baseURL+"/ws/report/approve/${reportId}", [comment:reason])
    }

    def reject(String reportId, String category, String reason) {
        webService.doPost(grailsApplication.config.ecodata.baseURL+"/ws/report/returnForRework/${reportId}", [comment:reason, category:category])
    }

    def create(report) {
        webService.doPost(grailsApplication.config.ecodata.baseURL+"/ws/report/", report)
    }

    def update(report) {
        webService.doPost(grailsApplication.config.ecodata.baseURL+"/ws/report/"+report.reportId, report)
    }

    def findReportsForUser(String userId) {

        def reports = webService.doPost(grailsApplication.config.ecodata.baseURL+"/ws/user/${userId}/reports", [:])


        if (reports.resp && !reports.error) {
            return reports.resp.projectReports.groupBy{it.projectId}
        }

    }

    def findReportsForOrganisation(String organisationId) {

        def reports = webService.doPost(grailsApplication.config.ecodata.baseURL+"/ws/organisation/${organisationId}/reports", [:])

        if (reports.resp && !reports.error) {
            return reports.resp
        }
        return []
    }

    /**
     * Returns the report that spans the period including the supplied date
     * @param isoDate an ISO8601 formatted date string.
     * @param reports the reports to check.
     */
    Map findReportForDate(String isoDate, List<Map> reports) {
        reports.find{it.fromDate < isoDate && it.toDate >= isoDate}
    }

    public Number filteredProjectCount(List<String> filter, String searchTerm) {
        def result = searchService.allProjects([fq:filter], searchTerm)
        result?.hits?.total ?: 0
    }

    public Map<String, Number> filteredInvestment(List<String> filter, String searchTerm = null, String investmentType = null) {

        int BATCH_SIZE = 100
        def result = searchService.allProjects([fq:filter], searchTerm)
        BigDecimal dollarsInvested = new BigDecimal(0)
        int count = result?.hits?.total ?: 0
        int matchCount = 0
        int processed = 0
        while (processed < count) {
            result.hits.hits?.each { hit ->

                def budget = hit._source.custom?.details?.budget
                if (budget) {
                    if (investmentType) {
                        def investmentRow = budget.rows.find { it.shortLabel == investmentType }
                        if (investmentRow) {
                            dollarsInvested += (investmentRow.rowTotal as BigDecimal)
                            matchCount++
                        }
                    }
                    else {
                        dollarsInvested += budget.overallTotal as BigDecimal
                        matchCount++
                    }
                }
                processed++

            }
            result = searchService.allProjects([fq:filter, offset:processed, max:BATCH_SIZE])
        }
        [count:matchCount, investment:dollarsInvested]
    }

    public Map<String, Number> getNumericScores(List<String> scores, List<String> filter = null) {

        def results = searchService.reportOnScores(scores,filter)

        Map<String, Number> values = scores.collectEntries { score ->
            def result = results.outputData?.find {it.groupTitle == score}
            def value = 0
            if (result && result.results) {
                value = result.results[0].result
            }
            [(score):(value as Number)]
        }
        values
    }

    public Number getNumericScore(String score, List<String> filter = null) {

        def results = searchService.reportOnScores([score], filter)

        def result = results.outputData?.find {it.label == score}
        def value = 0
        if (result) {
            value = result.result?.result ?: 0
        }
        value as Number

    }

    public Number filterGroupedScore(String score, String groupToFilter, List<String> filters = null) {
        def results = searchService.reportOnScores([score], filters)
        def value = 0
        if (results.outputData && results.outputData[0].result?.groups) {
            def result = results.outputData[0].result.groups.find{it.group == groupToFilter}
            if (result) {
                value = result.results[0].result
            }
            else {
                def section = results.outputData[0].results.find{it.result && it.result[groupToFilter]}
                if (section && section.result[groupToFilter]) {
                    value = section.result[groupToFilter]
                }
            }
        }
        value
    }

    public Number outputTarget(String scoreLabel, List<String> filters) {
        def reportParams = [scores:scoreLabel]
        if (filters) {
            reportParams.fq = filters
        }
        def url = grailsApplication.config.ecodata.baseURL + '/ws/search/targetsReportByScoreLabel' + commonService.buildUrlParamsFromMap(reportParams)
        def results = webService.getJson(url, 300000)
        if (!results || !results.targets) {
            return 0
        }
        BigDecimal result = new BigDecimal(0)
        results.targets.each {k, v ->
            if (v[scoreLabel]) {
                result = result.plus(new BigDecimal(v[scoreLabel].total))
            }
        }
        return result
    }

    def findHomePageNominatedProjects(Integer max = 10, Integer offset = 0, Boolean omitSource = false) {
        Map searchParams = [max:max, offset:offset, sort:'lastUpdated', order:'desc']
        if (omitSource) {
            searchParams.omitSource = true
        }
        def queryString =  "custom.details.caseStudy:true OR promoteOnHomePage:true"
        searchService.allProjects(searchParams, queryString)
    }

    Map findPotentialHomePageImages(Integer max = 10, Integer offset = 0) {

        def projectIds = findHomePageNominatedProjects(10000, 0, true)?.hits.hits.collect{it._id}

        def criteria = [
                type:'image',
                public:true,
                thirdPartyConsentDeclarationMade: true,
                max:max,
                offset:offset,
                projectId:projectIds,
                sort:'dateCreated',
                order:'desc'
        ]
        documentService.search(criteria)
    }

    @Cacheable('homePageImages')
    List homePageImages() {
        def max = 5
        def criteria = [
                type:'image',
                public:true,
                thirdPartyConsentDeclarationMade: true,
                max:1,
                offset:0,
                labels:'hp-y'
        ]

        def count = documentService.search(criteria).count
        criteria.offset = (int)Math.floor(Math.random()*count)
        criteria.max = max
        criteria.offset = Math.min(criteria.offset, count-max)
        def images = documentService.search(criteria).documents ?: []

        def projectIds = images.collect {it.projectId}
        def projects = projectService.search([projectId:projectIds])?.resp?.projects ?: []

        images.collect {[name:it.name, attribution:it.attribution, projectName:projects.find{project -> it.projectId == project.projectId}?.name?:'', url:it.url, projectId:it.projectId]}
    }

    Map performanceReportModel(String id, int version) {
        Map report = null
        if (id) {
            report = get(id)
        }

        String additionalPracticeQuestionV1 = "The regional NRM organisation has met all the expected practices and has additional practices in place."
        String additionalPracticeQuestionV2 = "The regional NRM organisation also has the following additional practices. (please list)"

        String additionalPracticeQuestion = version == 1 ? additionalPracticeQuestionV1 : additionalPracticeQuestionV2

        List themes = ["Regional NRM Organisation Governance", "Australian Government NRM Delivery"]
        List defaultConstraints = ["", "Yes", "No"]
        List constraintsWithNA = ["", "N/A", "Yes", "No"]
        List sections = [
                [title:"1. Organisational Governance",
                 name:"organisationalGovernance",
                 theme:themes[0],
                 questions:[
                         [text:"1.1\tThe regional NRM organisation is complying with governance responsibilities according to its statutory/incorporation or other legal obligations, including Work, Health and Safety obligations.",name:'1_1', constraints:defaultConstraints],
                         [text:"1.2\tThe regional NRM organisation has a process in place for formally reviewing the performance and composition of the regional NRM organisation’s board of directors.",name:'1_2', constraints:defaultConstraints],
                         [text:"1.3\tThe regional NRM organisation has organisational decision making processes that are transparent and communicated regularly with the local community.",name:'1_3', constraints:defaultConstraints],
                         [text:"1.4\tThe regional NRM organisation ensures all staff and board of directors demonstrate Indigenous cultural awareness.",name:'1_4', constraints:constraintsWithNA],
                         [text:"1.5\tThe regional NRM organisation has structures and processes in place to regularly communicate organisational and project performance achievements.",name:'1_5', constraints:defaultConstraints]],
                 additionalPracticeQuestion:[text:"1.6\t${additionalPracticeQuestion}",name:'1_6', constraints:defaultConstraints]],
                [title:"2. Financial Governance",
                 name:"financialGovernance",
                 theme:themes[0],
                 questions:[
                         [text:"2.1\tThe regional NRM organisation is complying with financial responsibilities according to its statutory/incorporation or other legal obligations.",name:'2_1', constraints:defaultConstraints],
                         [text:"2.2\tThe regional NRM organisation is complying with Australian Government NRM contractual obligations for project financial reporting and management, accurately and on time, including acquittal of funding as required.",name:'2_2', constraints:defaultConstraints],
                         [text:"2.3\tThe regional NRM organisation has annual financial reports that are publicly available.",name:'2_3', constraints:defaultConstraints]],
                 additionalPracticeQuestion:[text:"2.4\t${additionalPracticeQuestion}",name:'2_4', constraints:defaultConstraints]],
                [title:"3. Regional NRM plans",
                 theme:themes[1],
                 name:"regionalNRMPlans",
                 questions:[
                         [text:"3.1\tThe regional NRM organisation has a regional NRM plan that provides the strategic direction to NRM activity within the region based on best available scientific, economic and social information.",name:'3_1', constraints:defaultConstraints],
                         [text:"3.2\tThe regional NRM organisation has a regional NRM plan that demonstrates strategic alignment with Australian Government and state/territory NRM policies and priorities.",name:'3_2', constraints:defaultConstraints],
                         [text:"3.3\tThe regional NRM organisation has a regional NRM plan that has been developed with comprehensive and documented participation of the local community.",name:'3_3', constraints:defaultConstraints],
                         [text:"3.4\tThe regional NRM organisation has a regional NRM plan with clear priorities, outcomes and activities to achieve those outcomes.",name:'3_4', constraints:defaultConstraints],
                         [text:"3.5\tThe regional NRM organisation has a regional NRM plan that clearly articulates Indigenous land and sea management aspirations and participation and identifies strategies to implement them.",name:'3_5', constraints:constraintsWithNA]],
                 additionalPracticeQuestion:[text:"3.6\t${additionalPracticeQuestion}",name:'3_6', constraints:defaultConstraints]],
                [title:"4. Local community participation and engagement",
                 theme:themes[1],
                 name:"localCommunityParticipationAndEngagement",
                 questions:[
                         [text:"4.1\tThe regional NRM organisation has a current community participation plan and a current Indigenous participation plan.",name:'4_1', constraints:defaultConstraints],
                         [text:"4.2\tThe regional NRM organisation has an established process in place that allows the local community to participate in priority setting and/or decision making.",name:'4_2', constraints:defaultConstraints],
                         [text:"4.3\tThe regional NRM organisation is actively building the capacity of the local community to participate in NRM through funding support for training, on ground projects and related activities.",name:'4_3', constraints:defaultConstraints],
                         [text:"4.4\tThe regional NRM organisation is actively supporting increased participation of Indigenous people in the planning and delivery of NRM projects and investment.",name:'4_4', constraints:constraintsWithNA]],
                 additionalPracticeQuestion:[text:"4.5\t${additionalPracticeQuestion}",name:'4_5', constraints:defaultConstraints]],
                [title:"5. Monitoring, Evaluation, Reporting and Improvement ",
                 name:"meri",
                 theme:themes[1],
                 questions:[
                         [text:"5.1\tThe regional NRM organisation is providing comprehensive, accurate and timely project MERI plans and MERIT reporting.",name:'5_1', constraints:defaultConstraints],
                         [text:"5.2\tThe regional NRM organisation is implementing processes to ensure that MERI activities are adequately resourced by appropriately skilled and informed staff.",name:'5_2', constraints:defaultConstraints],
                         [text:"5.3\tThe regional NRM organisation is demonstrating and communicating progress towards NRM project outcomes through regular monitoring, evaluation and reporting of project performance and the use of results to guide improved practice.",name:'5_3', constraints:defaultConstraints]],
                 additionalPracticeQuestion:[text:"5.4\t${additionalPracticeQuestion}",name:'5_4', constraints:defaultConstraints]]
        ]

        Map sectionsByTheme = sections.groupBy{it.theme}
        sectionsByTheme.each { String k, List v ->
            v.sort{it.title}
        }

        [themes:themes, sectionsByTheme:sectionsByTheme, report:report]
    }

    Map performanceReport(int year, String state) {
        List scores = [[name:'regionalNRMPlans', property:'regionalNRMPlansOverallRating'],
                       [name:'localCommunityParticipationAndEngagement', property:'localCommunityParticipationAndEngagementOverallRating'],
                       [name:'organisationalGovernance', property:'organisationalGovernanceOverallRating'],
                       [name:'financialGovernance', property:'financialGovernanceOverallRating'],
                       [name:'meri', property:'meriOverallRating']]


        List<Map> aggregations = []
        scores.each {
            aggregations << [type:'HISTOGRAM', label:it.name, property:'data.'+it.property]
        }
        Map filter = state?[type:'DISCRETE', property:'data.state']:[:]
        Map config = [groups:filter, childAggregations: aggregations, label:'Performance assessment by state']

        Map searchCriteria = [type:['Performance Management Framework - Self Assessment', 'Performance Management Framework - Self Assessment v2'], publicationStatus:REPORT_APPROVED, dateProperty:'toDate', 'startDate':(year-1)+'-07-01T10:00:00Z', 'endDate':year+'-07-01T10:00:00Z']

        String url =  grailsApplication.config.ecodata.baseURL+"/ws/report/runReport"

        webService.doPost(url, [searchCriteria: searchCriteria, reportConfig: config])
    }


    Map reef2050PlanActionReport() {

        Map searchCriteria = [type:REEF_2050_PLAN_ACTION_REPORTING_ACTIVITY_TYPE, publicationStatus:REPORT_APPROVED]

        Map resp
        JSON.use("nullSafe") {
            resp = activityService.search(searchCriteria)
        }
        if (resp.error) {
            return [error:resp.error]
        }

        List activities = resp.resp.activities
        if (!activities) {
            return [actions:[], actionStatus: [:], actionStatusByTheme: [:]]
        }
        String mostRecent = activities.max{it.plannedEndDate}.plannedEndDate
        Period period = Period.months(6)
        DateTime periodStart = DateUtils.alignToPeriod(DateUtils.parse(mostRecent), period)
        activities = activities.findAll{DateUtils.parse(it.plannedEndDate).isAfter(periodStart)}
        String startDate = DateUtils.format(periodStart)
        String endDate = DateUtils.format(periodStart.plus(period))

        List projectIds = activities.collect{it.projectId}.unique()
        List projects = projectService.search([projectId:projectIds, view:'flat'])?.resp?.projects ?: []

        // Merge into a single list of actions.

        List<Map> allActions = []
        activities.each { activity ->
            Map output = activity.outputs?activity.outputs[0]:[:]
            List actions = output.data?.actions
            Map project = projects.find{it.projectId == activity.projectId}
            List agencyContacts = output.data.agencyContacts ? output.data.agencyContacts.collect{it.agencyContact}:[]
            List webLinks = output.data.webLinks ? output.data.webLinks.collect{it.webLink}:[]
            Map commonData = [organisationId:project?.organisationId, reportingLeadAgency:project?.organisationName, agencyContacts:agencyContacts, webLinks:webLinks]
            actions = actions.collect{
                if (it.webLinks) {
                    it.webLinks = it.webLinks.split(/(;|,|\n|\s)/)?.findAll{it}
                }
                commonData+it
            }
            allActions.addAll(actions)
        }
        String format = 'YYYY-MM'
        List dateBuckets = [startDate, endDate]
        Map countByStatus = [type:'HISTOGRAM', label:'Action status', property:'data.actions.status']
        Map dateGroupingConfig = [groups:[type:'date', buckets:dateBuckets, format:format, property:'activity.plannedEndDate'],
                                  childAggregations: [countByStatus, [label:'Action Status By Theme', groups:[type:'discrete', property:'data.actions.theme'], childAggregations: [countByStatus]]]]
        Map activityTypeFilter = [type:'DISCRETE', filterValue: REEF_2050_PLAN_ACTION_REPORTING_ACTIVITY_TYPE, property:'activity.type']
        Map config = [filter:activityTypeFilter, childAggregations: [dateGroupingConfig], label:'Action Status by Year']

        String url =  grailsApplication.config.ecodata.baseURL+"/ws/search/activityReport"
        List searchCriteriaForReport = ["associatedSubProgramFacet:"+REEF_2050_PLAN_ACTION_REPORTING_ACTIVITY_TYPE]

        Map report = webService.doPost(url, [fq:searchCriteriaForReport, reportConfig: config])
        Map actionStatus = [label:"Action Status"]
        Map actionStatusByTheme = [:]
        if (!report.error) {
            report = report.resp.results
            String startDateMatcher = startDate.substring(0, format.length())

            Map reportForYear = report?.groups?.find{it.group.startsWith(startDateMatcher)}
            if (reportForYear) {

                actionStatus.result = reportForYear.results[0]
                reportForYear.results[1]?.groups?.each { group ->
                    actionStatusByTheme[group.group] = [label: group.group + " - Action Status", result:group.results[0]]
                }
            }
        }

        [actions:allActions, actionStatus:actionStatus, actionStatusByTheme:actionStatusByTheme, endDate:endDate]

    }

    Map programReport(String programName, String searchTerm = "*:*") {
//        Provide a dashboard style capability for an authorised user, using speed dial type graphics (or similar), which provide a status snapshot of, for example, the –
//        •	Number of projects being performed by project type and status of finalised, current and planned
//        •	Number of project risks by the overall risk rating
//        •	Number of issues by the impact levels
//        •	Overall budget assigned to the projects by financial year.

        // This would almost certainly be better done with ES aggregrations....

        int BATCH_SIZE = 100

        String now = DateUtils.format(new Date())
        Map<String,Map> projectStatusByType = [:].withDefault{[:].withDefault{0}}
        Map<String, Integer> risks = [:].withDefault{0}
        Map<String, Integer> issues = [:].withDefault{0}
        Map<String, Integer> budgetByYear = [:].withDefault{0}

        int processed = 0
        Map params = [offset:processed, max:BATCH_SIZE]
        if (programName) {
            params.fq = "associatedProgram:"+programName
        }
        def result = searchService.allProjects(params, searchTerm)
        int count = result?.hits?.total ?: 0
        while (processed < count) {
            result.hits.hits?.each { hit ->
                Map project = hit._source
                projectStatusByType[project.projectType][getStatus(project, now)]++
                String overallRiskRating = project.custom?.details?.risks?.overallRisk
                if (overallRiskRating) {
                    risks[overallRiskRating]++
                }
                if (project.custom?.details?.issues?.issues) {
                    project.custom.details.issues.issues.each { issue ->
                        issues[issue.impact]++
                    }
                }
                if (project.custom?.details?.budget?.headers) {
                    Map budget = project.custom.details.budget
                    budget.headers.eachWithIndex { header, i ->
                        if (budget.columnTotal[i]) {
                            budgetByYear[header.data] += budget.columnTotal[i].data
                        }
                    }
                }

                processed++
            }
            params.offset = processed
            result = searchService.allProjects(params)
        }

        Map projectStatusByTypeAsScores = projectStatusByType.collectEntries { key, value ->
            String title = messageSource.getMessage('facets.typeOfProject.'+key, null, "Unspecified", Locale.default)
            [(key):asScore(title, value)]
        }
        [projectStatusByType:projectStatusByTypeAsScores,
         issueCountByImpact:asScore("Issue count by impact" , issues),
         riskCountByRating:asScore("Risk count by rating", risks),
         budgetByYear:asScore("Budget by financial year", budgetByYear, 'barchart')]
    }

    private Map asScore(String label, Map data, String type = 'piechart') {

        [label: label, result: [result:data], displayType:type]
    }

    private String getStatus(Map project, String isoDate) {
        if (project.plannedEndDate < isoDate) {
            return 'Finished'
        }
        if (project.plannedStartDate > isoDate) {
            return 'Planned'
        }
        return 'Current'
    }
}
