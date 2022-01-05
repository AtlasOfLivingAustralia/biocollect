<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'adminLayout'}"/>
		<title>Static pages - Edit ${settingTitle} | Data capture | Atlas of Living Australia</title>
		<style type="text/css" media="screen">
		</style>
	</head>
	<body>
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
        <content tag="pageTitle">Static pages</content>
        <div id="wrapper" class="container-fluid padding10-small-screen">
            <div class="row">
                <div class="col-12" id="">
                    <a href="${returnUrl}" class="btn btn-dark"><i class="far fa-arrow-alt-circle-left"></i> back to ${returnLabel}</a>
                    <g:if test="${params.editMode?.toBoolean()}">
                        <g:if test="${!ajax}">
                            <h3>Edit &quot;${settingTitle}&quot; content</h3>
                        </g:if>
                        <g:form id="saveSettingContent" controller="admin" action="saveTextAreaSetting">
                            <g:set var="spanN" value="${ajax ? 'col-12' : 'col-10'}"/>
                            <g:hiddenField name="settingKey" value="${settingKey}" />
                            <g:hiddenField name="returnUrl" value="${returnUrl}" />
                            <div class="row">
                                <div class="${spanN}">
                                    <div class="row">
                                        <div class="col-12 w-100 bg-white" id="notes-button-bar"></div>
                                    </div>
                                    <div class="row pr-2 mt-2">
                                        <div class="col-12">
                                            <g:textArea name="textValue" id="textValue" value="${textValue?:''.trim()}" rows="${!ajax ? 16 : 8}"
                                                    cols="120" style="width:100%;margin:0;"></g:textArea>
                                        </div>
                                    </div>
                                    <h4>Preview:</h4>
                                    <div class="row">
                                        <div class="col-12">
                                            <div id="notes-preview" class="border border-secondary p-5"></div>
                                        </div>
                                    </div>

                                    <div class="hide mt-2"><input type="text" name="copy_html" value="" id="copy_html" class="form-control"></div>
                                </div>
                            </div>
                            <g:if test="${!ajax}">
                                <div class="row mt-2">
                                    <div class="col-12">
                                        <a class="btn btn-dark" href="${returnUrl}"><i class="far fa-times-circle"></i> Cancel</a> &nbsp;
                                        <button class="btn btn-primary-dark"><i class="fas fa-hdd"></i> Save</button>
                                    </div>
                                </div>
                            </g:if>
                            <g:else>
                            </g:else>
                        </g:form>
                    </g:if>
                    <g:else>
                        <h1>${settingTitle}<span>&nbsp;&nbsp;<a href="?editMode=true" class="btn btn-sm btn-dark">
                            <i class="fas fa-pencil-alt"></i>&nbsp;Edit
                        </a></span></h1>
                        <div class="bg-light">
                            <div>${textValue?:''.trim()}</div>
                        </div>
                    </g:else>
                </div>
            </div>
        </div>
    </body>
</html>
