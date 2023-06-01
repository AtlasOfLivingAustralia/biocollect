package au.org.ala.biocollect

class ProjectFinderSpec extends StubbedCasSpec {
    def setup() {
        useDataSet('dataset1')
    }

    def cleanup() {
        logout(browser)
    }
}