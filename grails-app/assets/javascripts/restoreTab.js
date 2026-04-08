/**
 * Created by sat01a on 28/09/15.
 */
var RestoreTab = function (tabId, defaultHrefTab) {

    //Restore tab reference if available else show default tab.
    var storedTab = amplify.store(tabId + '-state');
    if (storedTab && (storedTab.indexOf('#') != 0)) {
        storedTab = '#' + storedTab;
    }

    if (storedTab && ($(storedTab).length > 0)) {
        Biocollect.Bootstrap5.showTab(storedTab);
    }
    else if (defaultHrefTab) {
        Biocollect.Bootstrap5.showTab('#' + defaultHrefTab);
    }

    //Store tab reference
    $('#' + tabId + ' a[data-bs-toggle="tab"]').on('shown.bs.tab', function (e) {
        var tab = e.currentTarget.id;
        saveTabSelection(tabId, tab);
    });

};

function saveTabSelection(uniqueTabId, tabHeadingId) {
    amplify.store(uniqueTabId + '-state', tabHeadingId);
};