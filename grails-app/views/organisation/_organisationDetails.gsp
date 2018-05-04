<form class="form-horizontal validationEngineContainer">

    <div class="row-fluid">
        <div class="well">
            <h4 class="block-header"><g:message code="organisation.details.header"/></h4>

            <div class="control-group required">
                <label class="control-label span3" for="name">Name: <fc:iconHelp><g:message code="organisation.name.help"/></fc:iconHelp> </label>
                <div class="controls span9">
                    <input type="text" id="name" class="input-xxlarge" data-bind="value:name" maxlength="256" data-validation-engine="validate[required,maxSize[256]]" placeholder="Organisation name">
                </div>
            </div>
            %{--Commenting out the type until we can come up with some better options and include them in the collectory--}%
            %{--<div class="control-group">--}%
                %{--<label class="control-label" for="name">Type</label>--}%
                %{--<div class="controls required">--}%
                    %{--<select id="orgType"--}%
                            %{--data-bind="value:orgType,options:transients.orgTypes,optionsText:'name',optionsValue:'orgType',optionsCaption: 'Choose...'"--}%
                            %{--data-validation-engine="validate[required]"></select>--}%
                %{--</div>--}%
            %{--</div>--}%
            <div class="control-group required">
                <label class="control-label span3" for="description">Description: <fc:iconHelp><g:message code="organisation.description.help"/></fc:iconHelp></label>
                <div class="controls span9">
                    <textarea rows="3" class="input-xxlarge" data-bind="value:description" data-validation-engine="validate[required]" id="description" placeholder="A description of the organisation"></textarea>
                    <br/><button class="btn popup-edit" data-bind="click:editDescription"><i class="icon-edit"></i> Edit with Markdown Editor</button>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label span3" for="url">Web Site URL: <fc:iconHelp><g:message code="organisation.webUrl.help"/></fc:iconHelp></label>
                <div class="controls span9">
                    <input type="text" class="input-xxlarge" id="url" data-bind="value:url" data-validation-engine="validate[custom[url]]" placeholder="link to your organisations website">
                </div>
            </div>
            <g:render template="/shared/editSocialMediaLinks"
                      model="${[entity:'organisation',imageUrl:asset.assetPath(src:'filetypes')]}"/>
        </div>
    </div>

    <div class="row-fluid">
        <div class="well">
            <h4 class="block-header"><g:message code="organisation.images.header"/></h4>

            <div class="control-group">
                <label class="control-label span3" for="logo">Organisation Logo<fc:iconHelp><g:message code="organisation.logo.help"/></fc:iconHelp>:</label>
                <div class="span6" style="text-align:center;background:white">
                    <g:message code="organisation.logo.extra"/><br/>
                    <div class="well" style="padding:0;width:200px;height:150px;line-height:146px;display:inline-block">
                        <img style="max-width:100%;max-height:100%" alt="No image provided" data-bind="attr:{src:logoUrl}">
                    </div>
                    <div data-bind="visible:logoUrl()"><g:message code="organisation.logo.visible"/></div>
                </div>
                <span class="span3">
                    <span class="btn fileinput-button pull-right"
                          data-url="${createLink(controller: 'image', action: 'upload')}"
                          data-role="logo"
                          data-owner-type="organisationId"
                          data-owner-id="${organisation?.organisationId}"
                          data-bind="stagedImageUpload:documents, visible:!logoUrl()"><i class="icon-plus"></i> <input
                            id="logo" type="file" name="files"><span>Attach</span></span>

                    <button class="btn main-image-button" data-bind="click:removeLogoImage, visible:logoUrl()"><i class="icon-minus"></i> Remove</button>
                </span>
            </div>

            <div class="control-group">
                <label class="control-label span3" for="mainImage">Feature Graphic<fc:iconHelp><g:message code="organisation.mainImage.help"/></fc:iconHelp>:</label>
                <div class="span6" style="text-align:center;background:white">
                    <g:message code="organisation.mainImage.extra"/><br/>
                    <div class="well" style="padding:0;max-height:512px;display:inline-block;overflow:hidden">
                        <img style="width:100%" alt="No image provided" data-bind="attr:{src:mainImageUrl}">
                    </div>
                </div>
                <span class="span3">
                    <span class="btn fileinput-button pull-right"
                          data-url="${createLink(controller: 'image', action: 'upload')}"
                          data-role="mainImage"
                          data-owner-type="organisationId"
                          data-owner-id="${organisation?.organisationId}"
                          data-bind="stagedImageUpload:documents, visible:!mainImageUrl()"><i class="icon-plus"></i> <input
                            id="mainImage" type="file" name="files"><span>Attach</span></span>

                    <button class="btn main-image-button" data-bind="click:removeMainImage,  visible:mainImageUrl()"><i class="icon-minus"></i> Remove</button>
                </span>
            </div>
        </div>
    </div>

</form>
<g:render template="/shared/attachDocument"/>
<g:render template="/shared/markdownEditorModal"/>