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
def USERNAME = "" // 510
def AUTH_KEY = ""
def xlsx = "NonCaneRust_FungiAgents.xlsx"

//def PROJECT_ACTIVITY_ID = ""

def IMAGES_PATH = "images//"
def DATA_TEMPLATE_FILE = "data_template.json"
def SITE_TEMPLATE_FILE = "site_template.json"

def SERVER_URL = "https://biocollect.ala.org.au"
def ADD_NEW_ACTIVITY_URL = "/ws/bioactivity/save?pActivityId="
def IMAGE_UPLOAD_URL = 'https://biocollect.ala.org.au/ws/attachment/upload'
def SITE_CREATION_URL = '/site/ajaxUpdate'
def header = []
def values = []
def invalidSpeciesConfigurations = []
def listTargetAgents = ["6aa5f403-e218-4799-b1bf-c66798de821d"]
// https://biocollect.ala.org.au/ala/project/index/56491ea9-f10b-45b0-a645-c7674e31be96
// Slender thistle biocontrol
println("Reading ${xlsx} file")
Paths.get(xlsx).withInputStream { input ->
    def workbook = new XSSFWorkbook(input)
    def sheet = workbook.getSheetAt(0)
    // TODO - > ROW HEADER CHANGED
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
        //if ((activityIndex >= 0 && activityIndex < activities?.size())) { // 183
        if (activityIndex >= 0 && activityIndex < activities?.size()) { // && activityRow.'BioCollect Project ID' != '56491ea9-f10b-45b0-a645-c7674e31be96'
            //sleep(2000)
            record = activityRow
            def jsonSlurper = new groovy.json.JsonSlurper()
            def activity = jsonSlurper.parseText(jsonStr)

            // Reset sightings photo.
            activity.outputs[0].data.sightingPhoto = []
            activity.projectId = record."BioCollect Project ID"
            println("-----START----")
            println("-----${activityIndex}----")
            try{
                def SPECIES_URL = "/search/searchSpecies/" + record."BioCollect Survey ID"+ "?limit=1&output=Weed%20Biological%20Control%20-%20Agent%20Record%20-%20Non%20cane%20rust%20and%20fungi%20agents"
                // Get species name
                def targetSpecies = [name: '', guid: '', scientificName: '', commonName: '']
                def url = SERVER_URL + SPECIES_URL + "&dataFieldName=targetSpecies"
                if(listTargetAgents?.find{it == record."BioCollect Survey ID"}) {
                    url = url + "&q=" + java.net.URLEncoder.encode(record.'targetSpecies', 'UTF-8')
                }


                def speciesResponse = new URL(url)?.text
                def speciesJSON = new groovy.json.JsonSlurper()
                def autoCompleteList = speciesJSON?.parseText(speciesResponse)?.autoCompleteList
                if(autoCompleteList?.size() == 0) {
                    println("autoCompleteList is empty")
                }

                if (!autoCompleteList) {
                    targetSpecies.name = record.'targetSpecies'
                }

                autoCompleteList?.eachWithIndex { item, index ->
                    if (index == 0) {
                        targetSpecies.name = item.name
                        targetSpecies.guid = item.guid
                        targetSpecies.scientificName = item.scientificName
                        targetSpecies.commonName = item.commonName
                    }
                }

                activity.outputs[0].data.targetSpecies = targetSpecies

                // Get Agent Species.
                def agentSpecies = [name: '', guid: '', scientificName: '', commonName: '']
                def url2 = SERVER_URL + SPECIES_URL + "&dataFieldName=agentSpecies"

                def agentSpeciesResponse = new URL(url2).text
                def agentSpeciesJSON = new groovy.json.JsonSlurper()
                def agentAutoCompleteList = agentSpeciesJSON?.parseText(agentSpeciesResponse)?.autoCompleteList

                if(agentAutoCompleteList?.size() == 0) {
                    println("agentAutoCompleteList is empty")
                }


                if (!agentAutoCompleteList) {
                    agentSpecies.name = record.'agentSpecies'
                }

                agentAutoCompleteList?.eachWithIndex { item, index ->
                    if (index == 0) {
                        agentSpecies.name = item.name
                        agentSpecies.guid = item.guid
                        agentSpecies.scientificName = item.scientificName
                        agentSpecies.commonName = item.commonName
                    }
                }
                activity.outputs[0].data.agentSpecies = agentSpecies
            } catch (Exception ex) {
                def found = invalidSpeciesConfigurations?.find{it == record."BioCollect Survey ID"}
                if(!found) {
                    invalidSpeciesConfigurations << record."BioCollect Survey ID"
                }
                println("ERROR : Autocomplete failed " + ex)
            }


            //Convert Date to UTC date.
            TimeZone tz = TimeZone.getTimeZone("UTC");
            java.text.DateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
            // Quoted "Z" to indicate UTC, no timezone offset
            df.setTimeZone(tz);
            java.text.DateFormat time = new java.text.SimpleDateFormat("hh:mm a");
            String isoDate = ""
            String isoDateTime = ""
            try {
                if(record."eventDate") {
                    isoDate = df.format(record."eventDate");
                    record."eventDate" = isoDate
                }
                if(record."eventTime") {
                    isoDateTime = time.format(record."eventTime")
                }

            } catch (Exception ex) {
                println("Date format error >>  >> ${record."eventTime"}")
            }

            // Upload photos to the staging area.
            def sightingPhotos = []
            String address = ""
            for (i = 0; i < 4; i++) {
                switch(i) {
                    case 0:
                        address = record."sightingPhoto";
                        break;
                    case 1:
                        address = record."sightingPhoto1";
                        break;
                    case 2:
                        address = record."sightingPhoto2";
                        break;
                    case 3:
                        address = record."sightingPhoto3";
                        break;
                }

                if (address) {
                    def decoded = java.net.URLDecoder.decode(address, "UTF-8");
                    def fileNameToken = decoded?.split("&fileName=")
                    String fileName = ""
                    if(fileNameToken?.size() > 0 && fileNameToken[fileNameToken.size() - 1] &&
                            fileNameToken[fileNameToken.size() - 1] != "false") {
                        fileName = fileNameToken[fileNameToken.size() - 1]
                    }

                    if(fileName) {
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
                                println("MIME type not supported. - ${fileName} >> " + mimeType)
                        }
                        println("Downloading image file...${IMAGES_PATH+fileName}")
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

                } else {
                    // "No image to attach"
                }
            }

            // Upload sites

            // Load default activity template file
            println("Loading site data template file")
            String siteStr = new File(SITE_TEMPLATE_FILE).text
            def siteJsonSlurper = new groovy.json.JsonSlurper()
            def siteObject = siteJsonSlurper.parseText(siteStr)
            siteObject.pActivityId = record."BioCollect Survey ID"
            siteObject.site.projects = []
            siteObject.site.projects << record."BioCollect Project ID"
            siteObject.site.extent.geometry.centre = [] // Long and latitudide. (example: long 136.)
            siteObject.site.extent.geometry.centre << record."locationLongitude"
            siteObject.site.extent.geometry.centre << record."locationLatitude"
            siteObject.site.extent.geometry.coordinates = [] // Long and latitudide. (example: long 136.)
            siteObject.site.extent.geometry.coordinates << record."locationLongitude"
            siteObject.site.extent.geometry.coordinates << record."locationLatitude"


            def siteConnection = new URL("${SERVER_URL}${SITE_CREATION_URL}").openConnection() as HttpURLConnection
            siteConnection.setRequestProperty('userName', "${USERNAME}")
            siteConnection.setRequestProperty('authKey', "${AUTH_KEY}")
            siteConnection.setRequestProperty('Content-Type', 'application/json;charset=utf-8')
            siteConnection.setRequestMethod("POST")
            siteConnection.setDoOutput(true)
            def siteId = "";
            if (!DEBUG_AND_VALIDATE) {
                java.io.OutputStreamWriter wr = new java.io.OutputStreamWriter(siteConnection.getOutputStream(), 'utf-8')
                wr.write(new groovy.json.JsonBuilder(siteObject).toString())
                wr.flush()
                wr.close()
                def statusCode = siteConnection.responseCode
                if (statusCode == 200 ){
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

            activity.outputs[0].data.recordedBy = record."recordedBy" instanceof String ? (record."recordedBy")?.trim() : ''
            activity.outputs[0].data.eventDate = record."eventDate"
            activity.outputs[0].data.eventTime = ""
            activity.outputs[0].data.observationId = record."observationId" instanceof String ? (record."recordedBy")?.trim() : ''


            def constraint0 = ["New release","Field observation"] // recordType
            def constraint1 = ["0","1 - 5","6 - 20","21 - 50","> 50","Not specified"] // numberOfTargetPlantsExaminedConstraints
            def constraint3 = ["None","Single plant","Several plants - scattered","Several plants - clustered","Many plants - scattered","Many plants - clustered","Not specified"] // numberOfAffectedPlants

            switch(record."numberOfTargetPlantsExamined"){
                case '6 -20':
                    record."numberOfTargetPlantsExamined" = '6 - 20'
                    break;
                case '21 -50':
                    record."numberOfTargetPlantsExamined" = '21 - 50'
                    break;

            }

            if(!constraint0?.find{it == record."recordType"}) {
                println("Warning:: Constraint 0: (${activityIndex}) >> "+ record."recordType"  +" not in  constraint0 list")
            }
            if(!constraint1?.find{it == record."numberOfTargetPlantsExamined"}) {
                println("Warning:: Constraint 1: (${activityIndex}) >> "+ record."numberOfTargetPlantsExamined"  +" not in  constraint1 list")
            }
            if(!constraint3?.find{it == record."numberOfAffectedPlants"}) {
                println("Warning:: Constraint 3: (${activityIndex}) >> "+ record."numberOfAffectedPlants"  +" not in  constraint3 list")
            }


            activity.outputs[0].data.numberOfTargetPlantsExamined = record."numberOfTargetPlantsExamined"
            activity.outputs[0].data.recordType = record."recordType"
            activity.outputs[0].data.numberOfAffectedPlants = record."numberOfAffectedPlants"

            activity.outputs[0].data.collectedBy = record."collectedBy" instanceof String ? (record."collectedBy")?.trim() : ''
            activity.outputs[0].data.verifiedBy = record."verifiedBy" instanceof String ? (record."verifiedBy")?.trim() : ''
            activity.outputs[0].data.observationNotes = record."observationNotes" instanceof String ? (record."observationNotes")?.trim() : ''
            activity.outputs[0].data.locationLocality = record."Locality" instanceof String ? (record."Locality")?.trim() : ''

            activity.outputs[0].data.locationAccuracy = ""
            activity.outputs[0].data.locationNotes = ""
            activity.outputs[0].data.locationSource = ""

            activity.outputs[0].data.locationLatitude = record."locationLatitude" //
            activity.outputs[0].data.locationLongitude = record."locationLongitude" //
            activity.outputs[0].data.state = record."state" instanceof String ? (record."state")?.trim() : ''
            activity.outputs[0].data.nearestTown = record."nearestTown" instanceof String ? (record."nearestTown")?.trim() : ''
            activity.outputs[0].data.moderatorComments = ""

            activity.outputs[0].data.location = siteId
            activity.siteId = siteId

            for (i = 0; i < sightingPhotos.size(); i++) {
                activity.outputs[0].data.sightingPhoto << sightingPhotos.get(i)
            }

            // Do data validation.
            if (!DEBUG_AND_VALIDATE) {
                println(new groovy.json.JsonBuilder( activity ).toString())
            }
            println("-----END----")

            if(siteId) {
                def connection = new URL("${SERVER_URL}${ADD_NEW_ACTIVITY_URL}"+record."BioCollect Survey ID").openConnection() as HttpURLConnection
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
            } else {
                if (!DEBUG_AND_VALIDATE) {
                    println("Error: (${activityIndex}) Activity creation skipped due to missing siteId")
                }
            }
        }
    }

    println("Wrong species configurations:")
    println(invalidSpeciesConfigurations)
    println("Completed..")
}
