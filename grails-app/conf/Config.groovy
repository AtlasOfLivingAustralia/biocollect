/******************************************************************************\
 *  CONFIG MANAGEMENT
 \******************************************************************************/
def ENV_NAME = "${appName.toUpperCase()}_CONFIG"
default_config = "/data/${appName}/config/${appName}-config.properties"
if(!grails.config.locations || !(grails.config.locations instanceof List)) {
    grails.config.locations = []
}

if(System.getenv(ENV_NAME) && new File(System.getenv(ENV_NAME)).exists()) {
    println "[${appName}] Including configuration file specified in environment: " + System.getenv(ENV_NAME);
    grails.config.locations.add "file:" + System.getenv(ENV_NAME)
} else if(System.getProperty(ENV_NAME) && new File(System.getProperty(ENV_NAME)).exists()) {
    println "[${appName}] Including configuration file specified on command line: " + System.getProperty(ENV_NAME);
    grails.config.locations.add "file:" + System.getProperty(ENV_NAME)
} else if(new File(default_config).exists()) {
    println "[${appName}] Including default configuration file: " + default_config;
    grails.config.locations.add "file:" + default_config
} else {
    println "[${appName}] No external configuration file defined."
}

// Resolves the "calculated" config properties
grails.config.locations.add LastEvaluatedConfig

println "[${appName}] (*) grails.config.locations = ${grails.config.locations}"

/******************************************************************************\
 *  RELOADABLE CONFIG
 \******************************************************************************/
reloadable.cfgs = ["file:/data/${appName}/config/${appName}-config.properties"]

grails.project.groupId = "au.org.ala" // change this to alter the default package name and Maven publishing destination
grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.use.accept.header = true
grails.mime.types = [
        all:           '*/*',
        atom:          'application/atom+xml',
        css:           'text/css',
        csv:           'text/csv',
        form:          'application/x-www-form-urlencoded',
        html:          ['text/html','application/xhtml+xml'],
        js:            'text/javascript',
        json:          ['application/json', 'text/json'],
        multipartForm: 'multipart/form-data',
        rss:           'application/rss+xml',
        text:          'text/plain',
        xml:           ['text/xml', 'application/xml']
]

grails.resources.resourceLocatorEnabled = true
grails.resources.adhoc.patterns = ['/images/*', '/css/*', '/js/*', '/plugins/*', '/vendor/*']
grails.resources.adhoc.includes = ['/images/**', '/css/**', '/js/**', '/plugins/**', '/vendor/**']

// URL Mapping Cache Max Size, defaults to 5000
//grails.urlmapping.cache.maxsize = 1000

// The default codec used to encode data with ${}
grails.views.default.codec = "none" // none, html, base64
grails.views.gsp.encoding = "UTF-8"
grails.converters.encoding = "UTF-8"
// enable Sitemesh preprocessing of GSP pages
grails.views.gsp.sitemesh.preprocess = true
// scaffolding templates configuration
grails.scaffolding.templates.domainSuffix = 'Instance'

// Set to false to use the new Grails 1.2 JSONBuilder in the render method
grails.json.legacy.builder = false
// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true
// packages to include in Spring bean scanning
grails.spring.bean.packages = []
// whether to disable processing of multi part requests
grails.web.disable.multipart=false

// request parameters to mask when logging exceptions
grails.exceptionresolver.params.exclude = ['password']

// configure auto-caching of queries by default (if false you can cache individual queries with 'cache: true')
grails.hibernate.cache.queries = false

// revert to grails 2.2 behaviour for html escaping until such time as every page can be reviewed.
grails.views.default.codec = "none"

// Field Capture custom configuration
// ----------------------------------
layout.skin = "ala2"

webservice.connectTimeout = 10000
webservice.readTimeout = 20000

//CAS config
security.cas.uriExclusionFilterPattern="/assets/.*,/images.*,/css.*,/js.*,/less.*,/ajax/bulkLookupQuestions,/uploads/.*"
security.cas.authenticateOnlyIfLoggedInPattern=".*"
security.cas.uriFilterPattern=".*/user/.*,.*/site/(?!(index|list|elasticsearch|getImages|getPoiImages|ajaxUpdate)).*,.*/project/(?!(index|search|citizenScience|listRecordImages|projectSummaryReportCallback)).*,.*/activity/(?!index).*,.*/output/(?!index).*,.*/image/(?!index).*,.*/admin/.*,i.*/proxy/speciesListPost,.*/proxy/documentUpdate,.*/proxy/deleteDocument,.*/home/advanced,.*/organisation/(?!index).*,.*/organisation/(?!list).*,.*/bioActivity/create/.*,.*/bioActivity/edit/.*,.*/bioActivity/list,/sight/.*"
security.cas.alaAdminRole = "ROLE_ADMIN"
security.cas.officerRole = "ROLE_FC_OFFICER"
security.cas.adminRole = "ROLE_FC_ADMIN"
security.cas.readOnlyOfficerRole = "ROLE_FC_READ_ONLY"

upload.images.path = "/data/${appName}/images/"
upload.path = "/data/${appName}/"
upload.extensions.blacklist = ['exe','js','php','asp','aspx','com','bat']

app.http.header.userId = "X-ALA-userId"

google.maps.base = 'https://maps.googleapis.com/maps/api/js?key='
google.geocode.url = "https://maps.googleapis.com/maps/api/geocode/json?"
pdfgen.baseURL="http://pdfgen.ala.org.au/"
merit.baseURL="https://fieldcapture-test.ala.org.au"

app.view.nocache = false

// Markdown configuration to match behaviour of the JavaScript editor.
markdown.hardwraps = true

// Sightings
coordinates.sources = ["Google maps", "Google earth", "GPS device", "camera/phone", "physical maps", "other"]
sighting.fields.excludes = ['errors','timeZoneOffset','eventDateNoTime','eventDateTime','class','log','constraints','$constraints']
sighting.licenses = ['Creative Commons Attribution','Creative Commons Attribution-Noncommercial','Creative Commons Attribution-Share Alike','Creative Commons Attribution-Noncommercial-Share Alike']
sortFields=['scientificName','commonName','eventDate','dateCreated','lastUpdated','locality','multimedia']
accuracyValues=[0,10,50,100,500,1000,5000,10000]
//flag.issues = ['Identification','Geocoding Issue','Suspected Outlier','Temporal Issue','Taxonomic Issue','Habitat Issue']
flag.issues = ['IDENTIFICATION','GEOCODING_ISSUE','TEMPORAL_ISSUE','HABITAT_ISSUE','--','INAPPROPRIATE_IMAGE']
showBiocacheLinks = false
identify.subgroupFacet="names_and_lsid"
identify.enabled = true

// Quarantine the EHP industries section to the test environment until this becomes hub configurable.
// This item will be set to true in the test environment only.
projectdata.industries.enabled = false

// ----------------------------------

environments {
    development {
        security.cas.appServerName = 'http://devt.ala.org.au:8087/'
        grails.logging.jul.usebridge = true
        emailFilter = /[A-Z0-9._%-]+@csiro\.au|chris\.godwin\.ala@gmail.com/
        grails {
            mail {
                host = 'localhost'
                port = 1025
            }
        }
    }
    test {
        security.cas.appServerName = 'http://devt.ala.org.au:8087/'
        test.user.admin.email = 'fc-ta@outlook.com'
        test.user.admin.password = 'testing!'
    }
    production {
        security.cas.appServerName = 'https://biocollect.ala.org.au/'
        grails.logging.jul.usebridge = false
        grails.resources.work.dir = "/data/${appName}/cache"
    }
}

def loggingDir = (System.getProperty('catalina.base') ? System.getProperty('catalina.base') + '/logs' : './logs')
if(!(new File(loggingDir).exists())){
    loggingDir = "/tmp"
}

// URL Mapping Cache Max Size, defaults to 5000
//grails.urlmapping.cache.maxsize = 1000
grails.assets.excludes = ["bootstrap/less/**"]
grails.assets.minifyOptions.excludes = ["**/*.min.js"]

// log4j configuration
log4j = {
    appenders {
        environments {
            production {
                rollingFile name: "tomcatLog", maxFileSize: '1MB', file: "${loggingDir}/${appName}.log", threshold: org.apache.log4j.Level.ERROR, layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")
                rollingFile name: 'aekosSubmissionLog',
                        maxFileSize: '1MB',
                        file: loggingDir + "/aekosSubmissionLog.log",
                        layout: pattern(conversionPattern: "%d %-5p [%c{1}]  %m%n")
            }
            development {
                console name: "stdout", layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n"), threshold: org.apache.log4j.Level.DEBUG
                rollingFile name: 'aekosSubmissionLog',
                        maxFileSize: '1MB',
                        file: "/tmp/aekosSubmissionLog.log",
                        layout: pattern(conversionPattern: "%d %-5p [%c{1}]  %m%n")
            }
            test {
                rollingFile name: "tomcatLog", maxFileSize: '1MB', file: "/tmp/${appName}", threshold: org.apache.log4j.Level.DEBUG, layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")
                rollingFile name: 'aekosSubmissionLog',
                        maxFileSize: '1MB',
                        file:  '/tmp/aekosSubmissionLog.log',
                        layout: pattern(conversionPattern: "%d %-5p [%c{1}]  %m%n")

            }
        }
    }
    root {
        // change the root logger to my tomcatLog file
        error 'tomcatLog'
        warn 'tomcatLog'
        additivity = true
    }

    all additivity: false, aekosSubmissionLog: [
            'grails.app.controllers.au.org.ala.biocollect.BioActivityController',
            'grails.app.services.au.org.ala.biocollect.ProjectActivityService',
            'grails.app.services.au.org.ala.biocollect.UtilService'
    ]

    error   'au.org.ala.cas.client',
            'grails.spring.BeanBuilder',
            'grails.plugin.webxml',
            'grails.plugin.cache.web.filter',
            'grails.app.services.org.grails.plugin.resource',
            'grails.app.taglib.org.grails.plugin.resource',
            'grails.app.resourceMappers.org.grails.plugin.resource'

    debug   'grails.app',
            "au.org.ala.cas"
}

if (!grails.cache.config) {

    grails.cache.config = {
        defaults {
            eternal false
            overflowToDisk false
            maxElementsInMemory 20000
            timeToLiveSeconds 3600
        }
    }
}

if (grails.cache.config) {
    grails.cache.config = {
        cache {
            name 'vocabListCache'
            eternal true
        }
    }
}

if (!grails.cache.ehcache) {
    grails {
        cache {
            ehcache {
                cacheManagerName = appName + '-ehcache'
                reloadable = false
            }
        }
    }
}

/******************************************************************************\
 *  EXTERNAL SERVERS
 \******************************************************************************/
if (!collectory.service.url) {
    collectory.service.url = "https://collections.ala.org.au"
}

if (!acsaUrl){
    acsaUrl = 'http://csna.gaiaresources.com.au/wordpress/'
}

if(!biocache.baseURL){
    biocache.baseURL = "https://biocache.ala.org.au"
}

/*
 * Specific configurations used by Biocollect
 */

if(!facets.flimit){
    facets.flimit = 15
}

if(!lists.commonFields){
    lists.commonFields = ['rawScientificName', 'matchedName', 'commonName']
} else if(lists.commonFields instanceof String) {
    lists.commonFields = lists.commonFields.split(',')
}

if(!speciesConfiguration.default){
    speciesConfiguration.default = [
            "type"                : "ALL_SPECIES",
            "speciesDisplayFormat": "SCIENTIFICNAME(COMMONNAME)"
    ]
}

if(!dataAccessMethods) {
    dataAccessMethods = [
        "Open access structured raw data download from this system",
        "Open access opaque raw data file attached in this system",
        "Limited structured raw data access in this system - via request (subject to embargo)",
        "Opaque raw data file attached in this system - via request",
        "Open access structured raw data download from external source",
        "Closed access structured raw data download from external source",
        "Raw data not available",
        "Only derived/interpreted data products available"
    ]
}

if(!dataQualityAssuranceMethods) {
    dataQualityAssuranceMethods = [
        "Data owner curated",
        "Subject matter expert record verification",
        "Crowd-sourced record verification",
        "Record annotation",
        "System supported data attribute configuration",
        "No DQ methods used",
        "Not applicable"
    ]
}