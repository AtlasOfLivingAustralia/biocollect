package au.org.ala.biocollect

import grails.boot.GrailsApp
import grails.boot.config.GrailsApplicationPostProcessor
import grails.boot.config.GrailsAutoConfiguration
import grails.core.GrailsApplication
import grails.core.GrailsApplicationLifeCycle
import grails.util.Metadata
import org.apache.grails.core.plugins.PluginDiscovery
import org.springframework.context.ApplicationContext
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Import
import org.slf4j.Logger
import org.slf4j.LoggerFactory

@Import(SpringCacheConfiguration)
class Application extends GrailsAutoConfiguration {

    private static final Logger LOGGER = LoggerFactory.getLogger(Application)

    static void main(String[] args) {
        GrailsApp.run(Application, args)
    }

    @Bean
    @Override
    GrailsApplicationPostProcessor grailsApplicationPostProcessor(PluginDiscovery pluginDiscovery) {
        return new UserAgentPostProcessor(this, applicationContext, pluginDiscovery, classes() as Class[])
    }

    /**
     * A named class rather than an anonymous one: under Groovy 5.1.3 an anonymous subclass of
     * GrailsApplicationPostProcessor fails to pass the Class... argument to the super constructor
     * (GroovyCastException on a PojoWrapper), which Groovy 4 handled.
     */
    static class UserAgentPostProcessor extends GrailsApplicationPostProcessor {

        UserAgentPostProcessor(GrailsApplicationLifeCycle lifeCycle, ApplicationContext applicationContext,
                               PluginDiscovery pluginDiscovery, Class... classes) {
            super(lifeCycle, applicationContext, pluginDiscovery, classes)
        }

        @Override
        protected void customizeGrailsApplication(GrailsApplication grailsApplication) {
            String applicationName =  Metadata.current.getApplicationName()
            String applicationVersion =  Metadata.current.getApplicationVersion()
            String userAgent = "${applicationName}/${applicationVersion}"
            System.setProperty('http.agent', 'au.org.ala.'+userAgent)
            Application.LOGGER.info("User Agent set to: ${userAgent}")
        }
    }

}
