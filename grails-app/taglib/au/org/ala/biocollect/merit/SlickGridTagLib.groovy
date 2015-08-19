package au.org.ala.biocollect.merit

import grails.converters.JSON

class SlickGridTagLib {
    static namespace = "fc"


    def slickGridColumns = { attrs ->

        def columns = []
        // Add the project name as the first column.
        columns << [id: 'projectName', name: 'Project', field:'projectName']

        def dataModel = attrs.model

        dataModel.each {

            def editor = null
            switch(it.dataType) {
                case 'number':
                    editor = 'Test'
                    break;
                case 'integer':
                    editor = 'Test'
                    break;
                case 'text':
                    editor = 'Test'
                    break;
                case 'date':
                case 'simpleDate':
                    editor = 'Date'
                    break;
                case 'image':
                    break;
                case 'embeddedImages':
                    break;
                case 'species':
                    break;
                case 'stringList':
                    break;
                case 'boolean':
                    editor = 'Checkbox'
                    break;
                case 'lookupRange':
                    break; // do nothing
            }
            def header = it.label && it.description ? it.label+fc.iconHelp([container:'body'], it.description) : it.name
            def column = [id: it.name, name: header ?: it.name, field: it.name, outputName:attrs.outputName]
            if (editor) {
                column << [editorType:editor, validationRules:'validate[required]']
            }
            columns << column

        }

        columns << [id:'progress', name:'Progress', field:'progress']
        out << (columns as JSON).toString()+';'



    }

    def slickGridData = { attrs ->

        out << "JSON.parse('${(attrs.data as JSON).toString().encodeAsJavaScript()}');"

    }

}
