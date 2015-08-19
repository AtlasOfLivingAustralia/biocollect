<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<!doctype html>
<html>
    <head>
        <meta name="layout" content="adminLayout"/>
        <title>Output models | Admin | Data capture | Atlas of Living Australia</title>
        <r:require modules="knockout,jquery_ui,knockout_sortable"/>
    </head>

    <body>
        <content tag="pageTitle">Output models</content>
        <content tag="adminButtonBar">
            <button type="button" id="btnSave" %{--data-bind="click:save, disable:modelName() == 'No output selected'"--}% class="btn btn-success">Save</button>
            <button type="button" data-bind="click:revert" class="btn">Cancel</button>
        </content>
        <div class="row-fluid">
            <g:select class="span6" name="outputSelector" from="${activitiesModel.outputs}" optionValue="name"
                      optionKey="template" noSelection="['':'Select an output to edit']"/>
        </div>

        <div class="row-fluid">
            <div class="span12"><h2 data-bind="text:modelName"></h2></div>
        </div>
        <div class="row-fluid">
            <div class="alert" data-bind="visible:transients.hasMessage">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <strong>Warning!</strong> <span data-bind="text:transients.message"></span>
            </div>
        </div>
        <div class="row-fluid">
            <div class="span12">
                %{--<pre id="outputModel" style="margin:0;width:97%;"></pre>--}%
                <textarea id="outputModelEdit" style="width:97%;min-height:600px;"></textarea>
                %{--<label for="dataModel">Data model</label>
                <textarea id="dataModel" style="width:97%;min-height:300px;" class="" data-bind="value:dataModel"></textarea>--}%
                %{--<pre id="dataModel" style="width:97%;min-height:300px;" data-bind="text:ko.toJSON(dataModel,null,2)"></pre>--}%
            </div>
        </div>
        %{--<div class="row-fluid">
            <div class="span12">
                <label for="viewModel">View model</label>
                <textarea id="viewModel" style="width:97%;min-height:300px;" class="" data-bind="value:viewModel"></textarea>
            </div>
        </div>--}%

    <g:if env="development">
        <div class="expandable-debug clearfix">
            <hr />
            <h3>Debug</h3>
            <div>
                <h4>KO model</h4>
                <pre data-bind="text:ko.toJSON($root,null,2)"></pre>
                <h4>Outputs</h4>
                <pre>${activitiesModel.outputs}</pre>
            </div>
        </div>
    </g:if>

<r:script>
    $(function(){

        var ViewModel = function () {
            var self = this;
            this.modelName = ko.observable('No output selected');
            this.templateName = ko.observable('');
            this.dataModel = ko.observable();
            this.viewModel = ko.observable();
            this.transients = {};
            this.transients.message = ko.observable('');
            this.transients.hasMessage = ko.computed(function () {return self.transients.message() !== ''});
            this.revert = function () {
                document.location.reload();
            };
            this.save = function () {
                console.log($('#dataModel').val());
                var model = ko.toJS(self);
                delete model.transients;
                console.log("saving " + model.modelName);
                //delete model.transients;
                $.ajax("${createLink(action: 'updateOutputDataModel')}/" + self.templateName(), {
                    type: 'POST',
                    data: $('#dataModel').val(), //ko.toJSON(model, null, 2),
                    contentType: 'application/json',
                    success: function (data) {
                        if (data !== 'error') {
                            //alert('saved');
                            //document.location.reload();
                        } else {
                            alert(data);
                        }
                    },
                    error: function () {
                        alert('failed');
                    },
                    dataType: 'text'
                });
            };
        },
        // create an empty model so we can bind the message state
        viewModel = new ViewModel();
        ko.applyBindings(viewModel);

        var $pre = $('#outputModel'),
            $textarea = $('#outputModelEdit');

        $('#outputSelector').change(function () {
            var output = $(this).val();
            $.getJSON("${createLink(action: 'getOutputDataModel')}/" + output, function (data) {
                if (data.error) {
                    viewModel.modelName(output);
                    viewModel.dataModel("");
                    viewModel.viewModel("");
                    viewModel.transients.message('No existing model was found. You are creating a new model.');
                } else {
                    viewModel.modelName(data.modelName);
                    viewModel.templateName(output);
                    viewModel.dataModel(ko.toJSON(data.dataModel, null, 2));
                    viewModel.viewModel(ko.toJSON(data.viewModel, null, 2));
                    viewModel.transients.message('');

                    $textarea.html(vkbeautify.json(data,2));
                    //$textarea.css('height',$pre.css('height'));
                    //$textarea.slideDown();
                }
            });
        });

        $('#btnSave').click(function () {
            var output = $('#outputSelector').val();
            $.ajax("${createLink(action: 'updateOutputDataModel')}/" + output, {
                type: 'POST',
                data: $textarea.val(),
                contentType: 'application/json',
                success: function (data) {
                    if (data !== 'error') {
                        $textarea.html(vkbeautify.json(data,2));
                    } else {
                        alert(data);
                    }
                },
                dataType: 'text'
            });
        });

        // open specified output (?open=<templateName> in url)
        var startWith = "${open}";
        if (startWith) {
            $('#outputSelector').val(startWith).change();
        }
    });
</r:script>
        </body>
</html>