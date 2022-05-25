def LOG_FILE = "import_test_log_6.txt"
File logFile = new File(LOG_FILE)

if (!logFile.exists()) {
    println "File does not exist"
} else {
    println("[")
    logFile.eachLine { line ->
        if (line.startsWith("projectId  >>")) {
            def jsonSlurper = new groovy.json.JsonSlurper()
            def projectId = line?.replaceAll('projectId  >> ', '')
            println("'" + projectId + "',")
        }
    }
    println("];")
}