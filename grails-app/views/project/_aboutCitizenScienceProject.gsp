<script type="text/javascript" src="${grailsApplication.config.google.maps.url}"></script>

<style type="text/css">
#surveyLink a {
    color:white;
    background:green;
    padding:10px
}

</style>
<div class="row-fluid" data-bind="visible:mainImageUrl">
    <div class="span12 banner-image-container">
        <img src="" data-bind="attr: {src: mainImageUrl}" class="banner-image"/>
        <div data-bind="visible:urlWeb" class="banner-image-caption"><strong><g:message code="g.visitUsAt" /> <a data-bind="attr:{href:urlWeb}"><span data-bind="text:urlWeb"></span></a></strong></div>
    </div>
</div>

<div id="weburl" data-bind="visible:!mainImageUrl()">
    <div data-bind="visible:urlWeb"><strong><g:message code="g.visitUsAt" /> <a data-bind="attr:{href:urlWeb}"><span data-bind="text:urlWeb"></span></a></strong></div>
</div>

<div class="container-fluid">
    <hr/>
    <div class="row-fluid">
        <div class="span6 well">
            <div class="well-title"><g:message code="project.display.about" /></div>
            <div data-bind="visible:aim">
                <b style="text-decoration: underline;"><g:message code="project.display.aim" /></b><br/>
                <span data-bind="text:aim"></span>
                <p/>
            </div>
            <div data-bind="visible:description">
                <b style="text-decoration: underline;"><g:message code="project.display.description" /></b><br/>
                <span data-bind="html:description.markdownToHtml()"></span>
            </div>
        </div>
        <div class="span6 well">
            <div class="well-title"><g:message code="project.display.involved" /></div>
            <div data-bind="visible:getInvolved">
                <div data-bind="html:getInvolved.markdownToHtml()"></div>
                <p/>
            </div>
            <div data-bind="visible:manager">
                <b style="text-decoration: underline;"><g:message code="project.display.contact" /></b><br/>
                <a data-bind="attr:{href:'mailto:' + manager()}"><span data-bind="text:manager"></span></a>
                <p/>
            </div>
            <div data-bind="visible:gear">
                <b style="text-decoration: underline;"><g:message code="project.display.gear" /></b><br/>
                <span data-bind="text:gear"></span>
                <p/>
            </div>
            <div data-bind="visible:task">
                <b style="text-decoration: underline;"><g:message code="project.display.task" /></b><br/>
                <span data-bind="text:task"></span>
                <p/>
            </div>
            <hr/>
            <div id="surveyLink" class="row-fluid" data-bind="visible:transients.daysRemaining() != 0 && (!isExternal() || urlWeb())">
                <a class="btn pull-right" data-bind="showTabOrRedirect: { url: isExternal() ? urlWeb() : '', tabId: '#activities-tab'}"><g:message code="project.display.join" /></a>
                <p class="clearfix"/>
            </div>
            <g:render template="/shared/listDocumentLinks"
                      model="${[transients:transients,imageUrl:resource(dir:'/images/filetypes')]}"/>
            <p/>
            <div style="line-height:2.2em">
                <g:render template="tags"/>
            </div>
        </div>
    </div>
    <g:if test="${projectSite?.extent?.geometry}">
    <div class="row-fluid">
        <div class="span12 well" style="height: 100%; width: 100%">
            <div class="well-title"><g:message code="project.display.site" /></div>
            <div id="projectSiteMap" style="width:100%; height: 512px;"></div>
        </div>
    </div>
    </g:if>
</div>
<r:script>
    <!-- Only load the google map on page load if the containing div is visible. -->
    <!-- This resolves issues with loading the map when the user is on a different tab (zoom problems with the map). -->
    <!-- There is also a 'click' event listener for the About tab icon which will load the map when the user selects the About tab. -->
    google.maps.event.addDomListener(window, 'load', function() {
        if ($('#projectSiteMap').is(':visible')) {
            initialiseProjectArea();
        }
    });

    function initialiseProjectArea() {
        <g:if test="${projectSite?.extent?.geometry}">
        if ((typeof map === 'undefined' || Object.keys(map).length == 0)) {
            var projectArea = <fc:modelAsJavascript model="${projectSite.extent.geometry}"/>;

            var mapFeatures = {
                zoomToBounds:true,
                zoomLimit:16,
                highlightOnHover:true,
                features:[projectArea],
                featureService: "${createLink(controller: 'proxy', action: 'feature')}",
                wmsServer: "${grailsApplication.config.spatial.geoserverUrl}"
            };

            var mapOptions = {
                mapContainer: "projectSiteMap",
                scrollwheel: false,
                featureService: "${createLink(controller: 'proxy', action: 'feature')}",
                wmsServer: "${grailsApplication.config.spatial.geoserverUrl}"
            };

            map = new MapWithFeatures(mapOptions, mapFeatures);
    }
</g:if>
    }
</r:script>
