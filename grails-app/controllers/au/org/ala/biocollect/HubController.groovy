package au.org.ala.biocollect

import au.org.ala.biocollect.merit.RoleService
import au.org.ala.biocollect.merit.SettingService
import au.org.ala.biocollect.merit.UserService
import au.org.ala.biocollect.merit.hub.HubSettings
import grails.util.Environment
import grails.converters.JSON

class HubController {
    SettingService settingService
    UserService userService
    def index() {
        HubSettings hubSettings = SettingService.hubConfig
        switch (hubSettings.getHubHomePageType()){
            case 'buttons':
                render view: 'buttonHomePage', model: [homepage: true]
                break
            case 'projectfinder':
                Map model = [homepage:true, showProjectDownloadButton:showProjectFinderDownloadButton(hubSettings)]
                render view: 'projectFinderHomePage', model: model
                break
        }
    }

    private showProjectFinderDownloadButton(HubSettings hub) {
        hub.showProjectFinderDownloadButton() && userService.doesUserHaveHubRole(RoleService.PROJECT_ADMIN_ROLE)
    }

    def getStyleSheet() {
        HubSettings hubSettings = SettingService.hubConfig
        Map styles = hubSettings.templateConfiguration?.styles
        String skin = hubSettings.skin
        String urlPath = hubSettings.urlPath
        Map config
        switch (skin){
            case 'configurableHubTemplate1':
                config = settingService.getConfigurableHubTemplate1(urlPath, styles)
                break;
        }

        if (Environment.current == Environment.DEVELOPMENT) {
            header 'Cache-Control', 'no-cache, no-store, must-revalidate'
        } else {
            header 'Cache-Control', 'public, max-age=31536000'
            response.setDateHeader('Expires', (new Date() + 365).time)
            // override grails pragma header
            header 'Pragma', 'cache'
        }

        render view: 'configurableHubTemplate1', contentType: 'text/css', model: config;
    }

    def defaultOverriddenLabels() {
        render text: grailsApplication.config.content.defaultOverriddenLabels as JSON, contentType: 'application/json'
    }
}
