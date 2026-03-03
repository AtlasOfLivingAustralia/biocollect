<div id="${id}" class="alert alert-dismissible alert-warning hide">
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    <strong>Unsaved data has been been found and restored from a previous editing session.</strong>
    <p>Press ${saveButton?:'Save'} to apply the changes to your project<g:if test="${cancelButton}"> or ${cancelButton} to discard these edits</g:if></p>
</div>