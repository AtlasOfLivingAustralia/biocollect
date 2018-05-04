<!-- ko stopBinding: true -->
<div id="edit${attributeName}Content">
<h3>${header}</h3>
<div class="row-fluid">
    <div class="span5 alert">This functionality is now deprecated, please create any new ${header} using
        <a href="#" onclick="$('#editProjectBlog-tab').click()" >Edit Blog</a></li>
    </div>
</div>
<div class="row-fluid">
    <div class="span5 alert" data-bind="visible:message(), css:{'alert-error':error(), 'alert-success':success()}">
        <button class="close" data-bind="click:clearMessage" href="#">×</button>
        <span data-bind="text:message"></span>
    </div>
</div>
<div class="row-fluid space-after well well-small">

        <h4>Update project "${header}"</h4>
        <div id="${attributeName}-button-bar" style="width:100%;background-color: white;"></div>
        <div style="padding-right:12px;">
            <g:textArea name="${attributeName}Input" id="${attributeName}Input" value="${project[attributeName]}" rows="16"
                        cols="120" style="width:100%;margin:0;"></g:textArea>
        </div>
        <div class="hide"><input type="text" name="${attributeName}Output" id="${attributeName}Output" class="hide"></div>
</div>
<div class="row-fluid">
        <h4>Preview</h4>
        <div id="${attributeName}-preview" class="well well-small"></div>
</div>
<div class="row-fluid">
    <span class="span3">
        <button class="btn btn-primary btn-small" data-bind="click:save${attributeName}"><i class="icon-white icon-hdd"></i> Save changes</button>
        <button class="btn  btn-small" data-bind="click:cancelEdit${attributeName}">Cancel</button>

    </span>
</div>
</div>
<!-- /ko -->

<asset:script type="text/javascript">
     window.${attributeName}ViewModel = function(project, initialValue) {
        var self = this;
        setup_wmd({
            output_format: "markdown",
            input: "${attributeName}Input",
            output: "${attributeName}Output",
            button_bar: "${attributeName}-button-bar",
            preview: "${attributeName}-preview",
            helpLink: "${asset.assetPath(src:"/wmd/markdownhelp.html")}"
        });

        self.message = ko.observable('');
        self.error = ko.observable(false);
        self.success = ko.observable(false);

        self.save${attributeName} = function() {

            var rawContent = $('#${attributeName}Input').val();
            var formattedContent = $('#${attributeName}Output').val();
            project['${attributeName}'](formattedContent);
            var payload = {};
            payload['${attributeName}'] = rawContent;
            payload.projectId = project.projectId;
            var url = fcConfig.projectUpdateUrl;
            $.ajax({
                url: url,
                type: 'POST',
                data: JSON.stringify(payload),
                contentType: 'application/json',
                success: function (data) {
                    if (data.error) {
                        self.message(data.detail + ' \n' + data.error);
                        self.error(true);
                    }
                    else {
                        self.message('${header} saved');
                        self.success(true);
                    }
                },
                error: function (data) {
                    self.message('An unhandled error occurred: ' + data.status);
                    self.error(true);
                }
            });
        };

        self.cancelEdit${attributeName} = function() {
            $('#${attributeName}Input').val(initialValue);
            $('#${attributeName}Input').focus();
            self.clearMessage();
        };

        self.clearMessage = function() {
            self.message('');
            self.error(false);
            self.success(false);
        };
    }

</asset:script>