/**
 * Created by sat01a on 28/09/15.
 */
var RestoreTab = function(tabId, defaultHrefTab, forceDefault){
    if (forceDefault === undefined) {
        forceDefault = false;
    }

    //Restore
    var storedTab = amplify.store(tabId+'-state');
    if(forceDefault){
        $('#'+defaultHrefTab).tab('show');
    }
    else if(storedTab){
        $(storedTab + "-tab").tab('show');
    } else{
        $('#'+defaultHrefTab).tab('show');
    }

    //Store
    $('#'+tabId+' a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
        var tab = e.currentTarget.hash;
        amplify.store(tabId +'-state', tab);
    });

};
