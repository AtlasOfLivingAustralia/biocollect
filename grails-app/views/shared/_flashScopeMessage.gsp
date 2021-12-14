<div class="container-fluid">
    <g:if test="${flash.errorMessage}">
        <div class="row">
            <div class="col-sm-12">
                <div class="alert alert-danger" role="alert">
                    ${flash.errorMessage}
                </div>
            </div>
        </div>
    </g:if>

    <g:if test="${flash.message}">
        <div class="row">
            <div class="col-sm-6">
                <div class="alert alert-info" role="alert">
                    ${flash.errorMessage} <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
                </div>
            </div>
        </div>
    </g:if>
</div>