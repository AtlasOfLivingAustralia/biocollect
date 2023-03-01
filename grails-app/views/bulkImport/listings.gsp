<%@ page contentType="text/html;charset=UTF-8" %>
<g:set bean="messageSource" var="messageSource"/>
<html>
<head>
    <meta name="layout" content="bs4"/>
    <title>List of bulk imports | | <g:message code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/' + hubConfig.urlPath)},Home"/>
    <meta name="breadcrumb"
          content="${messageSource.getMessage('projectActivity.create.bulkload.list', [].toArray(), '', Locale.default)}"/>
    <asset:stylesheet src="forms-manifest.css"/>
    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="bulk-import-view-models.js"/>
    <asset:script type="text/javascript">
        var fcConfig = {
        <g:applyCodec encodeAs="none">
            projectUrl: "${createLink(controller: 'project', action: 'index')}",
            bulkImportUrl: "${createLink(controller: 'bulkImport')}",
            returnTo: "${returnTo ?: (createLink(uri: '/', params: [hub: hubConfig.urlPath]))}"
        </g:applyCodec>
        },
        here = document.location.href;
    </asset:script>
</head>

<body>
<h1>${messageSource.getMessage('projectActivity.create.bulkload.list', [].toArray(), '', Locale.default)}</h1>
<table class="table">
    <caption>List of bulk imports</caption>
    <thead>
    <tr>
        <th colspan="3"></th>
        <th colspan="2">
            <div class="form-group">
                <label for="searchBulkImport">Search</label>
                <div class="input-group mb-3">
                    <input type="text" class="form-control" id="searchBulkImport" aria-describedby="searchHelp" data-bind="value: search, valueUpdate: 'input', enter: transients.searchHandler">
                    <div class="input-group-append">
                        <button class="btn btn-primary" type="button" id="button-addon2" data-bind="click: transients.searchHandler"><i class="fas fa-search"></i></button>
                    </div>
                </div>

                <small id="searchHelp" class="form-text text-muted">Search by project id, survey id, user id or bulk import id</small>
            </div>
        </th>
    </tr>
    <tr>
        <th scope="col">Description</th>
        <th scope="col">Survey</th>
        <th scope="col">Project</th>
        <th scope="col">Created by</th>
        <th scope="col">Actions</th>
    </tr>
    </thead>
    <tbody data-bind="foreach: bulkImports">
    <tr>
        <td data-bind="text: description"></td>
        <td>
            <!-- ko if: projectActivityId -->
                <a data-bind="attr: { href: $parent.transients.getProjectActivityUrl($data) }, text: transients.projectActivityName"></a>
                (<!-- ko text: projectActivityId --> <!-- /ko -->)
            <!-- /ko -->
        </td>
        <td>
            <!-- ko if: projectId -->
            <a data-bind="attr: { href: $parent.transients.getProjectAboutTabUrl($data) }, text: transients.projectName"></a>
            (<!-- ko text: projectId --> <!-- /ko -->)
            <!-- /ko -->
        </td>
        <td><!-- ko text: transients.userName --> <!-- /ko --> (<!-- ko text: userId --> <!-- /ko -->)</td>
        <td><a class="btn btn-dark" data-bind="attr: { href: $parent.transients.getBulkImportViewUrl($data) }"><i
                class="far fa-eye"></i> View</a></td>
    </tr>
    </tbody>
    <tfoot>
    <tr>
        <td colspan="5">
            <g:render template="/shared/pagination" model="[bs: 4]"/>
        </td>
    </tr>
    </tfoot>
</table>
<script>
    $(function () {
        var viewModel = new BulkImportListingViewModel();
        ko.applyBindings(viewModel);
    });
</script>
</body>
</html>