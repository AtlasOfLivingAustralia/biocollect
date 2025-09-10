package au.org.ala.biocollect

import grails.boot.GrailsApp
import grails.boot.config.GrailsApplicationPostProcessor
import grails.boot.config.GrailsAutoConfiguration
import grails.core.GrailsApplication
import grails.util.Metadata
import org.springframework.context.annotation.Bean
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class Application extends GrailsAutoConfiguration {

    private static final Logger LOGGER = LoggerFactory.getLogger(Application)

    static void main(String[] args) {
        GrailsApp.run(Application, args)
    }

    @Bean
    GrailsApplicationPostProcessor grailsApplicationPostProcessor() {
        
        return new GrailsApplicationPostProcessor( this, applicationContext, classes() as Class[]) {
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

}