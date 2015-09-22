/*
 * Copyright (C) 2014 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 */

/*  Global var GSP_VARS required to be set in calling page */

$(document).ready(function() {
    if (typeof GSP_VARS == 'undefined') {
        alert('GSP_VARS not set in page - required for submit.js');
    }

    // init BS3 tooltip on submit btn
    var tooltipVars = {
        viewport: '#submitArea',
        placement: 'bottom'
    };

    // upload code taken from http://blueimp.github.io/jQuery-File-Upload/basic-plus.html
    var imageCount = 0;
    var existingImagesIndex = 0;
    var uploadStateStack = []; // track uploaded files in progress

    $('#fileupload').fileupload({
        url: GSP_VARS.uploadUrl,
        dataType: 'json',
        autoUpload: true,
        acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
        maxFileSize: 5000000, // 5 MB
        // Enable image resizing, except for Android and Opera,
        // which actually support image resizing, but fail to
        // send Blob objects via XHR requests:
        disableImageResize: /Android(?!.*Chrome)|Opera/
            .test(window.navigator.userAgent),
        previewMaxWidth: 100,
        previewMaxHeight: 100,
        previewCrop: true
    }).on('fileuploadadd', function (e, data) {
        // load event triggered (start)
        // Disable the submit button while images are being uploaded to server in background
        $('#formSubmit').attr('disabled','disabled').attr('title','image upload in progress').addClass('disabled');
        $('#submitWrapper').attr('title', 'Image upload in progress... please wait').tooltip(tooltipVars).tooltip('show');
        // Clone the template and reference it via data.context
        data.context = $('#uploadActionsTmpl').clone(true).removeAttr('id').removeClass('hide').appendTo('#files');
        $.each(data.files, function (index, file) {
            var node = $(data.context[index]);
            node.find('.filename').append(file.name + '  (' + humanFileSize(file.size) + ')');
            node.data('index', imageCount++);
            $('#imageLicenseDiv').removeClass('hide'); // show the license options
            uploadStateStack.push(1);
        });
    }).on('fileuploadprocessalways', function (e, data) {
        // next event after 'add' setup progress bar, etc
        var index = data.index,
            file = data.files[index],
            hasMetaData = false,
            node = $(data.context[index]); // grab the current image node (created via a template)
        if (file.preview) {
            // add preview image
            node.find('.preview').append(file.preview);
        }

        if (data.exif) {
            // add EXIF data (date, location, etc)
            // console.log('exif tags', data.exif, data.exif.getAll());
            // GPS coordinates are in deg/min/sec -> convert to decimal
            var lat = data.exif.getText('GPSLatitude'); // getText returns "undefined" as a String if not set!
            var lng = data.exif.getText('GPSLongitude'); // getText returns "undefined" as a String if not set!

            if (lat != "undefined" && lng != "undefined") {
                // add GPS data
                lat = lat.split(',');
                lng = lng.split(',');
                var latRef = data.exif.getText('GPSLatitudeRef') || "N";
                var lngRef = data.exif.getText('GPSLongitudeRef') || "W";
                lat = ((Number(lat[0]) + Number(lat[1])/60 + Number(lat[2])/3600) * (latRef == "N" ? 1 : -1)).toFixed(10);
                lng = ((Number(lng[0]) + Number(lng[1])/60 + Number(lng[2])/3600) * (lngRef == "W" ? -1 : 1)).toFixed(10);
                hasMetaData = true;
                node.find('.imgCoords').empty().append(lat + ", " + lng).data('lat',lat).data('lng',lng);
            }

            var dateTime = (data.exif.getText('DateTimeOriginal') != 'undefined') ? data.exif.getText('DateTimeOriginal') : null;// || data.exif.getText('DateTime');
            var gpsDate = (data.exif.getText('GPSDateStamp') != 'undefined') ? data.exif.getText('GPSDateStamp') : null;
            var gpsTime = (data.exif.getText('GPSTimeStamp') != 'undefined') ? data.exif.getText('GPSTimeStamp') : null;

            if (gpsTime && dateTime) {
                // determine local time offset from UTC
                // by working out difference between DateTimeOriginal and GPSTimeStamp to get timezone (offset)
                // gpsDate is not always set - if absent assume same date as 'DateTimeOriginal'
                var date = gpsDate || dateTime.substring(0,10); //dateTime.substring(0,10)
                date = date.replace(/:/g,'-') + ' ' + parseGpsTime(gpsTime); // comvert YYYY:MM:DD to YYYY-MM-DD
                var gpsMoment = moment(date);
                var datetimeTemp = parseExifDateTime(dateTime, false);
                var localMoment = moment(datetimeTemp);
                var gpsDiff = localMoment.diff(gpsMoment, 'minutes');
                var prefix = (gpsDiff >= 0) ? '+' : '';
                gpsDiff = Math.round(gpsDiff / 10) * 10; // round to nearest 10 min (for minor discrepancies in time in EXIF data)
                var gpsOffset = prefix + moment.duration(gpsDiff, 'minutes').format("hh:mm");
                $('#timeZoneOffset').val(gpsOffset);
                hasMetaData = true;
            }
            if (dateTime) {
                // add date & time
                hasMetaData = true;
                var isoDateStr = parseExifDateTime(dateTime, true) || dateTime;
                node.find('.imgDate').html(isoDateStr);
                if (! node.find('.imgDate').data('datetime')) {
                    node.find('.imgDate').data('datetime', isoDateStr);
                }
            } else if (gpsDate) {
                hasMetaData = true;
                var isoDateStr = gpsDate.replace(/:/g,'-');
                node.find('.imgDate').html(isoDateStr);
                if (! node.find('.imgDate').data('datetime')) {
                    node.find('.imgDate').data('datetime', isoDateStr);
                }
            }

            if (hasMetaData) {
                // activate the button
                node.find('.imageData').removeAttr('disabled').attr('title','Use image date/time & GPS coordinates for this sighting');
            }
        }
        if (file.error) {
            node.find('.error').append($('<span class="text-danger"/>').text(file.error));
        }
    }).on('fileuploadprogressall', function (e, data) {
        // progress metre - gets triggered mulitple times TODO: not used so remove?
        var progress = parseInt(data.loaded / data.total * 100, 10);
        $('#progress .progress-bar').css('width', progress + '%');
    }).on('fileuploaddone', function (e, data) {
        // file has successfully uploaded
        // Re-enable the submit button
        uploadStateStack.pop(); //remove last element
        checkAllUploadsDone();
        $('#formSubmit').removeAttr('disabled').removeAttr('title').removeClass('disabled');
        $('#submitWrapper').removeAttr('title').tooltip('destroy');
        var node = $(data.context[0]);
        var index = node.data('index') + existingImagesIndex;
        var result = data.result; // ajax results
        if (result.success) {
            var link = $('<a>')
                .attr('target', '_blank')
                .prop('href', result.url);
            node.find('.preview').wrap(link);
            // populate hidden input fields
            node.find('.identifier').val(result.url).attr('name', 'multimedia['+ index + '].identifier');
            node.find('.title').val(result.filename).attr('name', 'multimedia['+ index + '].title');
            node.find('.format').val(result.mimeType).attr('name', 'multimedia['+ index + '].format');
            node.find('.creator').val((GSP_VARS.user && GSP_VARS.user.userDisplayName) ? GSP_VARS.user.userDisplayName : 'ALA User').attr('name', 'multimedia['+ index + '].creator');
            node.find('.license').val($('#imageLicense').val()).attr('name', 'multimedia['+ index + '].license');
            if (result.exif && result.exif.date) {
                node.find('.created').val(result.exif.date).attr('name', 'multimedia['+ index + '].created');
            }
            insertImageMetadata(node);
        } else if (data.error) {
            // in case an error still returns a 200 OK... (our service shouldn't)
            var error = $('<div class="alert alert-error"/>').text(data.error);
            node.append(error);
        }
    }).on('fileuploadfail', function (e, data) {
        $.each(data.files, function (index, file) {
            var error = $('<div class="alert alert-error"/>').text('File upload failed.');
            $(data.context.children()[index]).append(error);
        });
        uploadStateStack.pop(); //remove last element
        checkAllUploadsDone();
        // Re-enable the submit button
        $('#formSubmit').removeAttr('disabled').removeAttr('title').removeClass('disabled');
        $('#submitWrapper').removeAttr('title').tooltip('destroy');
    }).prop('disabled', !$.support.fileInput).parent().addClass($.support.fileInput ? undefined : 'disabled');

    /*
     * If all uploads are done, uploadStateStack will be empty so re-activate submit button
     */
    function checkAllUploadsDone() {
        //console.log('checkAllUploadsDone', uploadStateStack);
        if (uploadStateStack.length == 0) {
            $('#formSubmit').removeAttr('disabled').removeAttr('title').removeClass('disabled');
            $('#submitWrapper').removeAttr('title').tooltip('destroy');
        }
    }

    var autocompleteUrl = 'http://bie.ala.org.au/ws/search/auto.jsonp';

    if(typeof BIE_VARS != 'undefined' && BIE_VARS.autocompleteUrl){
        autocompleteUrl = BIE_VARS.autocompleteUrl;
    }

    $("input#speciesLookup").autocomplete(autocompleteUrl, {
        extraParams: {limit: 100},
        dataType: 'jsonp',
        parse: function(data) {
            var rows = new Array();
            data = data.autoCompleteList;
            for(var i=0; i<data.length; i++) {
                rows[i] = {
                    data:data[i],
                    value: data[i].matchedNames[0],
                    result: data[i].matchedNames[0]
                };
            }
            return rows;
        },
        matchSubset: false,
        formatItem: function(row, i, n) {
            return row.matchedNames[0];
        },
        cacheLength: 10,
        minChars: 3,
        scroll: false,
        max: 10,
        selectFirst: false
    }).result(function(event, item) {
        // user has selected an autocomplete item
        //console.log("item", item);
        $('input#guid').val(item.guid).change();
    });

    // pass in local time offset from UTC
    var offset = new Date().getTimezoneOffset() * -1;
    var hours = offset / 60;
    var minutes = offset % 60;
    var prefix = (hours >= 0) ? '+' : '';
    $('#timeZoneOffset').val(prefix + ('0' + hours).slice(-2) + ':' + ('0' + minutes).slice(-2));

    // use image data button
    $('#files').on('click', 'button.imageData', function() {
        insertImageMetadata($(this).parents('.imageRow'));
        return false;
    });

    // remove image button
    $('#files').on('click', 'button.imageRemove', function() {
        $(this).parents('.imageRow').remove();
    });

    // image license drop-down
    $('#imageLicense').change(function() {
        $('input.license').val($(this).val());
    });

    // Clear the #dateStr field (extracted from photo EXIF data) if user changes either the date or time field
    $('#dateStr, #timeStr').keyup(function() {
        $('#eventDate').val('');
    });

    // close button on bootstrap alert boxes
    $("[data-hide]").on("click", function(){
        $(this).closest("." + $(this).attr("data-hide")).hide();
        clearTaxonDetails();
    });

    // species group drop-down
    var speciesGroupsObj = GSP_VARS.speciesGroups;
    $('#speciesGroups').change(function(e) {
        var group = $(this).val();
        var noSelectOpt = '-- Choose a sub group --';
        $('#speciesSubgroups').empty().append($("<option/>").attr("value","").text(noSelectOpt));

        if (group) {
            $.each(speciesGroupsObj[group], function(i, el) {
                $('#speciesSubgroups')
                    .append($("<option/>")
                        .attr("value",el.common)
                        .text(el.common));
            });
            addTagLabel(group, 'group');
        }
    });

    // species subgroup drop-down
    $('#speciesSubgroups').change(function(e) {
        var subgroup = $(this).val();
        addTagLabel(subgroup, 'subgroup');
        //$(this).val(''); // reset
    });

    // remove species/scientificName box
    $('#species').on('click', 'a.removeTag', function(e) {
        e.preventDefault();
        $(this).parent().remove();
    });

    $('#species').on('click', 'a.removeHide', function(e) {
        e.preventDefault();
        $(this).parent().hide();
    });

    // prevent enter key on autocomplete submitting form/sighting
    $(document).on('keydown', '#speciesLookup', function(e) {
        if (e.which == 13) {
            return false;
        }
    });

    // detect change on #taxonConceptID input (autocomplete selection) and load species details
    $(document.body).on('change', '#guid', function(e) {
        //console.log('#guid on change');
        //$('#speciesLookup').alaAutocomplete.reset();
        //$('#speciesLookup').val('');
        var guid = $(this).val();
        setSpecies(guid);
    });

    // show tags in edit mode
    // look for request params first and then values in sighting bean
    var tags = ($.url(true).param('tags')) ? $.url(true).param('tags') : GSP_VARS.sightingBean.tags || [];
    if (tags && $.type(tags) === "string") {
        // force tags to be Array type
        tags = new Array(tags);
    }
    $.each(tags, function(i, t) {
        addTagLabel(t);
    });

    // show images in edit mode
    var media = (GSP_VARS.sightingBean.multimedia) ? GSP_VARS.sightingBean.multimedia : [];
    $.each(media, function(i, m) {
        //console.log("image", m);
        addServerImage(m, i);
        existingImagesIndex++;
    });

    // clear validation errors red border on input blur
    $('.validationErrors').on('blur', function(e) {
        $(this).removeClass('validationErrors');
    });

    // load species info if id is in the URL
    if (GSP_VARS.guid) {
        $('#guid').val(GSP_VARS.guid).change();
        $('#confident').trigger( "click" );
    }

    // trigger image assisted identification popup
    $('.identifyHelpTrigger').click(function(e) {
        e.preventDefault();
        var lat = $('#decimalLatitude').val();
        var lng = $('#decimalLongitude').val();
        var locality = $('#locality').val();
        //var url = $(this).attr('href');
        if (lat && lng) {
            GSP_VARS.lat = lat;
            GSP_VARS.lng = lng;
            updateSpeciesGroups(null, GSP_VARS.lat, GSP_VARS.lng);
            $('#identifyHelpModal').modal('show');
        } else {
            bootbox.alert('<h3>See species known to occur in a particular location</h3>A sighting location is required for this tool, please include a location using the map tool below, then try again');
        }

    });

    // Configure datetime pickers
    $('#datetimepicker1').datetimepicker({
        format: 'dd-MM-yyyy',
        weekStart: 1,
        pickTime: false
    });

    $('#datetimepicker2').datetimepicker({
        format: 'hh:mm',
        pickDate: false,
        timeIcon: 'fa fa-clock-o'
    });

    // catch submit button and convert date & time to ISO string
    $('#formSubmit').click(function(e) {
        e.preventDefault();
        var date = $('#dateStr').val();
        var time = $('#timeStr').val() || '00:00';
        var timeZone = $('#timeZoneOffset').val() || '+10:00';

        if (date) {
            var dateInput = date + " " + time  + " " +  timeZone
            var mDateTime = moment(dateInput, "DD-MM-YYYY HH:mm Z"); // format("DD-MM-YYYY, HH:mm");
            $('#eventDate').val(mDateTime.format()); // default is ISO
        }

        $('#sightingForm').submit();
    });

}); // end of $(document).ready(function()

function insertImageMetadata(imageRow) {
    // imageRow is a jQuery object
    var dateTimeVal = imageRow.find('.imgDate').data('datetime');
    if (dateTimeVal) {
        var dateTime = String(dateTimeVal);
        //$('#eventDateTime').val(dateTime);
        $('#eventDate').val(isoToAusDate(dateTime.substring(0,10)));
        //$('#eventTime').val(dateTime.substring(11,19));
        $('#timeZoneOffset').val(dateTime.substring(19));
        //console.log("dateTime 3.1", dateTime, dateTime instanceof String);
        var mDateTime = moment(dateTime, moment.ISO_8601); // format("DD-MM-YYYY, HH:mm");
        $('#dateStr').val(mDateTime.format("DD-MM-YYYY"));
        $('#timeStr').val(mDateTime.format("HH:MM"));
        //$('#eventDate_year').val(mDateTime.format("YYYY"));
        //$('#eventDate_month').val(mDateTime.format("M"));
        //$('#eventDate_day').val(mDateTime.format("D"));
        //$('#eventDate_hour').val(mDateTime.format("HH"));
        //$('#eventDate_minute').val(mDateTime.format("mm"));
    }
    var lat = imageRow.find('.imgCoords').data('lat');
    var lng = imageRow.find('.imgCoords').data('lng');
    if (lat && lng) {
        $('#decimalLatitude').val(lat).change();
        $('#decimalLongitude').val(lng).change();
        $('#georeferenceProtocol').val('camera/phone');
    }
}

function setSpecies(guid) {
    //console.log('setSpecies', guid);
    if (guid) {
        $.getJSON(GSP_VARS.bieBaseUrl + "/ws/species/shortProfile/" + guid + ".json?callback=?")
            .done(function(data) {
                if (data.scientificName) {
                    $('#taxonDetails').removeClass('hide').show();
                    $('#noSpecies').hide();
                    $('.sciName a').attr('href', GSP_VARS.bieBaseUrl + "/species/" + guid).html(data.scientificName);
                    $('.speciesThumbnail').attr('src', data.thumbnail);
                    if (data.commonName) {
                        $('.commonName').text(data.commonName);
                        $('#commonName').val(data.commonName);
                    }
                    $('#kingdom').val(data.kingdom);
                    $('#family').val(data.family);
                    $('#scientificName').val(data.scientificName);
                    $('#noTaxa').hide();
                    $('#matchedTaxa').show();
                    $('#identificationChoice').show();
                    if (!GSP_VARS.sightingBean) {
                        $("input[name=identificationVerificationStatus][value=confident]").prop('checked', true);
                    }

                }
            })
            .fail(function( jqXHR, textStatus, errorThrown ) {
                //console.log('error',jqXHR, textStatus, errorThrown);
                alert("Error: " + textStatus + " - " + errorThrown);
            })
            .always(function() {
                // clean-up & spinner deactivations, etc
            });
    }
}

function isoToAusDate(isoDate) {
    var dateParts = isoDate.substring(0,10).split('-');
    var ausDate = isoDate.substring(0,10); // fallback

    if (dateParts.length == 3) {
        ausDate = dateParts.reverse().join('-');
    }

    return ausDate;
}

function clearTaxonDetails() {
    $('#taxonDetails .commonName').html('');
    $('#taxonDetails img').attr('src','');
    $('#taxonDetails a').attr('href','').html('');
    $('#taxonConceptID, #scientificName, #commonName').val('');
}

/**
 * Adds a visual tag (label/badge) to the page when either group/subgroup select changes
 *
 * @param group
 */
function addTagLabel(group, type) {
    if (!isTagPresent(group) && group) {
        var close = '<a href="#" class="remove removeTag" title="remove this item"><i class="remove fa fa-close fa-inverse"></i></a>';
        var input = '<input type="hidden" value="' + group + '" name="tags" class="tags ' + type + '"/>';
        var label = $('<span class="tag label label-default"/>').append(input + '<span>' + group + '</span> ' + close).after('&nbsp;');
        $('#tagsBlock').append(label).append(' ');
    }
}

/**
 * Convert bytes to human readable form.
 * Taken from http://stackoverflow.com/a/14919494/249327
 *
 * @param bytes
 * @param si
 * @returns {string}
 */
function humanFileSize(bytes, si) {
    var thresh = si ? 1000 : 1024;
    if(bytes < thresh) return bytes + ' B';
    //var units = si ? ['kB','MB','GB','TB','PB','EB','ZB','YB'] : ['KiB','MiB','GiB','TiB','PiB','EiB','ZiB','YiB'];
    var units =  ['kB','MB','GB','TB','PB','EB','ZB','YB'];
    var u = -1;
    do {
        bytes /= thresh;
        ++u;
    } while(bytes >= thresh);
    return bytes.toFixed(1)+' '+units[u];
};

/**
 * Parse the weird date time format in EXIF data (TIFF format)
 *
 * @param dataTimeStr
 * @returns dateTimeObj (JS Date)
 */
function parseExifDateTime(dataTimeStr, includeOffset) {
    //first split on space to get date and time parts
    // console.log('dataTimeStr', dataTimeStr);
    //var dateTimeObj;
    var bigParts = dataTimeStr.split(' ');

    if (bigParts.length == 2) {
        var date = bigParts[0].split(':');
        //var time = bigParts[1].split(':');
        var offset = $('#timeZoneOffset').val() || '+10:00';
        //offset = (offset >= 0) ? '+' + offset : offset;
        var isoDateStr = date.join('-') + 'T' + bigParts[1];
        if (includeOffset) {
            isoDateStr += offset;
        } else {
            isoDateStr = isoDateStr.replace('T', ' ');
        }
        //alert('includeOffset = ' + includeOffset + ' - ' + isoDateStr);
    }

    return isoDateStr;
}

function parseGpsTime(time) {
    // e.g. 15,5,8.01
    var bits = [];
    $.each(time.split(','), function(i, it) {
        bits.push(('0' + parseInt(it)).slice(-2)); // zero pad
    });
    return bits.join(':');
}

function addServerImage(image, index) {
    var node = $('#uploadActionsTmpl').clone(true).removeAttr('id').removeClass('hide'); //.appendTo('#files');
    node.find('.filename').append(image.title); // add filesize -  humanFileSize(file.size)

    var link = $('<a>')
        .attr('target', '_blank')
        .prop('href', image.identifier);
    node.find('.preview').wrap(link);
    node.find('.preview').append($('<img/>').attr('src',image.identifier).addClass('serverLoaded'));
    // populate hidden input fields
    //node.find('.media').val(result.url).attr('name', 'associatedMedia['+ index + ']');
    node.find('.identifier').val(image.identifier).attr('name', 'multimedia['+ index + '].identifier');
    node.find('.imageId').val(image.imageId).attr('name', 'multimedia['+ index + '].imageId');
    node.find('.title').val(image.title).attr('name', 'multimedia['+ index + '].title');
    node.find('.format').val(image.format).attr('name', 'multimedia['+ index + '].format');
    node.find('.creator').val(image.creator).attr('name', 'multimedia['+ index + '].creator');
    node.find('.created').val(image.created).attr('name', 'multimedia['+ index + '].created');
    node.find('.license').val(image.license).attr('name', 'multimedia['+ index + '].license');

    if (false) {
        //if (result.exif && result.exif.date) {
        node.find('.created').val(result.exif.date).attr('name', 'multimedia['+ index + '].created');
    }
    
    $('#imageLicenseDiv').removeClass('hide'); // show the license options
    node.appendTo('#files');
}

/**
 * Used by the validation engine jquery plugin to validate the selection of a species name or species tags on the Record a Sighting form.
 *
 * This rule is defined on the #speciesLookup element.
 *
 */
function validateSpeciesSelection(field, rules, i, options) {
    var species = $("#taxonDetails .sciName").is(':visible');
    var tags = $("#tagsBlock").children().length > 0;
    var media = $("#files").children().length > 0;

    if (!species && (!tags || !media)) {
        // there is a bug with the funcCall option in JQuery Validation Engine where the rule is triggered but the
        // message is not raised unless the 'required' rule is also present.
        // The work-around for this is to manually add the 'required' rule when the message is raised.
        // http://stackoverflow.com/questions/16182395/jquery-validation-engine-funccall-not-working-if-only-rule
        rules.push('required');
        return "Either species name is required OR one or more tags AND media files are both required"
    }
}


/**
 * Returns true if tag is already present in page DOM
 *
 * @param tag
 * @returns {boolean}
 */
function isTagPresent(tag) {
    var isTagPresent = false;
    $('.tags').each(function() {
        if (tag == $(this).val()) {
            isTagPresent = true;
            return false;
        }
    });

    return isTagPresent
}



function Sighting() {

    var dirty = false;

    $(":input").change(function() {
        dirty = true;
    });

    this.getSightingsDataAsJS = function () {
        var record = {};

        var fields = ["guid",
            "scientificName",
            "commonName",
            "kingdom",
            "family",
            "speciesLookup",
            "speciesGroups",
            "speciesSubgroups",
            "imageLicense",
            "decimalLatitude",
            "decimalLongitude",
            "coordinateUncertaintyInMeters",
            "locality",
            "locationRemark",
            "dateStr",
            "timeStr",
            "individualCount",
            "eventDate",
            "occurrenceRemarks",
            "speciesTags"];

        $("#sighting :input").each(function (index, field) {
            if (field.id && fields.indexOf(field.id) > -1) {
                record[field.id] = field.value;
            }
        });

        record.speciesTags = [];
        $('.tags').each(function() {
            var tag = {
                name: $(this).val(),
                type: $(this).attr('class').split(" ")[1]
            };
            record.speciesTags.push(tag)
        });

        return record;
    };

    this.loadSightingData = function (data) {
        for (var property in data) {
            $('#' + property).val(data[property]);
            $('#' + property).change();
        }

        if (typeof data.speciesTags !== 'undefined') {
            data.speciesTags.forEach(function (tag) {
                addTagLabel(tag.name, tag.type);
            });
        }

        if (data.guid) {
            setSpecies(data.guid);
        }

        dirty = false;
    };

    this.isDirty = function () {
        return dirty;
    };

    this.reset = function () {
        $("#sighting :input").each(function (index, field) {
            if (field.id) {
                if (field.id === "individualCount") {
                    field.value = "1";
                } else {
                    field.value = "";
                }
            }
        });

        clearTaxonDetails();
        $('#taxonDetails').addClass('hide');
        $('#noSpecies').removeClass('hide').show();


        dirty = false;

    };
}