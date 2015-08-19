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
package au.org.ala.biocollect.sightings.marshaller

import au.org.ala.biocollect.sightings.command.Media
import grails.converters.JSON

/**
 * Created with IntelliJ IDEA.
 *
 * @author "Nick dos Remedios <Nick.dosRemedios@csiro.au>"
 */
class MediaMarshaller {
    void register() {
        JSON.registerObjectMarshaller(Media) { Media media ->

            return [
                    "type" : media.type,
                    "format" : media.format,
                    "identifier" : media.identifier,
                    "imageId" : media.imageId?:'',
                    "title": media.title,
                    //"description": media.description,
                    "created": media.created,
                    "creator": media.creator,
                    "license": media.license,
                    "rightsHolder": media.rightsHolder
            ]
        }
    }
}
