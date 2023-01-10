package au.org.ala.biocollect

import spock.lang.Specification

class FileUtilsSpec extends Specification {

    File temp, testPath
    void setup () {
        temp = File.createTempDir("tmp", "")
        testPath = new File(temp, "test")
        testPath.mkdir()
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
