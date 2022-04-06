package au.org.ala.biocollect.merit

import grails.converters.JSON

import org.apache.http.HttpHost;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.protocol.HttpClientContext
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.client.utils.URIUtils;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.impl.client.LaxRedirectStrategy;

class ResourceController {

    grails.core.GrailsApplication grailsApplication

    def viewer() {}

    def imageviewer() {}

    def videoviewer() {}

    def audioviewer() {}

    def error() {}

    def list() {}

    // proxy this request to work around browsers (firefox) that don't follow redirects properly :(
    def pdfUrl() {
        def url = params.file

        CloseableHttpClient httpclient = HttpClients.custom().setRedirectStrategy(new LaxRedirectStrategy()).build()

        try {
            HttpClientContext context = HttpClientContext.create()
            URIBuilder builder = new URIBuilder("${grailsApplication.config.pdfgen.baseURL}")
            builder.setPath("api/pdf").setParameter('docUrl', url)
            URI uri = builder.build();
            HttpGet httpGet = new HttpGet(uri)
            log.debug("Sending file to be converted into pdf: " + httpGet.getRequestLine())

            httpclient.execute(httpGet, context)
            HttpHost target = context.getTargetHost()
            List<URI> redirectLocations = context.getRedirectLocations()
            URI location = URIUtils.resolve(httpGet.getURI(), target, redirectLocations)
            log.debug("Generated pdf location can be obtained from: " + location.toString())

            if (!location) {
                def error = ['error': 'error getting pdf url']
                render error as JSON, status: 500
            }

            def result = ['location': location.toString()]
            render result as JSON

        } catch (Exception e) {
            log.error ("Error occurred during pdf generation. " + e.message, e)
        } finally {
            httpclient.close()
        }

    }

}
