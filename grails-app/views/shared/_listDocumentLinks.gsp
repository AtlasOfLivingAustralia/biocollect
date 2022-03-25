<!-- ko if: transients.mobileApps().length > 0 -->
<h4 class="text-small-heading"><g:message code="g.mobileApps" /></h4>
<p>
    <span data-bind="foreach:transients.mobileApps">
        <a data-bind="attr:{href:link.url, title: 'Connect with ' + role + ' app'}, css: role" class="do-not-mark-external pr-3"><i data-bind="attr: {class: 'fa-3x ' + icon()}"></i></a>
    </span>
</p>
<!-- /ko -->
<!-- ko if: transients.socialMedia().length > 0 -->
<h4 class="text-small-heading"><g:message code="g.socialMedia" /></h4>
<p>
    <span data-bind="foreach:transients.socialMedia">
        <a data-bind="attr:{href:link.url, title: 'Connect with ' + role}, css: role" class="do-not-mark-external pr-3"><i data-bind="attr: {class: 'fa-3x ' + icon()}"></i></a>
    </span>
</p>
<!-- /ko -->
