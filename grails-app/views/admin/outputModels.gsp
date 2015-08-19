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
            <button type="button" data-bind="click:save, disable:modelName() == 'No output selected'" class="btn btn-success">Save</button>
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
            <h3>Data model</h3>
            <ul data-bind="sortable:{data:dataModel}" class="sortableList">
                <li class="test">
                    <div class="">
                        <span class="" data-bind="text:name"></span><br>
                        <span>type: </span><span data-bind="text:dataType"></span>
                    </div>
                </li>
            </ul>
            <span data-bind="click:addDataItem" class="clickable"><i class="icon-plus"></i> Add another</span>
        </div>
        %{--<div class="row-fluid">
            <div class="span12">
                <label for="dataModel">Data model</label>
                <pre id="dataModel" style="width:97%;min-height:300px;" data-bind="text:ko.toJSON(dataModel,null,2)"></pre>
            </div>
        </div>
        <div class="row-fluid">
            <div class="span12">
                <label>View model</label>
                <pre data-bind="text:viewModel"></pre>
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

        var DataItem = function (item) {
            var self = this;
            this.name = ko.observable(item.name);
            this.dataType = ko.observable(item.dataType);
            this.constraints = ko.observableArray(item.constraints);
        };

        var ViewModel = function () {
            var self = this;
            this.modelName = ko.observable('No output selected');
            this.dataModel = ko.observableArray([]);
            this.viewModel = ko.observableArray([]);
            this.transients = {};
            this.transients.message = ko.observable('');
            this.transients.hasMessage = ko.computed(function () {return self.transients.message() !== ''});
            this.loadDataModel = function (model) {
                self.dataModel($.map(model, function (obj) {
                    return new DataItem(obj);
                }));
            };
            this.addDataItem = function () {};
            this.revert = function () {
                document.location.reload();
            };
            this.save = function () {
                var model = ko.toJS(self);
                delete model.transients;
                console.log("saving " + model.modelName);
                //delete model.transients;
                $.ajax("${createLink(action: 'updateOutputDataModel')}/" + self.modelName(), {
                    type: 'POST',
                    data: ko.toJSON(model, null, 2),
                    contentType: 'application/json',
                    success: function (data) {
                        if (data !== 'error') {
                            alert('saved');
                            //document.location.reload();
                        } else {
                            alert(data);
                        }
                    },
                    error: function () {
                        alert('failed');
                    }/*,
                    dataType: 'text'*/
                });
            };
        },
        // create an empty model so we can bind the message state
        viewModel = new ViewModel();
        ko.applyBindings(viewModel);

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
                    viewModel.loadDataModel(data.dataModel);
                    viewModel.viewModel(data.viewModel);
                    viewModel.transients.message('');
                }
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