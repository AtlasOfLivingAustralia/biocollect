<%@ page contentType="text/html;charset=UTF-8" %>
<g:set var="config" value="${grailsApplication.config.refAssess}" />
<html>
<head>
    <meta name="layout" content="bs4"/>
    <title>${config.title}</title>
</head>
<body>
<content tag="bannertitle">
    ${config.title}
</content>

<div class="container" id="hubRequestAssessmentRecords">
    <div class="row my-4">
        <div class="col-6">
            <div class="f-flex flex-column h-100 p-3">
                <h1>Step One</h1>
                <h3 class="text-secondary">Select the type of assessment records you&apos;d like to assess</h3>
                <div class="w-100 dropdown">
                    <button class="btn btn-link btn-primary dropdown-toggle text-white w-100 mt-4" type="button" data-toggle="dropdown">
                        <i class="fa fa-tree mr-2"></i>
                        Select ${config.reference.filterName}
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu">
                        <g:each in="${config.reference.filterTypes}" var="filterType">
                            <li class="dropdown-item">
                                <a class="dropdown-item-text user-select-none">
                                    %{--<span class="fa fa-search"></span>--}%
                                    ${filterType}
                                </a>
                            </li>
                        </g:each>
                    </ul>
                </div>
            </div>
        </div>
        <div class="col-6">
           <div class="d-flex flex-column w-100 h-100 p-3">
               <h1>Step Two</h1>
               <h3 class="text-secondary">Request the records</h3>
               <a class="btn btn-primary mt-auto justify-self-end disabled mt-4">
                   <i class="far fa-copy mr-2"></i>
                   Request Records
               </a>
           </div>
    </div>
</div>
</body>
</html>