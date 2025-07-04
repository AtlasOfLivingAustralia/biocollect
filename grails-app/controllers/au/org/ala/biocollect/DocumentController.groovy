package au.org.ala.biocollect

import au.org.ala.biocollect.merit.DocumentService
import au.org.ala.biocollect.merit.SettingService
import au.org.ala.biocollect.merit.UserService
import au.org.ala.biocollect.merit.WebService
import grails.converters.JSON
import grails.core.GrailsApplication
import org.apache.http.HttpStatus
import org.springframework.web.util.UriComponents
import org.springframework.web.util.UriComponentsBuilder
import org.springframework.web.util.UriUtils

class DocumentController {

    static allowedMethods = [download: 'GET']

    static final String DOCUMENT_DOWNLOAD_PATH = '/document/download/'

    DocumentService documentService
    SettingService settingService
    WebService webService
    GrailsApplication grailsApplication
    UserService userService

    def get(String id) {
        if (!id) {
            render text: [message: "Document not found"] as JSON, status: HttpStatus.SC_NOT_FOUND
            return
        }

        def document = documentService.get(id)
        if (!document.error) {
            render text: document as JSON, status: HttpStatus.SC_OK
        }
        else {
            render text: [message: "Document error"] as JSON, status: HttpStatus.SC_INTERNAL_SERVER_ERROR
            return
        }
    }

    /**
     * This function does an elastic search for documents. All elastic search parameters are supported like fq, max etc.
     * If format is zip, it will request download of the document list to a spreadsheet. By default it returns json.
     * @return
     */
    def allDocumentsSearch () {
        withFormat {
            json {
                render documentService.allDocumentsSearch(params) as JSON
            }
            zip {
                def resp = documentService.documentsDownload(params)
                if (org.springframework.http.HttpStatus.resolve(resp.statusCode as int).is2xxSuccessful()) {
                    render text: resp.resp as JSON, status: resp.statusCode
                }
                else {
                    render text: [error: "" +
                            "An error occurred when requesting download."] as JSON, status: resp.statusCode
                }
            }
            '*' {
                render documentService.allDocumentsSearch(params) as JSON
            }
        }
    }

    /** Downloads a the file attached to a document stored in the ecodata database */
    def download() {
        final String THUMBNAIL_PREFIX = "thumb_"
        // The Grails population of "path" and "filename" perform URL decoding early and
        // hence will incorrectly detect an encoded ? (%3F) as the query delimiter resulting
        // in files containing a ? not being able to be displayed.
        // Hence we deconstruct the path here to get the path and filename.
        String[] pathAndFilename = parsePathAndFilenameFromURL(
                request.requestURI, request.getCharacterEncoding())
        if (pathAndFilename) {

            String path = pathAndFilename[0]
            String filename = pathAndFilename[1]

            if (filename) {
                String originalName = filename
                if (filename.startsWith(THUMBNAIL_PREFIX)) {
                    originalName = filename.substring(THUMBNAIL_PREFIX.length())
                }
                Map results = documentService.search(filepath: path, filename: originalName)
                if (results && results.documents) {
                    Map document = results.documents[0]

                    if (documentService.canView(document)) {
                        String url = buildDownloadUrl(path, filename)
                        webService.proxyGetRequest(response, url, false)
                        return null
                    }
                }
            }
        }
        response.status = HttpStatus.SC_NOT_FOUND
    }

    protected String buildDownloadUrl(String path, String filename) {
        String url = grailsApplication.config.getProperty('ecodata.service.url') + DOCUMENT_DOWNLOAD_PATH
        if (path) {
            url += path + '/'
        }
        url += UriUtils.encodePath(filename, "UTF-8")

        url
    }

    /**
     * Parses and decodes a document path and filename from a URI of the form /document/download/{path}/{filename}
     * The path segment is optional and can be omitted.
     * @param uri the URI to parse
     * @param encoding the character encoding used in the URI
     * @return an array of Strings with the first element = {path} and second element = {filename}
     */
    protected String[] parsePathAndFilenameFromURL(String uri, String encoding) {
        UriComponents uriComponents = UriComponentsBuilder.fromUriString(uri).build()
        List pathSegments = uriComponents.getPathSegments()

        String path
        String filename
        // Path segment 0 & 1 will be "document" & "download"
        if (pathSegments.size() == 3) {
            path = null
            filename = pathSegments[2]
        } else if (pathSegments.size() == 4) {
            path = pathSegments[2]
            filename = pathSegments[3]
        } else {
            return null
        }
        filename = UriUtils.decode(filename, encoding ?: "UTF-8")
        String[] result = new String[2]
        result[0] = path
        result[1] = filename
        result
    }
}