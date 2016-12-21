<div id="bannerHubContainer" class="container-fluid">
    <div id="bannerHubOuter">
        <g:if test="${hubConfig.logoUrl}">
            <div class="logo">
                <img src="${hubConfig.logoUrl}">
            </div>
        </g:if>

        <g:if test="${hubConfig.templateConfiguration?.banner?.images?.size()}">
            <div id="bannerHub" class="carousel slide">
                <div class="carousel-inner">
                    <g:set var="images" value="${hubConfig.templateConfiguration.banner.images}"></g:set>
                    <g:each var="image" in="${images}" status="index">
                        <div class="item ${index ==0? 'active' :''}">
                            <img src="${image.url}">
                            <g:if test="${image.caption}">
                                <div class="carousel-caption">
                                    <p>${image.caption}</p>
                                </div>
                            </g:if>
                        </div>
                    </g:each>
                </div>
            </div>
        </g:if>
    </div>
    <script>
        $(document).ready(function () {
            $("#bannerHub").carousel({
                interval: ${hubConfig.templateConfiguration.banner.transitionSpeed?:3000}
            });
        });
    </script>
</div>