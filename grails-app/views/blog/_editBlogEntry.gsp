<form id="blogEntry" class="form-horizontal validationEngineContainer">

    <div class="row form-group required">
        <label class="col-form-label col-md-3"
               for="type">Type: <fc:iconHelp>What type of entry is this?</fc:iconHelp></label>
        <div class="col-md-9">
            <select class="form-control" id="type" data-bind="options:transients.blogEntryTypes, value:type"></select>
        </div>
    </div>

    <div class="row form-group required">
        <label class="col-form-label col-md-3"
               for="date">Date: <fc:iconHelp>The date for this blog entry</fc:iconHelp></label>
        <div class="col-md-9">
            <div class="input-group">
                <fc:datePicker targetField="date.date" name="date" data-validation-engine="validate[required]" bs4="true" theme="btn-dark"/>
            </div>
        </div>
    </div>

    <div class="row form-group required">
        <label class="col-form-label col-md-3"
               for="title">Title: <fc:iconHelp>The title of this blog entry</fc:iconHelp></label>
        <div class="col-md-9">
            <input type="text" id="title" class="form-control" data-bind="value:title" data-validation-engine="validate[required]">
        </div>
    </div>


    <div class="row form-group">
        <!-- ko if:type() !== 'Photo' -->
        <label class="col-form-label col-md-3"
               for="image">Feature image: <fc:iconHelp>An image that will be displayed alongside this blog entry</fc:iconHelp>
        </label>
        <!-- /ko -->
        <!-- ko if:type() == 'Photo' -->
        <label class="col-form-label col-md-3"
               for="image">Project photo: <fc:iconHelp>The photo that will be attached to the project images section of the blog</fc:iconHelp>
        </label>
        <!-- /ko -->

        <div class="col-md-3" style="text-align:center;background:white" data-bind="visible:!stockIcon()">
            <div style="margin:0;padding:0;width:200px;height:150px;line-height:146px;text-align:left;">
                <img class="img-thumbnail" alt="No image provided" data-bind="attr:{src:imageUrl}">
            </div>
        </div>
        <div class="col-md-3" data-bind="visible:stockIcon()">
            <i class="fa fa-4x" data-bind="css:stockIcon"></i>
        </div>
        <div class="col-md-3 mt-2 mt-md-0">
            <!-- ko if:type() !== 'Photo' -->
            <p data-bind="visible:!image() && !stockIcon()">Select or attach an image</p>

            <select class="form-control" data-bind="visible:!image(), value:stockIcon">
                <option/>
                <option value="fa-warning">Important<i class="fa fa-warning fa-3x"></i></option>
                <option value="fa-newspaper-o">News<i class="fa fa-newspaper-o fa-3x"></i></option>
                <option value="fa-star">Star<i class="fa fa-star-o fa-3x"></i></option>
                <option value="fa-info-circle">Information<i class="fa fa-info-circle fa-3x"></i></option>
            </select>
            <p></p>
            <!-- /ko -->

            <button class="btn btn-dark fileinput-button"
                  data-url="${grailsApplication.config.grails.serverURL}/image/upload"
                  data-role="blogImage"
                  data-owner-type="blogEntryId"
                  data-owner-id="${blogEntry?.blogEntryId}"
                  data-bind="stagedImageUpload:documents, visible:!image() && !stockIcon()"><i class="fas fa-file-upload"></i> <input
                    id="image" type="file" name="files">Attach</button>

            <button class="btn btn-danger main-image-button" data-bind="click:removeBlogImage, visible:image()">
                <i class="far fa-trash-alt"></i> Remove
            </button>


        </div>
    </div>

    <div class="row form-group" data-bind="with:image">
        <label class="col-form-label col-md-3"
               for="attribution">Image attribution: <fc:iconHelp>Will be displayed alongside the image</fc:iconHelp></label>
        <div class="col-md-9">
            <input type="text" id="attribution" class="form-control" data-bind="value:attribution">
        </div>
    </div>
    <div class="row form-group" data-bind="with:image">
        <label class="col-form-label required col-md-3"
               for="declaration">Privacy declaration: <fc:iconHelp>You must accept the declaration before the image can be saved.</fc:iconHelp></label>
        <div class="col-md-9">
            <div id="thirdPartyDeclarationText" class="checkbox custom-checkbox" for="declaration">
                <input id="declaration" type="checkbox" name="thirdPartyConsentDeclarationMade" data-validation-engine="validate[required]" data-bind="checked:thirdPartyConsentDeclarationMade">
                <fc:getSettingContent settingType="${au.org.ala.biocollect.merit.SettingPageType.THIRD_PARTY_PHOTO_CONSENT_DECLARATION}"/>
            </div>
        </div>
    </div>

    <!-- ko if:type() !== 'Photo' -->
    <div class="row form-group required">
        <label class="col-form-label col-md-3" for="blog-content">Content: <fc:iconHelp>The content of this blog entry</fc:iconHelp></label>
        <div class="col-md-9 btn-space">
            <textarea rows="10" id="blog-content" class="form-control" data-bind="value:content" data-validation-engine="validate[required]" placeholder="Content goes here..."></textarea>
            <button class="btn btn-dark popup-edit" data-bind="click:editContent"><i class="fas fa-pencil-alt"></i> Edit with Markdown Editor</button>
        </div>
    </div>

    <div class="row form-group">
        <label class="col-form-label col-md-3"
               for="title">See More URL: <fc:iconHelp>If supplied, the blog entry will show a "see more" link at the end which will take the user to this URL</fc:iconHelp></label>
        <div class="col-md-9">
            <input type="text" id="viewMoreUrl" class="form-control" data-bind="value:viewMoreUrl" data-validation-engine="validate[custom[url]]">
        </div>
    </div>
    <!-- /ko -->
</form>
<g:render template="/shared/attachDocument"/>
<g:render template="/shared/markdownEditorModal"/>