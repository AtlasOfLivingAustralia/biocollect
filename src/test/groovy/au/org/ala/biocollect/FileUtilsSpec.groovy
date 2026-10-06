package au.org.ala.biocollect

import spock.lang.Specification

class FileUtilsSpec extends Specification {

    File temp, testPath
    void setup () {
        temp = File.createTempDir("tmp", "")
        testPath = new File(temp, "test")
        testPath.mkdir()
    }

    def "resolveInDirectory returns files located directly in the base directory"() {
        expect:
        FileUtils.resolveInDirectory(testPath, 'file.txt') == new File(testPath.canonicalFile, 'file.txt')
        FileUtils.resolveInDirectory(testPath.absolutePath, 'file.txt') == new File(testPath.canonicalFile, 'file.txt')
        FileUtils.resolveInDirectory(testPath, 'a b-1_2.tar.gz') == new File(testPath.canonicalFile, 'a b-1_2.tar.gz')
    }

    def "resolveInDirectory rejects names that could escape the base directory"(String filename) {
        expect:
        FileUtils.resolveInDirectory(testPath, filename) == null

        where:
        filename << [null, '', '.', '..', '../file.txt', '../../etc/passwd', '/etc/passwd', 'sub/file.txt',
                     '..\\file.txt', "file.txt\u0000", "file\r\n.txt"]
    }

    def "resolveInDirectory rejects a symlink pointing outside of the base directory"() {
        setup:
        File outside = new File(temp, 'secret.txt')
        outside.text = 'secret'
        java.nio.file.Files.createSymbolicLink(new File(testPath, 'link.txt').toPath(), outside.toPath())

        expect:
        FileUtils.resolveInDirectory(testPath, 'link.txt') == null
    }

    def "Copy recursively should copy file to target directory" () {
        given:
        URL resource = getClass().getResource("/data/test.scss")

        when:
        au.org.ala.biocollect.FileUtils.copyResourcesRecursively(resource, testPath)

        then:
        String [] fileList = testPath.list()
        fileList.size() == 1
        fileList[0] == 'test.scss'
    }

    def "Copy should copy directory and its content to target directory" () {
        given:
        URL resource = getClass().getResource("/data/testDir")

        when:
        au.org.ala.biocollect.FileUtils.copyResourcesRecursively(resource, testPath)

        then:
        String [] fileList = testPath.list()
        fileList.size() == 1
        fileList[0] == 'testDir'
        File dirContent = new File(testPath, "testDir")
        String [] testDir = dirContent.list()
        testDir.size() == 1
        testDir[0] == 'test.txt'
    }
}
