package au.org.ala.biocollect.merit

import groovy.json.JsonOutput

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
        renderVisualization('Table', 'table', [elementId:attrs.elementId, columns:reportData.columns, data:reportData.rows])

    }


    def groupedChart = {attrs, body ->


        def scores = attrs.scores
        def data = attrs.data
        def elementId = attrs.elementId

        def reportData = formatGroupedReportData(scores, data)


        out << "<div id=\"${elementId}\"></div>"
        renderVisualization('BarChart', 'corechart', [height:300, elementId:elementId, columns:reportData.columns, data:reportData.rows])
    }

    def pieChart = {attrs, body ->
        def columnDefs = [['string', attrs.label], ['number', 'Count']]
        def chartData = toArray(attrs.data)
        drawChart('piechart', attrs.label, attrs.title, '', columnDefs, chartData, attrs)
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
            <div class="progress">
                <div class="progress-bar bg-info" role="progressbar" style="width: ${percentComplete}%;">${g.formatNumber(type:'number',number:result, maxFractionDigits: 2, groupingUsed:true)}/${score.target}</div>
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
                out << "<div id=\"${chartId}\" class=\"chart w-100\"></div>"
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
                renderVisualization('PieChart', 'corechart', options)
                break;
            case 'barchart':

                def topMargin = 5
                def bottomMargin = 50
                def height = Math.max(300, data.size()*20+topMargin+bottomMargin)
                if (!attrs.printable && height > 500) {
                    topMargin = 0
                    out << "<div id=\"${chartId}\" class=\"chart mb-4\" style=\"height:500px; overflow-y:scroll;\"></div>"
                }
                else {
                    out << "<div id=\"${chartId}\" class=\"chart\"></div>"
                }
                Map options = [elementId: chartId, legend:chartFont(), fontSize:11, tooltip:chartFont(), legend:"none", dynamicLoading: true, title: title, columns: columns, data: data, chartArea:[left:140, top:topMargin, bottom:bottomMargin, width:'290', height:height-topMargin-bottomMargin], width:'450', height:height, backgroundColor: 'transparent']
                if (attrs.chartOptions) {
                    options.putAll(attrs.chartOptions)
                }
                renderVisualization('BarChart', 'corechart', options)
                break;
        }
        if (!attrs.omitTitle) {
            out << '</div>'
        }

    }

    def chartFont() {

        return [fontSize:10]
    }

    /**
     * Emits the JavaScript to draw a Google Charts visualization, replacing the discontinued
     * grails-google-visualization plugin's taglib. Relies on the page including the Google
     * loader (https://www.google.com/jsapi), as the dashboard pages already do.
     *
     * @param chartObject the google.visualization object name (e.g. PieChart, BarChart, Table)
     * @param packageName the Google Charts package to load (e.g. corechart, table)
     * @param attrs elementId, columns ([[type, label], ...]), data (list of rows) plus any
     *        chart options which are passed through to chart.draw()
     */
    private void renderVisualization(String chartObject, String packageName, Map attrs) {
        String elementId = attrs.elementId
        List columns = attrs.columns ?: []
        List data = attrs.data ?: []
        Map options = new LinkedHashMap(attrs)
        ['elementId', 'columns', 'data', 'dynamicLoading'].each { options.remove(it) }

        String name = elementId?.replaceAll(/[^a-zA-Z0-9_]/, '_')
        StringBuilder js = new StringBuilder()
        js << "<script type=\"text/javascript\">\n"
        js << "google.load('visualization', '1', {'packages': ['${packageName}'], 'callback': draw_${name}});\n"
        js << "function draw_${name}() {\n"
        js << "    var data_${name} = new google.visualization.DataTable();\n"
        columns.each { col ->
            js << "    data_${name}.addColumn('${col[0]}', ${JsonOutput.toJson(col[1]?.toString())});\n"
        }
        js << "    data_${name}.addRows(${JsonOutput.toJson(data)});\n"
        js << "    var chart_${name} = new google.visualization.${chartObject}(document.getElementById(${JsonOutput.toJson(elementId)}));\n"
        js << "    chart_${name}.draw(data_${name}, ${JsonOutput.toJson(options)});\n"
        js << "}\n"
        js << "</script>"
        out << js.toString()
    }
}
