/**
 * Attaches a bootstrap popover to the bound element.  The details for the popover should be supplied as the
 * value of this binding.
 * e.g.  <a href="#" data-bind="popover: {title:"Popover title", content:"Popover content"}>My link with popover</a>
 *
 * The content and title must be supplied, other popover options have defaults.
 *
 */
ko.bindingHandlers.popover = {

    init: function (element, valueAccessor) {
        ko.bindingHandlers.popover.initPopover(element, valueAccessor);
    },
    update: function (element, valueAccessor) {

        var $element = $(element);
        $element.popover('destroy');
        var options = ko.bindingHandlers.popover.initPopover(element, valueAccessor);
        if (options.autoShow) {
            if ($element.data('firstPopover') === false) {
                $element.popover('show');
                $('body').on('click', function (e) {

                    if (e.target != element && $element.find(e.target).length == 0) {
                        $element.popover('hide');
                    }
                });
            }
            $element.data('firstPopover', false);
        }

    },

    defaultOptions: {
        placement: "right",
        animation: true,
        html: true,
        trigger: "hover",
        delay: {
            show: 250
        }
    },

    initPopover: function (element, valueAccessor) {
        var options = ko.utils.unwrapObservable(valueAccessor());

        var combinedOptions = ko.utils.extend({}, ko.bindingHandlers.popover.defaultOptions);
        var content = ko.utils.unwrapObservable(options.content);
        ko.utils.extend(combinedOptions, options);
        combinedOptions.description = content;

        $(element).popover(combinedOptions);

        ko.utils.domNodeDisposal.addDisposeCallback(element, function () {
            $(element).popover("destroy");
        });
        return options;
    }
};


ko.bindingHandlers.tooltip = {
    init: function(element, valueAccessor) {
        var local = ko.utils.unwrapObservable(valueAccessor()),
            options = {};

        ko.utils.extend(options, ko.bindingHandlers.tooltip.options);
        ko.utils.extend(options, local);

        $(element).tooltip(options);

        ko.utils.domNodeDisposal.addDisposeCallback(element, function() {
            $(element).tooltip("destroy");
        });
    },
    update: function (element, valueAccessor) {

        var $element = $(element);
        $element.tooltip('destroy');

        var local = ko.utils.unwrapObservable(valueAccessor()),
            options = {};

        ko.utils.extend(options, ko.bindingHandlers.tooltip.options);
        ko.utils.extend(options, local);

        $(element).tooltip(options);

        ko.utils.domNodeDisposal.addDisposeCallback(element, function() {
            $(element).tooltip("destroy");
        });

    },
    options: {
        placement: "right",
        trigger: "hover",
        html: true,
        delay: {
            show: 250
        }
    }
};

ko.bindingHandlers.independentlyValidated = {
    init: function (element, valueAccessor) {
        $(element).addClass('validationEngineContainer');
        $(element).find('thead').attr('data-validation-engine', 'validate'); // Horrible hack.
        $(element).validationEngine('attach', {scroll: false});
    }
};

ko.bindingHandlers.validateOnClick = {
    init: function (element, valueAccessor) {
        var value = valueAccessor(),
            options = {
                callback: false,
                selector: "button"
            };

        if(typeof value === 'function') {
            $.extend(options,{
                callback: value
            });
        } else if(typeof value === 'object') {
            $.extend(options, value);
        }

        $(element).validationEngine('attach', {scroll: false});

        $(element).find(options.selector).on('click', function () {
            options.callback && options.callback($(element).validationEngine('validate'));
        });
    }
};


ko.bindingHandlers.activityProgress = {
    update: function (element, valueAccessor) {
        var progressValue = ko.utils.unwrapObservable(valueAccessor());

        for (progress in ACTIVITY_PROGRESS_CLASSES) {
            ko.utils.toggleDomNodeCssClass(element, ACTIVITY_PROGRESS_CLASSES[progress], progress === progressValue);
        }
    }
}

ko.bindingHandlers.numeric = {
    init: function (element, valueAccessor) {
        $(element).on("keydown", function (event) {
            // Allow: backspace, delete, tab, escape, and enter
            if (event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 27 || event.keyCode == 13 ||
                    // Allow: Ctrl+A
                (event.keyCode == 65 && event.ctrlKey === true) ||
                    // Allow: . ,
                (event.keyCode == 190 || event.keyCode == 110) ||
                    // Allow: home, end, left, right
                (event.keyCode >= 35 && event.keyCode <= 39)) {
                // let it happen, don't do anything
                return;
            }
            else {
                // Ensure that it is a number and stop the keypress
                if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105)) {
                    event.preventDefault();
                }
            }
        });
    }
};

ko.bindingHandlers.slideVisible = {
    init: function (element, valueAccessor) {
        // Initially set the element to be instantly visible/hidden depending on the value
        var value = valueAccessor();
        $(element).toggle(ko.unwrap(value)); // Use "unwrapObservable" so we can handle values that may or may not be observable
    },
    update: function (element, valueAccessor, allBindings) {
        // Whenever the value subsequently changes, slowly fade the element in or out
        var value = valueAccessor(),
            duration = allBindings.get('slideDuration') || 600;
        ko.unwrap(value) ? $(element).slideDown(duration, 'linear') : $(element).slideUp(duration, 'linear');
    }
};

ko.bindingHandlers.booleanValue = {
    'after': ['options', 'foreach'],
    init: function (element, valueAccessor, allBindingsAccessor) {
        var observable = valueAccessor(),
            interceptor = ko.computed({
                read: function () {
                    return (observable() !== undefined ? observable().toString() : undefined);
                },
                write: function (newValue) {
                    observable(newValue === "true");
                }
            });

        ko.applyBindingsToNode(element, {value: interceptor});
    }
};

ko.bindingHandlers.onClickShowTab = {
    'init': function (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
        var originalFunction = valueAccessor();
        var newValueAccesssor = function () {
            return function () {
                var tabId = ko.utils.unwrapObservable(allBindingsAccessor().tabId);
                if (tabId) $(tabId).tab('show');
                originalFunction.apply(viewModel, arguments);
            }
        }
        ko.bindingHandlers.click.init(element, newValueAccesssor, allBindingsAccessor, viewModel, bindingContext);
    }
};


/**
 * Handles tab selection / redirect.
 * If url is empty & tabId is set then initiates tab selection
 * If url is set then initiates redirect
 *
 * Example: data-bind="showTabOrRedirect: { url: '', tabId: '#activities-tab'}"
 */
ko.bindingHandlers.showTabOrRedirect = {
    'init': function (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
        var newValueAccesssor = function () {
            return function () {
                var options = ko.utils.unwrapObservable(valueAccessor());
                if (options.url == '' && options.tabId) {
                    $(options.tabId).tab('show');
                } else if (options.url != '') {
                    window.location.href = options.url;
                }
            }
        };
        ko.bindingHandlers.click.init(element, newValueAccesssor, allBindingsAccessor, viewModel, bindingContext);
    }
};


ko.bindingHandlers.stagedImageUpload = {
    init: function (element, valueAccessor, allBindings, viewModel, bindingContext) {

        var defaultConfig = {
            maxWidth: 300,
            minWidth: 150,
            minHeight: 150,
            maxHeight: 300,
            previewSelector: '.preview'
        };
        var size = ko.observable();
        var progress = ko.observable();
        var error = ko.observable();
        var complete = ko.observable(true);

        var uploadProperties = {
            size: size,
            progress: progress,
            error: error,
            complete: complete
        };
        var innerContext = bindingContext.createChildContext(bindingContext);
        ko.utils.extend(innerContext, uploadProperties);

        var target = valueAccessor();
        var $elem = $(element);
        var role = $elem.data('role');
        var ownerKey = $elem.data('owner-type');
        var ownerValue = $elem.data('owner-id');
        var url = $elem.data('url');
        var owner = {};
        owner[ownerKey] = ownerValue;
        var config = {
            url: url,
            role: role,
            owner: owner
        };
        config = $.extend({}, defaultConfig, config);

        // Expected to be a ko.observableArray
        $(element).fileupload({
            url: config.url,
            autoUpload: true,
            forceIframeTransport: true
        }).on('fileuploadadd', function (e, data) {
            complete(false);
            progress(1);
        }).on('fileuploadprocessalways', function (e, data) {
            if (data.files[0].preview) {
                if (config.previewSelector !== undefined) {
                    var previewElem = $(element).parent().find(config.previewSelector);
                    previewElem.append(data.files[0].preview);
                }
            }
        }).on('fileuploadprogressall', function (e, data) {
            progress(Math.floor(data.loaded / data.total * 100));
            size(data.total);
        }).on('fileuploaddone', function (e, data) {

            var resultText = $('pre', data.result).text();
            var result = $.parseJSON(resultText);

            if (!result) {
                result = {};
                error('No response from server');
            }

            if (result.files[0]) {
                target.push(ko.bindingHandlers.stagedImageUpload.toDocument(result.files[0], config));
                complete(true);
            }
            else {
                error(result.error);
            }

        }).on('fileuploadfail', function (e, data) {
            error(data.errorThrown);
        });

        ko.applyBindingsToDescendants(innerContext, element);

        return {controlsDescendantBindings: true};
    },
    toDocument: function (f, config) {
        // same logic as projects.js for determining type
        var type;
        if (config.role == 'methodDoc') {
            if (f.type) {
                var ftype = file.type.split('/');
                if (ftype) {
                    type = ftype[0];
                }
            }
            else if (f.name) {
                var ftype = f.name.split('.').pop();

                var imageTypes = ['gif','jpeg', 'jpg', 'png', 'tif', 'tiff'];
                if ($.inArray(ftype.toLowerCase(), imageTypes) > -1) {
                    type = 'image';
                }
                else {
                    type = 'document';
                }
            }
        }
        else {
            type = 'image';
        }

        var data = {
            thumbnailUrl: f.thumbnail_url,
            url: f.url,
            contentType: f.contentType,
            filename: f.name,
            filesize: f.size,
            dateTaken: f.isoDate,
            lat: f.decimalLatitude,
            lng: f.decimalLongitude,
            name: f.name,
            type: type,
            role: config.role
        };

        return $.extend({}, data, config.owner);
    }
};

/*
 * Fused Autocomplete supports two versions of autocomplete (original autocomplete implementation by Jorn Zaefferer and jquery_ui)
 * Expects three parameters source, name and guid.
 * Ajax response lists needs name attribute.
 * Doco url: http://bassistance.de/jquery-plugins/jquery-plugin-autocomplete/
 * Note: Autocomplete implementation by Jorn Zaefferer is now been deprecated and its been migrated to jquery_ui.
 *
 */

ko.bindingHandlers.fusedAutocomplete = {

    init: function (element, params) {
        var params = params();
        var options = {};
        var url = ko.utils.unwrapObservable(params.source);
        options.source = function (request, response) {
            $(element).addClass("ac_loading");
            $.ajax({
                url: url,
                dataType: 'json',
                data: {q: request.term},
                success: function (data) {
                    var items = $.map(data.autoCompleteList, function (item) {
                        return {
                            label: item.name,
                            value: item.name,
                            source: item
                        }
                    });
                    response(items);

                },
                error: function () {
                    items = [{
                        label: "Error during species lookup",
                        value: request.term,
                        source: {listId: 'error-unmatched', name: request.term}
                    }];
                    response(items);
                },
                complete: function () {
                    $(element).removeClass("ac_loading");
                }
            });
        };
        options.select = function (event, ui) {
            var selectedItem = ui.item;
            params.name(selectedItem.source.name);
            params.guid(selectedItem.source.guid);
            params.scientificName(selectedItem.source.scientificName);
            params.commonName(selectedItem.source.commonName);
        };

        if (!$(element).autocomplete(options).data("ui-autocomplete")) {
            // Fall back mechanism to handle deprecated version of autocomplete.
            var options = {}, unknown = {
                guid: '',
                name: '(Unmatched taxon)',
                commonName: '',
                scientificName: '',
                value: element.value
            };
            options.source = url;
            options.matchSubset = false;
            options.formatItem = function (row, i, n) {
                return row.name;
            };
            options.highlight = false;
            options.parse = function (data) {
                var rows = new Array();
                if (params.matchUnknown) {
                    unknown.value = element.value;
                    unknown.name = element.value + ' (Unmatched taxon)'
                    rows.push({
                        data: unknown,
                        value: unknown,
                        result: unknown.name
                    })
                }

                data = data.autoCompleteList;
                for (var i = 0; i < data.length; i++) {
                    rows.push({
                        data: data[i],
                        value: data[i],
                        result: data[i].name
                    });
                }
                return rows;
            };

            $(element).autocomplete(options.source, options).result(function (event, data, formatted) {
                if (data) {
                    params.guid(data.guid);
                    params.name(data.name);
                    if (params.commonName && params.commonName != undefined) {
                        params.commonName(data.commonName);
                    }
                    if (params.scientificName && params.scientificName != undefined) {
                        params.scientificName(data.scientificName);
                    }
                }
            });
        }
    }
};

ko.bindingHandlers.autocompleteFromList = {
    init: function (element, params) {
        var params = params();
        var options = {};
        var data = ko.utils.unwrapObservable(params.data);
        options.select = function (event, ui) {
            params.select(ui)
            $(element).val('')
        };
        $(element).autocomplete(data, options).result(options.select)
    }
}

ko.bindingHandlers.autocomplete = {
    init: function (element, params) {
        var param = params();
        var url = ko.utils.unwrapObservable(param.url);
        var list = ko.utils.unwrapObservable(param.listId);
        var valueCallback = ko.utils.unwrapObservable(param.valueChangeCallback)
        var options = {};

        options.source = function (request, response) {
            $(element).addClass("ac_loading");

            if (valueCallback !== undefined) {
                valueCallback(request.term);
            }
            var data = {q: request.term};
            if (list) {
                $.extend(data, {druid: list});
            }
            $.ajax({
                url: url,
                dataType: 'json',
                data: data,
                success: function (data) {
                    var items = $.map(data.autoCompleteList, function (item) {
                        return {
                            label: item.name,
                            value: item.name,
                            source: item
                        }
                    });
                    items = [{
                        label: "Missing or unidentified species",
                        value: request.term,
                        source: {listId: 'unmatched', name: request.term}
                    }].concat(items);
                    response(items);

                },
                error: function () {
                    items = [{
                        label: "Error during species lookup",
                        value: request.term,
                        source: {listId: 'error-unmatched', name: request.term}
                    }];
                    response(items);
                },
                complete: function () {
                    $(element).removeClass("ac_loading");
                }
            });
        };
        options.select = function (event, ui) {
            ko.utils.unwrapObservable(param.result)(event, ui.item.source);
        };

        var render = ko.utils.unwrapObservable(param.render);
        if (render && $(element).autocomplete(options).data("ui-autocomplete")) {

            $(element).autocomplete(options).data("ui-autocomplete")._renderItem = function (ul, item) {
                var result = $('<li></li>').html(render(item.source));
                return result.appendTo(ul);

            };
        }
        else {
            $(element).autocomplete(options);
        }
    }
};

/*
 This binding allows text values to be displayed as simple text that can be clicked to access
 an input control for in-place editing.
 */
ko.bindingHandlers.clickToEdit = {
    init: function (element, valueAccessor) {
        var observable = valueAccessor(),
            link = document.createElement("a"),
            input = document.createElement("input"),
            dblclick = $(element).attr('data-edit-on-dblclick'),
            userPrompt = $(element).attr('data-prompt'),
            prompt = userPrompt || (dblclick ? 'Double-click to edit' : 'Click to edit'),
            linkBindings;

        // add any classes specified for the link element
        $(link).addClass($(element).attr('data-link-class'));
        // add any classes specified for the input element
        $(input).addClass($(element).attr('data-input-class'));

        element.appendChild(link);
        element.appendChild(input);

        observable.editing = ko.observable(false);
        observable.stopEditing = function () {
            $(input).blur();
            observable.editing(false)
        };

        linkBindings = {
            text: ko.computed(function () {
                // todo: style default text as grey
                var value = ko.utils.unwrapObservable(observable);
                return value !== "" ? value : prompt;
            }),
            visible: ko.computed(function () {
                return !observable.editing();
            })
        };

        // bind to either the click or dblclick event
        if (dblclick) {
            linkBindings.event = {dblclick: observable.editing.bind(null, true)};
        } else {
            linkBindings.click = observable.editing.bind(null, true);
        }

        ko.applyBindingsToNode(link, linkBindings);

        ko.applyBindingsToNode(input, {
            value: observable,
            visible: observable.editing,
            hasfocus: observable.editing
        });

        // quit editing on enter key
        $(input).keydown(function (e) {
            if (e.which === 13) {
                observable.stopEditing();
            }
        });
    }
};

/*
 This binding allows small non-negative integers in the model to be displayed as a number of ticks
 and edited by spinner buttons.
 */
ko.bindingHandlers.ticks = {
    init: function (element, valueAccessor) {
        var observable = valueAccessor(),
            $parent = $(element).parent(),
            $buttons,
            $widget = $('<div class="tick-controls btn-group btn-group-vertical"></div>');

        $parent.css('padding', '4px');
        $widget.append($('<button class="up btn btn-mini"><i class="icon-chevron-up"></i></button>'));
        $widget.append($('<button class="down btn btn-mini"><i class="icon-chevron-down"></i></button>'));
        $parent.append($widget);
        $buttons = $parent.find('button');

        $buttons.hide();

        ko.utils.registerEventHandler($parent, "mouseover", function () {
            $buttons.show();
        });

        ko.utils.registerEventHandler($parent, "mouseout", function () {
            $buttons.hide();
        });

        ko.utils.registerEventHandler($buttons, "click", function () {
            var isUp = $(this).hasClass('up'),
                value = Number(observable());
            if (isNaN(value)) {
                value = 0;
            }

            if (isUp) {
                observable("" + (value + 1));
            } else {
                if (value > 0) {
                    observable("" + (value - 1));
                }
            }
            return false;
        });
    },
    update: function (element, valueAccessor) {
        var observable = valueAccessor(), value,
            tick = '<i class="icon-ok"></i>', ticks = "";
        if (observable) {
            value = Number(ko.utils.unwrapObservable(observable));
            if (isNaN(value)) {
                $(element).html("");
            } else {
                //$(element).html(value);
                $(element).empty();
                for (i = 0; i < value; i++) {
                    ticks += tick;
                }
                $(element).html(ticks);
            }
        }
    }
};

ko.bindingHandlers.fileUploadNoImage = {
    init: function (element, options) {

        var defaults = {autoUpload: true, forceIframeTransport: true};
        var settings = {};
        $.extend(settings, defaults, options());
        $(element).fileupload(settings);
    }
};

// A handy binding to iterate over the properties of an object.
ko.bindingHandlers.foreachprop = {
    transformObject: function (obj) {
        var properties = [];
        for (var key in obj) {
            if (obj.hasOwnProperty(key)) {
                properties.push({key: key, value: obj[key]});
            }
        }
        return properties;
    },
    init: function (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
        var value = ko.utils.unwrapObservable(valueAccessor()),
            properties = ko.bindingHandlers.foreachprop.transformObject(value);
        ko.applyBindingsToNode(element, {foreach: properties});
        return {controlsDescendantBindings: true};
    }
};

// Compares this column to the current sort parameters and displays the appropriate sort icons.
// If this is the column that the model is currently sorted by, then shows an up or down icon
//  depending on the current sort order.
// Usage example: <th data-bind="sortIcon:sortParamsObject,click:sortBy" data-column="type">Type</th>
// The sortIcon binding takes an object or observable that contains a 'by' property and an 'order' property.
// The data-column attr defines the model value that the column holds. This is compared to the
//  current sort by value to see if this is the active column.
ko.bindingHandlers.sortIcon = {
    update: function (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
        var $element = $(element),
            name = $element.data('column'),
            $icon = $element.find('i'),
            className = "icon-blank",
            sortParams = ko.utils.unwrapObservable(valueAccessor());
        // see if this is the active sort column
        if (sortParams.by() === name) {
            // and if so, choose an icon based on sort order
            className = sortParams.order() === 'desc' ? 'icon-chevron-down' : 'icon-chevron-up';
        }
        // insert the icon markup if it doesn't exist
        if ($icon.length === 0) {
            $icon = $("<i class='icon-blank'></i>").appendTo($element);
        }
        // set the computed class
        $icon.removeClass('icon-chevron-down').removeClass('icon-chevron-up').removeClass('icon-blank').addClass(className);
    }
};

/**
 * custom binding to remove data from observable array.
 * @type {{init: Function}}
 */
ko.bindingHandlers.removeFromArray = {
    init: function (element, valueAccessor, allBindings, viewModel, bindingContext) {
        $(element).click(function () {
            var array = valueAccessor();
            array.remove && array.remove(bindingContext.$data);
            bindingContext.$data.remove && bindingContext.$data.remove();
        })
    }
}

/**
 * custom handler for fancybox plugin.
 * @type {{init: Function}}
 * config to fancybox plugin can be passed to custom binding using knockout syntax.
 * eg:
 * <a href="" data-bind="fancybox: {nextEffect:'fade', preload:0, 'prevEffect':'fade'}"></a>
 *
 * or
 *
 * <div data-bind="fancybox: {nextEffect:'fade', preload:0, 'prevEffect':'fade'}">
 *     <a href="..." target="fancybox">...</a>
 *     <a href="..." target="fancybox">...</a>
 * </div>
 */
ko.bindingHandlers.fancybox = {
  init: function(element, valueAccessor, allBindings, viewModel, bindingContext){
    var config = valueAccessor(),
        $elem = $(element);
    // suppress auto scroll on clicking image to view in fancybox
    config = $.extend({
      width: 700,
      height: 500,
      // fix for bringing the modal dialog to focus to make it accessible via keyboard.
      afterShow: function(){
        $('.fancybox-wrap').focus();
      },
      helpers: {
        title: {
          type : 'inside',
          position : 'bottom'
        },
        overlay: {
          locked: false
        }
      }
    }, config);

    if($elem.attr('target') == 'fancybox'){
      $elem.fancybox(config);
    }else{
      $elem.find('a[target=fancybox]').fancybox(config);
    }
  }
};

/**
 * Makes content appear on a single line until clicked to expand to it's full size.
 * If the data type is an array it will be rendered as comma separated values.
 */
ko.bindingHandlers.expandable = {

    'init': function() {
        var self = ko.bindingHandlers.expandable;
        self.truncate = function(cellWidth, originalTextWidth, originalText) {
            var fractionThatFits = cellWidth/originalTextWidth,
                truncationPoint = Math.floor(originalText.length * fractionThatFits) - 6;
            return originalText.substr(0,truncationPoint) + '...';
        };
    },
    'update':function(element, valueAccessor) {
        var self = ko.bindingHandlers.expandable;

        var text = ko.utils.unwrapObservable(valueAccessor());
        if ($.isArray(text)) {
            text = text.join(",");
        }
        var $element = $(element),
            textWidth = $element.textWidth(text),
            cellWidth = $element.availableWidth();

        $element.removeClass('truncated');
        var needsTruncation = cellWidth > 0 && textWidth > cellWidth;
        if (!needsTruncation) {
            $element.html(text);
            return;
        }

        var anchor = $('<a/>');
        anchor.click(function() {
            toggleTruncate($element);
        });
        $element.empty();
        $element.html("");
        $element.append(anchor);



        var toggleTruncate = function($element) {
            var truncate = !$element.hasClass('truncated');
            $element.toggleClass('truncated');
            var anchor = $element.find("a");
            if (truncate) {
                $element.attr('title', text);
                anchor.html(self.truncate(cellWidth, textWidth, text));
            } else {
                anchor.html(text);
                $element.removeAttr('title');
            }
        };
        toggleTruncate($element);

    }
};

/**
 * Get image of selected species
 */
ko.bindingHandlers.getImage = {
    update: function (element, valueAccessor, allBindings, viewModel) {
        if(viewModel.guid()){
            viewModel.transients.image('');

            $.ajax({
                url: fcConfig.bieUrl + '/ws/species/guids/bulklookup',
                method: 'post',
                dataType: 'json',
                data: JSON.stringify([ viewModel.guid() ]),
                contentType: 'application/json',
                success: function (data) {
                    var image = data.searchDTOList[0] && data.searchDTOList[0].thumbnailUrl;
                    viewModel.transients.image(image);
                }
            });
        }
    }
};

/**
 * Execute handler when enter key is pressed on input tag or similar elements
 * return true from handler to allow default action.
 */
ko.bindingHandlers.enter = {
    init: function (element, valueAccessor, allBindings, viewModel, bindingContext) {
        var handler = valueAccessor(),
            newHandler = function (viewModel, event) {
                var result = handler.apply(viewModel, arguments);
                return result || true;
            };
        var newValueAccessor = function() {
            var result = {};
            result['keypress'] = function (viewModel, event) {
                if (event.which == 13) {
                    return newHandler.apply(viewModel, arguments);
                }

                // return true from handler to allow default action. Otherwise, input will not show pressed key.
                return true;
            };

            return result;
        };

        return ko.bindingHandlers['event']['init'].call(this, element, newValueAccessor, allBindings, viewModel, bindingContext);
    }
};

/**
 * Dismiss a bootstrap modal dialog when subscriber passed to it is set to true.
 */
ko.bindingHandlers.dismissModal = {
    update: function (element, valueAccessor, allBindings, viewModel, bindingContext) {
        var value = valueAccessor(),
            $element = $(element);

        if(ko.unwrap(value)){
            $element.modal('hide')
        }
    }
};

/**
 * Hightlight an element on the
 */
ko.bindingHandlers.highlight = {
    update: function (element, valueAccessor, allBindings) {
        var value = valueAccessor(),
            $element = $(element),
            speed = allBindings.get('highlightDuration') || 1000;

        if(ko.unwrap(value)){
            setTimeout(function () {
                $element.effect('highlight', speed);
            }, 1000);
        }
    }
};

ko.bindingHandlers.validateObservable = {
    init: function (element, valueAccessor, allBindings, viewModel, bindingContext) {
        if (!element.type && jQuery.valHooks) {
            var uid = generateRandomId(),
                valueFunction = valueAccessor();

            element.type = uid;
            jQuery.valHooks[uid] = {
                get: function modelValidator() {
                    var value = ko.utils.unwrapObservable(valueFunction);
                    if(value instanceof Array){
                        return value.length == 0 ? "" : "Validation successful"
                    } else {
                        return [undefined, null, ""].indexOf(value) >= 0 ? "" : "Validation successful";
                    }
                }
            }
        } else {
            throw "KO error: validateObservable binding cannot be used on an input element or any element which has 'type' property."
        }
    }
};

function randomMax8HexChars() {
    return (((1 + Math.random()) * 0x100000000) | 0).toString(16).substring(1);
}
function generateRandomId() {
    return randomMax8HexChars() + randomMax8HexChars();
}

// the following code handles resize-sensitive truncation of the description field
$.fn.textWidth = function(text, font) {
    if (!$.fn.textWidth.fakeEl) $.fn.textWidth.fakeEl = $('<span>').hide().appendTo(document.body);
    $.fn.textWidth.fakeEl.html(text || this.val() || this.text()).css('font', font || this.css('font'));
    return $.fn.textWidth.fakeEl.width();
};

$.fn.availableWidth = function() {
    if (this.css('display').match(/inline/)) {
        var siblingWidth = 0;
        this.siblings().each(function(i, sibling) {
            var $sibling = $(sibling);
            if ($sibling.css('display').match(/inline/)) {
                siblingWidth += $sibling.width();
            }
        });
        return this.parent().width() - siblingWidth;
    }
    else {
        return this.width();
    }
};