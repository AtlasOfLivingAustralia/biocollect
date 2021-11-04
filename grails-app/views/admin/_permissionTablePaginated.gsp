<div>
    <div class="row" id="project-member-list">
        <div class="col-12 table-responsive">
            <table class="table table-striped table-bordered table-hover not-stacked-table" id="member-list">
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
    </div>
    <div class="row">
        <div class="col-12">
            <div id="formStatus" class="hide alert alert-success">
                <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
                <span></span>
            </div>
        </div>
    </div>
</div>
<asset:script type="text/javascript">
    $(window).on('load', function () {
        initialise(${raw(roles.inspect())}, ${raw(user?.userId)}, "${raw(project.projectId)}");
     })
</asset:script>
