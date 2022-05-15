// Groovy Rest Client.
// > export PATH=$PATH:/Users/sat01a/All/j2ee/groovy-2.4.7/bin
// > cd /Users/sat01a/All/sat01a_git/merged/biocollect-3/scripts/RestClient
// > groovy RestClient.groovy
// To get the example post data, enable debugger at this.save and print the variable or right click and store as global variable.
// variable json string data will be printed in the console
// Use http://jsonformatter.org/ to format the data. (make sure to remove the " " around the string...)
// User must have a auth token [ ozatlasproxy.ala.org.au]

import groovy.json.JsonSlurper
@Grapes([
        @Grab('org.apache.poi:poi:3.10.1'),
        @Grab(group = 'commons-codec', module = 'commons-codec', version = '1.9'),
        @Grab('org.apache.poi:poi-ooxml:3.10.1')]
)
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import org.apache.poi.ss.usermodel.*
import java.nio.file.Paths
import java.nio.file.Files
import java.text.DecimalFormat
import javax.script.*;
import static java.util.UUID.randomUUID
import java.nio.charset.StandardCharsets

// Import Configuration
def DEBUG_AND_VALIDATE = false;
def PROJECT_ID = "49031073-7485-44a2-99db-d39569d47ecd"
def PROJECT_ACTIVITY_ID = "e33fd862-3001-48e5-aca9-68db75a49c35"
def USERNAME = ""
def AUTH_KEY = ""
def xlsx = "/Users/kan088/Documents/Github/biocollect2/biocollect/scripts/RestClient/bcc/data.xlsm"

def SERVER_URL = "http://devt.ala.org.au:8087"
def SPECIES_URL = "/search/searchSpecies/${PROJECT_ACTIVITY_ID}?limit=1&hub=coralwatch&dataFieldName=coralSpecies&output=CoralWatch"
def ADD_NEW_ACTIVITY_URL = "/ws/bioactivity/save?pActivityId=${PROJECT_ACTIVITY_ID}&hub=coralwatch"
def SITE_TEMPLATE_FILE = "/Users/kan088/Documents/Github/biocollect2/biocollect/scripts/RestClient/bcc/site_template.json"
def SITE_CREATION_URL = '/site/ajaxUpdate'
def SITE_LIST = '/site/ajaxList'

def header = []
def values = []
def plotData = []
def plotDataHeader = []
def canopyData = []
def canopyDataHeader = []

FormulaEvaluator evaluator

println("Reading ${xlsx} file")
Paths.get(xlsx).withInputStream { input ->
    def workbook = new XSSFWorkbook(input)
    evaluator = workbook.getCreationHelper().createFormulaEvaluator()
    def dataSheet = workbook.getSheetAt(0) //conditionCollated_data
    def canopySheet = workbook.getSheetAt(1) //canopy data
    def plotSheet = workbook.getSheetAt(2) //plot data

    header = readHeader(dataSheet, true);
    plotDataHeader = readHeader(plotSheet, false);
    canopyDataHeader = readHeader(canopySheet, true);

    values = readData(dataSheet, true, header, evaluator);
    plotData = readData(plotSheet, false, plotDataHeader, evaluator);
    canopyData = readData(canopySheet, true, canopyDataHeader, evaluator);

    println("Successfully loaded ${xlsx} file");

    println("Combining plot and canopy data");
    values?.each { entry ->
        entry."plotData" = plotData.findAll {x -> entry."Site assessment number" == x."Site Assessment Number" }
        entry."canopyData" = canopyData.findAll {x -> entry."Site assessment number" == x."Site Assessment Number"}
    }

    def nestedActivities = values
    println("Records nested under activities");
    println("Total activities = ${nestedActivities?.size()}")

    // Load default activity template file
    String jsonStr = new File('/Users/kan088/Documents/Github/biocollect2/biocollect/scripts/RestClient/bcc/lite_template.json').text

    // Loop through the activities
    nestedActivities?.eachWithIndex { record, activityIndex ->

        def jsonSlurper = new groovy.json.JsonSlurper()
        def activity = jsonSlurper.parseText(jsonStr)

        println("***************")
        println("Building activity: ${activityIndex + 1 }")

        int numShrubSpecies = 0
        int numGrassSpecies = 0
        int totalTreeSpeciesRichness = 0
        int numForbSpecies = 0
        int numNonNativeSpecies =0

        activity.projectId = PROJECT_ID

        TimeZone tz = TimeZone.getTimeZone("UTC");
        java.text.DateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'"); // Quoted "Z" to indicate UTC, no timezone offset
        df.setTimeZone(tz);
        String isoDate = ''
        try{
            isoDate = df.format(record."Assessment date")
        } catch (Exception ex){
            println("Date format error ${activityIndex + 1}")
        }

        // Map generic fields

        activity.outputs[0].data.treeCanopyHeightInMetres = record."Tree Canopy (EDL) Height (m):"
        activity.outputs[0].data.transectAlignmentIrregular = record."Irregular shaped transect used?"
        activity.outputs[0].data.property = record."Property or park name"
        activity.outputs[0].data.patchAreaInHectares = record."Area of patch (Ha)"
        activity.outputs[0].data.nonNativePlantCoverPercent = record."Total cover of non-native plants (%):"
        activity.outputs[0].data.reConfidenceReason = record."RE confidence reason or comments"
        activity.outputs[0].data.numUnknownShrubSpecies = record."No. of unknown native shrub species:"
        activity.outputs[0].data.lengthOfTransectInMeters = record."Length of transect (m)"
        activity.outputs[0].data.numLargeNonEucalypt = record."No. of large non-eucalypt trees (> benchmark DBH):"
        activity.outputs[0].data.transectBearing = record."Transect bearing (degrees)"
        activity.outputs[0].data.siteAssessmentNumber = record."Site assessment number"
        activity.outputs[0].data.bioregion = record."Regional Ecosystem (RE) code"
        activity.outputs[0].data.subcanopyHeightInMetres = record."Tree subcanopy height (m):"
        activity.outputs[0].data.landholderPermissionObtained = record."Was landholder permission obtained?"
        activity.outputs[0].data.numUnknownTreeSpecies = record."No. of unknown native tree species:"
        activity.outputs[0].data.numUnknownForbSpecies = record."Number of unknown native forbs & other species:"
        activity.outputs[0].data.reConfidence = record."RE confidence"
        activity.outputs[0].data.proportionDominantCanopySpeciesWithEvidenceOfRecruitment = record."Proportion of canopy EDL species with evidence of recruitment (%):"
        activity.outputs[0].data.numUnknownNonNativeSpecies = record."Number of unknown non-native plants:"
        activity.outputs[0].data.assessmentAreaDescription = record."assessmentSiteDescription"
        activity.outputs[0].data.numLargeEucalypt = record."No. of large eucalypt trees (> benchmark DBH):"
        activity.outputs[0].data.eventDate = isoDate
        activity.outputs[0].data.numUnknownGrassSpecies = record."No. of unknown grass species:"
        activity.outputs[0].data.emergentHeightInMetres = record."Emergent height (m):"
        activity.outputs[0].data.recordedBy = record."Recorded by"
        activity.outputs[0].data.cwdLengths = []
        activity.outputs[0].data.cwdLengths << {cwdLength : record."CWD Length (m):"}
        activity.outputs[0].data.shrubCanopyRecords = []
        activity.outputs[0].data.treeCanopyRecords = []
        activity.outputs[0].data.shrubSpeciesRichness = []
        activity.outputs[0].data.forbsAndOtherNonGrassGroundSpeciesRichness = []
        activity.outputs[0].data.treeSpeciesRichness = []
        activity.outputs[0].data.nonNativeSpeciesRichness = []
        activity.outputs[0].data.grassSpeciesRichness = []

        numShrubSpecies = record."numShrubSpecies" ? record."numShrubSpecies".toFloat().toInteger() : 0;
        totalTreeSpeciesRichness = record."totalTreeSpeciesRichness" ? record."totalTreeSpeciesRichness".toFloat().toInteger() : 0;
        numForbSpecies = record."numForbSpecies" ? record."numForbSpecies".toFloat().toInteger() :0;
        numNonNativeSpecies = record."numNonNativeSpecies"? record."numNonNativeSpecies".toFloat().toInteger() : 0;
        numGrassSpecies = record."numGrassSpecies" ? record."numGrassSpecies".toFloat().toInteger() :0;

        def plotRecord = []
        (record."plotData"[0].keySet() as List).collate(12).each{
            plotRecord << record."plotData"[0].subMap(it)
        }

        activity.outputs[0].data.groundCover.eachWithIndex { it, index ->
            if(index < 12) {
                it."plot1" = plotRecord[0].get(plotRecord[0].keySet().toArray()[index])
                it."plot2" = plotRecord[1].get(plotRecord[1].keySet().toArray()[index])
                it."plot3" = plotRecord[2].get(plotRecord[2].keySet().toArray()[index])
                it."plot4" = plotRecord[3].get(plotRecord[3].keySet().toArray()[index])
                it."plot5" = plotRecord[4].get(plotRecord[4].keySet().toArray()[index])
            }
        }

        record."canopyData".each {
            def treeCanopyRecord = [
                    "distanceInMetersAlongTransectTreeStart":"",
                    "totalTCCover":"",
                    "treeOrTreeGroup":"",
                    "distanceInMetersAlongTransectTreeEnd":""]
            def shrubCanopyRecord = [
                    "distanceInMetersAlongTransectShrubStart":"",
                    "shrubType":"",
                    "distanceInMetersAlongTransectShrubEnd":"",
                    "totalSCCover":""]

            if(!(it."Distance along tree transect - start (m)" == "0.0" && it."Distance along tree transect - end (m)" == "0.0") && it."Tree or tree group") {
                treeCanopyRecord.treeOrTreeGroup = it."Tree or tree group"
                treeCanopyRecord.distanceInMetersAlongTransectTreeStart = it."Distance along tree transect - start (m)"
                treeCanopyRecord.distanceInMetersAlongTransectTreeEnd = it."Distance along tree transect - end (m)"
                activity.outputs[0].data."treeCanopyRecords" << treeCanopyRecord
            }

            if(!(it."Distance along transect - start (m)" == "0.0" && it."Distance along transect - end (m)" == "0.0") && it."Shrub type*") {
                shrubCanopyRecord.shrubType = it."Shrub type*"
                shrubCanopyRecord.distanceInMetersAlongTransectShrubStart = it."Distance along transect - start (m)"
                shrubCanopyRecord.distanceInMetersAlongTransectShrubEnd = it."Distance along transect - end (m)"
                activity.outputs[0].data."shrubCanopyRecords" << shrubCanopyRecord
            }
        }

        if(record."Native shrub species names (Scientific Name Only)") {
            activity.outputs[0].data.shrubSpeciesRichness << ["speciesNameShrub": getSpecies(record."Native shrub species names (Scientific Name Only)")]
        }
        if(record."Native forb species and other life form names (Scientific Name Only)") {
            activity.outputs[0].data.forbsAndOtherNonGrassGroundSpeciesRichness << ["speciesNameForb": getSpecies(record."Native forb species and other life form names (Scientific Name Only)")]
        }
        if(record."Native tree species names (Scientific Name Only)") {
            activity.outputs[0].data.treeSpeciesRichness << ["speciesNameTree": getSpecies(record."Native tree species names (Scientific Name Only)")]
        }
        if(record."Non-native plant names (Scientific Name Only)") {
            activity.outputs[0].data.nonNativeSpeciesRichness << ["speciesNameNonNative":getSpecies(record."Non-native plant names (Scientific Name Only)")]
        }
        if(record."Native grass species names (Scientific Name Only)") {
            activity.outputs[0].data.grassSpeciesRichness << ["speciesNameGrass": getSpecies(record."Native grass species names (Scientific Name Only)")]
        }

        if(activity) {

            if(numShrubSpecies > activity.outputs[0].data.shrubSpeciesRichness.size()) {
                activity.outputs[0].data.numUnknownShrubSpecies = (numShrubSpecies - activity.outputs[0].data.shrubSpeciesRichness.size()).toString()
            }
            if(totalTreeSpeciesRichness > activity.outputs[0].data.treeSpeciesRichness.size()) {
                activity.outputs[0].data.numUnknownTreeSpecies = (totalTreeSpeciesRichness - activity.outputs[0].data.treeSpeciesRichness.size()).toString()
            }
            if(numForbSpecies > activity.outputs[0].data.forbsAndOtherNonGrassGroundSpeciesRichness.size()) {
                activity.outputs[0].data.numUnknownForbSpecies = (numForbSpecies - activity.outputs[0].data.forbsAndOtherNonGrassGroundSpeciesRichness.size()).toString()
            }
            if(numNonNativeSpecies > activity.outputs[0].data.nonNativeSpeciesRichness.size()) {
                activity.outputs[0].data.numUnknownNonNativeSpecies = (numNonNativeSpecies - activity.outputs[0].data.nonNativeSpeciesRichness.size()).toString()
            }
            if(numGrassSpecies > activity.outputs[0].data.grassSpeciesRichness.size()) {
                activity.outputs[0].data.numUnknownGrassSpecies = (numGrassSpecies - activity.outputs[0].data.grassSpeciesRichness.size()).toString()
            }

            String jsonStr1 = new File('/Users/kan088/Documents/Github/biocollect2/biocollect/scripts/RestClient/bcc/benchmark_data_for_release_v3.1.json').text
            def jsonSlurper1 = new groovy.json.JsonSlurper()
            activity.outputs[0].data.consolidatedBenchmarks = jsonSlurper1.parseText(jsonStr1)

            String jsonStr2 = new File('/Users/kan088/Documents/Github/biocollect2/biocollect/scripts/RestClient/bcc/mini_vegetationTable.json').text
            def jsonSlurper2 = new groovy.json.JsonSlurper()
            activity.outputs[0].data.bioConditionAssessmentTableReference = jsonSlurper2.parseText(jsonStr2)

            ScriptEngineManager manager = new ScriptEngineManager();
            ScriptEngine engine = manager.getEngineByName("JavaScript");

            def x = activity.outputs[0].data;

            engine.eval(Files.newBufferedReader(Paths.get("/Users/kan088/Documents/Github/biocollect2/biocollect/scripts/RestClient/bcc/siteBcScoreLite.js"), StandardCharsets.UTF_8));

            Invocable inv = (Invocable) engine;

            def response = inv.invokeFunction("calculate", new groovy.json.JsonBuilder(x).toString());

            // Upload site
            def siteId = "";
            println("Loading site data template file")
            String siteStr = new File(SITE_TEMPLATE_FILE).text
            def siteJsonSlurper = new groovy.json.JsonSlurper()
            def siteObject = siteJsonSlurper.parseText(siteStr)
            siteObject.pActivityId = PROJECT_ACTIVITY_ID
            siteObject.projectId = PROJECT_ID
            siteObject.site.name = "Private site for survey: BioCondition Lite Methodology - revised"
            siteObject.site.projects = []
            siteObject.site.projects << PROJECT_ID
            siteObject.site.extent.geometry.centre = [] // Long and latitudide. (example: long 136.)
            siteObject.site.extent.geometry.centre << response.site.longitude
            siteObject.site.extent.geometry.centre << response.site.latitude
            siteObject.site.extent.geometry.coordinates = [] // Long and latitudide. (example: long 136.)
            siteObject.site.extent.geometry.coordinates << response.site.longitude
            siteObject.site.extent.geometry.coordinates << response.site.latitude

//                def siteConnection = new URL("${SERVER_URL}${SITE_CREATION_URL}").openConnection() as HttpURLConnection
//                siteConnection.setRequestProperty('userName', "${USERNAME}")
//                siteConnection.setRequestProperty('authKey', "${AUTH_KEY}")
//                siteConnection.setRequestProperty('Content-Type', 'application/json;charset=utf-8')
//                siteConnection.setRequestMethod("POST")
//                siteConnection.setDoOutput(true)
//
//                if (!DEBUG_AND_VALIDATE) {
//                    java.io.OutputStreamWriter wr = new java.io.OutputStreamWriter(siteConnection.getOutputStream(), 'utf-8')
//                    wr.write(new groovy.json.JsonBuilder(siteObject).toString())
//                    wr.flush()
//                    wr.close()
//                    statusCode = siteConnection.responseCode
//                    if (statusCode == 200) {
//                        def result = siteConnection.inputStream.text;
//                        def site_obj = new JsonSlurper().parseText(result)
//                        siteId = site_obj.id
//                        println(result);
//                    } else {
//                        def error = siteConnection.getErrorStream().text
//                        println(siteConnection.responseCode + " : " + error)
//                        def result = new JsonSlurper().parseText(error)
//                        if (result.status == "created")
//                            siteId = result.id
//                    }
//                    println("siteId: ${siteId}");
//                }

            activity.siteId = siteId
            activity.outputs[0].data.location = siteId
            activity.outputs[0].data.locationLongitude = response.site.longitude
            activity.outputs[0].data.locationLatitude = response.site.latitude
            activity.outputs[0].data.edlRecruitmentScore = response.edlRecruitmentScore
            activity.outputs[0].data.numNonNativeSpecies = response.numNonNativeSpecies
            activity.outputs[0].data.treeCanopyCoverScoreAve = response.treeCanopyCoverScoreAve
            activity.outputs[0].data.percentCoverNative = response.percentCoverNative
            activity.outputs[0].data.benchmarkEmergentCanopyCover = response.benchmarkEmergentCanopyCover
            activity.outputs[0].data.percentCoverExotic = response.percentCoverExotic
            activity.outputs[0].data.benchmarkSubCanopyHeight = response.benchmarkSubCanopyHeight
            activity.outputs[0].data.benchmarkNumGrassSpeciesTotal = response.benchmarkNumGrassSpeciesTotal
            activity.outputs[0].data.benchmarkTreeCanopyCover = response.benchmarkTreeCanopyCover
            activity.outputs[0].data.nativePlantSpeciesRichnessScore = response.nativePlantSpeciesRichnessScore
            activity.outputs[0].data.subcanopyHeightScore = response.subcanopyHeightScore
            activity.outputs[0].data.benchmarkMaxScoreExcludeLandscape = response.benchmarkMaxScoreExcludeLandscape
            activity.outputs[0].data.benchmarkReliability = response.benchmarkReliability
            activity.outputs[0].data.percentCoverS = response.percentCoverS
            activity.outputs[0].data.siteBcScore = response.siteBcScore
            activity.outputs[0].data.benchmarkNumForbSpeciesTotal = response.benchmarkNumForbSpeciesTotal
            activity.outputs[0].data.benchmarkSource = response.benchmarkSource
            activity.outputs[0].data.percentCoverE = response.percentCoverE
            activity.outputs[0].data.percentCoverC = response.percentCoverC
            activity.outputs[0].data.numLargeEucalyptPerHa = response.numLargeEucalyptPerHa
            activity.outputs[0].data.largeTreesScore = response.largeTreesScore
            activity.outputs[0].data.cwdScore = response.cwdScore
            activity.outputs[0].data.benchmarkNonEucalyptLargeTreeDBH = response.benchmarkNonEucalyptLargeTreeDBH
            activity.outputs[0].data.benchmarkGroundCoverNativeGrassCover = response.benchmarkGroundCoverNativeGrassCover
            activity.outputs[0].data.numGrassSpecies = response.numGrassSpecies
            activity.outputs[0].data.totalPlot5 = response.totalPlot5
            activity.outputs[0].data.benchmarkEucalyptLargeTreeNo = response.benchmarkEucalyptLargeTreeNo
            activity.outputs[0].data.totalPlot2 = response.totalPlot2
            activity.outputs[0].data.totalPlot1 = response.totalPlot1
            activity.outputs[0].data.benchmarkSpeciesCoverExotic = response.benchmarkSpeciesCoverExotic
            activity.outputs[0].data.totalPlot4 = response.totalPlot4
            activity.outputs[0].data.totalPlot3 = response.totalPlot3
            activity.outputs[0].data.numNonNativeSpeciesTotal = response.numNonNativeSpeciesTotal
            activity.outputs[0].data.totalLargeTreesPerHa = response.totalLargeTreesPerHa
            activity.outputs[0].data.numTreeSpeciesTotal = response.numTreeSpeciesTotal
            activity.outputs[0].data.aveCanopyHeightScore = response.aveCanopyHeightScore
            activity.outputs[0].data.benchmarkEdlSpeciesRecruitment = response.benchmarkEdlSpeciesRecruitment
            activity.outputs[0].data.numLargeNonEucalyptPerHa = response.numLargeNonEucalyptPerHa
            activity.outputs[0].data.numTreeSpecies = response.numTreeSpecies
            activity.outputs[0].data.numForbSpecies = response.numForbSpecies
            activity.outputs[0].data.benchmarkEucalyptLargeTreeDBH = response.benchmarkEucalyptLargeTreeDBH
            activity.outputs[0].data.benchmarkTreeCanopyHeight = response.benchmarkTreeCanopyHeight
            activity.outputs[0].data.benchmarkTreeSubcanopyCover = response.benchmarkTreeSubcanopyCover
            activity.outputs[0].data.numShrubSpeciesTotal = response.numShrubSpeciesTotal
            activity.outputs[0].data.litterCoverScore = response.litterCoverScore
            activity.outputs[0].data.numGrassSpeciesTotal = response.numGrassSpeciesTotal
            activity.outputs[0].data.benchmarkNumTreeSpeciesTotal = response.benchmarkNumTreeSpeciesTotal
            activity.outputs[0].data.benchmarkGroundCoverOrganicLitterCover = response.benchmarkGroundCoverOrganicLitterCover
            activity.outputs[0].data.coverScoreS = response.coverScoreS
            activity.outputs[0].data.emergentHeightScore = response.emergentHeightScore
            activity.outputs[0].data.numForbSpeciesTotal = response.numForbSpeciesTotal
            activity.outputs[0].data.numShrubSpecies = response.numShrubSpecies
            activity.outputs[0].data.nativePerennialGrassCoverScore = response.nativePerennialGrassCoverScore
            activity.outputs[0].data.totalLargeTrees = response.totalLargeTrees
            activity.outputs[0].data.edlCanopyHeightScore = response.edlCanopyHeightScore
            activity.outputs[0].data.benchmarkNonEucalyptLargeTreeNo = response.benchmarkNonEucalyptLargeTreeNo
            activity.outputs[0].data.coverScoreE = response.coverScoreE
            activity.outputs[0].data.benchmarkCWD = response.benchmarkCWD
            activity.outputs[0].data.coverScoreC = response.coverScoreC
            activity.outputs[0].data.benchmarkShrubCanopyCover = response.benchmarkShrubCanopyCover
            activity.outputs[0].data.totalCwdLength = response.totalCwdLength
            activity.outputs[0].data.benchmarkNumShrubSpeciesTotal = response.benchmarkNumShrubSpeciesTotal
            activity.outputs[0].data.shrubCanopyCoverScoreN = response.shrubCanopyCoverScoreN
            activity.outputs[0].data.nonNativePlantCoverScore = response.nonNativePlantCoverScore
            activity.outputs[0].data.benchmarkTreeEDLHeight = response.benchmarkTreeEDLHeight
            //activity.outputs[0].data.groundCover
            //canopy covers

            activity.outputs[0].selectedEcosystemBenchmark = response.selectedEcosystemBenchmark

//            // post data via web service.
//            def connection = new URL("${SERVER_URL}${ADD_NEW_ACTIVITY_URL}").openConnection() as HttpURLConnection
//
//            // set some headers
//            connection.setRequestProperty('userName', "${USERNAME}")
//            connection.setRequestProperty('authKey', "${AUTH_KEY}")
//            connection.setRequestProperty('Content-Type', 'application/json;charset=utf-8')
//            connection.setRequestMethod("POST")
//            connection.setDoOutput(true)
//
//            if (!DEBUG_AND_VALIDATE) {
//                java.io.OutputStreamWriter wr = new java.io.OutputStreamWriter(connection.getOutputStream(), 'utf-8')
//                wr.write(new groovy.json.JsonBuilder(activity).toString())
//                wr.flush()
//                wr.close()
//                // get the response code - automatically sends the request
//                println connection.responseCode + ": " + connection.inputStream.text
//            }
        }

    }

    println("Completed..")
}

List readHeader(def sheet, boolean basicData){

    def headerRow = basicData ? 1 : 0;
    def headers = []

    for (cell in sheet.getRow(headerRow).cellIterator()) {
        headers << cell.stringCellValue
    }

    return headers
}

List readData(def sheet, boolean basicData, List header, FormulaEvaluator evaluator){

    def headerRow = basicData ? 1 : 0;
    def data = [];

    Iterator<Row> allRows = sheet.rowIterator()
    while (allRows.hasNext()) {
        Row row = allRows.next()
        if (row.getRowNum() < headerRow + 1) {
            continue
        }

        if(row._cells[0].toString() == ""){
            break
        }

        def rowData = [:]
        for (cell in row.cellIterator()) {
            def value = ''

            switch (cell.cellType) {
                case Cell.CELL_TYPE_STRING:
                    value = cell.stringCellValue
                    break
                case Cell.CELL_TYPE_NUMERIC:
                    if (org.apache.poi.hssf.usermodel.HSSFDateUtil.isCellDateFormatted(cell)) {
                        value = cell.getDateCellValue()
                    } else {
                        value = cell.numericCellValue as String
                    }
                    break
                case Cell.CELL_TYPE_BLANK:
                    value = ""
                    break
                case Cell.CELL_TYPE_BOOLEAN:
                    value = cell.booleanCellValue
                    break
                case Cell.CELL_TYPE_FORMULA:
                    CellValue cellValue = evaluator.evaluate(cell);

                    switch (cellValue.getCellType()) {
                        case Cell.CELL_TYPE_NUMERIC:
                            value = cellValue.getNumberValue() as String;
                            break;
                        case Cell.CELL_TYPE_STRING:
                            value = cellValue.getStringValue();
                            break;
                        case Cell.CELL_TYPE_BLANK:
                            value = ""
                            break;
                        case Cell.CELL_TYPE_ERROR:
                            break;
                    }
                    break
                default:
                    println("Error: Cell type not supported..")
                    value = ''
            }

            rowData << [("${header[cell.columnIndex]}".toString()): value]
        }
        data << rowData
    }
    return data
}

Object getSpecies(String name) {

    def species = [name: '', guid: '', scientificName: '', commonName: '', outputSpeciesId: '', listId: '']

    // Get Unique Species Id
//    def uniqueIdResponse = new URL(SERVER_URL + "/ws/species/uniqueId")?.text
//    def jsonResponse = new groovy.json.JsonSlurper()
//    def outputSpeciesId = jsonResponse.parseText(uniqueIdResponse)?.outputSpeciesId
//    species.outputSpeciesId = outputSpeciesId
//
//    // Get species name
//    def speciesResponse = new URL(SERVER_URL + SPECIES_URL + "&q=${name}").text
//    def speciesJSON = new groovy.json.JsonSlurper()
//    def autoCompleteList = speciesJSON.parseText(speciesResponse)?.autoCompleteList
//
//    if (!autoCompleteList) {
//        species.name = name
//    }
//
//    autoCompleteList?.eachWithIndex { item, index ->
//        if (index == 0) {
//            species.name = item.name
//            species.guid = item.guid
//            species.scientificName = item.scientificName
//            species.commonName = item.commonName
//            species.listId = item.listId
//        }
//    }

    return species

}