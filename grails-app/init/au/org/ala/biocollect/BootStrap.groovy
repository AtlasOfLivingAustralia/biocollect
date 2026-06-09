package au.org.ala.biocollect

import asset.pipeline.AssetPipelineConfigHolder
import au.org.ala.ecodata.forms.TemplateFileAssetResolver
import grails.converters.JSON
import grails.util.BuildSettings
import grails.util.Environment


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
            // net.sf.json (json-lib) is no longer a direct dependency (http-builder-helper was
            // removed); it may still arrive transitively via http-builder, so the marshaller is
            // registered only when JSONNull is on the classpath. The named config must always
            // exist because JSON.use("nullSafe") is called by SiteController/ReportService.
            try {
                Class jsonNull = Class.forName('net.sf.json.JSONNull')
                cfg.registerObjectMarshaller(jsonNull, { return "" })
            }
            catch (ClassNotFoundException ignored) {
                // json-lib not on the classpath - nothing to marshal
            }
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
