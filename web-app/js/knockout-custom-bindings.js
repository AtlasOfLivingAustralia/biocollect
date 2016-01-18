/**
 * Attaches a bootstrap popover to the bound element.  The details for the popover should be supplied as the
 * value of this binding.
 * e.g.  <a href="#" data-bind="popover: {title:"Popover title", content:"Popover content"}>My link with popover</a>
 *
 * The content and title must be supplied, other popover options have defaults.
 *
 */
ko.bindingHandlers.popover = {

  init: function(element, valueAccessor) {
    ko.bindingHandlers.popover.initPopover(element, valueAccessor);
  },
  update: function(element, valueAccessor) {

    var $element = $(element);
    $element.popover('destroy');
    var options = ko.bindingHandlers.popover.initPopover(element, valueAccessor);
    if (options.autoShow) {
      if ($element.data('firstPopover') === false) {
        $element.popover('show');
        $('body').on('click', function(e) {

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
    trigger: "hover"
  },

  initPopover: function(element, valueAccessor) {
    var options = ko.utils.unwrapObservable(valueAccessor());

    var combinedOptions = ko.utils.extend({}, ko.bindingHandlers.popover.defaultOptions);
    var content = ko.utils.unwrapObservable(options.content);
    ko.utils.extend(combinedOptions, options);
    combinedOptions.description = content;

    $(element).popover(combinedOptions);

    ko.utils.domNodeDisposal.addDisposeCallback(element, function() {
      $(element).popover("destroy");
    });
    return options;
  }
};

ko.bindingHandlers.independentlyValidated = {
  init: function(element, valueAccessor) {
    $(element).addClass('validationEngineContainer');
    $(element).find('thead').attr('data-validation-engine', 'validate'); // Horrible hack.
    $(element).validationEngine('attach', {scroll:false});
  }
};


ko.bindingHandlers.activityProgress = {
  update: function(element, valueAccessor) {
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
  init: function(element, valueAccessor) {
    // Initially set the element to be instantly visible/hidden depending on the value
    var value = valueAccessor();
    $(element).toggle(ko.unwrap(value)); // Use "unwrapObservable" so we can handle values that may or may not be observable
  },
  update: function(element, valueAccessor) {
    // Whenever the value subsequently changes, slowly fade the element in or out
    var value = valueAccessor();
    ko.unwrap(value) ? $(element).slideDown() : $(element).slideUp();
  }
};

ko.bindingHandlers.booleanValue = {
  'after': ['options', 'foreach'],
  init: function(element, valueAccessor, allBindingsAccessor) {
    var observable = valueAccessor(),
        interceptor = ko.computed({
          read: function() {
            return (observable() !== undefined ? observable().toString() : undefined);
          },
          write: function(newValue) {
            observable(newValue === "true");
          }
        });

    ko.applyBindingsToNode(element, { value: interceptor });
  }
};

ko.bindingHandlers.onClickShowTab = {
  'init': function (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
    var originalFunction = valueAccessor();
    var newValueAccesssor = function() {
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
    var newValueAccesssor = function() {
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
  init: function(element, valueAccessor, allBindings, viewModel, bindingContext) {

    var defaultConfig = {
      maxWidth: 300,
      minWidth:150,
      minHeight:150,
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
      error:error,
      complete:complete
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
      url:url,
      role: role,
      owner:owner
    };
    config = $.extend({}, defaultConfig, config);

    // Expected to be a ko.observableArray
    $(element).fileupload({
      url:config.url,
      autoUpload:true,
      forceIframeTransport: true
    }).on('fileuploadadd', function(e, data) {
      complete(false);
      progress(1);
    }).on('fileuploadprocessalways', function(e, data) {
      if (data.files[0].preview) {
        if (config.previewSelector !== undefined) {
          var previewElem = $(element).parent().find(config.previewSelector);
          previewElem.append(data.files[0].preview);
        }
      }
    }).on('fileuploadprogressall', function(e, data) {
      progress(Math.floor(data.loaded / data.total * 100));
      size(data.total);
    }).on('fileuploaddone', function(e, data) {

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

    }).on('fileuploadfail', function(e, data) {
      error(data.errorThrown);
    });

    ko.applyBindingsToDescendants(innerContext, element);

    return { controlsDescendantBindings: true };
  },
  toDocument:function(f, config) {

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
      type: 'image',
      role:config.role
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
    options.source = function(request, response) {
      $(element).addClass("ac_loading");
      $.ajax({
        url: url,
        dataType:'json',
        data: {q:request.term},
        success: function(data) {
          var items = $.map(data.autoCompleteList, function(item) {
            return {
              label:item.name,
              value: item.name,
              source: item
            }
          });
          response(items);

        },
        error: function() {
          items = [{label:"Error during species lookup", value:request.term, source: {listId:'error-unmatched', name: request.term}}];
          response(items);
        },
        complete: function() {
          $(element).removeClass("ac_loading");
        }
      });
    };
    options.select = function(event, ui) {
      var selectedItem = ui.item;
      params.name(selectedItem.source.name);
      params.guid(selectedItem.source.guid);
    };

    if(!$(element).autocomplete(options).data("ui-autocomplete")){
      // Fall back mechanism to handle deprecated version of autocomplete.
      var options = {}, unknown = {
        guid: '',
        name: 'Unknown species',
        value: element.value
      };
      options.source = url;
      options.matchSubset = false;
      options.formatItem = function(row, i, n) {
        return row.name;
      };
      options.highlight = false;
      options.parse = function(data) {
        var rows = new Array();
        if(params.matchUnknown){
          unknown.value = element.value;
          rows.push({
              data: unknown,
              value: unknown,
              result: unknown.value
          })
        }

        data = data.autoCompleteList;
        for(var i=0; i < data.length; i++) {
          rows.push({
            data: data[i],
            value: data[i],
            result: data[i].name
          });
        }
        return rows;
      };

      $(element).autocomplete(options.source, options).result(function(event, data, formatted) {
        if (data) {
          if(data.name == unknown.name){
            params.name(data.value);
          } else {
            params.name(data.name);
          }
          params.guid(data.guid);
        }
      });
    }
  }
};

ko.bindingHandlers.autocomplete = {
  init: function (element, params) {
    var param = params();
    var url = ko.utils.unwrapObservable(param.url);
    var list = ko.utils.unwrapObservable(param.listId);
    var valueCallback = ko.utils.unwrapObservable(param.valueChangeCallback)
    var options = {};

    options.source = function(request, response) {
      $(element).addClass("ac_loading");

      if (valueCallback !== undefined) {
        valueCallback(request.term);
      }
      var data = {q:request.term};
      if (list) {
        $.extend(data, {druid: list});
      }
      $.ajax({
        url: url,
        dataType:'json',
        data: data,
        success: function(data) {
          var items = $.map(data.autoCompleteList, function(item) {
            return {
              label:item.name,
              value: item.name,
              source: item
            }
          });
          items = [{label:"Missing or unidentified species", value:request.term, source: {listId:'unmatched', name: request.term}}].concat(items);
          response(items);

        },
        error: function() {
          items = [{label:"Error during species lookup", value:request.term, source: {listId:'error-unmatched', name: request.term}}];
          response(items);
        },
        complete: function() {
          $(element).removeClass("ac_loading");
        }
      });
    };
    options.select = function(event, ui) {
      ko.utils.unwrapObservable(param.result)(event, ui.item.source);
    };

    var render = ko.utils.unwrapObservable(param.render);
    if (render && $(element).autocomplete(options).data("ui-autocomplete")) {

      $(element).autocomplete(options).data("ui-autocomplete")._renderItem = function(ul, item) {
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
  init: function(element, valueAccessor) {
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
      text: ko.computed(function() {
        // todo: style default text as grey
        var value = ko.utils.unwrapObservable(observable);
        return value !== "" ? value : prompt;
      }),
      visible: ko.computed(function() {
        return !observable.editing();
      })
    };

    // bind to either the click or dblclick event
    if (dblclick) {
      linkBindings.event = { dblclick: observable.editing.bind(null, true) };
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
    $(input).keydown(function(e) {
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
  init: function(element, valueAccessor) {
    var observable = valueAccessor(),
        $parent = $(element).parent(),
        $buttons,
        $widget = $('<div class="tick-controls btn-group btn-group-vertical"></div>');

    $parent.css('padding','4px');
    $widget.append($('<button class="up btn btn-mini"><i class="icon-chevron-up"></i></button>'));
    $widget.append($('<button class="down btn btn-mini"><i class="icon-chevron-down"></i></button>'));
    $parent.append($widget);
    $buttons = $parent.find('button');

    $buttons.hide();

    ko.utils.registerEventHandler($parent, "mouseover", function() {
      $buttons.show();
    });

    ko.utils.registerEventHandler($parent, "mouseout", function() {
      $buttons.hide();
    });

    ko.utils.registerEventHandler($buttons, "click", function() {
      var isUp = $(this).hasClass('up'),
          value = Number(observable());
      if (isNaN(value)) { value = 0; }

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
  update: function(element, valueAccessor) {
    var observable = valueAccessor(), value,
        tick = '<i class="icon-ok"></i>', ticks = "";
    if (observable) {
      value = Number(ko.utils.unwrapObservable(observable));
      if (isNaN(value)) {
        $(element).html("");
      } else {
        //$(element).html(value);
        $(element).empty();
        for (i=0; i < value; i++) {
          ticks += tick;
        }
        $(element).html(ticks);
      }
    }
  }
};

ko.bindingHandlers.fileUploadNoImage = {
  init: function(element, options) {

    var defaults = {autoUpload:true, forceIframeTransport:true};
    var settings = {};
    $.extend(settings, defaults, options());
    $(element).fileupload(settings);
  }
}

// A handy binding to iterate over the properties of an object.
ko.bindingHandlers.foreachprop = {
  transformObject: function (obj) {
    var properties = [];
    for (var key in obj) {
      if (obj.hasOwnProperty(key)) {
        properties.push({ key: key, value: obj[key] });
      }
    }
    return properties;
  },
  init: function(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
    var value = ko.utils.unwrapObservable(valueAccessor()),
        properties = ko.bindingHandlers.foreachprop.transformObject(value);
    ko.applyBindingsToNode(element, { foreach: properties });
    return { controlsDescendantBindings: true };
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
  update: function(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
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
  init: function(element, valueAccessor, allBindings, viewModel, bindingContext){
    $(element).click(function(){
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
 * eg:  <a href="fancybox: {nextEffect:'fade', preload:0, 'prevEffect':'fade'}"></a>
 */
ko.bindingHandlers.fancybox = {
  init: function(element, valueAccessor, allBindings, viewModel, bindingContext){
    var config = valueAccessor()
    // suppress auto scroll on clicking image to view in fancybox
    config = $.extend({
      helpers: {
        overlay: {
          locked: false
        }
      }
    }, config);
    $(element).fancybox(config);
  }
};