// Groovy Rest Client.
// > cd /Users/sat01a/All/sat01a_git/merged/biocollect-3/scripts/RestClient/gonna_watch
// > export PATH=$PATH:/Users/sat01a/All/j2ee/groovy-2.4.11/bin
// > groovy RestClient.groovy
// To get the example post data, enable debugger at this.save and print the variable or right click and store as global variable.
// variable json string data will be printed in the console
// Use http://jsonformatter.org/ to format the data. (make sure to remove the " " around the string...)
// User must have a auth token [ ozatlasproxy.ala.org.au]
// Generating UUID on the device: python -c 'import uuid; print str(uuid.uuid1())'

//Go through insect_upload_log and delete submitted activity id.
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
def LOG_FILE = "upload_log.txt"
File logFile = new File(LOG_FILE)

if (!logFile.exists()) {
    println "File does not exist"
} else {
    def index = 0;
    logFile.eachLine { line ->
        if (line.startsWith("200:")) {
            def jsonStr = line?.replaceAll('200:', '')
            def jsonSlurper = new groovy.json.JsonSlurper()
            def result = jsonSlurper.parseText(jsonStr)
            println("Deleting Activity : ${index++} . " + result?.resp?.activityId);
            def activityId = result?.resp?.activityId

            try {
                def connection = new URL("https://biocollect.ala.org.au/ws/bioactivity/delete/" + activityId).openConnection() as HttpURLConnection
                // set some headers
                connection.setRequestProperty('userName', "${USERNAME}")
                connection.setRequestProperty('authKey', "${AUTH_KEY}")
                connection.setRequestProperty('Content-Type', 'application/json;charset=utf-8')
                connection.setRequestMethod("GET")
                connection.setDoOutput(true)
                java.io.OutputStreamWriter wr = new java.io.OutputStreamWriter(connection.getOutputStream(), 'utf-8')
                wr.flush()
                wr.close()
                println connection.responseCode + ": " + connection.inputStream.text
            } catch (java.io.IOException ex) {
                println("Error deleting activtityId - ${activityId}")
            }
        }
    }

}

