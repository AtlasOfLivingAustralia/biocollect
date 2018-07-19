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

/**
 * Adds a request parameter named "returnTo" to the value of the target observable.
 * @param target assumed to be an observable containing a URL.
 * @param returnToUrl the value for the "returnTo" parameter in the URL.
 */
ko.extenders.returnTo = function(target, returnToUrl) {

    var encodedReturnToUrl = returnToUrl ? encodeURIComponent(returnToUrl) : undefined;

    var result = ko.pureComputed({
        read: target,
        write: function (url) {
            if (encodedReturnToUrl) {
                var separator = '?';
                if (url.indexOf('?') >= 0) {
                    separator = '&';
                }
                if(url.indexOf('returnTo') == -1) {
                    target(url + separator + 'returnTo=' + encodedReturnToUrl);
                } else {
                    target(url);
                }
            }
            else {
                target(url);
            }
        }
    });
    result(target());
    return result;

};

/**
 * Adds a request parameter named "version" to the value of the target observable.
 * @param target assumed to be an observable containing a URL.
 * @param version the value for the "version" parameter in the URL.
 */
ko.extenders.dataVersion = function(target, version) {

    var result = ko.pureComputed({
        read: target,
        write: function (url) {
            if (version) {
                var separator = '?';
                if (url.indexOf('?') >= 0) {
                    separator = '&';
                }

                target(url + separator + 'version=' + version);
            }
            else {
                target(url);
            }
        }
    });
    result(target());
    return result;

};

ko.extenders.numeric = function(target, precision) {
    //create a writable computed observable to intercept writes to our observable
    var result = ko.pureComputed({
        read: target,  //always return the original observables value
        write: function(newValue) {
            var current = target(),
                roundingMultiplier = Math.pow(10, precision),
                newValueAsNum = isNaN(newValue) ? 0 : parseFloat(+newValue),
                valueToWrite = Math.round(newValueAsNum * roundingMultiplier) / roundingMultiplier;

            //only write if it changed
            if (valueToWrite !== current) {
                target(valueToWrite);
            } else {
                //if the rounded value is the same, but a different value was written, force a notification for the current field
                if (newValue !== current) {
                    target.notifySubscribers(valueToWrite);
                }
            }
        }
    }).extend({ notify: 'always' });

    //initialize with current value to make sure it is rounded appropriately
    result(target());

    //return the new computed observable
    return result;
};

/**
 * Adds two utility functions to handle UI behaviour.
 * addWord - insert the passed value to array only if it does not exist in array
 * removeWord - remove a word from list
 * @param target
 * @returns target
 */
ko.extenders.set = function (target) {
    //create a writable computed observable to intercept writes to our observable
    target.addWord = ko.computed({
        read: function () {
            // it is not possible to delete/remove a value from array when combobox has the value selected in normal cases.
            // returning empty string enables deletion.
            return '';
        },
        write: function(newValue) {
            var values = target() || [];

            if(newValue && !newValue.push){
                newValue = [newValue]
            }

            if(newValue){
                for(var i in newValue){
                    if(values.indexOf(newValue[i]) == -1){
                        values.push(newValue[i]);
                    }
                }

                target(values);
            }
        }
    });

    target.removeWord = ko.computed({
        read: target,
        write: function(toBeDeleted) {
            var values = target() || [];
            ko.utils.arrayRemoveItem(values, toBeDeleted);
            target(values);
        }
    });

    return target
};