<div class="row form-group">
    <label class="col-form-label col-md-4"><g:message code="g.mobileApps" />:<fc:iconHelp><g:message code="g.mobileApps.help" args="[entity]"/></fc:iconHelp></label>
    <table class="table links-table col-md-8">
        <tbody data-bind="foreach:transients.mobileApps">
        <tr>
            <td><i class="fa-2x" data-bind="attr:{alt:name, title:name, class: 'fa-2x ' + icon()}"></i></td>
            <td><input class="form-control form-control-sm" type="url" data-bind="value:link.url"
                       data-validation-engine="validate[required,custom[url]]"/></td>
            <td><a class="btn btn-danger btn-sm" href="#" data-bind="click:remove"><i class="far fa-trash-alt"></i></a></td>
        </tr>
        </tbody>
        <tfoot data-bind="visible:transients.mobileAppsUnspecified().length > 0">
        <tr><td colspan="2">
            <select class="form-control" id="addMobileApp"
                    data-bind="options:transients.mobileAppsUnspecified,optionsText:'name',optionsValue:'role',value:transients.mobileAppToAdd,optionsCaption:'Add mobile app...'"></select>
        </td></tr>
        </tfoot>
    </table>
</div>