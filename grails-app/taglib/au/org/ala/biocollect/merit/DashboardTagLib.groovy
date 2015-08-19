package au.org.ala.biocollect.merit

import org.grails.plugins.google.visualization.GoogleVisualization

/**
 * Renders output scores for display on a project or program dashboard.
 */
class DashboardTagLib {
    static namespace = "fc"

    /**
     * Expects a single attribute with name "score" containing the result from an aggregation.
     */
    def renderScore = {attrs, body ->
        def score = attrs.score

        try {

            def target = score.target ? score.target as Double : 0
            // A zero target essentially means not a target.
            if (target > 0 && score.score.isOutputTarget && !score.displayType) {
                renderTarget(score, target)
            }
            else if (!score.score.displayType) {
                renderSingleScore(score)
            }
            else {
                renderGroupedScore(score)
            }
        }
        catch (Exception e) {
            log.warn("Found non-numeric target or result for score: ")
        }

    }

    static int estimateHeight(score) {

        def height = 25

        if (score.groupBy || score.aggregationType.name == 'HISTOGRAM') {

            height = score.displayType == 'barchart' ? 500 : 300
        }
        return height;

    }

    private Map formatGroupedReportData(scores, data) {
        def rows = []

        def columns = scores.collect {
            ['number', it.label]
        }
        columns = [['string', '']] + columns // Add the group column

        data.each { group ->

            def row = []
            row << group.group

            def rowData = [:]
            group.results?.each { subgroup ->
                subgroup.results?.each {
                    rowData << [(it.label):it.result]
                }
            }

            scores.each { score ->
                row << rowData[score.label] ?: 0
            }

            rows << row
        }

        [columns:columns, rows:rows]
    }

    def groupedTable = {attrs, body ->

        def scores = attrs.scores
        def data = attrs.data

        def reportData = formatGroupedReportData(scores, data)


        out << "<div id=\"${attrs.elementId}\"></div>"
        out << gvisualization.table(elementId:attrs.elementId, columns:reportData.columns, data:reportData.rows, dynamicLoading:true)

    }


    def groupedChart = {attrs, body ->


        def scores = attrs.scores
        def data = attrs.data
        def elementId = attrs.elementId

        def reportData = formatGroupedReportData(scores, data)


        out << "<div id=\"${elementId}\"></div>"
        out << gvisualization.barChart(height:300, elementId:elementId, columns:reportData.columns, data:reportData.rows, dynamicLoading:true)
    }

    def pieChart = {attrs, body ->
        def columnDefs = [['string', attrs.label], ['number', 'Count']]
        def chartData = toArray(attrs.data)
        drawChart(GoogleVisualization.PIE_CHART, attrs.label, attrs.title, '', columnDefs, chartData)
    }

    /**
     * Renders the value of a score alongside it's target value as a progress bar.
     * @param score the score being rendered
     * @param target the target value for the score
     */
    private void renderTarget(score, double target) {
        def result = score.results ? score.results[0].result as Double : 0
        def percentComplete = result / target * 100


        out << """
            <strong>${score.score.label}</strong><span class="pull-right progress-label ${percentComplete >= 99 ? 'progress-100':''}">${result}/${score.target}</span>
                <div class="progress progress-info active ">
                <div class="bar" style="width: ${percentComplete}%;"></div>
            </div>"""
    }

    private void renderSingleScore(score) {
        switch (score.score.aggregationType.name) {

            case 'SUM':
            case 'AVERAGE':
            case 'COUNT':
                def result = score.results ? score.results[0].result as Double : 0
                out << "<div><b>${score.score.label}</b>${helpText(score)} : ${g.formatNumber(type:'number',number:result, maxFractionDigits: 2, groupingUsed:true)}</div>"
                break
            case 'HISTOGRAM':
                def chartData = toArray(score.results[0].result)
                def chartType = score.score.displayType?:'piechart'
                drawChart(chartType, score.score.label, score.score.label, helpText(score), [['string', score.score.label], ['number', 'Count']], chartData)
                break
            case 'SET':
                out << "<div><b>${score.score.label}</b> :${score.results[0].result.join(',')}</div>"
                break
        }
    }

    private def toArray(dataMap) {
        def chartData = []
        dataMap.each{ key, value ->
            chartData << [key, value]
        }
        chartData
    }

    private def helpText(score) {
        if (score.score.description) {
            return fc.iconHelp([title:'']){score.score.description}
        }
        return ''
    }

    private void renderGroupedScore(score) {
        switch (score.score.aggregationType.name) {
            case 'SUM':
            case 'AVERAGE':
            case 'COUNT':
                def chartData = score.results.findAll{it.result}.collect{[it.group, it.result]}.sort{a,b -> a[0].compareTo(b[0])}
                def chartType = score.score.displayType?:'piechart'
                drawChart(chartType, score.score.label, score.groupTitle, helpText(score), [['string', score.groupTitle], ['number', score.score.label]], chartData)

                break
            case 'HISTOGRAM':
                def chartData = toArray(score.results[0].result)
                def chartType = score.score.displayType?:'piechart'
                drawChart(chartType, score.score.label, score.score.label, helpText(score), [['string', score.score.label], ['number', 'Count']], chartData)
                break

        }
    }

    private void drawPieChart(label, title, columns, data) {
        drawChart('piechart', label, title, '', columns, data)
    }

    private void drawBarChart(label, title, columns, data) {
        drawChart('barchart', label, title, '', columns, data)

    }

    private void drawChart(type, label, title, helpText, columns, data) {
        if (!data) {
            return
        }
        def chartId = label + '_chart'

        out << "<div class='chartTitle'>${title}${helpText}</div>"

        switch (type) {

            case 'piechart':
                out << "<div id=\"${chartId}\"></div>"
                out << gvisualization.pieCoreChart([elementId: chartId,  chartArea:new Expando(left:20, top:5, right:20, width:'430', height:'300'), dynamicLoading: true, title: title, columns: columns, data: data, width:'450', height:'300', backgroundColor: '#ebe6dc'])
                break;
            case 'barchart':

                def topMargin = 5
                def bottomMargin = 50
                def height = Math.max(300, data.size()*20+topMargin+bottomMargin)
                if (height > 500) {
                    topMargin = 0
                    out << "<div id=\"${chartId}\" style=\"height:500px; overflow-y:scroll; margin-bottom:20px;\"></div>"
                }
                else {
                    out << "<div id=\"${chartId}\"></div>"
                }
                out << gvisualization.barCoreChart([elementId: chartId, legendTextStyle:chartFont(), fontSize:11, tooltipTextStyle:chartFont(), legend:"none", dynamicLoading: true, title: title, columns: columns, data: data, chartArea:new Expando(left:140, top:topMargin, bottom:bottomMargin, width:'290', height:height-topMargin-bottomMargin), width:'450', height:height, backgroundColor: '#ebe6dc'])
                break;
        }
    }

    def chartFont() {

        return new Expando(fontSize:'10');
    }
}
