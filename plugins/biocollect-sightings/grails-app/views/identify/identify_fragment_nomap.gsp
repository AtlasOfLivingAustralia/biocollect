%{--
  - Copyright (C) 2015 Atlas of Living Australia
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
<!DOCTYPE html>
<html>
	<head>
		<meta name="layout" content="ajax"/>
        <title>Identify | Atlas of Living Australia</title>
        <r:require modules="jquery-ui, pigeonhole, identify, inview, purl, fontawesome"/>
        <r:script disposition="head">
            // global var to pass in GSP/Grails values into external JS files
            GSP_VARS = {
                biocacheBaseUrl: "${grailsApplication.config.biocache.baseURL + "/ws"}",
                bieBaseUrl: "${(grailsApplication.config.bie.baseURL)}",
                contextPath: "${request.contextPath}",
                lat: ${params.lat},
                lng: ${params.lng}
            }
        </r:script>
    </head>
    <body>
    <g:if test="${!(params.lat || params.lng)}">
        <div class="container-fluid">
            <div class="alert alert-error">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <b>Error:</b> No location information provided<br>Minimum requirements is latitude (lat) and longitude(lng).
            </div>
        </div>
    </g:if>
    <g:else>
        <div class="intro">
            This tool assists in the identification of a sighting by providing a list of suggested species known to occur at the
            sighting location, broken down into common species "groups".<br>
            <g:if test="${params.locality}"><b>Location: </b> ${params.locality}</g:if>
            <p>Searching for species within a <g:select name="radius" id="radius" class="select-mini" from="${[1,2,5,10,20]}" value="${defaultRadius?:5}"/>
            km area</p>
        </div>
        <div class="boxed-heading" id="species_group" data-content="Choose to a species group">
            <p>Select a species group</p>
            <r:img uri="/images/spinner.gif" class="spinner1 "/>
            <div id="speciesGroup"><span>[searching ...]</span></div>
            <p class="hide">Select a species sub-group (optional)</p>
            <div id="speciesSubGroup"></div>
            <div class="clearfix"></div>
        </div>
        <div class="boxed-heading" id="browse_species_images" data-content="Browse species images">
            <p>
                Look for images that match the species you are trying to identify. Click the image for more example images of that species and finally click the "select this image" button.
                <br><g:checkBox name="toggleNoImages" id="toggleNoImages" class="" value="${true}"/> hide species without images
            </p>
            <div id="speciesImagesDiv">
                <span>[choose a species group first]</span>
            </div>
            <r:img uri="/images/spinner.gif" class="spinner2 hide"/>
        </div>

        <!-- Modal -->
        <div id="imgModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="imgModalLabel" aria-hidden="true">
            <div class="modal-header">
                <button type="button" class="close" aria-hidden="true">×</button>
                <h3 id="imgModalLabel"></h3>
            </div>
            <div class="modal-body">
                <r:img uri="/images/spinner.gif" id="spinner3" class="spinner "/>
                <div class="" id="singleSpeciesImages"></div>
                <div id="imgConClone" class="imgCon hide">
                    <a href="#" class="cbLink thumbImage tooltips" rel="thumbs">
                        <img src="" alt="species thumbnail" onerror="imgError(this);"/>
                        <div class="meta brief"></div>
                        <div class="meta detail hide"><span class="scientificName"></span><br><span class="commonName"></span></div>
                    </a>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn" aria-hidden="true">Close</button>
                <button class="btn btn-primary pull-left" id="selectedSpeciesBtn">Select this species</button>
            </div>
        </div>
    </g:else>
	</body>
</html>
