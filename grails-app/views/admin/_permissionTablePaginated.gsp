<div class="pill-pane">
    <div class="row well well-small" id="project-member-list">
        <table style="width: 95%;" class="table table-striped table-bordered table-hover" id="member-list">
            <thead>
            <th>User Id</th>
            <th>User Name</th>
            <th>Role</th>
            <th width="5%"></th>
            </thead>
            <tbody>
            </tbody>
        </table>
    </div>
    <div class="span5">
        <div id="formStatus" class="hide alert alert-success">
            <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
            <span></span>
        </div>
    </div>
</div>
<asset:script type="text/javascript">
    $(window).load(function () {
        initialise(${roles.inspect()}, ${user?.userId}, "${project.projectId}");
     })
</asset:script>
