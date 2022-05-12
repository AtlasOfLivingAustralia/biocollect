<!-- ko stopBinding: true -->
<div id="jsonEditor" class="modal fade" style="display:none;">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="title" data-bind="text:title">Edit</h4>
            </div>

            <div class="modal-body">
                <div style="padding-right:12px;">
                    <g:textArea name="jsonEditorInput" id="jsonEditorInput" class="form-control" data-bind="value:initialValue" rows="16"
                                cols="120" />
                </div>
            </div>

            <div class="modal-footer control-group">
                <div class="controls">
                    <button type="button" class="btn btn-primary-dark" data-bind="click:save"><i class="fas fa-hdd"></i> Done</button>
                    <button class="btn btn-dark" data-bind="click:cancel"><i class="far fa-times-circle"></i> Cancel</button>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- /ko -->

<asset:script type="text/javascript">
    $(function() {
      var JsonEditorViewModel = function() {
          var self = this;
          var $modal = $('#jsonEditor').modal({show:false});

        self.title = ko.observable();
        self.initialValue = ko.observable();
        self.callback = null;

        self.show = function(title, koProperty) {
            self.title(title);
            self.initialValue(JSON.stringify(koProperty(), null, 2));
            self.callback = koProperty;
            $modal.modal('show');
        };

        self.save = function() {
            var rawValue = $('#jsonEditorInput').val() || '""';
            var newValue = JSON.parse(rawValue);
            self.callback(newValue);
            $modal.modal('hide');
        };

        self.cancel = function() {
            $modal.modal('hide');
        };
    };
    var jsonEditor = new JsonEditorViewModel();
    ko.applyBindings(jsonEditor, document.getElementById('jsonEditor'));

    window.editWithJson = function(title, koProperty) {
            jsonEditor.show(title, koProperty);
        }
    });

</asset:script>