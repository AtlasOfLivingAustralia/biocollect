<g:set var="orientation" value="${orientation ?: 'horizontal'}"/>

<g:if test="${orientation == 'horizontal'}">
    <div class="span6">
        <m:map id="${source}Map" width="100%"/>
    </div>
</g:if>

<div class="${orientation == 'horizontal' ? 'span6' : 'row-fluid'}" data-bind="visible: activityLevelData.pActivity.sites.length > 1">
    <div class="well">
        <div class="span12">
            <div class="span3">
                <label for="siteLocation">${readonly ? 'Location:' : 'Select a location'}</label>
            </div>

            <div class="span9">
                <g:if test="${readonly}">
                    <span class="output-text" data-bind="text: data.${source}Name() "></span>
                </g:if>
                <g:else>
                    <select id="siteLocation"
                            data-bind='options: activityLevelData.pActivity.sites, optionsText: "name", optionsValue: "siteId", value: data.${source}, optionsCaption: "Choose a site...", disable: ${readonly}'></select>
                </g:else>
            </div>
        </div>
    </div>
</div>

<g:if test="${orientation == 'vertical'}">
    <div class="row-fluid margin-bottom-1">
        <m:map id="${source}Map" width="100%"/>
    </div>
</g:if>

<div class="${orientation == 'horizontal' ? 'span6' : 'row-fluid'}">
    <div class="well">
        <div class="row-fluid">
            <div class="span3">
                <label for="${source}Latitude">Latitude<g:if test="${validation?.contains('required')}"><i class="req-field"></i></g:if></label>
            </div>

            <div class="span9">
                <g:if test="${readonly}">
                    <span data-bind="text: data.${source}Latitude"></span>
                </g:if>
                <g:else>
                    <input id="${source}Latitude" type="text" data-bind="value: data.${source}Latitude"
                           ${validation}>
                </g:else>
            </div>
        </div>

        <div class="row-fluid">
            <div class="span3">
                <label for="${source}Longitude">Longitude<g:if test="${validation?.contains('required')}"><i class="req-field"></i></g:if></label>
            </div>

            <div class="span9">
                <g:if test="${readonly}">
                    <span data-bind="text: data.${source}Longitude"></span>
                </g:if>
                <g:else>
                    <input id="${source}Longitude" type="text" data-bind="value: data.${source}Longitude"
                           ${validation}>
                </g:else>
            </div>
        </div>
    </div>
</div>
