aekosSubmission.url = "http://shared-uat.ecoinformatics.org.au:8080/shared-web/api/submission/create"
aekosMintedDoi.url= "http://shared-uat.aekos.org.au:8080/AEKOS.AekosSearchPortal/dataset"

acsaUrl= 'http://csna.gaiaresources.com.au/wordpress/'

bie.baseURL= "https://bie.ala.org.au"
bieWs.baseURL= "https://bie-ws.ala.org.au"

biocache.baseURL= "https://biocache.ala.org.au"

biocollect.support.email.address= "biocollect-support@ala.org.au"

collectory.service.url= "https://collections.ala.org.au"


ecodata.baseURL= "https://ecodata.ala.org.au/"


google {
        maps.base= "https://maps.googleapis.com/maps/api/js?key="
        geocode.url= "https://maps.googleapis.com/maps/api/geocode/json?sensor=false&latlng="
}

environments {
        development {
                grails.config.locations = ["file:///data/biocollect/config/biocollect-config.properties"]
                temp.dir = "/data/biocollect/temp"
//              system level config
                server.port = 8087
                serverURL = "http://localhost:8087"
                biocollect.system.email.replyTo = "biocollect-dev<no-reply>@ala.org.au"
                sender = "biocollect-dev@ala.org.au"
                debugUI = true
                loggerLevel = "DEBUG"
                auth.baseURL = "https://auth-test.ala.org.au"
        }

        test {
                spring.autoconfigure.exclude="au.org.ala.ws.security.AlaWsSecurityConfiguration"
                debugUI = false
                loggerLevel = "DEBUG"
                server.port = "8087"
                grails.host = "http://localhost"
                serverName = "${grails.host}:${server.port}"
                grails.serverURL = serverName
                server.serverURL = serverName
                layout.skin = "bs4"
                app.default.hub='ala'
                runWithNoExternalConfig = true
                wiremock.port = 8018
                grails.config.locations = []
                security.oidc.discoveryUri = "http://localhost:${wiremock.port}/cas/oidc/.well-known"
                security.oidc.allowUnsignedIdTokens = true
                def casBaseUrl = "http://localhost:${wiremock.port}"

                security.cas.appServerName=serverName
                security.cas.contextPath=
                security.cas.casServerName="${casBaseUrl}"
                auth.baseURL = "${casBaseUrl}"
                security.cas.casServerUrlPrefix="${casBaseUrl}/cas"
                security.cas.loginUrl="${security.cas.casServerUrlPrefix}/login"
                security.cas.casLoginUrl="${security.cas.casServerUrlPrefix}/login"
                security.cas.logoutUrl="${security.cas.casServerUrlPrefix}/logout"
                security.jwt.discoveryUri="${casBaseUrl}/cas/oidc/.well-known"
                userDetails.url = "${casBaseUrl}/userdetails/userDetails/"
                userDetailsSingleUrl = "${userDetails.Url}getUserDetails"
                logging.dir = '.'
                upload.images.path = '/tmp'
                upload.images.url = grails.serverURL+'/image/'
                ecodata.baseUrl = 'http://localhost:8080/'
                ecodata.baseURL = 'http://localhost:8080'
                ecodata.service.url = 'http://localhost:8080/ws'
                pdfgen.baseURL = "http://localhost:${wiremock.port}/"
                api_key='testapikey'
                grails.cache.config = {
                        diskStore {
                                path '/tmp'
                        }
                        defaultCache {
                                overflowToDisk false
                        }
                }
                spatial.baseUrl = "http://localhost:${wiremock.port}"
                spatial.baseURL = "http://localhost:${wiremock.port}"
                spatial.geoserverUrl= spatial.baseUrl + "/geoserver"
                spatial.layersUrl = spatial.baseUrl + "/ws"
                bie.baseURL="http://localhost:${wiremock.port}"
                biocache.baseURL="http://localhost:${wiremock.port}"
                pdfgen.baseURL="http://localhost:${wiremock.port}"
                images.baseURL="http://localhost:${wiremock.port}"
                lists.baseURL="http://localhost:${wiremock.port}"
                grails.mail.port = 3025 // com.icegreen.greenmail.util.ServerSetupTest.SMTP.port
                temp.dir="/tmp/stylesheet"
                google.maps.apiKey="testGoogleApi"
        }

        production {
                grails.config.locations = ["file:///data/biocollect/config/biocollect-config.properties"]
                biocollect.system.email.replyTo = "biocollect<no-reply>@ala.org.au"
                sender = "biocollect-local@ala.org.au"
                debugUI = false
                loggerLevel = "INFO"
                auth.baseURL = "https://auth.ala.org.au"
        }
}

casUrl = "${auth.baseURL}/cas/logout"
appUrl = grails.serverURL

security.cas.enabled = false
security.cas.uriExclusionFilterPattern = ['/assets/.*','/uploads/.*']
security.cas.uriFilterPattern = []
security.cas.readOnlyOfficerRole= "ROLE_FC_READ_ONLY"
security.cas.alaAdminRole = "ROLE_ADMIN"
security.cas.officerRole = "ROLE_FC_OFFICER"
security.cas.adminRole = "ROLE_FC_ADMIN"
security.cas.casServerName= "${auth.baseURL}"
security.cas.casServerLoginUrl= "${auth.baseURL}/cas/login"
security.cas.casServerUrlPrefix= "${auth.baseURL}/cas"
security.cas.logoutUrl= "${security.cas.casServerUrlPrefix}/logout"
security.cas.loginUrl= "${security.cas.casServerUrlPrefix}/login"

security.oidc.enabled= true
security.oidc.discoveryUri= "${auth.baseURL}/cas/oidc/.well-known"
security.oidc.clientId= "changeMe"
security.oidc.secret= "changeMe"
security.oidc.scope= "openid,profile,email,ala,roles"
security.oidc.allowUnsignedIdTokens= true

security.jwt.enabled= true
security.jwt.discoveryUri= "${auth.baseURL}/cas/oidc/.well-known"
security.jwt.fallbackToLegacyBehaviour= true

dataAccessMethods = [
        "oasrdfs",
        "oaordfs",
        "lsrds",
        "ordfsvr",
        "oasrdes",
        "casrdes",
        "rdna",
        "odidpa",
        "na"
]

dataQualityAssuranceMethods = [
        "dataownercurated",
        "subjectexpertverification",
        "crowdsourcedverification",
        "recordannotation",
        "systemsupported",
        "nodqmethodsused",
        "na"
    ]

methodType = [
    'opportunistic',
    'systematic'
]

datapage.defaultColumns = [
        [
                type: "image",
                displayName: "Image",
                isSortable: false
        ],
        [
                type: "recordNameFacet",
                displayName: "Identification",
                isSortable: true,
                sort: false,
                order: 'asc',
                code: "recordNameFacet"
        ],
        [
                type: "symbols",
                displayName: "",
                isSortable: false
        ],
        [
                type: "details",
                displayName: "Details",
                isSortable: false
        ],
        [
                type: "property",
                propertyName: "lastUpdated",
                code: "lastUpdated",
                displayName: "Last updated",
                dataType: 'date',
                isSortable: true,
                sort: true,
                order: 'desc'
        ],
        [
                type: "action",
                displayName: "Action",
                isSortable: false
        ]
        ,
        [
                type: "checkbox",
                displayName: "Select item",
                isSortable: false
        ]
]

datapage.allColumns = datapage.defaultColumns + [
        [
                type: "property",
                propertyName: "surveyYearFacet",
                displayName: "Survey Year"
        ]
        ,
        [
                type: "property",
                propertyName: "projectNameFacet",
                displayName: "Project name"
        ]
        ,
        [
                type: "property",
                propertyName: "projectActivityNameFacet",
                displayName: "Survey name"
        ]
        ,
        [
                type: "property",
                propertyName: "organisationNameFacet",
                displayName: "Organisation name"
        ]
        ,
        [
                type: "property",
                propertyName: "surveyMonthFacet",
                displayName: "Survey month"
        ],
        [
                type: "property",
                propertyName: "isDataManagementPolicyDocumented",
                displayName: ""
        ],
        [
                type: "property",
                propertyName: "dataQualityAssuranceMethods",
                displayName: ""
        ],
        [
                type: "property",
                propertyName: "nonTaxonomicAccuracy",
                displayName: ""
        ],
        [
                type: "property",
                propertyName: "temporalAccuracy",
                displayName: ""
        ],
        [
                type: "property",
                propertyName: "activityLastUpdatedMonthFacet",
                displayName: ""
        ],
        [
                type: "property",
                propertyName: "activityLastUpdatedYearFacet",
                displayName: ""
        ],
        [
                type: "property",
                propertyName: "associatedProgramFacet",
                displayName: ""
        ],
        [
                type: "property",
                propertyName: "siteNameFacet",
                displayName: ""
        ],
        [
                type: "property",
                propertyName: "spatialAccuracy",
                displayName: ""
        ],
        [
                type: "property",
                propertyName: "associatedSubProgramFacet",
                displayName: ""
        ],
        [
                type: "property",
                propertyName: "methodType",
                displayName: ""
        ],
        [
                type: "property",
                propertyName: "activityOwnerNameFacet",
                displayName: "Owner"
        ],
        [
                type: "property",
                propertyName: "verificationStatusFacet",
                displayName: "Verification status"
        ]
]


activitypropertypath = [
        surveyYearFacet: ['surveyYear'],
        projectNameFacet: ['projectActivity', 'projectName'],
        projectActivityNameFacet: ['projectActivity', 'name'],
        organisationNameFacet: ['projectActivity', 'organisationName'],
        surveyMonthFacet: ['projectActivity', 'surveyMonth'],
        isDataManagementPolicyDocumented: ['projectActivity', 'isDataManagementPolicyDocumented'],
        dataQualityAssuranceMethods: ['projectActivity', 'dataQualityAssuranceMethods'],
        nonTaxonomicAccuracy: ['projectActivity', 'nonTaxonomicAccuracy'],
        temporalAccuracy: ['projectActivity', 'temporalAccuracy'],
        speciesIdentification: ['projectActivity', 'speciesIdentification'],
        activityLastUpdatedMonthFacet: ['projectActivity', 'lastUpdatedMonth'],
        activityLastUpdatedYearFacet: ['projectActivity', 'lastUpdatedYear'],
        associatedProgramFacet: ['associatedProgram'],
        siteNameFacet: ['sites', 'name'],
        associatedSubProgramFacet: ['projectActivity', 'associatedSubProgram'],
        spatialAccuracy: ['projectActivity', 'spatialAccuracy'],
        methodType: ['projectActivity', 'methodType'],
        activityOwnerNameFacet: ['projectActivity', 'activityOwnerName'],
        verificationStatusFacet: ['verificationStatus']

]


content.defaultOverriddenLabels = [
        [
                id: 1,
                showCustomText: false,
                page: 'Project finder',
                defaultText: 'Showing XXXX to YYYY of ZZZZ projects',
                customText:'',
                notes: 'This text is generated dynamically. XXXX, YYYY & ZZZZ are replaced with dynamically generated content.'
        ],
        [
                id: 2,
                showCustomText: false,
                page: 'Project > "About" tab',
                defaultText: 'About the project',
                customText:'',
                notes: 'Section heading on project\'s about tab.'
        ],
        [
                id: 3,
                showCustomText: false,
                page: 'Project > "About" tab',
                defaultText: 'Aim',
                customText:'',
                notes: 'Section heading on project\'s about tab.'
        ],
        [
                id: 4,
                showCustomText: false,
                page: 'Project > "About" tab',
                defaultText: 'Description',
                customText:'',
                notes: 'Section heading on project\'s about tab.'
        ],
        [
                id: 5,
                showCustomText: false,
                page: 'Project > "About" tab',
                defaultText: 'Project information',
                customText:'',
                notes: 'Section heading on project\'s about tab.'
        ],
        [
                id: 6,
                showCustomText: false,
                page: 'Project > "About" tab',
                defaultText: 'Program name',
                customText:'',
                notes: 'Section heading on project\'s about tab.'
        ],
        [
                id: 7,
                showCustomText: false,
                page: 'Project > "About" tab',
                defaultText: 'Subprogram name',
                customText:'',
                notes: 'Section heading on project\'s about tab.'
        ],
        [
                id: 8,
                showCustomText: false,
                page: 'Project > "About" tab',
                defaultText: 'Project Area',
                customText:'',
                notes: 'Section heading for Map.'
        ],
        [
                id: 9,
                showCustomText: false,
                page: 'Project > "Resources" tab',
                defaultText: 'Resources',
                customText:'',
                notes: 'Section heading on project\'s resources tab.'
        ],
        [
                id: 10,
                showCustomText: false,
                page: 'Hub > "Charts" tab',
                defaultText: 'Dashboard',
                customText:'',
                notes: 'Section heading on project\'s charts tab.'
        ]
]

/*
 * Notes:
 * These are all approximately (but not exactly) the same. It is important that 'GetMap' requests include the 'SRS' (default is EPSG:3857).
 * EPSG:4283 GDA94
 * EPSG:4326 WGS 84
 * EPSG:3857 WGS 84 / Pseudo-Mercator
 */

// Bounds are in EPSG:4326.
def boundsSrs = "EPSG:4283"
def bounds = [:]
def defaultCqlFilter = ""
if (bounds.size()) {
        defaultCqlFilter = "BBOX(the_geom,${bounds.lngWestMin},${bounds.latSouthMin},${bounds.lngEastMax},${bounds.latNorthMax},'${boundsSrs}')"
}
if (!map.baseLayers) {
        map.baseLayers = [
                [
                        'code': 'minimal',
                        'displayText': 'Road map',
                        'isSelected': false
                ],
                [
                        'code': 'worldimagery',
                        'displayText': 'Satellite',
                        'isSelected': false
                ],
                [
                        'code': 'detailed',
                        'displayText': 'Detailed',
                        'isSelected': false
                ],
                [
                        'code': 'topographic',
                        'displayText': 'ESRI Topographic',
                        'isSelected': true
                ],
                [
                        'code': 'googlehybrid',
                        'displayText': 'Google hybrid',
                        'isSelected': false
                ],
                [
                        'code': 'googleroadmap',
                        'displayText': 'Google roadmap',
                        'isSelected': false
                ],
                [
                        'code': 'googleterrain',
                        'displayText': 'Google terrain',
                        'isSelected': false
                ]
        ]
}

if(!map.overlays) {
        map.overlays = [
                [
                        alaId       : 'cl22',
                        alaName     : 'aus1',
                        layerName   : 'aust_states_territories',
                        title         : 'States and territories',
                        defaultSelected: false,
                        boundaryColour  : '#fdb863',
                        showPropertyName: false,
                        fillColour      : '',
                        textColour      : '',
                        userAccessRestriction: 'anyUser',
                        inLayerShapeList     : true,
                        opacity: 0.5,

                        display     : [
                                cqlFilter     : defaultCqlFilter,
                                propertyName  : 'NAME_1'
                        ],
                        style       : [:],
                        bounds      : bounds,
                        restrictions: [:]
                ],
                [
                        alaId       : 'cl10923',
                        alaName     : 'psma_lga_2018',
                        layerName   : 'aust_local_govt_areas',
                        title         : 'Local government',
                        defaultSelected: false,
                        boundaryColour  : '#b2abd2',
                        showPropertyName: false,
                        fillColour      : '',
                        textColour      : '',
                        userAccessRestriction: 'anyUser',
                        inLayerShapeList     : true,
                        opacity: 0.5,
                        changeLayerColour: false,
                        display     : [
                                cqlFilter     : defaultCqlFilter,
                                propertyName  : 'LGA_NAME'
                        ],
                        style       : [:],
                        bounds      : bounds,
                        restrictions: [:]
                ],
                [
                        alaId       : 'cl1048',
                        alaName     : 'ibra7_regions',
                        layerName   : '',
                        title         : 'Biogeographic regions',
                        defaultSelected: false,
                        boundaryColour  : '#b2abd2',
                        showPropertyName: false,
                        fillColour      : '',
                        textColour      : '',
                        userAccessRestriction: 'anyUser',
                        inLayerShapeList     : true,
                        opacity: 0.5,
                        changeLayerColour: false,
                        display     : [
                                cqlFilter     : defaultCqlFilter,
                                propertyName  : 'REG_NAME_7'
                        ],
                        style       : [:],
                        bounds      : bounds,
                        restrictions: [:]
                ],
                [
                        alaId       : 'cl21',
                        alaName     : 'imcra4_pb',
                        layerName   : '',
                        title         : 'Marine regions',
                        defaultSelected: false,
                        boundaryColour  : '#b2abd2',
                        showPropertyName: false,
                        fillColour      : '',
                        textColour      : '',
                        userAccessRestriction: 'anyUser',
                        inLayerShapeList     : true,
                        opacity: 0.5,
                        changeLayerColour: false,
                        display     : [
                                cqlFilter     : defaultCqlFilter,
                                propertyName  : 'PB_NAME'
                        ],
                        style       : [:],
                        bounds      : bounds,
                        restrictions: [:]
                ],
                [
                        alaId       : 'cl10930',
                        alaName     : 'nrm_regions_2017',
                        layerName   : '',
                        title         : 'NRM Regions',
                        defaultSelected: false,
                        boundaryColour  : '#b2abd2',
                        showPropertyName: false,
                        fillColour      : '',
                        textColour      : '',
                        userAccessRestriction: 'anyUser',
                        inLayerShapeList     : true,
                        opacity: 0.5,
                        changeLayerColour: false,
                        display     : [
                                cqlFilter     : defaultCqlFilter,
                                propertyName  : 'NRM_REGION'
                        ],
                        style       : [:],
                        bounds      : bounds,
                        restrictions: [:]
                ],
                [
                        alaId       : 'cl1059',
                        alaName     : 'drainage_divisions_level2',
                        layerName   : '',
                        title         : 'Major drainage divisions',
                        defaultSelected: false,
                        boundaryColour  : '#b2abd2',
                        showPropertyName: false,
                        fillColour      : '',
                        textColour      : '',
                        userAccessRestriction: 'anyUser',
                        inLayerShapeList     : true,
                        opacity: 0.5,
                        changeLayerColour: false,
                        display     : [
                                cqlFilter     : defaultCqlFilter,
                                propertyName  : 'Level2Name'
                        ],
                        style       : [:],
                        bounds      : bounds,
                        restrictions: [:]
                ],
                [
                        alaId       : 'cl901',
                        alaName     : 'diwa_type_criteria',
                        layerName   : '',
                        title         : 'Directory of important wetlands',
                        defaultSelected: false,
                        boundaryColour  : '#b2abd2',
                        showPropertyName: false,
                        fillColour      : '',
                        textColour      : '',
                        userAccessRestriction: 'anyUser',
                        inLayerShapeList     : true,
                        opacity: 0.5,
                        changeLayerColour: false,
                        display     : [
                                cqlFilter     : defaultCqlFilter,
                                propertyName  : 'WNAME'
                        ],
                        style       : [:],
                        bounds      : bounds,
                        restrictions: [:]
                ],
                [
                        alaId       : 'cl935',
                        alaName     : 'ramsar',
                        layerName   : '',
                        title         : 'RAMSAR wetland regions',
                        defaultSelected: false,
                        boundaryColour  : '#005ce6',
                        showPropertyName: false,
                        fillColour      : '#bef7cf',
                        textColour      : '#FFF',
                        userAccessRestriction: 'anyUser',
                        inLayerShapeList     : true,
                        opacity: 0.5,
                        changeLayerColour: false,
                        display     : [
                                cqlFilter     : defaultCqlFilter,
                                propertyName  : 'RAMSAR_NAM'
                        ],
                        style       : [:],
                        bounds      : bounds,
                        restrictions: [:]
                ],
                [
                        alaId       : 'cl2015',
                        alaName     : 'ipa_7aug13',
                        layerName   : '',
                        title         : 'Indigenous protected areas',
                        defaultSelected: false,
                        boundaryColour  : '#5e3c99',
                        showPropertyName: false,
                        fillColour      : '',
                        textColour      : '',
                        userAccessRestriction: 'anyUser',
                        inLayerShapeList     : true,
                        opacity: 0.5,
                        changeLayerColour: false,
                        display     : [
                                cqlFilter     : defaultCqlFilter,
                                propertyName  : 'NAME'
                        ],
                        style       : [:],
                        bounds      : bounds,
                        restrictions: [:]
                ]
        ]
}

settings.surveyMethods="fielddata.survey.methods"
if (!app.file.script.path) {
        app.file.script.path = "/data/biocollect/scripts"
}
script.read.extensions.list = ['js','min.js','png', 'json', 'jpg', 'jpeg']
