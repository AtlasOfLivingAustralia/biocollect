// Groovy Rest Client.
// > export PATH=$PATH:/Users/sat01a/All/j2ee/groovy-2.4.7/bin
// > cd /Users/sat01a/All/sat01a_git/merged/biocollect-3/scripts/RestClient
// > groovy RestClient.groovy
// To get the example post data, enable debugger at this.save and print the variable or right click and store as global variable.
// variable json string data will be printed in the console
// Use http://jsonformatter.org/ to format the data. (make sure to remove the " " around the string...)
// User must have a auth token [ ozatlasproxy.ala.org.au]
// Generating UUID on the device: python -c 'import uuid; print str(uuid.uuid1())'

@Grapes([
        @Grab('org.apache.poi:poi:3.10.1'),
        @Grab(group = 'commons-codec', module = 'commons-codec', version = '1.9'),
        @Grab('org.apache.poi:poi-ooxml:3.10.1')]
)
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import static org.apache.poi.ss.usermodel.Cell.*
import java.nio.file.Paths
import static java.util.UUID.randomUUID

// Import Configuration
def DEBUG_AND_VALIDATE = false;
def PROJECT_ID = "f0caedd0-70fd-4388-adb8-8d26935fa6f7"
def PROJECT_ACTIVITY_ID = "80b4274a-b771-49dd-abdf-89e9b01ea1bc"
def USERNAME = ""
def AUTH_KEY = ""
def xlsx = "1_General_Weed_Sighting_WWWDataFeb2017.xlsx"


def SERVER_URL = "https://biocollect.ala.org.au"
def SPECIES_URL = "/search/searchSpecies/${PROJECT_ACTIVITY_ID}?limit=1&hub=ecoscience"
def ADD_NEW_ACTIVITY_URL = "/ws/bioactivity/save?pActivityId=${PROJECT_ACTIVITY_ID}&hub=ecoscience"

def header = []
def values = []

println("Reading ${xlsx} file")
Paths.get(xlsx).withInputStream { input ->
    def workbook = new XSSFWorkbook(input)
    def sheet = workbook.getSheetAt(0)

    for (cell in sheet.getRow(0).cellIterator()) {
        header << cell.stringCellValue
    }

    def headerFlag = true

    for (row in sheet.rowIterator()) {
        if (headerFlag) {
            headerFlag = false
            continue
        }
        def rowData = [:]
        for (cell in row.cellIterator()) {
            def value = ''

            switch (cell.cellType) {
                case CELL_TYPE_STRING:
                    value = cell.stringCellValue
                    break
                case CELL_TYPE_NUMERIC:
                    if (org.apache.poi.hssf.usermodel.HSSFDateUtil.isCellDateFormatted(cell)) {
                        value = cell.getDateCellValue()
                    } else {
                        value = cell.numericCellValue as String
                    }

                    break
                case CELL_TYPE_BLANK:
                    value = ""
                case CELL_TYPE_BOOLEAN:
                    value = cell.booleanCellValue
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
                        it."collectedBy" == entry."collectedBy" &&
                        it."surveyDate" == entry."surveyDate" &&
                        it."plotId" == entry."plotId" &&
                        it."surveyStartTime" == entry."surveyStartTime"
            }

            combinedRecords?.each {
                processedIds << it."uniqueId"
            }
            nestedActivities << combinedRecords
        }
    }

    println("Records nested under activities");
    println("Total activities = ${nestedActivities?.size()}")

    // Load default activity template file
    String jsonStr = new File('data_template.json').text

    // Loop through the activities
    nestedActivities?.eachWithIndex { activityRow, activityIndex ->

         if (activityIndex >= 0 && activityIndex <= 14 ) {

            def jsonSlurper = new groovy.json.JsonSlurper()
            def activity = jsonSlurper.parseText(jsonStr)
            println("Building activity: ${activityIndex}  with records : ${activityRow?.size()}")

            activity.projectId = PROJECT_ID
            activityRow?.eachWithIndex { record, idx ->
                TimeZone tz = TimeZone.getTimeZone("UTC");
                java.text.DateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'"); // Quoted "Z" to indicate UTC, no timezone offset
                df.setTimeZone(tz);
                java.text.DateFormat time = new java.text.SimpleDateFormat("hh:mm a");
                String isoDate = ''
                String isoDateTime
                try{
                    isoDate = df.format(record."surveyDate");
                    //isoDateTime = '12:00 AM' //record."surveyStartTime" ? time.format(record."surveyStartTime") : ''
                    isoDateTime = time.format(record."surveyStartTime")
                } catch (Exception ex){
                    println("Date format error ${idx} >>  >> ${record."surveyStartTime"}")
                }

                // Map generic fields
                if (idx == 0) {
                    activity.outputs[0].data.recordedBy = (record."recordedBy")?.trim()
                    activity.outputs[0].data.surveyDate = isoDate
                    activity.outputs[0].data.surveyStartTime = isoDateTime
                    activity.outputs[0].data.locationLatitude = (record."locationLatitude")
                    activity.outputs[0].data.locationLongitude = (record."locationLongitude")
                    activity.outputs[0].data.occurrenceDensity = (record."occurrenceDensity")
                    if((record."identificationConfidence")){
                        activity.outputs[0].data.identificationConfidence = (record."identificationConfidence") == 'certain' ? 'Certain' : ''
                    }
                }

                // Get Unique Species Id
                def uniqueIdResponse = new URL(SERVER_URL + "/ws/species/uniqueId")?.text
                def jsonResponse = new groovy.json.JsonSlurper()
                def outputSpeciesId = jsonResponse.parseText(uniqueIdResponse)?.outputSpeciesId

                // Get species name
                def species = [name: '', guid: '', scientificName: '', commonName: '', outputSpeciesId: outputSpeciesId]
                def rows = []
                def speciesResponse = new URL(SERVER_URL + SPECIES_URL + "&q=${record.'species'}").text
                def speciesJSON = new groovy.json.JsonSlurper()
                def autoCompleteList = speciesJSON.parseText(speciesResponse)?.autoCompleteList

                if (!autoCompleteList) {
                    species.name = record.'species'
                }

                autoCompleteList?.eachWithIndex { item, index ->
                    if (index == 0) {
                        species.name = item.name
                        species.guid = item.guid
                        species.scientificName = item.scientificName
                        species.commonName = item.commonName
                    }
                }
                activity.outputs[0].data.species = species


                // post data via web service.
            }

            def connection = new URL("${SERVER_URL}${ADD_NEW_ACTIVITY_URL}").openConnection() as HttpURLConnection

            // set some headers
            connection.setRequestProperty( 'userName', "${USERNAME}" )
            connection.setRequestProperty( 'authKey', "${AUTH_KEY}" )
            connection.setRequestProperty( 'Content-Type', 'application/json;charset=utf-8' )
            connection.setRequestMethod("POST")
            connection.setDoOutput(true)

            if(!DEBUG_AND_VALIDATE) {
                java.io.OutputStreamWriter wr = new java.io.OutputStreamWriter(connection.getOutputStream(), 'utf-8')
                wr.write(new groovy.json.JsonBuilder( activity ).toString())
                wr.flush()
                wr.close()
                // get the response code - automatically sends the request
                println connection.responseCode + ": " + connection.inputStream.text
            }

         }
    }

    println("Completed..")
}
