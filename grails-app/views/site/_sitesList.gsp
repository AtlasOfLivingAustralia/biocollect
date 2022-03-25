<style type="text/css">
</style>
<g:set var="wordForSite" value="${wordForSite?:'site'}"/>

<div id="sitesList" class="container-fluid">
<bc:koLoading>
    <div data-bind="visible: sites.length == 0">
        <p>No ${wordForSite}s are currently associated with this project.</p>
        <g:if test="${canEditSites}">
            <div class="row">
                <div class="col-sm-12">
                    Actions: <span class="btn-group ">
                    <button data-bind="click: $root.addSite" type="button" class="btn btn-dark"><i
                            class="fa fa-plus"></i> Add new ${wordForSite}</button>
                    <button data-bind="click: $root.addExistingSite" type="button" class="btn btn-dark"><i
                            class="fa fa-plus"></i> Add existing ${wordForSite}</button>
                    <button data-bind="click: $root.uploadShapefile" type="button" class="btn btn-dark"><i
                            class="fa fa-upload"></i> Upload ${wordForSite}s from shapefile</button>
                    </span>
                </div>
            </div>
        </g:if>
    </div>


    <div class="row"  data-bind="visible: sites.length > 0">
        <div class="col-sm-5">
            <g:if test="${canEditSites}">
                <div class="row mb-3">
                    <div class="col-sm-12">
                        Actions:  <span class="btn-group">
                        <a data-bind="click: $root.addSite" class="btn btn-dark" title="Create a new site for your project"><i class="fa fa-plus"></i> New</a>
                        <a data-bind="click: $root.uploadShapefile" type="button" class="btn btn-dark" title="Create sites for your project by uploading a shapefile"><i class="fa fa-upload"></i> Upload</a>
                        <a data-bind="click: $root.downloadShapefile" type="button" class="btn btn-dark" title="Download your project sites in shapefile format"><i class="fa fa-download"></i> Download</a>
                        <button data-bind="click: $root.removeSelectedSites, enable:$root.selectedSiteIds().length > 0" type="button" class="btn btn-danger" title="Delete selected sites"><i class="far fa-trash-alt"></i> Delete</button>
                    </span>
                    </div>
                </div>
            </g:if>

            %{-- The use of the width attribute (as opposed to a css style) is to allow for correct resizing behaviour of the DataTable --}%
            <table id="sites-table" class="sites-table table dataTable" width="100%">
                <thead>
                <tr>
                        <th class="col-1"><g:if test="${canEditSites}"><input type="checkbox" id="select-all-sites"></g:if></th>
                        <th class="col-3"></th>
                    <th>Name</th>
                    <th>Updated</th>
                    <th></th>
                </tr>

                </thead>
                <tbody data-bind="foreach: sites">
                <tr data-bind="click: $parent.selectDocument">
                        <td class="col-1"><g:if test="${canEditSites}"><input type="checkbox" name="select-site" data-bind="checked:selected"></g:if></td>
                        <td class="col-3">
                            <g:if test="${canEditSites}">
                                <span class="btn-group">
                                    <a type="button" data-bind="click:$root.editSite" type="button" class="btn btn-sm btn-dark"><i class="fas fa-pencil-alt" title="Edit ${wordForSite.capitalize()}"></i></a>
                                    <a type="button" data-bind="click:$root.viewSite" type="button" class="btn btn-sm btn-dark"><i class="far fa-eye" title="View ${wordForSite.capitalize()}"></i></a>
                                    <a type="button" data-bind="click:$root.deleteSite" type="button" class="btn btn-sm btn-danger"><i class="far fa-trash-alt" title="Delete ${wordForSite.capitalize()}"></i></a>
                                </span>
                            </g:if>
                        </td>
                    <td>
                        <a data-bind="text:name, attr: {href:'${createLink(controller: "site", action: "index")}' + '/' + siteId}"></a>
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


        <div class="col-sm-7">
            <div id="map" style="width:100%; height: 500px"></div>
        </div>
    </div>
</bc:koLoading>
</div>
