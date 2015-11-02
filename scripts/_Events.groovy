eventCreateWarStart = { warName, stagingDir ->
    ant.propertyfile(file: "${stagingDir}/WEB-INF/classes/application.properties") {
        entry(key:"app.build", value: new Date().format("dd/MM/yyyy HH:mm:ss"))
    }
}