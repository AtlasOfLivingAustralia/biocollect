package au.org.ala.biocollect.merit

import grails.converters.JSON

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
            response.contentType = "image/svg+xml"
            response.outputStream << getClass().getResourceAsStream("/data/images/image.svg")
            return null
        }

    }

    def searchBie() {
        Map results = speciesService.searchBie(params.q, params.fq, params.limit ?: 10)
        render results as JSON
    }
}
