package au.org.ala.biocollect.merit

import grails.converters.JSON
import groovyx.net.http.HTTPBuilder

import org.apache.http.impl.client.AbstractHttpClient
import org.apache.http.params.BasicHttpParams

import static groovyx.net.http.ContentType.TEXT
import static groovyx.net.http.Method.GET


class ResourceController {

    grails.core.GrailsApplication grailsApplication

    def viewer() {}

    def imageviewer() {}

    def videoviewer() {}

    def audioviewer() {}

    def error() {}

    // proxy this request to work around browsers (firefox) that don't follow redirects properly :(
    def pdfUrl() {
        def url = params.file

        def http = new HTTPBuilder(grailsApplication.config.pdfgen.baseURL)
        AbstractHttpClient ahc = http.client
        BasicHttpParams params = new BasicHttpParams();
        params.setParameter("http.protocol.handle-redirects",false)
        ahc.setParams(params)

        def location = http.request(GET, TEXT) {
            uri.path = 'api/pdf';
            uri.query = ['docUrl': url]

            response.success = { rsp ->
                rsp.headers?.Location
            }
        }

        if (!location) {
            def error = ['error': 'error getting pdf url']
            render error as JSON, status: 500
        }

        def result = ['location': location]
        render result as JSON
    }
}
