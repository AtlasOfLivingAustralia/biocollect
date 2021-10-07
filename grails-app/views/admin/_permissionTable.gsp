
<div class="row">
    <div class="col-6">
        <table class="table" id="existingMembersTable">
            <thead><tr><th>User&nbsp;Id</th><th>User&nbsp;Name</th><th>Role</th><th>&nbsp;</th><th>&nbsp;</th></tr></thead>
            <tbody class="membersTbody">
            <tr class="d-none">
                <td class="memUserId"></td>
                <td class="memUserName"></td>
                <td class="memUserRole"><span style="white-space: nowrap">&nbsp;</span><g:render template="/admin/userRolesSelect" model="[roles:roles, selectClass:'d-none']"/></td>
                <td><a class="memEditRole tooltips" href="" title="edit this user and role combination"><i class="fa fa-pencil-alt"></i> </a></td>
                <td><a class="memRemoveRole tooltips" href="" title="remove this user and role combination"><i class="fas fa-minus"></i></a></td>
            </tr>
            <tr id="spinnerRow"><td colspan="5">loading data... <g:img uri="${asset.assetPath(src:'spinner.gif')}" id="spinner2" class="spinner" alt="spinner icon"/></td></tr>
            <tr id="messageRow" class="d-none"><td colspan="5">No project members set</td></tr>
            </tbody>
        </table>
    </div>
    <div class="col-6">
        <div id="formStatus" class="d-none alert alert-success">
            <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
            <span></span>
        </div>
    </div>
</div>

<asset:script type="text/javascript">


            /**
            * This populates the "Project Members" table via an AJAX call
            * It uses the jQuery clone pattern to generate HTML using a plain
            * HTML template, found in the table itself.
            * See: http://stackoverflow.com/a/1091493/249327
            */
            function populatePermissionsTable() {
                var numberOfAdmins = 0;
                $("#spinnerRow").show();
                $('.membersTbody tr.cloned').remove();
                $.ajax({
                    url: '${loadPermissionsUrl}'
                })
                .done(function(data) {
                    //alert("Done data = " + data);
                    if (data.length > 0) {
                        $("#messageRow").hide();
                        $.each(data, function(i, el) {
                            var $clone = $('.membersTbody tr.d-none').clone();
                            $clone.removeClass("d-none");
                            $clone.addClass("cloned");
                            $clone.data("userid", el.userId);
                            $clone.data("role", el.role);
                            $clone.find('.memUserId').text(el.userId);
                            $clone.find('.memUserName').text(el.displayName);
                            $clone.find('.memUserRole select').val(el.role);
                            $clone.find('.memUserRole select').attr("id", el.userId);
                            $clone.find('.memUserRole span').text(decodeCamelCase(el.role).replace('Case','Grant')); // TODO: i18n this
                            if (el.role == "admin") {
                                numberOfAdmins++;
                                $clone.find('.memRemoveRole').addClass('admin')
                            }

                            $('.membersTbody').append($clone);
                        });

                        if (numberOfAdmins == 1) {
                            $('.memRemoveRole.admin').css("display", "none");
                        } else {
                            $('.memRemoveRole.admin:hidden').css("display", "inline-block");
                        }
                    } else {
                        $("#messageRow").show();
                    }
                }).fail(function(jqXHR, textStatus, errorThrown) {
                    alert(jqXHR.responseText);
                }).always(function() {
                    $("#spinnerRow").hide();
                });
            }

            function updateStatusMessage2(msg) {
                $('#formStatus span').text(''); // clear previous message
                $('#formStatus span').text(msg).parent().fadeIn();
            }

            /**
            * Modify a user's role
            *
            * @param userId
            * @param role
            */
            function removeUserRole(userId, role) {
                $.ajax( {
                    url: '${removeUserUrl}',
                    data: {
                        userId: userId,
                        role: role,
                        entityId: "${entityId}"
                    }
                })
                .done(function(result) {
                    updateStatusMessage2("user was removed.");
                    }
                )
                .fail(function(jqXHR, textStatus, errorThrown) {
                    alert(jqXHR.responseText);
                    }
                )
                .always(function(result) {
                    $("#spinner1").hide();
                    populatePermissionsTable(); // reload table
                });
            }

            $(function() {
            // click event on the "remove" button on Project Members table
                $('.membersTbody').on("click", ".memRemoveRole", function(e) {
                    e.preventDefault();
                    var $this = this;
                    var userId = $($this).parent().parent().data("userid");
                    var role = $($this).parent().parent().data("role");

                    var message;
                    if (userId == ${user?.userId}) {
                        message = "<span class='label label-important'>Important</span><p><b>If you proceed you may need assistance to get your access back.</b></p><p>Are you sure you want to remove your access to this project?</p>";
                    }
                    else {
                        message = "Are you sure you want to remove this user's access?";
                    }
                    bootbox.confirm(message, function(result) {
                        if (result) {
                            if (userId && role) {
                                removeUserRole(userId, role);
                            } else {
                                alert("Error: required params not provided: userId & role");
                            }
                        }
                    });
                });

                // hide/show the role select for editting role
                $('.membersTbody').on("click", ".memEditRole", function(e) {
                    e.preventDefault();
                    if ($(this).closest('.cloned').find("span").is(':visible')) {
                        $(this).closest('.cloned').find("span").hide();
                        $(this).closest('.cloned').find("select").removeClass('d-none');
                    } else {
                        $(this).closest('.cloned').find("span").show();
                        $(this).closest('.cloned').find("select").addClass('d-none');
                    }
                });

                // detect change on "role" select in table
                $('.membersTbody').on("change", ".memUserRole select", function() {
                    var role = $(this).val();
                    var currentRole = $(this).siblings('span').text();
                    var userId = $(this).attr('id'); // Couldn't get $(el).data('userId') to work for some reason

                    var message;
                    if (userId == ${user?.userId}) {
                        message = "<span class='label label-important'>Important</span><p><b>If you modify your access level you may need assistance to get it back.</b></p><p>Are you sure you want to change your access to this project from " + currentRole + " to " + decodeCamelCase(role)+"?</p>";
                    }
                    else {
                        message = "Are you sure you want to change this user's access from " + currentRole + " to " + decodeCamelCase(role) + "?";
                    }

                    bootbox.confirm(message, function(result) {
                        if (result) {
                            addUserWithRole(userId, role, "${entityId}");
                        } else {
                            populatePermissionsTable(); // reload table
                        }
                    });
                });
            });

</asset:script>