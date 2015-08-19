if (typeof jQuery !== 'undefined') {
	(function($) {
		$('#spinner').ajaxStart(function() {
			$(this).fadeIn();
		}).ajaxStop(function() {
			$(this).fadeOut();
		});
	})(jQuery);
}
// deprecated
$('#debug').click(function () {
    $(this).next().toggle();
});
// handles debug sections
$('.expandable-debug').each(function() {
    $(this).find('div,pre,ul').hide();
    $(this).find('h1,h2,h3,h4,h5')
        .css('cursor','pointer')
        .css('color','grey')
        .click(function () {
            $(this).next().toggle();
        })
        .hover(
            function () { $(this).css('text-decoration','underline') },
            function () { $(this).css('text-decoration','none') }
        );
    // pretty print sections with class pretty
    if (vkbeautify && typeof vkbeautify.json === 'function') {
        $(this).find('pre').each(function() {
            var value = $(this).html();
            if (value !== '') {
                try {
                    $(this).html(vkbeautify.json(value));
                } catch (e) {
                    $(this).html(value);
                }
            }
        });
    }
});

// returns blank string if the property is undefined, else the value
function orBlank(v) {
    return v === undefined ? '' : v;
}
function orFalse(v) {
    return v === undefined ? false : v;
}
function orZero(v) {
    return v === undefined ? 0 : v;
}
function orEmptyArray(v) {
    return v === undefined ? [] : v;
}

function fixUrl(url) {
    return typeof url == 'string' && url.indexOf("://") < 0? ("http://" + url): url;
}

function exists(parent, prop) {
    if(parent === undefined)
        return '';
    if(parent == null)
        return '';
    if(parent[prop] === undefined)
        return '';
    if(parent[prop] == null)
        return '';
    if(ko.isObservable(parent[prop])){
        return parent[prop]();
    }
    return parent[prop];
}

function neat_number (number, decimals) {
    var str = number_format(number, decimals);
    if (str.indexOf('.') === -1) {
        return str;
    }
    // trim trailing zeros beyond the decimal point
    while (str[str.length-1] === '0') {
        str = str.substr(0, str.length - 1);
    }
    if (str[str.length-1] === '.') {
        str = str.substr(0, str.length - 1);
    }
    return str;
}

function number_format (number, decimals, dec_point, thousands_sep) {
    // http://kevin.vanzonneveld.net
    // +   original by: Jonas Raoni Soares Silva (http://www.jsfromhell.com)
    // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    // +     bugfix by: Michael White (http://getsprink.com)
    // +     bugfix by: Benjamin Lupton
    // +     bugfix by: Allan Jensen (http://www.winternet.no)
    // +    revised by: Jonas Raoni Soares Silva (http://www.jsfromhell.com)
    // +     bugfix by: Howard Yeend
    // +    revised by: Luke Smith (http://lucassmith.name)
    // +     bugfix by: Diogo Resende
    // +     bugfix by: Rival
    // +      input by: Kheang Hok Chin (http://www.distantia.ca/)
    // +   improved by: davook
    // +   improved by: Brett Zamir (http://brett-zamir.me)
    // +      input by: Jay Klehr
    // +   improved by: Brett Zamir (http://brett-zamir.me)
    // +      input by: Amir Habibi (http://www.residence-mixte.com/)
    // +     bugfix by: Brett Zamir (http://brett-zamir.me)
    // +   improved by: Theriault
    // +      input by: Amirouche
    // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    // *     example 1: number_format(1234.56);
    // *     returns 1: '1,235'
    // *     example 2: number_format(1234.56, 2, ',', ' ');
    // *     returns 2: '1 234,56'
    // *     example 3: number_format(1234.5678, 2, '.', '');
    // *     returns 3: '1234.57'
    // *     example 4: number_format(67, 2, ',', '.');
    // *     returns 4: '67,00'
    // *     example 5: number_format(1000);
    // *     returns 5: '1,000'
    // *     example 6: number_format(67.311, 2);
    // *     returns 6: '67.31'
    // *     example 7: number_format(1000.55, 1);
    // *     returns 7: '1,000.6'
    // *     example 8: number_format(67000, 5, ',', '.');
    // *     returns 8: '67.000,00000'
    // *     example 9: number_format(0.9, 0);
    // *     returns 9: '1'
    // *    example 10: number_format('1.20', 2);
    // *    returns 10: '1.20'
    // *    example 11: number_format('1.20', 4);
    // *    returns 11: '1.2000'
    // *    example 12: number_format('1.2000', 3);
    // *    returns 12: '1.200'
    // *    example 13: number_format('1 000,50', 2, '.', ' ');
    // *    returns 13: '100 050.00'
    // Strip all characters but numerical ones.
    number = (number + '').replace(/[^0-9+\-Ee.]/g, '');
    var n = !isFinite(+number) ? 0 : +number,
        prec = !isFinite(+decimals) ? 0 : Math.abs(decimals),
        sep = (typeof thousands_sep === 'undefined') ? ',' : thousands_sep,
        dec = (typeof dec_point === 'undefined') ? '.' : dec_point,
        s = '',
        toFixedFix = function (n, prec) {
            var k = Math.pow(10, prec);
            return '' + Math.round(n * k) / k;
        };
    // Fix for IE parseFloat(0.55).toFixed(0) = 0;
    s = (prec ? toFixedFix(n, prec) : '' + Math.round(n)).split('.');
    if (s[0].length > 3) {
        s[0] = s[0].replace(/\B(?=(?:\d{3})+(?!\d))/g, sep);
    }
    if ((s[1] || '').length < prec) {
        s[1] = s[1] || '';
        s[1] += new Array(prec - s[1].length + 1).join('0');
    }
    return s.join(dec);
}

/* From:
 * jQuery File Upload User Interface Plugin 6.8.1
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2010, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */
function formatBytes(bytes) {
    if (typeof bytes !== 'number') {
        return '';
    }
    if (bytes >= 1000000000) {
        return (bytes / 1000000000).toFixed(2) + ' GB';
    }
    if (bytes >= 1000000) {
        return (bytes / 1000000).toFixed(2) + ' MB';
    }
    return (bytes / 1000).toFixed(2) + ' KB';
}

/**
 Bootstrap Alerts -
 Function Name - showAlert()
 Inputs - message,alerttype,target
 Example - showalert("Invalid Login","alert-error","alert-placeholder")
 Types of alerts -- "alert-error","alert-success","alert-info"
 Required - You only need to add a alert_placeholder div in your html page wherever you want to display these alerts "<div id="alert_placeholder"></div>"
 Written On - 14-Jun-2013
 **/
function showAlert(message, alerttype, target) {

    $('#'+target).append('<div id="alertdiv" class="alert ' +  alerttype + '"><a class="close" data-dismiss="alert">×</a><span>'+message+'</span></div>')

    setTimeout(function() { // this will automatically close the alert and remove this if the users doesnt close it in 5 secs
        $("#alertdiv").remove();
    }, 5000);
}

function blockUIWithMessage(message) {
    $.blockUI({ message: message, fadeIn:0,
        css: {
            border: 'none',
            padding: '15px',
            backgroundColor: '#000',
            '-webkit-border-radius': '10px',
            '-moz-border-radius': '10px',
            opacity: .5,
            color: '#fff'
        } });
}



/**
 * Attaches a simple dirty flag (one shot change detection) to the supplied model, then once the model changes,
 * auto-saves the model using the supplied key every autoSaveIntervalInSeconds seconds.
 * @param viewModel the model to autosave.
 * @param key the (localStorage) key to use when saving the model.
 * @param autoSaveIntervalInSeconds [optional, default=60] how often to autosave the edited model.
 */
function autoSaveModel(viewModel, saveUrl, options) {

    var serializeModel = function() {
        return (typeof viewModel.modelAsJSON === 'function') ? viewModel.modelAsJSON() : ko.toJSON(viewModel);
    };

    var defaults = {
        storageKey:window.location.href+'.autosaveData',
        autoSaveIntervalInSeconds:60,
        restoredDataWarningSelector:"#restoredData",
        resultsMessageId:"save-result-placeholder",
        timeoutMessageSelector:"#timeoutMessage",
        errorMessage:"Failed to save your data: ",
        successMessage:"Save successful!",
        errorCallback:undefined,
        successCallback:undefined,
        blockUIOnSave:false,
        blockUISaveMessage:"Saving...",
        blockUISaveSuccessMessage:"Save successful",
        serializeModel:serializeModel,
        pageExitMessage: 'You have unsaved data.  If you leave the page this data will be lost.',
        preventNavigationIfDirty: false,
        defaultDirtyFlag:ko.simpleDirtyFlag
    };
    var config = $.extend(defaults, options);

    var autosaving = false;

    var deleteAutoSaveData = function() {
        amplify.store(config.storageKey, null);
    };
    var saveLocally = function(data) {
        amplify.store(config.storageKey, data);
    };


    function confirmOnPageExit(e) {
        // If we haven't been passed the event get the window.event
        e = e || window.event;

        // For IE6-8 and Firefox prior to version 4
        if (e) {
            e.returnValue = config.pageExitMessage;
        }

        // For Chrome, Safari, IE8+ and Opera 12+
        return config.pageExitMessage;
    };

    var onunloadHandler = function(e) {
        autosaving = false;
        deleteAutoSaveData();

        return confirmOnPageExit(e);
    };

    var autoSaveModel = function() {
        if (!autosaving) {
            return;
        }

        if (viewModel.dirtyFlag.isDirty()) {
            amplify.store(config.storageKey, serializeModel());
            window.setTimeout(autoSaveModel, config.autoSaveIntervalInSeconds*1000);
        }
    };

    viewModel.cancelAutosave = function() {
        autosaving = false;
        deleteAutoSaveData();
        if (config.preventNavigationIfDirty) {
            window.onbeforeunload = null;
        }
    };

    if (typeof viewModel.dirtyFlag === 'undefined') {
        viewModel.dirtyFlag = config.defaultDirtyFlag(viewModel);
    }
    viewModel.dirtyFlag.isDirty.subscribe(
        function() {
            if (viewModel.dirtyFlag.isDirty()) {
                autosaving = true;

                if (config.preventNavigationIfDirty) {
                    window.onbeforeunload = onunloadHandler;
                }
                window.setTimeout(autoSaveModel, config.autoSaveIntervalInSeconds*1000);
            }
            else {
                viewModel.cancelAutosave();
            }
        }
    );

    viewModel.saveWithErrorDetection = function(successCallback, errorCallback) {
        if (config.blockUIOnSave) {
            blockUIWithMessage(config.blockUISaveMessage);
        }
        $(config.restoredDataWarningSelector).hide();

        var json = config.serializeModel();

        // Store data locally in case the save fails.plan
        amplify.store(config.storageKey, json);

        return $.ajax({
                url: saveUrl,
                type: 'POST',
                data: json,
                contentType: 'application/json'
            }).done(function (data) {
                if (data.error) {
                    if (config.blockUIOnSave) {
                        $.unblockUI();
                    }
                    showAlert(config.errorMessage + data.detail + ' \n' + data.error,
                        "alert-error",config.resultsMessageId);
                    if (typeof errorCallback === 'function') {
                        errorCallback(data);
                    }
                    if (typeof config.errorCallback === 'function') {
                        config.errorCallback(data);
                    }

                } else {
                    if (config.blockUIOnSave) {
                        blockUIWithMessage(config.blockUISaveSuccessMessage);
                    }
                    else {
                        showAlert(config.successMessage, "alert-success", config.resultsMessageId);
                    }
                    viewModel.cancelAutosave();
                    viewModel.dirtyFlag.reset();
                    if (typeof successCallback === 'function') {
                        successCallback(data);
                    }
                    if (typeof config.successCallback === 'function') {
                        config.successCallback(data);
                    }
                }
            })
            .fail(function (data) {
                if (config.blockUIOnSave) {
                    $.unblockUI();
                }
                bootbox.alert($(config.timeoutMessageSelector).html());
                if (typeof errorCallback === 'function') {
                    errorCallback(data);
                }
                if (typeof config.errorCallback === 'function') {
                    config.errorCallback(data);
                }
            });

    }

}

/**
 * Roles have camelCase names and this is a work-around for printing them from AJAX
 * responses.
 * TODO implement i18n encoding with JS
 *
 * @param text
 * @returns {string}
 */
function decodeCamelCase(text) {
    var result = text.replace( /([A-Z])/g, " $1" );
    return result.charAt(0).toUpperCase() + result.slice(1); // capitalize the first letter - as an example.
}

//
if (typeof Object.create !== 'function') {
    Object.create = function (o) {
        function F() {}
        F.prototype = o;
        return new F();
    };
}

/** A function that works with documents.  Intended for inheritance by ViewModels */
var mobileAppRoles = [
    { role: "android", name: "Android" },
    { role: "blackberry", name: "Blackberry" },
    { role: "iTunes", name: "ITunes" },
    { role: "windowsPhone", name: "Windows Phone" }
];
var socialMediaRoles = [
    { role: "facebook", name: "Facebook" },
    { role: "flickr", name: "Flickr" },
    { role: "googlePlus", name: "Google+" },
    { role: "instagram", name: "Instagram" },
    { role: "linkedIn", name: "LinkedIn" },
    { role: "pinterest", name: "Pinterest" },
    { role: "rssFeed", name: "Rss Feed" },
    { role: "tumblr", name: "Tumblr" },
    { role: "twitter", name: "Twitter" },
    { role: "vimeo", name: "Vimeo" },
    { role: "youtube", name: "You Tube" }
];
function Documents() {
    var self = this;
    self.documents = ko.observableArray();
    self.findDocumentByRole = function(documents, roleToFind) {
        for (var i=0; i<documents.length; i++) {
            var role = ko.utils.unwrapObservable(documents[i].role);
            var status = ko.utils.unwrapObservable(documents[i].status);
            if (role === roleToFind && status !== 'deleted') {
                return documents[i];
            }
        }
        return null;
    };

    self.links = ko.observableArray();
    self.findLinkByRole = function(links, roleToFind) {
        for (var i=0; i<links.length; i++) {
            var role = ko.utils.unwrapObservable(links[i].role);
            if (role === roleToFind) return links[i];
        }
        return null;
    };
    self.addLink = function(role, url) {
        self.links.push(new DocumentViewModel({
            role: role,
            url: url
        }));
    };
    self.fixLinkDocumentIds = function(existingLinks) {
        // match up the documentId for existing link roles
        var existingLength = existingLinks? existingLinks.length: 0;
        if (!existingLength) return;
        $.each(self.links(), function(i, link) {
            var role = ko.utils.unwrapObservable(link.role);
            for (i = 0; i < existingLength; i++)
                if (existingLinks[i].role === role) {
                    link.documentId = existingLinks[i].documentId;
                    return;
                }
        });
    }
    function pushLinkUrl(urls, links, role) {
        var link = self.findLinkByRole(links, role.role);
        if (link) urls.push({
            link: link,
            name: role.name,
            role: role.role,
            remove: function() {
              self.links.remove(link);
            },
            logo: function(dir) {
                return dir + "/" + role.role.toLowerCase() + ".png";
            }
        });
    };

    self.transients = {};

    self.transients.mobileApps = ko.pureComputed(function() {
        var urls = [], links = self.links();
        for (var i = 0; i < mobileAppRoles.length; i++)
            pushLinkUrl(urls, links, mobileAppRoles[i]);
        return urls;
    });
    self.transients.mobileAppsUnspecified = ko.pureComputed(function() {
        var apps = [], links = self.links();
        for (var i = 0; i < mobileAppRoles.length; i++)
        if (!self.findLinkByRole(links, mobileAppRoles[i].role))
            apps.push(mobileAppRoles[i]);
        return apps;
    });
    self.transients.mobileAppToAdd = ko.observable();
    self.transients.mobileAppToAdd.subscribe(function(role) {
        if (role) self.addLink(role, "");
    });
    self.transients.socialMedia = ko.pureComputed(function() {
        var urls = [], links = self.links();
        for (var i = 0; i < socialMediaRoles.length; i++)
            pushLinkUrl(urls, links, socialMediaRoles[i]);
        return urls;
    });
    self.transients.socialMediaUnspecified = ko.pureComputed(function() {
        var apps = [], links = self.links();
        for (var i = 0; i < socialMediaRoles.length; i++)
            if (!self.findLinkByRole(links, socialMediaRoles[i].role))
                apps.push(socialMediaRoles[i]);
        return apps;
    });
    self.transients.socialMediaToAdd = ko.observable();
    self.transients.socialMediaToAdd.subscribe(function(role) {
        if (role) self.addLink(role, "");
    });

    self.logoUrl = ko.pureComputed(function() {
        var logoDocument = self.findDocumentByRole(self.documents(), 'logo');
        return logoDocument ? logoDocument.url : null;
    });
    self.bannerUrl = ko.pureComputed(function() {
        var bannerDocument = self.findDocumentByRole(self.documents(), 'banner');
        return bannerDocument ? bannerDocument.url : null;
    });

    self.asBackgroundImage = function(url) {
        return url ? 'url('+url+')' : null;
    };

    self.mainImageUrl = ko.pureComputed(function() {
        var mainImageDocument = self.findDocumentByRole(self.documents(), 'mainImage');
        return mainImageDocument ? mainImageDocument.url : null;
    });

    self.removeBannerImage = function() {
        self.deleteDocumentByRole('banner');
    };

    self.removeLogoImage = function() {
        self.deleteDocumentByRole('logo');
    };

    self.removeMainImage = function() {
        self.deleteDocumentByRole('mainImage');
    };

    // this supports display of the project's primary images
    self.primaryImages = ko.computed(function () {
        var pi = $.grep(self.documents(), function (doc) {
            return ko.utils.unwrapObservable(doc.isPrimaryProjectImage);
        });
        return pi.length > 0 ? pi : null;
    });


    self.embeddedVideos = ko.computed(function () {
        var ev = $.grep(self.documents(), function (doc) {
            var isPublic = ko.utils.unwrapObservable(doc.public);
            var embeddedVideo = ko.utils.unwrapObservable(doc.embeddedVideo);
            if(isPublic && embeddedVideo) {
                var iframe = buildiFrame(embeddedVideo);
                if(iframe){
                    doc.iframe = iframe;
                    return doc;
                }
            }
        });
        return ev.length > 0 ? ev : null;
    });

    self.deleteDocumentByRole = function(role) {
        var doc = self.findDocumentByRole(self.documents(), role);
        if (doc) {
            if (doc.documentId) {
                doc.status = 'deleted';
                self.documents.valueHasMutated(); // observableArrays don't fire events when contained objects are mutated.
            }
            else {
                self.documents.remove(doc);
            }
        }
    };

    self.ignore = ['documents', 'links', 'logoUrl', 'bannerUrl', 'mainImageUrl', 'primaryImages', 'embeddedVideos', 'ignore', 'transients'];

};

/**
 * Wraps a list in a fuse search and exposes results and selection as knockout variables.
 * Make sure to require Fuse on any page using this.
 */
SearchableList = function(list, keys, options) {

    var self = this;
    var options = $.extend({keys:keys, maxPatternLength:64}, options || {});

    var searchable = new Fuse(list, options);

    self.term = ko.observable();
    self.selection = ko.observable();

    self.results = ko.computed(function() {
        if (self.term()) {
            var searchTerm = self.term();
            if (searchTerm > options.maxPatternLength) {
                searchTerm = searchTerm.substring(0, options.maxPatternLength);
            }
            return searchable.search(searchTerm);
        }
        return list;
    });

    self.select = function(value) {
        self.selection(value);
    };
    self.clearSelection = function() {
        self.selection(null);
        self.term(null);
    };
    self.isSelected = function(value) {
        if (!self.selection() || !value) {
            return false;
        }
        for (var i=0; i<keys.length; i++) {
            var selection = self.selection();
            if (selection[keys[i]] != value[keys[i]]) {
                return false;
            }
        }
        return true;
    }
};

function isUrlAndHostValid(url) {
    var allowedHost = ['fast.wistia.com','embed-ssl.ted.com', 'www.youtube.com', 'player.vimeo.com'];
    return (url && isUrlValid(url) && $.inArray(getHostName(url), allowedHost) > -1)
};

function isUrlValid(url) {
    return /^(https?|s?ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(url);
};

function getHostName(href) {
    var l = document.createElement("a");
    l.href = href;
    return l.hostname;
};

function buildiFrame(embeddedVideo){
    var html = $.parseHTML(embeddedVideo);
    var iframe = "";
    if(html){
        for(var i = 0; i < html.length; i++){
            var element = html[i];
            var attr = $(element).attr('src');
            if(typeof attr !== typeof undefined && attr !== false){
                var height =  element.getAttribute("height") ?  element.getAttribute("height") : "315";
                iframe = isUrlAndHostValid(attr)  ? '<iframe width="100%" src ="' +  attr + '" height = "' + height + '"/></iframe>' : "";
            }
            return iframe;
        }
    }
    return iframe;
};

function showFloatingMessage(message, alertType) {
    if (!alertType) {
        alertType = 'alert-success';
    }

    var messageContainer = $('<div id="alertdiv" style="display:none; margin:0;" class="alert ' +  alertType + '"><a class="close" data-dismiss="alert">×</a><span>'+message+'</span></div>');

    setTimeout(function() { // this will automatically close the alert and remove this if the users doesnt close it in 5 secs
        messageContainer.slideUp(400, function() {messageContainer.remove();});
    }, 5000);

    if ($('.navbar').is(':appeared')) {
        // attach below navbar
        $('#content').prepend(messageContainer);

    }
    else {
        // attach to top
        messageContainer.css("position", "fixed");
        messageContainer.width('100%');
        messageContainer.css("top", 0);
        messageContainer.css("left", 0);

        $('body').append(messageContainer);

    }
    messageContainer.slideDown(400);
}