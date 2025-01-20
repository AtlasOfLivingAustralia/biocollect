package au.org.ala.biocollect.swagger.model

import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import io.swagger.v3.oas.annotations.media.Schema

/*
 * Copyright (C) 2022 Atlas of Living Australia
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
 * Created by Temi on 14/7/22.
 */
@JsonIgnoreProperties('metaClass')
class ActivityAjaxUpdate {
    List<Output> outputs
    String siteId
    Map photoPoints
    @Schema(description = "Name of the ActivityForm")
    String type
}

@JsonIgnoreProperties('metaClass')
class SiteAjaxUpdate {
    Boolean visibility
    String projectId
    List projects
    String pActivityId
    Boolean asyncUpdate
    Map extent
    String name
}

@JsonIgnoreProperties('metaClass')
class SiteCreateUpdateResponse {
    String status
    String message
    String id
}

@JsonIgnoreProperties('metaClass')
class Output {
    String activityId
    String outputId
    @Schema(description = "Name of a section in ActivityForm. ActivityForm has one or more sections.")
    String name
    Data data
}

@JsonIgnoreProperties('metaClass')
@Schema(description = "This data structure contains data in the format defined in the data model of a Section in ActvityForm. Because the data model is flexible, no properties are added to this schema.")
class Data {
    @Schema(description = "List of staged photos to upload to ecodata")
    List<Multimedia> multimedia
}

@JsonIgnoreProperties('metaClass')
class Multimedia {
    String filename
    String title
    String format
    String license
}

@JsonIgnoreProperties('metaClass')
class FileUpload {
    @Schema(
            description = "File to upload",
            type = "string",
            format = "binary"
    )
    String files
}

@JsonIgnoreProperties('metaClass')
class UploadResponse {
    List<FileUploadResponse> files
}

@JsonIgnoreProperties('metaClass')
class FileUploadResponse {
        String name
        Integer size
        String isoDate
        String contentType
        String date
        String time
        String decimalLatitude
        String decimalLongitude
        String verbatimLatitude
        String verbatimLongitude
        String url
        String thumbnail_url
        String delete_url
        String delete_type
        String attribution
}

@JsonIgnoreProperties('metaClass')
class FileUploadErrorResponse {
    String error
}


// classes for ws/bioactivity/save
@JsonIgnoreProperties('metaClass')
class ActivitySaveResponse {
    ActivitySaveResp resp
    Integer statusCode
    String error
}

@JsonIgnoreProperties('metaClass')
class ActivitySaveResp {
    String activityId
    String message
}

@JsonIgnoreProperties('metaClass')
class ErrorResponse {
    String error
    int status
}

// classes for /ws/species/uniqueId
@JsonIgnoreProperties('metaClass')
class GetOutputSpeciesIdentifierError {
    @Schema( description = "Status word")
    String status
    @Schema( description = "Descriptive error message")
    String error
}

@JsonIgnoreProperties('metaClass')
class GetOutputSpeciesIdentifierResponse {
    String outputSpeciesId
}


// classes for
@JsonIgnoreProperties('metaClass')
class DeleteActivityResponse {
    @Schema( description = "Status code")
    Integer status
    @Schema( description = "Descriptive error message")
    String error
    String text
}

@JsonIgnoreProperties('metaClass')
class SearchProjectActivitiesResponse {
    List<Activity> activities
    List<Facet> facets
    Integer total
}

@JsonIgnoreProperties('metaClass')
class Activity {
    String activityId
    String projectActivityId
    String type
    String status
    String lastUpdated
    String userId
    String siteId
    String name
    String activityOwnerName
    Boolean embargoed
    String embargoUntil
    List<Record> records
    String endDate
    String projectName
    String projectType
    String projectId
    String thumbnailUrl
    Boolean showCrud
    Boolean userCanModerate
}

@JsonIgnoreProperties('metaClass')
class Record {
    String commonName
    List<ActivityMultimedia> multimedia
    Integer individualCount
    String name
    List<Float> coordinates
    String eventTime
    String guid
    String occurrenceID
    String eventDate
}

@JsonIgnoreProperties('metaClass')
class ActivityMultimedia {
    String rightsHolder
    String identifier
    String license
    String creator
    String imageId
    String rights
    String format
    String documentId
    String title
    String type

}

@JsonIgnoreProperties('metaClass')
class Facet {
    String name
    Integer total
    List<Map> terms
}

@JsonIgnoreProperties('metaClass')
class GetProjectActivitiesRecordsForMappingResponse {
    Integer total
    List<ActivityMap> activities
}

@JsonIgnoreProperties('metaClass')
class ActivityMap {
    String activityId
    String projectActivityId
    String type
    String name
    String activityOwnerName
    List<Record> records
    String projectName
    String projectId
    List<Site> sites
    List<Float> coordinates
}

@JsonIgnoreProperties('metaClass')
class Site {
       Extend extent
        String lastUpdated
        List<String> projects
        String dateCreated
        String visibility
        String name
        String siteId
        String id
        List<Float> geoPoint
        Boolean isSciStarter
        String status
}

@JsonIgnoreProperties('metaClass')
class Extend {
    Geometry geometry
    String source
}

@JsonIgnoreProperties('metaClass')
class Geometry {
    Integer areaKmSq
    List<Float> coordinates
    List<Float> centre
    String type
}

// classes for "ws/bioactivity/data/{id}
@JsonIgnoreProperties('metaClass')
class GetOutputForActivityResponse {
    Map activity
    Site site
    Map project
    Map projectSite
    List speciesLists
    List themes
    Map metaModel
    Map outputModels
    Map pActivity
    String projectActivityId
    String error
}

// class ws/bioactivity/model/{id}
@JsonIgnoreProperties('metaClass')
class GetActivityModelResponse {
    Map activity
    String returnTo
    Site site
    Map project
    Map projectSite
    List speciesLists
    List themes
    Map metaModel
    Map outputModels
    Map pActivity
    String error
}


// class /ws/project/searc
@JsonIgnoreProperties('metaClass')
class ProjectSearchResponse {
    List<Map> projects
    Integer total
    List<Facet> facets
}

// classes for "ws/bioactivity/data/simplified/{id}/{includeSiteData}
@JsonIgnoreProperties('metaClass')
class GetOutputForActivitySimplifiedResponse {
    Map activity
    String error
}
