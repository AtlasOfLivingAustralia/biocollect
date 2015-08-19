package au.org.ala.biocollect.merit
import com.drew.imaging.ImageMetadataReader
import com.drew.lang.GeoLocation
import com.drew.metadata.Directory
import com.drew.metadata.Metadata
import com.drew.metadata.exif.ExifSubIFDDirectory
import com.drew.metadata.exif.GpsDirectory
import grails.converters.JSON

import java.text.SimpleDateFormat


/**
 * A delegate to the ecodata admin services.
 */
class AdminService {

    def grailsApplication,webService,outputService,documentService,activityService,siteService

    /**
     * Triggers a full site re-index.
     */
    def reIndexAll() {
        webService.getJson(grailsApplication.config.ecodata.service.url + '/admin/reIndexAll')
    }

    static outputDateFormat = new SimpleDateFormat("yyyy-MM-dd'T'hh:mm:ssZ")
    static {
        outputDateFormat.setTimeZone(TimeZone.getTimeZone("UTC"))
    }

    def migratePhotoPoints(photoPoints) {

        def report = new File('/data/fieldcapture-hub/photoPointMigration.csv')
        def writer = new PrintStream(new FileOutputStream(report))

        if (!photoPoints) {
            def outputs = outputService.list();
            def url = "${grailsApplication.config.ecodata.service.url}document"

            photoPoints = outputs.findAll{it.name == 'Photo Points'}
        }
        photoPoints.each { photoPointOutput ->

            try {
                def activity = activityService.get(photoPointOutput.activityId)
                if (!activity || activity.error) {
                    log.error("No activity for photopoint: ${photoPointOutput.outputId}, activityId:${photoPointOutput.activityId}")
                    writer.println("No activity for photopoint: ${photoPointOutput.outputId}, activityId:${photoPointOutput.activityId}")

                } else {
                    if (activity.documents && activity.documents.find{it.role == 'photoPoint'}) {
                        writer.println("Photopoint: ${photoPointOutput.outputId} has already been migrated")
                    }
                    else {
                        def site = siteService.get(activity.siteId)
                        if (!site || site.error) {
                            log.error("No site for photopoint: ${photoPointOutput.outputId}, activityId:${photoPointOutput.activityId}, siteId:${activity.siteId}")
                            writer.println("No site for photopoint: ${photoPointOutput.outputId}, activityId:${photoPointOutput.activityId}, siteId:${activity.siteId}")
                        } else {
                            photoPointOutput.data.photoPoints.each { photoPoint ->

                                def poi = site.poi?.findAll { it.name == photoPoint.name }
                                if (!poi) {
                                    log.error("No POI found with name: ${photoPoint.name} in site: ${site.siteId}")
                                    writer.println("No POI found with name: ${photoPoint.name} in site: ${site.siteId} for output: ${photoPointOutput.outputId}")
                                } else if (poi.size() > 1) {
                                    log.error("Multiple POIs found with name ${photoPoint.name} in site: ${site.siteId}")
                                    writer.println("Multiple POIs found with name ${photoPoint.name} in site: ${site.siteId} for output: ${photoPointOutput.outputId}")
                                } else if (!poi[0].poiId) {
                                    log.error("No poiId found for photo point ${poi[0].name} in site: ${site.siteId}")
                                    writer.println("No poiId found for photo point ${poi[0].name} in site: ${site.siteId} for output: ${photoPointOutput.outputId}")
                                } else {

                                    photoPoint.photo?.each { photo ->
                                        String filename = photo.name
                                        if (filename == null || filename  == 'null' && photo.id) {
                                            def imageDetailsUrl = "${grailsApplication.config.images.baseURL}ws/getImageInfo?id=${photo.id}"
                                            def result = webService.getJson(imageDetailsUrl)
                                            if (result.originalFileName) {
                                                filename = result.originalFileName
                                            }
                                        }
                                        String ext = ''
                                        int extensionLoc = filename.lastIndexOf('.')
                                        if (extensionLoc > 0 && extensionLoc < filename.length()) {
                                            ext = filename.substring(extensionLoc + 1, filename.length())
                                        }
                                        if (!ext) {
                                            log.error("unable to determine file extension for photopoint: ${photoPointOutput.outputId}, filename=${filename}")
                                            writer.println("unable to determine file extension for photopoint: ${photoPointOutput.outputId}, filename=${filename}")
                                            return
                                        }

                                        File tmp = File.createTempFile("image", filename)
                                        def fileOut = new BufferedOutputStream(new FileOutputStream(tmp))

                                        def encodedUrl = photo.url

                                        if (photo.url?.indexOf('image?id=') > 0 && photo.url?.indexOf(photo.name) > 0) {
                                            // Some of the old photo points are not URL encoded properly.
                                            def filenameParamIndex = photo.url.indexOf('image?id=') + 'image?id='.length() + 1
                                            def filenameParam = photo.url.substring(filenameParamIndex, photo.url.length())
                                            encodedUrl = photo.url.replace(filenameParam, filenameParam.encodeAsURL().replaceAll('\\+', '%20'))
                                        }


                                        fileOut << new URL(encodedUrl).openStream()
                                        fileOut.close()


                                        def exifData = getExifMetadata(tmp)

                                        def dateTaken
                                        if (exifData.date) {
                                            dateTaken = outputDateFormat.format(exifData.date)
                                            dateTaken = dateTaken.replace("+0000", "Z")
                                        } else {
                                            writer.println("No exif data for photo: ${photoPointOutput.outputId} ${filename} using: ${activity.endDate} ")
                                            dateTaken = activity.endDate
                                        }

                                        def doc = [
                                                name      : filename,
                                                poiId     : poi[0].poiId,
                                                filesize  : photo.size,
                                                filename  : filename,
                                                type      : 'image',
                                                role      : 'photoPoint',
                                                activityId: photoPointOutput.activityId,
                                                siteId    : activity.siteId,
                                                notes     : photoPoint.comment,
                                                dateTaken : dateTaken
                                        ]

                                        writer.println("Creating " + doc)
                                        documentService.createDocument(doc, "image/${ext.toLowerCase()}", new FileInputStream(tmp))

                                        tmp.delete()

                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception e) {
                log.error("Error migrating photopoint: ${photoPointOutput.outputId}",e)
                writer.println("Error migrating photopoint: ${photoPointOutput.outputId}, ${e.getMessage()}")
            }

        }
        writer.close()
    }

    private Map getExifMetadata(file) {
        def exif = [:]
        try {
            Metadata metadata = ImageMetadataReader.readMetadata(file);

            Directory directory = metadata.getDirectory(ExifSubIFDDirectory.class)
            if (directory) {
                Date date = directory.getDate(ExifSubIFDDirectory.TAG_DATETIME_ORIGINAL)
                exif.date = date
            }

            Directory gpsDirectory = metadata.getDirectory(GpsDirectory.class)
            if (gpsDirectory) {
                /*gpsDirectory.getTags().each {
                    println it.getTagType()
                    println it.getTagName()
                    println it.getTagTypeHex()
                    println it.getDescription()
                    println it.toString()
                }*/
                //def lat = gpsDirectory.getRationalArray(GpsDirectory.TAG_GPS_LATITUDE)
                //def lng = gpsDirectory.getRationalArray(GpsDirectory.TAG_GPS_LONGITUDE)
                GeoLocation loc = gpsDirectory.getGeoLocation()
                if (loc) {
                    exif.latitude = gpsDirectory.getDescription(GpsDirectory.TAG_GPS_LATITUDE)
                    exif.longitude = gpsDirectory.getDescription(GpsDirectory.TAG_GPS_LONGITUDE)
                    exif.decLat = loc.latitude
                    exif.decLng = loc.longitude
                }
            }
        } catch (Exception e){
            //this will be thrown if its a PNG....
            log.debug(e.getMessage(),e)
        }

        return exif
    }


    def syncCollectoryOrgs() {
        def url = "${grailsApplication.config.ecodata.service.url}admin/syncCollectoryOrgs"
        webService.doPost(url, [
                api_key: grailsApplication.config.api_key
        ])
    }
}
