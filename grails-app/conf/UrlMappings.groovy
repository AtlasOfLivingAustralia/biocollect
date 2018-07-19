import au.org.ala.biocollect.merit.SettingService
import org.codehaus.groovy.grails.commons.spring.GrailsWebApplicationContext

class UrlMappings {


        static isHubValid(applicationContext, hub) {
                def settingsService = applicationContext.getBean(SettingService)
                return settingsService.isValidHub(hub)
        }

        static mappings = { GrailsWebApplicationContext applicationContext ->
                "/$hub/$controller/$action?/$id?(.$format)?"{
                        constraints {
                                hub validator: {val, obj -> isHubValid(applicationContext, val)}
                        }
                }

                "/$controller/$action?/$id?(.$format)?"{

                }

                "/$hub/$controller/$id?"(parseRequest:true) {
                        constraints {
                                hub validator: {val, obj -> isHubValid(applicationContext, val)}
                        }
                        action = [GET: "get", POST: "upload", PUT: "upload", DELETE: "delete"]
                }

                "/project/getAuditMessagesForProject/$id"(controller: "project", action: 'getAuditMessagesForProject')

                "/activity/$entityId/comment"(controller: "comment"){
                        action = [GET: 'list', POST: 'create']
                        entityType = 'au.org.ala.ecodata.Activity'
                }
                "/activity/$entityId/comment/$id"(controller: 'comment'){
                        entityType = 'au.org.ala.ecodata.Activity'
                        action = [GET: 'get', POST: 'update', PUT: 'update', DELETE: 'delete']
                }

                "/bioActivity/$entityId/comment"(controller: "comment"){
                        action = [GET: 'list', POST: 'create']
                        entityType = 'au.org.ala.ecodata.Activity'
                }
                "/bioActivity/$entityId/comment/$id"(controller: 'comment'){
                        entityType = 'au.org.ala.ecodata.Activity'
                        action = [GET: 'get', POST: 'update', PUT: 'update', DELETE: 'delete']
                }

                "/bioActivity/previewActivity/$formName/$projectId"(controller: "bioActivity", action: 'previewActivity')

                "/sight/$taxonId**" (controller: 'bioActivity', action: 'create') {
                        id = grailsApplication.config.individualSightings.pActivity
                        hub = grailsApplication.config.individualSightings.hub
                }

                "/spotter/$spotterId" (controller: 'bioActivity', action: 'spotter')

                "/$controller/$id?"(parseRequest:true) {

                        action = [GET: "get", POST: "upload", PUT: "upload", DELETE: "delete"]
                }

                "/$hub/"(controller: 'home', action: 'index') {
                        constraints {
                                hub validator: {val, obj -> isHubValid(applicationContext, val)}
                        }
                }
                "/$hub"(controller: 'home', action: 'index') {

                        constraints {
                                hub validator: {val, obj -> isHubValid(applicationContext, val)}
                        }
                }
                "/"(controller: 'home', action: 'index') {

                }
                "/$hub/nocas/geoService"(controller: 'home', action: 'geoService') {
                        constraints {
                                hub validator: {val, obj -> isHubValid(applicationContext, val)}
                        }
                }
                "/nocas/geoService"(controller: 'home', action: 'geoService') {

                }
                "/$hub/myProfile"(controller: 'home', action: 'myProfile') {
                        constraints {
                                hub validator: {val, obj -> isHubValid(applicationContext, val)}
                        }
                }
                "/myProfile"(controller: 'home', action: 'myProfile') {

                }

                "/$hub/admin/user/$id"(controller: "user", action: "show") {
                        constraints {
                                hub validator: {val, obj -> isHubValid(applicationContext, val)}
                        }
                }
                "/admin/user/$id"(controller: "user", action: "show") {

                }
                "/download/file"(controller: "download", action: [GET: "file"])
                "/download/$id"(controller: "download", action: [GET: "downloadProjectDataFile"])
                "500"(controller:'error', action:'response500')
                "404"(controller:'error', action:'response404')
                "/$hub?/$controller/ws/$action/$id" {
                        constraints {
                                hub validator: {val, obj -> isHubValid(applicationContext, val)}
                        }
                }

                // Following api's are used by external mobile clients
                "/ws/project/search"(controller: "project", action: 'search')
                "/ws/survey/list/$id"(controller:  "project", action: 'listSurveys')
                "/ws/attachment/upload"(controller:  "image", action: 'upload')
                "/ws/bioactivity/model/$id"(controller: "bioActivity", action: 'getActivityModel')
                "/ws/bioactivity/data/$id"(controller:  "bioActivity", action: 'getOutputForActivity')
                "/ws/species/uniqueId"(controller:  "output", action: 'getOutputSpeciesIdentifier')
                "/ws/bioactivity/save"(controller:  "bioActivity", action: 'ajaxUpdate')
                "/ws/bioactivity/delete/$id"(controller:  "bioActivity", action: 'delete')
                "/ws/bioactivity/search"(controller:  "bioActivity", action: 'searchProjectActivities')
                "/ws/bioactivity/map"(controller:  "bioActivity", action: 'getProjectActivitiesRecordsForMapping')
        }
}

