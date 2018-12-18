// Groovy Rest Client.
// > cd /Users/sat01a/All/sat01a_git/merged/biocollect-4/scripts/RestClient
// > export PATH=$PATH:/Users/sat01a/All/j2ee/groovy-2.4.11/bin
// > groovy RestClient.groovy
// To get the example post data, enable debugger at this.save and print the variable or right click and store as global variable.
// variable json string data will be printed in the console
// Use http://jsonformatter.org/ to format the data. (make sure to remove the " " around the string...)
// User must have a auth token [ ozatlasproxy.ala.org.au]
// Generating UUID on the device: python -c 'import uuid; print str(uuid.uuid1())'
// https://biocollect.ala.org.au/search/searchSpecies/58df20ef-0f2b-47d5-a632-b1fa84ffe376?limit=10&hub=ala&dataFieldName=species&output=Bird%20Survey%20-%20Western%20Sydney&q=

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
def xlsx = "data_load.xlsx"

def DATA_TEMPLATE_FILE = "data_template.json"
def SITE_TEMPLATE_FILE = "site_template.json"

def SERVER_URL = "https://biocollect.ala.org.au"
def ADD_NEW_ACTIVITY_URL = "/ws/bioactivity/save?pActivityId="
def IMAGE_UPLOAD_URL = 'https://biocollect.ala.org.au/ws/attachment/upload'
def SITE_CREATION_URL = '/site/ajaxUpdate'
def SPECIES_URL = "https://biocollect.ala.org.au/search/searchSpecies/58df20ef-0f2b-47d5-a632-b1fa84ffe376?limit=10&hub=ala&dataFieldName=species&output=Bird%20Survey%20-%20Western%20Sydney"

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

        if ((activityIndex >= 0 && activityIndex < activities?.size())) { // 183
        //if ((activityIndex >= 0 && activityIndex < 1)) { // 183
            record = activityRow
            def jsonSlurper = new groovy.json.JsonSlurper()
            def activity = jsonSlurper.parseText(jsonStr)

            // Reset sightings photo.
            activity.outputs[0].data.sightingPhoto = []

            println("-----${activityIndex}. START----")

            //Convert Date to UTC date.
            TimeZone tz = TimeZone.getTimeZone("UTC");
            java.text.DateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
            // Quoted "Z" to indicate UTC, no timezone offset
            df.setTimeZone(tz);
            java.text.DateFormat time = new java.text.SimpleDateFormat("hh:mm a");
            String isoDate = ""
            String isoStartTime = ""
            String isoEndTime = ""
            try {
                if(record."surveyStartDate") {
                    isoDate = df.format(record."surveyStartDate");
                    activity.outputs[0].data.surveyStartDate = isoDate

                }
                if(record."surveyFinishDate") {
                    isoDate = df.format(record."surveyFinishDate");
                    activity.outputs[0].data.surveyFinishDate = isoDate
                }
                if(record."Time") {
                    activity.outputs[0].data.surveyStartTime = "7:30 AM";
                }
                if(record."End Time") {
                    activity.outputs[0].data.surveyFinishTime = "9:30 AM";
                }
            } catch (Exception ex) {
                println("Date format error >>  >> ${ex}")
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
                    println("Attaching image: ${address}")
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

                } else {
                    //println("No image to attach")
                }
            }

            // Load default activity template file
            println("Loading site data template file")
            String siteStr = new File(SITE_TEMPLATE_FILE).text
            def siteJsonSlurper = new groovy.json.JsonSlurper()
            def siteObject = siteJsonSlurper.parseText(siteStr)
            siteObject.pActivityId = record."Survey ID"
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
            activity.outputs[0].data.surveyType = record."surveyType" instanceof String ? (record."surveyType")?.trim() : ''
            activity.outputs[0].data.notes = record."notes" instanceof String ? (record."notes")?.trim() : ''


            // Validate Abundance, Breeding and Habitat Code.
            def constraint1= ["A","B","C","D","E","X"];
            def constraint2= ["NB - nest","NY - young","DY - juvenile","B - breeding"];
            def constraint3= ["Not provided","Tidal Area","Mangroves","Saltmarsh","River (width >2m)","River (width <2m)","Freshwater Wetland (Lagoon/Swamp)","Sandstone Woodland",
                              "Heathland","Tall Smooth Euc. Forest","Casuarina Forest","Urban Area", "Parks/Gardens", "Restored Local Native Vegetation – Terrestrial","Restored Local Native Vegetation – Riparian"];


            //2 juveniles, female, NB-Nest
            switch(record."Breeding"){
                case "DY - juvenile" :
                case "juveniles present":
                    record."Breeding" = "DY - juvenile"
                    break;
                case "NB-Nest":
                case "NB - nest":
                    record."Breeding" = "NB - nest"
                    break;

            }
            if(record."Abundance" && !constraint1?.find{it == record."Abundance"}) {
                println("Warning:: Constraint 1: (${activityIndex}) >> "+ record."Abundance"  +" not in  constraint1 list")
            }

            if(record."Breeding" && !constraint2?.find{it == record."Breeding"}) {
                println("Warning:: Constraint 2: (${activityIndex}) >> "+ record."Breeding"  +" not in  constraint2 list")
            }

            if(record."Habitat Code" && !constraint3?.find{it == record."Habitat Code"}) {
                println("Warning:: Constraint 3: (${activityIndex}) >> "+ record."Habitat Code"  +" not in  constraint3 list")
            }

            activity.outputs[0].data.abundanceCode = record."Abundance" instanceof String ? (record."Abundance")?.trim() : ''
            activity.outputs[0].data.breedingStatus = record."Breeding" instanceof String ? (record."Breeding")?.trim() : ''
            activity.outputs[0].data.habitatCode = record."Habitat Code" instanceof String ? (record."Habitat Code")?.trim() : ''

            activity.outputs[0].data.locationLatitude = record."locationLatitude"
            activity.outputs[0].data.locationLongitude = record."locationLongitude"

            // Site information.
            activity.outputs[0].data.location = siteId
            activity.siteId = siteId

            // Get Unique Species Id
            def uniqueIdResponse = new URL(SERVER_URL + "/ws/species/uniqueId")?.text
            def jsonResponse = new groovy.json.JsonSlurper()
            def outputSpeciesId = jsonResponse.parseText(uniqueIdResponse)?.outputSpeciesId

            // Get species name
            def species = [name: '', guid: '', scientificName: '', commonName: '', outputSpeciesId: outputSpeciesId, listId: "dr7900"]
            def rows = []
            def query = record."species"
            query = URLEncoder.encode(query, "UTF-8");
            def speciesResponse = new URL(SPECIES_URL + "&q=${query}").text
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
                    species.listId = "dr9563"
                }
            }
            def speciesSightings = []
            def speciesMap = [:]
            speciesMap.species = species
            Double count = Double.parseDouble(record."individualCount")
            speciesMap.individualCount = "${count.intValue()}"
            speciesMap.sightingComments = record."sightingComments" instanceof String ? (record."sightingComments")?.trim() : ''
            speciesMap.sightingPhoto = []
            speciesSightings << speciesMap
            activity.outputs[0].data.speciesSightings = speciesSightings

            for (i = 0; i < sightingPhotos.size(); i++) {
                activity.outputs[0].data.sightingPhoto << sightingPhotos.get(i)
            }

            println(new groovy.json.JsonBuilder( activity ).toString())


            if(siteId) {
                def connection = new URL("${SERVER_URL}${ADD_NEW_ACTIVITY_URL}"+record."Survey ID").openConnection() as HttpURLConnection
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
                println("Error: (${activityIndex}) activity creation skipped due to missing siteId")
            }

            println("-----END----")
        }
    }

    println("Completed..")
}
