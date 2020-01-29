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
        activityOwnerNameFacet: ['projectActivity', 'activityOwnerName']
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
                        alaId       : 'cl917',
                        alaName     : 'australian_coral_ecoregions',
                        layerName   : 'aust_coral_ecoregions',
                        title: 'Australian Coral Ecoregions',
                        defaultSelected: false,
                        boundaryColour  : '#e66101',
                        showPropertyName: false,
                        fillColour      : '',
                        textColour      : '',
                        userAccessRestriction: 'anyUser',
                        inLayerShapeList     : true,
                        opacity: 0.5,
                        changeLayerColour: false,
                        display     : [
                                cqlFilter     : defaultCqlFilter,
                                propertyName  : 'ECONAME'
                        ],
                        style       : [ : ],
                        bounds      : bounds,
                        restrictions: [ : ]
                ],
                [
                        alaId       : 'cl22',
                        alaName     : 'aus1',
                        layerName   : 'aust_states_territories',
                        title         : 'Australian States',
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
                        title         : 'Local Gov. Areas',
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
                                propertyName  : 'ABB_NAME'
                        ],
                        style       : [:],
                        bounds      : bounds,
                        restrictions: [:]
                ],
                [
                        alaId       : 'cl1059',
                        alaName     : 'drainage_divisions_level2',
                        layerName   : 'aust_river_basins',
                        title         : 'River Basins',
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
                                propertyName  : 'Level2Name'
                        ],
                        style       : [:],
                        bounds      : bounds,
                        restrictions: [:]
                ],
                [
                        alaId       : 'cl10947',
                        alaName     : 'nrm2017_qld2019',
                        layerName   : 'aust_nrm_regions',
                        title         : 'Regions',
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
                                propertyName  : 'NRM_REGION'
                        ],
                        style       : [:],
                        bounds      : bounds,
                        restrictions: [:]
                ],
                [
                        alaId       : 'cl10922',
                        alaName     : 'psma_state_electoral_2018',
                        layerName   : 'aust_state_govt_electorates',
                        title         : "State Gov't Electorates",
                        defaultSelected: false,
                        boundaryColour  : '#ff00c5',
                        showPropertyName: false,
                        fillColour      : '',
                        textColour      : '#0070ff',
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
                ],
                [
                        alaId       : 'cl1083',
                        alaName     : 'user_uploaded_objects',
                        layerName   : 'qld_gbr_catchment',
                        title         : "GBR Catchment",
                        defaultSelected: false,
                        boundaryColour  : '#000000',
                        showPropertyName: false,
                        fillColour      : '',
                        textColour      : '',
                        userAccessRestriction: 'anyUser',
                        inLayerShapeList     : false,
                        opacity: 0.5,
                        changeLayerColour: false,
                        display     : [
                                cqlFilter     : defaultCqlFilter,
                                propertyName  : '',
                                pids          : []
                        ],
                        style       : [:],
                        bounds      : bounds,
                        restrictions: [:]
                ],[
                        alaId       : 'el671',
                        alaName     : 'evap_cv',
                        layerName   : 'evap_cv',
                        title         : "Evaporation - variability",
                        defaultSelected: false,
                        userAccessRestriction: 'anyUser',
                        inLayerShapeList     : false,
                        opacity: 0.5,
                        changeLayerColour: false,
                        display     : [
                                cqlFilter     : defaultCqlFilter,
                                propertyName  : '',
                                pids          : []
                        ],
                        style       : [:],
                        bounds      : bounds,
                        restrictions: [:]
                ]
        ]
}

settings.surveyMethods="fielddata.survey.methods"