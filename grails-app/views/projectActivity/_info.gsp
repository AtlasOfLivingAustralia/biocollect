<div id="pActivityInfo" class="well">

        <!-- ko foreach: projectActivities -->
            <!-- ko if: current -->
            <g:render template="/projectActivity/publish"/>

            <div class="row-fluid">
                <h5>General information about the survey</h5>
            </div>

            <div class="row-fluid">
                <div class="span3 text-right">
                    <label class="control-label" for="name"> Name: <span class="req-field"></span></label>
                </div>

                <div class="span7">
                    <div class="controls">
                        <input id="name" type="text" data-bind="value: name" data-validation-engine="validate[required]">
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span3 text-right">
                    <label class="control-label" for="description">Description: <span class="req-field"></span></label>
                </div>

                <div class="span7">
                    <div class="controls">
                        <textarea id="description" style="width: 97%;" rows="4" class="input-xlarge" data-bind="value: description"
                                  data-validation-engine="validate[required]"></textarea>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span3 text-right">
                    <label class="control-label" for="startDate"> Start date: <span class="req-field"></span></label>
                </div>

                <div class="span7">
                    <div class="controls input-append">
                        <input id="startDate" data-bind="datepicker:startDate.date" type="text"  data-validation-engine="validate[required]" />
                        <span class="add-on  open-datepicker"><i class="icon-calendar"></i> </span>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span3 text-right">
                    <label class="control-label" for="endDate">End date:</label>
                </div>

                <div class="span7">
                    <div class="controls input-append">
                        <input id="endDate" data-bind="datepicker:endDate.date" type="text" />
                        <span class="add-on open-datepicker"><i class="icon-calendar"></i> </span>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span3 text-right">
                    <label class="control-label" for="publicAccess">Allow public users to enter data:</label>
                </div>

                <div class="span7">
                    <div class="controls">
                        <input id="publicAccess" type="checkbox" data-bind="checked: publicAccess"/>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span3 text-right">
                    <label class="control-label" for="allowComments">Comments on records allowed:</label>
                </div>

                <div class="span7">
                    <div class="controls">
                        <input id="allowComments" type="checkbox" data-bind="checked: commentsAllowed"/>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span3 text-right">
                    <label class="control-label">Attach logo</label>
                </div>

                <div class="span2 text-left">
                    <img  alt="No image" data-bind="attr:{src: transients.logoUrl()}">
                    </br>
                    <span class="btn fileinput-button pull-left"
                          data-bind="
                            attr:{'data-role':'logo',
                                'data-url': transients.imageUploadUrl(),
                                'data-owner-type': 'projectActivityId',
                                'data-owner-id': projectActivityId()},
                                 stagedImageUpload: documents,
                                     visible:!logoUrl()">
                            <i class="icon-plus"></i>
                            <input id="logo" type="file" name="files">
                            <span>Attach</span></span>
                    <button class="btn btn-small" data-bind="click:removeLogoImage, visible:logoUrl()"><i class="icon-minus"></i> Remove</button>
                </div>
            </div>
    <!-- /ko -->
<!-- /ko -->

    <br/> <br/>
    <div class="row-fluid">
        <div class="span12">
            <button class="btn-primary btn btn-small block" data-bind="click: saveInfo"><i class="icon-white  icon-hdd" ></i>  Save </button>
        </div>
    </div>
</div>