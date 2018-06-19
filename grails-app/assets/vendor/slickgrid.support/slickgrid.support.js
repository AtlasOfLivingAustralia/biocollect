

//---- taken from jqueryValidationEngine with minor modifications ------
var ValidationSupport = function() {

    var self = this;
    var defaults = {

        // Name of the event triggering field validation
        validationEventTrigger: "blur",
        // Automatically scroll viewport to the first error
        scroll: true,
        // Focus on the first input
        focusFirstField:true,
        // Show prompts, set to false to disable prompts
        showPrompts: true,
        // Should we attempt to validate non-visible input fields contained in the form? (Useful in cases of tabbed containers, e.g. jQuery-UI tabs)
        validateNonVisibleFields: false,
        // Opening box position, possible locations are: topLeft,
        // topRight, bottomLeft, centerRight, bottomRight, inline
        // inline gets inserted after the validated field or into an element specified in data-prompt-target
        promptPosition: "topRight",
        bindMethod:"bind",
        // internal, automatically set to true when it parse a _ajax rule
        inlineAjax: false,
        // if set to true, the form data is sent asynchronously via ajax to the form.action url (get)
        ajaxFormValidation: false,
        // The url to send the submit ajax validation (default to action)
        ajaxFormValidationURL: false,
        // HTTP method used for ajax validation
        ajaxFormValidationMethod: 'get',
        // Ajax form validation callback method: boolean onComplete(form, status, errors, options)
        // retuns false if the form.submit event needs to be canceled.
        onAjaxFormComplete: $.noop,
        // called right before the ajax call, may return false to cancel
        onBeforeAjaxFormValidation: $.noop,
        // Stops form from submitting and execute function assiciated with it
        onValidationComplete: false,

        // Used when you have a form fields too close and the errors messages are on top of other disturbing viewing messages
        doNotShowAllErrosOnSubmit: false,
        // Object where you store custom messages to override the default error messages
        custom_error_messages:{},
        // true if you want to vind the input fields
        binded: true,
        // set to true, when the prompt arrow needs to be displayed
        showArrow: true,
        // did one of the validation fail ? kept global to stop further ajax validations
        isError: false,
        // Limit how many displayed errors a field can have
        maxErrorsPerField: false,

        // Caches field validation status, typically only bad status are created.
        // the array is used during ajax form validation to detect issues early and prevent an expensive submit
        ajaxValidCache: {},
        // Auto update prompt position after window resize
        autoPositionUpdate: false,

        InvalidFields: [],
        onFieldSuccess: false,
        onFieldFailure: false,
        onSuccess: false,
        onFailure: false,
        validateAttribute: "class",
        addSuccessCssClassToField: "",
        addFailureCssClassToField: "",

        // Auto-hide prompt
        autoHidePrompt: false,
        // Delay before auto-hide
        autoHideDelay: 10000,
        // Fade out duration while hiding the validations
        fadeDuration: 0.3,
        // Use Prettify select library
        prettySelect: false,
        // Add css class on prompt
        addPromptClass : "",
        // Custom ID uses prefix
        usePrefix: "",
        // Custom ID uses suffix
        useSuffix: "",
        // Only show one message per error prompt
        showOneMessage: false
    };

    /**
     * Calculates prompt position
     *
     * @param {jqObject}
     *            field
     * @param {jqObject}
     *            the prompt
     * @param {Map}
     *            options
     * @return positions
     */
    var _calculatePosition = function (field, promptElmt, options) {

        var promptTopPosition, promptleftPosition, marginTopSize;
        var fieldWidth = field.width();
        var fieldLeft = field.offset().left;
        var fieldTop = field.offset().top;
        var fieldHeight = field.height();
        var promptHeight = promptElmt.height();


        // is the form contained in an overflown container?
        promptTopPosition = promptleftPosition = 0;
        // compensation for the arrow
        marginTopSize = -promptHeight;


        //prompt positioning adjustment support
        //now you can adjust prompt position
        //usage: positionType:Xshift,Yshift
        //for example:
        //   bottomLeft:+20 means bottomLeft position shifted by 20 pixels right horizontally
        //   topRight:20, -15 means topRight position shifted by 20 pixels to right and 15 pixels to top
        //You can use +pixels, - pixels. If no sign is provided than + is default.
        var positionType = field.data("promptPosition") || options.promptPosition;
        var shift1 = "";
        var shift2 = "";
        var shiftX = 0;
        var shiftY = 0;
        if (typeof(positionType) == 'string') {
            //do we have any position adjustments ?
            if (positionType.indexOf(":") != -1) {
                shift1 = positionType.substring(positionType.indexOf(":") + 1);
                positionType = positionType.substring(0, positionType.indexOf(":"));

                //if any advanced positioning will be needed (percents or something else) - parser should be added here
                //for now we use simple parseInt()

                //do we have second parameter?
                if (shift1.indexOf(",") != -1) {
                    shift2 = shift1.substring(shift1.indexOf(",") + 1);
                    shift1 = shift1.substring(0, shift1.indexOf(","));
                    shiftY = parseInt(shift2);
                    if (isNaN(shiftY)) shiftY = 0;
                }
                ;

                shiftX = parseInt(shift1);
                if (isNaN(shift1)) shift1 = 0;

            }
            ;
        }
        ;


        switch (positionType) {
            default:
            case "topRight":
                promptleftPosition += fieldLeft + fieldWidth - 30;
                promptTopPosition += fieldTop;
                break;

            case "topLeft":
                promptTopPosition += fieldTop;
                promptleftPosition += fieldLeft;
                break;

            case "centerRight":
                promptTopPosition = fieldTop + 4;
                marginTopSize = 0;
                promptleftPosition = fieldLeft + field.outerWidth(true) + 5;
                break;
            case "centerLeft":
                promptleftPosition = fieldLeft - (promptElmt.width() + 2);
                promptTopPosition = fieldTop + 4;
                marginTopSize = 0;

                break;

            case "bottomLeft":
                promptTopPosition = fieldTop + field.height() + 5;
                marginTopSize = 0;
                promptleftPosition = fieldLeft;
                break;
            case "bottomRight":
                promptleftPosition = fieldLeft + fieldWidth - 30;
                promptTopPosition = fieldTop + field.height() + 5;
                marginTopSize = 0;
                break;
            case "inline":
                promptleftPosition = 0;
                promptTopPosition = 0;
                marginTopSize = 0;
        }
        ;


        //apply adjusments if any
        promptleftPosition += shiftX;
        promptTopPosition += shiftY;

        return {
            "callerTopPosition": promptTopPosition + "px",
            "callerleftPosition": promptleftPosition + "px",
            "marginTopSize": marginTopSize + "px"
        };
    };

    /**
     * Builds and shades a prompt for the given field.
     *
     * @param {jqObject} field
     * @param {String} name the name of the data attribute being validated.
     * @param {String} promptText html text to display type
     * @param {String} type the type of bubble: 'pass' (green), 'load' (black) anything else (red)
     * @param {boolean} ajaxed - use to mark fields than being validated with ajax
     * @param {Map} options user options
     */
    var _buildPrompt = function (field, name, promptText, type, ajaxed, options) {

        if (!options) {
            options = defaults;
        }
        // create the prompt
        var prompt = $('<div>');
        //prompt.addClass(methods._getClassName(field.attr("id")) + "formError");
        // add a class name to identify the parent form of the prompt
        //prompt.addClass("parentForm" + methods._getClassName(field.closest('form, .validationEngineContainer').attr("id")));
        prompt.addClass("formError");
        prompt.attr('id', getPromptId(name));

        switch (type) {
            case "pass":
                prompt.addClass("greenPopup");
                break;
            case "load":
                prompt.addClass("blackPopup");
                break;
            default:
            /* it has error  */
            //alert("unknown popup type:"+type);
        }
        if (ajaxed)
            prompt.addClass("ajaxed");

        // create the prompt content
        var promptContent = $('<div>').addClass("formErrorContent").html(promptText).appendTo(prompt);

        // determine position type
        var positionType = field.data("promptPosition") || options.promptPosition;

        // create the css arrow pointing at the field
        // note that there is no triangle on max-checkbox and radio
        if (options.showArrow) {
            var arrow = $('<div>').addClass("formErrorArrow");

            //prompt positioning adjustment support. Usage: positionType:Xshift,Yshift (for ex.: bottomLeft:+20 or bottomLeft:-20,+10)
            if (typeof(positionType) == 'string') {
                var pos = positionType.indexOf(":");
                if (pos != -1)
                    positionType = positionType.substring(0, pos);
            }

            switch (positionType) {
                case "bottomLeft":
                case "bottomRight":
                    prompt.find(".formErrorContent").before(arrow);
                    arrow.addClass("formErrorArrowBottom").html('<div class="line1"><!-- --></div><div class="line2"><!-- --></div><div class="line3"><!-- --></div><div class="line4"><!-- --></div><div class="line5"><!-- --></div><div class="line6"><!-- --></div><div class="line7"><!-- --></div><div class="line8"><!-- --></div><div class="line9"><!-- --></div><div class="line10"><!-- --></div>');
                    break;
                case "topLeft":
                case "topRight":
                    arrow.html('<div class="line10"><!-- --></div><div class="line9"><!-- --></div><div class="line8"><!-- --></div><div class="line7"><!-- --></div><div class="line6"><!-- --></div><div class="line5"><!-- --></div><div class="line4"><!-- --></div><div class="line3"><!-- --></div><div class="line2"><!-- --></div><div class="line1"><!-- --></div>');
                    prompt.append(arrow);
                    break;
            }
        }
        // Add custom prompt class
        if (options.addPromptClass)
            prompt.addClass(options.addPromptClass);

        // Add custom prompt class defined in element
        var requiredOverride = field.attr('data-required-class');
        if (requiredOverride !== undefined) {
            prompt.addClass(requiredOverride);
        } else {
            if (options.prettySelect) {
                if ($('#' + field.attr('id')).next().is('select')) {
                    var prettyOverrideClass = $('#' + field.attr('id').substr(options.usePrefix.length).substring(options.useSuffix.length)).attr('data-required-class');
                    if (prettyOverrideClass !== undefined) {
                        prompt.addClass(prettyOverrideClass);
                    }
                }
            }
        }

        prompt.css({
            "opacity": 0
        });

        $('body').append(prompt); // Slickgrid uses overflow:none a lot so the error popup needs to be attached to the body.

        var pos = _calculatePosition(field, prompt, options);

        prompt.css({
            'position': positionType === 'inline' ? 'relative' : 'absolute',
            "top": pos.callerTopPosition,
            "left": pos.callerleftPosition,
            "marginTop": pos.marginTopSize,
            "opacity": 0
        }).data("callerField", field);


        if (options.autoHidePrompt) {
            setTimeout(function () {
                prompt.animate({
                    "opacity": 0
                }, function () {
                    prompt.closest('.formErrorOuter').remove();
                    prompt.remove();
                });
            }, options.autoHideDelay);
        }
        return prompt.animate({
            "opacity": 0.87
        });
    };



    var invalid = {};

    var getPromptId = function(name) {
        return name+'Error';
    };


    var findPrompt = function(name) {

        var prompt = $('#'+getPromptId(name));
        return prompt;
    };

    self.addPrompt = function (field, id, fieldName, error) {
        self.removePrompt(id, fieldName);
        if (!invalid[id]) {
            invalid[id] = {};
        }

        invalid[id][fieldName] = error;
        _buildPrompt(field, fieldName, error);
    };

    self.removePrompt = function(id, fieldName) {
        if (!invalid[id]) {
            invalid[id] = {};
        }
        invalid[id][fieldName] = null;
        findPrompt(fieldName).remove();
    };

    self.addValidationSupport = function($elem, activityId, fieldName) {
        $elem.on('jqv.field.result', function(event, field, error, messageString) {

            self.removePrompt(activityId, fieldName);
            if (error) {
                self.addPrompt($elem, activityId, fieldName, messageString);
            }
        });
    };


};

function helpHover(helpText) {
    return '<a href="#" class="helphover" data-original-title="" data-placement="top" data-container="body" data-content="'+helpText+'">'+
        '<i class="icon-question-sign">&nbsp;</i>'+
        '</a>';
};

var validationSupport = new ValidationSupport();
/**
 * Support for bulk editing activities using slick grid.
 */
function OutputValueEditor(args) {
    var $input;
    var defaultValue;
    var scope = this;

    this.init = function () {
        $input = $("<INPUT type=text class='editor-text' data-prompt-target='blah'/>")
            .addClass(args.column.validationRules)// Using class because of way jqueryValidationEngine determines the pattern used.
            .appendTo(args.container)
            //.bind("keydown.nav", function (e) {
            //    if (e.keyCode === $.ui.keyCode.LEFT || e.keyCode === $.ui.keyCode.RIGHT) {
            //        e.stopImmediatePropagation();
            //    }
            //})
            .focus()
            .select();

        validationSupport.addValidationSupport($input, args.item, args.column.field);
    };

    this.destroy = function () {
        $input.remove();
    };

    this.focus = function () {
        $input.focus();
    };

    this.getValue = function () {
        return $input.val();
    };

    this.setValue = function (val) {
        $input.val(val);
    };

    this.loadValue = function (item) {
        defaultValue = args.grid.getOptions().dataItemColumnValueExtractor(item, args.column);
        $input.val(defaultValue);
        $input[0].defaultValue = defaultValue;
        $input.select();
    };

    this.serializeValue = function () {
        return $input.val();
    };

    this.applyValue = function (item, state) {
        outputValueEditor(item, args.column, state);
    };

    this.isValueChanged = function () {
        /*return (!($input.val() == "" && defaultValue == null)) && ($input.val() != defaultValue);*/
        return true;
    };

    this.validate = function () {

        $input.closest('.validationEngineContainer').validationEngine('validate');

        /** always return true as otherwise focus traversal will be blocked by the grid */
        return {
            valid: true,
            msg: null
        };
    };

    this.init();
}

function OutputSelectEditor(args) {
    var $select;
    var defaultValue;
    var scope = this;

    this.init = function () {

        $select = $("<SELECT tabIndex='0' class='editor-yesno'></SELECT>");
        for (var i=0; i<args.column.options.length; i++) {
            $select.append($("<OPTION name=\""+args.column.options[i]+"\" value=\""+args.column.options[i]+"\">"+args.column.options[i]+"</OPTION>"));
        }
        $select.appendTo(args.container);
        $select.focus();

        validationSupport.addValidationSupport($select, args.item, args.column.field);
    };

    this.destroy = function () {
        $select.remove();
    };

    this.focus = function () {
        $select.focus();
        $select.size == args.column.options.length;
    };

    this.loadValue = function (item) {

        defaultValue = args.grid.getOptions().dataItemColumnValueExtractor(item, args.column);

        $select.val(defaultValue);
        $select.select();
    };

    this.serializeValue = function () {
        return ($select.val());
    };

    this.applyValue = function (item, state) {
        outputValueEditor(item, args.column, state);
    };

    this.isValueChanged = function () {
        return ($select.val() != defaultValue);
    };

    this.validate = function () {

        $select.closest('.validationEngineContainer').validationEngine('validate'); // A single field validation returns the opposite of what it should?

        return {
            valid: true,
            msg: null
        };
    };

    this.init();
}

/*
 * An example of a "detached" editor.
 * The UI is added onto document BODY and .position(), .show() and .hide() are implemented.
 * KeyDown events are also handled to provide handling for Tab, Shift-Tab, Esc and Ctrl-Enter.
 */
function LongTextEditor(args) {
    var $input, $wrapper;
    var defaultValue;
    var scope = this;

    this.init = function () {
        var $container = $("body");

        $wrapper = $("<DIV style='z-index:10000;position:absolute;background:white;padding:5px;border:3px solid gray; -moz-border-radius:10px; border-radius:10px;'/>")
            .appendTo($container);

        $input = $("<TEXTAREA hidefocus rows=5 style='backround:white;width:250px;height:80px;border:0;outline:0'>");
        if (args.column.maxlength) {
            $input.attr('maxlength', args.column.maxlength);
        }
        $input.appendTo($wrapper);

        $("<DIV style='text-align:right'><BUTTON>Save</BUTTON><BUTTON>Cancel</BUTTON></DIV>")
            .appendTo($wrapper);

        $wrapper.find("button:first").bind("click", this.save);
        $wrapper.find("button:last").bind("click", this.cancel);
        $input.bind("keydown", this.handleKeyDown);

        scope.position(args.position);
        $input.focus().select();

        validationSupport.addValidationSupport($input, args.item, args.column.field);
    };

    this.handleKeyDown = function (e) {
        if (e.which == $.ui.keyCode.ENTER && e.ctrlKey) {
            scope.save();
        } else if (e.which == $.ui.keyCode.ESCAPE) {
            e.preventDefault();
            scope.cancel();
        } else if (e.which == $.ui.keyCode.TAB && e.shiftKey) {
            e.preventDefault();
            args.grid.navigatePrev();
        } else if (e.which == $.ui.keyCode.TAB) {
            e.preventDefault();
            args.grid.navigateNext();
        }
    };

    this.save = function () {
        args.commitChanges();
    };

    this.cancel = function () {
        $input.val(defaultValue);
        args.cancelChanges();
    };

    this.hide = function () {
        $wrapper.hide();
    };

    this.show = function () {
        $wrapper.show();
    };

    this.position = function (position) {
        $wrapper
            .css("top", position.top - 5)
            .css("left", position.left - 5)
    };

    this.destroy = function () {
        $wrapper.remove();
    };

    this.focus = function () {
        $input.focus();
    };

    this.loadValue = function (item) {
        defaultValue = args.grid.getOptions().dataItemColumnValueExtractor(item, args.column);
        $input.val(defaultValue);
        $input.select();
    };

    this.serializeValue = function () {
        return $input.val();
    };

    this.applyValue = function (item, state) {
        outputValueEditor(item, args.column, state);
    };

    this.isValueChanged = function () {
        return (!($input.val() == "" && defaultValue == null)) && ($input.val() != defaultValue);
    };

    this.validate = function () {
        $input.closest('.validationEngineContainer').validationEngine('validate'); // A single field validation returns the opposite of what it should?

        return {
            valid: true,
            msg: null
        };
    };

    this.init();
}

function CheckboxEditor(args) {
    var $select;
    var defaultValue;
    var scope = this;

    this.init = function () {
        $select = $("<INPUT type=checkbox value='true' class='editor-checkbox' hideFocus>");
        $select.appendTo(args.container);
        $select.focus();
    };

    this.destroy = function () {
        $select.remove();
    };

    this.focus = function () {
        $select.focus();
    };

    this.loadValue = function (item) {
        defaultValue = args.grid.getOptions().dataItemColumnValueExtractor(item, args.column);
        if (defaultValue) {
            $select.prop('checked', true);
        } else {
            $select.prop('checked', false);
        }
    };

    this.serializeValue = function () {
        return $select.prop('checked');
    };

    this.applyValue = function (item, state) {
        outputValueEditor(item, args.column, state);
    };

    this.isValueChanged = function () {
        return (this.serializeValue() !== defaultValue);
    };

    this.validate = function () {
        return {
            valid: true,
            msg: null
        };
    };

    this.init();
}

function ProgressEditor(args) {
    var $select, $progressLabel;
    var defaultValue;
    var currentButtonClass;
    var scope = this;

    this.init = function () {
        $select = $("<INPUT type=checkbox value='true' class='progress-checkbox' hideFocus>");
        $select.appendTo(args.container);
        $progressLabel = $('<span class="label"/>');
        $progressLabel.appendTo(args.container);
        $select.change(scope.changeProgress);
        $select.focus();
    };

    this.destroy = function () {
        $select.remove();
    };

    this.focus = function () {
        $select.focus();
    };

    this.loadValue = function (item) {

        defaultValue = item.progress();

        if (defaultValue == 'finished') {
            $select.prop('checked', true);
        } else {
            $select.prop('checked', false);
        }
        $select.change();

    };

    this.changeProgress = function() {
        var progress = $select.prop('checked') == true ? 'finished' : 'started';
        var newClass = activityProgressClass(progress);

        $progressLabel.removeClass(currentButtonClass).addClass(newClass).text(progress);
        currentButtonClass = newClass;
    };

    this.serializeValue = function () {
        return $select.prop('checked');
    };

    this.applyValue = function (item, state) {
        var progress = state == true ? 'finished' : 'started';
        item.progress(progress);
    };

    this.isValueChanged = function () {
        return (this.serializeValue() !== defaultValue);
    };

    this.validate = function () {
        return {
            valid: true,
            msg: null
        };
    };

    this.init();
}

function BaseEditor(args) {
    var self = this;
    var originalValue;

    self.$element = undefined;

    self.setElement = function(element) {
        self.$element = element;
        if (args.column.validationRules) {
            element.addClass(args.column.validationRules)// Using class because of way jqueryValidationEngine determines the pattern used.
        }
        validationSupport.addValidationSupport(element, args.item, args.column.field);
    };

    this.destroy = function () {
        self.$element.remove();
    };

    this.focus = function () {
        self.$element.focus();
        if (typeof self.$element.select === 'function') {
            self.$element.select();
        }
    };

    this.extractValue = function (item) {
        var dataExtractor = args.grid.getOptions().dataItemColumnValueExtractor;
        originalValue = dataExtractor ? dataExtractor(item, args.column) : item[args.column.field];
        return originalValue;
    };

    this.loadValue = function (item) {
        var value = self.extractValue(item);
        self.$element.val(value);
        self.focus();
    };

    this.serializeValue = function () {
        return (self.$element.val());
    };

    this.applyValue = function (item, state) {
        item[args.column.field] = state;
        //outputValueEditor(item, args.column, state);
    };

    this.isValueChanged = function () {
        return (self.serializeValue() != originalValue);
    };

    this.validate = function () {

        self.$element.closest('.validationEngineContainer').validationEngine('validate'); // A single field validation returns the opposite of what it should?

        return {
            valid: true,
            msg: null
        };
    };
}

function BodyAttachedEditor(args) {
    var self = this;
    BaseEditor.apply(this, [args]);
    this.position = function (position) {
        self.$element
            .css("top", position.top - 5)
            .css("left", position.left - 5)
    };

    this.hide = function () {
        self.$element.hide();
    };
    this.show = function () {
        self.$element.show();
    };

}

function ComboBoxEditor(args) {

    BodyAttachedEditor.apply(this, [args]);
    var self = this;
    var $comboboxWrapper;
    var combobox;
    var $select;

    this.init = function () {

        $select = $("<SELECT tabIndex='0' class='editor'></SELECT>");
        var labelProperty = args.column.optionLabel || 'label';
        var valueProperty = args.column.optionValue || 'value';
        for (var i=0; i<args.column.options.length; i++) {
            $select.append($("<OPTION name=\""+args.column.options[i][labelProperty]+"\" value=\""+args.column.options[i][valueProperty]+"\">"+args.column.options[i][labelProperty]+"</OPTION>"));
        }
        $select.combobox({bsVersion:'2'});
        combobox = $select.data('combobox');
        $comboboxWrapper = combobox.$container;
        $comboboxWrapper.appendTo($('body'));
        $comboboxWrapper.css('position', 'absolute');
        $comboboxWrapper.css('z-index', 10000);


        // The default hide and blur behaviour don't work well with the SlickGrid editing model.
        combobox.hide = function() {
            if (combobox.selected) {
                args.commitChanges();
            }
            else {
                args.cancelChanges();
            }
        };
        combobox.$element.off('blur');
        if (combobox.$element.width() < args.position.width) {
            combobox.$element.width(args.position.width);
        }
        self.setElement($comboboxWrapper);
        self.position(args.position);

    };

    this.focus = function () {

        combobox.$element.val(combobox.$target.val());

        combobox.$element.on('focus', function() {
            combobox.$element.select();
            combobox.$element.off('focus', this);
            combobox.lookup(combobox.$target.val());
        });
        combobox.$element.focus();

    };

    this.destroy = function() {
        $select.remove();
        $comboboxWrapper.remove();
        combobox.$menu.remove();
        delete combobox;
    };

    this.loadValue = function (item) {
        var value = self.extractValue(item);
        combobox.$target.val(value);
        self.focus();
    };

    this.serializeValue = function () {
        return (combobox.$target.val());
    };

    this.init();
}

function SelectEditor(args) {
    BaseEditor.apply(this, [args]);
    var self = this;

    this.init = function () {

        var $select = $("<SELECT tabIndex='0' class='editor' style='width:100%;'></SELECT>");
        var labelProperty = args.column.optionLabel || 'label';
        var valueProperty = args.column.optionValue || 'value';

        for (var i=0; i<args.column.options.length; i++) {
            var option = args.column.options[i];
            var value, label;
            if (option.hasOwnProperty(labelProperty) && option.hasOwnProperty(valueProperty)) {
                value = option[valueProperty];
                label = option[labelProperty];
            }
            else {
                value = option;
                label = option;
            }
            $select.append($("<OPTION name=\""+args.column.field+"\" value=\""+value+"\">"+label+"</OPTION>"));
        }
        $select.height($(args.container).height());
        $select.appendTo(args.container);
        $select.focus();

        self.setElement($select);
    };

    this.init();
}

function CurrencyEditor(args) {
    BaseEditor.apply(this, [args]);
    var self = this;

    this.init = function () {
        var height = $(args.container).height();
        var width = $(args.container).width();
        var $container = $('<div class="input-append input-prepend" style="width:100%;"></div>');
        $container.append('<span class="add-on">$</span>');
        var $input = $('<input style="width:100%;" type="text">');
        $container.append($input);
        $container.append('<span class="add-on">.00</span>');
        $container.appendTo(args.container);
        $input.focus();
        $container.height(height);
        $input.height(height).width(width-68).css('padding-top', 0).css('padding-bottom', 0);
        $container.find('span').height(height).css('padding-top', 0).css('padding-bottom', 0);

        self.setElement($input);
    };

    this.init();
}

function DateEditor2(args) {
    BaseEditor.apply(this, [args]);
    var self = this;
    var calendarOpen = false;

    var focus = self.focus;
    var extractValue = self.extractValue;

    this.init = function () {
        var $input = $("<INPUT type=text class='editor-text' />");
        $input.appendTo(args.container);
        $input.focus().select();
        $input.datepicker({
            format: 'dd-mm-yyyy',
            autoclose: true
        });
        $input.on('changeDate', args.commitChanges);

        $input.width(args.container.width);
        self.setElement($input);
        self.focus();
    };

    this.destroy = function () {
        $.datepicker.dpDiv.stop(true, true);
        self.$element.datepicker("hide");
        self.$element.datepicker("destroy");
        self.$element.remove();
    };

    this.extractValue = function(item) {
        var original = extractValue(item);
        if (!original) {
            return '';
        }
        return convertToSimpleDate(original, false);
    };

    this.focus = function() {
        self.$element.datepicker('show');
        focus();
    };
    this.show = function () {
        if (calendarOpen) {
            $.datepicker.dpDiv.stop(true, true).show();
        }
    };

    this.hide = function () {
        if (calendarOpen) {
            $.datepicker.dpDiv.stop(true, true).hide();
        }
    };

    this.position = function (position) {
        if (!calendarOpen) {
            return;
        }
        $.datepicker.dpDiv
            .css("top", position.top + 30)
            .css("left", position.left);
    };

    this.serializeValue = function () {
        var simpleDate = self.$element.val();
        return convertToIsoDate(simpleDate);
    };

    this.init();
}

dateFormatter = function(row, cell, value, columnDef, dataContext) {
    if (!value) {
        return '';
    }
    return convertToSimpleDate(value, false);
};

optionsFormatter = function(row, cell, value, columnDef, dataContext) {
    var labelProperty = columnDef.optionLabel || 'label';
    var valueProperty = columnDef.optionValue || 'value';

    for (var i=0; i<columnDef.options.length; i++) {
        if (value == columnDef.options[i][valueProperty]) {
            return columnDef.options[i][labelProperty];
        }
    }
    return '';
};

progressFormatter = function( row, cell, value, columnDef, dataContext ) {

    var saving = dataContext.saving();

    var progress = ko.utils.unwrapObservable(value);
    var result = '<input type="checkbox" class="progress-checkbox" value="progress"';

    if (progress === 'finished') {
        result += " checked=checked";
    }

    result +=  "><span class=\"label "+activityProgressClass(progress)+"\">"+progress+"</span>"
    if (saving) {
        result += '<img src="${asset.assetPath(src:\'ajax-saver.gif\')}" alt="saving icon"/>'
    }
    return result;
};


function findOutput(activity, name) {
    if (!name) {
        return;
    }
    var output = ko.utils.arrayFirst(activity.outputModels, function(output) {
        return output.name === name;
    });
    return output;

}

// The item is an activity containing an array of outputs.
var outputValueExtractor = function(item, column) {
    if (column.outputName) {
        var output = findOutput(item, column.outputName);
        return output ? ko.utils.unwrapObservable(output.data[column.field]) : '';
    }
    return item[column.field];
};

var outputValueEditor = function(item, column, value) {
    if (column.outputName) {
        var output = findOutput(item, column.outputName);
        if (!output) {
            output = {name:column.outputName, data:{}, activityId: item.activityId};
            item.outputs.push(output);
        }
        output.data[column.field](value);
    }

};

function validate(grid, activity, outputModels) {

    var activityValid = true;
    $.each(outputModels, function(i, outputModel) {
        var output = findOutput(activity, outputModel.name);

        var results = validateOutput(output, outputModel.dataModel);

        $.each(results, function(j, result) {
            if (!result.valid) {
                var columnIdx = columnIndex(result.field, grid.getColumns());
                var node = grid.getCellNode(activity.row, columnIdx);
                if (node) {
                    validationSupport.addPrompt($(node), activity.activityId, result.field, result.error);
                    activityValid = false;
                }
            }
        });
    });
    return activityValid;

};

function columnIndex(name, columns) {
    var index = -1;
    $.each(columns, function(i, column) {
        if (column.field == name) {
            index = i;
            return false;
        }
    });
    return index;
}

function validateOutput(output, outputModel) {

    var results = [];
    $.each(outputModel.dataModel, function(i, dataItem) {
        var value = output.data[dataItem.name];
        var validations = dataItem.validate;
        if (validations) {
            validations = validations.split(',');

            $.each(validations, function(j, validation) {
                var args = undefined;
                var validatorName = validation;
                var argsIndex = validation.indexOf('[');
                if (argsIndex > 0) {
                    validatorName = validation.substring(0, argsIndex);
                    args = validation.substring(argsIndex+1, validation.length-1);
                }

                var validator = validators[validatorName];
                if (validator) {
                    var result = validator(dataItem.name, value(), args);
                    if (!result.valid) {
                        results.push(result);
                        return false;
                    }
                }


            });
        }

    });
    return results;
};

function parseValidationString(validationString) {
    var validationFunctions = [];
    if (!validationString) {
        return [];
    }
    var validatePrefix = 'validate['
    var index = validationString.indexOf(validatePrefix);
    if (index >= 0) {
        validationString = validationString.substring(validatePrefix.length, validationString.length-1);
    }
    var validations = validationString.split(',');
    for (var i=0; i<validations.length; i++) {
        var validation = validations[i];
        var args = undefined;
        var validatorName = validation;
        var argsIndex = validation.indexOf('[');
        if (argsIndex > 0) {
            validatorName = validation.substring(0, argsIndex);
            args = validation.substring(argsIndex+1, validation.length-1);
        }
        var validatorFn = validators[validatorName];
        if (validatorFn) {
            validationFunctions.push(
                function(field, value) {
                    return validatorFn(field, value, args);
                });
        }
    }
    return validationFunctions;
}

validators = {
    required: function(field, value) {
        if (value === null || value === undefined || !String(value)) {
            var error = $.validationEngineLanguage.allRules.required.alertText;
            return {field:field, valid:false, error:error};
        }
        return {field:field, valid:true};
    },
    min: function(field, value, args) {
        var min = parseFloat(args);
        var value = parseFloat(value);
        if (isNaN(value) || value < min) {
            var error = $.validationEngineLanguage.allRules.min.alertText + min;
            return {field:field, valid:false, error:error};
        }
        return {field:field, valid:true};
    },
    max: function(field, value, args) {
        var max = parseFloat(args);
        var value = parseFloat(value);
        if (isNaN(value) || value > max) {
            var error = $.validationEngineLanguage.allRules.max.alertText + max;
            return {field:field, valid:false, error:error};
        }
        return {field:field, valid:true};
    }
}

