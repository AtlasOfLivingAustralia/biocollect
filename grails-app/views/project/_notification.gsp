<div class="row-fluid">
    <div class="span12">
        <h2><g:message code="notification.title"/> </h2>
    </div>
</div>
<!-- ko with: transients.notification -->
<form class="form-horizontal">
    <div class="control-group">
        <label class="control-label"><g:message code="notification.subject"/> </label>
        <div class="controls">
            <input class="full-width" type="text" data-bind="value: subject">
        </div>
    </div>
    <div class="control-group">
        <label class="control-label"><g:message code="notification.body"/></label>
        <div class="controls">
            <textarea class="full-width" data-bind="value: body" rows="10"></textarea>
        </div>
    </div>
    <div class="control-group">
        <label class="control-label"><g:message code="notification.users"/> </label>
        <div class="controls" id="notification-selected-members">
            <div class="row-fluid" data-bind="slideVisible: !transients.recipients().length">
                <div class="span12" >
                    <p><g:message code="notification.noRecipeients"/> </p>
                </div>
            </div>
            <div class="row-fluid" data-bind="slideVisible: transients.recipients().length">
                <div class="span12" data-bind="foreach: transients.recipients">
                    <div class="input-append">
                        <span class="add-on" data-bind="text: displayName"></span>
                        <span class="add-on" data-bind="click: $parent.removeMember"><i class="icon-remove"></i></span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="control-group">
        <label class="control-label"><g:message code="notification.bulkActions"/> </label>
        <div class="controls" id="notification-selected-members">
            <div class="row-fluid" >
                <div class="span12" >
                    <button class="btn btn-default">Select all Members</button>
                    <button class="btn btn-default">Select only Admins</button>
                    <button class="btn btn-default">Select only Editors</button>
                    <button class="btn btn-default">Select only Project Participants</button>
                </div>
            </div>
        </div>
    </div>
    <div class="control-group">
        <div class="control-label">
            <label class="control-label"><g:message code="notification.projectMembers"/> </label>
        </div>
        <div class="controls">
            <div class="row-fluid">
                <div class="span12">
                    <table class="table table-striped table-bordered table-hover full-width" id="notification-member-list" data-bind="if: transients.members().length">
                        <thead>
                        <th>User Id</th>
                        <th>User Name</th>
                        <th>Role</th>
                        <th>Select/De-select member</th>
                        </thead>
                        <tbody data-bind="foreach: transients.members">
                        <tr>
                            <td data-bind="text: userId"></td>
                            <td data-bind="text: displayName"></td>
                            <td data-bind="text: $parent.getRoleDisplayName(role)"></td>
                            <td>
                                <button class="btn btn-default" data-bind="click: $parent.addMember, disable: $parent.isMemberSelected($data)"><i class="icon-plus"></i> </button>
                                <button class="btn btn-default" data-bind="click: $parent.removeMember, disable: !$parent.isMemberSelected($data)"><i class="icon-remove"></i> </button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                    <p data-bind="if: !transients.members().length"><g:message code="notification.noMembers"/> </p>
                    <!-- ko with: transients -->
                    <g:render template="/shared/pagination"/>
                    <!-- /ko -->
                </div>
            </div>
        </div>
    </div>
    <div class="control-group">
        <div class="controls">
            <button class="btn btn-default" data-bind="click: sendTestNotification"><g:message code="notification.sendTest"/> </button>
            <button class="btn btn-danger" data-bind="click: sendNotification"><g:message code="notification.send"/> </button>
        </div>
    </div>
</form>
<!-- /ko -->