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
import java.text.DecimalFormat

// Import Configuration
def DEBUG_AND_VALIDATE = false;
def PROJECT_ID = "9c55416c-f56a-4917-a65e-da1d64a851f7"
def PROJECT_ACTIVITY_ID = "6355f9da-ac48-4e23-bb09-e4fdaf3e446f"
def USERNAME = ""
def AUTH_KEY = ""
def xlsx = "coralWatch_v5.xlsx"

def SERVER_URL = "http://devt.ala.org.au:8087"
def SPECIES_URL = "/search/searchSpecies/${PROJECT_ACTIVITY_ID}?limit=1&hub=coralwatch&dataFieldName=coralSpecies&output=CoralWatch"
def ADD_NEW_ACTIVITY_URL = "/ws/bioactivity/save?pActivityId=${PROJECT_ACTIVITY_ID}&hub=coralwatch"
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

    for (cell in sheet.getRow(0).cellIterator()) {
        header << cell.stringCellValue
    }

    def headerFlag = true

    Iterator<Row> allRows = sheet.rowIterator()
    while (allRows.hasNext()) {
        Row row = allRows.next()
        if (headerFlag) {
            headerFlag = false
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
                    value = evaluator.evaluate(cell)._textValue
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
    def nestedActivities = []
    def processedIds = []

    println("Combining records");
    values?.each { entry ->
        def alreadyProcessed = processedIds.findAll { entry."Survey" == it }
        if (!alreadyProcessed) {
            def combinedRecords = values?.findAll {
                it."Survey" == entry."Survey" &&
                        it."Date" == entry."Date" &&
                        it."Reef Name" == entry."Reef Name"
            }

            DecimalFormat decimalFormat = new DecimalFormat("#")
            int intNum = decimalFormat.parse(entry."Number of records").intValue()
            if (combinedRecords.size() != intNum) {
                //some records have multiple sites

                def totalRecords = values?.findAll {it."Survey" == entry."Survey"}

                if(totalRecords.size() != intNum){
                    println("Error in survey " + entry."Survey")
                    println("Total record count should be ${intNum} but only ${totalRecords.size()} were found.")
                }

                def sites = totalRecords."Reef Name".unique()
                for(int i=0; i<sites.size(); i++){
                    combinedRecords = totalRecords.findAll{ item -> item."Reef Name" == sites[i]}
                    processedIds << totalRecords[0]."Survey"
                    nestedActivities << combinedRecords
                }
            }

            else {
                processedIds << combinedRecords[0]."Survey"
                nestedActivities << combinedRecords
            }
        }
    }

    println("Records nested under activities");
    println("Total activities = ${nestedActivities?.size()}")

    // Load default activity template file
    String jsonStr = new File('test_coralwatch_template.json').text

    // Loop through the activities
    nestedActivities?.eachWithIndex { activityRow, activityIndex ->

        def jsonSlurper = new groovy.json.JsonSlurper()
        def activity = jsonSlurper.parseText(jsonStr)

        println("***************")
        println("Building activity: ${activityIndex + 1 }  with records : ${activityRow?.size()} and starting excel row number : ${activityRow[0]."rowNumber"}")

        activity.projectId = PROJECT_ID

        activityRow?.eachWithIndex { record, idx ->
            TimeZone tz = TimeZone.getTimeZone("UTC");
            java.text.DateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'"); // Quoted "Z" to indicate UTC, no timezone offset
            df.setTimeZone(tz);
            java.text.DateFormat time = new java.text.SimpleDateFormat("hh:mm a");
            String isoDate = ''
            String isoDateTime
            try{
                isoDate = df.format(record."Date")
                isoDateTime = record."Time" ? time.format(record."Time") : ""
            } catch (Exception ex){
                println("Date format error ${record."Survey"}")
            }

            // Map generic fields
            if (idx == 0) {
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

                    if(site_list.name.contains(record."Reef Name")) {
                        siteId = site_list.find{ it.name == record."Reef Name"}.siteId
                    }
                    else {
                        // Upload site
                        if(!record."Longitude" || !record."Latitude"){
                            println("Error: no Longitude or Latitude for site for ${record."Survey"} ${record."Reef Name"}")
                            activity = null
                            return
                        }

                        println("Loading site data template file")
                        String siteStr = new File(SITE_TEMPLATE_FILE).text
                        def siteJsonSlurper = new groovy.json.JsonSlurper()
                        def siteObject = siteJsonSlurper.parseText(siteStr)
                        siteObject.pActivityId = PROJECT_ACTIVITY_ID
                        siteObject.projectId = PROJECT_ID
                        siteObject.site.name = record."Reef Name"
                        siteObject.site.projects = []
                        siteObject.site.projects << PROJECT_ID
                        siteObject.site.extent.geometry.centre = [] // Long and latitudide. (example: long 136.)
                        siteObject.site.extent.geometry.centre << record."Longitude"
                        siteObject.site.extent.geometry.centre << record."Latitude"
                        siteObject.site.extent.geometry.coordinates = [] // Long and latitudide. (example: long 136.)
                        siteObject.site.extent.geometry.coordinates << record."Longitude"
                        siteObject.site.extent.geometry.coordinates << record."Latitude"

                        siteObject.site.extent.geometry.decimalLongitude = record."Longitude"
                        siteObject.site.extent.geometry.decimalLatitude = record."Latitude"

                        siteObject.site.geoIndex.coordinates = [] // Long and latitudide. (example: long 136.)
                        siteObject.site.geoIndex.coordinates << record."Longitude"
                        siteObject.site.geoIndex.coordinates << record."Latitude"

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
                activity.outputs[0].data.groupName = record."Group Name"
                activity.outputs[0].data.groupType = record."Participating As"
                activity.outputs[0].data.countryOfSurvey = record."Country of Survey"
                activity.outputs[0].data.recordedBy = record."Creator"
                activity.outputs[0].data.eventDate = isoDate
                activity.outputs[0].data.eventTime = isoDateTime
                activity.outputs[0].data.lightCondition = record."Light Condition"
                activity.outputs[0].data.depthInMetres = record."Depth (m)" ?: record."Depth (ft)" ? footToMeter(Double.parseDouble(record."Depth (ft)")) : 0
                activity.outputs[0].data.depthInFeet = record."Depth (ft)" ?: record."Depth (m)" ? meterToFoot(Double.parseDouble(record."Depth (m)")) : 0
                activity.outputs[0].data.waterTemperatureInDegreesCelcius = record."Water Temperature (C)" ?: record."Water Temperature (F)" ? farenheitToCelcius(Double.parseDouble(record."Water Temperature (F)")): 0
                activity.outputs[0].data.waterTemperatureInDegreesFarenheit = record."Water Temperature (F)" ?: record."Water Temperature (C)" ? celciusToFarenheit(Double.parseDouble(record."Water Temperature (C)")): 0
                activity.outputs[0].data.activity = record."Activity"
                activity.outputs[0].data.eventRemarks = record."Comments"
                activity.outputs[0].data.gpsDeviceUsed = record."I used a GPS" == "yes"

                activity.outputs[0].data.location = siteId
                activity.outputs[0].data.locationLatitude = record."Latitude"
                activity.outputs[0].data.locationLongitude = record."Longitude"
                activity.outputs[0].data.locationHiddenLatitude = record."Latitude"
                activity.outputs[0].data.locationHiddenLongitude = record."Longitude"
                activity.outputs[0].data.overallAverage = record."Average overall"
            }

            if(activity) {

                def coralObservations = []
                def species = [name: '', guid: '', scientificName: '', commonName: '', outputSpeciesId: '', listId: '']

                if (record.'Coral Species') {
                    def list = record.'Coral Species'.split(",")

                    if (list.size() == 1) {

                        // Get Unique Species Id
                        def uniqueIdResponse = new URL(SERVER_URL + "/ws/species/uniqueId")?.text
                        def jsonResponse = new groovy.json.JsonSlurper()
                        def outputSpeciesId = jsonResponse.parseText(uniqueIdResponse)?.outputSpeciesId
                        species.outputSpeciesId = outputSpeciesId

                        // Get species name
                        def speciesResponse = new URL(SERVER_URL + SPECIES_URL + "&q=${list[0].replace(" sp.", "").replace(" ", "+").trim()}").text
                        def speciesJSON = new groovy.json.JsonSlurper()
                        def autoCompleteList = speciesJSON.parseText(speciesResponse)?.autoCompleteList

                        if (!autoCompleteList) {
                            species.name = list[0]
                        }

                        autoCompleteList?.eachWithIndex { item, index ->
                            if (index == 0) {
                                species.name = item.name
                                species.guid = item.guid
                                species.scientificName = item.scientificName
                                species.commonName = item.commonName
                                species.listId = item.listId
                            }
                        }
                    } else if (list.size() > 1 && idx == 0) {
                        def separator = activity.outputs[0].data.eventRemarks ? "; " : ""
                        activity.outputs[0].data.eventRemarks = activity.outputs[0].data.eventRemarks.concat("${separator}${record.'Coral Species'}")
                    }
                }

                coralObservations << [sampleId          : idx + 1,
                                      colourCodeLightest: record.'Lightest',
                                      colourCodeDarkest : record.'Darkest',
                                      colourCodeAverage : (Double.parseDouble(record.'Lightest Number') + Double.parseDouble(record."Darkest Number")) / 2,
                                      typeOfCoral       : record.'Coral Type' + " corals",
                                      coralSpecies      : species,
                                      speciesPhoto      : []]

                coralObservations?.each { coralObservation ->
                    activity.outputs[0].data.coralObservations << coralObservation
                }
            }

        }

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

public static double footToMeter(double foot){
    return (foot * 0.3048).round(2)
}
public static double meterToFoot(double meter){
    return (meter / 0.3048).round(2)
}

public static double celciusToFarenheit(double celcius){
    return ((9.0/5.0)*celcius + 32).round(2)
}
public static double farenheitToCelcius(double farenheit){
    return ((5.0/9.0)*(farenheit - 32)).round(2)
}