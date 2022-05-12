<div class="row">
    <g:if test="${flash.errorMessage}">
        <div class="container-fluid">
            <div class="alert alert-danger">
                ${flash.errorMessage}
            </div>
        </div>
    </g:if>

    <g:if test="${flash.message}">
        <div class="row">
            <div class="col-md-6 mb-0 alert alert-info alert-dismissible">
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
                ${flash.message}
            </div>
        </div>
    </g:if>
</div>