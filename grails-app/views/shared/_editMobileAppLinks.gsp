<div class="control-group">
    <label class="control-label span3"><g:message code="g.mobileApps" />:<fc:iconHelp><g:message code="g.mobileApps.help" args="[entity]"/></fc:iconHelp></label>
    <table class="table links-table controls span9">
        <tbody data-bind="foreach:transients.mobileApps">
        <tr>
            <td><img data-bind="attr:{alt:name,title:name,src:logo('${imageUrl}')}"/></td>
            <td><input type="url" data-bind="value:link.url"
                       data-validation-engine="validate[required,custom[url]]"/></td>
            <td><a href="#" data-bind="click:remove"><i class="icon-remove"></i></a></td>
        </tr>
        </tbody>
        <tfoot data-bind="visible:transients.mobileAppsUnspecified().length > 0">
        <tr><td colspan="2">
            <select id="addMobileApp"
                    data-bind="options:transients.mobileAppsUnspecified,optionsText:'name',optionsValue:'role',value:transients.mobileAppToAdd,optionsCaption:'Add mobile app...'"></select>
        </td></tr>
        </tfoot>
    </table>
</div>