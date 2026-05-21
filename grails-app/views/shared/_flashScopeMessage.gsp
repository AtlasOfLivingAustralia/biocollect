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
            <div class="col-md-6 mb-0 alert alert-dismissible alert-info">
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close">
                    
                </button>
                ${flash.message}
            </div>
        </div>
    </g:if>
</div>