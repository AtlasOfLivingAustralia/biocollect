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
        boolean isHubHomePage = false
        if (hubSettings.overridesHomePage()) {
            if(hubSettings.isHomePagePathSimple()){
                Map result = hubSettings.getHomePageControllerAndAction()
                if( result.controller != "hub" && result.action != "index") {
                    forward(result)
                    return
                } else {
                    isHubHomePage = true
                }
            } else {
                redirect([uri: hubSettings['homePagePath'] ])
                return
            }
        } else {
            isHubHomePage = true
        }

        if (isHubHomePage) {
            switch (hubSettings.getHubHomePageType()) {
                case 'buttons':
                    render view: 'buttonHomePage', model: [homepage: true]
                    break
                case 'projectfinder':
                default:
                    Map model = [homepage:true, showProjectDownloadButton:showProjectFinderDownloadButton(hubSettings)]
                    render view: 'projectFinderHomePage', model: model
                    break
            }
        }
    }

    private showProjectFinderDownloadButton(HubSettings hub) {
        hub.showProjectFinderDownloadButton() && userService.doesUserHaveHubRole(RoleService.PROJECT_ADMIN_ROLE)
    }

    def defaultOverriddenLabels() {
        render text: grailsApplication.config.content.defaultOverriddenLabels as JSON, contentType: 'application/json'
    }

    def generateStylesheet(){
        HubSettings hubSettings = SettingService.hubConfig
        Map result = settingService.generateStyleSheetForHub(hubSettings)


        if (Environment.current == Environment.DEVELOPMENT) {
            header 'Cache-Control', 'no-cache, no-store, must-revalidate'
        } else {
            Calendar cal = new GregorianCalendar()
            cal.add(Calendar.DATE, 365)
            Date date = cal.getTime()
            header 'Cache-Control', 'public, max-age=31536000'
            response.setDateHeader('Expires', date.time)
            // override grails pragma header
            header 'Pragma', 'cache'
        }

        render text: result.css, contentType: 'text/css', status: result.status
    }
}
