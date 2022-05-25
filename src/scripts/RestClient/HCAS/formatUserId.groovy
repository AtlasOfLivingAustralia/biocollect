def LOG_FILE = "output.txt"
File logFile = new File(LOG_FILE)

if (!logFile.exists()) {
    println "File does not exist"
} else {
    println("[")
    logFile.eachLine { line ->
        if (line.startsWith("200:::::")) {
            def jsonSlurper = new groovy.json.JsonSlurper()
            def parseItem = line?.replaceAll('200:::::', '')
            def values = parseItem.tokenize('|||')

            def result = jsonSlurper.parseText(values[0])
            def userId = values[1]
            def activityId = result?.resp?.activityId
            println("{userId: '" + userId + "', activityId: '" + activityId + "'},")
        }
    }
    println("];")
}