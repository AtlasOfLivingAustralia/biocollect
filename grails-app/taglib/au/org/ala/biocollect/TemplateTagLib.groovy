package au.org.ala.biocollect

import groovy.json.StringEscapeUtils

class TemplateTagLib {
    static namespace = "config"
    //static encodeAsForTags = [tagName: [taglib:'html'], otherTagName: [taglib:'none']]

    def createAButton = { attrs ->
        Map link = attrs.config;

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
     */
    def getLinkFromConfig = { attrs ->
        if(attrs.config){
            Map link = attrs.config;
            String style = "";
            if(attrs.style){
                style = "style='color:${attrs.style?.textColor}';";
            }
            switch (link.contentType){
                case 'external':
                    out << "<a href=\"${link.href}\" class=\"do-not-mark-external\" ${style}>${link.displayName}</a>";
                    break;
                case 'content':
                    out << "<a href=\"${createLink(uri: link.href)}\" ${style}>${link.displayName}</a>";
                    break;
                case 'static':
                    out << "<a href=\"${createLink(controller: 'staticPage', action: 'index')}?page=${link.href}\" ${style}>${link.displayName}</a>";
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
        }

        return url;
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
}
