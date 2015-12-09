<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Organisations | Field Capture</title>
    <r:script disposition="head">
        var fcConfig = {
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            createOrganisationUrl: "${createLink(controller: 'organisation', action: 'create')}",
            viewOrganisationUrl: "${createLink(controller: 'organisation', action: 'index')}"
            };
    </r:script>
    <r:require modules="knockout,amplify,organisation,fuseSearch"/>
    <style type="text/css">
.organisation-logo {
    width: 200px;
    height: 150px;
    line-height: 146px;
    margin-right: 10px;
    overflow: hidden;
    padding: 1px;
    text-align: center;
    float:left;
}
</style>

</head>

<body>
<div class="container-fluid">
    <ul class="breadcrumb">
        <li>
            <g:link controller="home">Home</g:link><span class="divider">/</span>
        </li>
        <li class="active">Organisations<span class="divider"></span></li>
    </ul>
<g:if test="${allowOrganisationRegistration}">
    <div>
        <h2 style="display:inline">Registered

        Organisations</h2>

        <g:if test="${user}">
            <button class="btn btn-success pull-right" data-bind="click:addOrganisation">Register new organisation</button>
        </g:if>
    </div>
</g:if>

    <div class="row-fluid">
        <div class="span6 input-prepend">
            <span class="add-on"><i class="icon-search"></i> </span>
            <input id="searchText" data-bind="value:searchTerm, valueUpdate:'keyup'" class="span12" placeholder="Search..." />
        </div>
        <div class="span2">
            <input id="searchByName" type="checkbox" checked="true" data-bind="checkbox:searchName"/>
            <label for="searchByName" style="display:inline">By name</label>
        </div>
        <div class="span2">
            <input id="searchByDescription" type="checkbox" data-bind="checkbox:searchDescription" />
            <label for="searchByDescription" style="display:inline">By description</label>
        </div>
        <div class="span2">
            <input id="searchCaseSensitive" type="checkbox" data-bind="checkbox:caseSensitive" />
            <label for="searchCaseSensitive" style="display:inline">Case sensitive</label>
        </div>
    </div>
    <div class="row-fluid">
        <span class="span12">
            <table class="table table-striped" id="organisations">

                <tbody data-bind="foreach:currentPage">
                <tr class="banner">

                    <td class="organisation-banner" data-bind="style:{'backgroundImage':bannerUrl}">
                        <div class="organisation-logo" data-bind="visible:logoUrl"><img class="logo" data-bind="attr:{'src':logoUrl}"></div>
                        <div style="margin-left:20px;">
                            <h4>
                                <a data-bind="visible:organisationId,attr:{href:fcConfig.viewOrganisationUrl+'/'+organisationId}"><span
                                data-bind="text:name"></span></a>
                                <span data-bind="visible:!organisationId,text:name"></span>
                            </h4>
                            <span data-bind="html:description.markdownToHtml()"></span>
                        </div>
                    </td>
                </tr>
                </tbody>
                <tfoot>
                <tr>
                    <td>
                        <button class="btn" data-bind="click:prev,enable:hasPrev()"><i class="icon-arrow-left"></i> Prev</button>
                        <!-- ko foreach: pageList -->
                        <button class="btn" data-bind="click:function() {$parent.gotoPage($data)},text:$data,css: {active:$data == $parent.pageNum()}"></button>
                        <!-- /ko -->
                        <button class="btn" data-bind="click:next,enable:hasNext()">Next <i class="icon-arrow-right"></i></button>

                    </td>

                </tr>
                </tfoot>

            </table>
        </span>

    </div>

</div>


<r:script>

    $(function () {

        var userOrgs = [], otherOrgs = [], citizenScienceOrg;

        var organisations = <fc:modelAsJavascript model="${organisations}" default="${[]}"/>;
        var userOrgIds = <fc:modelAsJavascript model="${userOrgIds}" default="${[]}"/>;
        var organisationsViewModel = new OrganisationsViewModel(organisations, userOrgIds);

        ko.applyBindings(organisationsViewModel);


});

</r:script>

</body>

</html>