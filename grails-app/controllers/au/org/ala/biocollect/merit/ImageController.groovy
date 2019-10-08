package au.org.ala.biocollect.merit

import au.org.ala.biocollect.FileUtils
import com.drew.imaging.ImageMetadataReader
import com.drew.lang.GeoLocation
import com.drew.metadata.Directory
import com.drew.metadata.Metadata
import com.drew.metadata.exif.ExifSubIFDDirectory
import com.drew.metadata.exif.GpsDirectory
import grails.converters.JSON
import org.apache.commons.io.FilenameUtils
import org.imgscalr.Scalr
import org.springframework.web.multipart.MultipartFile

import javax.imageio.ImageIO
import java.awt.image.BufferedImage
import java.text.DecimalFormat
import java.text.SimpleDateFormat

class ImageController {

    def webService, userService

    static defaultAction = "get"

    def test() {}

    def exif() {
        def f = new File("/data/sightings/DSCN6487.jpg")
        def result = getExifMetadata(f)
        render result as JSON
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

    private isoDateStrToDate(date) {
        if (date) {
            SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy")
            return sdf.format(date)
        }
        return ""
    }

    private isoDateStrToTime(date) {
        if (date) {
            SimpleDateFormat sdf = new SimpleDateFormat("HH:mm")
            return sdf.format(date)
        }
        return ""
    }

    private doubleToString(d) {
        if (d) {
            DecimalFormat df = new DecimalFormat("0.0000000")
            return df.format(d)
        }
        return ""
    }

    def sample() {}

    def demo() {}

    /**
     * Uploads the image to the ALA image service.
     * @return
     */
    def uploadNew() {
        if (request.respondsTo('getFile')) {
            def url = grailsApplication.config.images.baseURL + 'ws/uploadImage'

            def params = [synchronousThumbnail:'true']
            MultipartFile file = request.getFile('files')

            def result = webService.postMultipart(url, params, file, 'image')
            if (result.content) {
                def detailsUrl = "${grailsApplication.config.images.baseURL}ws/getImageInfo?id=${result.content.imageId}"
                def imageDetails = webService.getJson(detailsUrl)
                def thumbnailUrl = imageDetails.imageUrl.replace("/original", "/thumbnail")

                def md = [
                        name         : imageDetails.orignalFileName,
                        size         : imageDetails.sizeInBytes,
                        id           : result.content.imageId,
                        url          : imageDetails.imageUrl,
                        thumbnail_url: thumbnailUrl,
                        delete_url   : grailsApplication.config.grails.serverURL + '/image/delete?id='+result.content.imageId,
                        delete_type  : 'DELETE']
                result = [files: [md]]
            }
            response.addHeader('Content-Type','text/plain')
            def json = result as JSON
            render json.toString()
        }
    }

    /**
     * Uploads image file or survey method supporting file to staging area
     * @return file metadata for rending in view
     */
    def upload() {
        def user = userService.getCurrentUserId(request)

        def result = []
        if (request.respondsTo('getFile') && user) {
            MultipartFile file = request.getFile('files')

            if (file?.size) {  // will only have size if a file was selected
                String filename = file.getOriginalFilename().replaceAll(' ', '_')
                String ext = FilenameUtils.getExtension(filename)
                String path = grailsApplication.config.upload.images.path
                filename = FileUtils.nextUniqueFileName(FilenameUtils.getBaseName(filename) + '.' + ext, path)

                def thumbFilename
                if (!params.role) {
                    thumbFilename = FilenameUtils.removeExtension(filename) + "-thumb." + ext
                }

                def colDir = new File(grailsApplication.config.upload.images.path as String)
                colDir.mkdirs()
                File f = new File(FileUtils.fullPath(filename, path))
                //println "saving ${filename} to ${f.absoluteFile}"
                file.transferTo(f)
                def exifMd = getExifMetadata(f)

                // thumbnail it if file is not for supporting method
                if (!params.role) {
                    BufferedImage img = ImageIO.read(f)
                    BufferedImage tn = Scalr.resize(img, 300, Scalr.OP_ANTIALIAS)
                    File tnFile = new File(colDir, thumbFilename)
                    try {
                        def success = ImageIO.write(tn, ext, tnFile)
                        log.debug "Thumbnailing: " + success
                    } catch (IOException e) {
                        e.printStackTrace()
                        log.error "Write error for " + tnFile.getPath() + ": " + e.getMessage()
                    }
                }

                def md = [
                        name: filename,
                        size: file.size,
                        isoDate: exifMd.date,
                        contentType: file.contentType,
                        date: isoDateStrToDate(exifMd.date) ?: 'Not available',
                        time: isoDateStrToTime((exifMd.date)),
                        decimalLatitude: doubleToString(exifMd.decLat),
                        decimalLongitude: doubleToString(exifMd.decLng),
                        verbatimLatitude: exifMd.latitude,
                        verbatimLongitude: exifMd.longitude,
                        url: FileUtils.encodeUrl(grailsApplication.config.upload.images.url, filename),
                        thumbnail_url: thumbFilename ? FileUtils.encodeUrl(grailsApplication.config.upload.images.url, thumbFilename): null,
                        delete_url: FileUtils.encodeUrl(grailsApplication.config.grails.serverURL+"/image/delete?filename=", filename),
                        delete_type: 'DELETE',
                        attribution: ''
                ]
                result = [files:[md]]
            }
        }
        log.debug result.toString()

        if(!user){
            render ([error: 'Invalid user'] as JSON)
        } else {
            response.addHeader('Content-Type','text/plain')
            def json = result as JSON
            render json.toString()
        }
    }

    def delete = {
        log.debug "deleted " + params.filename
        render '{"deleted":true}'
    }


    /**
     * A convenience method to help serve files in the dev. environment.
     * The content type of the file is derived purely from the file extension.
     */
    def get() {
        String path = grailsApplication.config.upload.images.path
        File f = new File(FileUtils.fullPath(params.id, path))
        if (!f.exists()) {
            response.status = 404
            return
        }

        // treat method supporting document differently
        if (params.role) {
            FileInputStream fis = new FileInputStream(f)
            byte[] buffer = new byte[fis.available()]
            fis.read(buffer)
            fis.close()

            response.addHeader("Content-Disposition", "attachment; filename=" + URLEncoder.encode(params.id,"utf-8"))
            response.addHeader("Content-Length",String.valueOf(f.length()))
            OutputStream out = new BufferedOutputStream(response.getOutputStream())
            response.setContentType("application/octet-stream")
            out.write(buffer)
            out.flush()
            out.close()
        } else {
            def ext = FilenameUtils.getExtension(params.id)

            response.contentType = 'image/'+ext
            response.outputStream << new FileInputStream(f)
            response.outputStream.flush()
        }

    }
}
