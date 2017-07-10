package au.org.ala.biocollect.merit

class FormSpeciesFieldParserService {
    MetadataService metadataService

    /**
     * Get the list of species fields, for the specified survey, grouped by outputs
     * This will enable the fine configuration of species by field
     *
     * Currently the only feature not supported is looking for species fields in footers
     * (Grids and tables are the only types supporting footers, Other than the footer, a grid does not support primitive types such as species)
     * @param id Survey name
     * @return the list of species fields
     */
    Map getSpeciesFieldsForSurvey(String id) {
        def model = [:]

        // the activity meta-model
        model.metaModel = metadataService.getActivityModel(id)
        // the array of output models
        model.outputModels = model.metaModel?.outputs?.collectEntries {
            [it, metadataService.getDataModelFromOutputName(it)]
        }


        def fields = []

        def attr = [fields: fields]

        // Find the species fields in the data model for each output model
        model.outputModels.each { outputName, outputModel ->
            if(outputModel) { // Yes there are a few instances were the output is null
                attr.model = outputModel
                attr.outputName = outputName
                viewModelItems(attr, outputModel.viewModel)
            }
        }

        [result:fields]
    }

    private viewModelItems(attrs, items) {

        items?.eachWithIndex { viewModel, index ->
            switch (viewModel.type) {
                case 'table':
                    table attrs, viewModel
                    break
                case 'section':
                case 'row':
                case 'col':
                    viewModelItems(attrs, viewModel.items)
                    break;
                case 'grid':
                    viewModelItems(attrs, viewModel.rows)
                    break;
                default:
                    addIfSpeciesDatatype(attrs, viewModel, "")
                    break;
            }
        }
    }

    private void addIfSpeciesDatatype(attrs, viewModelEntry, String context) {
        if (viewModelEntry.type != "literal") {
            def dataModelEntry = getDataModelEntry(attrs, viewModelEntry.source, context)
            if (dataModelEntry?.dataType == "species") {
                attrs.fields << [label: viewModelEntry.preLabel ?: viewModelEntry.title, dataFieldName: dataModelEntry.name, context: context, output: attrs.outputName]
            }
        }
    }

    private table(attrs, viewModel) {
        tableBodyEdit attrs, viewModel
    }


    private tableBodyEdit (attrs, tableViewModel) {
        // body elements for main rows
        tableViewModel.columns.each { col ->
            addIfSpeciesDatatype(attrs, col, tableViewModel.source)

        }
    }


    /*------------ methods to look up attributes in the data model -------------*/


    static  getDataModelEntry(attrs, name, context) {
        //println "getting ${attribute} for ${name} in ${context}"
        def dataModel = attrs.model.dataModel
        def level = dataModel.find {it.name == context}
        level = level ?: dataModel
        //println "level = ${level}"
        def target
        if (level.dataType in ['list','matrix', 'photoPoints']) {
            target = level.columns.find {it.name == name}
            if (!target) {
                target = level.rows.find {it.name == name}
            }
        }
        else {
            //println "looking for ${name}"
            target = dataModel.find {it.name == name}
        }
        //println "found ${attribute} = ${target ? target[attribute] : null}"
        return target
    }
}
