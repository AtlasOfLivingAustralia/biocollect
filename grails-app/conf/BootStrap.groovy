import grails.converters.JSON
import net.sf.json.JSONNull

class BootStrap {

    def grailsApplication

    def init = { servletContext ->
        JSON.createNamedConfig("nullSafe", { cfg ->
            cfg.registerObjectMarshaller(JSONNull, {return ""})
        })
    }
    def destroy = {
    }
}
