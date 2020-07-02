package au.org.ala.biocollect

import grails.converters.JSON
import org.grails.web.converters.marshaller.json.CollectionMarshaller
import org.grails.web.converters.marshaller.json.MapMarshaller
import spock.lang.Specification

/*
 * Copyright (C) 2020 Atlas of Living Australia
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
 * 
 * Created by Temi on 24/6/20.
 */

class GeometryUtilsSpec extends Specification {
    def setup() {
        JSON.registerObjectMarshaller(new MapMarshaller())
        JSON.registerObjectMarshaller(new CollectionMarshaller())
    }

    def "The GeometryUtils class provides a convenience method to check intersection of a point with a shape"() {

        setup:
        Map shape = [
                "type":"Polygon",
                "coordinates":[[[0, 0], [0, 3],  [1, 10], [5, 10], [0, 0]]]
        ]
        Map point = [
                "type":"Point",
                "coordinates":[1, 9]
        ]

        Map pointOutside = [
                "type":"Point",
                "coordinates":[100, 90]
        ]


        when:
        boolean intersect = GeometryUtils.doShapesIntersect(shape, point)

        then:
        intersect == true

        when:
        intersect = GeometryUtils.doShapesIntersect(shape, pointOutside)

        then:
        intersect == false

    }

}
