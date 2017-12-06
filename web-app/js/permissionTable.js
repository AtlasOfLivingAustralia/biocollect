/**
 * Render project members and their roles, support pagination.
 */
function initialise(roles, currentUserId, projectId) {
    var table = $('#member-list').DataTable({
        "bFilter": false,
        "processing": true,
        "serverSide": true,
        "ajax": fcConfig.getMembersForProjectIdPaginatedUrl + "/" + projectId,
        "columns": [{
            data: 'userId',
            name: 'userId',
            bSortable: false
        },
            {
                data: 'displayName',
                name: 'displayName',
                bSortable: false
            },
            {
                data: 'role',
                render: function (data, type, row) {
                    var $select = $("<select></select>", {
                        "id": "role_" + row.userId,
                        "value": data
                    });
                    $.each(roles, function (i, value) {
                        var $option = $("<option></option>", {
                            "text": decodeCamelCase(value).replace('Case', 'Grant'),
                            "value": value
                        });
                        if (data === value) {
                            $option.attr("selected", "selected")
                        }
                        $select.append($option);
                    });
                    return $select.prop("outerHTML");
                },
                bSortable: false
            },
            {
                render: function (data, type, row) {
                    // cannot delete the last admin
                    if (table.ajax.json().totalNbrOfAdmins == 1 && row.role == "admin") {
                        return '';
                    } else {
                        return '<a class="btn btn-small tooltips href="" title="remove this user and role combination"><i class="icon-remove"></i></a>';
                    }
                },
                bSortable: false
            }]
    });

    $('#member-list').on("change", "tbody td:nth-child(3) select", function (e) {
        e.preventDefault();

        var role = $(this).val();
        var row = this.parentElement.parentElement;
        var data = table.row(row).data();
        var currentRole = data.role;
        var userId = data.userId;

        var message;
        if (userId == currentUserId) {
            message = "<span class='label label-important'>Important</span><p><b>If you modify your access level you may need assistance to get it back.</b></p><p>Are you sure you want to change your access to this project from " + currentRole + " to " + decodeCamelCase(role) + "?</p>";
        }
        else {
            message = "Are you sure you want to change this user's access from " + decodeCamelCase(currentRole) + " to " + decodeCamelCase(role) + "?";
        }

        bootbox.confirm(message, function (result) {
            if (result) {
                addUserWithRole(userId, role, projectId);

            } else {
                reloadMembers(); // reload table
            }
        });
    });

    $('#member-list').on("click", "tbody td:nth-child(4) a", function (e) {
        e.preventDefault();

        var row = this.parentElement.parentElement;
        var data = table.row(row).data();
        var userId = data.userId;
        var role = data.role;

        var message;
        if (userId == currentUserId) {
            message = "<span class='label label-important'>Important</span><p><b>If you proceed you may need assistance to get your access back.</b></p><p>Are you sure you want to remove your access to this project?</p>";
        }
        else {
            message = "Are you sure you want to remove this user's access?";
        }
        bootbox.confirm(message, function (result) {
            if (result) {
                if (userId && role) {
                    removeUserRole(userId, role);
                } else {
                    alert("Error: required params not provided: userId & role");
                }
            }
        });
    });

    function updateStatusMessage2(msg) {
        $('#formStatus span').text(''); // clear previous message
        $('#formStatus span').text(msg).parent().fadeIn();
    }

    function removeUserRole(userId, role) {
        $.ajax({
            url: fcConfig.removeUserRoleUrl,
            data: {
                userId: userId,
                role: role,
                entityId: projectId
            }
        })
            .done(function (result) {
                    updateStatusMessage2("user was removed.");
                }
            )
            .fail(function (jqXHR, textStatus, errorThrown) {
                    alert(jqXHR.responseText);
                }
            )
            .always(function (result) {
                reloadMembers(); // reload table
            });
    }
}

function reloadMembers() {
    $('#member-list').DataTable().ajax.reload();
}