// Groovy Rest Client.
// > cd /Users/sat01a/All/sat01a_git/merged/biocollect-3/scripts/RestClient/gonna_watch
// > export PATH=$PATH:/Users/sat01a/All/j2ee/groovy-2.4.11/bin
// > groovy RestClient.groovy
// To get the example post data, enable debugger at this.save and print the variable or right click and store as global variable.
// variable json string data will be printed in the console
// Use http://jsonformatter.org/ to format the data. (make sure to remove the " " around the string...)
// User must have a auth token [ ozatlasproxy.ala.org.au]
// Generating UUID on the device: python -c 'import uuid; print str(uuid.uuid1())'

@Grapes([
        @Grab('org.codehaus.groovy.modules.http-builder:http-builder:0.7'),
        @Grab('org.apache.httpcomponents:httpmime:4.5.1'),
        @Grab('org.apache.poi:poi:3.10.1'),
        @Grab(group = 'commons-codec', module = 'commons-codec', version = '1.9'),
        @Grab('org.apache.poi:poi-ooxml:3.10.1')]
)
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import static org.apache.poi.ss.usermodel.Cell.*
import java.nio.file.Paths
import static java.util.UUID.randomUUID
import groovy.json.JsonSlurper

import groovyx.net.http.HTTPBuilder
import org.apache.http.entity.mime.MultipartEntityBuilder
import org.apache.http.entity.mime.content.FileBody
import groovyx.net.http.Method
import groovyx.net.http.ContentType

// IMPORTANT CONFIGURATION
def DEBUG_AND_VALIDATE = false;
def PROJECT_ID = "dc147397-82c0-4754-854f-8014b8d0d470"

def USERNAME = "" // 510
def AUTH_KEY = ""
def xlsx = "data-cleaned.xlsx"

//def PROJECT_ACTIVITY_ID = "6ea589d6-252e-40ea-b63a-4b980dd7d8a1"
//def SUPPORTED_SPECIES = "Varanus rosenbergi"
//def IMAGES_PATH = "images//Varanus_rosenbergi//"
//def DATA_TEMPLATE_FILE = "data_template_Varanus_rosenbergi.json"


//def PROJECT_ACTIVITY_ID = "4eb242f1-0b60-4325-b11e-40ad13a5f4f2"
//def SUPPORTED_SPECIES = "Varanus giganteus"
//def IMAGES_PATH = "images//Varanus_giganteus//"
//def DATA_TEMPLATE_FILE = "data_template_Neil_Rankin_Surveys.json"

def PROJECT_ACTIVITY_ID = "534dfa1c-5b78-480e-9eb5-f26d087f9a77"
def SUPPORTED_SPECIES = "Varanus varius"
def IMAGES_PATH = "images//Varanus_varius//"
def DATA_TEMPLATE_FILE = "data_template_Varanus_varius.json"

// data_template_Varanus_gouldii
// def PROJECT_ACTIVITY_ID = "fc89081b-fe0f-442d-9016-a8e6d1a658dd"
// def SUPPORTED_SPECIES = "Varanus gouldii"
// def IMAGES_PATH = "images//Varanus_gouldii//"
// def DATA_TEMPLATE_FILE = "data_template_Varanus_gouldii.json"

//"data_template_current_surveys.json"
//def PROJECT_ACTIVITY_ID = "e14a3597-3dea-403b-845d-afee66beb5d1"
//def SUPPORTED_SPECIES = "Unknown"
//def IMAGES_PATH = "images//unknown//"
//def DATA_TEMPLATE_FILE = "data_template_current_surveys.json"


def SERVER_URL = "https://biocollect.ala.org.au"
def ADD_NEW_ACTIVITY_URL = "/ws/bioactivity/save?pActivityId=${PROJECT_ACTIVITY_ID}"
def IMAGE_UPLOAD_URL = 'https://biocollect.ala.org.au/ws/attachment/upload'

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
    def activities = values
    println("Total activities to upload = ${activities?.size()}")

    // Load default activity template file
    println("Loading data_template file")
    String jsonStr = new File(DATA_TEMPLATE_FILE).text

    // Loop through the activities
    activities?.eachWithIndex { activityRow, activityIndex ->

        if ((activityIndex >= 1 && activityIndex <= 183) && activityRow."species" == SUPPORTED_SPECIES) { // 183
            record = activityRow
            def jsonSlurper = new groovy.json.JsonSlurper()
            def activity = jsonSlurper.parseText(jsonStr)
            activity.projectId = PROJECT_ID

            println("-----START----")
            println(record."RECORD_ID")
            //Convert Date to UTC date.
            TimeZone tz = TimeZone.getTimeZone("UTC");
            java.text.DateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
            // Quoted "Z" to indicate UTC, no timezone offset
            df.setTimeZone(tz);
            java.text.DateFormat time = new java.text.SimpleDateFormat("hh:mm a");
            String isoDate = ''
            String isoDateTime
            try {
                isoDate = df.format(record."surveyStartDate");
                //isoDateTime = '12:00 AM' //record."surveyStartTime" ? time.format(record."surveyStartTime") : ''
                isoDateTime = time.format(record."surveyStartTime")
            } catch (Exception ex) {
                println("Date format error ${idx} >>  >> ${record."surveyStartTime"}")
            }

            // Upload photos to the stageing area.
            def sightingPhotos = []

            for (i = 0; i < 2; i++) {
                def address = (i == 0) ? record."sightingPhoto" : record."sightingPhoto1"
                if (address) {
                    def decoded = java.net.URLDecoder.decode(address, "UTF-8");
                    def fileNameToken = decoded?.split("&fileName=")
                    String fileName = fileNameToken?.size() > 0 ? fileNameToken[fileNameToken.size() - 1] : ""
                    fileName = activityIndex + "_" + i + "_" + fileName.replace(" ", "_")
                    List fileExtensionList = fileName?.tokenize(".")
                    String mimeType = fileExtensionList?.size() > 0 ? fileExtensionList[fileExtensionList.size() - 1] : ""
                    mimeType = mimeType?.toLowerCase()
                    switch (mimeType) {
                        case ".jpg":
                        case "jpg":
                        case ".jpeg":
                        case "jpeg":
                            mimeType = "image/jpeg"
                            break
                        case ".png":
                        case "png":
                            mimeType = "image/png"
                            break
                        default:
                            println("MIME type not supported." + mimeType)

                    }
                    println("Downloading image file...")
                    println("File name "+ IMAGES_PATH+fileName)
                    if (!DEBUG_AND_VALIDATE) {
                        try{
                            URL url = new URL(address)
                            File newFile = new File(IMAGES_PATH+fileName) << url.openStream()
                            def http = new HTTPBuilder(IMAGE_UPLOAD_URL)
                            println("Uploading image...")


                            http.request(Method.POST, ContentType.BINARY) { req ->
                                requestContentType: "multipart/form-data"
                                headers.userName = USERNAME
                                headers.authKey = AUTH_KEY
                                MultipartEntityBuilder multipartRequestEntity = new MultipartEntityBuilder()
                                multipartRequestEntity.addPart('files', new FileBody(newFile, mimeType))
                                req.entity = multipartRequestEntity.build()

                                response.success = { resp, data ->
                                    // Convert to map
                                    def documents = data?.getText()
                                    if(documents) {
                                        def documentsMap = new JsonSlurper().parseText(documents)
                                        sightingPhotos << documentsMap?.files?.get(0)
                                        println("Image upload successful. - ${i}")
                                    } else {
                                        println("Image upload unsuccessful. - ${i}")
                                    }
                                }
                            }
                        } catch(Exception e) {
                            println("Error downloading image" + e)
                        }

                    }
                }
            }

            activity.outputs[0].data.surveyStartDate = isoDate
            activity.outputs[0].data.surveyStartTime = isoDateTime
            activity.outputs[0].data.individualCount = 1
            activity.outputs[0].data.locationLatitude = record."locationLatitude"
            activity.outputs[0].data.locationLongitude = record."locationLongitude"
            activity.outputs[0].data.nearestLocationName = record."nearestLocationName" ? (record."nearestLocationName").trim(): ""
            activity.outputs[0].data.lifeStatus = record."lifeStatus" ? (record."lifeStatus").trim() : ""
            activity.outputs[0].data.distinguishingTraitsOnTail = (record."distinguishingTraitsOnTail")
            activity.outputs[0].data.distinguishingTraitsOnFace = (record."distinguishingTraitsOnFace")
            activity.outputs[0].data.distinguishingTraitsOnJaw = (record."distinguishingTraitsOnJaw")
            activity.outputs[0].data.landHolderStatus = (record."landHolderStatus")
            activity.outputs[0].data.notes = record."notes" ? (record."notes").trim() : ""
            activity.outputs[0].data.recordedBy = record."recordedBy" ? (record."recordedBy").trim() : ""

            for (i = 0; i < sightingPhotos.size(); i++) {
                activity.outputs[0].data.sightingPhoto << sightingPhotos.get(i)
            }

            // Custom mapping.
            def behaviour = (record."observedBehaviour") ? (record."observedBehaviour").trim() : ""
            switch(behaviour) {
                case "In a shrub (woody plant <5m)":
                case "In a tree (woody plant >5m)":
                    activity.outputs[0].data.observedBehaviour =  "Yes, the goanna climbed a tree"
                    break
                case "On ground":
                    activity.outputs[0].data.observedBehaviour =  "No, the goanna did not climb a tree"
                    break
                case "Other (please describe in the Notes section)" :
                    activity.outputs[0].data.observedBehaviour =  "I’m not sure"
                    break
                case "":
                    println ("Empty behaviour")
                    break
                default:
                    println ("Invalid behaviour")

            }

            def classRange = (record."fullLengthInMetresClassRange") ? (record."fullLengthInMetresClassRange").trim() : ""
            switch(classRange) {
                case "1.0-1.5 metres":
                    activity.outputs[0].data.fullLengthInMetresClassRange =  "1.0 – 1.5 metres"
                    break
                case "0.5-1.0 metres":
                    activity.outputs[0].data.fullLengthInMetresClassRange =  "0.5 – 1.0 metre"
                    break
                case "Less than 0.5 metres (50 centimetres)":
                    activity.outputs[0].data.fullLengthInMetresClassRange =  "Less than 0.5 metres (50 centimetres)"
                    break
                case "Over 1.5 metres":
                    activity.outputs[0].data.fullLengthInMetresClassRange =  "Over 1.5. metres"
                    break
                case "I'm not sure":
                    activity.outputs[0].data.fullLengthInMetresClassRange =  "I’m not sure"
                    break
                case "":
                    println ("Empty classRange")
                    break
                default:
                    println ("Invalid classRange")
            }

            if (DEBUG_AND_VALIDATE) {
                println(new groovy.json.JsonBuilder( activity ).toString())
            }
            println("-----END----")

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
