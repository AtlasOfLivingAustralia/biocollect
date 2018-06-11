package au.org.ala.biocollect

import grails.converters.JSON

/**
 * Generates web page content for metadata-driven dynamic data entry and display.
 */
class ModelTagLib {

    static namespace = "x"

    private final static INDENT = "    "
    private final static operators = ['sum':'+', 'times':'*', 'divide':'/']
    private final static String QUOTE = "\"";
    private final static String SPACE = " ";
    private final static String EQUALS = "=";
    private final static String DEFERRED_TEMPLATES_KEY = "deferredTemplates"
    private final static String NUMBER_OF_TABLE_COLUMNS = "numberOfTableColumns"

    private final static int LAYOUT_COLUMNS = 12 // Bootstrap scaffolding uses a 12 column layout.

    /*---------------------------------------------------*/
    /*------------ HTML for dynamic content -------------*/
    /*---------------------------------------------------*/

    /**
     * Main tag to insert html
     * @attrs model the data and view models
     * @attrs edit if true the html will support the editing of values
     */
    def modelView = { attrs ->
        viewModelItems(attrs, out, attrs.model?.viewModel)

        renderDeferredTemplates out
    }

    def viewModelItems(attrs, out, items) {

        items?.eachWithIndex { mod, index ->
            switch (mod.type) {
                case 'table':
                    table out, attrs, mod
                    break
                case 'grid':
                    grid out, attrs, mod
                    break
                case 'section':
                    section out, attrs, mod
                    break
                case 'row':
                    def span = LAYOUT_COLUMNS
                    row out, attrs, mod, span
                    break
                case 'photoPoints':
                    photoPoints out, attrs, mod, index
                    break
                case 'template':
                    out << g.render(template:mod.source, plugin: "${mod.plugin ?: 'fieldcapture-plugin'}", model: [config: mod.config ?: [:], readonly: attrs.readonly?.toBoolean() ?: false])
                    break
            }
        }
    }

    /**
     * Generates an element for display, depending on context. Currently
     * @parma attrs the attributes passed to the tag library.  Used to access site id.
     * @param model of the data element
     * @param context the dot notation path to the data
     * @param editable if the html element is an input
     * @param elementAttributes any additional html attributes to output as a AttributeMap
     * @param databindAttrs additional clauses to add to the data binding
     * @return the markup
     */
    def dataTag(attrs, model, context, editable, elementAttributes, databindAttrs, labelAttributes) {
        ModelWidgetRenderer renderer

        def toEdit = editable && !model.computed && !model.noEdit

        def validate = validationAttribute(attrs, model, editable)

        if (attrs.printable) {
            renderer = new PrintModelWidgetRenderer()
        } else {
            renderer = toEdit ? new EditModelWidgetRenderer() : new ViewModelWidgetRenderer()
        }

        // hack - sometimes span class are added to elementAttributes. It interferes with the rendering of input like
        // selectOne since span12 or span8 is passed to it.
        if(model.inline){
            elementAttributes?.removeSpan()
            labelAttributes?.removeSpan()
        }

        if(toEdit){
            // controls padding, display and other css properties
            elementAttributes?.add('class', 'form-control')
        }

        def renderContext = new WidgetRenderContext(model, context, validate, databindAttrs, elementAttributes, labelAttributes, g, attrs)

        if (model.visibility) {
            renderContext.databindAttrs?.add "visible", evalDependency(model.visibility)
        }
        if (model.enabled) {
            renderContext.databindAttrs?.add "enable", evalDependency(model.enabled)
        }

        switch (model.type) {
            case 'literal':
                renderer.renderLiteral(renderContext)
                break
            case 'text':
                renderer.renderText(renderContext)
                break;
            case 'readonlyText':
                renderer.renderReadonlyText(renderContext)
                break;
            case 'number':
                renderer.renderNumber(renderContext)
                break
            case 'boolean':
                renderer.renderBoolean(renderContext)
                break
            case 'textarea':
                if(toEdit){
                    if(model.rows){
                        renderContext.attributes?.add('rows', model.rows)
                    }

                    elementAttributes?.add('class', 'full-width')
                }

                renderer.renderTextArea(renderContext)
                break
            case 'simpleDate':
                renderer.renderSimpleDate(renderContext)
                break
            case 'selectOne':
                renderer.renderSelectOne(renderContext)
                break;
            case 'selectMany':
                renderer.renderSelectMany(renderContext)
                break
            case 'selectManyCombo':
                renderer.renderSelectManyCombo(renderContext)
                break
            case 'wordCloud':
                renderer.renderWordCloud(renderContext)
                break
            case 'audio':
                renderer.renderAudio(renderContext)
                break
            case 'image':
                renderer.renderImage(renderContext)
                break
            case 'imageDialog':
                renderer.renderImageDialog(renderContext)
                break
            case 'embeddedImage':
                renderer.renderEmbeddedImage(renderContext)
                break
            case 'embeddedImages':
                renderer.renderEmbeddedImages(renderContext)
                break
            case 'autocomplete':
                renderer.renderAutocomplete(renderContext)
                break
            case 'speciesSearchWithImagePreview':
                renderer.renderSpeciesSearchWithImagePreview(renderContext)
                break
            case 'fusedAutoComplete':
                renderer.renderFusedAutocomplete(renderContext)
                break
            case 'photopoint':
                renderer.renderPhotoPoint(renderContext)
                break
            case 'link':
                renderer.renderLink(renderContext)
                break
            case 'date':
                renderer.renderDate(renderContext)
                break
            case 'time':
                renderer.renderTime(renderContext)
                break
            case 'document':
                renderer.renderDocument(renderContext)
                break
            case 'buttonGroup':
                renderer.renderButtonGroup(renderContext)
                break
            case 'geoMap':
                renderer.renderGeoMap(renderContext)
                break
            default:
                log.warn("Unhandled widget type: ${model.type}")
                break
        }

        def result = renderContext.writer.toString()

        // make sure to remember any deferred templates
        renderContext.deferredTemplates?.each {
            addDeferredTemplate(it)
        }


        if (model.preLabel) {
            model.dataClass = model.dataClass?:''
            labelAttributes.addClass 'preLabel'

            if (isRequired(attrs, model, editable)) {
                labelAttributes.addClass 'required'
            }

            if(model.preLabelClass ){
                labelAttributes.add('class', model.preLabelClass)
            }

            if( model.inline ){
                result = "<span class='row-fluid'><span ${labelAttributes.toString()}><label class='inline'>${labelText(attrs, model, model.preLabel)}</label></span>" +
                        "<span class='${model.dataClass}'>${result}</span></span>"
            } else {
                result = "<span ${labelAttributes.toString()}><label>${labelText(attrs, model, model.preLabel)}</label></span>" + result
            }
        }

        if (model.postLabel) {
            labelAttributes.addClass 'postLabel'
            result += "<span ${labelAttributes.toString()}>${model.postLabel}</span>"
        }

        return result
    }

    /**
     * Generates the contents of a label, including help text if it is available in the model.
     * The attribute "helpText" on the view model is used first, if that does not exist, the dataModel "description"
     * attribute is used a fallback.  If that doesn't exist either, no help is added to the label.
     * @param attrs the taglib attributes, includes the full model.
     * @param model the current viewModel item being processed.
     * @param label text to use for the label.  Will also be used as a title for the help test.
     * @return a generated html string to use to render the label.
     */
    def labelText(attrs, model, label) {

        if (attrs.printable) {
            return label
        }

        def helpText = model.helpText

        if (!helpText) {

            if (model.source) {
                // Get the description from the data model and use that as the help text.
                def attr = getAttribute(attrs.model.dataModel, model.source)
                if (!attr) {
                    log.warn "Attribute ${model.source} not found"
                }
                helpText = attr?.description
            }
        }
        helpText = helpText?fc.iconHelp([title:''], helpText):''
        return "${label}${helpText}"

    }

    def evalDependency(dependency) {
        if (dependency.source) {
            if (dependency.values) {
                return "jQuery.inArray(${dependency.source}(), ${dependency.values as JSON}) >= 0"
            }
            else if (dependency.value) {
                return "${dependency.source}() === ${dependency.value}"
            }
            return "${dependency.source}()"
        }
    }

    // convenience method for the above
    def dataTag(attrs, model, context, editable, at) {
        dataTag(attrs, model, context, editable, at, null, null)
    }

    // convenience method for the above
    def dataTag(attrs, model, context, editable) {
        dataTag(attrs, model, context, editable, null, null, null)
    }

    def specialProperties(attrs, properties) {
        return properties.collectEntries { entry ->
            switch (entry.getValue()) {
                case "#siteId":
                    entry.setValue(attrs?.site?.siteId)
                default:
                    return entry
            }
        }
    }

    // -------- validation declarations --------------------
    def getValidationCriteria(attrs, model, edit) {
        //log.debug "checking validation for ${model}, edit = ${edit}"
        if (!edit) { return []}  // don't bother if the user can't change it

        def validationCriteria = model.validate
        def dataModel = getAttribute(attrs.model.dataModel, model.source)

        if (!validationCriteria) {
            // Try the data model.
            validationCriteria = dataModel?.validate
        } // no criteria

        def criteria = []
        if (validationCriteria) {
            criteria = validationCriteria.tokenize(',')
            criteria = criteria.collect {
                def rule = it.trim()
                // Wrap these rules in "custom[]" to keep jquery-validation-engine happy and avoid having to
                // specify "custom" in the json.
                if (rule in ['number', 'integer', 'url', 'date', 'phone']) {
                    rule = "custom[${rule}]"
                }
                rule
            }
        }

        // Add implied numeric validation to numeric data types
        if (dataModel?.dataType == 'number') {
            if (!criteria.contains('custom[number]') && !criteria.contains('custom[integer]')) {
                criteria << 'custom[number]'
            }
            if (!criteria.find{it.startsWith('min')}) {
                criteria << 'min[0]'
            }
        }

        if (dataModel?.dataType == 'species') {
            criteria << 'funcCall[validateSpeciesLookup]'
        }

        return criteria
    }

    def isRequired(attrs, model, edit) {
        def criteria = getValidationCriteria(attrs, model, edit)
        return criteria.contains("required")
    }

    /**
     * Check if the field is visible to only project members (and ALA admins)
     * @parma attrs the attributes passed to the tag library.  Used to access site id.
     * @param model of the data element
     * @return true if field marked as member only, false if it has public visibility
     */
    def isHidden(attrs, model) {
        def toEdit = attrs.edit && !model.computed && !model.noEdit
        def userIsProjectMember = attrs.userIsProjectMember

        // hidden from public and visible to only project members (and ALA admins)
        return (!toEdit && model.memberOnlyView && !userIsProjectMember) ? true: false
    }

    def validationAttribute(attrs, model, edit) {
        def criteria = getValidationCriteria(attrs, model, edit)
        if (criteria.isEmpty()) {
            return ""
        }

        def values = []
        criteria.each {
            switch (it) {
                case 'required':
                    if (model.type == 'selectMany') {
                        values << 'minCheckbox[1]'
                    }
                    else {
                        values << it
                    }
                    break
                case 'number':
                    values << 'custom[number]'
                    break
                case it.startsWith('min:'):
                    values << it
                    break
                default:
                    values << it
            }
        }
        //log.debug " data-validation-engine='validate[${values.join(',')}]'"
        return " data-validation-engine='validate[${values.join(',')}]'"
    }

    // form section
    def section(out, attrs, model) {

        if (model.title && !model.boxed) {
            out << "<h4>${model.title}</h4>"
        }
        out << "<div class=\"row-fluid space-after output-section boxed-heading\" data-content='${model.title}'>\n"

        viewModelItems(attrs, out, model.items)

        out << "</div>"
    }

    // row model
    def row(out, attrs, model, parentSpan) {
        def extraClassAttrs = model.class ?: ""
        def databindAttrs = model.visibility ? "data-bind=\"visible:${model.visibility}\"" : ""

        out << "<div class=\"row-fluid space-after ${extraClassAttrs}\" ${databindAttrs}>\n"
        if (model.align == 'right') {
            out << "<div class=\"pull-right\">\n"
        }
        items(out, attrs, model, parentSpan, 'row')
        if (model.align == 'right') {
            out << "</div>\n"
        }
        out << "</div>\n"
    }

    def items(out, attrs, model, parentSpan, context) {

        def span = context == 'row'? (int)(LAYOUT_COLUMNS / model.items.size()) : LAYOUT_COLUMNS

        model.items.each { it ->
            if (isHidden(attrs, it)){
                return
            }
            AttributeMap at = new AttributeMap()
            at.addClass(it.css)
            // inject computed from data model

            it.computed = it.computed ?: getComputed(attrs, it.source, '')
            if (it.type == 'col') {
                out << "<div class=\"span${span}\">\n"
                items(out, attrs, it, span, 'col')
                out << "</div>"
            } else if (it.type == 'row') {
                row out, attrs, it, span
            }
            else if (it.type == 'table') {
                table out, attrs, it
            } else if (it.type == 'section') {
                section out, attrs, it
            } else {
                // Wrap data elements in rows to reset the bootstrap indentation on subsequent spans to save the
                // model definition from needing to do so.
                def labelAttributes = new AttributeMap()
                def elementAttributes = new AttributeMap()
                if (context == 'col') {
                    out << "<div class=\"row-fluid\">"
                    labelAttributes.addClass 'span4'
                    if (it.type != "number") {
                        elementAttributes.addClass 'span8'
                    }
                } else {
                    if (it.type != "number") {
                        elementAttributes.addClass 'span12'
                    }
                }

                at.addSpan("span${span}")
                out << "<span${at.toString()}>"
                out << INDENT << dataTag(attrs, it, 'data', attrs.edit, elementAttributes, null, labelAttributes)
                out << "</span>"

                if (context == 'col') {
                    out << "</div>"
                }
            }
        }
    }

    def grid(out, attrs, model) {
        out << "<div class=\"row-fluid\">\n"
        out << INDENT*3 << "<table class=\"table table-bordered ${model.source}\">\n"
        gridHeader out, attrs, model
        if (attrs.edit) {
            gridBodyEdit out, attrs, model
        } else {
            gridBodyView out, attrs, model
        }
        footer out, attrs, model
        out << INDENT*3 << "</table>\n"
        out << INDENT*2 << "</div>\n"
    }

    def gridHeader(out, attrs, model) {
        Integer colCount = 0;
        pageScope.setVariable(NUMBER_OF_TABLE_COLUMNS, colCount);
        out << INDENT*4 << "<thead><tr>"
        model.columns.each { col ->
            colCount ++
            out << "<th>"
            out << col.title
            if (col.pleaseSpecify) {
                def ref = col.pleaseSpecify.source
                // $ means top-level of data
                if (ref.startsWith('$')) { ref = 'data.' + ref[1..-1] }
                if (attrs.edit) {
                    out << " (<span data-bind='clickToEdit:${ref}' data-input-class='input-mini' data-prompt='specify'></span>)"
                } else {
                    out << " (<span data-bind='text:${ref}'></span>)"
                }
            }
            out << "</th>"
        }
        out << '\n' << INDENT*4 << "</tr></thead>\n"
        pageScope.setVariable(NUMBER_OF_TABLE_COLUMNS, colCount);
    }

    def gridBodyEdit(out, attrs, model) {
        out << INDENT*4 << "<tbody>\n"
        model.rows.eachWithIndex { row, rowIndex ->

            // >>> output the row heading cell
            AttributeMap at = new AttributeMap()
            at.addClass('shaded')  // shade the row heading
            if (row.strong) { at.addClass('strong') } // bold the heading if so specified
            // row and td tags
            out << INDENT*5 << "<tr>" << "<td${at.toString()}>"
            out << row.title
            if (row.pleaseSpecify) { //handles any requirement to allow the user to specify the row heading
                def ref = row.pleaseSpecify.source
                // $ means top-level of data
                if (ref.startsWith('$')) { ref = 'data.' + ref[1..-1] }
                out << " (<span data-bind='clickToEdit:${ref}' data-input-class='input-small' data-prompt='specify'></span>)"
            }
            // close td
            out << "</td>" << "\n"

            // find out if the cells in this row are computed
            def isComputed = getComputed(attrs, row.source, model.source)
            // >>> output each cell in the row
            model.columns[1..-1].eachWithIndex { col, colIndex ->
                out << INDENT*5 << "<td>"
                if (isComputed) {
                    out << "<span data-bind='text:data.${model.source}.get(${rowIndex},${colIndex})'></span>"
                } else {
                    out << "<span data-bind='ticks:data.${model.source}.get(${rowIndex},${colIndex})'></span>"
                    //out << "<input class='input-mini' data-bind='value:data.${model.source}.get(${rowIndex},${colIndex})'/>"
                }
                out << "</td>" << "\n"
            }

            out << INDENT*5 << "</tr>\n"
        }
        out << INDENT*4 << "</tr></tbody>\n"
    }

    def gridBodyView(out, attrs, model) {
        out << INDENT*4 << "<tbody>\n"
        model.rows.eachWithIndex { row, rowIndex ->

            // >>> output the row heading cell
            AttributeMap at = new AttributeMap()
            at.addClass('shaded')
            if (row.strong) { at.addClass('strong')}
            // row and td tags
            out << INDENT*5 << "<tr>" << "<td${at.toString()}>"
            out << row.title
            if (row.pleaseSpecify) { //handles any requirement to allow the user to specify the row heading
                def ref = row.pleaseSpecify.source
                // $ means top-level of data
                if (ref.startsWith('$')) { ref = 'data.' + ref[1..-1] }
                out << " (<span data-bind='text:${ref}'></span>)"
            }
            // close td
            out << "</td>" << "\n"

            // >>> output each cell in the row
            model.columns[1..-1].eachWithIndex { col, colIndex ->
                out << INDENT*5 << "<td>" <<
                    "<span data-bind='text:data.${model.source}.get(${rowIndex},${colIndex})'></span>" <<
                    "</td>" << "\n"
            }

            out << INDENT*5 << "</tr>\n"
        }
        out << INDENT*4 << "</tr></tbody>\n"
    }

    def table(out, attrs, model) {

        def isprint = attrs.printable

        def extraClassAttrs = model.class ?: ""
        def tableClass = isprint ? "printed-form-table" : ""
        def validation = model.editableRows && model.source ? "data-bind=\"independentlyValidated:data.${model.source}\"":""
        out << "<div class=\"row-fluid ${extraClassAttrs}\">\n"
        out << INDENT*3 << "<table class=\"table table-bordered ${model.source} ${tableClass}\" ${validation}>\n"
        tableHeader out, attrs, model
        if (isprint) {
            tableBodyPrint out, attrs, model
        } else {
            tableBodyEdit out, attrs, model
            footer out, attrs, model
        }

        out << INDENT*3 << "</table>\n"
        out << INDENT*2 << "</div>\n"
    }

    def tableHeader(out, attrs, table) {
        Integer colCount = 0;
        pageScope.setVariable(NUMBER_OF_TABLE_COLUMNS, colCount);
        out << INDENT*4 << "<thead><tr>"
        table.columns.eachWithIndex { col, i ->
            if (isRequired(attrs, col, attrs.edit)) {
                out << "<th class=\"required\">" + labelText(attrs, col, col.title) + "</th>"
            } else {
                out << "<th>" + labelText(attrs, col, col.title) + "</th>"
            }
            colCount ++;
        }
        if (table.source && attrs.edit && !attrs.printable && (table.editableRows || getAllowRowDelete(attrs, table.source, null))) {
            out << "<th></th>"
            colCount++;
        }
        out << '\n' << INDENT*4 << "</tr></thead>\n"
        pageScope.setVariable(NUMBER_OF_TABLE_COLUMNS, colCount);
    }

    def tableBodyView (out, attrs, table) {
        if (!table.source) {
            out << INDENT*4 << "<tbody><tr>\n"
        }
        else {
            out << INDENT*4 << "<tbody data-bind=\"foreach: data.${table.source}\"><tr>\n"
        }
        table.columns.eachWithIndex { col, i ->
            col.type = col.type ?: getType(attrs, col.source, table.source)
            out << INDENT*5 << "<td>" << dataTag(attrs, col, '', false) << "</td>" << "\n"
        }
        out << INDENT*4 << "</tr></tbody>\n"
    }

    def tableBodyPrint (out, attrs, table) {

        def numRows = table.printRows ?: 10

        out << INDENT * 4 << "<tbody>\n"
        for (int rowIndex = 0; rowIndex < numRows; ++rowIndex) {
            out << INDENT * 5 << "<tr>"
            table.columns.eachWithIndex { col, i ->
                out << INDENT * 6 << "<td></td>\n"
            }

            out << INDENT * 5 << "</tr>"
        }
        out << INDENT * 4 << "</tbody>\n"
    }

    def tableBodyEdit (out, attrs, table) {
        // body elements for main rows
        if (attrs.edit) {

            def dataBind
            if (table.source) {
                def templateName = table.editableRows ? "${table.source}templateToUse" : "'${table.source}viewTmpl'"
                dataBind = "template:{name:${templateName}, foreach: data.${table.source}}"
            }
            else {
                def count = getUnnamedTableCount(true)
                def templateName = table.editableRows ? "${count}templateToUse" : "'${count}viewTmpl'"
                dataBind = "template:{name:${templateName}, data: data}"
            }

            out << INDENT*4 << "<tbody data-bind=\"${dataBind}\"></tbody>\n"
            if (table.editableRows) {
                // write the view template
                tableViewTemplate(out, attrs, table, false)
                // write the edit template
                tableEditTemplate(out, attrs, table)
            } else {
                // write the view template
                tableViewTemplate(out, attrs, table, attrs.edit)
            }
        } else {
            out << INDENT*4 << "<tbody data-bind=\"foreach: data.${table.source}\"><tr>\n"
            table.columns.eachWithIndex { col, i ->
                col.type = col.type ?: getType(attrs, col.source, table.source)
                out << INDENT*5 << "<td>" << dataTag(attrs, col, '', false) << "</td>" << "\n"
            }
            out << INDENT*4 << "</tr></tbody>\n"
        }

        // body elements for additional rows (usually summary rows)
        if (table.rows) {
            out << INDENT*4 << "<tbody>\n"
            table.rows.each { tot ->
                def at = new AttributeMap()
                if (tot.showPercentSymbol) { at.addClass('percent') }
                out << INDENT*4 << "<tr>\n"
                table.columns.eachWithIndex { col, i ->
                    if (i == 0) {
                        out << INDENT*4 << "<td>${tot.title}</td>\n"
                    } else {
                        // assume they are all computed for now
                        out << INDENT*5 << "<td>" <<
                          "<span${at.toString()} data-bind='text:data.frequencyTotals().${col.source}.${tot.source}'></span>" <<
                          "</td>" << "\n"
                    }
                }
                if (attrs.edit) {
                    out << INDENT*5 << "<td></td>\n"
                }
                out << INDENT*4 << "</tr>\n"
            }
            out << INDENT*4 << "</tbody>\n"
        }
    }

    def tableViewTemplate(out, attrs, model, edit) {
        def templateName = model.source ? "${model.source}viewTmpl" : "${getUnnamedTableCount(false)}viewTmpl"
        def allowRowDelete = getAllowRowDelete(attrs, model.source, null)
        out << INDENT*4 << "<script id=\"${templateName}\" type=\"text/html\"><tr>\n"
        model.columns.eachWithIndex { col, i ->
            col.type = col.type ?: getType(attrs, col.source, model.source)
            //log.debug "col = ${col}"
            out << INDENT*5 << "<td>" << dataTag(attrs, col, '', edit) << "</td>" << "\n"
        }
        if (model.editableRows) {
                out << INDENT*5 << "<td >\n"
                out << INDENT*6 << "<button class='btn btn-mini' data-bind='click:\$root.edit${model.source}Row, enable:!\$root.${model.source}Editing()' title='edit'><i class='icon-edit'></i> Edit</button>\n"
                if (allowRowDelete) {
                    out << INDENT * 6 << "<button class='btn btn-mini' data-bind='click:\$root.remove${model.source}Row, enable:!\$root.${model.source}Editing()' title='remove'><i class='icon-trash'></i> Remove</button>\n"
                }
                out << INDENT*5 << "</td>\n"
        } else {
            if (edit && model.source && allowRowDelete) {
                out << INDENT*5 << "<td>\n"
                out << INDENT*6 << "<i data-bind='click:\$root.remove${model.source}Row' class='icon-remove'></i>\n"
                out << INDENT*5 << "</td>\n"
            }
        }
        out << INDENT*4 << "</tr></script>\n"
    }

    def tableEditTemplate(out, attrs, model) {
        def templateName = model.source ? "${model.source}viewTmpl" : "${getUnnamedTableCount(false)}viewTmpl"
        out << INDENT*4 << "<script id=\"${templateName}\" type=\"text/html\"><tr>\n"
        model.columns.eachWithIndex { col, i ->
            def edit = !col['readOnly'];
            // mechanism for additional data binding clauses
            def bindAttrs = new Databindings()
            if (i == 0) {bindAttrs.add 'hasFocus', 'isSelected'}
            // inject type from data model
            col.type = col.type ?: getType(attrs, col.source, model.source)
            // inject computed from data model
            col.computed = col.computed ?: getComputed(attrs, col.source, model.source)
            out << INDENT*5 << "<td>" << dataTag(attrs, col, '', edit, null, bindAttrs, null) << "</td>" << "\n"
        }
        out << INDENT*5 << "<td>\n"
        out << INDENT*6 << "<a class='btn btn-success btn-mini' data-bind='click:\$root.accept${model.source}' href='#' title='save'>Update</a>\n"
        out << INDENT*6 << "<a class='btn btn-mini' data-bind='click:\$root.cancel${model.source}' href='#' title='cancel'>Cancel</a>\n"
        out << INDENT*5 << "</td>\n"
        out << INDENT*4 << "</tr></script>\n"
    }

    /**
     * Common footer output for both tables and grids.
     */
    def footer(out, attrs, model) {

        def colCount = pageScope.getVariable(NUMBER_OF_TABLE_COLUMNS);
        def containsSpecies = model.columns.find{it.type == 'autocomplete'}
        out << INDENT*4 << "<tfoot>\n"
        model.footer?.rows.each { row ->
            out << INDENT*4 << "<tr>\n"
            row.columns.eachWithIndex { col, i ->
                def attributes = new AttributeMap()
                if (getAttribute(attrs, col.source, '', 'primaryResult') == 'true') {
                    attributes.addClass('value');
                }
                def colspan = col.colspan ? " colspan='${col.colspan}'" : ''
                // inject type from data model
                col.type = col.type ?: getType(attrs, col.source, '')

                // inject computed from data model
                col.computed = col.computed ?: getComputed(attrs, col.source, '')
                out << INDENT*5 << "<td${colspan}>" << dataTag(attrs, col, 'data', attrs.edit, attributes) << "</td>" << "\n"
            }
            if (model.type == 'table' && attrs.edit) {
                out << INDENT*5 << "<td></td>\n"  // to balance the extra column for actions
            }
            out << INDENT*4 << "</tr>\n"
        }
        if (attrs.edit && model.userAddedRows) {
            out << INDENT*4 << """<tr><td colspan="${colCount}" style="text-align:left;">
                        <button type="button" class="btn btn-small" data-bind="click:add${model.source}Row"""
            if (model.editableRows) {
                out << ", enable:!\$root.${model.source}Editing()"
            }
            out << """">
                        <i class="icon-plus"></i> Add a row</button>"""
            if (!attrs.disableTableUpload) {
                out << """
                <button type="button" class="btn btn-small" data-bind="click:show${model.source}TableDataUpload"><i class="icon-upload"></i> Upload data for this table</button>


                    </td></tr>\n"""
                out << """<tr data-bind="visible:${model.source}TableDataUploadVisible"><td colspan="${colCount}">"""
                if (containsSpecies) {
                    out << """
                <div class="text-error text-left">
                    Note: Only valid exact scientific names will be matched and populated from the database (indicated by a <i class="icon-info-sign"></i> button). Unmatched species will load, but will not show <i class="icon-info-sign"></i> button. Please check your uploaded data and correct as required.
                </div>"""
                }
                out << """<div class="text-left" style="margin:5px">
                    <a href="${createLink(controller: 'proxy', action: 'excelOutputTemplate')}?type=${
                    attrs.output
                }&listName=${model.source}" target="${model.source}TemplateDownload" class="btn">Step 1 - Download template (.xlsx)</a>
                </div>
                <div class="text-left" style="margin:5px;">
                    <input type="checkbox" data-bind="checked:appendTableRows" style="margin-right:5px">Append uploaded data to table (unticking this checkbox will result in all table rows being replaced)
                </div>

                <div class="btn fileinput-button" style="margin-left:5px">
                        <input id="${
                    model.source
                }TableDataUpload" type="file" name="data" data-bind="fileUploadNoImage:${model.source}TableDataUploadOptions">
                        Step 2 - Upload populated template
                </div>"""
            }
            out<<"""</td></tr>"""
            out << """ <script id="${model.source}template-upload" type="text/x-tmpl">{% %}</script>
                       <script id="${model.source}template-download" type="text/x-tmpl">{% %}</script>"""
        }
        out << INDENT*4 << "</tfoot>\n"

    }

    def photoPoints(out, attrs, model, index) {
        table out, attrs, model
    }

    def addDeferredTemplate(name) {
        def templates = pageScope.getVariable(DEFERRED_TEMPLATES_KEY);
        if (!templates) {
            templates = []
            pageScope.setVariable(DEFERRED_TEMPLATES_KEY, templates);
        }
        templates.add(name)
    }

    def renderDeferredTemplates(out) {

        // some templates need to be rendered after the rest of the view code as it was causing problems when they were
        // embedded inside table view/edit templates. (as happened if an image type was included in a table row).
        def templates = pageScope.getVariable(DEFERRED_TEMPLATES_KEY)
        templates?.each {
            out << g.render(template: it, plugin:'fieldcapture-plugin')
        }
        pageScope.setVariable(DEFERRED_TEMPLATES_KEY, null)
    }

    /*------------ methods to look up attributes in the data model -------------*/

    static String getType(attrs, name, context) {
        getAttribute(attrs, name, context, 'dataType')
    }

    static String getComputed(attrs, name, context) {
        getAttribute(attrs, name, context, 'computed')
    }

    static boolean getAllowRowDelete(attrs, name, context) {
        def ard = getAttribute(attrs, name, context, 'allowRowDelete') ?: 'true'
        return ard.toBoolean()
    }


    static String getAttribute(attrs, name, context, attribute) {
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
        return target ? target[attribute] : null
    }

    def getAttribute(model, name) {
        return model.findResult( {

            if (it?.dataType == 'list') {
                return getAttribute(it.columns, name)
            }
            else {
                return (it.name == name)?it:null
            }

        })
    }

    /**
     * Uses a page scoped variable to track the number of unnamed tables on the page so each can have a unquie
     * rendering template.
     * @param increment true if the value should be incremented (the pre-incremented value will be returned)
     * @return
     */
    private int getUnnamedTableCount(boolean increment = false) {
        def name = 'unnamedTableCount'
        def count = pageScope.getVariable(name) ?: 0

        if (increment) {
            count++
        }
        pageScope.setVariable(name, count)

        return count
    }

}

