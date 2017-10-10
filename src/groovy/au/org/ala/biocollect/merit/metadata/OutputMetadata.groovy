package au.org.ala.biocollect.merit.metadata
/**
 * Works with the Output metadata.
 *
 * Copied from ecodata
 */
class OutputMetadata {

    private def metadata
    public OutputMetadata(metadata) {
        this.metadata = metadata
    }

    def getDarwinCoreMapping() {
        metadata.darwinCoreMapping
    }

    def annotateDataModel() {
        annotateNodes(metadata.dataModel)
    }

    def annotateNodes(nodes) {
        def annotatedNodes = []
        nodes.each { node->
            def annotatedNode = [:]
            annotatedNode.putAll(node)
            if (isNestedDataModelType(node)) {

                annotatedNode.columns = annotateNodes(getNestedDataModelNodes(node))

            }
            else {

                def result = findViewByName(node.name)
                if (result) {
                    def label = result.preLabel?:(result.title?:result.postLabel)
                    annotatedNode.label = label
                    annotatedNode.putAll(result)
                }
                if (!annotatedNode.label) {
                    annotatedNode.label = annotatedNode.name
                }


            }
            annotatedNodes << annotatedNode
        }

        // Sort the nodes based on the order they appear in the view model for consistency.
        if (metadata.viewModel) {
            annotatedNodes.sort { node ->
                metadata.viewModel.findIndexOf{it.source == node.name}
            }
        }
        annotatedNodes
    }


    def findViewByName(name, context = null) {

        if (!context) {
            context = metadata.viewModel
        }
        return context.findResult { node ->
            if (isNestedViewModelType(node)) {
                def nested = getNestedViewNodes(node)

                return findViewByName(name, nested)
            }
            else {
                return (node.source == name)?node:null
            }
        }
    }

    def getNestedPropertyNames() {
        def props = []
        metadata.dataModel.each { property ->
            if (isNestedDataModelType(property)) {
                props << property.name
            }
        }
        props
    }

    def getMemberOnlyPropertyNames() {
        def props = []

        metadata.dataModel.each { property ->
            def viewNode = findViewByName(property.name)
            if (viewNode.memberOnlyView) {
                props << property.name
            }
        }

        props
    }

    def getNestedViewNodes(node) {
        return (node.type in ['table', 'photoPoints', 'grid'] ) ? node.columns: node.items
    }
    def getNestedDataModelNodes(node) {
        return node.columns
    }

    def isNestedDataModelType(node) {
        return (node.columns != null && node.dataType != "geoMap")
    }
    def isNestedViewModelType(node) {
        return (node.items != null || node.columns != null)
    }

    /**
     * lists all names of type passed to function
     * @param type
     * @return
     * [ 'imageList':true,
     *   'multiSightingTable':['imageTable':true]
     * ]
     *
     */
    Map getNamesForDataType(String type, context){
        Map names = [:], childrenNames

        if(!context && metadata){
            context = metadata.dataModel;
        }

        context?.each { data ->
            if(isNestedDataModelType(data)){
                // recursive call for nested data model
                childrenNames = getNamesForDataType(type, getNestedDataModelNodes(data));
                if(childrenNames?.size()){
                    names[data.name] = childrenNames
                }
            }

            if(data.dataType == type){
                names[data.name] = true
            }
        }

        return names;
    }

    static class ValidationRules {

        def validationRules = []
        public ValidationRules(property) {
            if (property.validate) {
                def criteria = property.validate.tokenize(',')
                validationRules = criteria.collect { it.trim() }
            }

        }


        public boolean isMandatory() {
            return validationRules.contains('required')
        }

        public BigDecimal min() {
            def min = validationProperties().minimum?:new BigDecimal(0)
            return min
        }

        public BigDecimal max() {
            return validationProperties().maximum
        }

        def validationProperties() {
            def props = [:]
            validationRules.each {
                if (it.startsWith('min')) {
                    props << minProperty(it)
                }
                else if (it.startsWith('max')) {
                    props << maxProperty(it)
                }
            }
            return props
        }

        def valueInBrackets(rule) {
            def matcher = rule =~ /.*\[(.*)\]/
            if (matcher.matches()) {
                return matcher[0][1]
            }
            return null
        }

        def minProperty(rule) {
            def min = valueInBrackets(rule)
            if (min) {
                return [minimum: min as BigDecimal]
            }
            throw new IllegalArgumentException("Invalid validation rule: "+rule)
        }

        def maxProperty(rule) {
            def max = valueInBrackets(rule)
            if (max) {
                return [maximum: max as BigDecimal]
            }
            throw new IllegalArgumentException("Invalid validation rule: "+rule)
        }

    }

}
