package au.org.ala.biocollect.merit

import org.springframework.http.HttpStatus

import au.org.ala.biocollect.merit.SpeciesService
import grails.converters.JSON

import jakarta.servlet.http.HttpServletResponse

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
            render text: result as JSON, status: HttpStatus.OK.value(), contentType: 'application/json'
        }
        else {
            render text: result as JSON, status: HttpStatus.INTERNAL_SERVER_ERROR.value(), contentType: 'application/json'
        }
    }

    def speciesDownload (Integer page) {
        File file = new File("${grailsApplication.config.getProperty('speciesCatalog.dir')}/${page}.json")
        if (file.exists()) {
            render text: file.text, status: HttpStatus.OK.value(), contentType: 'application/json'
        }
        else {
            render text: [message: "Species file not found"] as JSON, status: HttpStatus.NOT_FOUND.value(), contentType: 'application/json'
        }
    }

    def totalSpecies () {
        File file = new File("${grailsApplication.config.getProperty('speciesCatalog.dir')}/${grailsApplication.config.getProperty('speciesCatalog.totalFileName')}")
        if (file.exists()) {
            render text: file.text, status: HttpStatus.OK.value(), contentType: 'application/json'
        }
        else {
            render text: [message: "Total file not found"] as JSON, status: HttpStatus.NOT_FOUND.value(), contentType: 'application/json'
        }
    }
}
