%{--
  - Copyright (C) 2014 Atlas of Living Australia
  - All Rights Reserved.
  -
  - The contents of this file are subject to the Mozilla Public
  - License Version 1.1 (the "License"); you may not use this file
  - except in compliance with the License. You may obtain a copy of
  - the License at http://www.mozilla.org/MPL/
  -
  - Software distributed under the License is distributed on an "AS
  - IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  - implied. See the License for the specific language governing
  - rights and limitations under the License.
  --}%

<%--
  Created by IntelliJ IDEA.
  User: dos009@csiro.au
  Date: 10/12/14
  Time: 12:09 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<g:set var="biocacheLink">
    <g:if test="${actionName != 'index' && user && user.userId}">${si.generateBiocacheLink(dataResourceUids: dataResourceUids, userId: user.userId)}</g:if>
    <g:else>${si.generateBiocacheLink(dataResourceUids: dataResourceUids)}</g:else>
</g:set>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>${pageHeading}</title>
    <r:require modules="moment, bootbox, pigeonhole"/>
</head>
<body class="nav-species">
<g:render template="/topMenu" model="[pageHeading: pageHeading, biocacheLink: biocacheLink]"/>
<div class="row">
    <div class="col-sm-12">
        <g:if test="${flash.message?:flash.errorMessage}">
            <div class="container-fluid">
                <div class="alert ${(flash.errorMessage) ? 'alert-error' : 'alert-info'}">
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${raw(flash.message?:flash.errorMessage)}
                </div>
            </div>
        </g:if>
    </div>
</div>
<div class="row">
    <div class="col-sm-12 col-md-12 col-lg-12">
        <div class="row" id="content">
            <div class="col-md-12">
                <div class="panel panel-body">
                    <div class="panel-heading">
                        This is a simple list of the sightings
                        <g:if test="${actionName == 'user' && params.id}">${user?.displayName?:'[unknown username]'} has submitted.</g:if>
                        <g:elseif test="${actionName == 'user'}">you have submitted.</g:elseif>
                        <g:elseif test="${actionName == 'index'}">submitted recently by users.</g:elseif>
                        You can filter, sort and map sightings using the Atlas'
                        <a href="${biocacheLink}">Occurrence explorer</a>.
                        <div class=""><strong>Note:</strong> Sightings may take up to 24 hours to appear in the <a href="${biocacheLink}">Occurrence explorer</a> pages.</div>
                    </div>
                    <div class="panel-body">
                        <g:if test="${sightings && sightings.list}">
                            <div class="" id="sightingsBlurb">
                            </div>
                            <g:if test="${sightings?.total > 0}">
                                <div class="">
                                    <div id="sortWidget">Sort by:
                                    <g:select from="${grailsApplication.config.sortFields}" valueMessagePrefix="sort" id="sortBy" name="sortBy" value="${params.sort?:'lastUpdated'}"/>
                                    <g:select from="${['asc','desc']}" valueMessagePrefix="order" id="orderBy" name="orderBy" value="${params.order?:'desc'}"/>
                                    </div>
                                    <div id="recordsPaginateSummary">
                                        <g:set var="total" value="${sightings.total}"/>
                                        <g:set var="fromIndex" value="${(params.offset) ? (params.offset.toInteger() + 1) : 1}"/>
                                        <g:set var="toIndex" value="${((params.offset?:0).toInteger() + (params.max?:10).toInteger())}"/>
                                        Displaying records ${fromIndex} to ${(toIndex < total) ? toIndex : total} of ${g.formatNumber(number: total, format: "###,##0")}
                                    </div>
                                </div>
                            </g:if>
                            <div class="table-responsive">
                                <table class="table table-bordered table-condensed table-striped" id="sightingsTable">
                                    <thead>
                                    <tr>
                                        <th>Images</th>
                                        <th style="width:20%;">Identification</th>
                                        <th>Sighting info</th>
                                        <g:if test="${user?.userId && user.userId == s?.userId || auth.ifAnyGranted(roles:'ROLE_ADMIN', "1")}"><th>Action</th></g:if>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <g:each in="${sightings.list}" var="s">
                                        <tr id="s_${s.occurrenceID}" data-tags="${(si.getTags(sighting: s)).encodeAsJavaScript()}" data-uuid="${s.occurrenceID}">
                                            <td>
                                                <g:if test="${(s.offensiveFlag == null || s.offensiveFlag?.toBoolean() == false) && s.multimedia}">
                                                    <g:each in="${s.multimedia}" var="i" status="st">
                                                        <g:set var="imagUrls" value="${s.multimedia.collect{it.identifier}}"/>
                                                        <g:if test="${i.thumbnailUrl?:i.identifier && st < 1}">
                                                            <a href="#imageModal2" role="button" class="imageModal" style="white-space:nowrap;" data-imgurls='${imagUrls.encodeAsJSON()}' title="view full sized image" target="original"><img src="${i.thumbnailUrl?:i.identifier}" alt="sighting photo thumbnail"
                                                                                                                                                                                                                                               style="max-height: 175px;  max-width: 175px;"/>${s.multimedia.size() > 1 ? "&times;${s.multimedia.size()}" : ""}</a>
                                                        </g:if>
                                                    </g:each>
                                                </g:if>
                                                <g:elseif test="${s.multimedia}">
                                                    [image has been flagged as inappropriate]
                                                    <g:if test="${auth.ifAnyGranted(roles:'ROLE_ADMIN', "1")}">
                                                        <button class="btn btn-default btn-sm unflagBtn" data-recordid="${s.occurrenceID}"><i class="fa fa-flag-o"></i>&nbsp;Unflag image/s</button>
                                                    </g:if>
                                                </g:elseif>
                                                <g:else>
                                                    <g:img dir="images" file="noImage.jpg" style="max-height:130px;  max-width: 130px; opacity: 0.6;"/>
                                                </g:else>
                                            </td>
                                            <td>
                                                <span class="speciesName">${s.scientificName}</span>
                                                <div>${s.commonName}</div>
                                                <g:if test="${s.tags}"><div class="tagGroup">
                                                    <g:each in="${s.tags}" var="t"><span class="label label-default">${raw(t)}</span> </g:each>
                                                </div></g:if>
                                                <g:if test="${s.identificationVerificationStatus}">
                                                    <div class="tagGroup"><span class="label label-default">${s.identificationVerificationStatus}</span></div>
                                                </g:if>
                                                <g:if test="${grailsApplication.config.showBiocacheLinks && s.occurrenceID}">
                                                    <a href="${grailsApplication.config.biocache.baseURL}/occurrence/${s.occurrenceID}">View public record</a>
                                                </g:if>
                                                <g:if test="${!grailsApplication.config.hideTaxonOverflowLinks?.asBoolean() || params.show_to}">
                                                    <g:if test="${s.taxonoverflowURL}">
                                                        <div><a href="${s.taxonoverflowURL}" class="btn btn-default btn-sm questionBtn" title="View the Community identification discussion of this record">
                                                            <i class="fa fa-comments"></i> View community identification</a></div>
                                                    </g:if>
                                                    <g:elseif test="${s.multimedia && grailsApplication.config.hideTaxonOverflowLinks.toBoolean() || params.show_to}">
                                                        <div><a class="btn btn-default btn-sm flagBtn" href="#flagModal" role="button" data-occurrenceid="${s.occurrenceID}" title="Suggest this record might require an identification or confirmation" style="white-space: nowrap">
                                                            <i class="fa fa-comments-o"></i> Suggest an identification</a></div>
                                                    </g:elseif>
                                                    <g:if test="${s.identifiedBy}">
                                                        <div>Identified by: ${s.identifiedBy}</div>
                                                        <div><i class="fa fa-check"></i>&nbsp;<a href="${s.taxonoverflowURL}">Identification community verified</a></div>
                                                    </g:if>
                                                </g:if>
                                            </td>
                                            <td>
                                                <span style="white-space:nowrap;">
                                                    <g:if test="${!org.codehaus.groovy.grails.web.json.JSONObject.NULL.equals(s.get("eventDate"))}">
                                                        <span class="eventDateFormatted" data-isodate="${s.eventDate}">${(s.eventDate.size() >= 10) ? s.eventDate?.substring(0,10) : s.eventDate}</span>
                                                    </g:if>
                                                    <g:set var="userNameMissing" value="User ${s.userId}"/>
                                                    <div>Recorded by: <a href="${g.createLink(mapping: 'spotter', id: s.userId)}" title="View other sightings by this user">${s.recordedBy?:userNameMissing}</a></div>
                                                </span>
                                                <g:if test="${s.locality}">
                                                    <div>Locality: ${s.locality}</div>
                                                </g:if>
                                                <g:if test="${s.decimalLatitude && s.decimalLatitude != 'null' && s.decimalLongitude && s.decimalLongitude != 'null' }">
                                                    <div>
                                                        <a href="#" class="mapPopup tooltips" data-lat="${s.decimalLatitude}" data-lng="${s.decimalLongitude}" title="Click to see map"><i class="fa fa-location-arrow"></i> ${s.decimalLatitude?.round(5)}, ${s.decimalLongitude?.round(5)}</a>
                                                    </div>
                                                </g:if>
                                            </td>
                                            <g:if test="${user?.userId && user?.userId == s?.userId || auth.ifAnyGranted(roles:'ROLE_ADMIN', "1")}"><td>
                                                <div class="actionButtons">
                                                    <a href="${g.createLink(controller: 'submitSighting', action:'edit', id: s.occurrenceID)}" class="btn btn-default btn-sm editBtn" data-recordid="occurrenceID"><i class="fa fa-pencil"></i> Edit</a>
                                                    <button class="btn btn-default btn-sm deleteRecordBtn" data-recordid="${s.occurrenceID}"><i class="fa fa-trash"></i>&nbsp;Delete</button>
                                                </div>
                                            </td></g:if>
                                        </tr>
                                    </g:each>
                                    </tbody>
                                </table>
                            </div>
                            <div class="col-md-12" style="text-align: center;">
                                <g:set var="mappingName"><g:if test="${actionName == 'index'}">recent</g:if><g:elseif test="${actionName == 'user' && params.id}">spotter</g:elseif><g:else>mine</g:else></g:set>
                                <g:paginate total="${sightings.total?:0}" mapping="${mappingName}" id="${params.id}"/>
                            </div>
                            <!-- Image Modal -->
                        %{--<div class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">--}%
                        %{--<div class="modal-header">--}%
                        %{--<button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>--}%
                        %{--<h3 id="myModalLabel">Sighting image</h3>--}%
                        %{--</div>--}%
                        %{--<div class="modal-body">--}%
                        %{--<img id="originalImage" src="${g.resource(dir:'images',file:'spinner.gif')}" alt="original image file for sighting"/>--}%
                        %{--</div>--}%
                        %{--<div class="modal-footer">--}%
                        %{--<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>--}%
                        %{--</div>--}%
                        %{--</div>--}%
                            <div id="imageModal2" class="modal fade">
                                <div class="modal-dialog modal-lg">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                                            <h4 class="modal-title">Sighting images</h4>
                                        </div>
                                        <div class="modal-body">
                                            <img id="originalImage" src="${g.resource(dir:'images',file:'spinner.gif')}" alt="original image file for sighting"/>
                                        </div>
                                        <div class="modal-footer">
                                            <div class="pull-left">
                                                <button type="button" id="prevImage" class="btn btn-default" disabled><i class="fa fa-chevron-circle-left"></i> Prev</button>
                                                <button type="button" id="nextImage" class="btn btn-default" disabled>Next <i class="fa fa-chevron-circle-right"></i></button>
                                            </div>
                                            <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                                        </div>
                                    </div><!-- /.modal-content -->
                                </div><!-- /.modal-dialog -->
                            </div><!-- /.modal -->

                        <!-- Flag Modal -->
                            <div id="flagModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="flagModalLabel" aria-hidden="true">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                                    <h3 id="flagModalLabel">Raise a question about a sighting</h3>
                                </div>
                                <div class="modal-body">
                                    <div>Please provide a reason category for why this record requires reviewing:</div>
                                    <div class="requiredBlock">
                                        <g:select from="${grailsApplication.config.flag?.issues}" id="questionType" name="questionType" valueMessagePrefix="reason" noSelection="['':'-- choose a reason--']" class="col-md-8"/>
                                        <i class="fa fa-asterisk"></i>
                                    </div>
                                    <div>Add a short comment describing the reason for questioning this record:</div>
                                    <div class="requiredBlock">
                                        <g:textArea name="comment" id="comment" rows="8" class="col-md-8"/>
                                        <i class="fa fa-asterisk"></i>
                                    </div>
                                    <input type="hidden" id="occurrenceId" name="occurrenceId" value=""/>
                                </div>
                                <div class="modal-footer">
                                    <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
                                    <button id="submitFlagIssue" class="btn btn-primary">Submit</button>
                                </div>
                            </div>
                            <r:script>
                            $(document).ready(function() {
                                // delete record button confirmation
                                $('.deleteRecordBtn').click(function(e) {
                                    e.preventDefault();
                                    var id = $(this).data('recordid');
                                    bootbox.confirm("Are you sure you want to permanently delete this record?", function(result) {
                                        if (result) {
                                            window.location = "${g.createLink(controller: 'sightings', action:'delete')}/" + id;
                                        }
                                    });
                                });

                                // Use Moment.js to output time in correct timezone
                                // ISO date stores time in UTC but this gets outputted in local time for user
                                // not perfect but fixes issues where users complain their sighting date/time is wrong
                                // due to UTC timezone storage
                                $.each($('.eventDateFormatted'), function(i, el) {
                                    var isoDate = $(this).data('isodate');
                                    var outputDate = moment(isoDate).format("DD-MM-YYYY, HH:mm");
                                    $(this).text(outputDate);
                                });

                                $('#sortBy').change(function(e) {
                                    e.preventDefault();
                                    window.location = "?sort=" + $(this).val();
                                });

                                $('#orderBy').change(function(e) {
                                    e.preventDefault();
                                    window.location = "?sort=${params.sort?:'lastUpdated'}&order=" + $(this).val();
                                });

                                // trigger image viewer in modal
                                $('.imageModal').click(function(e) {
                                     e.preventDefault();
                                     var urls = $(this).data('imgurls');
                                     var initialUrl = $('#originalImage').attr('src');

                                     if (urls[0]) {
                                        $('#imageModal2').data('imgurls', urls);
                                        $('#prevImage').attr('disabled', true);
                                        $('#nextImage').attr('disabled', true);

                                        $('#imageModal2').modal('show').on('shown.bs.modal', function (e) {
                                            var urls = $(this).data('imgurls');
                                            $('#originalImage').attr('src', urls[0]);
                                            $('#imageModal2').data('index', 0);
                                            if (urls.length > 1) {
                                                $('#nextImage').removeAttr('disabled');
                                            }

                                        }).on('hidden', function () {
                                            $('#originalImage').attr('src', initialUrl);
                                        });
                                     }
                                });

                                // next/prev image buttons in image model
                                $('#imageModal2').on('click', '#nextImage', function(e) {
                                    e.preventDefault();
                                    var i = $('#imageModal2').data('index');
                                    showImageInModal((i + 1), i);
                                });
                                $('#imageModal2').on('click', '#prevImage', function(e) {
                                    e.preventDefault();
                                    var i = $('#imageModal2').data('index');
                                    showImageInModal((i - 1), i);
                                });

                                function showImageInModal(newIndex, oldIndex) {
                                    var urls = $('#imageModal2').data('imgurls');
                                    $('#originalImage').attr('src', urls[newIndex]);
                                    $('#prevImage').removeAttr('disabled');
                                    $('#nextImage').removeAttr('disabled');
                                    if (newIndex == urls.length - 1) {
                                        // last image
                                        $('#nextImage').attr('disabled', true);
                                    } else if (newIndex == 0) {
                                        // first image
                                        $('#prevImage').attr('disabled', true);
                                    }
                                    $('#imageModal2').data('index', newIndex); // reset index stored
                                }

                                var reasonBorderCss = $('#questionType').css('border');
                                var commentBorderCss = $('#comment').css('border');

                                // flag sighting button event handler
                                $('.flagBtn').click(function(e) {
                                    e.preventDefault();
                                    var occurrenceId = $(this).data('occurrenceid');
                                    createIdentificationCase(occurrenceId, "IDENTIFICATION", "");

                                    if (false) {
                                        // NdR - parked this for a later version - keep it as a simple identification case for now
                                        $('#flagModal').modal('show').on('shown', function (event) {
                                            $(this).find('#occurrenceId').val(occurrenceId);
                                        }).on('hidden', function (event) {
                                            $(this).find('#occurrenceId').val('');
                                            $(this).find('#questionType').val('').css('border', reasonBorderCss);
                                            $(this).find('#comment').val('').css('border', commentBorderCss);
                                        });
                                    }

                                });

                                // submit question via "flag" button (modal)
                                $('#submitFlagIssue').click(function(e) {
                                    e.preventDefault();
                                    var occurrenceId = $('#occurrenceId').val();
                                    var questionType = $('#questionType').val();
                                    var comment = $('#comment').val();

                                    if (!(questionType && comment)) {
                                        // validation failed
                                        if (!questionType) {
                                            $('#questionType').css('border','1px solid red');
                                            $('#questionType').on('change', function(e){
                                                $(this).css('border', reasonBorderCss);
                                            });
                                        }
                                        if (!comment) {
                                            $('#comment').css('border','1px solid red');
                                            $('#comment').on('change', function(e){
                                                $(this).css('border', commentBorderCss);
                                            });
                                        }
                                        bootbox.alert('Please fill in required fields (in <span style="color:red;">red</span>)');
                                    } else {
                                        if (questionType == 'INAPPROPRIATE_IMAGE') {
                                            // inappropriate image - hide record
                                            var params = { comment: comment }
                                            $.ajax({
                                                url: "${g.createLink(controller:'sightingAjax', action:'flagInappropriateImage')}/" + occurrenceId,
                                                type: "POST",
                                                data: params,
                                                //contentType: "application/json",
                                                dataType: "json"
                                            })
                                            .done(function(data) {
                                                bootbox.alert("Thank you - record has been flagged.");
                                            })
                                            .fail(function( jqXHR, textStatus, errorThrown ) {
                                                bootbox.alert("Error: " + textStatus + " - " + errorThrown);
                                            })
                                            .always(function() {
                                                // clean-up
                                                $('#flagModal').modal('hide');
                                            });
                                        } else {
                                            createIdentificationCase(occurrenceId, questionType, comment);
                                        }

                                    }
                                });

                                $('.unflagBtn').click(function(e) {
                                    e.preventDefault();
                                    var recordId = $(this).data('recordid');
                                    //console.log("unflagBtn", "${g.createLink(controller:'sightingAjax', action:'unflagRecord')}/" + recordId);
                                    $.get("${g.createLink(controller:'sightingAjax', action:'unflagRecord')}/" + recordId)
                                    .done(function() {
                                        //assume 200 is success
                                        bootbox.alert("Record was unflagged", function() {
                                            location.reload(false);
                                        });
                                    })
                                    .fail(function( jqXHR, textStatus, errorThrown ) {
                                        bootbox.alert("Error un-flagging record: " + textStatus + " - " + errorThrown);
                                    });
                                });

                                $('.mapPopup').click(function(e) {
                                    e.preventDefault();
                                    var latLngStr = $(this).data('lat') + ',' + $(this).data('lng');
                                    bootbox.alert('<img border="0" src="//maps.googleapis.com/maps/api/staticmap?center=' + latLngStr
                                            + '&zoom=15&size=400x400&markers=|' + latLngStr + '" alt="Map view of ' + latLngStr + '">');
                                });

                            }); // end of $(document).ready(function()

                            function getTags(occurrenceId) {
                                //console.log('tags 0', $('#s_' + occurrenceId).data('tags'), $('#s_' + occurrenceId).attr('data-tags'));
                                var rawTags = $('#s_' + occurrenceId).data('tags');
                                var tags;

                                if (rawTags) {
                                    tags = JSON.parse('"'+(rawTags)+'"'); // add surrounding quotes to force string un-encoding
                                    //console.log('tags 1', tags);
                                    tags = JSON.parse(tags); // second round gives JS object
                                }

                                //console.log('tags 2', tags);
                                return tags;
                            }

                            function createIdentificationCase(occurrenceId, questionType, comment) {

                                // send Question through to taxonOverflow via Ajax controller
                                var jsonBody = {
                                    occurrenceId: occurrenceId,
                                    questionType: questionType,
                                    tags: getTags(occurrenceId),
                                    comment: comment
                                }
                                $.ajax({
                                    url: "${g.createLink(controller:'sightingAjax', action:'createQuestion')}",
                                    type: "POST",
                                    data: JSON.stringify(jsonBody),
                                    contentType: "application/json",
                                    dataType: "json"
                                })
                                .done(function(data) {
                                    if (data.success && !data.questionId) {
                                        bootbox.alert("Sighting was flagged successfully");
                                    } else if (data.success && data.questionId) {
                                        // TODO make a nicer looking "response" for user with link to Question page, etc.
                                        bootbox.dialog("Community identification discussion created", [
                                            {   "label" : "Stay on this page",
                                                "class" : "btn"
                                            },
                                            {  "label" : "Take me to identification discussion",
                                                "class" : "btn-success",
                                                "callback": function() {
                                                    window.location = "${grailsApplication.config.taxonoverflow?.baseURL}/question/" + data.questionId;
                                                }
                                            }
                                        ]);
                                    } else if (data.message) {
                                        bootbox.alert(data.message); // shouldn't ever trigger
                                    } else {
                                        bootbox.alert("unexpected error: " + data);
                                    }
                                })
                                .fail(function( jqXHR, textStatus, errorThrown ) {
                                    bootbox.alert("Error: " + textStatus + " - " + errorThrown);
                                })
                                .always(function() {
                                    // clean-up
                                    $('#flagModal').modal('hide');
                                });
                            }
                            </r:script>
                        </g:if>
                        <g:elseif test="${sightings && sightings instanceof org.codehaus.groovy.grails.web.json.JSONObject && sightings.has('error')}">
                            <div class="container-fluid">
                                <div class="alert alert-error">
                                    <b>Error:</b> ${sightings.error} (${sightings.exception})
                                </div>
                            </div>
                        </g:elseif>
                        <g:else>
                            No sightings found
                        </g:else>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
