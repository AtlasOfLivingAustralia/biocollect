(function (window, $) {
  if (!$ || !window.bootstrap) {
    return;
  }

  var bootstrap = window.bootstrap;
  var Biocollect = window.Biocollect = window.Biocollect || {};

  function resolveElement(target) {
    if (!target) {
      return null;
    }
    if (target.jquery) {
      return target[0];
    }
    if (typeof target === 'string') {
      return document.querySelector(target);
    }
    return target;
  }

  function resolveElements(target) {
    if (!target) {
      return [];
    }
    if (target.jquery) {
      return target.toArray();
    }
    if (typeof target === 'string') {
      return Array.prototype.slice.call(document.querySelectorAll(target));
    }
    if (typeof NodeList !== 'undefined' && target instanceof NodeList) {
      return Array.prototype.slice.call(target);
    }
    if (Array.isArray(target)) {
      return target.map(resolveElement).filter(Boolean);
    }
    return [target];
  }

  function forEachElement(target, callback) {
    return resolveElements(target).map(function (element) {
      return callback(element);
    });
  }

  function getInstance(Constructor, element, options, action) {
    if (typeof action === 'string' && action === 'dispose') {
      return Constructor.getInstance(element);
    }
    return Constructor.getOrCreateInstance(element, options);
  }

  function invoke(instance, action) {
    if (instance && typeof instance[action] === 'function') {
      instance[action]();
    }
  }

  Biocollect.Bootstrap5 = {
    getCollapse: function (target, options) {
      var element = resolveElement(target);
      return element ? bootstrap.Collapse.getOrCreateInstance(element, options) : null;
    },
    showCollapse: function (target, options) {
      var instance = this.getCollapse(target, options);
      if (instance) {
        instance.show();
      }
      return instance;
    },
    hideCollapse: function (target) {
      var element = resolveElement(target);
      var instance = element ? bootstrap.Collapse.getInstance(element) : null;
      if (instance) {
        instance.hide();
      }
      return instance;
    },
    getModal: function (target, options) {
      var element = resolveElement(target);
      return element ? bootstrap.Modal.getOrCreateInstance(element, options) : null;
    },
    showModal: function (target, options) {
      var instance = this.getModal(target, options);
      if (instance) {
        instance.show();
      }
      return instance;
    },
    hideModal: function (target) {
      var element = resolveElement(target);
      var instance = element ? bootstrap.Modal.getInstance(element) : null;
      if (instance) {
        instance.hide();
      }
      return instance;
    },
    showTab: function (target) {
      var element = resolveElement(target);
      if (!element) {
        return null;
      }
      var instance = bootstrap.Tab.getOrCreateInstance(element);
      instance.show();
      return instance;
    },
    getTooltip: function (target, options) {
      var element = resolveElement(target);
      return element ? bootstrap.Tooltip.getOrCreateInstance(element, options) : null;
    },
    showTooltip: function (target, options) {
      var instance = this.getTooltip(target, options);
      if (instance) {
        instance.show();
      }
      return instance;
    },
    hideTooltip: function (target) {
      var element = resolveElement(target);
      var instance = element ? bootstrap.Tooltip.getInstance(element) : null;
      if (instance) {
        instance.hide();
      }
      return instance;
    },
    disposeTooltip: function (target) {
      var element = resolveElement(target);
      var instance = element ? bootstrap.Tooltip.getInstance(element) : null;
      if (instance) {
        instance.dispose();
      }
      return instance;
    },
    initTooltips: function (target, options) {
      return forEachElement(target, function (element) {
        return bootstrap.Tooltip.getOrCreateInstance(element, options);
      });
    },
    getPopover: function (target, options) {
      var element = resolveElement(target);
      return element ? bootstrap.Popover.getOrCreateInstance(element, options) : null;
    },
    showPopover: function (target, options) {
      var instance = this.getPopover(target, options);
      if (instance) {
        instance.show();
      }
      return instance;
    },
    hidePopover: function (target) {
      var element = resolveElement(target);
      var instance = element ? bootstrap.Popover.getInstance(element) : null;
      if (instance) {
        instance.hide();
      }
      return instance;
    },
    disposePopover: function (target) {
      var element = resolveElement(target);
      var instance = element ? bootstrap.Popover.getInstance(element) : null;
      if (instance) {
        instance.dispose();
      }
      return instance;
    },
    initPopovers: function (target, options) {
      return forEachElement(target, function (element) {
        return bootstrap.Popover.getOrCreateInstance(element, options);
      });
    }
  };

  $.fn.modal = function (configOrAction) {
    return this.each(function () {
      var options = typeof configOrAction === 'object' ? configOrAction : undefined;
      var action = typeof configOrAction === 'string' ? configOrAction : undefined;
      var instance = getInstance(bootstrap.Modal, this, options, action);

      if (!action) {
        if (!options || options.show !== false) {
          instance.show();
        }
        return;
      }

      invoke(instance, action);
    });
  };
  $.fn.modal.Constructor = bootstrap.Modal;
})(window, window.jQuery);