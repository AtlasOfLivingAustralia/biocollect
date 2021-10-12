<form class="form-horizontal validationEngineContainer">

    <div class="row">
        <div class="col-12">
            <h4 class="block-header"><g:message code="organisation.details.header"/></h4>

            <div class="form-group row required">
                <label class="col-form-label col-12 col-sm-3" for="name">Name: <fc:iconHelp><g:message
                        code="organisation.name.help"/></fc:iconHelp></label>

                <div class="col-sm-9">
                    <input class="form-control" id="name" type="text" data-bind="value:name" maxlength="256"
                           data-validation-engine="validate[required,maxSize[256]]" placeholder="Organisation name">
                </div>
            </div>
            <div class="form-group row required">
                <label class="col-form-label col-sm-3" for="description">Description: <fc:iconHelp><g:message
                        code="organisation.description.help"/></fc:iconHelp></label>

                <div class="col-sm-9">
                    <textarea class="form-control" id="description" rows="3" data-bind="value:description"
                              data-validation-engine="validate[required]"
                              placeholder="A description of the organisation"></textarea>
                    <button class="btn btn-dark mt-1 popup-edit" data-bind="click:editDescription"><i
                        class="fas fa-pencil-alt"></i> Edit with Markdown Editor</button>
                </div>
            </div>

            <div class="form-group row">
                <label class="col-form-label col-sm-3" for="url">Web Site URL: <fc:iconHelp><g:message
                        code="organisation.webUrl.help"/></fc:iconHelp></label>

                <div class="col-sm-9">
                    <input class="form-control" type="text" id="url" data-bind="value:url"
                           data-validation-engine="validate[custom[url]]"
                           placeholder="link to your organisations website">
                </div>
            </div>
            <g:render template="/shared/editSocialMediaLinks"
                      model="${[entity: 'organisation', imageUrl: asset.assetPath(src: 'filetypes')]}"/>
        </div>
    </div>

    <div class="row mt-5">
        <div class="col-12">
            <h4 class="block-header"><g:message code="organisation.images.header"/></h4>

            <div class="form-group row">
                <label class="col-form-label col-sm-3" for="logo">Organisation Logo: <fc:iconHelp><g:message
                        code="organisation.logo.help"/></fc:iconHelp></label>

                <div class="col-sm-6 text-center">
                    <g:message code="organisation.logo.extra"/><br/>
                    <div class="row justify-content-center">
                        <div class="border border-secondary p-0 col-4" style="width:200px;height:150px;line-height:146px;">
                            <img class="mw-100 mh-100" alt="No image provided"
                                 data-bind="attr:{src:logoUrl}">
                        </div>
                    </div>

                    <div data-bind="visible:logoUrl()"><g:message code="organisation.logo.visible"/></div>
                </div>
                <span class="col-sm-3">
                    <span class="btn btn-dark fileinput-button"
                          data-url="${createLink(controller: 'image', action: 'upload')}"
                          data-role="logo"
                          data-owner-type="organisationId"
                          data-owner-id="${organisation?.organisationId}"
                          data-bind="stagedImageUpload:documents, visible:!logoUrl()"><i class="fas fa-file-upload"></i> <input
                            id="logo" type="file" name="files"><span>Attach</span></span>

                    <button class="btn btn-danger main-image-button" data-bind="click:removeLogoImage, visible:logoUrl()"><i
                            class="fas fa-minus"></i> Remove</button>
                </span>
            </div>

            <div class="form-group row">
                <label class="col-form-label col-sm-3" for="mainImage">Feature Graphic: <fc:iconHelp><g:message
                        code="organisation.mainImage.help"/></fc:iconHelp></label>

                <div class="col-sm-6 text-center bg-white">
                    <g:message code="organisation.mainImage.extra"/>
                    <div class="row justify-content-center">
                        <div class="border border-secondary p-0 overflow-hidden col-4" style="max-height:512px;">
                            <img class="w-100" alt="No image provided" data-bind="attr:{src:mainImageUrl}">
                        </div>
                    </div>
                </div>
                <span class="col-sm-3">
                    <span class="btn btn-dark fileinput-button"
                          data-url="${createLink(controller: 'image', action: 'upload')}"
                          data-role="mainImage"
                          data-owner-type="organisationId"
                          data-owner-id="${organisation?.organisationId}"
                          data-bind="stagedImageUpload:documents, visible:!mainImageUrl()"><i class="fas fa-file-upload"></i> <input
                            id="mainImage" type="file" name="files"><span>Attach</span></span>

                    <button class="btn btn-danger main-image-button" data-bind="click:removeMainImage,  visible:mainImageUrl()"><i
                            class="fas fa-minus"></i> Remove</button>
                </span>
            </div>
        </div>
    </div>

</form>
<g:render template="/shared/attachDocument"/>
<g:render template="/shared/markdownEditorModal"/>