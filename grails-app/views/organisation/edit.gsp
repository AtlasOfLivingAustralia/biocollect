<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Edit | ${organisation.name.encodeAsHTML()} | Field Capture</title>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'organisation', action: 'list')},Organisations"/>
    <meta name="breadcrumb" content="${organisation.name}"/>

    <asset:script type="text/javascript">
        var fcConfig = {
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            viewProjectUrl: "${createLink(controller:'project', action:'index')}",
            documentUpdateUrl: '${g.createLink(controller:"proxy", action:"documentUpdate")}',
            documentDeleteUrl: '${g.createLink(controller:"proxy", action:"deleteDocument")}',
            organisationDeleteUrl: '${g.createLink(action:"ajaxDelete", id:"${organisation.organisationId}")}',
            organisationEditUrl: '${g.createLink(action:"edit", id:"${organisation.organisationId}")}',
            organisationViewUrl: '${g.createLink(action:"index")}',
            organisationListUrl: '${g.createLink(action:"list")}',
            organisationSaveUrl: "${createLink(action:'ajaxUpdate')}",
            imageUploadUrl: "${createLink(controller: 'image', action:'upload')}",
            returnTo: "${params.returnTo?:createLink(action:'index', id:organisation.organisationId)}"

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

<div class="container-fluid organisation-header organisation-banner image-box" data-bind="style:{'backgroundImage':asBackgroundImage(bannerUrl())}">
    <g:render template="organisationDetails"/>

    <div class="form-actions">
        <button type="button" id="save" data-bind="click:save" class="btn btn-primary">Save</button>
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
                blockUISaveMessage:'Saving organisation....',
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
            document.location.href = fcConfig.returnTo;
        });

    });


</asset:script>

</body>
</html>