<%--
  Created by IntelliJ IDEA.
  User: dos009
  Date: 5/07/13
  Time: 12:32 PM
  To change this template use File | Settings | File Templates.
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Search Results | Field Capture</title>
</head>
<body>
<div id="wrapper" class="container-fluid">
    <div class="row-fluid">
        <div class="span12" id="header">
            <h1 class="pull-left">Search Results</h1>
            <g:form controller="search" method="GET" class="hide form-horizontal pull-right" style="padding-top:5px;">
                <div class="input-append">
                    <g:textField class="input-large" name="query" value="${params.query}"/>
                    <button class="btn" type="submit">Search</button>
                </div>
            </g:form>
        </div>
    </div>
    <g:if test="${flash.error || results.error}">
        <g:set var="error" value="${flash.error?:results.error}"/>
        <div class="row-fluid">
            <div class="alert alert-error large-space-before">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <span>Error: ${error}</span>
            </div>
        </div>
    </g:if>
    <g:elseif test="${results.hits?.total?:0 > 0}">
        <div class="row-fluid ">
            <div class="span9">
                <p class="lead">
                    <fc:searchResultsCounts max="${params.max?:10}" offset="${params.offset?:0}" total="${results.hits.total}"/>
                    <strong>${(params.query=="*:*")?"[all records]":params.query}</strong>
                </p>
            </div>
            <div class="span3 pull-right" style="text-align: right;">
                <g:form class="max" controller="search" method="GET">
                    <g:hiddenField name="query" value="${params.query}"/>
                    <g:hiddenField name="offset" value="${params.offset}"/>
                %{--<g:hiddenField name="sort" value="${params.sort}"/>--}%
                %{--<g:hiddenField name="order" value="${params.order}"/>--}%
                    Items per page:
                    <g:select name="max" from="${[10,20,50,100]}" value="${params.max}" class="btn btn-small" style="width:auto;"
                              onChange="console.log('change');jQuery('form.max').submit();"/>
                </g:form>
            </div>
        </div>
        <div id="content" class="row-fluid ">
            <div id="facetsCol" class="span3 well well-small">
                <h2>Filter results</h2>
                <g:set var="facets" value="${results.facets}"/>
                <g:set var="max" value="${5}"/>
                <g:set var="reqParams" value="sort,order,max,fq,query"/>
                <g:set var="fqLink"><fc:formatParams params="${params}" requiredParams="${reqParams}"/></g:set>
                <g:if test="${params.fq}">
                    <div class="currentFilters">
                        <h4>Current filters</h4>
                        <ul>
                        <%-- convert either Object and Object[] to a list, in case there are multiple params with same name --%>
                            <g:set var="fqList" value="${[params.fq].flatten().findAll { it != null }}"/>
                            <g:each var="f" in="${fqList}">
                                <g:set var="fqBits" value="${f?.tokenize(':')}"/>
                                <g:set var="newUrl"><fc:formatParams params="${params}" requiredParams="${reqParams}" excludeParam="${f}"/></g:set>
                                <li><g:message code="label.${fqBits[0]}" default="${fqBits[0]}"/>: <g:message code="label.${fqBits[1]}" default="${fqBits[1]}"/>
                                    <a href="${newUrl?:"?"}" class="btn btn-inverse btn-mini tooltips" title="remove filter">
                                        <i class="icon-white icon-remove"></i></a>
                                </li>
                            </g:each>
                        </ul>
                    </div>
                </g:if>
                <g:each var="fn" in="${facetsList}">
                    <g:set var="f" value="${results.facets.get(fn)}"/>
                    <g:set var="max" value="${5}"/>
                    <g:if test="${f?.terms?.size() > 0}">
                        <g:set var="fName"><g:message code="label.${fn}" default="${fn?.capitalize()}"/></g:set>
                        <h4>${fName}</h4>
                        <ul class="facetValues">
                            <g:each var="t" in="${f.terms}" status="i">
                                <g:if test="${i < max && t.term}">
                                    <li><a href="${fqLink}&fq=${fn.encodeAsURL()}:${t.term}"><g:message
                                            code="label.${t.term}" default="${t.term}"/></a> (${t.count})
                                    </li>
                                </g:if>
                            </g:each>
                        </ul>
                        <g:if test="${f?.terms?.size() > max}">
                            <a href="#${fn}Modal" role="button" class="moreFacets tooltips" data-toggle="modal" title="View full list of values"><i class="icon-hand-right"></i> choose more...</a>
                            <div id="${fn}Modal" class="modal hide fade">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h3>Filter by ${fName}</h3>
                                </div>
                                <div class="modal-body">
                                    <ul class="facetValues">
                                        <g:each var="t" in="${f.terms}">
                                            <g:if test="${t.term}">
                                                <li><a href="${fqLink}&fq=${fn.encodeAsURL()}:${t.term}"><g:message
                                                        code="label.${t.term}" default="${t.term}"/></a> (${t.count})
                                                </li>
                                            </g:if>
                                        </g:each>
                                    </ul>
                                </div>
                                <div class="modal-footer">
                                    <a href="#" class="btn" data-dismiss="modal">Close</a>
                                </div>
                            </div>
                        </g:if>
                    </g:if>
                </g:each>
            </div>
            <div class="span9">
                <g:if test="${results.hits?.total > 0}">
                    <table class="table table-bordered table-condensed table-striped">
                        <thead>
                        <tr>
                            <th class="<fc:getSortCssClasses params="${params}" field="class"/>">
                                <g:set var="baseParams"><fc:formatParams params="${params}" requiredParams="query,fq,max" excludeParam="sort"/></g:set>
                                <a href="${baseParams}&sort=className&order=${params.order=="DESC"?"ASC":"DESC"}" title="Sort by page type">Page</a>
                            </th>
                            <th class="<fc:getSortCssClasses params="${params}" field="nameSort"/>">
                                <g:set var="baseParams"><fc:formatParams params="${params}" requiredParams="query,fq,max" excludeParam="sort"/></g:set>
                                <a href="${baseParams}&sort=nameSort&order=${params.order=="DESC"?"ASC":"DESC"}" title="Sort by name">Details</a>
                            </th>
                            <th class="<fc:getSortCssClasses params="${params}" field="lastUpdated"/>">
                                <g:set var="baseParams"><fc:formatParams params="${params}" requiredParams="query,fq,max" excludeParam="sort"/></g:set>
                                <a href="${baseParams}&sort=lastUpdated&order=${params.order=="DESC"?"ASC":"DESC"}" title="Sort by date updated">Date updated</a>
                            </th>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each var="r" in="${results.hits.hits}">
                            <g:set var="hit" value="${r._source}"/>
                            <g:set var="highlights" value="${r.highlight?._all}"/>
                            <tr>
                                <td><g:message code="label.${hit.className}" default="${hit.className}"/></td>
                                <td>
                                    <g:if test="${hit.className=~/Project/}">
                                        <g:link controller="project" id="${hit.projectId}">${hit.name}</g:link>
                                    </g:if>
                                    <g:if test="${hit.className=~/Site/}">
                                        <g:link controller="site" id="${hit.siteId}">${hit.name}</g:link>
                                    </g:if>
                                    <g:elseif test="${hit.className=~/Activity/}">
                                        <g:link controller="activity" id="${hit.activityId}">${hit.name?:hit.type}</g:link>
                                    </g:elseif>
                                    <g:else>
                                        ${hit.type}
                                    </g:else>
                                    <g:if test="${highlights}">
                                        &mdash; ${highlights?.join("; ")?.replace("\\/","/")}
                                    </g:if>
                                </td>
                                <td><fc:formatDateString date="${hit.lastUpdated}" inputFormat="yyyy-MM-dd'T'HH:mm:ss'Z'"/></td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                    <div class="pagination">
                        <g:paginate controller="search" total="${results.hits?.total}" params="${params}" />
                    </div>
                </g:if>
            </div>
        </div>
    </g:elseif>
    <g:else>
        <div class="row-fluid ">
            <div class="span12">
                No results found for <strong>${params.query}</strong>
            </div>
        </div>
    </g:else>

</div>
<asset:script type="text/javascript">
    $(window).load(function () {
        $('.tooltips').tooltip({placement: "right"});
    });
</asset:script>
</body>
</html>