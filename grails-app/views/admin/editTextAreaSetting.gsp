<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'adminLayout'}"/>
		<title>Static pages - Edit ${settingTitle} | Data capture | Atlas of Living Australia</title>
		<style type="text/css" media="screen">
		</style>
	</head>
	<body>
        <asset:javascript src="common.js" />
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
            <div class="row-fluid">
                <div class="span12" id="">
                    <a href="${returnUrl}" class="btn"><i class="icon-hand-left"></i> back to ${returnLabel}</a>
                    <g:if test="${params.editMode?.toBoolean()}">
                        <g:if test="${!ajax}">
                            <h3>Edit &quot;${settingTitle}&quot; content</h3>
                        </g:if>
                        <g:form id="saveSettingContent" controller="admin" action="saveTextAreaSetting">
                            <g:set var="spanN" value="${ajax ? 'span12' : 'span10'}"/>
                            <g:hiddenField name="settingKey" value="${settingKey}" />
                            <g:hiddenField name="returnUrl" value="${returnUrl}" />
                            <div class="row-fluid">
                                <div class="${spanN}">
                                    <div class="row-fluid" id="notes-button-bar" style="width:100%;background-color: white;"></div>
                                    <div class="row-fluid" style="padding-right:12px;">
                                        <g:textArea name="textValue" id="textValue" value="${textValue?:''.trim()}" rows="${!ajax ? 16 : 8}"
                                                    cols="120" style="width:100%;margin:0;"></g:textArea>
                                    </div>
                                    <h4>Preview:</h4>
                                    <div id="notes-preview" class="well well-small"></div>
                                    <div class="hide"><input type="text" name="copy_html" value="" id="copy_html" class="hide"></div>
                                </div>
                            </div>
                            <g:if test="${!ajax}">
                                <div class="row-fluid">
                                    <a class="btn" href="${returnUrl}">Cancel</a>
                                    <button class="btn btn-primary">Save</button>
                                </div>
                            </g:if>
                            <g:else>
                            </g:else>
                        </g:form>
                    </g:if>
                    <g:else>
                        <h1>${settingTitle}<span>&nbsp;&nbsp;<a href="?editMode=true" class="btn btn-small">
                            <i class="icon-edit"></i>&nbsp;Edit
                        </a></span></h1>
                        <div class="well well-small">
                            <div>${textValue?:''.trim()}</div>
                        </div>
                    </g:else>
                </div>
            </div>
        </div>
    </body>
</html>
