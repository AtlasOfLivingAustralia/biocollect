/**
 * User: MEW
 * Date: 18/06/13
 * Time: 2:24 PM
 */

//iterates over the outputs specified in the meta-model and builds a temp object for
// each containing the name, and the scores and id of any matching outputs in the data
ko.bindingHandlers.foreachModelOutput = {
    init: function(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
        if (valueAccessor() === undefined) {
            var dummyRow = {name: 'No model was found for this activity', scores: [], outputId: '', editLink:''};
            ko.applyBindingsToNode(element, { foreach: [dummyRow] });
            return { controlsDescendantBindings: true };
        }
        var metaOutputs = ko.utils.unwrapObservable(valueAccessor()),// list of String names of outputs
            activity = bindingContext.$data,// activity data
            transformedOutputs = [];//created list of temp objects

        $.each(metaOutputs, function (i, name) { // for each output name
            var scores = [],
                outputId = '',
                editLink = fcConfig.serverUrl + "/output/";

            // search for corresponding outputs in the data
            $.each(activity.outputs(), function (i,output) { // iterate output data in the activity to
                                                             // find any matching the meta-model name
                if (output.name === name) {
                    outputId = output.outputId;
                    $.each(output.scores, function (k, v) {
                        scores.push({key: k, value: v});
                    });
                }
            });

            if (outputId) {
                // build edit link
                editLink += 'edit/' + outputId +
                    "?returnTo=" + returnTo;
            } else {
                // build create link
                editLink += 'create?activityId=' + activity.activityId +
                    '&outputName=' + encodeURIComponent(name) +
                    "&returnTo=" + returnTo;
            }
            // build the array that we will actually iterate over in the inner template
            transformedOutputs.push({name: name, scores: scores, outputId: outputId,
                editLink: editLink});
        });

        // re-cast the binding to iterate over our new array
        ko.applyBindingsToNode(element, { foreach: transformedOutputs });
        return { controlsDescendantBindings: true };
    }
};
ko.virtualElements.allowedBindings.foreachModelOutput = true;

// handle activity accordion
$('#activities').
    on('show', 'div.collapse', function() {
        $(this).parents('tr').prev().find('td:first-child a').empty()
            .html("&#9660;").attr('title','hide').parent('a').tooltip();
    }).
    on('hide', 'div.collapse', function() {
        $(this).parents('tr').prev().find('td:first-child a').empty()
            .html("&#9658;").attr('title','expand');
    }).
    on('shown', 'div.collapse', function() {
        trackState();
    }).
    on('hidden', 'div.collapse', function() {
        trackState();
    });

function trackState () {
    var $leaves = $('#activityList div.collapse'),
        state = [];
    $.each($leaves, function (i, leaf) {
        if ($(leaf).hasClass('in')) {
            state.push($(leaf).attr('id'));
        }
    });
    console.log('state stored = ' + state);
    amplify.store.sessionStorage('output-accordion-state',state);
}

function readState () {
    var $leaves = $('#activityList div.collapse'),
        state = amplify.store.sessionStorage('output-accordion-state'),
        id;
    console.log('state retrieved = ' + state);
    $.each($leaves, function (i, leaf) {
        id = $(leaf).attr('id');
        if (($.inArray(id, state) > -1)) {
            $(leaf).collapse('show');
        }
    });
}

var image = function(props) {

    var imageObj = {
        id:props.id,
        name:props.name,
        size:props.size,
        url: props.url,
        thumbnail_url: props.thumbnail_url,
        viewImage : function() {
            window['showImageInViewer'](this.id, this.url, this.name);
        }
    };
    return imageObj;
};

ko.bindingHandlers.photoPoint = {
    init: function(element, valueAccessor) {

    }
}


ko.bindingHandlers.photoPointUpload = {
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

        var config = valueAccessor();
        config = $.extend({}, config, defaultConfig);

        var target = config.target; // Expected to be a ko.observableArray
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

//            var resultText = $('pre', data.result).text();
//            var result = $.parseJSON(resultText);


            var result = data.result;
            if (!result) {
                result = {};
                error('No response from server');
            }

            if (result.files[0]) {
                result.files.forEach(function (f) {
                    var data = {
                        thumbnailUrl: f.thumbnail_url,
                        url: f.url,
                        contentType: f.contentType,
                        filename: f.name,
                        name: f.name,
                        filesize: f.size,
                        dateTaken: f.isoDate,
                        staged: true,
                        attribution: f.attribution,
                        notes: f.notes,
                        status: f.status,
                        licence: f.licence
                    };

                    if (f.contentType.indexOf("image") > -1) {
                        target.push(new ImageViewModel(data));
                    } else if (f.contentType.indexOf("audio") > -1) {
                        target.push(new AudioItem(data));
                    } else {
                        target.push(new DocumentViewModel(data));
                    }
                });

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
    }
};

ko.bindingHandlers.imageUpload = {
    init: function(element, valueAccessor, allBindings, viewModel, bindingContext) {
        var defaultConfig = {
            maxWidth: 300,
            minWidth:150,
            minHeight:150,
            maxHeight: 300,
            previewSelector: '.preview',
            viewModel: viewModel
        };
        var size = ko.observable();
        var progress = ko.observable();
        var error = ko.observable();
        var complete = ko.observable(true);

        var config = valueAccessor();
        config = $.extend({}, config, defaultConfig);

        var target = config.target,
            dropZone = $(element).find('.dropzone');
        var uploadProperties = {
            size: size,
            progress: progress,
            error:error,
            complete:complete
        };

        var innerContext = bindingContext.createChildContext(bindingContext);
        ko.utils.extend(innerContext, uploadProperties);
        var previewElem = $(element).parent().find(config.previewSelector);

// Expected to be a ko.observableArray
        $(element).fileupload({
            url:config.url,
            autoUpload:true,
            forceIframeTransport: false,
            dropZone: dropZone
        }).on('fileuploadadd', function(e, data) {
            previewElem.html('');
            complete(false);
            progress(1);
        }).on('fileuploadprocessalways', function(e, data) {
            if (data.files[0].preview) {
                if (config.previewSelector !== undefined) {
                    previewElem.append(data.files[0].preview);
                }
            }
        }).on('fileuploadprogressall', function(e, data) {
            progress(Math.floor(data.loaded / data.total * 100));
            size(data.total);
        }).on('fileuploaddone', function(e, data) {
            var result = data.result;
            var $doc = $(document);
            if (!result) {
                result = {};
                error('No response from server');
            }

            if (result.files[0]) {
                result.files.forEach(function( f ){
                    // flag to indicate the image is in biocollect and needs to be save to ecodata as a document
                    var data = {
                        thumbnailUrl: f.thumbnail_url,
                        url: f.url,
                        contentType: f.contentType,
                        filename: f.name,
                        name: f.name,
                        filesize: f.size,
                        dateTaken: f.isoDate,
                        staged: true,
                        attribution: f.attribution,
                        licence: f.licence
                    };

                    target.push(new ImageViewModel(data));

                    if(f.decimalLongitude && f.decimalLatitude){
                        $doc.trigger('imagelocation', {
                            decimalLongitude: f.decimalLongitude,
                            decimalLatitude: f.decimalLatitude
                        });
                    }

                    if(f.isoDate){
                        $doc.trigger('imagedatetime', {
                            date: f.isoDate
                        });
                    }

                });

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
    }
};

ko.bindingHandlers.fileUploadWithProgress = {
    init: function (element, valueAccessor, allBindings, viewModel, bindingContext) {
        var defaultConfig = {
            maxWidth: 300,
            minWidth: 150,
            minHeight: 150,
            maxHeight: 300
        };
        var size = ko.observable();
        var progress = ko.observable();
        var error = ko.observable();
        var complete = ko.observable(true);

        var config = valueAccessor();
        config = $.extend({}, config, defaultConfig);

        var target = config.target;
        var uploadProperties = {
            size: size,
            progress: progress,
            error: error,
            complete: complete
        };

        var innerContext = bindingContext.createChildContext(bindingContext);
        ko.utils.extend(innerContext, uploadProperties);

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
            var result = data.result;
            if (!result) {
                result = {};
                error('No response from server');
            }

            if (result.files[0]) {
                result.files.forEach(function (f) {
                    var data = {
                        thumbnailUrl: f.thumbnail_url,
                        url: f.url,
                        contentType: f.contentType,
                        filename: f.name,
                        name: f.name,
                        filesize: f.size,
                        dateTaken: f.isoDate,
                        staged: true,
                        attribution: f.attribution,
                        notes: f.notes,
                        status: f.status
                    };

                    if (f.contentType.indexOf("image") > -1) {
                        target.push(new ImageViewModel(data));
                    } else if (f.contentType.indexOf("audio") > -1) {
                        target.push(new AudioItem(data));
                    } else {
                        target.push(new DocumentViewModel(data));
                    }
                });

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
    }
};


ko.bindingHandlers.editDocument = {
    init:function(element, valueAccessor) {
        if (ko.isObservable(valueAccessor())) {
            var document = ko.utils.unwrapObservable(valueAccessor());
            if (typeof document.status == 'function') {
                document.status.subscribe(function(status) {
                    if (status == 'deleted') {
                        valueAccessor()(null);
                    }
                });
            }
        }
        var options = {
            name:'documentEditTemplate',
            data:valueAccessor()
        };
        return ko.bindingHandlers['template'].init(element, function() {return options;});
    },
    update:function(element, valueAccessor, allBindings, viewModel, bindingContext) {
        var options = {
            name:'documentEditTemplate',
            data:valueAccessor()
        };
        ko.bindingHandlers['template'].update(element, function() {return options;}, allBindings, viewModel, bindingContext);
    }
}