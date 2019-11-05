package au.org.ala.biocollect.merit

import grails.converters.JSON
import groovyx.net.http.HTTPBuilder
import org.apache.http.NameValuePair
import org.apache.http.client.HttpClient

//import groovyx.net.http.URIBuilder
import org.apache.http.client.methods.HttpGet
import org.apache.http.client.params.ClientPNames
import org.apache.http.client.utils.URIBuilder
import org.apache.http.impl.client.AbstractHttpClient
import org.apache.http.impl.client.CloseableHttpClient
import org.apache.http.impl.client.HttpClientBuilder
import org.apache.http.impl.client.HttpClients
import org.apache.http.message.BasicNameValuePair
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

        def uri = new URIBuilder(grailsApplication.config.pdfgen.baseURL)
                .setParameter("http.protocol.handle-redirects","false")


        def http = new HTTPBuilder(uri)
        //HttpClient ahc = http.client

        def location = http.request(GET, TEXT) {
            uri.path = 'api/pdf';
            //NameValuePair nameValuePair = new NameValuePair().
           // List<NameValuePair> listParams = new ArrayList<NameValuePair>();
           // listParams.add(new BasicNameValuePair('docUrl', url))
           // uri.queryParams = listParams
            uri.setParameter('docUrl', url)
            //uri.queryParams = ['docUrl': url]

        //    uri.query = ['docUrl': url]

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
