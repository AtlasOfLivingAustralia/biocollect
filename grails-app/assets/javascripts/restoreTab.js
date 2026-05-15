/**
 * Created by sat01a on 28/09/15.
 */
var RestoreTab = function (tabId, defaultHrefTab) {

    var tabToggleSelector = '[data-bs-toggle="tab"], [data-bs-toggle="pill"], [data-bs-toggle="list"]';

    function idSelector(id) {
        if (!id) {
            return null;
        }
        id = id.indexOf('#') === 0 ? id.substring(1) : id;
        return '#' + ($.escapeSelector ? $.escapeSelector(id) : id);
    }

    function findTabToggle(tabReference) {
        var tabContainer = $('#' + tabId);
        var selector = idSelector(tabReference);
        var element = selector ? $(selector) : $();

        if (element.is(tabToggleSelector)) {
            return element.first();
        }

        return tabContainer.find(tabToggleSelector).filter(function () {
            var target = tabReference && tabReference.indexOf('#') === 0 ? tabReference : selector;
            return this.id === tabReference ||
                '#' + this.id === tabReference ||
                $(this).attr('href') === target ||
                $(this).attr('data-bs-target') === target;
        }).first();
    }

    function storeTabSelection(e) {
        var tab = e.currentTarget.id || $(e.currentTarget).attr('data-bs-target') || $(e.currentTarget).attr('href');
        saveTabSelection(tabId, tab);
    }

    //Restore tab reference if available else show default tab.
    var storedTab = amplify.store(tabId + '-state');

    var tabToggle = storedTab ? findTabToggle(storedTab) : $();
    if (tabToggle.length) {
        Biocollect.Bootstrap5.showTab(tabToggle);
    }
    else if (defaultHrefTab) {
        tabToggle = findTabToggle(defaultHrefTab);
        if (tabToggle.length) {
            Biocollect.Bootstrap5.showTab(tabToggle);
        }
    }

    //Store tab reference
    $('#' + tabId + ' ' + tabToggleSelector).on('shown.bs.tab', storeTabSelection);

};

function saveTabSelection(uniqueTabId, tabHeadingId) {
    amplify.store(uniqueTabId + '-state', tabHeadingId);
};