<form class="form-horizontal" id="userAccessForm">
    <div class="control-group">
        <label class="control-label" for="emailAddress">User's email address</label>
        <div class="controls">
            <input class="input-xlarge validate[required,custom[email]]" id="emailAddress" placeholder="enter a user's email address" type="text"/>
        </div>
    </div>
    <div class="control-group">
        <label class="control-label" for="addUserRole">Permission level</label>
        <div class="controls" id="rolesSelect">
            <g:render id="addUserRole" template="/admin/userRolesSelect" model="[roles:roles, includeEmptyOption: true]"/>
        </div>
    </div>
    <g:if test="${entityId}">
        <input type='hidden' id='entityId' value='${entityId}'>
    </g:if>
    <g:elseif test="${projects}">
        <div class="control-group">
            <label class="control-label" for="projectId">Project</label>
            <div class="controls nowrap">
                <g:select name="project" id="projectId" class="input-xlarge combobox validate[required]" from="${projects}" optionValue="name" optionKey="projectId" noSelection="['':'start typing a project name']" />
            </div>
        </div>
    </g:elseif>
    <g:else><div class="alert alert-error">Missing model - either <code>projectId</code> or <code>projects</code> must be provided</div></g:else>
    <div class="control-group">
        <div class="controls">
            <button id="addUserRoleBtn" class="btn btn-primary btn-small">Submit</button>
            <g:img uri="${asset.assetPath(src:'spinner.gif')}" id="spinner1" class="hide spinner" alt="spinner icon"/>
        </div>
    </div>
</form>
<div id="status" class="offset2 span7 hide alert alert-success">
    <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
    <span></span>
</div>
<div class="clearfix">&nbsp;</div>
<div class="clearfix hide bbAlert1">
    The email address did not match a registered user. This may because:
    <ul>
        <li>the email address is incorrect</li>
        <li>the user is not registered - see the <a href="${grailsApplication.config.user.registration.url}"
                target='_blank' style='text-decoration: underline;'>sign-up page</a>.
        </li>
    </ul>
</div>
<asset:script type="text/javascript">
    $(document).ready(function() {
        // combobox plugin enhanced select
        $(".combobox").combobox();

        // Click event on "add" button to add new user to project
        $('#addUserRoleBtn').click(function(e) {
            e.preventDefault();
            var email = $('#emailAddress').val();
            var role = $('#addUserRole').val();
            var entityId = $('#entityId').val();

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