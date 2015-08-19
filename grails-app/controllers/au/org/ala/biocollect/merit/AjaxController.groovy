package au.org.ala.biocollect.merit

import grails.converters.JSON

class AjaxController {

    /**
     * Simple action that can be called by long running pages periodically to keep the container session alive.
     * If this action is configured to hit CAS, then it should keep the CAS session alive also.
     * @return
     */
    def keepSessionAlive() {
        render(['status':'ok'] as JSON)
    }

}
