<form id="blogEntry" class="form-horizontal validationEngineContainer col-sm-6">

    <div class="form-group row required">
        <label class="col-form-label col-sm-3"
               for="type">Type: <fc:iconHelp>What type of entry is this?</fc:iconHelp></label>
        <div class="col-sm-9">
            <select id="type" data-bind="options:transients.blogEntryTypes, value:type" class="form-control"></select>
        </div>
    </div>

    <div class="form-group row required">
        <label class="col-form-label col-sm-3"
               for="date">Date: <fc:iconHelp>The date for this blog entry</fc:iconHelp></label>
        <div class="col-sm-9">
            <div class="input-group-append">
                <fc:datePicker targetField="date.date" name="date" data-validation-engine="validate[required]"/>
            </div>
        </div>
    </div>

    <div class="form-group row required">
        <label class="col-form-label col-sm-3"
               for="title">Title: <fc:iconHelp>The title of this blog entry</fc:iconHelp></label>
        <div class="col-sm-9">
            <input type="text" id="title" class="form-control" data-bind="value:title" data-validation-engine="validate[required]">
        </div>
    </div>


    <div class="form-group row">
        <!-- ko if:type() !== 'Photo' -->
        <label class="col-form-label col-sm-3"
               for="image">Feature image: <fc:iconHelp>An image that will be displayed alongside this blog entry</fc:iconHelp>
        </label>
        <!-- /ko -->
        <!-- ko if:type() == 'Photo' -->
        <label class="col-form-label col-sm-3"
               for="image">Project photo: <fc:iconHelp>The photo that will be attached to the project images section of the blog</fc:iconHelp>
        </label>
        <!-- /ko -->

        <div class="col-sm-3" style="text-align:center;background:white" data-bind="visible:!stockIcon()">
            <div style="margin:0;padding:0;width:200px;height:150px;line-height:146px;text-align:left;">
                <img alt="No image provided" data-bind="attr:{src:imageUrl}">
            </div>
        </div>
        <div class="col-sm-3" data-bind="visible:stockIcon()">
            <i class="fa fa-4x" data-bind="css:stockIcon"></i>
        </div>
        <div class="col-sm-3">
            <!-- ko if:type() !== 'Photo' -->
            <p data-bind="visible:!image() && !stockIcon()">Select or attach an image</p>

            <select data-bind="visible:!image(), value:stockIcon">
                <option/>
                <option value="fa-warning">Important<i class="fa fa-warning fa-3x"></i></option>
                <option value="fa-newspaper-o">News<i class="fa fa-newspaper-o fa-3x"></i></option>
                <option value="fa-star">Star<i class="fa fa-star-o fa-3x"></i></option>
                <option value="fa-info-circle">Information<i class="fa fa-info-circle fa-3x"></i></option>
            </select>
            <p></p>
            <!-- /ko -->

            <div class="btn btn-dark fileinput-button"
                  data-url="${grailsApplication.config.grails.serverURL}/image/upload"
                  data-role="blogImage"
                  data-owner-type="blogEntryId"
                  data-owner-id="${blogEntry?.blogEntryId}"
                  data-bind="stagedImageUpload:documents, visible:!image() && !stockIcon()"><i class="fas fa-plus"></i> <input
                    id="image" type="file" name="files"><span>Attach</span></div>

            <button class="btn btn-dark main-image-button" data-bind="click:removeBlogImage, visible:image()"><i
                    class="fas fa-minus"></i> Remove</button>


        </div>
    </div>

    <div class="form-group row" data-bind="with:image">
        <label class="col-form-label col-sm-3"
               for="attribution">Image attribution: <fc:iconHelp>Will be displayed alongside the image</fc:iconHelp></label>
        <div class="col-sm-9">
            <input type="text" id="attribution" class="form-control" data-bind="value:attribution">
        </div>
    </div>
    <div class="form-group row" data-bind="with:image">
        <label class="col-form-label required col-sm-3"
               for="declaration">Privacy declaration: <fc:iconHelp>You must accept the declaration before the image can be saved.</fc:iconHelp></label>
        <div class="col-sm-9">
            <label id="thirdPartyDeclarationText" class="checkbox" for="declaration">
                <input id="declaration" type="checkbox" name="thirdPartyConsentDeclarationMade" data-validation-engine="validate[required]" data-bind="checked:thirdPartyConsentDeclarationMade">
                <fc:getSettingContent settingType="${au.org.ala.biocollect.merit.SettingPageType.THIRD_PARTY_PHOTO_CONSENT_DECLARATION}"/>
            </label>
        </div>
    </div>

    <!-- ko if:type() !== 'Photo' -->
    <div class="form-group row required">
        <label class="col-form-label col-sm-3" for="blog-content">Content: <fc:iconHelp>The content of this blog entry</fc:iconHelp></label>
        <div class="col-sm-9">
            <textarea rows="10" id="blog-content" class="form-control" data-bind="value:content" data-validation-engine="validate[required]" placeholder="Content goes here..."></textarea>
            <br/><button class="btn btn-dark popup-edit" data-bind="click:editContent"><i class="fas fa-pencil-alt"></i> Edit with Markdown Editor</button>
        </div>
    </div>

    <div class="form-group row">
        <label class="col-form-label col-sm-3"
               for="title">See More URL: <fc:iconHelp>If supplied, the blog entry will show a "see more" link at the end which will take the user to this URL</fc:iconHelp></label>
        <div class="col-sm-9">
            <input type="text" id="viewMoreUrl" class="form-control" data-bind="value:viewMoreUrl" data-validation-engine="validate[custom[url]]">
        </div>
    </div>
    <!-- /ko -->
</form>
<g:render template="/shared/attachDocument" plugin="fieldcapture-plugin"/>
<g:render template="/shared/markdownEditorModal" plugin="fieldcapture-plugin"/>