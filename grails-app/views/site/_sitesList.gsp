<style type="text/css">
div.dataTables_filter input {
    margin-left:0;
}
</style>
<g:set var="wordForSite" value="${wordForSite?:'site'}"/>

<div id="sitesList">
<bc:koLoading>
    <div data-bind="visible: sites.length == 0">
        <p>No ${wordForSite}s are currently associated with this project.</p>
        <g:if test="${canEditSites}">
            <div class="row-fluid margin-bottom-10">
                <div class="span12">
                    Actions: <span class="btn-group ">
                    <button data-bind="click: $root.addSite" type="button" class="btn"><i
                            class="fa fa-plus"></i> Add new ${wordForSite}</button>
                    <button data-bind="click: $root.addExistingSite" type="button" class="btn"><i
                            class="fa fa-plus"></i> Add existing ${wordForSite}</button>
                    <button data-bind="click: $root.uploadShapefile" type="button" class="btn"><i
                            class="fa fa-upload"></i> Upload ${wordForSite}s from shapefile</button>
                    </span>
                </div>
            </div>
        </g:if>
    </div>


    <div class="row-fluid"  data-bind="visible: sites.length > 0">
        <div class="span5">
            <g:if test="${canEditSites}">
                <div class="row-fluid margin-bottom-10">
                    <div class="span12">
                        Actions:  <span class="btn-group">
                        <a data-bind="click: $root.addSite" class="btn " title="Create a new site for your project"><i class="fa fa-plus"></i> New</a>
                        <a data-bind="click: $root.uploadShapefile" type="button" class="btn " title="Create sites for your project by uploading a shapefile"><i class="fa fa-upload"></i> Upload</a>
                        <a data-bind="click: $root.downloadShapefile" type="button" class="btn " title="Download your project sites in shapefile format"><i class="fa fa-download"></i> Download</a>
                        <button data-bind="click: $root.removeSelectedSites, enable:$root.selectedSiteIds().length > 0" type="button" class="btn " title="Delete selected sites"><i class="fa fa-trash"></i> Delete</button>
                    </span>
                    </div>
                </div>
            </g:if>

            %{-- The use of the width attribute (as opposed to a css style) is to allow for correct resizing behaviour of the DataTable --}%
            <table id="sites-table" class="sites-table table" width="100%">
                <thead>
                <tr>
                        <th><g:if test="${canEditSites}"><input type="checkbox" id="select-all-sites"></g:if></th>
                        <th></th>
                    <th>Name</th>
                    <th>Updated</th>
                    <th></th>
                </tr>

                </thead>
                <tbody data-bind="foreach: sites">
                <tr data-bind="click: $parent.selectDocument">
                        <td><g:if test="${canEditSites}"><input type="checkbox" name="select-site" data-bind="checked:selected"></g:if></td>
                        <td>
                            <g:if test="${canEditSites}">
                                <span class="btn-group">
                                    <a type="button" data-bind="click:$root.editSite" type="button" class="btn btn-mini"><i class="icon-edit" title="Edit ${wordForSite.capitalize()}"></i></a>
                                    <a type="button" data-bind="click:$root.viewSite" type="button" class="btn btn-mini"><i class="icon-eye-open" title="View ${wordForSite.capitalize()}"></i></a>
                                    <a type="button" data-bind="click:$root.deleteSite" type="button" class="btn btn-mini"><i class="icon-remove" title="Delete ${wordForSite.capitalize()}"></i></a>
                                </span>
                            </g:if>
                        </td>
                    <td>
                        <a style="margin-left:10px;" data-bind="text:name, attr: {href:'${createLink(controller: "site", action: "index")}' + '/' + siteId}"></a>
                    </td>
                    <td>
                        <span data-bind="text:convertToSimpleDate(lastUpdated)"></span>
                    </td>
                    <td>
                        <span data-bind="text:lastUpdated"></span>
                    </td>

                </tr>
                </tbody>
            </table>

        </div>


        <div class="span7">
            <div id="map" style="width:100%; height: 500px"></div>
        </div>
    </div>
</bc:koLoading>
</div>
