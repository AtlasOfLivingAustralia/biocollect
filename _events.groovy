import java.nio.file.Files
import java.nio.file.Paths
import java.nio.file.attribute.BasicFileAttributes
import java.nio.file.attribute.FileTime
import org.apache.commons.io.FileUtils

Boolean doesTemplateNeedCompiling (File templateDirectory, File compiledTemplateFile) {
    Boolean compile = false
    if (templateDirectory != null) {
        BasicFileAttributes attr = Files.readAttributes(Paths.get(compiledTemplateFile.canonicalPath), BasicFileAttributes.class)
        FileTime lastModifiedTime = attr.lastModifiedTime()
        def templateFiles = templateDirectory.listFiles()

        for (templateFile in templateFiles) {
            BasicFileAttributes templateFileAttributes = Files.readAttributes(Paths.get(templateFile.canonicalPath), BasicFileAttributes.class)
            if (templateFileAttributes.lastModifiedTime().compareTo(lastModifiedTime) > 0 ) {
                return true
            }
        }
    }

    return compile
}


void generateTemplateFile(File compiledTemplateFile, File templateDirectory) {
    if (!compiledTemplateFile.getParentFile().exists()) {
        compiledTemplateFile.getParentFile().mkdirs()
    }

    FileUtils.writeStringToFile(compiledTemplateFile, '/* Do not edit or commit this file. This file built at compile by _Events.groovy */\n')
    def templates = templateDirectory.listFiles()
    templates.each { File template ->
        def fileParts = template.getName().split("\\.")
        if (fileParts.length >= 1) {
            def componentName = fileParts[0]

            if (template.exists()) {
                def content = template.getText().replaceAll("[\n\r]", "")
                        .replaceAll("\"", "\\\\\"")
                        .replaceAll('\\s+', ' ')
                FileUtils.writeStringToFile(compiledTemplateFile,
                        "componentService.setTemplate(\"${componentName}\", \"" + content + "\");" as String, true)
            }
        }
    }
}

def buildTemplateFile(String templateDirectoryName, String compiledTemplateFileName) {
    File templateDir = new File(templateDirectoryName)
    File compiledTemplateFile = new File(compiledTemplateFileName)
    if (!compiledTemplateFile?.exists() || doesTemplateNeedCompiling(templateDir, compiledTemplateFile)) {
        generateTemplateFile(compiledTemplateFile, templateDir)
    }

}

buildTemplateFile("${projectDir}/grails-app/assets/components/template", "${projectDir}/grails-app/assets/components/compile/biocollect-templates.js")