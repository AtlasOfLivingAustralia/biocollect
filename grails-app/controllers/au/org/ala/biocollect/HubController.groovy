package au.org.ala.biocollect

import au.org.ala.biocollect.merit.SettingService
import au.org.ala.biocollect.merit.hub.HubSettings
import grails.util.Environment

class HubController {
    SettingService settingService
    def index() {
        HubSettings hubSettings = SettingService.hubConfig;
            switch (hubSettings?.templateConfiguration?.homePage?.homePageConfig){
            case 'buttons':
                render view: 'buttonHomePage', model: [homepage: true];
                break;
            case 'projectfinder':
                render view: 'projectFinderHomePage', model: [homepage: true];
                break;
        }
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
}
