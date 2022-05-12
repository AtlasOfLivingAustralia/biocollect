<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title></title>
    <meta name="layout" content="bs4"/>
    <asset:stylesheet src="common-bs4.css" />
    <asset:stylesheet src="wmd/wmd.css" />
    <asset:javascript src="common-bs4.js" />
    <asset:javascript src="wmd/wmd.js" />
    <asset:script type="text/javascript">
        $(document).ready(function (e) {
            setup_wmd({
                output_format: "markdown",
                input: "textValue",
                output: "copy_html",
                button_bar: "notes-button-bar",
                preview: "notes-preview",
                helpLink: "${asset.assetPath(src:"/wmd/markdownhelp.html")}"
            });
        });
    </asset:script>
</head>
<body data-offset="70" data-target="#page-nav" data-spy="scroll">
<div class="${fluidLayout?'container-fluid':'container'}">
    <div class="inner">
        <div class="row">
            <div class="col-12" id="">
                <g:if test="${params.editMode?.toBoolean()}">
                    <g:form id="saveSettingContent" controller="staticPage" action="saveTextAreaSetting">
                        <g:hiddenField name="settingKey" value="${settingKey}" />
                        <div class="row">
                            <div class="col-12">
                                <div class="row">
                                    <div lang="col-12 bg-white w-100" id="notes-button-bar"></div>
                                </div>
                                <div class="row mt-2">
                                    <div class="col-12">
                                        <g:textArea class="form-control" name="textValue" id="textValue" value="${textValue?:''.trim()}" rows="${!ajax ? 16 : 8}"
                                                cols="120" style="width:100%;margin:0;"></g:textArea>
                                    </div>
                                </div>
                                <div class="row mt-2">
                                    <div class="col-12">
                                        <h4>Preview:</h4>
                                        <div id="notes-preview" class="border border-secondary p-5"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <g:if test="${!ajax}">
                            <div class="row mt-2">
                                <div class="col-12">
                                    <button class="btn btn-primary-dark"><i class="fas fa-hdd"></i> Save</button>
                                    <a class="btn btn-dark" href="${returnUrl}"><i class="far fa-times-circle"></i> Cancel</a>
                                </div>
                            </div>
                        </g:if>
                        <g:else>
                        </g:else>
                    </g:form>
                </g:if>
                <g:else>
                    <h1>${settingTitle}<span>&nbsp;&nbsp;<a href="?editMode=true&page=${params.page}" class="btn btn-sm btn-dark">
                        <i class="fas fa-pencil-alt"></i>&nbsp;Edit
                    </a></span></h1>
                    <div class="border border-secondary p-3">
                        <div>${textValue?:''.trim()}</div>
                    </div>
                </g:else>
            </div>
        </div>
    </div>
%{--    <div style="margin: 200px 0;">&nbsp;</div>--}%
</div>
</body>
</html>