<!-- ko stopBinding: true -->
<div id="markdownEditor" class="modal fade">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title" id="title" data-bind="text:title"></h4>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>

      <div class="modal-body">
        <div class="w-100 bg-white mb-2" id="editor-button-bar"></div>
        <div class="pr-2">
          <g:textArea name="editorInput" id="editorInput" data-bind="value:initialValue" rows="16"
                      cols="120" style="width:100%;margin:0;"></g:textArea>
        </div>
        <div class="d-none"><input type="text" name="editorOutput" id="editorOutput" class="hide"></div>

      </div>
      <div class="modal-footer ">
        <button class="btn btn-primary-dark" type="button" data-bind="click:save">Done</button>
        <button class="btn btn-dark" data-bind="click:cancel">Cancel</button>
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