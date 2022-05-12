package au.org.ala.biocollect

import asset.pipeline.AssetPipelineConfigHolder
import au.org.ala.ecodata.forms.TemplateFileAssetResolver
import grails.converters.JSON
import grails.util.BuildSettings
import grails.util.Environment
import net.sf.json.JSONNull


class BootStrap {
    def configService
    def settingService
    def messageSource

    def init = { servletContext ->
        messageSource.setBasenames(
                "file:///var/opt/atlas/i18n/biocollect/messages",
                "file:///opt/atlas/i18n/biocollect/messages",
                "WEB-INF/grails-app/i18n/messages",
                "classpath:messages"
        )

        JSON.createNamedConfig("nullSafe", { cfg ->
            cfg.registerObjectMarshaller(JSONNull, {return ""})
        })

        configService.computeConfig()


        if (Environment.isDevelopmentMode()) {
            String appDir = "${BuildSettings.BASE_DIR?.absolutePath}"
            def templateFileAssetResolver = new TemplateFileAssetResolver('templates', "${appDir}/grails-app/assets/components", false, '/compile/biocollect-templates.js', '/template')
            AssetPipelineConfigHolder.resolvers.add(0, templateFileAssetResolver)
        }
        settingService.initService()
    }
    def destroy = {
    }
}
