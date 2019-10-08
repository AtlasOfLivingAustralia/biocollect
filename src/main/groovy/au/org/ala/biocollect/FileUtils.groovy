package au.org.ala.biocollect

class FileUtils {
    /**
     * We are preserving the file name so the URLs look nicer and the file extension isn't lost.
     * As filename are not guaranteed to be unique, we are pre-pending the file with a counter if necessary to
     * make it unique.
     */
    static String nextUniqueFileName(filename, path) {
        String newFilename = filename
        File file = new File(fullPath(newFilename, path))

        int counter = 0;
        while (file.exists()) {
            newFilename = "${counter}_${filename}"
            counter++;
            file = new File(fullPath(newFilename, path))
        }

        newFilename
    }

    static String fullPath(filename, path) {
        path + File.separator + filename
    }

    static def encodeUrl(prefix, filename) {
        String encodedFileName = filename.encodeAsURL().replaceAll('\\+', '%20')
        String url = "${prefix}${prefix.contains("?") ? "" : "/"}${encodedFileName}"
        new URI(url).toURL()
    }
}
