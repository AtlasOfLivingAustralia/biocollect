
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

    <div class="row-fluid" data-bind="">
        <div class="span6" id="column1">
            <div class="well span12">
                <div class="well-title"><g:message code="project.display.about" /></div>
                <div data-bind="visible:aim">
                    <div class="text-small-heading"><g:message code="project.display.aim" /></div>
                    <span data-bind="text:aim"></span>
                    <p/>
                </div>
                <div data-bind="visible:description">
                    <div class="text-small-heading"><g:message code="project.display.description" /></div>
                    <span data-bind="html:description.markdownToHtml()"></span>
                </div>
                <div data-bind="visible:isContributingDataToAla" class="margin-top-1 margin-bottom-1">
                    <img src="${resource([dir: "images", file: "ala-logo-small.png"])}" class="logo-icon" alt="Atlas of Living Australia logo"><g:message code="project.contributingToALA"/>

                </div>
            </div>
        </div>
        <div class="span6" id="column2">
            <div class="well">
                <div class="well-title"><g:message code="project.display.involved" /></div>
                <div data-bind="visible:getInvolved">
                    <div data-bind="html:getInvolved.markdownToHtml()"></div>
                    <p/>
                </div>
                <div data-bind="visible:manager">
                    <div class="text-small-heading"><g:message code="project.display.contact" /></div>
                    <a data-bind="attr:{href:'mailto:' + manager()}"><span data-bind="text:manager"></span></a>
                    <p/>
                </div>
                <div data-bind="visible:gear">
                    <div class="text-small-heading"><g:message code="project.display.gear" /></div>
                    <span data-bind="text:gear"></span>
                    <p/>
                </div>
                <div data-bind="visible:task">
                    <div class="text-small-heading"><g:message code="project.display.task" /></div>
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
        <div style="display: none">
            <div data-bind="template:{name:'associated-orgs'}"></div>
        </div>
    </div>
    <g:if test="${projectSite?.extent?.geometry}">
    <div class="row-fluid">
        <div class="span12 well" style="height: 100%; width: 100%">
            <div class="well-title"><g:message code="project.display.site" /></div>
            <m:map id="projectSiteMap" width="100%" height="512px"/>
        </div>
    </div>
    </g:if>

    <div class="image-attribution-panel" data-bind="visible: logoAttributionText() || mainImageAttributionText()">
        <strong>Image credits</strong>: <span data-bind="visible: logoAttributionText()">Logo: <span data-bind="text: logoAttributionText()"></span>;&nbsp;</span>
        <span data-bind="visible: mainImageAttributionText()">Feature image: <span data-bind="text: mainImageAttributionText()"></span></span>
    </div>
</div>
<r:script>

    <g:if test="${projectSite?.extent?.geometry}">
    if ((typeof map === 'undefined' || Object.keys(map).length == 0)) {
        var projectArea = <fc:modelAsJavascript model="${projectSite.extent.geometry}"/>;

        if (projectArea) {
            var mapOptions = {
                drawControl: false,
                showReset: false,
                draggableMarkers: false,
                useMyLocation: false,
                allowSearchLocationByAddress: false,
                allowSearchRegionByAddress: false,
                wmsFeatureUrl: "${createLink(controller: 'proxy', action: 'feature')}?featureId=",
                wmsLayerUrl: "${grailsApplication.config.spatial.geoserverUrl}/wms/reflect?"
            }

            map = new ALA.Map("projectSiteMap", mapOptions);

            if (projectArea.pid) {
                map.addWmsLayer(projectArea.pid);
            } else {
                var geometry = _.pick(projectArea, "type", "coordinates");
                var geoJson = ALA.MapUtils.wrapGeometryInGeoJSONFeatureCol(geometry);
                map.setGeoJSON(geoJson);
            }
        }
    }
    </g:if>

    // make sure the list of associated organisations are below the shorter of the two columns.
    function placeAssociatedOrgs() {
        if ($("#column1").height() > $("#column2").height()) {
            $("#column2").append($("#associatedOrgs"));
        } else {
            $("#column1").append($("#associatedOrgs"));
        }
    }

    setTimeout(placeAssociatedOrgs, 2000);
</r:script>



<script type="text/html" id="associated-orgs">
<div class="well span12 margin-left-0" id="associatedOrgs" data-bind="visible: associatedOrgs().length > 0">
    <div class="well-title"><g:message code="project.display.associatedOrgs"/></div>

    <!-- ko foreach: associatedOrgs -->
    <div class="span5 associated-org thumbnail">
        <div data-bind="visible: url" class=" clearfix">
            <a href="#" data-bind="attr: {href: url}" target="_blank" class="do-not-mark-external">
                <div data-bind="visible: logo"><img src="" data-bind="attr: {src: logo, title: name}"
                                                    alt="Organisation logo" class="small-logo"></div>

                <div data-bind="visible: !logo" class="associated-org-no-logo"><span data-bind="text: name"></span>
                </div>
            </a>
        </div>

        <div data-bind="visible: !url">
            <div data-bind="visible: logo"><img src="" data-bind="attr: {src: logo, title: name}"
                                                alt="Organisation logo" class="small-logo"></div>

            <div data-bind="visible: !logo" class="associated-org-no-logo"><span data-bind="text: name"></span></div>
        </div>

        <div class="clearfix"></div>
    </div>
    <!-- /ko -->
</div>
</script>