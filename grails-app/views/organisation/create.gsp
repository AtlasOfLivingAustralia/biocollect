<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="bs4"/>
    <title>Create | Organisation | <g:message code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'organisation', action: 'list')},Organisations"/>
    <meta name="breadcrumb" content="New Organisation"/>

    <asset:script type="text/javascript">
        var fcConfig = {
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            organisationSaveUrl: "${createLink(action: 'ajaxUpdate')}",
            organisationViewUrl: "${createLink(action: 'index')}",
            documentUpdateUrl: "${createLink(controller: "proxy", action: "documentUpdate")}",
            returnTo: "${params.returnTo}"
            };
    </asset:script>
    <asset:stylesheet src="fileupload-ui-manifest.css"/>
    <asset:stylesheet src="wmd/wmd.css"/>
    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="fileupload-manifest.js"/>
    <asset:javascript src="cors/jquery.xdr-transport.js"/>
    <asset:javascript src="organisation.js"/>
    <asset:javascript src="document.js"/>

</head>

<body>
<div class="container">
    <g:render template="organisationDetails"/>

    <div class="row mt-3">
        <div class="col-12">
            <div class="form-actions">
                <button  class="btn btn-primary-dark" id="save"  type="button" data-bind="click:save">Create</button>
                <button  class="btn btn-dark" id="cancel" type="button">Cancel</button>
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
            document.location.href = "${createLink(action: 'list')}";
        });

        // tooltip needs to be initialised manually
        $("[data-toggle=\"tooltip\"]").tooltip();
    });

</asset:script>

</body>

</html>