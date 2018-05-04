/**
 * Created by sat01a on 28/09/15.
 */
var RestoreTab = function (tabId, defaultHrefTab) {

    //Restore tab reference if available else show default tab.
    var storedTab = amplify.store(tabId + '-state');
    if (storedTab && $(storedTab).length > 0) {
        $(storedTab + "-tab").tab('show');
    } else {
        $('#' + defaultHrefTab).tab('show');
    }

    //Store tab reference
    $('#' + tabId + ' a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
        var tab = e.currentTarget.hash;
        amplify.store(tabId + '-state', tab);
    });

};
