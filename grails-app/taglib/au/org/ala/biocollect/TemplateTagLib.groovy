package au.org.ala.biocollect

import au.org.ala.biocollect.merit.SettingService
import au.org.ala.biocollect.merit.UserService

class TemplateTagLib {
    static namespace = "config"

    UserService userService
    SettingService settingService

    def createAButton = { attrs ->
        Map link = attrs.config;
        if (link.role && !userService.doesUserHaveHubRole(link.role)) {
            return
        }
        if(link){
            String classes = getSpanClassForColumnNumber(attrs.layout)?:'span4';
            String url = getLinkUrl(link)
            out << """
            <div class="${classes} homePageNav">
                <button class="well nav-well text-center" onclick="window.location = '${url}'">
                    <h3 class="">${link?.displayName}</h3>
                </button>
            </div>
            """
        }
    }


    /**
     * Generate links for header and footer based on config options.
     * @attr hubConfig REQUIRED hub configuration object {@link au.org.ala.biocollect.merit.hub.HubSettings}
     */
    def getLinkFromConfig = { attrs ->
        if(attrs.config){
            Map link = attrs.config
            if (link.role && !userService.doesUserHaveHubRole(link.role)) {
                return
            }
            String url = getLinkUrl(link)

            switch (link.contentType){
                case 'external':
                    out << "<li class=\"main-menu\">";
                    out << "<a href=\"${url}\" class=\"do-not-mark-external\">${link.displayName}</a>";
                    out << "</li>";
                    break;
                case 'content':
                    out << "<li class=\"main-menu\">";
                    out << "<a href=\"${url}\">${link.displayName}</a>";
                    out << "</li>";
                    break;
                case 'static':
                    out << "<li class=\"main-menu\">";
                    out << "<a href=\"${url}\" >${link.displayName}</a>";
                    out << "</li>";
                    break;
                case 'nolink':
                    out << "<li class=\"main-menu\">";
                    out << link.displayName;
                    out << "</li>";
                    break;
                case 'admin':
                    if(userService.userIsAlaAdmin()){
                        out << "<li class=\"main-menu\">";
                        out << "<a href=\"${url}\">${link.displayName?:'Admin'}</a>";
                        out << "</li>";
                    }
                    break;
                case 'allrecords':
                    out << "<li class=\"main-menu\">";
                    out << "<a href=\"${url}\">${link.displayName?:'All Records'}</a>";
                    out << "</li>";
                    break;
                case 'home':
                    out << "<li class=\"main-menu\">";
                    out << "<a href=\"${url}\">${link.displayName?:'Home'}</a>";
                    out << "</li>";
                    break;
                case 'login':
                    Map loginOrLogout = printLoginOrLogoutButton(attrs.hubConfig);
                    out << "<li class=\"main-menu\">";
                    out << "<a href=\"${loginOrLogout.href}\">${loginOrLogout.displayName}</a>";
                    out << "</li>";
                    break;
                case 'newproject':
                    out << "<li class=\"main-menu\">";
                    out << "<a href=\"${url}\">${link.displayName?:'New project'}</a>";
                    out << "</li>";
                    break;
                case 'sites':
                    out << "<li class=\"main-menu\">";
                    out << "<a href=\"${url}\">${link.displayName?:'Sites'}</a>";
                    out << "</li>";
                    break;
                case 'biocacheexplorer':
                    out << "<li class=\"main-menu\">";
                    out << "<a href=\"${ url }\">${link.displayName?:'Occurrence explorer'}</a>";
                    out << "</li>";
                    break;
                case 'recordSighting':
                    String disabled = isRequestForRecordASighting(link)?"disabled":"";
                    out << "<li class=\"main-menu\">"
                    out << "<button class=\"btn btn-primary\" style=\"font-size: 13px;\" title=\"Login required\" " +
                            "${disabled} onclick=\"window.location = '${url}'\"><i class=\"fa fa-binoculars fa-inverse\">" +
                            "</i>&nbsp;&nbsp;Record a sighting</button>"
                    out << "</li>"
                    break;
            }
        }
    }

    def getSocialMediaLinkFromConfig = { attrs ->

        if(attrs.config){
            Map link = attrs.config;
            String style = "";
            if(attrs.style){
                style = "style='color:${attrs.style?.textColor}';";
            }

            out << """
                <a class="do-not-mark-external" href="${link.href}" ${style}>
                <span class="fa-stack fa-lg">
                <i class="fa fa-circle fa-stack-2x fa-inverse"></i>
                                    <i class="fa fa-${link.contentType} fa-stack-1x"></i>
                </span>
                </a>
                """
        }
    }

    def getStyleSheet = { attrs ->
        if(attrs.file){
            def scss = grailsApplication.parentContext.getResource("css/template/${attrs.file}")
            if(scss.exists()){
                out << scss.inputStream.text;
            }
        }
    }

    def optionalContent = { attrs, body ->

        if (settingService.getHubConfig()?.supportsOptionalContent(attrs?.key)) {
            out << body()
        }
    }

    def convertHexToRGBA = { attrs ->
        String colour = attrs.hex?.replace('#', '')
        if (colour && attrs.alpha) {
            String red, green, blue
            if (colour.size() == 6) {
                red = colour.substring(0,2)
                green = colour.substring(2,4)
                blue = colour.substring(4,6)
            } else if (colour.size() == 3) {
                red = colour[0] + colour[0]
                green = colour[1] + colour[1]
                blue = colour[2] + colour[2]
            } else {
                return
            }

            try {
                int redInt = Integer.parseInt(red, 16)
                int greenInt = Integer.parseInt(green, 16)
                int blueInt = Integer.parseInt(blue, 16)
                out << "rgba(${redInt},${greenInt},${blueInt}, ${attrs.alpha})"
            } catch (NumberFormatException nfe) {
                log.error("Error occurred while converting hex to integer.", nfe);
            }
        }
    }


    private String getLinkUrl (Map link){
        String url;
        switch (link.contentType){
            case 'external':
                url = link.href;
                break;
            case 'content':
                url = "${createLink(uri: link.href)}";
                break;
            case 'static':
                url = "${createLink(controller: 'staticPage', action: 'index')}?page=${link.href}";
                break;
            case 'admin':
                url = "${createLink(controller: 'admin', action: 'index')}";
                break;
            case 'allrecords':
                url = "${createLink(controller: 'bioActivity', action: 'allRecords')}";
                break;
            case 'home':
                url = "${createLink(controller: 'home', action: 'index')}";
                break;
            case 'login':
                url = "${createLink(controller: 'bioActivity', action: 'allRecords')}";
                break;
            case 'newproject':
                url = "${createLink(controller: 'project', action: 'create')}";
                break;
            case 'sites':
                url = "${createLink(controller: 'site', action: 'list')}";
                break;
            case 'biocacheexplorer':
                String fq = ''
                if(request.forwardURI?.contains('/bioActivity/myProjectRecords')){
                    fq = "&fq=alau_user_id:${userService.getCurrentUserId(request)}";
                }

                url = grailsApplication.config.biocache.baseURL + '/occurrences/search?q=*:*&fq=(data_resource_uid:dr364)' + fq
                break;
            case 'recordSighting':
                url = "${createLink(uri: link.href)}"
                break;
        }

        return url;
    }

    private isRequestForRecordASighting(Map link){
        if(link){
            String normalisedUrl = "${createLink(uri: link.href)}"
            normalisedUrl = normalisedUrl?.indexOf('?') >= 0 ? normalisedUrl.split('\\?')[0] : normalisedUrl
            String sightUrl = createLink(uri: '/sight/')
            sightUrl = sightUrl?.indexOf('?') >= 0 ? sightUrl.split('\\?')[0] : sightUrl

            if((normalisedUrl == request.forwardURI) || (request.forwardURI.startsWith(sightUrl))){
                return true
            }
        }

        false
    }

    private String getSpanClassForColumnNumber (Integer number){
        if(number){
            Map numberToSpan = [ '1': 'span12',
                                 '2': 'span6',
                                 '3': 'span4',
                                 '4': 'span3'
            ]

            return numberToSpan[number.toString()]
        }

        return ''
    }

    private Map printLoginOrLogoutButton(Map hubConfig){
        if(!fc.userIsLoggedIn()){
            String loginUrl = grailsApplication.config.security.cas.loginUrl + "?service=" + grailsApplication.config.security.cas.appServerName + request.forwardURI + "?hub=" + hubConfig.urlPath
            return [displayName: 'Login', href: loginUrl, contentType:'external']
        } else {
            String logoutUrl = grailsApplication.config.grails.serverURL + "/logout/logout?casUrl=" + grailsApplication.config.security.cas.logoutUrl + "&appUrl=" +  grailsApplication.config.security.cas.appServerName + request.forwardURI + "?hub=" + hubConfig.urlPath
            return [displayName: 'Logout', href: logoutUrl, contentType:'external']
        }
    }
}
