package au.org.ala.biocollect.merit

import grails.converters.JSON
import org.apache.http.HttpStatus

import javax.servlet.http.HttpServletResponse

class SpeciesController {

    SpeciesService speciesService
    WebService webService

    private int ONE_DAY_IN_SECONDS = 60*60*24
    private String CACHE_FOR_A_DAY = 'public, max-age='+Integer.toString(ONE_DAY_IN_SECONDS)

    private void addCachingHeaders(HttpServletResponse response) {
        response.setHeader('Cache-Control', CACHE_FOR_A_DAY)
    }

    def speciesProfile(String id) {

        Map result = speciesService.speciesProfile(id)
        if (result && result.scientificName) {
            addCachingHeaders(response)
        }
        render result as JSON
    }

    def speciesImage(String id) {

        String url = speciesService.speciesImageThumbnailUrl(id)
        if (url) {
            addCachingHeaders(response)
            webService.proxyGetRequest(response, url)
            return null
        }
        else {
            response.contentType = "image/png"
            response.outputStream << getClass().getResourceAsStream("/data/images/image.png")
            return null
        }

    }

    def searchBie() {
        Map results = speciesService.searchBie(params.q, params.fq, params.limit ?: 10)
        render results as JSON
    }

    @PreAuthorise(accessLevel = 'alaAdmin')
    def refreshSpeciesCatalog(boolean force) {
        force = force ?: false
        Map result = speciesService.constructSpeciesFiles(force)
        if (result.success) {
            render text: result as JSON, status: HttpStatus.SC_OK, contentType: org.apache.http.entity.ContentType.APPLICATION_JSON
        }
        else {
            render text: result as JSON, status: HttpStatus.SC_INTERNAL_SERVER_ERROR, contentType: org.apache.http.entity.ContentType.APPLICATION_JSON
        }
    }

    def speciesDownload (Integer page) {
        File file = new File("${grailsApplication.config.getProperty('speciesCatalog.dir')}/${page}.json")
        if (file.exists()) {
            render text: file.text, status: HttpStatus.SC_OK, contentType: org.apache.http.entity.ContentType.APPLICATION_JSON
        }
        else {
            render text: [message: "Species file not found"] as JSON, status: HttpStatus.SC_NOT_FOUND, contentType: org.apache.http.entity.ContentType.APPLICATION_JSON
        }
    }

    def totalSpecies () {
        File file = new File("${grailsApplication.config.getProperty('speciesCatalog.dir')}/${grailsApplication.config.getProperty('speciesCatalog.totalFileName')}")
        if (file.exists()) {
            render text: file.text, status: HttpStatus.SC_OK, contentType: org.apache.http.entity.ContentType.APPLICATION_JSON
        }
        else {
            render text: [message: "Total file not found"] as JSON, status: HttpStatus.SC_NOT_FOUND, contentType: org.apache.http.entity.ContentType.APPLICATION_JSON
        }
    }
}
