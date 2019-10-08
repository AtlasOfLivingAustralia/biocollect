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
def USERNAME = ""
def AUTH_KEY = ""
def xlsx = "data.xlsx"

def IMAGES_PATH = "//Users//sat01a//All//HCAS_Photos//"
def DATA_TEMPLATE_FILE = "data_template.json"
def SITE_TEMPLATE_FILE = "site_template.json"

def SERVER_URL = "https://biocollect.ala.org.au"
def ADD_NEW_ACTIVITY_URL = "/ws/bioactivity/save?pActivityId="
def IMAGE_UPLOAD_URL = 'https://biocollect.ala.org.au/ws/attachment/upload'
def header = []
def values = []
def fileNotFound = []

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
        if (activityIndex >= 0 && activityIndex < activities?.size()) {
        //if (activityIndex >= 0 && activityIndex <= 0) {
            record = activityRow
            def jsonSlurper = new groovy.json.JsonSlurper()
            def activity = jsonSlurper.parseText(jsonStr)

            // Reset sightings photo.
            activity.outputs[0].data.sightingPhoto = []
            activity.projectId = record."project id"
            println("-----START----")
            println("-----${activityIndex}----")
            // Upload photos to the staging area.
            def sightingPhotos = []
            String fileName = record."sitePhoto";
            boolean fileUploadSuccessful = false;
            if (fileName && !DEBUG_AND_VALIDATE) {
                    try {
                        File newFile
                        //println("Filename: "+ IMAGES_PATH+fileName)
                        def mimeType = "image/jpeg"
                        fileName = fileName.trim()
                        newFile = new File(IMAGES_PATH+fileName)
                        if(!newFile.exists()) {
                            newFile = new File(IMAGES_PATH+fileName+".JPG")
                        }
                        if(!newFile.exists()) {
                            newFile = new File(IMAGES_PATH+fileName+".JPEG")
                        }
                        if(!newFile.exists()) {
                            newFile = new File(IMAGES_PATH+fileName+".jpeg")
                        }
                        if(!newFile.exists()) {
                            newFile = new File(IMAGES_PATH+fileName+".jpg")
                        }
                        if(!newFile.exists()) {
                            newFile = new File(IMAGES_PATH+fileName+".png")
                            mimeType = "image/png"
                        }

                        if(newFile.exists()) {
                            fileUploadSuccessful  = true;
                            //println("mimeType > ${mimeType}");

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
                                        println("Image upload successful. ")
                                        fileUploadSuccessful  = true;
                                    } else {
                                        println("Image upload unsuccessful. ")
                                    }
                                }
                            }

                        } else {
                            println("File not found - ${fileName}")
                            fileNotFound << fileName
                        }

                    } catch(Exception e) {
                        println("Error downloading image " + e)
                    }

            }

            activity.outputs[0].data.recordedBy = record."recordedBy" instanceof String ? (record."recordedBy")?.trim() : ''
            activity.outputs[0].data.mvgGroup = record."mvgGroup" instanceof String ? (record."mvgGroup")?.trim() : ''
            activity.outputs[0].data.huchinsonGroup = record."huchinsonGroup" instanceof String ? (record."huchinsonGroup")?.trim() : ''
            activity.outputs[0].data.comments = record.comments instanceof String ? (record."comments")?.trim() : ''
            activity.outputs[0].data.completionStatus = ""

            activity.outputs[0].data.sitePhoto = [];
            for (i = 0; i < sightingPhotos.size(); i++) {
                activity.outputs[0].data.sitePhoto << sightingPhotos.get(i)
            }

            if (!DEBUG_AND_VALIDATE) {
                //println(new groovy.json.JsonBuilder( activity ).toString())
            }
            println("-----END----")


            def connection = new URL("${SERVER_URL}${ADD_NEW_ACTIVITY_URL}"+record."survey id").openConnection() as HttpURLConnection
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
                println connection.responseCode + ":::::" + connection.inputStream.text + "|||" + ((int)Float.parseFloat(record."user id"))
            }

        }

    }
    println("Total image file not found = ${fileNotFound?.size()}");
    println(fileNotFound);
    println("Completed..")
}
