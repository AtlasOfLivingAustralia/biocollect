// Add custom configuration properties at runtime once the external config has been digested
spatial.layersUrl = "${spatial.baseURL}/layers-service"
spatial.geoserverUrl = "${spatial.baseURL}/geoserver"
spatial.wms.url = "${spatial.baseURL}/geoserver/ALA/wms?"
spatial.wms.cache.url = "${spatial.baseURL}/geoserver/gwc/service/wms?"
ecodata.service.url = "${ecodata.baseURL}/ws"
upload.images.url = "${grails.serverURL}/image?id="