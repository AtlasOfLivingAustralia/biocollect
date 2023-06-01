var singleSighting = {
  "dateCreated" : ISODate("2022-02-15T13:08:29.111Z"),
  "minOptionalSectionsCompleted" : 1,
  "supportsSites" : false,
  "lastUpdated" : ISODate("2022-02-15T13:08:29.111Z"),
  "createdUserId" : "<anon>",
  "supportsPhotoPoints" : false,
  "publicationStatus" : "published",
  "name" : "Single Sighting",
  "sections" : [
    {
      "collapsedByDefault" : false,
      "template" : {
        "dataModel" : [
          {
            "dataType" : "date",
            "name" : "surveyDate",
            "dwcAttribute" : "eventDate",
            "description" : "The date on which the sighting was made.",
            "validate" : "required"
          },
          {
            "dataType" : "time",
            "name" : "surveyStartTime",
            "dwcAttribute" : "eventTime",
            "description" : "The time at which the sighting was made."
          },
          {
            "dataType" : "text",
            "name" : "notes",
            "dwcAttribute" : "eventRemarks",
            "description" : "General remarks about the survey event, including any characteristic site features, conditions, etc."
          },
          {
            "dataType" : "text",
            "name" : "recordedBy",
            "dwcAttribute" : "recordedBy",
            "description" : "The name of the person who is attributed with making the sighting."
          },
          {
            "columns" : [
              {
                "dwcAttribute" : "verbatimLatitude",
                "source" : "locationLatitude"
              },
              {
                "dwcAttribute" : "verbatimLongitude",
                "source" : "locationLongitude"
              }
            ],
            "dataType" : "geoMap",
            "name" : "location",
            "dwcAttribute" : "verbatimCoordinates",
            "validate" : "required"
          },
          {
            "dataType" : "species",
            "name" : "species",
            "dwcAttribute" : "scientificName",
            "description" : "The species name of the plant, animal or fungus observed.",
            "validate" : "required"
          },
          {
            "defaultValue" : "1",
            "dataType" : "number",
            "name" : "individualCount",
            "dwcAttribute" : "individualCount",
            "description" : "The number of individuals or colonies (for certain insects).",
            "validate" : "min[0]"
          },
          {
            "dataType" : "text",
            "name" : "identificationConfidence",
            "description" : "How certain are you that you have correctly identified your sighting? Only choose 'certain' if you are 100% sure.",
            "constraints" : [
              "Certain",
              "Uncertain"
            ]
          },
          {
            "dataType" : "text",
            "name" : "comments",
            "dwcAttribute" : "notes",
            "description" : "Observation notes about the record."
          },
          {
            "dataType" : "image",
            "name" : "sightingPhoto",
            "description" : "Upload a photo taken of the species at the time of the record. This is essential for verification of the record.",
            "validate" : "required"
          }
        ],
        "modelName" : "ad-hoc_species_sightings",
        "record" : "true",
        "viewModel" : [
          {
            "type" : "row",
            "items" : [
              {
                "computed" : null,
                "source" : "Record your individual sightings of species in the project region.",
                "type" : "literal"
              }
            ]
          },
          {
            "type" : "row",
            "items" : [
              {
                "computed" : null,
                "type" : "col",
                "items" : [
                  {
                    "computed" : null,
                    "source" : "<h4>Step 1: Upload one or more of the best images of your sighting.</h4><i>This is strongly recommended so that the record can be validated and used in scientific work.</i>",
                    "type" : "literal"
                  },
                  {
                    "preLabel" : "Sighting photo",
                    "computed" : null,
                    "source" : "sightingPhoto",
                    "type" : "image"
                  },
                  {
                    "computed" : null,
                    "source" : "<h4>Step 2: Check & update or Record the details of your sighting.</h4>",
                    "type" : "literal"
                  },
                  {
                    "computed" : null,
                    "source" : "<h3>Sighting Event Information</h3>",
                    "type" : "literal"
                  },
                  {
                    "preLabel" : "Survey date",
                    "computed" : null,
                    "source" : "surveyDate",
                    "type" : "date"
                  },
                  {
                    "preLabel" : "Survey start time",
                    "computed" : null,
                    "source" : "surveyStartTime",
                    "type" : "time"
                  },
                  {
                    "preLabel" : "Notes",
                    "computed" : null,
                    "source" : "notes",
                    "type" : "textarea"
                  },
                  {
                    "preLabel" : "Recorded by",
                    "computed" : null,
                    "source" : "recordedBy",
                    "type" : "text"
                  },
                  {
                    "computed" : null,
                    "source" : "<h3>Single Species Sighting</h3>",
                    "type" : "literal"
                  },
                  {
                    "preLabel" : "Species name",
                    "computed" : null,
                    "source" : "species",
                    "type" : "autocomplete"
                  },
                  {
                    "computed" : null,
                    "source" : "<i>Start typing a common or scientific name.</i>",
                    "type" : "literal"
                  },
                  {
                    "preLabel" : "Are you confident of the species identification?",
                    "computed" : null,
                    "source" : "identificationConfidence",
                    "type" : "selectOne"
                  },
                  {
                    "preLabel" : "How many individuals did you see?",
                    "computed" : null,
                    "source" : "individualCount",
                    "type" : "number"
                  },
                  {
                    "preLabel" : "Comments",
                    "computed" : null,
                    "source" : "comments",
                    "type" : "textarea"
                  }
                ]
              },
              {
                "computed" : null,
                "type" : "col",
                "items" : [
                  {
                    "orientation" : "vertical",
                    "computed" : null,
                    "readonly" : true,
                    "source" : "location",
                    "type" : "geoMap"
                  }
                ]
              }
            ],
            "class" : "output-section"
          }
        ]
      },
      "templateName" : "singleSighting",
      "optional" : false,
      "name" : "Single Sighting"
    }
  ],
  "type" : "Activity",
  "category" : "Assessment & monitoring",
  "status" : "active",
  "lastUpdatedUserId" : "<anon>",
  "formVersion" : 1
}
