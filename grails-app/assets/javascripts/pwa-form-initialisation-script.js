var initialisedSuccessfully = false,
    delay = 2000;
document.addEventListener("credential-saved", renderPage);
document.addEventListener("credential-failed", function (e) {
    alert("Error occurred while saving credentials");
});

window.addEventListener("load", function (e) {
    setTimeout(renderPage, delay);
});

function renderPage() {
    if (initialisedSuccessfully) {
        return;
    }

    entities.getCredentials().then(function (result) {
        var credentials = result.data;
        if (credentials && credentials.length > 0) {
            var credential = credentials[0];
            var authorization = "Bearer " + credential.token;
            $.ajax({
                url: fcConfig.htmlFragmentURL,
                dataType: 'html',
                headers: {
                    'Authorization': authorization
                },
                success: function (html) {
                    // makes sure comments are not removed. Important from KnockoutJS perspective.
                    const constHtml = html;
                    initialisedSuccessfully = true;
                    var element = document.querySelector("#form-placeholder");
                    element.innerHTML = constHtml;
                    biocollect.utils.nodeScriptReplace(element);
                    getMetadataAndInitialise();
                },
                error: function (){
                    alert("Error occurred while getting content. Close the modal and try again. If the problem persists, contact the administrator.");
                }
            });
        }
    }, function () {
        alert("Error occurred while getting credentials");
    });
}