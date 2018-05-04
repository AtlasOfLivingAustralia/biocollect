/*
Handles the display and editing of UTC dates.

Declares a Knockout extender that allows UTC ISODates to be displayed and edited as simple dates in the form
 dd-MM-yyyy and with local timezone adjustment. Hours and minutes can optionally be shown and edited.

Declares a custom binding that allows dates to be changed using the Bootstrap datepicker
 (https://github.com/eternicode/bootstrap-datepicker).

The date values in the ViewModel are maintained as UTC dates as strings in ISO format (ISO8601 without milliseconds).

The extender adds a 'formattedDate' property to the observable. It is this property that should be bound
 to an element, eg

    <input data-bind="value: myDate.formattedDate" type=...../> or
    <span data-bind="text: myDate.formattedDate" />

The date is defined in the view model like this:

    self.myDate = ko.observable("${myDate}").extend({simpleDate: false});

The boolean indicates whether to show the time as well.

The extender also adds a 'date' property to the observable that holds the value as a Javascript date object.
This is used by the datepicker custom binding.

The custom binding listens for changes via the datepicker as well as direct edits to the input field and
 updates the model. It also updates the datepicker on change to the model.

*/

(function(){

    // creates an ISO8601 date string but without millis - to match the format used by the java thingy for BSON dates
    Date.prototype.toISOStringNoMillis = function() {
        function pad(n) { return n < 10 ? '0' + n : n }
        return this.getUTCFullYear() + '-'
            + pad(this.getUTCMonth() + 1) + '-'
            + pad(this.getUTCDate()) + 'T'
            + pad(this.getUTCHours()) + ':'
            + pad(this.getUTCMinutes()) + ':'
            + pad(this.getUTCSeconds()) + 'Z';
    };

    // Use native ISO date parsing or shim for old browsers (IE8)
    var D= new Date('2011-06-02T09:34:29+02:00');
    if(!D || +D!== 1307000069000){
        Date.fromISO= function(s){
            var day, tz,
                rx=/^(\d{4}\-\d\d\-\d\d([tT ][\d:\.]*)?)([zZ]|([+\-])(\d\d):(\d\d))?$/,
                p= rx.exec(s) || [];
            if(p[1]){
                day= p[1].split(/\D/);
                for(var i= 0, L= day.length; i<L; i++){
                    day[i]= parseInt(day[i], 10) || 0;
                }
                day[1]-= 1;
                day= new Date(Date.UTC.apply(Date, day));
                if(!day.getDate()) return NaN;
                if(p[5]){
                    tz= (parseInt(p[5], 10)*60);
                    if(p[6]) tz+= parseInt(p[6], 10);
                    if(p[4]== '+') tz*= -1;
                    if(tz) day.setUTCMinutes(day.getUTCMinutes()+ tz);
                }
                return day;
            }
            return NaN;
        }
    }
    else{
        Date.fromISO= function(s){
            return new Date(s);
        }
    }
})();

function isValidDate(d) {
    if ( Object.prototype.toString.call(d) !== "[object Date]" )
        return false;
    return !isNaN(d.getTime());
}

function convertToSimpleDate(isoDate, includeTime) {
    if (!isoDate) { return ''}
    var date = isoDate, strDate;
    if (typeof isoDate === 'string') {
        date = Date.fromISO(isoDate);
    }
    if (!isValidDate(date)) { return '' }
    strDate = pad(date.getDate(),2) + '-' + pad(date.getMonth() + 1,2) + '-' + date.getFullYear();
    strDate = pad(date.getDate(),2) + '-' + pad(date.getMonth() + 1,2) + '-' + date.getFullYear();
    if (includeTime) {
        strDate = strDate + ' ' + pad(date.getHours(),2) + ':' + pad(date.getMinutes(),2);
    }
    return strDate;
}

function convertToIsoDate(date) {
    if (typeof date === 'string') {
        if (date.length === 20 && date.charAt(19) === 'Z') {
            // already an ISO date string
            return date;
        } else if (date.length > 9){
            // assume a short date of the form dd-mm-yyyy
            var year = date.substr(6,4),
                month = Number(date.substr(3,2))- 1,
                day = date.substr(0,2),
                hours = date.length > 12 ? date.substr(11,2) : 0,
                minutes = date.length > 15 ? date.substr(14,2) : 0;
            return new Date(year, month, day, hours, minutes).toISOStringNoMillis();
        } else {
            return '';
        }
    } else if (typeof date === 'object') {
        // assume a date object
        return date.toISOStringNoMillis();
    } else {
        return '';
    }
}

function stringToDate(date) {
    if (typeof date === 'string') {
        if (date.length === 20 && date.charAt(19) === 'Z') {
            // already an ISO date string
            return Date.fromISO(date);
        } else if (date.length > 9){
            // assume a short date of the form dd-mm-yyyy
            var year = date.substr(6,4),
                month = Number(date.substr(3,2))- 1,
                day = date.substr(0,2),
                hours = date.length > 12 ? date.substr(11,2) : 0,
                minutes = date.length > 15 ? date.substr(14,2) : 0;
            return new Date(year, month, day, hours, minutes);
        } else {
            return undefined;
        }
    } else if (typeof date === 'object') {
        // assume a date object
        return date;
    } else {
        return undefined;
    }
}

(function() {

    // Binding to exclude the contained html from the current binding context.
    // Used when you want to bind a section of html to a different viewModel.
    ko.bindingHandlers.stopBinding = {
        init: function() {
            return { controlsDescendantBindings: true };
        }
    };
    ko.virtualElements.allowedBindings.stopBinding = true;

    // This extends an observable that holds a UTC ISODate. It creates properties that hold:
    //  a JS Date object - useful with datepicker; and
    //  a simple formatted date of the form dd-mm-yyyy useful for display.
    // The formatted date will include hh:MM if the includeTime argument is true
    ko.extenders.simpleDate = function (target, includeTime) {
        target.date = ko.computed({
            read: function () {
                return Date.fromISO(target());
            },

            write: function (newValue) {
                if (newValue) {
                    var current = target(),
                        valueToWrite = convertToIsoDate(newValue);

                    if (valueToWrite !== current) {
                        target(valueToWrite);
                    }
                } else {
                    // date has been cleared
                    target("");
                }
            }
        });
        target.formattedDate = ko.computed({
            read: function () {
                return convertToSimpleDate(target(), includeTime);
            },

            write: function (newValue) {
                if (newValue) {
                    var current = target(),
                        valueToWrite = convertToIsoDate(newValue);

                    if (valueToWrite !== current) {
                        target(valueToWrite);
                    }
                }
            }
        });

        target.date(target());
        target.formattedDate(target());

        return target;
    };

    /* Custom binding for Bootstrap datepicker */
    // This binds an element and a model observable to the bootstrap datepicker.
    // The element can be an input or container such as span, div, td.
    // The datepicker is 2-way bound to the model. An input element will be updated automatically,
    //  other elements may need an explicit text binding to the formatted model date (see
    //  clickToPickDate for an example of a simple element).
    //
    // Additional properties that are supported by the Bootstrap Data Picker can be provided by adding
    // "datePickerOptions: {...}" to the data-bind attribute of the parent element.
    // e.g. data-bind="datepicker: myDate, datePickerOptions: {endDate: '+12m', startDate: '+0d'}" will add a date range constraint to the calendar.
    ko.bindingHandlers.datepicker = {
        init: function (element, valueAccessor, allBindingsAccessor) {
            // set current date into the element
            var $element = $(element),
                initialDate = ko.utils.unwrapObservable(valueAccessor()),
                initialDateStr = convertToSimpleDate(initialDate);
            if ($element.is('input')) {
                $element.val(initialDateStr);
            } else {
                $element.data('date', initialDateStr);
            }

            //initialize datepicker with some optional options
            var datePickerConfig = {format: 'dd-mm-yyyy', autoclose: true};
            if (allBindingsAccessor().datePickerOptions) {
                $.extend(datePickerConfig, allBindingsAccessor().datePickerOptions);
            }
            $element.datepicker(datePickerConfig);

            // if the parent container holds any element with the class 'open-datepicker'
            // then add a hook to do so
            $element.parent().find('.open-datepicker').click(function () {
                $element.datepicker('show');
            });
            $element.parent().find('.clear-date').click(function () {
                $(this).siblings('input').val('');
                $(this).siblings('input').change();
            });


            var changeHandler = function (event) {
                var value = valueAccessor();
                if (ko.isObservable(value)) {
                    value(event.date);
                }
            };

            //when a user changes the date via the datepicker, update the view model
            ko.utils.registerEventHandler(element, "changeDate", changeHandler);
            ko.utils.registerEventHandler(element, "hide", changeHandler);

            //when a user changes the date via the input, update the view model
            ko.utils.registerEventHandler(element, "change", function () {
                var value = valueAccessor();
                if (ko.isObservable(value)) {
                    value(stringToDate(element.value));
                    $(element).trigger('blur');  // This is to trigger revalidation of the date field to remove existing validation errors.
                }
            });
        },
        update: function (element, valueAccessor) {
            var widget = $(element).data("datepicker");
            //when the view model is updated, update the widget
            if (widget) {
                var date = ko.utils.unwrapObservable(valueAccessor());
                widget.date = date;
                if (!isNaN(widget.date)) {
                    widget.setDate(widget.date);
                } else {
                    console.log('reset')
                }
            }
        },
    };

}());

function pad(number, length){
    var str = "" + number
    while (str.length < length) {
        str = '0'+str
    }
    return str
}

//wrapper for an observable that protects value until committed
// CG - Changed the way the protected observable works from value doesn't change until commit to
// value changes as edits are made with rollback.  This was to enable cross field dependencies in a table
// row - using a temp variable meant observers were not notified of changes until commit.
ko.protectedObservable = function(initialValue) {
    //private variables
    var _current = ko.observable(initialValue);
    var _committed = initialValue;

    var result = ko.dependentObservable({
        read: _current,
        write: function(newValue) {
           _current(newValue);
        }
    });

    //commit the temporary value to our observable, if it is different
    result.commit = function() {
        _committed = _current();
    };

    //notify subscribers to update their value with the original
    result.reset = function() {
        _current(_committed);
    };

    return result;
};

// This binding allows dates to be displayed as simple text that can be clicked to access
//  a date picker for in-place editing.
// A user prompt appears if the model has no value. this can be customised.
// A calendar icon is added after the bound element as a visual indicator that the date can be edited.
// A computed 'hasChanged' property provides an observable isDirty flag for external save/revert mechanisms.
// The 'datepicker' binding is applied to the element to integrate the bootstrap datepicker.
// NOTE you can use the datepicker binding directly if you have an input as your predefined element.
ko.bindingHandlers.clickToPickDate = {
    init: function(element, valueAccessor, allBindingsAccessor, viewModel) {
        var observable = valueAccessor(),
            userPrompt = $(element).attr('data-prompt'),
            prompt = userPrompt || 'Click to edit',
            icon = $('<i class="icon-calendar open-datepicker" title="Click to change date"></i>');

        observable.originalValue = observable.date();
        observable.hasChanged = ko.computed(function () {
            //console.log("original: " + observable.originalValue + " current: " + observable.date());
            var original = observable.originalValue.getTime();
            var current = observable.date().getTime();
            return (original != current) && (!isNaN(original) || !isNaN(current));
        });

        $(element).parent().append(icon);

        ko.applyBindingsToNode(element, {
            text: ko.computed(function() {
                // todo: style default text as grey
                return ko.utils.unwrapObservable(observable) !== "" ? observable.formattedDate() : prompt;
            }),
            datepicker: observable.date
        });
    }
};



/**
 * Creates a flag that indicates whether the model has been modified.
 *
 * Compares the model to its initial state each time an observable changes. Uses the model's
 * modelAsJSON method if it is defined else uses ko.toJSON.
 *
 * @param root the model to watch
 * @param isInitiallyDirty
 * @returns an object (function) with the methods 'isDirty' and 'reset'
 */
ko.dirtyFlag = function(root, isInitiallyDirty) {
    var result = function() {};
    var _isInitiallyDirty = ko.observable(isInitiallyDirty || false);
    // this allows for models that do not have a modelAsJSON method
    var getRepresentation = function () {
        return (typeof root.modelAsJSON === 'function') ? root.modelAsJSON() : ko.toJSON(root);
    };
    var _initialState = ko.observable(getRepresentation());

    result.isDirty = ko.dependentObservable(function() {
        var dirty = _isInitiallyDirty() || _initialState() !== getRepresentation();
        /*if (dirty) {
            console.log('Initial: ' + _initialState());
            console.log('Actual: ' + getRepresentation());
        }*/
        return dirty;
    });

    result.reset = function() {
        _initialState(getRepresentation());
        _isInitiallyDirty(false);
    };

    return result;
};

/**
 * A simple dirty flag that will detect the first change to a model, then afterwards always return true (meaning
 * dirty).  This is to prevent the full model being re-serialized to JSON on every change, which can cause
 * performance issues for large models.
 * From: http://www.knockmeout.net/2011/05/creating-smart-dirty-flag-in-knockoutjs.html
 * @param root the model.
 * @returns true if the model has changed since this function was added.
 */
ko.simpleDirtyFlag = function(root) {
    var _initialized = ko.observable(false);

    // this allows for models that do not have a modelAsJSON method
    var getRepresentation = function () {
        return (typeof root.modelAsJSON === 'function') ? root.modelAsJSON() : ko.toJSON(root);
    };

    var result = function() {};

    //one-time dirty flag that gives up its dependencies on first change
    result.isDirty = ko.computed(function () {
        if (!_initialized()) {

            //just for subscriptions
            getRepresentation();

            //next time return true and avoid ko.toJS
            _initialized(true);

            //on initialization this flag is not dirty
            return false;
        }

        //on subsequent changes, flag is now dirty
        return true;
    });
    result.reset = function() {
        _initialized(false);
    }

    return result;
};


/**
 * A vetoableObservable is an observable that provides a mechanism to prevent changes to its value under certain
 * conditions.  When a change is notified, the vetoCheck function is executed - if it returns false the change is
 * disallowed and the vetoCallback function is invoked.  Otherwise the change is allowed and the noVetoCallback
 * function is invoked.
 * The only current example of it's use is when the type of an activity is changed, it
 * can potentially invalidate any target score values that have been supplied by the user - hence the user is
 * asked if they wish to proceed, and if so, the targets can be removed.
 * @param initialValue the initial value for the observable.
 * @param vetoCheck a function or string that will be invoked when the value of the vetoableObservable changes.  Returning
 * false from this function will disallow the change.  If a string is supplied, it is used as the question text
 * for a window.confirm function.
 * @param noVetoCallback this callback will be invoked when a change to the vetoableObservable is allowed.
 * @param vetoCallback this callback will be invoked when a change to the vetoableObservable is disallowed (has been vetoed).
 * @returns {*}
 */
ko.vetoableObservable = function(initialValue, vetoCheck, noVetoCallback, vetoCallback) {
    //private variables
    var _current = ko.observable(initialValue);

    var vetoFunction = typeof (vetoCheck) === 'function' ? vetoCheck : function() {
        return window.confirm(vetoCheck);
    };
    var result = ko.dependentObservable({
        read: _current,
        write: function(newValue) {

            // The equality check is treating undefined as equal to an empty string to prevent
            // the initial population of the value with an empty select option from triggering the veto.
            if (_current() !== newValue && (_current() !== undefined || newValue !== '')) {

                if (vetoFunction()) {
                    _current(newValue);
                    if (noVetoCallback !== undefined) {
                        noVetoCallback();
                    }
                }
                else {
                    _current.notifySubscribers();
                    if (vetoCallback !== undefined) {
                        vetoCallback();
                    }
                }
            }

        }
    });

    return result;
};

// custom validator to ensure that only one of two fields is populated
function exclusive (field, rules, i, options) {
    var otherFieldId = rules[i+2], // get the id of the other field
        otherValue = $('#'+otherFieldId).val(),
        thisValue = field.val(),
        message = rules[i+3];
    // checking thisValue is technically redundant as this validator is only called
    // if there is a value in the field
    if (otherValue !== '' && thisValue !== '') {
        return message;
    } else {
        return true;
    }
};


var ACTIVITY_PROGRESS_CLASSES = {
    'planned':'btn-warning',
    'started':'btn-success',
    'finished':'btn-info',
    'deferred':'btn-danger',
    'cancelled':'btn-inverse'
};


/** Returns a bootstrap class used to style activity progress labels */
function activityProgressClass(progress) {
    return ACTIVITY_PROGRESS_CLASSES[progress];
}

/** Allows a subscription to an observable that passes both the old and new value to the callback */
ko.subscribable.fn.subscribeChanged = function (callback) {
    var savedValue = this.peek();
    return this.subscribe(function (latestValue) {
        var oldValue = savedValue;
        savedValue = latestValue;
        callback(latestValue, oldValue);
    });
};

