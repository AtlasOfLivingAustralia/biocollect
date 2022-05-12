<form id="userAccessForm">
    <div class="row form-group">
        <label class="col-form-label col-md-3" for="emailAddress"><g:message code="project.admin.permissions.email"/></label>
        <div class="col-md-9">
            <input class="form-control validate[required,custom[email]]" id="emailAddress" placeholder="enter a user's email address" type="text"/>
        </div>
    </div>
    <div class="row form-group">
        <label class="col-form-label col-md-3" for="addUserRole"><g:message code="project.admin.permissions.level"/></label>
        <div class="col-md-9" id="rolesSelect">
            <g:render id="addUserRole" template="/admin/userRolesSelect" model="[roles:roles, includeEmptyOption: true, selectClass: 'form-control']"/>
        </div>
    </div>
    <g:if test="${entityId}">
        <input type='hidden' id='entityId' value='${entityId}'>
    </g:if>
    <g:elseif test="${projects}">
        <div class="row form-group">
            <label class="col-form-label col-md-3" for="projectId"><g:message code="g.project"/></label>
            <div class="col-md-9">
                <g:select name="project" id="projectId" class="form-control combobox validate[required]" from="${projects}" optionValue="name" optionKey="projectId" noSelection="['':'start typing a project name']" />
            </div>
        </div>
    </g:elseif>
    <g:else><div class="alert alert-danger"><g:message code="project.admin.permissions.missingmodel"/></div></g:else>
    <div class="row form-group">
        <div class="col-md-9 offset-md-3">
            <button id="addUserRoleBtn" class="btn btn-sm btn-primary-dark"><i class="fas fa-upload"></i> <g:message code="g.submit"/></button>
            <g:img uri="${asset.assetPath(src:'spinner.gif')}" id="spinner1" class="d-none spinner" alt="spinner icon"/>
        </div>
    </div>
</form>
<div id="status" class="offset-md-2 col-md-7 d-none alert alert-success">
    <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
    <span></span>
</div>
%{--<div class="clearfix">&nbsp;</div>--}%
<div class="d-none bbAlert1">
    <g:message code="project.admin.permissions.noemail"/>
    <ul>
        <li><g:message code="project.admin.permissions.incorrectemail"/></li>
        <li><g:message code="project.admin.permissions.emailnotregistered"/> <a href="${grailsApplication.config.user.registration.url}"
                target='_blank'><u><g:message code="project.admin.permissions.signup"/>sign-up page</u></a>.
        </li>
    </ul>
</div>
<asset:script type="text/javascript">
    $(document).ready(function() {
        // combobox plugin enhanced select
        // $(".combobox").combobox();

        // Click event on "add" button to add new user to project
        $('#addUserRoleBtn').on('click',function(e) {
            e.preventDefault();
            var email = $('#emailAddress').val();
            var role = $('#addUserRole').val();
            var entityId = $('#entityId').val();
            entityId = entityId ||  $('#projectId').val();

            if ($('#userAccessForm').validationEngine('validate')) {
                $("#spinner1").show();

                if (email) {
                    // first check email address is a valid user
                    $.get("${g.createLink(controller:'user',action:'checkEmailExists')}?email=" + email, function(data) {
                        if (data && /^\d+$/.test(data)) {
                            addUserWithRole( data, role, entityId);
                        } else {
                            var $clone = $('.bbAlert1').clone();
                            bootbox.alert($clone.show());
                        }
                    })
                    .fail(function(jqXHR, textStatus, errorThrown) { alert(jqXHR.responseText); })
                    .always(function() { $(".spinner").hide(); });
                }
            }
        });
    }); // end document ready

    /**
     * Add a user with given role to the current project
     *
     * @param userId
     * @param role
     * @param projectId
     */
    function addUserWithRole(userId, role, id) {
        //console.log("addUserWithRole",userId, role, projectId);
        if (userId && role) {
            $.ajax({
                url: '${addUserUrl}',
                data: { userId: userId, role: role, entityId: id }
            })
            .done(function(result) { updateStatusMessage("user was added with role " + decodeCamelCase(role)); })
            .fail(function(jqXHR, textStatus, errorThrown) { alert(jqXHR.responseText); })
            .always(function(result) { resetAddForm(); });
        } else {
            alert("Required fields are: userId and role.");
            $('.spinner').hide();
        }
    }

    function updateStatusMessage(msg) {
        $('#status span').text(''); // clear previous message
        $('#status span').text(msg).parent().fadeIn();
    }

    function resetAddForm() {
        $(".spinner").hide();
        $("#userAccessForm")[0].reset();
        if ($("#projectId").data('combobox')) {
            $("#projectId").data('combobox').toggle(); // reset combobox
        }
        // project page - trigger user table refresh
        if (typeof(reloadMembers()) != "undefined") {
            reloadMembers();
        }

    }
</asset:script>
