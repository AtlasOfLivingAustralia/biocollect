package au.org.ala.biocollect

import au.org.ala.biocollect.merit.CommonService
import au.org.ala.biocollect.merit.WebService
import grails.core.GrailsApplication

import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse

/**
 * Interacts with the ALA pdfgen service to produce a PDF version of an HTML page.
 * Handles basic authorization.
 */
class PdfGenerationService {

    WebService webService
    CommonService commonService
    def grailsLinkGenerator
    GrailsApplication grailsApplication

    /**
     * This is simple way of authorizing the generation of a report on behalf of the PDF generation service.
     * Because this state is maintained between requests, this mechanism introduces session affinity requirement which
     * we can get away with as there is currently only one instance of BioCollect.  Possibly a JSONToken
     * style authorization would work better.
     */
    static Set PDF_AUTHORIZATION_STORAGE = Collections.synchronizedSet(new HashSet())
    static final String TOKEN_PARAM = "token"
    static final String PDFGEN_PATH = "api/pdf"

    /** reports can be slow to produce, so we are using a long timeout */
    static final int TIMEOUT = 10 * 60 * 1000

    /**
     * Generates a PDF from the supplied URL information and configures the supplied response to return the PDF.
     * @param reportUrlDetails used to generate a URL that will produce a HTML version of the report.  Must be in the form of a grails map e.g [controller:'report', action:'myreport']
     * @param pdfParams parameters to be passed to wkthmltopdf, The only currently supported parameter is [orentation:landscape] will produce a landscape report.
     * @param response the HttpServletResponse being produced.  The response returned from the pdfgen server will be copied to this response.
     * @return true if the generation was successful, false otherwise.  If true is returned, no further modifications to the response should be made by the client.
     */
    boolean generatePDF(Map reportUrlDetails, Map pdfParams, HttpServletResponse response) {
        String token = UUID.randomUUID().toString()
        PDF_AUTHORIZATION_STORAGE.add(token)

        reportUrlDetails.absolute = true
        if (reportUrlDetails.params) {
            reportUrlDetails.params.token = token
        }
        else {
            reportUrlDetails.params = [token:token]
        }

        String reportUrl = grailsLinkGenerator.link(reportUrlDetails)
        Map pdfGenParams = [docUrl: reportUrl, cacheable: false, options:'--print-media-type --viewport-size 1280x1024']
        if (pdfParams?.orientation == 'landscape') {
            pdfGenParams.options += ' -O landscape'
        }

        String url = grailsApplication.config.pdfgen.baseURL + PDFGEN_PATH + commonService.buildUrlParamsFromMap(pdfGenParams)
        Map result
        try {
            result = webService.proxyGetRequest(response, url, false, false, TIMEOUT)
        }
        catch (Exception e) {
            result = [error: e.message]
            log.error("Error generating PDF for URL ${reportUrl}: ", e)
        }
        finally {
            PDF_AUTHORIZATION_STORAGE.remove(token)
        }
        return result.error ? false : true
    }

    /**
     * Checks that the supplied request is authorized to generate a report.  This method needs to be invoked by the
     * callback method that does the work of generating the report.
     * @param request the callback from the pdfgen server.
     * @return true if the request is authorized.
     */
    boolean authorizePDF(HttpServletRequest request) {
        return PDF_AUTHORIZATION_STORAGE.contains(request.getParameter(TOKEN_PARAM))
    }
}
