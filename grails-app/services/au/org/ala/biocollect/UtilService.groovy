package au.org.ala.biocollect

import au.org.ala.web.AuthService
import groovyx.net.http.HTTPBuilder
import groovyx.net.http.Method
import org.apache.http.HttpStatus
import org.apache.http.entity.mime.HttpMultipartMode
import org.apache.http.entity.mime.MultipartEntity
import org.apache.http.entity.mime.content.FileBody

//import org.apache.http.entity.mime.content.ByteArrayBody
//import org.apache.http.entity.mime.content.InputStreamBody
import org.apache.http.entity.mime.content.StringBody
import org.springframework.context.MessageSource

import java.nio.charset.StandardCharsets

class UtilService {
    AuthService authService
    MessageSource messageSource

    /**
     * Post a HTTP multipart/form-data request to external web sites.
     * @param url the URL to forward to.
     * @param params the (string typed) HTTP parameters to be attached.
     * @inputStreanMap [contentIn: <Input Stream>, contentInfo: [contentType: <content type for eg. json string, zip>, contentName: <can be file name or any name given to the content>]]
     * @return [status:<request status>, content:<The response content from the server, assumed to be JSON>
     */
    def postMultipart(url, Map params, List<Map> inputStreamListMap, String authenticationKey = null) {

        def result = [:]


        try {
            HTTPBuilder builder = new HTTPBuilder(url)
            builder.request(Method.POST) { request ->
                requestContentType: 'multipart/form-data'
                MultipartEntity content = new MultipartEntity(HttpMultipartMode.BROWSER_COMPATIBLE)

                inputStreamListMap.each {
                    Map contentInfo = it.contentInfo
                    if (it.contentIn && contentInfo.contentType == "application/zip") {
                        //   content.addPart(contentInfo.contentName, new ByteArrayBody(it.contentIn, contentInfo.contentType, contentInfo.contentName + ".zip"))
                        content.addPart(contentInfo.contentName, new FileBody(it.contentIn, contentInfo.contentType))
                    } else if (it.contentIn && contentInfo.contentType == "application/json") {
                        content.addPart(contentInfo.contentName, new StringBody(it.contentIn, contentInfo.contentType, StandardCharsets.UTF_8))
                    }
                }
                params.each { key, value ->
                    if (value) {
                        content.addPart(key, new StringBody(value.toString()))
                    }
                }

                if (authenticationKey) {
                    def encoded = authenticationKey.bytes.encodeBase64().toString()
                    headers["Authorization"] = "Basic " + encoded
                }

                request.setEntity(content)

                response.success = { resp, message ->
                    result.status = resp.status
                    result.content = message
                }

                response.failure = { resp, message ->
                    result.status = resp.status
                    result.content = "Error submitting to ${url}. Shared code: " + message?.sharedErrorCode ?: '' + " Shared message: " + message?.message ?: ""
                }
            }

        } catch (Exception e) {
            e.printStackTrace()
            log.error("Failed sending request to ${url}", e)
            result.status = HttpStatus.SC_INTERNAL_SERVER_ERROR
            result.content = "Failed calling web service. ${e.getClass()} ${e.getMessage()} URL= ${url}."
        }
        log.info("Result of Submission to Aekos: " + result.toString())
        result
    }


    def removeHTMLTags(String content){
        content?.replaceAll("<[^>]*>", "")
    }

    /**
     * Convert facet names and terms to a human understandable text.
     * @param facets
     * @return
     */
    List getDisplayNamesForFacets(facets, List facetConfig) {
        facets?.each { facet ->
            switch (facet.name) {
                case 'userId':
                    List userIds = facet.terms.collect { it.term }
                    Map users = authService.getUserDetailsById(userIds, false)?.users
                    facet.terms.each { term ->
                        term.title = users[term.term]?.displayName
                    }
                    break;
                default:
                    facet.terms?.each { term ->
                        term.title = messageSource.getMessage("facets." + facet.name + "." + term.term, [].toArray(), term.name, Locale.default)
                    }
            }

            Map facetSetting = facetConfig.find { it.name == facet.name }
            facet.title = facetSetting?.title
            facet.helpText = facetSetting?.helpText
        }
    }

    /**
     * Convert facet names and terms to a human understandable text.
     * @param facets
     * @return
     */
    def getDisplayNameForValue(String name, value) {
        switch (name) {
            case 'userId':
                Map users = authService.getUserDetailsById([value], false)?.users
                value = users[value]?.displayName
                break;
            default:
                if (value instanceof String) {
                    value = messageSource.getMessage("facets." + name + "." + value, [].toArray(), value?:"", Locale.default)
                }
                break;
        }

        value
    }
}
