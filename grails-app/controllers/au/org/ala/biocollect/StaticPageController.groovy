package au.org.ala.biocollect

import au.org.ala.biocollect.merit.SettingService
import au.org.ala.web.AlaSecured

class StaticPageController {
    SettingService settingService

    def index() {
        String page = params.page;
        if(page){
            String setting = "${page}";
            render view: 'index', model: ["setting": setting, "mobile": params.mobile ?:false];
        } else {
            render view: "404";
        }
    }


    def edit(){
        String content
        String page = params.page
        String returnUrl = params.returnUrl ?: g.createLink(controller: 'staticPage', action: 'index', absolute: true, params: [page: page])


        if (page) {
            content = settingService.getSettingText(page)
        } else {
            render(status: 404, text: "No settings type found for: ${params.name}")
            return
        }

        render(view: 'edit',
                model: [
                        textValue   : content,
                        returnUrl   : returnUrl,
                        settingKey  : page
                        ])
    }

    /**
     * Save static page text
     */
    @AlaSecured(value = ['ROLE_ADMIN'])
    def saveTextAreaSetting() {
        String text = params.textValue
        String settingKey = params.settingKey
        String returnUrl = params.returnUrl ?: g.createLink(controller: 'staticPage', action: 'index', absolute: true, params: [page: settingKey])

        if (settingKey) {
            settingService.setSettingText(settingKey, text)
            flash.message = "Successfully saved."
        } else {
            flash.errorMessage = "Error: Undefined setting key - ${settingKey}"
        }

        redirect(url: returnUrl)
    }
}
