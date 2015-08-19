<script type="text/javascript" src="${grailsApplication.config.google.maps.url}"></script>

<style type="text/css">
#surveyLink a {
    color:white;
    background:green;
    padding:10px
}

</style>
<div id="carousel" class="row-fluid slider-pro" data-bind="visible:mainImageUrl()">
    <div class="sp-slides">
        <div class="sp-slide">
            <img class="sp-image" data-bind="attr:{'data-src':mainImageUrl}"/>
            <p class="sp-layer sp-white sp-padding"
               data-position="topLeft" data-width="100%" data-bind="visible:urlWeb"
               data-show-transition="down" data-show-delay="0" data-hide-transition="up">
                <strong><g:message code="g.visitUsAt" /> <a data-bind="attr:{href:urlWeb}"><span data-bind="text:urlWeb"></span></a></strong>
            </p>
        </div>
    </div>
</div>

<div id="weburl" data-bind="visible:!mainImageUrl()">
    <div data-bind="visible:urlWeb()"><strong><g:message code="g.visitUsAt" /> <a data-bind="attr:{href:urlWeb}"><span data-bind="text:urlWeb"></span></a></strong></div>
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
                <a class="btn pull-right" data-bind="attr:{href:isExternal()?urlWeb:'${createLink(action:'survey',id:project.projectId)}'}"><g:message code="project.display.join" /></a>
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
        <div class="span12 well">
            <div class="well-title"><g:message code="project.display.site" /></div>
            <div id="map" style="width:100%; height: 512px;"></div>
        </div>
    </div>
    </g:if>
</div>
<r:script>

    function initialiseProjectArea() {
    <g:if test="${projectSite?.extent?.geometry}">
        var projectArea = <fc:modelAsJavascript model="${projectSite.extent.geometry}"/>;
        var mapOptions = {
            zoomToBounds:true,
            zoomLimit:16,
            highlightOnHover:true,
            features:[projectArea],
            featureService: "${createLink(controller: 'proxy', action: 'feature')}",
            wmsServer: "${grailsApplication.config.spatial.geoserverUrl}"
        };

        map = init_map_with_features({
                mapContainer: "map",
                scrollwheel: false,
                featureService: "${createLink(controller: 'proxy', action: 'feature')}",
                wmsServer: "${grailsApplication.config.spatial.geoserverUrl}"
            },
            mapOptions
        );
</g:if>
    }
</r:script>
