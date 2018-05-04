<!-- ko stopBinding: true -->
<div id="markdownEditor" class="modal fade" style="display:none;">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title" id="title" data-bind="text:title">Attach Document</h4>
      </div>

      <div class="modal-body">
        <div id="editor-button-bar" style="width:100%;background-color: white;"></div>
        <div style="padding-right:12px;">
          <g:textArea name="editorInput" id="editorInput" data-bind="value:initialValue" rows="16"
                      cols="120" style="width:100%;margin:0;"></g:textArea>
        </div>
        <div class="hide"><input type="text" name="editorOutput" id="editorOutput" class="hide"></div>

      </div>
      <div class="modal-footer control-group">
        <div class="controls">
          <button type="button" class="btn btn-success" data-bind="click:save">Done</button>
          <button class="btn" data-bind="click:cancel">Cancel</button>

        </div>
      </div>

    </div>
  </div>
</div>
<!-- /ko -->

<asset:script type="text/javascript">
  $(function() {
    var EditorViewModel = function() {
        var self = this;
        var $modal = $('#markdownEditor').modal({show:false});
        setup_wmd({
            output_format: "markdown",
            input: "editorInput",
            output: "editorOutput",
            button_bar: "editor-button-bar",
            preview: "",
            helpLink: "${asset.assetPath(src:"/wmd/markdownhelp.html")}"
        });

        self.title = ko.observable();
        self.initialValue = ko.observable();
        self.callback = null;

        self.show = function(title, koProperty) {
            self.title(title);
            self.initialValue(koProperty());
            self.callback = koProperty;
            $modal.modal('show');
        };

        self.save = function() {
            self.callback($('#editorInput').val());
            $modal.modal('hide');
        };

        self.cancel = function() {
            $modal.modal('hide');
        };

    };
    var editor = new EditorViewModel();
    ko.applyBindings(editor, document.getElementById('markdownEditor'));

    window.editWithMarkdown = function(title, koProperty) {
            editor.show(title, koProperty);
        }
    });


</asset:script>