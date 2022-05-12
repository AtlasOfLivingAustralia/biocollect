<div class="row">
    <div class="col-12">
        <h4><g:message code="notification.title"/> </h4>
    </div>
</div>
<!-- ko with: transients.notification -->
<form>
    <div class="form-group">
        <label class="col-sm-4 col-form-label"><g:message code="notification.subject"/> </label>
        <div class="col-sm-8">
            <input class="full-width" type="text" data-bind="value: subject">
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-4 col-form-label"><g:message code="notification.body"/></label>
        <div class="col-sm-8">
            <textarea class="full-width" data-bind="value: body" rows="10"></textarea>
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-4 col-form-label"><g:message code="notification.users"/> </label>
        <div class="col-sm-8" id="notification-selected-members">
            <div class="row" data-bind="slideVisible: !transients.recipients().length">
                <div class="col-12" >
                    <p><g:message code="notification.noRecipeients"/> </p>
                </div>
            </div>
            <div class="row" data-bind="slideVisible: transients.recipients().length">
                <div class="col-12" data-bind="foreach: transients.recipients">
                    <div class="input-group">
                        <div class="input-group-append">
                            <span class="input-group-text" data-bind="text: displayName"></span>
                            <span class="btn btn-danger" data-bind="click: $parent.removeMember"><i class="far fa-trash-alt"></i></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-4 col-form-label"><g:message code="notification.bulkActions"/> </label>
        <div class="col-sm-8">
            <div class="row" >
                <div class="col-12" >
                    <button class="btn btn-dark">Select all Members</button>
                    <button class="btn btn-dark">Select only Admins</button>
                    <button class="btn btn-dark">Select only Editors</button>
                    <button class="btn btn-dark">Select only Project Participants</button>
                </div>
            </div>
        </div>
    </div>
    <div class="form-group">
        <div class="col-sm-4 col-form-label">
            <label class="col-sm-4 col-form-label"><g:message code="notification.projectMembers"/> </label>
        </div>
        <div class="col-sm-8">
            <div class="row">
                <div class="col-12">
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
                    <g:render template="/shared/pagination" model="[bs: 4]"/>
                    <!-- /ko -->
                </div>
            </div>
        </div>
    </div>
    <div class="form-group">
        <div class="col-sm-8 offset-sm-4">
            <button class="btn btn-primary-dark" data-bind="click: sendTestNotification"><i class="far fa-paper-plane"></i> <g:message code="notification.sendTest"/> </button>
            <button class="btn btn-danger" data-bind="click: sendNotification"><i class="far fa-paper-plane"></i> <g:message code="notification.send"/> </button>
        </div>
    </div>
</form>
<!-- /ko -->