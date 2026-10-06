package au.org.ala.biocollect


import org.apache.commons.lang.StringUtils

import java.util.jar.JarEntry
import java.util.jar.JarFile
import java.util.regex.Pattern

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

    /**
     * Safely resolves a client supplied file name against a base directory.
     * Only bare file names are accepted - anything containing a path component (e.g. "../x", "/etc/passwd",
     * "a/b", "..\\x"), control characters or null bytes is rejected
     * @param baseDir the directory the file must reside in
     * @param filename the untrusted file name
     * @return the File within baseDir, or null if the file name is not acceptable. The file is not
     * guaranteed to exist.
     */
    private static final Pattern WINDOWS_RESERVED = Pattern.compile('(?i)^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\\..*)?$')

    static File resolveInDirectory(Object baseDir, Object filename) {
        if (baseDir == null || filename == null) {
            return null
        }

        String name = filename.toString()
        if (!name || name == '.' || name == '..') {
            return null
        }

        // Reject separators and DOS reserved device names
        if (name.contains('/') || name.contains('\\') || WINDOWS_RESERVED.matcher(name).matches()) {
            return null
        }

        // Reject ISO control characters
        for (int i = 0; i < name.length(); i++) {
            if (Character.isISOControl(name.charAt(i))) {
                return null
            }
        }

        try {
            File base = new File(baseDir.toString()).canonicalFile
            if (!base.exists() || !base.isDirectory()) {
                return null
            }

            File candidate = new File(base, name).canonicalFile
            return (candidate.parentFile == base) ? candidate : null
        } catch (IOException | IllegalArgumentException ignored) {
            return null
        }
    }

    static def encodeUrl(prefix, filename) {
        String encodedFileName = filename.encodeAsURL().replaceAll('\\+', '%20')
        String url = "${prefix}${prefix.contains("?") ? "" : "/"}${encodedFileName}"
        new URI(url).toURL()
    }

    public static boolean copyFile(final File toCopy, final File destFile) {
        try {
            return FileUtils.copyStream(new FileInputStream(toCopy),
                    new FileOutputStream(destFile));
        } catch (final FileNotFoundException e) {
            e.printStackTrace();
        }
        return false;
    }

    private static boolean copyFilesRecursively(final File toCopy,
                                                final File destDir) {
        assert destDir.isDirectory();

        if (!toCopy.isDirectory()) {
            return FileUtils.copyFile(toCopy, new File(destDir, toCopy.getName()));
        } else {
            final File newDestDir = new File(destDir, toCopy.getName());
            if (!newDestDir.exists() && !newDestDir.mkdir()) {
                return false;
            }
            for (final File child : toCopy.listFiles()) {
                if (!FileUtils.copyFilesRecursively(child, newDestDir)) {
                    return false;
                }
            }
        }
        return true;
    }

    public static boolean copyJarResourcesRecursively(final File destDir,
                                                      final JarURLConnection jarConnection) throws IOException {

        final JarFile jarFile = jarConnection.getJarFile();

        for (final Enumeration<JarEntry> e = jarFile.entries(); e.hasMoreElements();) {
            final JarEntry entry = e.nextElement();
            if (entry.getName().startsWith(jarConnection.getEntryName())) {
                final String filename = StringUtils.removeStart(entry.getName(), //
                        jarConnection.getEntryName());

                final File f = new File(destDir, filename);
                if (!entry.isDirectory()) {
                    final InputStream entryInputStream = jarFile.getInputStream(entry);
                    if(!FileUtils.copyStream(entryInputStream, f)){
                        return false;
                    }
                    entryInputStream.close();
                } else {
                    if (!FileUtils.ensureDirectoryExists(f)) {
                        throw new IOException("Could not create directory: "
                                + f.getAbsolutePath());
                    }
                }
            }
        }
        return true;
    }

    public static boolean copyResourcesRecursively( //
        final URL originUrl, final File destination) {
        try {
            final URLConnection urlConnection = originUrl.openConnection();
            if (urlConnection instanceof JarURLConnection) {
                return FileUtils.copyJarResourcesRecursively(destination,
                        (JarURLConnection) urlConnection);
            } else {
                return FileUtils.copyFilesRecursively(new File(originUrl.getPath()),
                        destination);
            }
        } catch (final IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    private static boolean copyStream(final InputStream is, final File f) {
        try {
            return FileUtils.copyStream(is, new FileOutputStream(f));
        } catch (final FileNotFoundException e) {
            e.printStackTrace();
        }
        return false;
    }

    private static boolean copyStream(final InputStream is, final OutputStream os) {
        try {
            final byte[] buf = new byte[1024];

            int len = 0;
            while ((len = is.read(buf)) > 0) {
                os.write(buf, 0, len);
            }
            is.close();
            os.close();
            return true;
        } catch (final IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    private static boolean ensureDirectoryExists(final File f) {
        return f.exists() || f.mkdir();
    }}
