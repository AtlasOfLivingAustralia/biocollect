package au.org.ala.biocollect

import au.org.ala.biocollect.merit.SettingService
import au.org.ala.biocollect.merit.hub.HubSettings

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
        switch (skin){
            case 'configurableHubTemplate1':
                Map map = settingService.getConfigurableHubTemplate1(urlPath, styles)
                render text: map.css, contentType: 'text/css';
                break;
            case 'configurableHubTemplate-ALA':
                Map map = settingService.getConfigurableHubTemplateALA(urlPath, styles)
                render text: map.css, contentType: 'text/css';
                break;
        }
    }
}
