<div class="row-fluid" data-bind="visible:mainImageUrl">
    <div class="span12 banner-image-container">
        <img src="" data-bind="attr: {src: mainImageUrl}" class="banner-image"/>
        <div data-bind="visible:url" class="banner-image-caption"><strong><g:message code="g.visitUsAt" /> <a data-bind="attr:{href:url}"><span data-bind="text:url"></span></a></strong></div>
    </div>
</div>

<div id="weburl" data-bind="visible:!mainImageUrl()">
    <div data-bind="visible:url()"><strong>Visit us at <a data-bind="attr:{href:url}"><span data-bind="text:url"></span></a></strong></div>
</div>

<div data-bind="visible:description">
    <div class="span12 well">
        <div class="well-title">About ${organisation.name}</div>

        <span data-bind="html:description.markdownToHtml()"></span>
    </div>
</div>