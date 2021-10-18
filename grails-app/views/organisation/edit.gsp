<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="bs4"/>
    <title>Edit | ${organisation.name.encodeAsHTML()} | <g:message code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'organisation', action: 'list')},Organisations"/>
    <meta name="breadcrumb" content="${organisation.name}"/>

    <asset:script type="text/javascript">
        var fcConfig = {
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            viewProjectUrl: "${createLink(controller: 'project', action: 'index')}",
            documentUpdateUrl: '${g.createLink(controller: "proxy", action: "documentUpdate")}',
            documentDeleteUrl: '${g.createLink(controller: "proxy", action: "deleteDocument")}',
            organisationDeleteUrl: '${g.createLink(action: "ajaxDelete", id: "${organisation.organisationId}")}',
            organisationEditUrl: '${g.createLink(action: "edit", id: "${organisation.organisationId}")}',
            organisationViewUrl: '${g.createLink(action: "index")}',
            organisationListUrl: '${g.createLink(action: "list")}',
            organisationSaveUrl: "${createLink(action: 'ajaxUpdate')}",
            imageUploadUrl: "${createLink(controller: 'image', action: 'upload')}",
            returnTo: "${params.returnTo ?: createLink(action: 'index', id: organisation.organisationId)}"

            };
    </asset:script>
    <asset:stylesheet src="fileupload-ui-manifest.css"/>
    <asset:stylesheet src="wmd/wmd.css"/>
    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="fileupload-manifest.js"/>
    <!-- todo: is cors/jquery.xdr-transport.js needed -->
    <asset:javascript src="cors/jquery.xdr-transport.js"/>
    <asset:javascript src="organisation.js"/>
    <asset:javascript src="document.js"/>
</head>

<body>

<div class="container organisation-header organisation-banner image-box"
     data-bind="style:{'backgroundImage':asBackgroundImage(bannerUrl())}">
    <g:render template="organisationDetails"/>

    <div class="row mt-3">
        <div class="col-12">
            <div class="form-actions">
                <button type="button" id="save" data-bind="click:save" class="btn btn-primary-dark">Save</button>
                <button type="button" id="cancel" class="btn">Cancel</button>
            </div>
        </div>
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