<r:require
        modules="fileuploads, exif, moment, pigeonhole, bs2_datepicker, udraggable, fontawesome, purl, submitSighting, inview, identify, leafletGoogle, leafletEasyButton"/>

<r:script disposition="head">
        // global var to pass in GSP/Grails values into external JS files
        GSP_VARS = {
            autocompleteUrl: "${autocompleteUrl ?: grailsApplication.config.bie.baseURL + '/ws/search/auto.jsonp'}",
            autocompleteDataType: "${autocompleteUrl ? 'json' : 'jsonp'}",
            biocacheBaseUrl: "${grailsApplication.config.biocache.baseURL + "/ws"}",
            bieBaseUrl: "${(grailsApplication.config.bie.baseURL)}",
            uploadUrl: "${createLink(uri: "/sightingAjax/upload")}",
            bookmarksUrl: "${createLink(controller: "sightingAjax", action: "getBookmarkLocations")}",
            saveBookmarksUrl: "${createLink(controller: "sightingAjax", action: "saveBookmarkLocation")}",
            contextPath: "${request.contextPath}",
            //bookmarks: ${(bookmarks).encodeAsJson() ?: '{}'},
            guid: "${taxon?.guid}",
            speciesGroups: ${(speciesGroupsMap).encodeAsJson() ?: '{}'}, // TODO move this to an ajax call (?)
            leafletImagesDir: "${r.resource(dir: 'vendor/leaflet-0.7.3/images', file: 'marker-icon.png', plugin: 'fieldcapture-sightings').replaceFirst("/marker-icon.png", "")}",
            user: ${(user).encodeAsJson() ?: '{}'},
            sightingBean: ${(sighting).encodeAsJson() ?: '{}'},
            validateUrl: "${createLink(controller: 'sightings', action: 'validate')}",
            defaultMapLng: ${grailsApplication.config.defaultMapLng ?: '134'},
            defaultMapLat: ${grailsApplication.config.defaultMapLat ?: '-28'},
            defaultMapZoom: ${grailsApplication.config.defaultMapZoom ?: '3'},
            geocodeRegion: '${grailsApplication.config.defaultGeocodeRegion ?: 'AU'}',
            expectedRegionName: '${grailsApplication.config.expectedRegionName ?: 'Australasia'}',
            expectedMinLat: ${grailsApplication.config.expectedMinLat ?: '-90'},
            expectedMinLng: ${grailsApplication.config.expectedMinLng ?: '0'},
            expectedMaxLat: ${grailsApplication.config.expectedMaxLat ?: '0'},
            expectedMaxLng: ${grailsApplication.config.expectedMaxLng ?: '180'},
            config: {
                includeSpeciesSelection: ${config?.includeSpeciesSelection == null ? true : config?.includeSpeciesSelection},
                includeMap: ${config?.includeMap == null ? true : config?.includeMap},
                includeImages: ${config?.includeImages == null ? true : config?.includeImages},
                allowGeospatialSpeciesSuggestion: ${config?.allowGeospatialSpeciesSuggestion == null ? true : config?.allowGeospatialSpeciesSuggestion}
            }
    };

    function imgError(image){
        image.onerror = "";
        image.src = GSP_VARS.contextPath + "/images/noImage.jpg";

        //console.log("img", $(image).parents('.imgCon').html());
        //$(image).parents('.imgCon').addClass('hide');// hides species without images
        var hide = ($('#toggleNoImages').is(':checked')) ? 'hide' : '';
        $(image).parents('.imgCon').addClass('noImage ' + hide);// hides species without images
        return true;
    }

</r:script>