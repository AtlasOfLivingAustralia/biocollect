// Add custom configuration properties at runtime once the external config has been digested
spatial.layersUrl = "${spatial.baseURL}/layers-service"
spatial.geoserverUrl = "${spatial.baseURL}/geoserver"
spatial.wms.url = "${spatial.baseURL}/geoserver/ALA/wms?"
spatial.wms.cache.url = "${spatial.baseURL}/geoserver/gwc/service/wms?"
ecodata.service.url = "${ecodata.baseURL}/ws"
upload.images.url = "${grails.serverURL}/image?id="
//TODO: Update to a correct wordpress homepage url.
biocollect.homepageUrl = "${ala.baseURL}/get-involved/citizen-science/"