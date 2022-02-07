// Groovy Rest Client.
// > export PATH=$PATH:/Users/sat01a/All/j2ee/groovy-2.4.7/bin
// > cd /Users/sat01a/All/sat01a_git/merged/biocollect-3/scripts/RestClient
// > groovy RestClient.groovy
// To get the example post data, enable debugger at this.save and print the variable or right click and store as global variable.
// variable json string data will be printed in the console
// Use http://jsonformatter.org/ to format the data. (make sure to remove the " " around the string...)
// User must have a auth token [ ozatlasproxy.ala.org.au]

@Grapes([
        @Grab(group='org.codehaus.groovy.modules.http-builder', module='http-builder', version='0.7'),
        @Grab('org.apache.httpcomponents:httpmime:4.5.13'),
        @Grab('org.apache.poi:poi:3.10.1'),
        @Grab(group = 'commons-codec', module = 'commons-codec', version = '1.9'),
        @Grab('org.apache.poi:poi-ooxml:3.10.1')]
)
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import org.apache.poi.ss.usermodel.*
import java.nio.file.Paths
import static java.util.UUID.randomUUID
import groovy.json.JsonSlurper

import groovyx.net.http.HTTPBuilder
import org.apache.http.entity.mime.MultipartEntityBuilder
import org.apache.http.entity.mime.content.FileBody
import groovyx.net.http.Method
import groovyx.net.http.ContentType

// Import Configuration
def DEBUG_AND_VALIDATE = false;
def PROJECT_ID = "665b17e8-c950-4785-b0c3-e7cc89def22b"
def PROJECT_ACTIVITY_ID = "a87bdb6b-2c90-427a-bd48-d61797a95fb8"
def USERNAME = ""
def AUTH_KEY = ""
def xlsx = "data.xlsx"

SERVER_URL = "http://devt.ala.org.au:8087"
SPECIES_URL = "/search/searchSpecies/${PROJECT_ACTIVITY_ID}?limit=1&hub=ecoscience&output=Simple%20Voucher%20Sample%20Collection&dataFieldName="
def ADD_NEW_ACTIVITY_URL = "/ws/bioactivity/save?pActivityId=${PROJECT_ACTIVITY_ID}&hub=ecoscience"
def SITE_TEMPLATE_FILE = "site_template.json"
def SITE_CREATION_URL = '/site/ajaxUpdate'
def SITE_LIST = '/site/ajaxList'
def IMAGE_UPLOAD_URL = "${SERVER_URL}/ws/attachment/upload"
def IMAGES_PATH = "photos/"


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
        //skip header
        if (row.getRowNum() <= 1) {
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
        println("Building activity: ${activityIndex + 1} starting excel row number : ${record."rowNumber"}")

        activity.projectId = PROJECT_ID

        TimeZone tz = TimeZone.getTimeZone("UTC");
        java.text.DateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'"); // Quoted "Z" to indicate UTC, no timezone offset
        df.setTimeZone(tz);
        String isoDate = ''
        try {
            isoDate = df.format(record."Date:")
        } catch (Exception ex) {
            println("Date format error ${activityIndex + 1}")
        }

        // Map fields
        def siteId = "";

        // Upload private site
        if (!record."Long" || !record."Lat") {
            println("Error: no Longitude or Latitude for site for ${activityIndex + 1}")
            activity = null
            return
        }

        println("Loading site data template file")
        String siteStr = new File(SITE_TEMPLATE_FILE).text
        def siteJsonSlurper = new groovy.json.JsonSlurper()
        def siteObject = siteJsonSlurper.parseText(siteStr)
        siteObject.pActivityId = PROJECT_ACTIVITY_ID
        siteObject.projectId = PROJECT_ID
        siteObject.site.projects = []
        siteObject.site.projects << PROJECT_ID
        siteObject.site.extent.geometry.centre = [] // Long and latitudide.
        siteObject.site.extent.geometry.centre << record."Long"
        siteObject.site.extent.geometry.centre << record."Lat"
        siteObject.site.extent.geometry.coordinates = [] // Long and latitudide.
        siteObject.site.extent.geometry.coordinates << record."Long"
        siteObject.site.extent.geometry.coordinates << record."Lat"
        siteObject.site.extent.geometry.decimalLongitude = record."Long"
        siteObject.site.extent.geometry.decimalLatitude = record."Lat"

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
            def statusCode = siteConnection.responseCode
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

        if (siteId && siteId != "") {
            activity.siteId = siteId
            activity.outputs[0].data.location = siteId
            activity.outputs[0].data.voucherNumber = record."Voucher number".isNumber() ?
                    record."Voucher number".substring(0,record."Voucher number".indexOf(".0")) : record."Voucher number" //this is to remove .0 at the end of numbers
            activity.outputs[0].data.recordedBy = record."Collector"
            activity.outputs[0].data.eventDate = isoDate
            activity.outputs[0].data.minimumElevationInMetres = record."Altitude (mASL)" ? record."Altitude (mASL)".toFloat().toInteger() : null
            activity.outputs[0].data.endemicity = record."Endemicity"
            activity.outputs[0].data.countAccuracy = record."Count accuracy"
            activity.outputs[0].data.taxonSubspecies = record."Subspecies or lower"
            activity.outputs[0].data.commonName = record."Common name"
            activity.outputs[0].data.lifeForm = record."Life form"
            activity.outputs[0].data.lifeStage = []
            activity.outputs[0].data.lifeStage << record."Life stage"
            activity.outputs[0].data.heightInMetres = record."Height (m)"
            activity.outputs[0].data.eventRemarks = record."Survey notes"

            activity.outputs[0].data.majorVegetationGroup = record."Major vegetation group"
            activity.outputs[0].data.majorVegetationSubGroup = record."Major vegetation sub-group"
            activity.outputs[0].data.aspectInDegrees = record."Aspect (degrees)"
            activity.outputs[0].data.landscapeContext = record."Position in the landscape"
            activity.outputs[0].data.geologyCategorical = record."Geology"

            activity.outputs[0].data.vegetationCover[0].vegetationType = record."Vegetation type"
            activity.outputs[0].data.vegetationCover[0].canopyCoverInPercentClass = record."Canopy cover (%)"
            activity.outputs[0].data.vegetationCover[0].vegetationStructuralFormation = record."Structural formation class"

            //assess slope and select correct slope class
            if(record."Slope (degrees)") {
                def separator = activity.outputs[0].data.eventRemarks ? " , " : ""
                activity.outputs[0].data.eventRemarks += separator + "Measured terrain slope = ${record."Slope (degrees)"} degrees"

                def slope = record."Slope (degrees)".toFloat()

                def slopeClass = null

                if(slope < 1) { slopeClass = "LE - Level (< 1%)" }
                else if (slope >= 1 && slope < 3) { slopeClass = "VG - Very gentle (1 - 3%)" }
                else if (slope >= 3 && slope < 10) { slopeClass = "GE - Gentle (3 - 10%)" }
                else if (slope >= 10 && slope < 32) { slopeClass = "MO - Moderately inclined (10 - 32%)" }
                else if (slope >= 32 && slope < 56) { slopeClass = "ST - Steep (32 - 56%)" }
                else if (slope >= 56 && slope <= 100) { slopeClass = "VS - Very steep (56 -100%)" }
                else if (slope > 100) { slopeClass = "PR - Precipitous (> 100%)" }

                if(!slopeClass) {
                    println("Slope class error:" + slope)
                }
                else {
                    activity.outputs[0].data.slopeCategorical = slopeClass
                }
            }

            if(record."Count") {
                if (record."Count" == "a few" || record."Count" == "many" || record."Count" == "several") {
                    def separator = activity.outputs[0].data.eventRemarks ? " , " : ""
                    activity.outputs[0].data.eventRemarks += separator + "Observation count recorded as ${record."Count"}"
                }
                else if(record."Count".contains(">")){
                    activity.outputs[0].data.individualCount = record."Count".split(">")[1].toFloat().toInteger().toString()
                    def separator = activity.outputs[0].data.eventRemarks ? " , " : ""
                    activity.outputs[0].data.eventRemarks += separator + "Observation count recorded as ${record."Count"}"
                }
                else{
                    activity.outputs[0].data.individualCount = record."Count".toFloat().toInteger().toString()
                }
            }

            if(record."Family (Scientific Name Only)") {
                activity.outputs[0].data.taxonFamily = getSpecies(record."Family (Scientific Name Only)", "taxonFamily")
            }
            if(record."Genus (Scientific Name Only)") {
                activity.outputs[0].data.taxonGenus = getSpecies(record."Genus (Scientific Name Only)", "taxonGenus")
            }

            if(record."Species (Scientific Name Only)") {
                //full species name is genus + species name + sub species
                String speciesName = record."Genus (Scientific Name Only)" + " " + record."Species (Scientific Name Only)" + (record."Subspecies or lower" ? " subsp. " + record."Subspecies or lower" : "")
                activity.outputs[0].data.scientificName = getSpecies(speciesName, "scientificName")
            }

            activity.outputs[0].data.voucherImage = []

            if (record."Photo") {
                def photoList = record.'Photo'.split(",")

                photoList.each {
                    def sightingPhoto = []
                    String fileName = it
                    boolean fileUploadSuccessful = false;

                    //stage the photo first
                    if (fileName) {
                        try {
                            File newFile
                            def mimeType = "image/jpeg"
                            fileName = fileName.trim()
                            newFile = new File(IMAGES_PATH + fileName + ".JPG")

                            if (!newFile.exists()) {
                                newFile = new File(IMAGES_PATH + fileName + ".jpg")
                            }

                            if (newFile.exists()) {
                                fileUploadSuccessful = true;

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
                                        if (documents) {
                                            def documentsMap = new JsonSlurper().parseText(documents)
                                            sightingPhoto << documentsMap?.files?.get(0)
                                            println("Image upload successful. ")
                                            fileUploadSuccessful = true;
                                        } else {
                                            println("Image upload unsuccessful. ")
                                        }
                                    }
                                }

                            } else {
                                println("File not found - ${fileName}")
                            }

                        } catch (Exception e) {
                            println("Error downloading image " + e)
                        }

                    }

                    if (fileUploadSuccessful) {

                        def photo =[:]

                        photo.dateTaken = sightingPhoto[0].isoDate
                        photo.contentType = sightingPhoto[0].contentType
                        photo.url = sightingPhoto[0].url
                        photo.filesize = sightingPhoto[0].size
                        photo.thumbnailUrl = sightingPhoto[0].thumbnail_url
                        photo.filename = sightingPhoto[0].name
                        photo.attribution = ""
                        photo.licence = "CC BY 3.0"
                        photo.notes = ""
                        photo.name = sightingPhoto[0].name
                        photo.formattedSize = "${sightingPhoto[0].size/1024} KB"
                        photo.staged = true
                        photo.status = "active"
                        photo.documentId = ""

                        activity.outputs[0].data.voucherImage << photo
                    }
                }

            }

            activity.outputs[0].data.vegetationSpeciesComposition = []

            if (record.'Species names' || record."Species short name (or voucher name)") {
                def list = record.'Species names'.split(",")

                list.each {
                    def speciesComposition = [speciesShortName:'', individualCount:'', scientificName:'', speciesImage:[]]

                    speciesComposition.speciesShortName = record."Species short name (or voucher name)"
                    //if count is not set the default is one, since the record of species
                    speciesComposition.individualCount = record."Individual Count" ? record."Individual Count".toFloat().toInteger() : 1
                    speciesComposition.scientificName = getSpecies(it as String, "scientificName")

                    activity.outputs[0].data.vegetationSpeciesComposition << speciesComposition
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