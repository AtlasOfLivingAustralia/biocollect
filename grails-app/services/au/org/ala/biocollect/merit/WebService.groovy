/*
 * Copyright (C) 2013 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 */

package au.org.ala.biocollect.merit
import groovyx.net.http.HTTPBuilder
import grails.converters.JSON
import groovyx.net.http.Method
import org.apache.http.entity.mime.HttpMultipartMode
import org.apache.http.entity.mime.MultipartEntity
import org.apache.http.entity.mime.content.InputStreamBody
import org.apache.http.entity.mime.content.StringBody
import org.grails.web.converters.exceptions.ConverterException
import grails.web.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.web.multipart.MultipartFile

import javax.servlet.http.Cookie
import javax.servlet.http.HttpServletResponse
import java.nio.charset.StandardCharsets

import static org.apache.http.HttpHeaders.*

/**
 * Helper class for invoking ecodata (and other Atlas) web services.
 */
class WebService {
    private static APPLICATION_JSON = 'application/json'
    // Used to avoid a circular dependency during initialisation
    def getUserService() {
        return grailsApplication.mainContext.userService
    }
    
    def grailsApplication

    def get(String url, boolean includeUserId) {
        def conn = null
        try {
            conn = configureConnection(url, includeUserId)
            return responseText(conn)
        } catch (SocketTimeoutException e) {
            def error = [error: "Timed out calling web service. URL= ${url}."]
            log.error error
            return error
        } catch (Exception e) {
            def error = [error: "Failed calling web service. ${e.getClass()} ${e.getMessage()} URL= ${url}.",
                    statusCode: conn?.responseCode?:"",
                    detail: conn?.errorStream?.text]
            log.error error
            return error
        }
    }

    private int defaultTimeout() {
        grailsApplication.config.webservice.readTimeout as int
    }

    private URLConnection configureConnection(String url, boolean includeUserId, Integer timeout = null) {
        URLConnection conn = new URL(url).openConnection()

        def readTimeout = timeout?:defaultTimeout()
        conn.setConnectTimeout(grailsApplication.config.webservice.connectTimeout as int)
        conn.setReadTimeout(readTimeout)
        def user = getUserService().getUser()
        if (includeUserId && user) {
            conn.setRequestProperty(grailsApplication.config.app.http.header.userId, user.userId)
        }
        conn
    }

    /**
     * Proxies a request URL but doesn't assume the response is text based. (Used for proxying requests to
     * ecodata for excel-based reports)
     */
    def proxyGetRequest(HttpServletResponse response, String url, boolean includeUserId = true, boolean includeApiKey = false, Integer timeout = null) {

        HttpURLConnection conn = configureConnection(url, includeUserId)
        def readTimeout = timeout?:defaultTimeout()
        conn.setConnectTimeout(grailsApplication.config.webservice.connectTimeout as int)
        conn.setReadTimeout(readTimeout)

        if (includeApiKey) {
            conn.setRequestProperty("Authorization", grailsApplication.config.api_key);
        }

        def headers = [HttpHeaders.CONTENT_DISPOSITION]
        def resp = [status:conn.responseCode]
        if (conn.responseCode == 200) {
            response.setContentType(conn.getContentType())
            response.setContentLength(conn.getContentLength())

            headers.each { header ->
                response.setHeader(header, conn.getHeaderField(header))
            }
            response.status = conn.responseCode

            response.outputStream << conn.inputStream
        }
        else {
            resp.error = conn.inputStream?.text ?: 'An error occurred'
        }
        return resp

    }

    /**
     * Proxies a request URL with post data but doesn't assume the response is text based. (Used for proxying requests to
     * ecodata for excel-based reports)
     */
    def proxyPostRequest(HttpServletResponse response, String url, Map postBody, boolean includeUserId = true, boolean includeApiKey = false, Integer timeout = null) {

        def charEncoding = 'utf-8'

        HttpURLConnection conn = configureConnection(url, includeUserId)

        def readTimeout = timeout?:defaultTimeout()
        conn.setConnectTimeout(grailsApplication.config.webservice.connectTimeout as int)
        conn.setRequestProperty("Content-Type", "application/json;charset=${charEncoding}");
        conn.setRequestMethod("POST")
        conn.setReadTimeout(readTimeout)
        conn.setDoOutput ( true );

        if (includeApiKey) {
            conn.setRequestProperty("Authorization", grailsApplication.config.api_key);
        }

        OutputStreamWriter wr = new OutputStreamWriter(conn.getOutputStream(), charEncoding)
        wr.write((postBody as JSON).toString())
        wr.flush()
        wr.close()

        def headers = [HttpHeaders.CONTENT_DISPOSITION, HttpHeaders.TRANSFER_ENCODING]
        response.setContentType(conn.getContentType())
        response.setContentLength(conn.getContentLength())

        headers.each { header ->
            response.setHeader(header, conn.getHeaderField(header))
        }
        response.status = conn.responseCode

        // to make jqueryFiledownload plugin happy
        def cookie = new Cookie("filedownload","true")
        cookie.setPath("/")
        response.addCookie(cookie)

        response.outputStream << conn.inputStream
    }

    def get(String url) {
        return get(url, true)
    }

    def getJson(String url, Integer timeout = null, boolean includeApiKey = false) {
        def conn = null
        try {
            conn = configureConnection(url, true, timeout)
            if (includeApiKey) {
                conn.setRequestProperty("Authorization", grailsApplication.config.api_key);
            }
            conn.setRequestProperty(ACCEPT, MediaType.APPLICATION_JSON_VALUE)
            def json = responseText(conn)
            def result = JSON.parse(json)
            return result
        } catch (ConverterException e) {
            def error = ['error': "Failed to parse json. ${e.getClass()} ${e.getMessage()} URL= ${url}."]
            log.error error
            return error
        } catch (SocketTimeoutException e) {
            def error = [error: "Timed out getting json. URL= ${url}."]
            log.error error, e
            return error
        } catch (ConnectException ce) {
            log.info "Exception class = ${ce.getClass().name} - ${ce.getMessage()}"
            def error = [error: "ecodata service not available. URL= ${url}."]
            log.error error, ce
            return error
        } catch (Exception e) {
            log.info "Exception class = ${e.getClass().name} - ${e.getMessage()}"
            def error = [error: "Failed to get json from web service. ${e.getClass()} ${e.getMessage()} URL= ${url}.",
                         statusCode: conn?.responseCode?:"",
                         detail: conn?.errorStream?.text]
            log.error error.toString(), e
            return error
        }
    }

    /**
     * Reads the response from a URLConnection taking into account the character encoding.
     * @param urlConnection the URLConnection to read the response from.
     * @return the contents of the response, as a String.
     */
    def responseText(urlConnection) {

        def charset = 'UTF-8' // default
        def contentType = urlConnection.getContentType()
        if (contentType) {
            def mediaType = MediaType.parseMediaType(contentType)
            charset = (mediaType.charSet)?mediaType.charSet.toString():'UTF-8'
        }
        return urlConnection.content.getText(charset)
    }

    def doPostWithParams(String url, Map params) {
        def conn = null
        def charEncoding = 'utf-8'
        try {
            String query = ""
            boolean first = true
            for (String name:params.keySet()) {
                query+=first?"?":"&"
                first = false
                query+=name.encodeAsURL()+"="+params.get(name).encodeAsURL()
            }
            conn = new URL(url+query).openConnection()
            conn.setRequestMethod("POST")
            conn.setDoOutput(true)
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            conn.setRequestProperty("Authorization", grailsApplication.config.api_key);

            def user = getUserService().getUser()
            if (user) {
                conn.setRequestProperty(grailsApplication.config.app.http.header.userId, user.userId) // used by ecodata
                conn.setRequestProperty("Cookie", "ALA-Auth="+java.net.URLEncoder.encode(user.userName, charEncoding)) // used by specieslist
            }
            OutputStreamWriter wr = new OutputStreamWriter(conn.getOutputStream(), charEncoding)

            wr.flush()
            def resp = conn.inputStream.text
            wr.close()
            return [resp: JSON.parse(resp?:"{}"), statusCode: conn.responseCode] // fail over to empty json object if empty response string otherwise JSON.parse fails
        } catch (SocketTimeoutException e) {
            def error = [error: "Timed out calling web service. URL= ${url}.",
                         statusCode: conn?.responseCode?:"",
                         detail: conn?.errorStream?.text]
            log.error(error, e)
            return error
        } catch (Exception e) {
            def error = [error: "Failed calling web service. ${e.getMessage()} URL= ${url}.",
                         statusCode: conn?.responseCode?:"",
                         detail: conn?.errorStream?.text]
            log.error(error, e)
            return error
        }
    }

    def doPost(String url, Map postBody) {
        def conn = null
        def charEncoding = 'utf-8'
        try {
            conn = new URL(url).openConnection()
            conn.setDoOutput(true)
            conn.setRequestProperty("Content-Type", "application/json;charset=${charEncoding}");
            conn.setRequestProperty("Authorization", grailsApplication.config.api_key);

            def user = getUserService().getUser()
            if (user) {
                conn.setRequestProperty(grailsApplication.config.app.http.header.userId, user.userId) // used by ecodata
                conn.setRequestProperty("Cookie", "ALA-Auth="+java.net.URLEncoder.encode(user.userName, charEncoding)) // used by specieslist
            }
            OutputStreamWriter wr = new OutputStreamWriter(conn.getOutputStream(), charEncoding)
            wr.write((postBody as JSON).toString())
            wr.flush()
            def resp = conn.inputStream.text
            wr.close()
            return [resp: JSON.parse(resp?:"{}"), statusCode: conn.responseCode] // fail over to empty json object if empty response string otherwise JSON.parse fails
        } catch (SocketTimeoutException e) {
            def error = [error: "Timed out calling web service. URL= ${url}."]
            log.error(error, e)
            return error
        } catch (Exception e) {
            def error = [error: "Failed calling web service. ${e.getMessage()} URL= ${url}.",
                    statusCode: conn?.responseCode?:"",
                    detail: conn?.errorStream?.text]
            log.error(error.toString(), e.toString())
            return error
        }
    }

    Map doGet(String url, Map data) {
        URLConnection conn = null

        try {
            List params = []
            data?.each{ key, value->
                def strValue = value?.toString()
                params.add("${key}=${URLEncoder.encode(strValue ?: "", StandardCharsets.UTF_8.toString())}")
            }

            String serialParam = params.join('&');
            if(params.size()){
                url = url + '?' + serialParam
            }

            conn = new URL(url).openConnection()
            conn.setDoOutput(true)
            conn.setRequestMethod("GET")
            conn.setRequestProperty("Content-Type", "${APPLICATION_JSON};charset=${StandardCharsets.UTF_8.toString()}");
            conn.setRequestProperty("Authorization", grailsApplication.config.api_key);

            def user = getUserService().getUser()
            if (user) {
                conn.setRequestProperty(grailsApplication.config.app.http.header.userId, user.userId) // used by ecodata
                conn.setRequestProperty("Cookie", "ALA-Auth="+java.net.URLEncoder.encode(user.userName, StandardCharsets.UTF_8.toString())) // used by specieslist
            }
            def resp = conn.inputStream.text
            return [resp: JSON.parse(resp?:"{}"), statusCode: conn.responseCode] // fail over to empty json object if empty response string otherwise JSON.parse fails
        } catch (SocketTimeoutException e) {
            def error = [error: "Timed out calling web service. URL= ${url}."]
            log.error(error, e)
            return error
        } catch (Exception e) {
            def error = [error: "Failed calling web service. ${e.getMessage()} URL= ${url}.",
                         statusCode: conn?.responseCode?:"",
                         detail: conn?.errorStream?.text]
            log.error(error, e)
            return error
        }
    }

    def doDelete(String url) {
        url += (url.indexOf('?') == -1 ? '?' : '&') + "api_key=${grailsApplication.config.api_key}"
        def conn = null
        try {
            conn = new URL(url).openConnection()
            conn.setRequestMethod("DELETE")
            conn.setRequestProperty("Authorization", grailsApplication.config.api_key);
            def user = getUserService().getUser()
            if (user) {
                conn.setRequestProperty(grailsApplication.config.app.http.header.userId, user.userId)
            }
            return conn.getResponseCode()
        } catch(Exception e){
            log.error e
            return 500
        } finally {
            if (conn != null){
                conn?.disconnect()
            }
        }
    }

    /**
     * This function wraps the doDelete function. But it returns a Map to be consistent with other
     * webservice calls.
     * @param url
     * @return
     */
    Map deleteWrapper(url){
        def statusCode = doDelete(url)
        [resp: ['message':'delete webservice returned'], statusCode: statusCode]
    }

    /**
     * Forwards a HTTP multipart/form-data request to ecodata.
     * @param url the URL to forward to.
     * @param params the (string typed) HTTP parameters to be attached.
     * @param file the Multipart file object to forward.
     * @return [status:<request status>, content:<The response content from the server, assumed to be JSON>
     */
    def postMultipart(url, Map params, MultipartFile file, fileParam = 'files') {

        postMultipart(url, params, file.inputStream, file.contentType, file.originalFilename, fileParam)
    }

    /**
     * Forwards a HTTP multipart/form-data request to ecodata.
     * @param url the URL to forward to.
     * @param params the (string typed) HTTP parameters to be attached.
     * @param contentIn the content to post.
     * @param contentType the mime type of the content being posted (e.g. image/png)
     * @param originalFilename the original file name of the data to be posted
     * @param fileParamName the name of the HTTP parameter that will be used for the post.
     * @return [status:<request status>, content:<The response content from the server, assumed to be JSON>
     */
    def postMultipart(url, Map params, InputStream contentIn, contentType, originalFilename, fileParamName = 'files') {

        def result = [:]
        def user = userService.getUser()

        HTTPBuilder builder = new HTTPBuilder(url)
        builder.request(Method.POST) { request ->
            requestContentType : 'multipart/form-data'
            MultipartEntity content = new MultipartEntity(HttpMultipartMode.BROWSER_COMPATIBLE)
            if (contentIn) content.addPart(fileParamName, new InputStreamBody(contentIn, contentType, originalFilename?:fileParamName))
            params.each { key, value ->
                if (value) {
                    content.addPart(key, new StringBody(value.toString()))
                }
            }
            headers.'Authorization' = grailsApplication.config.api_key
            if (user) {
                headers[grailsApplication.config.app.http.header.userId] = user.userId
            }
            else {
                log.warn("No user associated with request: ${url}")
            }
            request.setEntity(content)

            response.success = {resp, message ->
                result.status = resp.status
                result.content = message
            }

            response.failure = {resp ->
                result.status = resp.status
                result.error = "Error POSTing to ${url}"
            }
        }
        result
    }
}
