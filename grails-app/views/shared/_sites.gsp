<div class="tab-pane" id="mapView">
    <m:map id="siteMap" width="100%"/>

    <div style=" float: right;" id="map-info">
        <span id="numberOfProjects">${projectCount ?: 0}</span> projects with <span
            id="numberOfSites">[calculating]</span>
    </div>
</div>

<asset:script type="text/javascript">

    function generateMap(facetList) {
        var url = "${createLink(controller: 'nocas', action: 'geoService')}?max=10000&geo=true";

        if (facetList && facetList.length > 0) {
            url += "&fq=" + facetList.join("&fq=");
        }
        <g:if test="${params.fq}">
            <g:set var="fqList" value="${[params.fq].flatten()}"/>
            url += "&fq=${fqList.collect { it.encodeAsURL() }.join('&fq=')}";
        </g:if>
        var projectLinkPrefix = "${createLink(controller: 'project')}/";
        var siteLinkPrefix = "${createLink(controller: 'site')}/";

        var siteDisplay = new Biocollect.SiteDisplay();
        siteDisplay.generateMap(url, projectLinkPrefix, siteLinkPrefix);
    }
</asset:script>
