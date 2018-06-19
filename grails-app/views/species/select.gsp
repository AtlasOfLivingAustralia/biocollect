<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>${project.name} | Species | Field Capture</title>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'project', action: 'index')}/${project.projectId},${project.name}"/>
    <meta name="breadcrumb" content="Species"/>

    <asset:stylesheet src="datatables-manifest.css"/>
    <asset:javascript src="common.js"/>
    <asset:javascript src="datatables-manifest.js"/>
</head>
<body>
<div class="container-fluid validationEngineContainer" id="validation-container">
    <div class="row-fluid">
        <div class="page-header">
            <h1>${project.name} - Species</h1>
        </div>
    </div>

    <div class="row-fluid" data-bind="visible: speciesLists().length">
        <div class="span12">
            <h3>Project Species Lists</h3>
            <table class="table-striped">
                <thead>
                <tr> <th>Species List Name</th><th>Species Count</th><th>Used for</th><th></th>
                </thead>
                <tbody data-bind="foreach: speciesLists">
                <tr>
                    <td data-bind="text:listName"></td>
                    <td data-bind="text:itemCount"></td>
                    <td>
                    <select data-bind="value:purpose">
                        <option></option>
                    <g:each in="${activityTypes}" var="t" status="i">
                        <g:if test="${i == 0 && create}">
                            <option></option>
                        </g:if>
                        <optgroup label="${t.name}">
                        <g:each in="${t.list}" var="opt">
                            <option>${opt.name}</option>
                        </g:each>
                        </optgroup>
                    </g:each>
                    </select>
                    </td>
                    <td width="10%"><a class="btn btn-mini" data-bind="click:$root.removeSpeciesList" href="#" title="edit"><i class="icon-edit"></i> Remove</a></td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
    <div class="row-fluid">
        <div data-bind="visible: !speciesLists().length" class="span12">
            This project does not have any species of interest.
        </div>
    </div>

    <div class="form-actions">
        <button type="button" data-bind="click: save" class="btn btn-primary">Save changes</button>
        <button type="button" id="cancel" data-bind="click:cancel" class="btn">Cancel</button>
    </div>


    <h3 class="pull-left">Available Species Lists</h3>
    <div id="availableSpeciesLists" class="row-fluid">
        <div class="span12 well list-box">
            <span id="project-filter-warning" class="label filter-label label-warning hide pull-left">Filtered</span>
            <div class="control-group pull-right dataTables_filter">
                <div class="input-append">
                    <g:textField class="filterinput input-medium" data-target="project"
                                 title="Type a few characters to restrict the list." name="projects"
                                 placeholder="filter"/>
                    <button type="button" class="btn clearFilterBtn"
                            title="clear"><i class="icon-remove"></i></button>
                </div>
            </div>

            <div class="scroll-list clearfix" id="projectList">
                <table class="accordion" id="speciesLists">
                    <thead class="hide"><tr><th>Name</th><th></th><th></th></tr></thead>
                    <tbody>

                    </tbody>
                </table>
            </div>

        </div>
    </div>
    <hr />
    <div class="debug">
        <h3 id="debug">Debug</h3>
        <div style="display:none">
            <pre data-bind="text: ko.toJSON($root, null, 2)"></pre>
            <pre>${project}</pre>
        </div>
    </div>

</div>
<asset:script type="text/javascript">
$(window).load(function(){

    var SpeciesList = function(data) {
        this.listId = data.dataResourceUid;
        this.listName = data.listName;
        this.itemCount = data.itemCount;
        this.purpose = 'Reporting';
    }

    function SpeciesViewModel (data) {
        var self = this;
        
        self.speciesLists = ko.observableArray(data.speciesLists !== undefined ? data.speciesLists : []);

        self.availableLists = [];

        self.cancel = function() {
            document.location.href = '<g:createLink controller="project" action="index" id="${project.projectId}"/>';
        }
        self.addSpeciesList = function(event) {
            var uid = $(event.currentTarget).data('listuid');
            $.each(self.availableLists, function(index, list) {
                if (list.dataResourceUid === uid) {
                    self.speciesLists.push(new SpeciesList(list));
                    $(event.currentTarget).parents('tr').hide();
                    return false;
                }
            });

        };
        self.removeSpeciesList = function(data, event) {
            self.speciesLists.remove(data);
        }
        self.selectSpeciesLists = function(data, event) {
            $('#availableSpeciesLists').dialog({
                buttons: [{
                    text: "OK",
                    click: function() {
                        $( this ).dialog( "close" );
                    }
                }],
                width:"600px"
            });
        };

        self.loadAvailableSpeciesLists = function() {
            $('#speciesLists').delegate('button', 'click', function(event) {
                self.addSpeciesList(event);
            });
            $.get('${createLink(controller:'proxy', action:'speciesLists')}', {}, function(data) {
                self.availableLists = data.lists;
                $('#speciesLists').dataTable({
                    "aaData": self.availableLists,
                    "aoColumns": [
                        {"mData":"listName"},
                        {"mData":function(obj, string, value) {return '<a href="#">'+obj.itemCount+'</a>';}},
                        {"mData":function(obj, string, value){return '<button class="btn" data-listuid="'+obj.dataResourceUid+'"/>Use this list'}}
                    ],
                    "sPaginationType": "bootstrap",
                    "oLanguage": {
                        "oPaginate": {
                            "sNext": "▶",
                            "sPrevious": "◀"
                        }
                    },
                    "bFilter": true,
                    "bLengthChange": false,
                    "bInfo": false
                });

            },'json');
        }


        self.save = function () {
            //if ($('.validation-container').validationEngine('validate')) {
                var jsData = ko.toJS(self.speciesLists);
                var json = JSON.stringify({speciesLists:jsData});
                var id = "${project?.projectId ? '/' + project.projectId : ''}";
                $.ajax({
                    url: "${createLink(action: 'ajaxUpdate')}" + id,
                    type: 'POST',
                    data: json,
                    contentType: 'application/json',
                    success: function (data) {
                        if (data.error) {
                            alert(data.detail + ' \n' + data.error);
                        } else {
                            var projectId = "${project?.projectId}" || data.projectId;
                            if (data.message === 'created') {
                                document.location.href = "${createLink(controller: 'home', action: 'index')}";
                            } else {
                                document.location.href = "${createLink(action: 'index')}/" + projectId;
                            }
                        }
                    },
                    error: function (data) {
                        var status = data.status;
                        alert('An unhandled error occurred: ' + data.status);
                    }
                });
            //}
        }
    };

    var speciesViewModel = new SpeciesViewModel(${project ?: [:]});
    speciesViewModel.loadAvailableSpeciesLists();

    ko.applyBindings(speciesViewModel);



});

</asset:script>
</body>
</html>