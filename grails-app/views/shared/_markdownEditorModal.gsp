<!-- ko stopBinding: true -->
<div id="markdownEditor" class="modal fade">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title" id="title" data-bind="text:title"></h4>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">
          
        </button>
      </div>

      <div class="modal-body">
        <div class="w-100 bg-white mb-2" id="editor-button-bar"></div>
        <div class="pe-2">
          <g:textArea name="editorInput" id="editorInput" data-bind="value:initialValue" rows="16"
                      cols="120" style="width:100%;margin:0;"></g:textArea>
        </div>
        <div class="d-none"><input type="text" name="editorOutput" id="editorOutput" class="hide"></div>

      </div>
      <div class="modal-footer ">
        <button class="btn btn-primary-dark" type="button" data-bind="click:save"><i class="fas fa-hdd"></i> Done</button>
        <button class="btn btn-dark" data-bind="click:cancel"><i class="far fa-times-circle"></i> Cancel</button>
      </div>

    </div>
  </div>
</div>
<!-- /ko -->

<asset:script type="text/javascript">
  $(function() {
    var EditorViewModel = function() {
        var self = this;
      var $modal = $('#markdownEditor');
      Biocollect.Bootstrap5.getModal($modal, {show:false});
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
          Biocollect.Bootstrap5.showModal($modal);
        };

        self.save = function() {
            self.callback($('#editorInput').val());
          Biocollect.Bootstrap5.hideModal($modal);
        };

        self.cancel = function() {
          Biocollect.Bootstrap5.hideModal($modal);
        };

    };
    var editor = new EditorViewModel();
    ko.applyBindings(editor, document.getElementById('markdownEditor'));

    window.editWithMarkdown = function(title, koProperty) {
            editor.show(title, koProperty);
        }
    });


</asset:script>