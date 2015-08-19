/**
 *
 * @param target the knockoutjs object being extended.
 * @param options {currencySymbol, decimalSeparator, thousandsSeparator}
 */
ko.extenders.currency = function(target, options) {

    var symbol, d,t;
    if (options !== undefined) {
        symbol = options.currencySymbol;
        d = options.decimalSeparator;
        t = options.thousandsSeparator;
    }
    target.formattedCurrency = ko.computed(function() {
        var n = target(),
            c = isNaN(c = Math.abs(c)) ? 2 : c,
            d = d == undefined ? "." : d,
            t = t == undefined ? "," : t,
            s = n < 0 ? "-" : "",
            sym = symbol == undefined ? "$" : symbol,
            i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "",
            j = (j = i.length) > 3 ? j % 3 : 0;
        return sym + s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
    });
    return target;
};

ko.extenders.numericString = function(target, precision) {
    //create a writable computed observable to intercept writes to our observable
    var result = ko.computed({
        read: target,  //always return the original observables value
        write: function(newValue) {
            var val = newValue;
            if (typeof val === 'string') {
                val = newValue.replace(/,|\$/g, '');
            }
            var current = target(),
                roundingMultiplier = Math.pow(10, precision),
                newValueAsNum = isNaN(val) ? 0 : parseFloat(+val),
                valueToWrite = Math.round(newValueAsNum * roundingMultiplier) / roundingMultiplier;

            //only write if it changed
            if (valueToWrite.toString() !== current || isNaN(val)) {
                target(isNaN(val) ? newValue : valueToWrite.toString());
            }
            else {
                if (newValue !== current) {
                    target.notifySubscribers(valueToWrite.toString());
                }
            }
        }
    }).extend({ notify: 'always' });

    //initialize with current value to make sure it is rounded appropriately
    result(target());

    //return the new computed observable
    return result;
};

ko.extenders.url = function(target) {
    var result = ko.pureComputed({
        read:target,
        write: function(url) {
            var value = typeof url == 'string' && url.indexOf("://") < 0? ("http://" + url): url;
            target(value);
        }
    });
    result(target());
    return result;
};

/**
 * Converts markdown formatted text into html, filters an allowed list of tags.  (To prevent script injection).
 * @param target the knockout observable holding the text.
 * @param options unused.
 * @returns {*}
 */
ko.extenders.markdown = function(target, options) {
    var converter = new window.Showdown.converter();
    var filterOptions = window.WMDEditor.defaults.tagFilter;

    target.markdownToHtml = ko.computed(function() {
        var text = target();
        if (text) {
            text = text.replace(/<[^<>]*>?/gi, function (tag) {
                return (tag.match(filterOptions.allowedTags) || tag.match(filterOptions.patternLink) || tag.match(filterOptions.patternImage) || tag.match(filterOptions.patternAudio)) ? tag : "";
            });
        }
        else {
            text = '';
        }
        return converter.makeHtml(text);
    });
    return target;
};


// handles simple or deferred computed objects
// see activity/edit.gsp for an example of use
ko.extenders.async = function(computedDeferred, initialValue) {

    var plainObservable = ko.observable(initialValue), currentDeferred;
    plainObservable.inProgress = ko.observable(false);

    ko.computed(function() {
        if (currentDeferred) {
            currentDeferred.reject();
            currentDeferred = null;
        }

        var newDeferred = computedDeferred();
        if (newDeferred &&
            (typeof newDeferred.done == "function")) {

            // It's a deferred
            plainObservable.inProgress(true);

            // Create our own wrapper so we can reject
            currentDeferred = $.Deferred().done(function(data) {
                plainObservable.inProgress(false);
                plainObservable(data);
            });
            newDeferred.done(currentDeferred.resolve);
        } else {
            // A real value, so just publish it immediately
            plainObservable(newDeferred);
        }
    });

    return plainObservable;
};