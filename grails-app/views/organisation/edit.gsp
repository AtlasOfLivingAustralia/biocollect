<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Edit | ${organisation.name.encodeAsHTML()} | Field Capture</title>
    <script type="text/javascript" src="${grailsApplication.config.google.maps.url}"></script>
    <r:script disposition="head">
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
    </r:script>
    <r:require modules="knockout,jqueryValidationEngine,amplify,organisation"/>


</head>
<body>

<div class="container-fluid organisation-header organisation-banner image-box" data-bind="style:{'backgroundImage':asBackgroundImage(bannerUrl())}">

    <div class="row-fluid">
        <ul class="breadcrumb demphasise">
            <li>
                <g:link controller="home">Home</g:link> <span class="divider">/</span>
            </li>
            <li class="active">Organisations <span class="divider">/</span></li>
            <li class="active" data-bind="text:name"/>
        </ul>
    </div>
    <g:render template="organisationDetails"/>

    <div class="form-actions">
        <button type="button" id="save" data-bind="click:save" class="btn btn-primary">Save</button>
        <button type="button" id="cancel" class="btn">Cancel</button>
    </div>

</div>

<r:script>

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


</r:script>

</body>
</html>