package au.org.ala.biocollect

import au.org.ala.biocollect.merit.SettingService
import au.org.ala.biocollect.merit.UserService
import org.grails.web.servlet.mvc.GrailsWebRequest
import org.springframework.context.MessageSource

class TemplateTagLib {
    static namespace = "config"

    UserService userService
    SettingService settingService
    MessageSource messageSource

    def createAButton = { attrs ->
        Map link = attrs.config;
        if (link.role && !userService.doesUserHaveHubRole(link.role)) {
            return
        }
        if(link){
            String classes = attrs.classes + " "
            classes += getSpanClassForColumnNumber(attrs.layout)?:'col-md-4'
            String url = getLinkUrl(link)
            out << """
            <div class="${classes} homePageNav">
                <div class="w-100 h-100 border text-center rounded-lg homepage-button" onclick="window.location = '${url}'">
                    <div class="p-3 border-0">
                        <h3 class="p-0 m-0">${link?.displayName}</h3>
                    </div>
                </div>
            </div>
            """
        }
    }

    boolean isUrlActivePage(String url) {
        if(url) {
            String qString = request.getQueryString()
            qString = qString ? '?' + qString : ''
            String rUrl = "${request.requestURI}${qString}"
            String fUrl =  "${request.forwardURI}${qString}"
            rUrl?.endsWith(url) || fUrl?.endsWith(url)
        }
    }

    /**
     * Generate links for header and footer based on config options.
     * @attr hubConfig REQUIRED hub configuration object {@link au.org.ala.biocollect.merit.hub.HubSettings}
     */
    def getLinkFromConfig = { attrs ->
        if(attrs.config){
            Map link = attrs.config
            String classes = attrs?.classes ?: ""
            String activeClass = attrs?.activeClass ?: "current-menu-item"
            Boolean bs4 = Boolean.parseBoolean(attrs.bs4  ?: "false")
            if (link.role && !userService.doesUserHaveHubRole(link.role)) {
                return
            }
            String url = getLinkUrl(link)
            if (isUrlActivePage(url)) {
                classes += " ${activeClass}"
            }

            switch (link.contentType){
                case 'external':
                    if (bs4) {
                        out << "<li itemscope=\"itemscope\" itemtype=\"https://www.schema.org/SiteNavigationElement\" class=\"menu-item nav-item ${classes}\">";
                        out << "<a title=\"${link.displayName}\" href=\"${url}\" class=\"do-not-mark-external nav-link\">${link.displayName}</a>";
                        out << "</li>";
                    } else {
                        out << "<li class=\"main-menu ${classes}\">";
                        out << "<a href=\"${url}\" class=\"do-not-mark-external\">${link.displayName}</a>";
                        out << "</li>";
                    }
                    break;
                case 'content':
                case 'static':
                    if (bs4) {
                        out << "<li itemscope=\"itemscope\" itemtype=\"https://www.schema.org/SiteNavigationElement\" class=\"menu-item nav-item ${classes}\">";
                        out << "<a class=\"nav-link\" title=\"${link.displayName}\" href=\"${url}\">${link.displayName}</a>";
                        out << "</li>";
                    } else {
                        out << "<li class=\"main-menu ${classes}\">";
                        out << "<a href=\"${url}\">${link.displayName}</a>";
                        out << "</li>";
                    }
                    break;
                case 'nolink':
                    if (bs4) {
                        out << "<li itemscope=\"itemscope\" itemtype=\"https://www.schema.org/SiteNavigationElement\" class=\"menu-item nav-item ${classes}\">";
                        out << "<span class=\"nav-link\">${link.displayName}</span>";
                        out << "</li>";

                    } else {
                        out << "<li class=\"main-menu ${classes}\">";
                        out << link.displayName;
                        out << "</li>";
                    }
                    break;
                case 'admin':
                    if(userService.userIsAlaAdmin()){
                        if (bs4) {
                            out << "<li itemscope=\"itemscope\" itemtype=\"https://www.schema.org/SiteNavigationElement\" class=\"menu-item nav-item ${classes}\">";
                            out << "<a class=\"nav-link\" title=\"${link.displayName?:'Admin'}\" href=\"${url}\">${link.displayName?:'Admin'}</a>";
                            out << "</li>";

                        } else {
                            out << "<li class=\"main-menu ${classes}\">";
                            out << "<a href=\"${url}\">${link.displayName?:'Admin'}</a>";
                            out << "</li>";
                        }
                    }
                    break;
                case 'allrecords':
                    if (bs4) {
                        out << "<li itemscope=\"itemscope\" itemtype=\"https://www.schema.org/SiteNavigationElement\" class=\"menu-item nav-item ${classes}\">";
                        out << "<a class=\"nav-link\" title=\"${link.displayName?:'All Records'}\" href=\"${url}\">${link.displayName?:'All Records'}</a>";
                        out << "</li>";

                    } else {
                        out << "<li class=\"main-menu ${classes}\">";
                        out << "<a href=\"${url}\">${link.displayName?:'All Records'}</a>";
                        out << "</li>";
                    }
                    break;
                case 'home':
                    if (bs4) {
                        out << "<li itemscope=\"itemscope\" itemtype=\"https://www.schema.org/SiteNavigationElement\" class=\"menu-item nav-item ${classes}\">";
                        out << "<a class=\"nav-link\" title=\"${link.displayName?:'Home'}\" href=\"${url}\">${link.displayName?:'Home'}</a>";
                        out << "</li>";
                    } else {
                        out << "<li class=\"main-menu ${classes}\">";
                        out << "<a href=\"${url}\">${link.displayName?:'Home'}</a>";
                        out << "</li>";
                    }
                    break;
                case 'login':
                    // HubAwareLinkGenerator adds hub parameter to the link which causes subsequent URL parsing to return null in Pac4J filter.
                    // This causes the app to redirect to root page. And, BioCollect root page is redirected to Wordpress.
                    // Taking the user outside the application. This is a workaround to fix the issue. First, remove the
                    // hub parameter before link is generated and set it afterwards.
                    def hub = clearHubParameter()
                    def logoutReturnToUrl = getCurrentURL( attrs.hubConfig )
                    if (grailsApplication.config.getProperty("security.oidc.logoutAction",String, "CAS") == "cognito") {
                        //                                cannot use createLink since it adds hub query parameter and cognito will not consider it valid
                        logoutReturnToUrl = grailsApplication.config.getProperty("grails.serverURL") + grailsApplication.config.getProperty("logoutReturnToUrl",String, "/hub/index")
                    }

                    if (bs4) {
                        out << "<li itemscope=\"itemscope\" itemtype=\"https://www.schema.org/SiteNavigationElement\" class=\"menu-item nav-item ${classes}\">";
                        out << auth.loginLogout(
                                ignoreCookie: "true", cssClass: "btn btn-primary btn-sm nav-button custom-header-login-logout",
//                                cannot use createLink since it adds hub query parameter and eventually creates malformed URL with two ? characters
                                logoutUrl: "/logout",
                                loginReturnToUrl: getCurrentURL( attrs.hubConfig ),
                                logoutReturnToUrl: logoutReturnToUrl
                        )
                        out << "</li>";
                    } else {
                        out << "<li class=\"main-menu ${classes}\">";
                        out << auth.loginLogout(
                                ignoreCookie: "true",
//                                cannot use createLink since it adds hub query parameter and eventually creates malformed URL with two ? characters
                                logoutUrl: "/logout",
                                loginReturnToUrl: getCurrentURL( attrs.hubConfig ),
                                logoutReturnToUrl: logoutReturnToUrl
                        )
                        out << "</li>";
                    }
                    setHubParameter(hub)
                    break;
                case 'newproject':
                    if (bs4) {
                        out << "<li itemscope=\"itemscope\" itemtype=\"https://www.schema.org/SiteNavigationElement\" class=\"menu-item nav-item ${classes}\">";
                        out << "<a class=\"nav-link\" title=\"${link.displayName?:'New project'}\" href=\"${url}\">${link.displayName?:'New project'}</a>";
                        out << "</li>";
                    } else {
                        out << "<li class=\"main-menu ${classes}\">";
                        out << "<a href=\"${url}\">${link.displayName?:'New project'}</a>";
                        out << "</li>";
                    }
                    break;
                case 'sites':
                    if (bs4) {
                        out << "<li itemscope=\"itemscope\" itemtype=\"https://www.schema.org/SiteNavigationElement\" class=\"menu-item nav-item ${classes}\">";
                        out << "<a class=\"nav-link\" title=\"${link.displayName?:'Sites'}\" href=\"${url}\">${link.displayName?:'Sites'}</a>";
                        out << "</li>";
                    } else {
                        out << "<li class=\"main-menu ${classes}\">";
                        out << "<a href=\"${url}\">${link.displayName?:'Sites'}</a>";
                        out << "</li>";
                    }
                    break;
                case 'resources':
                    if (bs4) {
                        out << "<li itemscope=\"itemscope\" itemtype=\"https://www.schema.org/SiteNavigationElement\" class=\"menu-item nav-item ${classes}\">";
                        out << "<a class=\"nav-link\" title=\"${link.displayName?:'Resources'}\" href=\"${url}\">${link.displayName?:'Resources'}</a>";
                        out << "</li>";
                    } else {
                        out << "<li class=\"main-menu ${classes}\">";
                        out << "<a href=\"${url}\">${link.displayName?:'Resources'}</a>";
                        out << "</li>";
                    }
                    break;
                case 'biocacheexplorer':
                    if (bs4) {
                        out << "<li itemscope=\"itemscope\" itemtype=\"https://www.schema.org/SiteNavigationElement\" class=\"menu-item nav-item ${classes}\">";
                        out << "<a class=\"nav-link\" title=\"${link.displayName?:'Occurrence explorer'}\" href=\"${url}\">${link.displayName?:'Occurrence explorer'}</a>";
                        out << "</li>";
                    } else {
                        out << "<li class=\"main-menu ${classes}\">";
                        out << "<a href=\"${ url }\">${link.displayName?:'Occurrence explorer'}</a>";
                        out << "</li>";
                    }
                    break;
                case 'recordSighting':
                    String disabled = isRequestForRecordASighting(link)?"disabled":"";

                    if (bs4) {
                        out << "<li itemscope=\"itemscope\" itemtype=\"https://www.schema.org/SiteNavigationElement\" class=\"menu-item nav-item ${classes}\">";
                        out << "<button class=\"btn btn-primary\" style=\"font-size: 13px;\" title=\"Login required\" " +
                                "${disabled} onclick=\"window.location = '${url}'\"><i class=\"fa fa-binoculars fa-inverse\">" +
                                "</i>&nbsp;&nbsp;Record a sighting</button>"
                        out << "</li>";
                    } else {
                        out << "<li class=\"main-menu ${classes}\">"
                        out << "<button class=\"btn btn-primary-dark\" style=\"font-size: 13px;\" title=\"Login required\" " +
                                "${disabled} onclick=\"window.location = '${url}'\"><i class=\"fa fa-binoculars fa-inverse\">" +
                                "</i>&nbsp;&nbsp;Record a sighting</button>"
                        out << "</li>"
                    }
                    break;
                    break;
                case 'charts':
                    out << "<li itemscope=\"itemscope\" itemtype=\"https://www.schema.org/SiteNavigationElement\" class=\"menu-item nav-item ${classes}\">";
                    out << "<a class=\"nav-link\" title=\"${link.displayName?:messageSource.getMessage('hub.chart.title', null, '', Locale.default)}\" href=\"${url}\">${link.displayName?:messageSource.getMessage('hub.chart.title', null, '', Locale.default)}</a>";
                    out << "</li>";
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

    def getSocialMediaIcons = { attrs ->
        String icon
        switch (attrs.document.role) {
            case "facebook":
                icon = "fab fa-facebook-f"
                break;
            case "flickr":
                icon = "fab fa-flickr"
                break;
            case "googlePlus":
                icon = "fab fa-google-plus-g"
                break;
            case "instagram":
                icon = "fab fa-instagram"
                break;
            case "linkedIn":
                icon = "fab fa-linkedin-in"
                break;
            case "pinterest":
                icon = "fab fa-pinterest-p"
                break;
            case "rssFeed":
                icon = "fas fa-rss"
                break;
            case "tumblr":
                icon = "fab fa-tumblr"
                break;
            case "twitter":
                icon = "fab fa-twitter"
                break;
            case "vimeo":
                icon = "fab fa-vimeo-v"
                break;
            case "youtube":
                icon = "fab fa-youtube"
                break;
        }

        out << icon
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

    String getCurrentURLFromRequest() {
        String requestURL = request.getRequestURL().toString()
        // Construct the complete URL
        StringBuilder url = new StringBuilder()
        url.append(requestURL)

        String queryString = request.getQueryString()
        // Include the query string if present
        if (queryString != null) {
            url.append("?").append(queryString)
        }

        url.toString()
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
            case 'resources':
                url = "${createLink(controller: 'resource', action: 'list')}";
                break;
            case 'biocacheexplorer':
                String fq = ''
                if(request.forwardURI?.contains('/bioActivity/myProjectRecords')){
                    fq = "&fq=alau_user_id:${userService.getCurrentUserId()}";
                }

                url = grailsApplication.config.biocache.baseURL + '/occurrences/search?q=*:*&fq=(data_resource_uid:dr364)' + fq
                break;
            case 'recordSighting':
                url = "${createLink(uri: link.href)}"
                break;
                break;
            case 'charts':
                url = "${createLink(controller: 'report', action: 'chartList')}";
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
            Map numberToSpan = [ '1': 'col-md-12',
                                 '2': 'col-md-6',
                                 '3': 'col-md-4',
                                 '4': 'col-md-3'
            ]

            return numberToSpan[number.toString()]
        }

        return ''
    }

    private String getCurrentURL(Map hubConfig){
        getCurrentURLFromRequest()
    }

    private String clearHubParameter(){
        def request = GrailsWebRequest.lookup()
        def hub  = request?.params?.hub
        if(hub){
            request.params.remove('hub')
        }

        hub
    }

    private void setHubParameter(String hub) {
        def request = GrailsWebRequest.lookup()
        if (hub && request.params) {
            request.params.hub = hub
        }
    }
}
