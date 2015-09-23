<div class="row">
    <div class="span12">
        <g:set var="errorsShown" value="${false}"/>
        <g:hasErrors bean="${sighting}">
            <g:set var="errorsShown" value="${true}"/>
            <div class="">
                <div class="alert alert-danger">
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${raw(flash.message)}
                    <g:eachError var="err" bean="${sighting}">
                        <li><g:message code="sighting.field.${err.field}"/> - <g:fieldError bean="${sighting}"
                                                                                            field="${err.field}"/></li>
                    </g:eachError>
                </div>
            </div>
        </g:hasErrors>
        <g:if test="${!errorsShown && (flash.message || sighting?.error)}">
            <div class="">
                <div class="alert alert-danger">
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${raw(flash.message) ?: sighting?.error}
                </div>
            </div>
        </g:if>
    </div>
</div>

<g:if test="${sighting && !sighting?.error || !sighting}">
        <input type="hidden" name="occurrenceID" id="occurrenceID" value="${sighting?.occurrenceID}"/>
        <input type="hidden" name="userId" id="userId" value="${sighting?.userId ?: user?.userId}"/>
        <input type="hidden" name="recordedBy" id="recordedBy" value="${sighting?.recordedBy ?: user?.displayName}"/>

        <!-- Species -->
    <div id="sighting">
        <div class="boxed-heading" id="species" data-content="Species">
            <div class="row-fluid">
                <div class="span4">
                    <div id="taxonDetails" class="well well-small" style="display: none">
                        <table class="hidden">
                            <tr>
                                <td><img src="" class="speciesThumbnail" alt="thumbnail image of species"
                                         style="width:75px; height:75px;"/></td>
                                <td>
                                    <div class="sciName">
                                        <a href="" class="tooltips" title="view species page" target="BIE">species name</a>
                                    </div>

                                    <div class="commonName">common name</div>
                                </td>
                            </tr>
                        </table>

                        <div class="row-fluid">
                            <div class="span4">
                                <img src="" width="75" class="speciesThumbnail" alt="thumbnail image of species"
                                     style="width:75px; height:75px;"/>
                            </div>

                            <div class="span8">
                                <div class="sciName">
                                    <a href="" class="tooltips" title="view species page" target="BIE">species name</a>
                                </div>

                                <div class="commonName">common name</div>
                            </div>
                        </div>
                        <input type="hidden" name="taxonConceptID" id="guid" value="${taxon?.taxonConceptID}"/>
                        <input type="hidden" name="scientificName" id="scientificName" value="${taxon?.scientificName}"/>
                        <input type="hidden" name="commonName" id="commonName" value="${taxon?.commonName}"/>
                        <input type="hidden" name="kingdom" id="kingdom" value="${taxon?.kingdom}"/>
                        <input type="hidden" name="family" id="family" value="${taxon?.family}"/>
                        %{--<input type="hidden" name="identificationVerificationStatus" id="identificationVerificationStatus" value="${taxon?.identificationVerificationStatus}"/>--}%
                        %{--<a href="#" class="close removeHide" title="remove this item"><span aria-hidden="true">&times;</span></a>--}%
                    </div>

                    <div class="well well-small" id="noSpecies">
                        <div class="row-fluid" style="font-size:15px;">
                            <div class="span3">
                                <i class="fa fa-image" style="font-size:36px; margin-right:10px;"></i>
                            </div>

                            <div class="span9">
                                No species selected
                            </div>
                        </div>
                    </div>

                    <div id="tagsBlock"></div>
                </div>

                <div class="span8">
                    <div id="showConfident" class="control-group">
                        <label class="control-label" for="speciesLookup">
                            <div id="noTaxa"
                                 style="display: inherit;">Type a scientific or common name into the box below and choose from the auto-complete list.</div>

                            <div id="matchedTaxa"
                                 style="display: none;">Not the right species? To change identification, type a scientific
                            or common name into the box below and choose from the auto-complete list.</div>
                        </label>
                        <input class="span12 ${hasErrors(bean: sighting, field: 'scientificName', 'validationErrors')}"
                               data-validation-engine="validate[funcCall[validateSpeciesSelection]]"
                               id="speciesLookup" type="text" placeholder="Start typing a species name (common or latin)">
                    </div>

                    <div id="showUncertain" class="control-group">
                        <label>How confident are you with the species identification?
                            <g:set var="confidenceGuess" value="${(taxon?.guid) ? 'confident' : 'uncertain'}"/>
                            <g:radioGroup name="identificationVerificationStatus" labels="['Confident', 'Uncertain']"
                                          values="['confident', 'uncertain']"
                                          value="${sighting?.identificationVerificationStatus?.toLowerCase() ?: confidenceGuess}">
                                <span style="white-space:nowrap;">${it.radio}&nbsp;${it.label}</span>
                            </g:radioGroup>
                        </label>
                    </div>

                    <div id="identificationChoice" class="form-group">
                        <label for="speciesGroups"><strong>(Optional)</strong> Tag this sighting with species group and/or sub-group:
                        </label>

                        <div class="row-fluid">
                            <div class="span6">
                                <g:select name="tag" from="${speciesGroupsMap?.keySet()}" id="speciesGroups"
                                          class="span12 input-sm ${hasErrors(bean: sighting, field: 'scientificName', 'validationErrors')}"
                                          noSelection="['': '-- Species group --']"/>
                            </div>

                            <div class="span6">
                                <g:select name="tag" from="${[]}" id="speciesSubgroups" class="span12 input-sm"
                                          noSelection="['': '-- Subgroup (select a group first) --']"/>
                            </div>
                        </div>
                    </div>
                    <g:if test="${grailsApplication.config.include.taxonoverflow}">
                        <div id="speciesMisc" class="hide">
                            <label for="requireIdentification" class="checkbox">
                                <g:checkBox id="requireIdentification" name="requireIdentification"
                                            value="${(sighting?.requireIdentification)}"/>
                                Ask the Taxon-Overflow community to assist with or confirm the identification (requires a photo of the sighting)
                            </label>
                        </div>
                    </g:if>
                </div>

                <g:if test="${grailsApplication.config.identify.enabled.toBoolean()}">
                    <div id="identifyHelpTrigger">Unsure of the species name? Try the location-based: <a
                            href="#identifyHelpModal" class="identifyHelpTrigger btn btn-primary btn-small"><i
                                class="fa fa-search"></i> Species Suggestion Tool</a></div>
                </g:if>
            </div>
        </div>

        <!-- Media -->
        <div class="boxed-heading" id="media" data-content="Images">

            <div class="controls">
                <!-- The fileinput-button span is used to style the file input field as button -->
                <span class="btn btn-primary fileinput-button control-label"
                      title="Select one or more photos to upload (you can also simply drag and drop files onto the page).">
                    <i class="icon icon-white icon-plus"></i>
                    <span>Add files...</span>
                    <!-- The file input field used as target for the file upload widget -->
                    <input id="fileupload" type="file" name="files[]" multiple>
                </span>
                <span style="display: inline-block;"><strong>(Optional)</strong> Add one or more images. Image metadata will be used to automatically set date and location fields (where available)
                    <br><strong><i class="fa fa-info-circle"></i> Hint:
                </strong> you can drag and drop files onto this window</span>
                <br>
            </div>
            <br/>

            <!-- The container for the uploaded files -->
            <div id="files" class="files"></div>

            <div id="imageLicenseDiv" class="form-horizontal">
                <div class="control-group">
                    <label for="imageLicense" class="control-label">Licence:</label>

                    <div class="controls">
                        <g:select from="${grailsApplication.config.sighting.licenses}" name="imageLicense" class="span5"
                                  id="imageLicense"
                                  value="${sighting?.multimedia ? sighting?.multimedia?.get(0)?.license : ''}"/>
                    </div>
                </div>
            </div>
        </div>

        <!-- Location -->
        <div class="boxed-heading" id="location" data-content="Location">
            <div class="row-fluid">
                <div class="span6" id="mapWidget">
                    <div class="row-fluid">
                        <div class="span4">
                            <button class="btn btn-default span11" id="useMyLocation">
                                <i class="fa fa-location-arrow fa-lg"
                                   style="margin-left:-2px;margin-right:2px;"></i> Current location <r:img
                                    uri="/images/spinner.gif" class="spinner0" style="display:none;height: 18px;"/>
                            </button>
                        </div>

                        <div class="span1" style="text-align: center;">
                            <span class="badge pull-right" style="font-size:14px;margin:5px 0">OR</span>
                        </div>

                        <div class="span7">
                            <div class="input-append span12">
                                <input id="geocodeinput" class="span10" style="margin-left: 10px;" type="text"
                                       placeholder="Enter an address, location or lat/lng">
                                <span class="input-group-btn">
                                    <button id="geocodebutton" class="btn btn-default"><i class="fa fa-search"></i></button>
                                </span>
                            </div><!-- /input-group -->
                        </div>
                    </div>

                    <div style="position:relative;">
                        <div id="map" style="width: 100%; height: 280px"></div>

                        <div class="" id="mapTip"><strong><i class="fa fa-info-circle"></i> Hint:
                        </strong> drag the marker to fine-tune your location
                            <img class="drag" id="markerIcon"
                                 src="${r.resource(dir: 'vendor/leaflet-0.7.3/images', file: 'marker-icon.png', plugin: 'fieldcapture-sightings')}"
                                 alt="marker icon"/>
                        </div>
                    </div>

                </div>

                <div class="span6 form-horizontal" style="margin-bottom: 0px;">
                    <div class="control-group">
                        <label for="decimalLatitude" class="control-label">Latitude (decimal):</label>

                        <div class="controls">
                            <input type="text" name="decimalLatitude" id="decimalLatitude"
                                   class="form-control ${hasErrors(bean: sighting, field: 'decimalLatitude', 'validationErrors')}"
                                   value="${sighting?.decimalLatitude}"/>
                        </div>
                    </div>

                    <div class="control-group">
                        <label for="decimalLongitude" class="control-label">Longitude (decimal):</label>

                        <div class="controls">
                            <input type="text" name="decimalLongitude" id="decimalLongitude"
                                   class="form-control ${hasErrors(bean: sighting, field: 'decimalLongitude', 'validationErrors')}"
                                   value="${sighting?.decimalLongitude}"/>
                        </div>
                    </div>

                    <div class="control-group">
                        <label for="coordinateUncertaintyInMeters" class="control-label">Accuracy (metres):</label>

                        <div class="controls">
                            <g:select
                                    from="${grailsApplication.config.accuracyValues ?: [0, 10, 50, 100, 500, 1000, 10000]}"
                                    id="coordinateUncertaintyInMeters"
                                    class="form-control  ${hasErrors(bean: sighting, field: 'coordinateUncertaintyInMeters', 'validationErrors')}"
                                    name="coordinateUncertaintyInMeters"
                                    value="${sighting?.coordinateUncertaintyInMeters ?: 50}" noSelection="['': '--']"/>
                        </div>
                    </div>

                    <div class="control-group">
                        <label for="georeferenceProtocol" class="control-label">Source of coordinates:</label>

                        <div class="controls">
                            <g:select from="${grailsApplication.config.coordinates.sources}" id="georeferenceProtocol" class="form-control "
                                      name="georeferenceProtocol" value="${sighting?.georeferenceProtocol}"/>
                        </div>
                    </div>

                    <div class="control-group">
                        <label for="locality" class="control-label">Matched locality:</label>

                        <div class="controls">
                            <textarea id="locality" name="locality" class="form-control disabled"
                                      rows="3">${sighting?.locality}</textarea>
                        </div>
                    </div>

                    <div class="control-group">
                        <label for="locationRemark" class="control-label">Location notes:</label>

                        <div class="controls">
                            <textarea id="locationRemark" name="locationRemark" class="form-control" rows="3"
                                      value="${sighting?.decimalLatitude}">${sighting?.locationRemark}</textarea>
                        </div>
                    </div>

                    <div class="control-group">
                        <label for="bookmarkedLocations" class="control-label">Saved locations:</label>

                        <div class="controls">
                            <div class="input-append">
                                <g:select name="bookmarkedLocations" id="bookmarkedLocations" from="${[]}" optionKey=""
                                          optionValue="" noSelection="['': '-- saved locations --']"/>
                                <span class="input-group-btn">
                                    <button id="bookmarkLocation" class="btn btn-primary disabled" disabled="disabled"
                                            title="Save this location"><i class="fa fa-save"></i> Save</button>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Details -->
        <div class="boxed-heading" id="details" data-content="Details">
            <div class="row-fluid">
                <div class="span6 form-horizontal">
                    <div class="control-group">
                        <label for="dateStr" class="span2 control-label">Date:</label>

                        <div class="controls span10">
                            <div class="input-append date" id='datetimepicker1'>
                                <input type="text" id="dateStr" name="dateStr"
                                       class="${hasErrors(bean: sighting, field: 'eventDate', 'validationErrors')}"
                                       placeholder="DD-MM-YYYY" data-validation-engine="validate[required]"
                                       value="${si.getDateTimeValue(date: sighting?.eventDate, part: 'date')}"/>
                                <span class="add-on"><i class="fa fa-calendar"></i></span>
                            </div>
                            <span class="helphint">Required</span>
                        </div>
                    </div>

                    <div class="control-group">
                        <label for="timeStr" class="span2 control-label">Time:</label>

                        <div class="controls span10">
                            <div class='input-append date' id='datetimepicker2'>
                                <input type='text' id="timeStr" name="timeStr" class="form-control" placeholder="HH:MM"
                                       value="${si.getDateTimeValue(date: sighting?.eventDate, part: 'time')}"/>
                                <span class="add-on"><i class="fa fa-clock-o"></i></span>
                            </div>
                            <span class="helphint">24 hour format</span>
                        </div>
                    </div>

                    <div class="control-group">
                        <label for="individualCount" class="span2 control-label">Individuals:</label>

                        <div class="controls span10">
                            <g:select from="${1..99}" name="individualCount" class="input-sm form-control smartspinner"
                                      value="${sighting?.individualCount}"
                                      data-validation-engine="validate[custom[integer], min[1]]" id="individualCount"/>
                            <span class="helphint">How many did you see?</span>
                        </div>
                    </div>
                    <input type="hidden" name="timeZoneOffset" id="timeZoneOffset" value="${sighting?.timeZoneOffset}"/>
                    <input type="hidden" name="eventDate" id="eventDate" value="${sighting?.eventDate}"/>
                </div>

                <div class="span6">
                    <section class="sightings-block form-horizontal" style="vertical-align: top;">
                        <div class="control-group">
                            <label for="occurrenceRemarks" class="span2 control-label">Notes:</label>

                            <div class="controls span10">
                                <textarea name="occurrenceRemarks" rows="6" cols="90" class="form-control"
                                          id="occurrenceRemarks">${sighting?.occurrenceRemarks}</textarea>
                            </div>
                        </div>
                    </section>
                </div>
            </div>
        </div>

        <%-- Template HTML used by JS code via .clone() --%>
        <div class="hide imageRow row-fluid" id="uploadActionsTmpl">
            <div class="span2"><span class="preview pull-right"></span></div>

            <div class="span10">
                <div class="metadata media">
                    Filename: <span class="filename"></span>
                    %{--<input type="hidden" class="media" value=""/>--}%
                    %{--TODO: convert to a proper form and allow user to change these and other values via a hide/show option--}%
                    <input type="hidden" class="title" value=""/>
                    <input type="hidden" class="format" value=""/>
                    <input type="hidden" class="identifier" value=""/>
                    <input type="hidden" class="imageId" value=""/>
                    <input type="hidden" class="license" value=""/>
                    <input type="hidden" class="created" value=""/>
                    <input type="hidden" class="creator" value=""/>
                </div>

                <div class="metadata">
                    Image date: <span class="imgDate">not available</span>
                </div>

                <div class="metadata">
                    GPS coordinates: <span class="imgCoords">not available</span>
                </div>
                %{--<button class="btn btn-small imageDate">Use image date</button>--}%
                %{--<button class="btn btn-small imageLocation">Use image location</button>--}%
                <button class="btn btn-sm btn-info imageData" title="No metadata found" disabled>Use image metadata</button>
                <button class="btn btn-sm btn-danger imageRemove" title="remove this image">Remove image</button>
            </div>

            <div class="error hide"></div>
        </div>
        <!-- Modal -->
        <div id="identifyHelpModal" class="modal hide fade">
            %{--<div class="modal-dialog modal-lg">--}%
            %{--<div class="modal-content">--}%
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span
                        aria-hidden="true">&times;</span></button>

                <h3 id="identifyHelpModalLabel">See species known to occur in a particular location</h3>
            </div>

            <div class="modal-body">
                <g:render template="/identify/widget_nomap"/>
            </div>

            <div class="modal-footer">
                <div class="pull-left" style="margin-top:10px;">Searching for species within a <g:select name="radius"
                                                                                                         id="radius"
                                                                                                         class="select-mini"
                                                                                                         from="${[1, 2, 5, 10, 20]}"
                                                                                                         value="${defaultRadius ?: 5}"/>
                km area - increase to see more species</div>
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>

</g:if>