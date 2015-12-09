<g:set var="wordForSite" value="${wordForSite?:'site'}"/>
<div id="sitesList">
    <div data-bind="visible: sites.length == 0">
        <p>No ${wordForSite}s are currently associated with this project.</p>
        <g:if test="${editable}">
            <div class="btn-group btn-group-horizontal ">
                <button data-bind="click: $root.addSite" type="button" class="btn">Add new ${wordForSite}</button>
                <button data-bind="click: $root.addExistingSite" type="button" class="btn">Add existing ${wordForSite}</button>
                <button data-bind="click: $root.uploadShapefile" type="button" class="btn">Upload ${wordForSite}s from shapefile</button>
            </div>
        </g:if>
    </div>

    <div class="row-fluid"  data-bind="visible: sites.length > 0">
        <div class="span5 well list-box">
            <div class="span9">
                <div class="control-group">
                    <div class="input-append">
                        <input type="text" class="filterinput input-medium"
                               data-bind="value: sitesFilter, valueUpdate:'keyup'"
                               title="Type a few characters to restrict the list." name="sites"
                               placeholder="filter"/>
                        <button type="button" class="btn" data-bind="click:clearFilter"
                                title="clear"><i class="icon-remove"></i></button>
                    </div>
                    <span id="site-filter-warning" class="label filter-label label-warning"
                          style="display:none;margin-left:4px;"
                          data-bind="visible:sitesFilter().length > 0,valueUpdate:'afterkeyup'">Filtered</span>
                </div>

                <div class="scroll-list">
                    <ul id="siteList" style="list-style: none; margin-left: 0px;"
                        data-bind="template: {foreach:displayedSites},
                                                      beforeRemove: hideElement,
                                                      afterAdd: showElement">
                        <li data-bind="event: {mouseover: $root.highlight, mouseout: $root.unhighlight}">
                            <g:if test="${editable}">
                                <span>
                                    <button type="button" data-bind="click:$root.editSite" class="btn btn-container"><i class="icon-edit" title="Edit ${wordForSite.capitalize()}"></i></button>
                                    <button type="button" data-bind="click:$root.viewSite" class="btn btn-container"><i class="icon-eye-open" title="View ${wordForSite.capitalize()}"></i></button>
                                    <button type="button" data-bind="click:$root.deleteSite" class="btn btn-container"><i class="icon-remove" title="Delete ${wordForSite.capitalize()}"></i></button>
                                </span>

                                <a style="margin-left:10px;" data-bind="text:name, attr: {href:'${createLink(controller: "site", action: "index")}' + '/' + siteId}"></a>
                            </g:if>
                            <g:else>
                                <span data-bind="text:name"></span>
                            </g:else>
                        </li>
                    </ul>
                </div>
                <div id="paginateTable" data-bind="visible:sites.length>pageSize">
                    <span id="paginationInfo" style="display:inline-block;float:left;margin-top:4px;"></span>
                    <div class="btn-group">
                        <button class="btn btn-small prev" data-bind="click:prevPage,enable:(offset()-pageSize) >= 0"><i class="icon-chevron-left"></i>&nbsp;previous</button>
                        <button class="btn btn-small next" data-bind="click:nextPage,enable:(offset()+pageSize) < filteredSites().length">next&nbsp;<i class="icon-chevron-right"></i></button>
                    </div>
                    <g:if env="development">
                        total: <span id="total" data-bind="text:filteredSites().length"></span>
                        offset: <span id="offset" data-bind="text:offset"></span>
                    </g:if>
                </div>

            </div>
        %{--<div class="span5" id="sites-scroller">
           <ul class="unstyled inline" data-bind="foreach: sites">
               <li class="siteInstance" data-bind="event: {mouseover: $root.highlight, mouseout: $root.unhighlight}">
                   <a data-bind="text: name, click: $root.openSite"></a>
                   <button data-bind="click: $root.removeSite" type="button" class="close" title="delete">&times;</button>
               </li>
           </ul>
       </div>--}%

            <g:if test="${editable}">

                <div class="row-fluid">
                    <div class="span3">
                        <div class="btn-group btn-group-vertical pull-right">
                            <a data-bind="click: $root.addSite" type="button" class="btn ">Add new ${wordForSite}</a>
                            <a data-bind="click: $root.addExistingSite" type="button" class="btn">Add existing ${wordForSite}</a>
                            <a data-bind="click: $root.uploadShapefile" type="button" class="btn">Upload ${wordForSite}s from shapefile</a>
                            <a data-bind="click: $root.removeAllSites" type="button" class="btn">Delete all ${wordForSite}s</a>
                        </div>
                    </div>
                </div>
            </g:if>
        </div>
        <div class="span7">
            <div id="map" style="width:100%"></div>
        </div>
    </div>
</div>

<r:script>
   function initialiseSites(sites) {
        var mapOptions = {
            zoomToBounds:true,
            zoomLimit:16,
            highlightOnHover:true,
            features:[],
            featureService: "${createLink(controller: 'proxy', action: 'feature')}",
            wmsServer: "${grailsApplication.config.spatial.geoserverUrl}"
        };

        map = new new ALA.Map("map", {});
        var mapFeatures = $.parseJSON('${mapFeatures?:[].encodeAsJavaScript()}');
        var sitesViewModel = new SitesViewModel(sites, map, mapFeatures, ${editable ?: false});
        ko.applyBindings(sitesViewModel, document.getElementById('sitesList'));

    };
</r:script>
