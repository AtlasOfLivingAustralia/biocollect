package au.org.ala.biocollect.merit

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

    def webService

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

    def upload() {
        log.debug "-------------------------------upload action"
        params.each { log.debug it }
        def result = []
        if (request.respondsTo('getFile')) {
            MultipartFile file = request.getFile('files')
            //println "file is " + file
            if (file?.size) {  // will only have size if a file was selected
                def filename = file.getOriginalFilename().replaceAll(' ','_')
                def ext = FilenameUtils.getExtension(filename)
                filename = nextUniqueFileName(FilenameUtils.getBaseName(filename)+'.'+ext)

                def thumbFilename = FilenameUtils.removeExtension(filename) + "-thumb." + ext
                //println "filename=${filename}"

                def colDir = new File(grailsApplication.config.upload.images.path as String)
                colDir.mkdirs()
                File f = new File(fullPath(filename))
                //println "saving ${filename} to ${f.absoluteFile}"
                file.transferTo(f)
                def exifMd = getExifMetadata(f)

                // thumbnail it
                BufferedImage img = ImageIO.read(f)
                BufferedImage tn = Scalr.resize(img, 300, Scalr.OP_ANTIALIAS)
                File tnFile = new File(colDir, thumbFilename)
                try {
                    def success = ImageIO.write(tn, ext, tnFile)
                    log.debug "Thumbnailing: " + success
                } catch(IOException e) {
                    e.printStackTrace()
                    log.error "Write error for " + tnFile.getPath() + ": " + e.getMessage()
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
                        url: encodeImageURL(grailsApplication.config.upload.images.url,filename),
                        thumbnail_url: encodeImageURL(grailsApplication.config.upload.images.url, thumbFilename),
                        delete_url: encodeImageURL(grailsApplication.config.grails.serverURL+"/image/delete?filename=", filename),
                        delete_type: 'DELETE']
                result = [files:[md]]
            }
        }
        log.debug result

        response.addHeader('Content-Type','text/plain')
        def json = result as JSON
        render json.toString()
    }

    def delete = {
        log.debug "deleted " + params.filename
        render '{"deleted":true}'
    }

    def encodeImageURL(prefix, filename) {
        def encodedFileName = filename.encodeAsURL().replaceAll('\\+', '%20')
        URI uri = new URI(prefix + "/" + encodedFileName)
        return uri.toURL();
    }

    /**
     * A convenience method to help serve files in the dev. environment.
     * The content type of the file is derived purely from the file extension.
     */
    def get() {

        File f = new File(fullPath(params.id))
        if (!f.exists()) {
            response.status = 404
            return
        }

        def ext = FilenameUtils.getExtension(params.id)

        response.contentType = 'image/'+ext
        response.outputStream << new FileInputStream(f)
        response.outputStream.flush()

    }

    /**
     * We are preserving the file name so the URLs look nicer and the file extension isn't lost.
     * As filename are not guaranteed to be unique, we are pre-pending the file with a counter if necessary to
     * make it unique.
     */
    private String nextUniqueFileName(filename) {
        int counter = 0;
        String newFilename = filename
        File f = new File(fullPath(newFilename))
        while (f.exists()) {
            newFilename = "${counter}_${filename}"
            counter++;
            f = new File(fullPath(newFilename))
        }
        return newFilename;
    }

    String fullPath(filename) {

        return grailsApplication.config.upload.images.path + File.separator  + filename
    }
}
