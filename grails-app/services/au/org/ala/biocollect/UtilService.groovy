package au.org.ala.biocollect

import au.org.ala.biocollect.merit.SettingService
import au.org.ala.biocollect.merit.hub.HubSettings
import au.org.ala.ecodata.forms.EcpWebService
import au.org.ala.web.AuthService
import groovy.json.JsonSlurper
import grails.core.GrailsApplication
import org.springframework.context.MessageSource
import org.springframework.http.HttpStatus

import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.nio.charset.StandardCharsets
import java.nio.file.Files

class UtilService {
    GrailsApplication grailsApplication
    AuthService authService
    MessageSource messageSource
    EcpWebService ecpWebService
    /**
     * Post a HTTP multipart/form-data request to external web sites.
     * @param url the URL to forward to.
     * @param params the (string typed) HTTP parameters to be attached.
     * @inputStreanMap [contentIn: <Input Stream>, contentInfo: [contentType: <content type for eg. json string, zip>, contentName: <can be file name or any name given to the content>]]
     * @return [status:<request status>, content:<The response content from the server, assumed to be JSON>
     */
    def postMultipart(url, Map params, List<Map> inputStreamListMap, String authenticationKey = null) {

        def result = [:]
        File bodyFile = null

        try {
            String boundary = "----BioCollect" + UUID.randomUUID().toString().replace('-', '')
            bodyFile = File.createTempFile("aekos-multipart", ".bin")
            bodyFile.withOutputStream { OutputStream out ->
                inputStreamListMap.each { part ->
                    Map contentInfo = part.contentInfo
                    if (part.contentIn && contentInfo.contentType == "application/zip") {
                        File file = part.contentIn as File
                        writeMultipartFile(out, boundary, contentInfo.contentName as String, contentInfo.contentType as String, file)
                    } else if (part.contentIn && contentInfo.contentType == "application/json") {
                        writeMultipartText(out, boundary, contentInfo.contentName as String, "application/json; charset=UTF-8", part.contentIn.toString())
                    }
                }
                params.each { key, value ->
                    if (value) {
                        writeMultipartText(out, boundary, key.toString(), "text/plain; charset=UTF-8", value.toString())
                    }
                }
                out.write("--${boundary}--\r\n".getBytes(StandardCharsets.UTF_8))
            }

            HttpRequest.Builder requestBuilder = HttpRequest.newBuilder(URI.create(url.toString()))
                    .header("Content-Type", "multipart/form-data; boundary=${boundary}")
                    .POST(HttpRequest.BodyPublishers.ofFile(bodyFile.toPath()))
            if (authenticationKey) {
                String encoded = authenticationKey.getBytes(StandardCharsets.UTF_8).encodeBase64().toString()
                requestBuilder.header("Authorization", "Basic " + encoded)
            }

            HttpClient client = HttpClient.newBuilder().followRedirects(HttpClient.Redirect.NORMAL).build()
            HttpResponse<String> response = client.send(requestBuilder.build(), HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8))
            result.status = response.statusCode()
            def message = parseJsonOrText(response.body())
            if (response.statusCode() >= 200 && response.statusCode() < 300) {
                result.content = message
            } else {
                result.content = "Error submitting to ${url}. Shared code: " + message?.sharedErrorCode ?: '' + " Shared message: " + message?.message ?: ""
            }
        } catch (Exception e) {
            e.printStackTrace()
            log.error("Failed sending request to ${url}", e)
            result.status = HttpStatus.INTERNAL_SERVER_ERROR.value()
            result.content = "Failed calling web service. ${e.getClass()} ${e.getMessage()} URL= ${url}."
        } finally {
            bodyFile?.delete()
        }
        log.info("Result of Submission to Aekos: " + result.toString())
        result
    }

    private static void writeMultipartText(OutputStream out, String boundary, String name, String contentType, String value) {
        out.write("--${boundary}\r\n".getBytes(StandardCharsets.UTF_8))
        out.write("Content-Disposition: form-data; name=\"${name}\"\r\n".getBytes(StandardCharsets.UTF_8))
        out.write("Content-Type: ${contentType}\r\n\r\n".getBytes(StandardCharsets.UTF_8))
        out.write(value.getBytes(StandardCharsets.UTF_8))
        out.write("\r\n".getBytes(StandardCharsets.UTF_8))
    }

    private static void writeMultipartFile(OutputStream out, String boundary, String name, String contentType, File file) {
        out.write("--${boundary}\r\n".getBytes(StandardCharsets.UTF_8))
        out.write("Content-Disposition: form-data; name=\"${name}\"; filename=\"${file.name}\"\r\n".getBytes(StandardCharsets.UTF_8))
        out.write("Content-Type: ${contentType}\r\n\r\n".getBytes(StandardCharsets.UTF_8))
        Files.copy(file.toPath(), out)
        out.write("\r\n".getBytes(StandardCharsets.UTF_8))
    }

    private static Object parseJsonOrText(String body) {
        if (!body) {
            return body
        }
        String trimmed = body.trim()
        if (!(trimmed.startsWith("{") || trimmed.startsWith("["))) {
            return body
        }
        try {
            return new JsonSlurper().parseText(body)
        } catch (Exception ignored) {
            return body
        }
    }


    def removeHTMLTags(String content){
        content?.replaceAll("<[^>]*>", "")
    }

    /**
     * Convert facet names and terms to a human understandable text.
     * add adminOnly property to control visibility of facets
     * @param facets
     * @return
     */
    List getDisplayNamesForFacets(facets, List facetConfig) {
        facets?.each { facet ->
            switch (facet.name) {
                case 'userId':
                    List userIds = facet.terms.collect { it.term }
                    Map users = authService.getUserDetailsById(userIds, false)?.users
                    if(users) {
                        facet.terms.each { term ->
                            term.title = users[term.term]?.displayName
                        }
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
            facet.sortOrder = facetSetting?.sortOrder ?: 'count'
            facet.adminOnly = facetSetting?.adminOnly || false
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

    String getMainImageURL(List documents) {
        Map doc = documents?.find {
            it.role == 'mainImage' && it.status != 'deleted'
        }

        doc?.url ?: doc?.externalUrl
    }

    String getLogoURL(List documents) {
        Map document = documents?.find {
            it.role == 'logo' && it.status != 'deleted'
        }

        document?.thumbnailUrl ?: document?.url
    }

    Map getHeaderLinkForContentTypeOrURI(String contentType, String uri){
        HubSettings hubSettings = SettingService.getHubConfig()
        List links = hubSettings.templateConfiguration?.header?.links
        Map result
        if (links) {
            result = links?.find {it.contentType == contentType}

            if (!result) {
                result = links?.findAll {it.contentType == 'content'}?.find { it.href?.contains(uri) }
            }
        }

        result
    }

    /**
     * Validate redirect URL.
     * If returnTo is relative, then it is valid.
     * If returnTo is absolute, then host name should be in the allowed list.
     * @param returnTo
     * @return
     */
    boolean isRedirectSafe(String returnTo) {
        if (returnTo) {
            try {
                URI uri = new URI(returnTo)
                if (uri.isAbsolute())
                    return ['http', 'https'].contains(uri.scheme?.toLowerCase()) &&
                            uri.host != null && ecpWebService.isValidDomain(uri.host)
                return uri.rawAuthority == null && !returnTo.startsWith('//')
            } catch (Exception ex) {
                return false
            }
        }

        return false
    }

    /**
     * Check if the file name is safe to use for saving files on the server.
     * @param fileName
     * @return
     */
    boolean isFileNameSafe(String fileName) {
        List blackList = grailsApplication.config.getProperty('upload.extensions.blacklist', List, [])?.collect { it.toLowerCase() }
        def extension = FilenameUtils.getExtension(fileName)?.toLowerCase()
        if (extension && !blackList.contains(extension))
            return true

        return false
    }
}
