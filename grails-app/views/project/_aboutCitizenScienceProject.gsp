
<style type="text/css" >
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
                <div class="well-title">${hubConfig.getTextForAboutTheProject(grailsApplication.config.content.defaultOverriddenLabels)}</div>
                <div data-bind="visible:aim">
                    <div class="text-small-heading">${hubConfig.getTextForAim(grailsApplication.config.content.defaultOverriddenLabels)}</div>
                    <span data-bind="text:aim"></span>
                    <p/>
                </div>
                <div data-bind="visible:description">
                    <div class="text-small-heading">${hubConfig.getTextForDescription(grailsApplication.config.content.defaultOverriddenLabels)}</div>
                    <span data-bind="html:description.markdownToHtml()"></span>
                </div>
                <g:if test="${hubConfig?.content?.hideProjectAboutOriginallyRegistered != true}">
                <div data-bind="visible: origin">
                    <div class="text-small-heading"><g:message code="project.display.origin" /></div>
                    <span data-bind="text:origin"></span>
                    <p/>
                </div>
                </g:if>
                <g:if test="${hubConfig?.content?.hideProjectAboutContributing != true}">
                <div data-bind="visible:!isExternal()" class="margin-top-1 margin-bottom-1">
                    <img src="${asset.assetPath(src: "ala-logo-small.png")}" class="logo-icon" alt="Atlas of Living Australia logo"><g:message code="project.contributingToALA"/>

                </div>
                </g:if>
            </div>
        </div>
        <div class="span6" id="column2">
            <div class="well">
                <div class="well-title" data-bind="visible:projectType() == 'survey'"><g:message code="project.display.involved" /></div>
                <div class="well-title" data-bind="visible:projectType() != 'survey'">${hubConfig.getTextForProjectInformation(grailsApplication.config.content.defaultOverriddenLabels)}</div>
                <div data-bind="visible:getInvolved">
                    <div data-bind="html:getInvolved.markdownToHtml()"></div>
                    <p/>
                </div>
                <div class="row-fluid">
                    <div class="span6">
                        <div data-bind="visible:externalId">
                            <div class="text-small-heading"><g:message code="project.display.externalId" /></div>
                            <span data-bind="text:externalId"></span>
                            <p/>
                        </div>
                        <div data-bind="visible:grantId">
                            <div class="text-small-heading"><g:message code="project.display.grantId" /></div>
                            <span data-bind="text:grantId"></span>
                            <p/>
                        </div>
                        <div data-bind="visible:funding">
                            <div class="text-small-heading"><g:message code="project.display.fundingValue" /></div>
                            <span data-bind="text:funding.formattedCurrency" style="margin-right:16px" ></span>
                            <g:if test="project.fundings">
                                    <a href="#" data-toggle="modal" data-target="#fundingDetails"><i class="icon-th-list"></i></a>
                            </g:if>
                            <p/>
                        </div>

                    <g:if test="project.fundings">
                        <div class="modal fade"  id="fundingDetails" tabindex="-1" role="dialog" aria-labelledby="Fundings" aria-hidden="true">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-body">
                                        <table class="table"><thead><td>Funding Source</td><td>Funding Type</td><td>Funding Amount</td></thead>
                                            <tbody>
                                            <!-- ko foreach: fundings -->
                                                <tr >
                                                    <td ><span data-bind="text: fundingSource"></span></td>
                                                    <td ><span data-bind="text: fundingType"></span></td>
                                                    <td ><span data-bind="text: fundingSourceAmount.formattedCurrency"></span></td>
                                                </tr>
                                            <!-- /ko -->
                                            </tbody>
                                        </table>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        </g:if>

                        <div data-bind="visible:associatedProgram">
                            <div class="text-small-heading">${hubConfig.getTextForProgramName(grailsApplication.config.content.defaultOverriddenLabels)}</div>
                            <span data-bind="text:associatedProgram"></span>
                            <p/>
                        </div>
                        <div data-bind="visible:associatedSubProgram">
                            <div class="text-small-heading">${hubConfig.getTextForSubprogramName(grailsApplication.config.content.defaultOverriddenLabels)}</div>
                            <span data-bind="text:associatedSubProgram"></span>
                            <p/>
                        </div>
                        <div data-bind="visible:orgGrantee">
                            <div class="text-small-heading"><g:message code="project.display.orgGrantee" /></div>
                            <span data-bind="text:orgGrantee"></span>
                            <p/>
                        </div>
                        <div data-bind="visible:orgSponsor">
                            <div class="text-small-heading"><g:message code="project.display.orgSponsor" /></div>
                            <span data-bind="text:orgSponsor"></span>
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
                    </div>
                    <div class="span6">
                        <div data-bind="visible: industries().length">
                            <div class="text-small-heading"><g:message code="project.display.industries"/></div>
                            <span data-bind="text:industries().join(', ')"></span>
                            <p/>
                        </div>
                        <g:if test="${hubConfig?.content?.hideProjectAboutParticipateInProject != true}">
                        <div data-bind="visible: countries().length">
                            <div class="text-small-heading">
                                <g:if test="${hubConfig.defaultFacetQuery.contains('isEcoScience:true')}">
                                    <g:message code="project.display.countries.ecoscience" />
                                </g:if>
                                <g:else>
                                    <g:message code="project.display.countries.citizenscience" />
                                </g:else>
                            </div>
                            <span data-bind="text:countries().join(', ')"></span>
                            <p/>
                        </div>
                        </g:if>
                        <g:if test="${hubConfig?.content?.hideProjectAboutUNRegions != true}">
                        <div data-bind="visible: uNRegions().length">
                            <div class="text-small-heading"><g:message code="project.display.unregions" /></div>
                            <span data-bind="text:uNRegions().join(', ')"></span>
                            <p/>
                        </div>
                        </g:if>
                        %{-- TODO: swap fields. check issue - biocollect#667 --}%
                        <div data-bind="visible:managerEmail">
                            <div class="text-small-heading"><g:message code="project.display.contact.name" /></div>
                            <span data-bind="text:managerEmail"></span>
                            <p/>
                        </div>
                        <div data-bind="visible:manager">
                            <div class="text-small-heading"><g:message code="project.display.contact.email" /></div>
                            <a data-bind="attr:{href:'mailto:' + manager()}"><span data-bind="text:manager"></span></a>
                            <p/>
                        </div>
                        %{-- TODO END--}%
                    </div>
                </div>
                <hr id="hrGetStartedMobileAppTag" data-bind="visible: transients.checkVisibility('#contentGetStartedMobileAppTag', '#hrGetStartedMobileAppTag')" />
                <div id="contentGetStartedMobileAppTag">
                    <div class="row-fluid">
                        <div class="media span8"  data-bind="visible:isSciStarter">
                            <a class="pull-left" href="#">
                                <div class="media-object sciStarterLogo"></div>
                            </a>
                            <div class="media-body">
                                <h4 class="media-heading">Project sourced from SciStarter</h4>
                            </div>
                        </div>
                        <div id="surveyLink" class="span4 pull-right" data-bind="visible:transients.daysRemaining() != 0 && (!isExternal() || urlWeb()) && projectType() == 'survey' ">
                            <a class="btn pull-right" data-bind="showTabOrRedirect: { url: isExternal() ? urlWeb() : '', tabId: '#activities-tab'}"><g:message code="project.display.join" /></a>
                            <p class="clearfix"/>
                        </div>
                    </div>
                    <g:render template="/shared/listDocumentLinks"
                              model="${[transients:transients,imageUrl:asset.assetPath(src:'filetypes')]}"/>
                    <p/>
                    <div style="line-height:2.2em">
                        <g:render template="tags" />
                    </div>
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
            <div class="well-title">${hubConfig.getTextForProjectArea(grailsApplication.config.content.defaultOverriddenLabels)}</div>
            <m:map id="projectSiteMap" width="100%" height="512px"/>
        </div>
    </div>
    </g:if>

    <div class="image-attribution-panel" data-bind="visible: logoAttributionText() || mainImageAttributionText()">
        <strong>Image credits</strong>: <span data-bind="visible: logoAttributionText()">Logo: <span data-bind="text: logoAttributionText()"></span>;&nbsp;</span>
        <span data-bind="visible: mainImageAttributionText()">Feature image: <span data-bind="text: mainImageAttributionText()"></span></span>
    </div>
</div>
<asset:script type="text/javascript">

    <g:if test="${projectSite?.extent?.geometry}">
    if ((typeof map === 'undefined' || Object.keys(map).length == 0)) {
        var projectArea = <fc:modelAsJavascript model="${projectSite.extent.geometry}"/>;
        console.log(projectArea);
        if (projectArea) {
            var mapOptions = {
                drawControl: false,
                showReset: false,
                draggableMarkers: false,
                useMyLocation: false,
                allowSearchLocationByAddress: false,
                allowSearchRegionByAddress: false,
                baseLayer: "${project.baseLayer}" || "${grailsApplication.config.map.baseLayers?.find { it.default == true } .code}",
                wmsFeatureUrl: "${createLink(controller: 'proxy', action: 'feature')}?featureId=",
                wmsLayerUrl: "${grailsApplication.config.spatial.geoserverUrl}/wms/reflect?"
            }

            map = new ALA.Map("projectSiteMap", mapOptions);

            if (projectArea.pid && projectArea.pid != 'null' && projectArea.pid != "undefined") {
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
</asset:script>



<script type="text/html" id="associated-orgs">
<div class="well span12 margin-left-0" id="associatedOrgs" data-bind="visible: associatedOrgs().length > 0">
    <div class="well-title"><g:message code="project.display.associatedOrgs"/></div>

    <!-- ko foreach: associatedOrgs -->
    <div class="span5 associated-org thumbnail">
        <div data-bind="visible: url" class=" clearfix">
            <a href="#" data-bind="attr: {href: url}" target="_blank" class="do-not-mark-external">

                <g:set var="noImageUrl" value="${asset.assetPath(src: "no-image-2.png")}"/>

                    %{--Use 'if' instead of 'visible' to prevent creating child elements that potentially will source non https content--}%
                    <div data-bind="if: logo && logo.startsWith('https') "><img src="" data-bind="attr: {src: logo, title: name}"
                                                    alt="Organisation logo" class="small-logo"></div>

                    <div data-bind="visible: !logo || !logo.startsWith('https')" class="associated-org-no-logo"><span data-bind="text: name"></span></div>
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