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

// Import Configuration
def DEBUG_AND_VALIDATE = false;
def PROJECT_ID = "dea9729b-d9fe-42b7-ac74-af5e157933e0"
def PROJECT_ACTIVITY_ID = "fb0763e1-fb62-4c76-bf93-dfa37334ab16"
def USERNAME = ""
def AUTH_KEY = ""
def xlsx = "data.xlsx"

def SERVER_URL = "https://biocollect-test.ala.org.au"
def ADD_NEW_ACTIVITY_URL = "/ws/bioactivity/save?pActivityId=${PROJECT_ACTIVITY_ID}&hub=ecoscience"
def SITE_TEMPLATE_FILE = "site_template.json"
def SITE_CREATION_URL = '/site/ajaxUpdate'
def SITE_LIST = '/site/ajaxList'

def header = []
def values = []

FormulaEvaluator evaluator

println("Reading ${xlsx} file")
Paths.get(xlsx).withInputStream { input ->
    def workbook = new XSSFWorkbook(input)
    evaluator = workbook.getCreationHelper().createFormulaEvaluator()
    def sheet = workbook.getSheetAt(0)

    for (cell in sheet.getRow(1).cellIterator()) {
        header << cell.stringCellValue
    }

    Iterator<Row> allRows = sheet.rowIterator()
    while (allRows.hasNext()) {
        Row row = allRows.next()
        if (row.getRowNum() + 1 <= 2) {
            continue
        }

        if(row._cells[0].toString() == ""){
            break
        }

        def rowData = [:]
        rowData << ["rowNumber" : row.getRowNum() + 1]
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
                    //value = evaluator.evaluate(cell)._textValue

                    CellValue cellValue = evaluator.evaluate(cell);

                    switch (cellValue.getCellType()) {
                        case Cell.CELL_TYPE_NUMERIC:
                            value = cellValue.getNumberValue() as String;
                            break;
                        case Cell.CELL_TYPE_STRING:
                            value = cellValue.getStringValue();
                            break;
                        case Cell.CELL_TYPE_BLANK:
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
        values << rowData
    }

    println("Successfully loaded ${xlsx} file");
    // Group same elements in to an array.
    def nestedActivities = values

    println("Records nested under activities");
    println("Total activities = ${nestedActivities?.size()}")

    // Load default activity template file
    String jsonStr = new File('form_template.json').text

    // Loop through the activities
    nestedActivities?.eachWithIndex { record, activityIndex ->

        def jsonSlurper = new groovy.json.JsonSlurper()
        def activity = jsonSlurper.parseText(jsonStr)

        println("***************")
        println("Building activity: ${activityIndex + 1}")

        activity.projectId = PROJECT_ID

        TimeZone tz = TimeZone.getTimeZone("UTC");
        java.text.DateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'"); // Quoted "Z" to indicate UTC, no timezone offset
        df.setTimeZone(tz);
        java.text.DateFormat time = new java.text.SimpleDateFormat("hh:mm a");
        String isoDate = ''
        String isoDateTime
        try{
            isoDate = df.format(record."Sample date:")
            isoDateTime = record."Sample time:" ? time.format(record."Sample time:") : ""
        } catch (Exception ex){
            println("Date format error ${activityIndex + 1}")
        }

        // Map fields
        def siteId = "";

        //check site

        def siteCheckNameConnection = new URL("${SERVER_URL}${SITE_LIST}?id=${PROJECT_ACTIVITY_ID}&entityType=projectActivity").openConnection() as HttpURLConnection
        siteCheckNameConnection.setRequestProperty('userName', "${USERNAME}")
        siteCheckNameConnection.setRequestProperty('authKey', "${AUTH_KEY}")
        siteCheckNameConnection.setRequestProperty('Content-Type', 'application/json;charset=utf-8')
        siteCheckNameConnection.setRequestMethod("GET")
        siteCheckNameConnection.setDoOutput(true)

        def statusCode = siteCheckNameConnection.responseCode
        if (statusCode == 200 ){
            def list = siteCheckNameConnection.inputStream.text;
            def site_list = new JsonSlurper().parseText(list)

            if(site_list.name.contains(record."Site name")) {
                siteId = site_list.find{ it.name == record."Site name"}.siteId
            }
            else {
                // Upload site
                if(!record."Long (dec)" || !record."Lat (dec)"){
                    println("Error: no Longitude or Latitude for site for ${activityIndex + 1} ${record."Site name"}")
                    activity = null
                    return
                }

                println("Loading site data template file")
                String siteStr = new File(SITE_TEMPLATE_FILE).text
                def siteJsonSlurper = new groovy.json.JsonSlurper()
                def siteObject = siteJsonSlurper.parseText(siteStr)
                siteObject.pActivityId = PROJECT_ACTIVITY_ID
                siteObject.projectId = PROJECT_ID
                siteObject.site.name = record."Site name"
                siteObject.site.projects = []
                siteObject.site.projects << PROJECT_ID
                siteObject.site.extent.geometry.centre = [] // Long and latitudide. (example: long 136.)
                siteObject.site.extent.geometry.centre << record."Long (dec)"
                siteObject.site.extent.geometry.centre << record."Lat (dec)"
                siteObject.site.extent.geometry.coordinates = [] // Long and latitudide. (example: long 136.)
                siteObject.site.extent.geometry.coordinates << record."Long (dec)"
                siteObject.site.extent.geometry.coordinates << record."Lat (dec)"
                siteObject.site.description = record."Description"

                def siteConnection = new URL("${SERVER_URL}${SITE_CREATION_URL}").openConnection() as HttpURLConnection
                siteConnection.setRequestProperty('userName', "${USERNAME}")
                siteConnection.setRequestProperty('authKey', "${AUTH_KEY}")
                siteConnection.setRequestProperty('Content-Type', 'application/json;charset=utf-8')
                siteConnection.setRequestMethod("POST")
                siteConnection.setDoOutput(true)

                if (!DEBUG_AND_VALIDATE) {
                    java.io.OutputStreamWriter wr = new java.io.OutputStreamWriter(siteConnection.getOutputStream(), 'utf-8')
                    wr.write(new groovy.json.JsonBuilder(siteObject).toString())
                    wr.flush()
                    wr.close()
                    statusCode = siteConnection.responseCode
                    if (statusCode == 200) {
                        def result = siteConnection.inputStream.text;
                        def site_obj = new JsonSlurper().parseText(result)
                        siteId = site_obj.id
                        println(result);
                    } else {
                        def error = siteConnection.getErrorStream().text
                        println(siteConnection.responseCode + " : " + error)
                        def result = new JsonSlurper().parseText(error)
                        if (result.status == "created")
                            siteId = result.id
                    }
                    println("siteId: ${siteId}");
                }
            }

        } else {
            def error = siteCheckNameConnection.getErrorStream().text
            println(siteCheckNameConnection.responseCode + " : " + error)
            def result = new JsonSlurper().parseText(error)

        }

        activity.siteId = siteId
        activity.outputs[0].data.siteName = record."Site name:"
        activity.outputs[0].data.siteId = record."Site number:"
        activity.outputs[0].data.recordedBy = record."Recorded by"
        activity.outputs[0].data.eventDate = isoDate
        activity.outputs[0].data.eventTime = isoDateTime
        activity.outputs[0].data.lastRainfall = record."Last Rainfall:"
        activity.outputs[0].data.waterFlow = record."Water Flow:"
        activity.outputs[0].data.waterTemperatureInDegreesCelcius = record."Water temperature(deg C)"
        activity.outputs[0].data.waterTurbidityInNtu = record."Turbidity (N.T.U.)"
        activity.outputs[0].data.surfaceWaterPhUnits = record."pH (pH units)"
        activity.outputs[0].data.surfaceWaterEcInMillisiemensPerCentimetre = record."Conductivity (EC units)"
        activity.outputs[0].data.surfaceWaterPhosphatesInMilligramsPerLitre = record."Phosphate (mg/L)"
        activity.outputs[0].data.surfaceWaterAmmoniumInMilligramsPerLitre = record."Ammonium (mg/L))"
        activity.outputs[0].data.surfaceWaterOxidisedNitrogenInMilligramsPerLitre = record."Nitrates (mg/L as N)"
        activity.outputs[0].data.specificGravityUncorrected = record."Specific Gravity (raw)"
        activity.outputs[0].data.specificGravityCorrected = record."Specific Gravity (Corrected)"
        activity.outputs[0].data.totalColliformsInCfuPer100Millitres = record."Total colliforms (CFU/100 ml)"
        activity.outputs[0].data.eColiInCfuPer100Millilitres = record."E. Coli (CFU/100 ml)"
        activity.outputs[0].data.measurementRemarks =
                record."measurementRemarks" + (record."instrumentCalibration" ? ", Instrument Calibration: " + record."instrumentCalibration" : "") + (record."Weather conditions:" ? ", Weather conditions: " + record."Weather conditions:" : "")
        activity.outputs[0].data.eventRemarks = record."Overall Notes and Comments:"

        activity.outputs[0].data.location = siteId
        activity.outputs[0].data.locationLatitude = record."Lat (dec)"
        activity.outputs[0].data.locationLongitude = record."Long (dec)"

        if(activity) {
            // post data via web service.
            def connection = new URL("${SERVER_URL}${ADD_NEW_ACTIVITY_URL}").openConnection() as HttpURLConnection

            // set some headers
            connection.setRequestProperty('userName', "${USERNAME}")
            connection.setRequestProperty('authKey', "${AUTH_KEY}")
            connection.setRequestProperty('Content-Type', 'application/json;charset=utf-8')
            connection.setRequestMethod("POST")
            connection.setDoOutput(true)

            if (!DEBUG_AND_VALIDATE) {
                java.io.OutputStreamWriter wr = new java.io.OutputStreamWriter(connection.getOutputStream(), 'utf-8')
                wr.write(new groovy.json.JsonBuilder(activity).toString())
                wr.flush()
                wr.close()
                // get the response code - automatically sends the request
                println connection.responseCode + ": " + connection.inputStream.text
            }
        }
    }

    println("Completed..")
}