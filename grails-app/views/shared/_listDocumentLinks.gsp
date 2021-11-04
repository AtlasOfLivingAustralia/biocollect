<div class="my-1" data-bind="visible:transients.mobileApps().length > 0">
    <g:message code="g.mobileApps" />: <span data-bind="foreach:transients.mobileApps">
    <a data-bind="attr:{href:link.url}" class="do-not-mark-external"><i data-bind="attr: {class: 'fa-2x ' + icon()}"></i></a>
</span>
</div>
<div class="my-1" data-bind="visible:transients.socialMedia().length > 0">
    <g:message code="g.socialMedia" />: <span data-bind="foreach:transients.socialMedia">
    <a data-bind="attr:{href:link.url}" class="do-not-mark-external"><i data-bind="attr: {class: 'fa-2x ' + icon()}"></i></a>
</span>
</div>
