print("This script is expected to be executed with a working directory containing this script");
print("Current working dir: "+process.cwd());
load('../data_common/loadAlaHub.js');
load("../data_common/insertData.js");
loadActivityForms();

var  activityProject = {
    "bushfireCategories" : [],
    "origin" : "atlasoflivingaustralia",
    "dateCreated" : ISODate("2022-04-07T07:12:58.072Z"),
    "promoteOnHomepage" : "no",
    "ecoScienceType" : [],
    "countries" : [
        "Australia"
    ],
    "name" : "Test project",
    "funding" : 0.0,
    "isCitizenScience" : true,
    "uNRegions" : [
        "Oceania"
    ],
    "industries" : [],
    "tags" : [
        "noCost"
    ],
    "lastUpdated" : ISODate("2022-04-07T07:12:59.036Z"),
    "isBushfire" : false,
    "alaHarvest" : false,
    "scienceType" : [
        "Birds"
    ],
    "isMERIT" : false,
    "status" : "active",
    "isSciStarter" : false,
    "isExternal" : false,
    "projectId" : "project_1",
    "aim" : "Test Aim",
    "associatedOrgs" : [],
    "associatedProgram" : "Citizen Science Projects",
    "baseLayer" : "",
    "description" : "Test Description",
    "facets" : [],
    "fundings" : [],
    "isEcoScience" : false,
    "isWorks" : false,
    "legalCustodianOrganisation" : "Atlas of Living Australia",
    "legalCustodianOrganisationType" : "",
    "projLifecycleStatus": "published",
    "mapLayersConfig" : {
        "baseLayers" : [],
        "overlays" : []
    },
    "orgGrantee" : "",
    "orgSponsor" : "",
    "organisationId" : "3a04141a-2290-4c54-aee3-a433d60b4476",
    "organisationName" : "Atlas of Living Australia",
    "plannedStartDate" : ISODate("2022-04-06T14:00:00.000Z"),
    "projectSiteId" : "ab9ec9af-241b-49f7-adcf-ca40e474d119",
    "projectType" : "survey",
    "regenerateProjectTimeline" : false,
    "task" : "collect plants",
    "termsOfUseAccepted" : true
};
db.project.insert(activityProject);
db.userPermission.insert({
    entityType: 'au.org.ala.ecodata.Project',
    entityId: activityProject.projectId,
    userId: '1',
    accessLevel: 'editor'
});
db.userPermission.insert({
    entityType: 'au.org.ala.ecodata.Project',
    entityId: activityProject.projectId,
    userId: '2',
    accessLevel: 'admin'
});

var projectActivity = {
    "speciesIdentification" : "high",
    "visibility" : {
        "alaAdminEnforcedEmbargo" : false,
        "embargoOption" : "NONE"
    },
    "surveySiteOption" : "sitepickcreate",
    "sites" : [
        "ab9ec9af-241b-49f7-adcf-ca40e474d119"
    ],
    "temporalAccuracy" : "high",
    "canEditAdminSelectedSites" : false,
    "dateCreated" : ISODate("2022-04-07T07:21:23.388Z"),
    "spatialAccuracy" : "high",
    "dataManagementPolicyDocument" : "",
    "dataQualityAssuranceDescription" : "Data quality assurance test",
    "lastUpdated" : ISODate("2022-04-07T07:22:28.163Z"),
    "publicAccess" : true,
    "submissionRecords" : [],
    "allowAdditionalSurveySites" : false,
    "legalCustodianOrganisation" : "Atlas of Living Australia",
    "dataSharingLicense" : "https://creativecommons.org/publicdomain/zero/1.0/",
    "restrictRecordToSites" : false,
    "commentsAllowed" : false,
    "methodName" : "Opportunistic/ad-hoc observation recording",
    "dataManagementPolicyDescription" : "",
    "startDate" : ISODate("2022-04-06T14:00:00.000Z"),
    "dataManagementPolicyURL" : "",
    "methodType" : "opportunistic",
    "dataQualityAssuranceMethods" : [
        "dataownercurated"
    ],
    "projectActivityId" : "pa_1",
    "dataAccessExternalURL" : "",
    "name" : "Test survey",
    "status" : "active",
    "dataAccessMethods" : [],
    "nonTaxonomicAccuracy" : "high",
    "projectId" : activityProject.projectId,
    "description" : "Test description",
    "isDataManagementPolicyDocumented" : false,
    "methodUrl" : "",
    "previewUrl" : "",
    "documents" : [],
    "downloadFormTemplateUrl" : "",
    "selectedDocument" : "",
    "methodDocUrl" : "",
    "alert" : {
        "emailAddresses" : [],
        "allSpecies" : []
    },
    "methodAbstract" : "",
    "methodDocName" : "",
    "usageGuide" : "",
    "speciesFields" : [
        {
            "dataFieldName" : "species",
            "output" : "Single Sighting",
            "context" : "",
            "label" : "Species name",
            "config" : {
                "type" : "ALL_SPECIES",
                "speciesDisplayFormat" : "SCIENTIFICNAME(COMMONNAME)"
            }
        }
    ],
    "defaultZoomArea" : "ab9ec9af-241b-49f7-adcf-ca40e474d119",
    "published" : true,
    "relatedDatasets" : [],
    "allowPolygons" : false,
    "allowLine" : false,
    "allowPoints" : true,
    "attribution" : "Atlas of Living Australia, Test survey",
    "displaySelectedLicence" : [],
    "mapLayersConfig" : {
        "baseLayers" : [],
        "overlays" : []
    },
    "pActivityFormName" : "Single Sighting"
}
db.projectActivity.insert(projectActivity);

var site = {
    "projects" : [
        "project_1"
    ],
    "dateCreated" : ISODate("2022-04-07T07:12:56.343Z"),
    "lastUpdated" : ISODate("2022-04-07T07:13:28.815Z"),
    "catchment" : "",
    "notes" : "",
    "siteId" : "ab9ec9af-241b-49f7-adcf-ca40e474d119",
    "extent" : {
        "geometry" : {
            "datum" : "",
            "fid" : "",
            "areaKmSq" : 200.627883229948,
            "precision" : "",
            "lga" : [
                "Yass Valley (A)",
                "Unincorporated ACT"
            ],
            "bbox" : "",
            "nrm" : [
                "South East NSW",
                "ACT"
            ],
            "locality" : "QVMP+VM Uriarra NSW, Australia",
            "coordinates" : [
                148.88671875,
                -35.2153316684663
            ],
            "decimalLongitude" : 148.88671875,
            "centre" : [
                "148.88671726683353",
                "-35.21533929655656"
            ],
            "aream2" : 200597595.863365,
            "decimalLatitude" : -35.2153316684663,
            "pid" : 9121748,
            "mvs" : "",
            "uncertainty" : "",
            "type" : "Circle",
            "name" : "",
            "state" : [
                "Australian Capital Territory",
                "New South Wales (including Coastal Waters)"
            ],
            "layerName" : "",
            "radius" : 7993.38666198557,
            "mvg" : "",
            "ibra" : [
                "South Eastern Highlands"
            ],
            "elect" : [
                "BEAN",
                "FENNER",
                "EDEN-MONARO"
            ],
            "cmz" : [
                "South Eastern Australia mixed temperate forests woodlands and grasslands"
            ],
            "other" : [
                "ACT TAMS Reserves",
                "NSW Local Land Services Regions",
                "Great Eastern Ranges Initiative",
                "Indigenous Land Use Agreements"
            ],
            "gerSubRegion" : [
                "GER Kosciuszko to Coast"
            ]
        },
        "source" : "drawn"
    },
    "name" : "Project area for Test project",
    "type" : "",
    "status" : "active",
    "isSciStarter" : false,
    "description" : "",
    "area" : 200.627883229948,
    "externalId" : "",
    "poi" : [],
    "userId" : ""
}
db.site.insert(site);