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

def SIGHTINGS_URL = "https://biocollect.ala.org.au/sightings/project/getMembersForProjectIdPaginated/f813c99c-1a1d-4096-8eeb-cbc40e321101";
    println("Building sightings users")
    def start = 0;
    for(int i=0; i < 86; i++) {
        def SIGHTINGS = SIGHTINGS_URL + "?start=${start}"+ "&length=100";
        start = start + 100
        def connection = new URL("${SIGHTINGS}").openConnection() as HttpURLConnection

        connection.setRequestProperty('Cookie', '')
        connection.setRequestProperty('Content-Type', 'application/json;charset=utf-8');
        connection.setRequestMethod("POST");
        connection.setDoOutput(true);
        def jsonSlurper = new groovy.json.JsonSlurper()
        def response = jsonSlurper.parseText(connection.inputStream.text)
        def rows = response?.data
        rows?.each {
            println(it."userId" + "||||" + it."userName" + "||||"+ it."displayName")
        }
        Thread.sleep(1000)
    }

    println("Done - index = ${start} ")


