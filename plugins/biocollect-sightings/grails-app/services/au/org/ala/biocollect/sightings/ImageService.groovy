/*
 * Copyright (C) 2014 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 */

package au.org.ala.biocollect.sightings

import com.drew.imaging.ImageMetadataReader
import com.drew.lang.GeoLocation
import com.drew.metadata.Directory
import com.drew.metadata.Metadata
import com.drew.metadata.exif.ExifSubIFDDirectory
import com.drew.metadata.exif.GpsDirectory
import org.apache.commons.io.FilenameUtils
import org.apache.tika.mime.MimeType
import org.apache.tika.mime.MimeTypes
import org.imgscalr.Scalr
import org.springframework.web.multipart.MultipartFile
import org.springframework.web.multipart.MultipartHttpServletRequest
import org.springframework.web.multipart.commons.CommonsMultipartFile

import javax.imageio.ImageIO
import javax.servlet.http.HttpServletRequest
import java.awt.image.BufferedImage

/**
 * Utility service for reading and writing image files
 */
class ImageService {

    def grailsApplication

    def InputStream selectInputStream(HttpServletRequest request) {
        if (request instanceof MultipartHttpServletRequest) {
            MultipartFile uploadedFile = ((MultipartHttpServletRequest) request).getFile('files[]')
            return uploadedFile.inputStream
        }
        return request.inputStream
    }

    def File generateThumbnail(File imageFile) {

        File colDir = new File(grailsApplication.config.media.uploadDir as String)
        def filename = imageFile.name // FilenameUtils.getName()
        def ext = FilenameUtils.getExtension(filename)
        def filenamename = FilenameUtils.getBaseName(filename)
        String thumbFilename = filenamename + "-thumb." + ext
        // thumbnail it
        BufferedImage img = ImageIO.read(imageFile)
        BufferedImage tn = Scalr.resize(img, 100, Scalr.OP_ANTIALIAS)
        File tnFile = new File(colDir, thumbFilename)
        try {
            def success = ImageIO.write(tn, ext, tnFile)
            log.debug "Thumbnailing: " + success
        } catch(IOException e) {
            log.error "Write error for " + tnFile.getPath() + ": " + e.getMessage(), e
        }

        tnFile
    }

    /**
     * Generate a File (filepath really) for the image upload (not yet created)
     *
     * @return
     */
    def File createTemporaryFile(CommonsMultipartFile file) {
        File uploaded
        String uuid = UUID.randomUUID().toString() // unique temp image file name
        MimeTypes allTypes = MimeTypes.getDefaultMimeTypes()
        MimeType mt = allTypes.forName(file.contentType)
        String ext = mt.getExtension()

        if (grailsApplication.config?.containsKey('media')) {
            File uploadDir = new File("${grailsApplication.config.media.uploadDir}")
            def filename = file.originalFilename
            log.debug "image upload filename: ${filename}"
            if (!uploadDir.exists()) {
                uploadDir.mkdirs() ? log.info("Created temp image dir: ${uploadDir.absolutePath}")
                        : log.error("Failed to create temp image dir: ${uploadDir.absolutePath} - PLEASE FIX")
            }

            uploaded = new File("${grailsApplication.config.media.uploadDir}/image_${uuid}${ext}")
        } else {
            uploaded = File.createTempFile('grails', "image_${uuid}${ext}")
        }

        if (uploaded) {
            // add some dynamic attributes
            uploaded.metaClass.mimeType = mt.toString()
            uploaded.metaClass.fileName = file.originalFilename
        }

        log.debug "uploaded = ${uploaded.absolutePath}"

        return uploaded
    }

    private void uploadFile(InputStream inputStream, File file) {

        try {
            file << inputStream
        } catch (Exception e) {
            throw new Exception(e)
        }

    }

    def getExifForUrl(String urlStr) {
        def exif = [:]
        URL url = new URL(urlStr)
        BufferedInputStream bis = new BufferedInputStream(url.openStream())
        //File image = new File(url.toURI())

        if (bis) {
            log.debug "reading exif data from BufferedReader"
            exif = getExifDataForBis(bis)
        }

        exif
    }

    def getExifForFile(File file) {
        def exif = [:]

        if (file.canRead()) {
            try {
                Metadata metadata = ImageMetadataReader.readMetadata(file)
                exif = readMetadata(metadata)
            } catch (Exception e) {
                log.warn("Error reading EXIF data. " + e.getMessage(),e)
            }
        }

        exif
    }

    private Map getExifDataForBis(BufferedInputStream br) {
        def exif = [:]

        try {
            Metadata metadata = ImageMetadataReader.readMetadata(br, false);
            exif = readMetadata(metadata)
        } catch (Exception e){
            //this will be thrown if its a PNG....
            log.warn("Error reading EXIF data. " + e.getMessage(),e)
        }

        exif
    }

    private readMetadata(Metadata metadata) {
        def exif = [:]
        Directory directory = metadata.getDirectory(ExifSubIFDDirectory.class)
        if (directory) {
            Date date = directory.getDate(ExifSubIFDDirectory.TAG_DATETIME_ORIGINAL)
            exif.date = date
        }

        Directory gpsDirectory = metadata.getDirectory(GpsDirectory.class)
        if (gpsDirectory) {
            GeoLocation loc = gpsDirectory.getGeoLocation()
            if (loc) {
                //exif.latitude = gpsDirectory.getDescription(GpsDirectory.TAG_GPS_LATITUDE)
                //exif.longitude = gpsDirectory.getDescription(GpsDirectory.TAG_GPS_LONGITUDE)
                exif.decLat = loc.latitude
                exif.decLng = loc.longitude
            }
        }

        exif
    }
}
