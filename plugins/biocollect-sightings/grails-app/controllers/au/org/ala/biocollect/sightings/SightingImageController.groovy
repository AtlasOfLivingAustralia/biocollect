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

package au.org.ala.biocollect.sightings

import grails.converters.JSON

import javax.activation.MimetypesFileTypeMap

/**
 * Serve images saved in cache directory so they can be harvested by down-line systems
 */
class SightingImageController {
    def imageService

    def index(String file) {
        log.debug "file = ${file} || params.file = ${params.file}"
        String fileName = "${grailsApplication.config.media.uploadDir}${file}"
        File imageFile = new File(fileName)

        if (imageFile.exists()) {
            MimetypesFileTypeMap mimeTypesMap = new MimetypesFileTypeMap()
            response.setStatus(200)
            response.contentType = mimeTypesMap.getContentType(imageFile)
            response.flushBuffer() // send the headers

            try {
                response.outputStream << imageFile.bytes
                response.outputStream.flush()
                response.outputStream.close()
            } catch (Exception e) {
                log.error e.message, e
            }
            return
        } else {
            render (status: 404, text: "No file found: ${fileName}")
        }
    }

    def exif() {
        def exif = [:]

        if (params.url) {
            exif = imageService.getExifForUrl(params.url)
        }

        render exif as JSON
    }
}
