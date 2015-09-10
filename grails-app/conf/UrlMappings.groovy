import au.org.ala.biocollect.merit.SettingService

import org.codehaus.groovy.grails.commons.spring.GrailsWebApplicationContext

class UrlMappings {

        static isHubValid(applicationContext, hub) {
                def settingsService = applicationContext.getBean(SettingService)
                return settingsService.isValidHub(hub)
        }

        static mappings = { GrailsWebApplicationContext applicationContext ->
                "/$hub/$controller/$action?/$id?"{
                        constraints {
                                hub validator: {val, obj -> isHubValid(applicationContext, val)}
                        }
                }

                "/$controller/$action?/$id?"{

                }

                "/$hub/$controller/$id?"(parseRequest:true) {
                        constraints {
                                hub validator: {val, obj -> isHubValid(applicationContext, val)}
                        }
                        action = [GET: "get", POST: "upload", PUT: "upload", DELETE: "delete"]
                }

                "/sightingAjax/saveBookmarkLocation" controller: "sightingAjax", action: [POST:"saveBookmarkLocation"]

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
                "500"(controller:'error', action:'response500')
                "404"(controller:'error', action:'response404')
                "/$hub?/$controller/ws/$action/$id" {
                        constraints {
                                hub validator: {val, obj -> isHubValid(applicationContext, val)}
                        }
                }
        }
}
