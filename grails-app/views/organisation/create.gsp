<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Create | Organisation | Field Capture</title>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'organisation', action: 'list')},Organisations"/>
    <meta name="breadcrumb" content="New Organisation"/>

    <asset:script type="text/javascript">
        var fcConfig = {
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            organisationSaveUrl: "${createLink(action:'ajaxUpdate')}",
            organisationViewUrl: "${createLink(action:'index')}",
            documentUpdateUrl: "${createLink(controller:"proxy", action:"documentUpdate")}",
            returnTo: "${params.returnTo}"
            };
    </asset:script>
    <asset:stylesheet src="forms-manifest.css"/>
    <asset:stylesheet src="organisation.css"/>
    <asset:javascript src="common.js"/>
    <asset:javascript src="fileupload-9.0.0/load-image.min.js"/>
    <asset:javascript src="fileupload-9.0.0/jquery.fileupload.js"/>
    <asset:javascript src="fileupload-9.0.0/jquery.fileupload-process.js"/>
    <asset:javascript src="fileupload-9.0.0/jquery.fileupload-image.js"/>
    <asset:javascript src="fileupload-9.0.0/jquery.fileupload-video.js"/>
    <asset:javascript src="fileupload-9.0.0/jquery.fileupload-validate.js"/>
    <asset:javascript src="fileupload-9.0.0/jquery.fileupload-audio.js"/>
    <asset:javascript src="fileupload-9.0.0/jquery.iframe-transport.js"/>
    <asset:javascript src="fileupload-9.0.0/locale.js"/>
    <asset:javascript src="cors/jquery.xdr-transport.js"/>
    <asset:javascript src="organisation.js"/>


</head>
<body>
<div class="container-fluid">
    <g:render template="organisationDetails"/>

    <div class="form-actions">
        <button type="button" id="save" data-bind="click:save" class="btn btn-primary">Create</button>
        <button type="button" id="cancel" class="btn">Cancel</button>
    </div>
</div>

<asset:script type="text/javascript">

    $(function () {
        var organisation = <fc:modelAsJavascript model="${organisation}"/>;
        var organisationViewModel = new OrganisationViewModel(organisation);
        autoSaveModel(organisationViewModel, fcConfig.organisationSaveUrl,
            {
                blockUIOnSave:true,
                blockUISaveMessage:'Creating organisation....',
                 serializeModel:function() {return organisationViewModel.modelAsJSON(true);}
            });
        organisationViewModel.save = function() {
            if ($('.validationEngineContainer').validationEngine('validate')) {
                organisationViewModel.saveWithErrorDetection(
                    function(data) {
                        var orgId = self.organisationId?self.organisationId:data.organisationId;

                        var url;
                        if (fcConfig.returnTo) {
                            if (fcConfig.returnTo.indexOf('?') > 0) {
                                url = fcConfig.returnTo+'&organisationId='+orgId;
                            }
                            else {
                                url = fcConfig.returnTo+'?organisationId='+orgId;
                            }
                        }
                        else {
                            url = fcConfig.organisationViewUrl+'/'+orgId;
                        }
                        window.location.href = url;
                    }
                );

            }
        };

        ko.applyBindings(organisationViewModel);
        $('.validationEngineContainer').validationEngine();

        $("#cancel").on("click", function() {
            document.location.href = "${createLink(action:'list')}";
        });

    });


</asset:script>

</body>


</html>