package au.org.ala.biocollect.merit

import au.org.ala.web.NoSSO
import grails.converters.JSON
import org.springframework.http.HttpStatus

import java.net.URLEncoder
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.nio.charset.StandardCharsets

class ResourceController {

    WebService webService

    grails.core.GrailsApplication grailsApplication
    @NoSSO
    def viewer() {}
    @NoSSO
    def imageviewer() {}
    @NoSSO
    def videoviewer() {}
    @NoSSO
    def audioviewer() {}
    @NoSSO
    def error() {}
    @NoSSO
    def list() {}

    // proxy this request to work around browsers (firefox) that don't follow redirects properly :(
    @NoSSO
    def pdfUrl() {
        def docUrl = params.file

        try {
            URI uri = new URI(docUrl)
            if (!uri.isAbsolute()) {
                docUrl = grailsApplication.config.getProperty('grails.serverURL') + uri.getPath()
            }
            else if (!webService.isValidDomain(uri.getHost())) {
                render status: HttpStatus.BAD_REQUEST.value(), view:'/error'
                return
            }
        }
        catch (URISyntaxException e) {
            log.warn("Invalid document URL for PDF generation: ${docUrl}", e)
            render([error: 'Invalid document URL'] as JSON, status: 400)
            return
        }

        HttpClient httpClient = HttpClient.newBuilder().followRedirects(HttpClient.Redirect.NEVER).build()

        try {
            URI base = new URI(grailsApplication.config.getProperty('pdfgen.baseURL').toString())
            String query = "docUrl=" + URLEncoder.encode(docUrl.toString(), StandardCharsets.UTF_8)
            URI requestUri = new URI(base.scheme, base.userInfo, base.host, base.port, "/api/pdf", query, null)
            log.debug("Sending file to be converted into pdf: GET ${requestUri}")

            URI location = followRedirects(httpClient, requestUri)
            log.debug("Generated pdf location can be obtained from: " + location?.toString())

            if (!location) {
                def error = ['error': 'error getting pdf url']
                render error as JSON, status: 500
            }

            def result = ['location': location.toString()]
            render result as JSON

        } catch (Exception e) {
            log.error ("Error occurred during pdf generation. " + e.message, e)
        }

    }

    private URI followRedirects(HttpClient httpClient, URI start) {
        URI current = start
        for (int hop = 0; hop < 20; hop++) {
            HttpRequest request = HttpRequest.newBuilder(current).GET().build()
            HttpResponse<Void> response = httpClient.send(request, HttpResponse.BodyHandlers.discarding())
            int code = response.statusCode()
            if (!(code in [301, 302, 303, 307, 308])) {
                return current
            }
            String next = response.headers().firstValue("location").orElse(null)
            if (!next) {
                return current
            }
            current = current.resolve(next)
        }
        return current
    }

}
