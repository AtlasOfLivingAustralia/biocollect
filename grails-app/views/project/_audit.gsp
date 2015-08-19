<div class="row-fluid">
    <div class="span12">
        <h3>Audit</h3>
    </div>
</div>
<div class="row-fluid">
    <div class="span12">
        <g:link controller="admin" action="auditProject" params='[id: "${project.projectId}", searchTerm:"${project.name}"]' target="_blank">
            <h4>${project.name}</h4>
        </g:link>
    </div>
</div>




