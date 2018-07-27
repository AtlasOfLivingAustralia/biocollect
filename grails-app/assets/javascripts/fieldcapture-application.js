if (typeof jQuery !== 'undefined') {
	(function($) {
		$('#spinner').ajaxStart(function() {
			$(this).fadeIn();
		}).ajaxStop(function() {
			$(this).fadeOut();
		});
	})(jQuery);

	$(function () {
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
    });
}

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

    var alertAnchor = '#'+target;
    $(alertAnchor).append('<div id="alertdiv" class="alert ' +  alerttype + '"><a class="close" data-dismiss="alert">×</a><span>'+message+'</span></div>')
    $(document).scrollTop( $(alertAnchor).offset().top - 15);

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
        resultsMessageSelector:"#save-result-placeholder",
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
        defaultDirtyFlag:ko.dirtyFlag
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
                    bootbox.alert(config.errorMessage + data.detail + '<br/>' + data.error)
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
                if (config.preventNavigationIfDirty) {
                    window.onbeforeunload = null;
                }
                if (config.blockUIOnSave) {
                    $.unblockUI();
                }
                var message = $(config.timeoutMessageSelector).html();
                if (message) {
                    bootbox.alert(message, function() {
                        if (config.preventNavigationIfDirty) {
                            window.onbeforeunload = onunloadHandler;
                        }
                    });
                }
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
    if(typeof text == 'string'){
        var result = text.replace( /([A-Z])/g, " $1" );
        return result.charAt(0).toUpperCase() + result.slice(1); // capitalize the first letter - as an example.
    }
}

//
if (typeof Object.create !== 'function') {
    Object.create = function (o) {
        function F() {}
        F.prototype = o;
        return new F();
    };
}

/**
 * Document preview modes to content type 'map'
 * @type {{convert: string[], pdf: string[], image: string[], audio: string[], video: string[]}}
 */
var contentTypes = {
    convert: [
        'application/msword',
        'application/ms-excel',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.template',
        'application/vnd.ms-word.document.macroEnabled.12',
        'application/vnd.ms-word.template.macroEnabled.12',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.template',
        'application/vnd.ms-excel.sheet.macroEnabled.12',
        'application/vnd.ms-excel.template.macroEnabled.12',
        'application/vnd.ms-excel.addin.macroEnabled.12',
        'application/vnd.ms-excel.sheet.binary.macroEnabled.12',
        'application/vnd.ms-powerpoint',
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        'application/vnd.openxmlformats-officedocument.presentationml.template',
        'application/vnd.openxmlformats-officedocument.presentationml.slideshow',
        'application/vnd.ms-powerpoint.addin.macroEnabled.12',
        'application/vnd.ms-powerpoint.presentation.macroEnabled.12',
        'application/vnd.ms-powerpoint.template.macroEnabled.12',
        'application/vnd.ms-powerpoint.slideshow.macroEnabled.12',
        'application/vnd.oasis.opendocument.chart',
        'application/vnd.oasis.opendocument.chart-template',
        //'application/vnd.oasis.opendocument.database',
        'application/vnd.oasis.opendocument.formula',
        'application/vnd.oasis.opendocument.formula-template',
        'application/vnd.oasis.opendocument.graphics',
        'application/vnd.oasis.opendocument.graphics-template',
        'application/vnd.oasis.opendocument.image',
        'application/vnd.oasis.opendocument.image-template',
        'application/vnd.oasis.opendocument.presentation',
        'application/vnd.oasis.opendocument.presentation-template',
        'application/vnd.oasis.opendocument.spreadsheet',
        'application/vnd.oasis.opendocument.spreadsheet-template',
        'application/vnd.oasis.opendocument.text',
        'application/vnd.oasis.opendocument.text-master',
        'application/vnd.oasis.opendocument.text-template',
        'application/vnd.oasis.opendocument.text-web',
        'text/html',
        'text/plain',
        'text/csv'
    ],
    pdf: [
        'application/pdf',
        'text/pdf'
    ],
    image: [
        'image/jpeg',
        'image/jpg',
        'image/png',
        'image/gif',
        'image/webp',
        'image/bmp'
    ],
    audio: [
        'audio/webm',
        'audio/ogg',
        'audio/wave',
        'audio/wav',
        'audio/x-wav',
        'audio/x-pn-wav',
        'audio/mpeg',
        'audio/mp3',
        'audio/mp4'
    ],
    video: [
        'video/webm',
        'video/ogg',
        'application/ogg',
        'video/mp4'
    ]
};

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
    self.documentFilter = ko.observable('');
    self.documentFilterFieldOptions = [{ label: 'Name', fun: 'name'}, { label: 'Attribution', fun: 'attribution' }, { label: 'Type', fun: 'type' }];
    self.documentFilterField = ko.observable(self.documentFilterFieldOptions[0]);

    self.selectedDocument = ko.observable();

    function listContains(list, value) {
        return list.indexOf(value) > -1;
    }

    self.selectDocument = function(data) {
        self.selectedDocument(data);
        return true;
    };

    self.previewTemplate = ko.pureComputed(function() {
        var selectedDoc = self.selectedDocument();

        var val;
        if (selectedDoc) {
            var contentType = (selectedDoc.contentType() || 'application/octet-stream').toLowerCase().trim();
            var embeddedVideo = selectedDoc.embeddedVideo();
            if (embeddedVideo) {
                val = "xssViewer";
            } else if (listContains(contentTypes.convert.concat(contentTypes.audio, contentTypes.video, contentTypes.image, contentTypes.pdf), contentType)) {
                val = "iframeViewer";
            } else {
                val = "noPreviewViewer";
            }
        } else {
            val = "noViewer";
        }
        return val;
    });

    self.selectedDocumentFrameUrl = ko.computed(function() {
        var selectedDoc = self.selectedDocument();

        var val;
        if (selectedDoc) {
            var contentType = (selectedDoc.contentType() || 'application/octet-stream').toLowerCase().trim();
            //return (selectedDoc && selectedDoc.url) ? "https://docs.google.com/viewer?url="+encodeURIComponent(selectedDoc.url)+"&embedded=true" : '';

            if (listContains(contentTypes.pdf, contentType)) {
                val = fcConfig.pdfViewer + '?file=' + encodeURIComponent(selectedDoc.url);
            } else if (listContains(contentTypes.convert, contentType)) {

              // jq promises are fundamentally broken, so...
              val = $.Deferred(function(dfd) {
                $.get(fcConfig.pdfgenUrl, {"file": selectedDoc.url }, $.noop, "json")
                  .promise()
                  .done(function(data) {
                    dfd.resolve(fcConfig.pdfViewer + '?file=' + encodeURIComponent(data.location));
                  })
                  .fail(function(jqXHR, textStatus, errorThrown) {
                    console.warn('get pdf failed', jqXHR, textStatus, errorThrown);
                    dfd.resolve(fcConfig.errorViewer || '');
                  })
              }).promise();
            } else if (listContains(contentTypes.image, contentType)) {
                val = fcConfig.imgViewer + '?file=' + encodeURIComponent(selectedDoc.url);
            } else if (listContains(contentTypes.video, contentType)) {
                val = fcConfig.videoViewer + '?file=' + encodeURIComponent(selectedDoc.url);
            } else if (listContains(contentTypes.audio, contentType)) {
                val = fcConfig.audioViewer + '?file=' + encodeURIComponent(selectedDoc.url);
            } else {
                //val = fcConfig.noViewer + '?file='+encodeURIComponent(selectedDoc.url);
                val = '';
            }
        } else {
            val = '';
        }
        return val;
    }).extend({async: ''});

    self.filteredDocuments = ko.pureComputed(function() {
        var lcFilter = self.documentFilter().trim().toLowerCase();
        var field = self.documentFilterField();
        return ko.utils.arrayFilter(self.documents(), function(doc) {
            return (doc[field.fun]() || '').toLowerCase().indexOf(lcFilter) !== -1;
        });
    });

    self.docViewerClass = ko.pureComputed(function() {
        return self.selectedDocument() ? 'span6': 'hidden';
    });

    self.docListClass = ko.pureComputed(function() {
        return self.selectedDocument() ? 'span6': 'span12';
    });

    self.showListItem = function(element, index, data) {
        var $elem = $(element);
        $elem.hide(); // element is visible after render, so hide it to animate it appearing.
        $elem.show(100);
    };

    self.hideListItem = function(element, index, data) {
        $(element).hide(100);
    };

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
    };
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
    }

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
        return logoDocument ? (logoDocument.thumbnailUrl ? logoDocument.thumbnailUrl : logoDocument.url) : null;
    });

    self.logoAttributionText = ko.pureComputed(function() {
        var logoDocument = self.findDocumentByRole(self.documents(), 'logo');
        return logoDocument && logoDocument.attribution ? logoDocument.attribution() : null;
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

    self.mainImageAttributionText = ko.pureComputed(function() {
        var mainImageDocument = self.findDocumentByRole(self.documents(), 'mainImage');
        return mainImageDocument && mainImageDocument.attribution ? mainImageDocument.attribution() : null;
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

    self.ignore = ['documents', 'links', 'logoUrl', 'bannerUrl', 'mainImageUrl', 'primaryImages', 'embeddedVideos',
        'ignore', 'transients', 'documentFilter', 'documentFilterFieldOptions', 'documentFilterField',
        'previewTemplate', 'selectedDocumentFrameUrl', 'filteredDocuments','docViewerClass','docListClass',
        'mainImageAttributionText', 'logoAttributionText'];

}

/**
 * Wraps a list in a fuse search and exposes results and selection as knockout variables.
 * Make sure to require Fuse on any page using this.
 */
SearchableList = function(list, keys, options) {

    var self = this;
    var options = $.extend({keys:keys, maxPatternLength:256}, options || {});

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

function siteExtentToValidGeoJSON(siteExtent) {
    var geoJson = null;

    if (siteExtent.geometry) {
        var geometry = _.pick(siteExtent.geometry, "type", "coordinates");
        var properties = _.extend(_.extend({}, siteExtent.properties), siteExtent.geometry);
        geoJson = ALA.MapUtils.wrapGeometryInGeoJSONFeatureCol(geometry);
        geoJson.properties = properties;
    }

    return geoJson;
}

function imageError(imageElement, alternateImage) {
    imageElement.onerror = "";
    imageElement.src = alternateImage;//"/static/images/no-image-2.png";
    return true;
}

/**
 * fired when logo image is loaded. fn used to stretch small image to height or width of parent container.
 * @param imageElement the img element
 * givenWidth - (optional) width of the bounding box containing the image. If nothing is passed parent width is used.
 * givenHeight - (optional) height of the bounding box containing the image. If nothing is passed parent height is used.
 */
function findLogoScalingClass(imageElement, givenWidth, givenHeight) {
    var $elem = $(imageElement);
    var parentHeight = givenHeight || $elem.parent().height();
    var parentWidth = givenWidth || $elem.parent().width();
    var height = imageElement.height;
    var width = imageElement.width;

    var ratio = parentWidth/parentHeight;
    if( ratio * height > width){
        $elem.addClass('tall')
    } else {
        $elem.addClass('wide')
    }
}

function backgroundImageStyle(imageUrl) {
    return "background-image: url('" + imageUrl + "');" ;
}

function backgroundImageError(imageElement, alternateImage) {
    imageElement.onerror = "";
    imageElement.style =  backgroundImageStyle(alternateImage);//"/static/images/no-image-2.png";
    return true;
}

function initCarouselImages(image){
    $(image).parent().fancybox({nextEffect:'fade', preload:0, 'prevEffect':'fade'});
    findLogoScalingClass(image)
};

function initialiseImageGallery(config){
    var vm = new ImageGalleryViewModel(config);
    ko.applyBindings(vm, config.element);

    return vm;
}

/**
 * Converts kilometer square area to an appropriate human readable unit
 * supported units - km square, hectare, meter square
 * @param kmSq {number}
 * @returns {string}
 */
function convertKMSqToReadableUnit(kmSq){
    if(kmSq != undefined){
        if(kmSq > 1){
            return neat_number(kmSq,4) + ' km&sup2;'
        }
        if(kmSq > 0.001){
            return neat_number(kmSq*100,4) + ' hectare'
        }

        return neat_number(kmSq*1000000,4) + ' m&sup2;'
    }
}

/** Polyfill String.startsWith */
if (!String.prototype.startsWith) {
    String.prototype.startsWith = function(searchString, position){
        position = position || 0;
        return this.substr(position, searchString.length) === searchString;
    };
}

/**
 * Sets up the floating save appear / disappear based on a supplied dirtyFlag and some selectors.
 * Note this method requires the floating save to have been rendered into page html.
 * @param dirtyFlag needs to be an object containing a knockout observable "isDirty".
 * @param options selectors for page elements.
 */
function configureFloatingSave(dirtyFlag, options) {
    var defaults = {
        floatingSaveSelector: '#floating-save',
        saveButtonSelector: '#save-button'
    };
    var config = $.extend(defaults, options);

    var $floatingSave = $(config.floatingSaveSelector);
    $(config.saveButtonSelector).appear().on('appear', function() {
        $floatingSave.slideUp(400);
    }).on('disappear', function() {
        if (dirtyFlag.isDirty()) {
            $floatingSave.slideDown(400);
        }
        else {
            $floatingSave.slideUp(400);
        }
    });
    dirtyFlag.isDirty.subscribe(function(dirty) {
        if (dirty && !$floatingSave.is(':appeared')) {
            $floatingSave.slideDown(400);
        }
        else {
            $floatingSave.slideUp(400);
        }
    });
}

/**
 * Truncates a string adding and adds ... to the end of it.
 * @param string The string to truncate if it  string.length > length
 * @param length The maximum string length before it is truncated
 * @returns the original string if string.length <= length or a truncated version of string ending in '...'
 */
function truncate (string,  length) {
    if(string == undefined)
    {
        return undefined;
    }

    length = length || 30;
    var truncation = '...';
    return string.length > length ?
        string.slice(0, length - truncation.length) + truncation : string;
};

function stageNumberFromStage(stage) {
    var stageRegexp = /.+ (\d+)/;
    var match = stageRegexp.exec(stage);
    if (match) {
        stage = match[1];
    }
    else {
        stage = '';
    }
    return stage
}