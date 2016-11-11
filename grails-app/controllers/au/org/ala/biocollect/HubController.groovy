package au.org.ala.biocollect

import au.org.ala.biocollect.merit.SettingService
import au.org.ala.biocollect.merit.hub.HubSettings

class HubController {
    SettingService settingService
    def index() {
        HubSettings hubSettings = SettingService.hubConfig;
        switch (hubSettings?.templateConfiguration?.homePage?.homePageConfig){
            case 'buttons':
                render view: 'buttonHomePage';
                break;
            case 'projectfinder':
                render view: 'projectFinderHomePage';
                break;
        }
    }
}
