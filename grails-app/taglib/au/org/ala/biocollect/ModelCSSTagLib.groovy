package au.org.ala.biocollect

class ModelCSSTagLib {
    static namespace = "x"

    private final static INDENT = "    "
    private final static operators = ['sum':'+', 'times':'*', 'divide':'/']
    private final static String QUOTE = "\"";
    private final static String SPACE = " ";
    private final static String EQUALS = "=";

    /*------------ STYLES for dynamic content -------------*/
    // adds a style block for the dynamic components
    def modelStyles = { attrs ->
        viewModelStyles(attrs, out, attrs.model?.viewModel)
    }

    def viewModelStyles(attrs, out, items) {
        items.each { mod ->
            switch (mod.type) {
                case 'grid':
                case 'table':
                case 'photoPoints':
                    tableStyle(attrs, mod, out)
                    break
                case 'section':
                case 'row':
                case 'col':
                    viewModelStyles(attrs, out, mod.items)
                    break
            }
        }
    }

    def tableStyle(attrs, model, out ) {
        def edit = attrs.edit
        def tableClass = model.source

        out << '<style type="text/css">\n'
        if (model.allowHeaderWrap || attrs.forceHeaderWrap) {
            out << INDENT*2 << "table.${tableClass} th {white-space:normal;}\n"
        }
        model.columns.eachWithIndex { col, i ->

            def width = col.width ? "width:${col.width};" : ""
            def textAlign = model.type == 'grid' ? '' : getTextAlign(attrs, col, model.source)
            if (width || textAlign) {
                out << INDENT*2 << "table.${tableClass} tbody td:nth-child(${i+1}) {${width}${textAlign}}\n"
                // If a width has been supplied, make sure an embedded select element doesn't override it.
                if (width) {
                    out << INDENT*2 << "table.${tableClass} tbody td:nth-child(${i+1})\n"
                }
                //out << INDENT*2 << "table.${tableClass} th:nth-child(${i+1}) {${width}${textAlign}}\n"
            }
        }
        // add extra column for editing buttons
        if (edit) {
            if (model.editableRows) {
                // add extra column for editing buttons
                out << INDENT*2 << "table.${tableClass} td:last-child {width:5%;min-width:70px;text-align:center;}\n"
            } else {
                // add column for delete buttons
                out << INDENT*2 << "table.${tableClass} td:last-child {width:4%;text-align:center;}\n"
            }
        }

        out << INDENT*2 << "table.${tableClass} textarea {width:100%; box-sizing:border-box; }\n"
        out << INDENT*2 << "table.${tableClass} select {width:100%; box-sizing:border-box; }\n"

        out << INDENT << "</style>"
    }

    def getTextAlign(attrs, col, context) {
        //println "col=${col}"
        //println "type=${getType(attrs, col.source, context)}"
        // check for explicit first
        if (col.textAlign) return "text-align:${col.textAlign};"
        return (ModelTagLib.getType(attrs, col.source, context) in ['boolean','number']) ? "text-align:center;" : ""
    }
}
