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
            if (target > 0 && score.isOutputTarget) {
                renderTarget(score, target, attrs)
            }
            else if (!score.displayType) {
                renderSingleScore(score, attrs)
            }
            else {
                renderGroupedScore(score, attrs)
            }
        }
        catch (Exception e) {
            log.warn("Found non-numeric target or result for score: "+score.label)
        }

    }

    static int estimateHeight(score) {

        def height = 25

        if (score.displayType) {

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
    private void renderTarget(score, double target, attrs) {
        def result = score.result?.result ?: 0
        def percentComplete = result / target * 100
        percentComplete = Math.min(100, percentComplete)
        percentComplete = Math.max(0, percentComplete)

        out << """
            <strong>${score.label}${helpText(score, attrs)}</strong>
            <div class="progress progress-info active " style="position:relative">
                <div class="bar" style="width: ${percentComplete}%;"></div>
                <span class="pull-right progress-label ${percentComplete >= 99 ? 'progress-100':''}" style="position:absolute; top:0; right:0;"> ${g.formatNumber(type:'number',number:result, maxFractionDigits: 2, groupingUsed:true)}/${score.target}</span>
            </div>"""
    }

    private void renderSingleScore(score, attrs) {
        def result = score.result?.result

        if (result instanceof Map) {
            if (!enoughResults(result.size(), attrs)) {
                return
            }
            def chartData = toArray(result, attrs.order)
            def chartType = score.displayType?:'piechart'
            drawChart(chartType, score.label, score.label, helpText(score, attrs), [['string', score.label], ['number', 'Count']], chartData, attrs)
        }
        else {
            result = result as Double ?: 0
            out << "<div><b>${score.label}</b>${helpText(score, attrs)} : ${g.formatNumber(type:'number',number:result, maxFractionDigits: 2, groupingUsed:true)}</div>"
        }
    }

    private def toArray(dataMap, List order = null) {
        def chartData = []
        dataMap.each{ key, value ->
            chartData << [key, value]
        }
        if (order) {
            chartData.sort{a, b -> order.indexOf(a[0]) <=> order.indexOf(b[0])}
        }

        chartData
    }

    private def helpText(score, attrs) {
        if (score.description && !attrs.printable) {
            return fc.iconHelp([title:'']){score.description}
        }
        return ''
    }

    private void renderGroupedScore(score, attrs) {
        def result = score.result
        if (result && result.result instanceof Map) {
            if (!enoughResults(result.result.size(), attrs)) {
                return
            }
            def chartData = toArray(result.result, attrs.order)
            def chartType = score.displayType?:'piechart'
            drawChart(chartType, score.label, score.label, helpText(score, attrs), [['string', score.label], ['number', 'Count']], chartData, attrs)
        }
        else {
            if (result && result.groups.size() == 1 && result.groups[0].count == 1) {
                return
            }
            def chartData = result.groups.collect{[it.group, it.results[0].result]}.findAll{it[1]}.sort{a,b -> a[0].compareTo(b[0])}
            def chartType = score.displayType?:'piechart'
            drawChart(chartType, score.label, score.label?:'', helpText(score, attrs), [['string', score.label?:''], ['number', score.label]], chartData, attrs)

        }

    }

    private boolean enoughResults(int resultSize, attrs) {
        int min = attrs.minResults ? Integer.parseInt(attrs.minResults) : 2
        return resultSize >= min
    }

    private void drawChart(type, label, title, helpText, columns, data, attrs) {
        if (!data) {
            return
        }
        if (!attrs.omitTitle) {
            out << '<div class="chart-plus-title">'
            out << "<div class='chartTitle'>${title}${helpText}</div>"
        }

        def chartId = (label + '_chart').replaceAll(" ", "-")

        switch (type) {

            case 'piechart':
                out << "<div id=\"${chartId}\" class=\"chart\" style=\" width:100%;\"></div>"
                Map options = [elementId: chartId, chartArea:[left:20, top:5, right:20, width:'430', height:'300'], dynamicLoading: true, title: title, columns: columns, data: data, width:'450', height:'300', backgroundColor: 'transparent']
                if (attrs.sliceColoursByTitle) {
                    Map slices = [:]
                    attrs.sliceColoursByTitle.each { sliceTitle, colour ->
                        data.eachWithIndex { item, index ->
                            if (item[0] == sliceTitle) {
                                slices[index] = [color:colour]
                            }
                        }
                    }
                    options['slices'] = slices
                }
                if (attrs.chartOptions) {
                    options.putAll(attrs.chartOptions)
                }
                out << gvisualization.pieCoreChart(options)
                break;
            case 'barchart':

                def topMargin = 5
                def bottomMargin = 50
                def height = Math.max(300, data.size()*20+topMargin+bottomMargin)
                if (!attrs.printable && height > 500) {
                    topMargin = 0
                    out << "<div id=\"${chartId}\" class=\"chart\" style=\"height:500px; overflow-y:scroll; margin-bottom:20px;\"></div>"
                }
                else {
                    out << "<div id=\"${chartId}\" class=\"chart\"></div>"
                }
                Map options = [elementId: chartId, legend:chartFont(), fontSize:11, tooltip:chartFont(), legend:"none", dynamicLoading: true, title: title, columns: columns, data: data, chartArea:[left:140, top:topMargin, bottom:bottomMargin, width:'290', height:height-topMargin-bottomMargin], width:'450', height:height, backgroundColor: 'transparent']
                if (attrs.chartOptions) {
                    options.putAll(attrs.chartOptions)
                }
                out << gvisualization.barCoreChart(options)
                break;
        }
        if (!attrs.omitTitle) {
            out << '</div>'
        }

    }

    def chartFont() {

        return [fontSize:10]
    }
}
