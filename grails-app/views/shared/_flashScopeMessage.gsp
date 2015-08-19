<div class="row-fluid">
    <g:if test="${flash.errorMessage}">
        <div class="container-fluid">
            <div class="alert alert-error">
                ${flash.errorMessage}
            </div>
        </div>
    </g:if>

    <g:if test="${flash.message}">
        <div class="row-fluid">
            <div class="span6 alert alert-info" style="margin-bottom:0;">
                <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
                ${flash.message}
            </div>
        </div>
    </g:if>
</div>