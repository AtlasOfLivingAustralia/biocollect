// Groovy Rest Client.
// > export PATH=$PATH:/Users/sat01a/All/j2ee/groovy-2.4.7/bin
// > cd /Users/sat01a/All/sat01a_git/merged/biocollect-3/scripts/RestClient
// > groovy RestClient.groovy
// To get the example post data, enable debugger at this.save and print the variable or right click and store as global variable.
// variable json string data will be printed in the console
// Use http://jsonformatter.org/ to format the data. (make sure to remove the " " around the string...)
// User must have a auth token [ ozatlasproxy.ala.org.au]

@Grapes([
        @Grab('org.apache.poi:poi:3.10.1'),
        @Grab(group = 'commons-codec', module = 'commons-codec', version = '1.9'),
        @Grab('org.apache.poi:poi-ooxml:3.10.1')]
)
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import org.apache.poi.ss.usermodel.*
import java.nio.file.Paths
import static java.util.UUID.randomUUID
import groovy.json.JsonSlurper

// Import Configuration
def DEBUG_AND_VALIDATE = false;
def PROJECT_ID = "665b17e8-c950-4785-b0c3-e7cc89def22b"
def PROJECT_ACTIVITY_ID = "661aba3c-c746-480e-b1aa-13697cdb3050"
def USERNAME = ""
def AUTH_KEY = ""
def xlsx = "Voucher Sample Collection - Quadrat _Delta Environmental_2021.xlsx"

SERVER_URL = "http://devt.ala.org.au:8087"
SPECIES_URL = "/search/searchSpecies/${PROJECT_ACTIVITY_ID}?limit=1&hub=ecoscience&output=Voucher%20Sample%20Collection%20-%20Quadrat&dataFieldName="
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

    for (cell in sheet.getRow(0).cellIterator()) {
        header << cell.stringCellValue
    }

    Iterator<Row> allRows = sheet.rowIterator()
    while (allRows.hasNext()) {
        Row row = allRows.next()
        //skip header
        if (row.getRowNum() == 0) {
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
        rowData << ["uniqueId": randomUUID() as String]
        values << rowData
    }

    println("Successfully loaded ${xlsx} file");
    // Group same elements in to an array.
    def nestedActivities = []
    def processedIds = []

    println("Combining records");
    values?.each { entry ->
        def alreadyProcessed = processedIds.findAll { entry."uniqueId" == it }
        if (!alreadyProcessed) {
            def combinedRecords = values?.findAll {
                it."location" == entry."location" &&
                        it."Date:" == entry."Date:" &&
                        it."Voucher number" == entry."Voucher number"
            }

            combinedRecords?.each {
                processedIds << combinedRecords[0]."uniqueId"
            }
            nestedActivities << combinedRecords
        }
    }

    println("Records nested under activities");
    println("Total activities = ${nestedActivities?.size()}")

    // Load default activity template file
    String jsonStr = new File('form_template.json').text

    // Loop through the activities
    nestedActivities?.eachWithIndex { activityRow, activityIndex ->

        def jsonSlurper = new groovy.json.JsonSlurper()
        def activity = jsonSlurper.parseText(jsonStr)

        println("***************")
        println("Building activity: ${activityIndex + 1} with records : ${activityRow?.size()} and starting excel row number : ${activityRow[0]."rowNumber"}")

        activity.projectId = PROJECT_ID

        activityRow?.eachWithIndex { record, idx ->
            TimeZone tz = TimeZone.getTimeZone("UTC");
            java.text.DateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'"); // Quoted "Z" to indicate UTC, no timezone offset
            df.setTimeZone(tz);
            String isoDate = ''
            try {
                isoDate = df.format(record."Date:")
            } catch (Exception ex) {
                println("Date format error ${activityIndex + 1}")
            }

            if (idx == 0) {
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
                if (statusCode == 200) {
                    def list = siteCheckNameConnection.inputStream.text;
                    def site_list = new JsonSlurper().parseText(list)

                    if (site_list.name.contains(record."location")) {
                        siteId = site_list.find { it.name == record."location" }.siteId
                    } else {
                        // Upload site
                        if (!record."Long (dec)" || !record."Lat (dec)") {
                            println("Error: no Longitude or Latitude for site for ${activityIndex + 1} ${record."location"}")
                            activity = null
                            return
                        }

                        println("Loading site data template file")
                        String siteStr = new File(SITE_TEMPLATE_FILE).text
                        def siteJsonSlurper = new groovy.json.JsonSlurper()
                        def siteObject = siteJsonSlurper.parseText(siteStr)
                        siteObject.pActivityId = PROJECT_ACTIVITY_ID
                        siteObject.projectId = PROJECT_ID
                        siteObject.site.name = record."location"
                        siteObject.site.projects = []
                        siteObject.site.projects << PROJECT_ID
                        siteObject.site.extent.geometry.centre = [] // Long and latitudide.
                        siteObject.site.extent.geometry.centre << record."Long (dec)"
                        siteObject.site.extent.geometry.centre << record."Lat (dec)"
                        siteObject.site.extent.geometry.coordinates = [] // Long and latitudide.
                        siteObject.site.extent.geometry.coordinates << record."Long (dec)"
                        siteObject.site.extent.geometry.coordinates << record."Lat (dec)"
                        siteObject.site.extent.geometry.decimalLongitude = record."Long (dec)"
                        siteObject.site.extent.geometry.decimalLatitude = record."Lat (dec)"

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
                }

                if (siteId && siteId != "") {
                    activity.siteId = siteId
                    activity.outputs[0].data.voucherNumber = record."Voucher number"
                    activity.outputs[0].data.recordedBy = record."Collector"
                    activity.outputs[0].data.eventDate = isoDate
                    activity.outputs[0].data.quadratId = record."Quadrat number" ? record."Quadrat number".toFloat().toInteger().toString() : null
                    activity.outputs[0].data.minimumElevationInMetres = record."Altitude (mASL)" ? record."Altitude (mASL)".toFloat().toInteger() : null
                    activity.outputs[0].data.endemicity = record."Endemicity"
                    activity.outputs[0].data.countAccuracy = record."Count accuracy"
                    activity.outputs[0].data.commonName = record."Common name"
                    activity.outputs[0].data.lifeForm = record."Life form"
                    activity.outputs[0].data.lifeStage = []
                    activity.outputs[0].data.lifeStage << record."Life stage"
                    activity.outputs[0].data.heightInMetres = record."Height (m)"
                    activity.outputs[0].data.eventRemarks = record."Survey notes"

                    if(record."Count" && record."Count" == "abundant") {
                        activity.outputs[0].data.individualCount = "100"
                        def separator = activity.outputs[0].data.eventRemarks ? " , " : ""
                        activity.outputs[0].data.eventRemarks += separator + "Observation count recorded as Abundant"
                    }
                    else if(record."Count"){
                        activity.outputs[0].data.individualCount = record."Count".toFloat().toInteger().toString()
                    }

                    activity.outputs[0].data.location = siteId

                    if(record."Species (Scientific Name Only)") {
                        //full species name is genus + species name + sub species
                        String speciesName = record."Genus (Scientific Name Only)" + " " + record."Species (Scientific Name Only)" + (record."Subspecies or lower" ? " subsp. " + record."Subspecies or lower" : "")
                        activity.outputs[0].data.scientificName = getSpecies(speciesName, "scientificName")
                    }
                    else if(record."Genus (Scientific Name Only)") {
                        activity.outputs[0].data.scientificName = getSpecies(record."Genus (Scientific Name Only)", "scientificName")
                    }
                    else if(record."Family (Scientific Name Only)") {
                        activity.outputs[0].data.scientificName = getSpecies(record."Family (Scientific Name Only)", "scientificName")
                    }
                }
            }
        }

        if(activity) {
//             post data via web service.
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

Object getSpecies(String name, String dataField){
    def species = [name: '', guid: '', scientificName: '', commonName: '', outputSpeciesId: '', listId: '']

    species.outputSpeciesId = UUID.randomUUID().toString()

    // Get species name
    def speciesResponse = new URL(SERVER_URL + SPECIES_URL + dataField + "&q=${name.trim().replace(" ", "+")}").text
    def speciesJSON = new groovy.json.JsonSlurper()
    def autoCompleteList = speciesJSON.parseText(speciesResponse)?.autoCompleteList

    if (!autoCompleteList) {
        species.name = name
    }

    //There are separate lists for family, genus and species, Therefore first match will be taken.
    autoCompleteList?.eachWithIndex { item, index ->
        if (index == 0) {
            species.name = item.name
            species.guid = item.guid
            species.scientificName = item.scientificName
            species.commonName = item.commonName
            species.listId = item.listId
        }
    }

    return species
}