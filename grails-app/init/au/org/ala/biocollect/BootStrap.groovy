package au.org.ala.biocollect

import grails.converters.JSON
import net.sf.json.JSONNull


class BootStrap {
    def configService

    def init = { servletContext ->
        JSON.createNamedConfig("nullSafe", { cfg ->
            cfg.registerObjectMarshaller(JSONNull, {return ""})
        })

        configService.computeConfig()
    }
    def destroy = {
    }
}
