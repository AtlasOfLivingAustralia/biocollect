package au.org.ala.biocollect.merit

import com.vividsolutions.jts.geom.Geometry
import com.vividsolutions.jts.geom.Point
import com.vividsolutions.jts.io.WKTReader
import grails.converters.JSON
import org.grails.web.json.JSONArray
import grails.web.mapping.LinkGenerator
import grails.web.servlet.mvc.GrailsParameterMap
import org.geotools.kml.v22.KMLConfiguration
import org.geotools.xml.Parser
import org.opengis.feature.simple.SimpleFeature

class SiteService {

    def webService, grailsApplication, commonService, metadataService, userService
    def documentService
    ActivityService activityService
    ProjectService projectService
    LinkGenerator grailsLinkGenerator
    ReportService reportService

    def list() {
        webService.getJson(grailsApplication.config.ecodata.service.url + '/site/').list
    }

    /**
     * Creates a site extent object from a supplied latitude and longitude in the correct format, and populates the facet metadata for the extent.
     * @param lat the latitude of the point.
     * @param lon the longitude of the point.
     * @return a Map containing the site extent in the correct format (see the metaModel())
     */
    def siteExtentFromPoint(lat, lon) {

        def extent = [:].withDefault{[:]}
        extent.source = 'point'
        extent.geometry.type = 'Point'
        extent.geometry.decimalLatitude = lat
        extent.geometry.decimalLongitude = lon
        extent.geometry.coordinates = [lon, lat]
        extent.geometry.centre = [lon, lat]
        extent.geometry << metadataService.getLocationMetadataForPoint(lat, lon)
        extent
    }

    def getLocationMetadata(site) {
        //log.debug site
        def loc = getFirstPointLocation(site)
        //log.debug "loc = " + loc
        if (loc && loc.geometry?.decimalLatitude && loc.geometry?.decimalLongitude) {
            return metadataService.getLocationMetadataForPoint(loc.geometry.decimalLatitude, loc.geometry.decimalLongitude)
        }
        return null
    }

    def injectLocationMetadata(List sites) {
        sites.each { site ->
            injectLocationMetadata(site)
        }
        sites
    }

    def injectLocationMetadata(Object site) {
        def loc = getFirstPointLocation(site)
        if (loc && loc.geometry?.decimalLatitude && loc.geometry?.decimalLongitude) {
            site << metadataService.getLocationMetadataForPoint(loc.geometry.decimalLatitude, loc.geometry.decimalLongitude)
        }
        site
    }

    def getFirstPointLocation(site) {
        site.location?.find {
            it.type == 'locationTypePoint'
        }
    }

    def getSitesFromIdList(ids) {
        def result = []
        ids.each {
            result << get(it)
        }
        result
    }

    def addPhotoPoint(siteId, photoPoint) {
        photoPoint.type = 'photopoint'
        addPOI(siteId, photoPoint)
    }

    def addPOI(siteId, poi) {

        if (!siteId) {
            throw new IllegalArgumentException("The siteId parameter cannot be null")
        }
        def url = "${grailsApplication.config.ecodata.service.url}/site/${siteId}/poi"
        webService.doPost(url, poi)
    }

    def get(id, Map urlParams = [:]) {
        if (!id) return null
        webService.getJson(grailsApplication.config.ecodata.service.url + '/site/' + id +
                commonService.buildUrlParamsFromMap(urlParams))
    }

    def getRaw(id) {
        def site = get(id, [raw:'true'])
        if (!site || site.error) return [:]

        if (site.shapePid && !(site.shapePid instanceof JSONArray)) {
            log.debug "converting to array"
            site.shapePid = [site.shapePid] as JSONArray
        }
        def documents = documentService.getDocumentsForSite(site.siteId).resp?.documents?:[]
        [site: site, documents:documents as JSON, meta: metaModel()]
    }

    def updateRaw(id, values, userId = "") {
        def resp = [:]
        values['userId'] = userId
        values['asyncUpdate'] = values['asyncUpdate'] != null ? values['asyncUpdate'] : true

        if (id) {
            def result = update(id, values)
            if(result.error){
                resp = [status: 'error', message: result.detail]
            } else {
                resp = [status: 'updated', id:id]
            }
        } else {
            def result = create(values)
            if(result.error){
               resp = [status: 'error', message: result.detail]
            } else {
                resp = [status: 'created', id:result.resp.siteId]
            }
        }
        return resp
    }

    def create(body){
        webService.doPost(grailsApplication.config.ecodata.service.url + '/site/', body)
    }

    def update(id, body) {
        webService.doPost(grailsApplication.config.ecodata.service.url + '/site/' + id, body)
    }

    def updateProjectAssociations(body) {
        webService.doPost(grailsApplication.config.ecodata.service.url + '/project/updateSites/' + body.projectId, body)
    }

    def addProjectToSite(String siteId, String projectId) {
        webService.getJson(grailsApplication.config.ecodata.service.url + '/site/' + siteId + '?projectId=' + projectId)
    }

    /** uploads a shapefile to the spatial portal */
    def uploadShapefile(shapefile) {
        def userId = userService.getUser().userId
        def url = "${grailsApplication.config.spatial.layersUrl}/shape/upload/shp?user_id=${userId}&api_key=${grailsApplication.config.api_key}"

        return webService.postMultipart(url, [:], shapefile)
    }

    /**
     * Creates a site for a specified project from the supplied site data.
     * @param shapeFileId the id of the shapefile in the spatial portal
     * @param siteId the id of the shape to use (as returned by the spatial portal upload)
     * @param name the name for the site
     * @param description the description for the site
     * @param projectId the project the site should be associated with.
     * @param forceAddToWhiteList update project's map configuration with site so that it appears in whitelist
     */
    def createSiteFromUploadedShapefile(shapeFileId, siteId, externalId, name, description, projectId, forceAddToWhiteList) {
        def baseUrl = "${grailsApplication.config.spatial.layersUrl}/shape/upload/shp"
        def userId = userService.getUser().userId

        def site = [name:name, description: description, user_id:userId, api_key:grailsApplication.config.api_key]

        def url = "${baseUrl}/${shapeFileId}/${siteId}"

        def result = webService.doPost(url, site)
        if (!result.error) {
            def id = result.resp.id

            Point centriod = calculateSiteCentroid(id)
            Map data = createSite(projectId, name, description, externalId, id, centriod.getY(), centriod.getX())
            if (!data.error && data.resp?.siteId) {
                addSitesToSiteWhiteListInWorksProjects([data.resp?.siteId], [projectId], forceAddToWhiteList)
            }
        }
    }

    /**
     * Creates (and saves) a site definition from a name, description and lat/lon.
     * @param projectId the project the site should be associated with.
     * @param name a name for the site.
     * @param description a description of the site.
     * @param lat latitude of the site centroid.
     * @param lon longitude of the site centroid.
     */
    def createSiteFromPoint(projectId, name, description, lat, lon) {
        def site = [name:name, description:description, projects:[projectId]]
        site.extent = siteExtentFromPoint(lat, lon)

        create(site)
    }

    /**
     * Creates sites for a project from the supplied KML.  The Placemark elements in the KML are used to create
     * the sites, other contextual and styling information is ignored.
     * @param kml the KML that defines the sites to be created
     * @param projectId the project the sites will be assigned to.
     */
    def createSitesFromKml(kml, projectId) {

        def url = "${grailsApplication.config.spatial.layersUrl}/shape/upload/wkt"
        def userId = userService.getUser().userId

        Parser parser = new Parser(new KMLConfiguration())
        SimpleFeature f = parser.parse(new StringReader(kml))

        def placemarks = []
        extractPlacemarks(f, placemarks)

        def sites = []

        placemarks.each { SimpleFeature placemark ->
            def name = placemark.getAttribute('name')
            def description = placemark.getAttribute('description')

            Geometry geom = placemark.getDefaultGeometry()
            def site = [name:name, description: description, user_id:userId, api_key:grailsApplication.config.api_key, wkt:geom.toText()]

            def result = webService.doPost(url, site)
            if (!result.error) {
                def id = result.resp.id
                if (!result.resp.error) {
                    sites << createSite(projectId, name, description, '', id, geom.centroid.getY(), geom.centroid.getX())
                }
            }

        }
        return sites
    }

    /**
     * Extracts any features that have a geometry attached, in the case of KML these will likely be placemarks.
     */
    def extractPlacemarks(features, placemarks) {
        if (!features) {
            return
        }
        features.each { SimpleFeature feature ->
            if (feature.getDefaultGeometry()) {
                placemarks << feature
            }
            else {
                extractPlacemarks(feature.getAttribute('Feature'), placemarks)
            }
        }
    }


    /** Returns the centroid (as a Point) of a site in the spatial portal */
    def calculateSiteCentroid(spatialPortalSiteId) {

        def getWktUrl = "${grailsApplication.config.spatial.baseURL}/ws/shape/wkt"
        def wkt = webService.get("${getWktUrl}/${spatialPortalSiteId}")
        Geometry geom = new WKTReader().read(wkt)
        return geom.getCentroid()
    }

    def createSite(projectId, name, description, externalId, geometryPid, centroidLat, centroidLong) {
        def metadata = metadataService.getLocationMetadataForPoint(centroidLat, centroidLong)
        def strLat =  "" + centroidLat + ""
        def strLon = "" + centroidLong + ""
        def values = [extent: [source: 'pid', geometry: [pid: geometryPid, type: 'pid', state: metadata.state, nrm: metadata.nrm, lga: metadata.lga, locality: metadata.locality, mvg: metadata.mvg, mvs: metadata.mvs, centre: [strLon, strLat]]], projects: [projectId], name: name, description: description, externalId:externalId]
        return create(values)
    }

    def delete(id) {
        webService.doDelete(grailsApplication.config.ecodata.service.url + '/site/' + id)
    }

    def deleteSitesFromProject(projectId){
        webService.doDelete(grailsApplication.config.ecodata.service.url + '/project/deleteSites/' + projectId)
    }

    /**
     * Returns json that describes in a generic fashion the features to be placed on a map that
     * will represent the site's locations.
     *
     * If no extent is defined, returns an empty JSON object.
     *
     * @param site
     */
    def getMapFeatures(site) {
        def featuresMap = [zoomToBounds: true, zoomLimit: 15, highlightOnHover: true, features: []]
        switch (site.extent?.source?.toLowerCase()) {
            case 'point':
                featuresMap.features << site.extent.geometry
                break
            case 'pid':
                featuresMap.features << site.extent.geometry
                break
            case 'drawn' :
                featuresMap.features << site.extent.geometry
                break
            default:
                featuresMap = [:]
        }

        def asJSON = featuresMap as JSON
        asJSON
    }

    /**
     * Get images for a list of sites. Number of images returned can be limited by max and offset parameters.
     */
    List getImages( GrailsParameterMap params) throws SocketTimeoutException, Exception{
        String url = grailsApplication.config.ecodata.service.url + '/site/getImages';
        Map response = webService.doGet(url, params);
        if(response.resp){
            return response.resp;
        } else  if(response.error){
            if(response.error.contains('Timed out')){
                throw new SocketTimeoutException(response.error)
            } else {
                throw  new Exception(response.error);
            }
        }
    }


    /**
     * Get images for a point of interest id. Number of images returned can be limited by max and offset parameters.
     */
    Map getPoiImages( GrailsParameterMap params) throws SocketTimeoutException, Exception{
        String url = grailsApplication.config.ecodata.service.url + '/site/getPoiImages';
        Map response = webService.doGet(url, params);
        if(response.resp){
            return response.resp;
        } else  if(response.error){
            if(response.error.contains('Timed out')){
                throw new SocketTimeoutException(response.error)
            } else {
                throw  new Exception(response.error);
            }
        }
    }

    static metaModel() {
        return [domain: 'site',
                model: [
                        [name:'siteName', type:'text', immutable:true],
                        [name:'externalId', type:'text'],
                        [name:'type', type:'text'],
                        [name:'area', type:'text'],
                        [name:'description', type:'text'],
                        [name:'notes', type:'text'],
                        [name:'extent', type:'Location', itemModel: [
                                [name:'name', type: 'text'],
                                [name:'type', type:'list', itemType:'text', listValues:[
                                        'locationTypeNone','locationTypePoint','locationTypePid','locationTypeUpload',
                                ]],
                                [name:'geometry', type:'list', itemType:[
                                        [name:'NoneLocation', type:'null'],
                                        [name:'PointLocation', type:'list', itemType:[
                                                [name:'decimalLatitude', type:'latLng'],
                                                [name:'decimalLongitude', type:'latLng'],
                                                [name:'uncertainty', type:'text'],
                                                [name:'precision', type:'text'],
                                                [name:'datum', type:'text']
                                        ]],
                                        [name:'PidLocation', type:'list', itemType:[
                                                [name:'pid', type: 'text']
                                        ]],
                                        [name:'UploadLocation', type:'list', itemType:[
                                                [name:'shape', type: 'text'],
                                                [name:'pid', type: 'text']
                                        ]],
                                        [name:'DrawnLocation', type:'list', itemType:[
                                                [name:'decimalLatitude', type:'latLng'],
                                                [name:'decimalLongitude', type:'latLng'],
                                                [name:'radius', type:'text'],
                                                [name:'wkt', type:'text']
                                        ]]
                                ]]
                            ]
                        ],
                        [name:'location', type:'list', itemType: 'Location', itemModel: [
                                [name:'name', type: 'text'],
                                [name:'type', type:'list', itemType:'text', listValues:[
                                        'locationTypeNone','locationTypePoint','locationTypePid','locationTypeUpload',
                                ]],
                                [name:'data', type:'list', itemType:[
                                        [name:'NoneLocation', type:'null'],
                                        [name:'PointLocation', type:'list', itemType:[
                                                [name:'decimalLatitude', type:'latLng'],
                                                [name:'decimalLongitude', type:'latLng'],
                                                [name:'uncertainty', type:'text'],
                                                [name:'precision', type:'text'],
                                                [name:'datum', type:'text']
                                        ]],
                                        [name:'PidLocation', type:'list', itemType:[
                                                [name:'pid', type: 'text']
                                        ]],
                                        [name:'UploadLocation', type:'list', itemType:[
                                                [name:'shape', type: 'text'],
                                                [name:'pid', type: 'text']
                                        ]],
                                        [name:'DrawnLocation', type:'list', itemType:[
                                                [name:'decimalLatitude', type:'latLng'],
                                                [name:'decimalLongitude', type:'latLng'],
                                                [name:'radius', type:'text'],
                                                [name:'wkt', type:'text']
                                        ]]
                                ]]
                            ]
                        ],
                ]
            ]
    }

    /**
     * Checks if a siteId is linked to one or more activity.
     * @param siteId
     * @return Boolean - true if more than one activity is associated with a site
     */
    Boolean isSiteAssociatedWithActivity(String siteId) throws SocketTimeoutException, Exception{
        Map siteCriteria = new HashMap();
        siteCriteria.put('siteId', siteId);
        Map response = activityService.search(siteCriteria);
        List activities

        if(response.error){
            if(response.error.contains('Timed out')){
                throw new SocketTimeoutException(response.error)
            } else {
                throw new Exception(response.error)
            }
        }

        activities = response.resp?.activities;
        if(activities?.size()){
            return true
        }

        return false
    }

    /**
     * Checks if a siteId is linked to a project.
     * @param siteId
     * @return Boolean - true if site is project area
     */
    Boolean isSiteAssociatedWithProject(String siteId) throws SocketTimeoutException, Exception{
        Map siteCriteria = new HashMap();
        siteCriteria.put('siteId', siteId);
        Map response = get(siteId);
        List projects

        if(response.error){
            if(response.error.contains('Timed out')){
                throw new SocketTimeoutException(response.error)
            } else {
                throw new Exception(response.error)
            }
        }

        projects = response?.projects;
        if(projects?.size()){
            return true
        }

        return false
    }

    Boolean isSiteNameUnique(String id, String entityType, String name) {

        def response = webService.getJson(grailsApplication.config.ecodata.service.url + "/site/uniqueName/${enc(id)}?name=${enc(name)}&entityType=${enc(entityType)}")
        // convert an exception to a string and back again...
        if(response.error){
            if(response.error.contains('Timed out')){
                throw new SocketTimeoutException(response.error)
            } else {
                throw new Exception(response.error)
            }
        }

        return response.value
    }

    def enc(String value) {
        URLEncoder.encode(value, 'UTF-8')
    }

    void addPhotoPointPhotosForSites(List<Map> sites, List activities, List projects) {

        long start = System.currentTimeMillis()
        List siteIds = sites.collect{it.siteId}
        List pois = sites.collect{it.poi?it.poi.collect{poi->poi.poiId}:[]}.flatten()
        if (pois) {


            Map documents = documentService.search(siteId: siteIds)

            if (documents.documents) {

                Map docsByPOI = documents.documents.groupBy{it.poiId}
                sites.each { site->

                    site.poi?.each { poi ->
                        poi.photos = docsByPOI[poi.poiId]
                        poi.photos?.each{ photo ->
                            photo.activity = activities?.find{it.activityId == photo.activityId}
                            photo.projectId = photo.activity?.projectId ?: photo.projectId
                            Map project = projects.find{it.projectId == photo.projectId}
                            if (photo.activity) {

                                if (!project.reports) {
                                    project.reports = reportService.getReportsForProject(photo.projectId)
                                }
                                Map report = reportService.findReportForDate(photo.activity.plannedEndDate, project.reports)
                                photo.stage = report?report.name:''
                            }
                            photo.projectName = project?.name?:''
                            photo.siteName = site.name
                            photo.poiName = poi.name

                        }
                        poi.photos?.sort{it.dateTaken || ''}
                        poi.photos = poi.photos?.findAll{it.projectId} // Remove photos not associated with a supplied project
                    }
                }
            }
        }
        long end = System.currentTimeMillis()
        log.debug "Photopoint initialisation took ${(end-start)} millis"
    }

    /**
     * Add the site to the project's site whitelist if the following conditions are met.
     * 1. Allow additional survey sites is checked or force add flag is set
     */
    Boolean addSiteToProjectSiteWhiteList(String siteId, Map mapConfiguration, Boolean forceAdd = false) {
        Boolean isDirty = false
        if (mapConfiguration?.allowAdditionalSurveySites || forceAdd) {
            mapConfiguration.sites = mapConfiguration.sites ?: []
            // check if this site was added previously
            String sitePresent = mapConfiguration.sites.find { it == siteId }
            if (!sitePresent) {
                mapConfiguration.sites.add(siteId)
                isDirty = true
            }
        }

        isDirty
    }

    /**
     * Add sites to project's whitelist for each project in list.
     * The conditions to add a site is described in {@link #addSiteToProjectSiteWhiteList(String, Map, Boolean)}.
     * @param sites
     * @param projects
     * @param forceAdd add site without checking for further conditions
     */
    void addSitesToSiteWhiteListInWorksProjects(List sites, List projects, Boolean forceAdd = false) {
        projects?.each { projectId ->
            Map project = projectService.get(projectId)
            if (projectService.isWorks(project)) {
                project.mapConfiguration = project.mapConfiguration ?: [:]
                List projectSiteIds = project.sites?.collect { it.siteId }
                // ensure sites in map configuration is a subset of project sites
                sanitiseSiteIdListInMapConfiguration(projectSiteIds, project.mapConfiguration)

                Boolean isDirty = false
                sites?.each { siteId ->
                    // add site project relationship if it does not exist
                    if (!projectSiteIds?.contains(siteId)) {
                        addProjectToSite(siteId, projectId)
                    }

                    Boolean isAdded = addSiteToProjectSiteWhiteList(siteId, project.mapConfiguration, forceAdd)
                    isDirty = isDirty || isAdded
                }

                // update project if site list has been modified.
                if (isDirty) {
                    Map body = [mapConfiguration: project.mapConfiguration]
                    projectService.update(project.projectId, body)
                }
            }
        }
    }

    /**
     * Sites in map configuration must be a subset of sites associated with project.
     * This function removes all other sites.
     * @param projectSites
     * @param mapConfiguration
     */
    void sanitiseSiteIdListInMapConfiguration(List projectSites, Map mapConfiguration) {
        List toRemove = []
        mapConfiguration.sites?.each { siteId ->
            if (!projectSites.contains(siteId)) {
                toRemove.add(siteId)
            }
        }

        mapConfiguration.sites?.removeAll(toRemove)
    }


    Map defaultMapConfiguration(String defaultZoomSiteId = null){
        [
            "sites" : [],
            "allowPoints" : true,
            "allowPolygons" : true,
            "allowAdditionalSurveySites" : false,
            "selectFromSitesOnly" : false,
            "defaultZoomArea" : defaultZoomSiteId,
            "baseLayersName" : "Open Layers"
        ]
    }
}