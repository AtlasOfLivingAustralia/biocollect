package au.org.ala.biocollect.merit

public class EditModelWidgetRenderer implements ModelWidgetRenderer {

    @Override
    void renderLiteral(WidgetRenderContext context) {
        context.writer << "<span ${context.attributes.toString()}>${context.model.source}</span>"
    }

    @Override
    void renderReadonlyText(WidgetRenderContext context) {
        context.databindAttrs.add 'value', context.source
        context.writer << "<span ${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}'></span>"
    }

    @Override
    void renderText(WidgetRenderContext context) {
        context.attributes.addClass context.getInputWidth()
        context.databindAttrs.add 'value', context.source
        context.writer << "<input ${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}' ${context.validationAttr} type='text' class='input-small'/>"
    }

    @Override
    void renderNumber(WidgetRenderContext context) {
        context.attributes.addClass context.getInputWidth()
        context.attributes.add 'style','text-align:center'
        context.databindAttrs.add 'value', context.source
        context.writer << "<input${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}'${context.validationAttr} type='number' class='input-mini'/>"
    }

    @Override
    void renderBoolean(WidgetRenderContext context) {
        context.databindAttrs.add 'checked', context.source
        context.writer << "<input${context.attributes.toString()} name='${context.source}' data-bind='${context.databindAttrs.toString()}'${context.validationAttr} type='checkbox' class='checkbox'/>"
    }

    @Override
    void renderTextArea(WidgetRenderContext context) {
        context.databindAttrs.add 'value', context.source
        context.writer << "<textarea ${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}'></textarea>"
    }

    @Override
    void renderSimpleDate(WidgetRenderContext context) {
        context.databindAttrs.add 'datepicker', context.source + '.date'
        context.writer << "<input${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}'${context.validationAttr} type='text' class='input-small'/>"
    }

    @Override
    void renderSelectOne(WidgetRenderContext context) {
        context.databindAttrs.add 'value', context.source
        // Select one or many view types require that the data model has defined a set of valid options
        // to select from.
        context.databindAttrs.add 'options', 'transients.' + context.model.source + 'Constraints'
        context.databindAttrs.add 'optionsCaption', '"Please select"'
        context.writer <<  "<select${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}'${context.validationAttr}></select>"
    }

    @Override
    void renderSelectMany(WidgetRenderContext context) {
        context.labelAttributes.addClass 'checkbox-list-label '
        def constraints = 'transients.' + context.model.source + 'Constraints'
        // This complicated binding string is to ensure we have unique ids for checkboxes, even when they are nested
        // inside tables.  (The ids are necessary to allow the label to be selected to check the checkbox.  This is
        // in turn necessary to make checkboxes usabled on mobile devices).
        def idBinding = "'${context.model.source}'+\$index()+'-'+(\$parentContext.\$index?\$parentContext.\$index():'')"
        def nameBinding = "'${context.model.source}'+'-'+(\$parentContext.\$index?\$parentContext.\$index():'')"
        context.databindAttrs.add 'value', '\$data'
        context.databindAttrs.add 'checked', "\$parent.${context.source}"
        context.databindAttrs.add 'attr', "{'id': ${idBinding}, 'name': ${nameBinding}}"
        context.writer << """
            <ul class="checkbox-list" data-bind="foreach: ${constraints}">
                <li>
                    <label data-bind="attr:{'for': ${idBinding}}"><input type="checkbox" name="${context.source}" data-bind="${context.databindAttrs.toString()}" ${context.validationAttr}/><span data-bind="text:\$data"/></label></span>
                </li>
            </ul>
        """
    }

    @Override
    void renderImage(WidgetRenderContext context) {
        context.addDeferredTemplate('/output/fileUploadTemplate')
        context.databindAttrs.add 'imageUpload', "{target:${context.source}, config:{}}"

        context.writer << context.g.render(template: '/output/imageDataTypeTemplate', plugin:'fieldcapture-plugin', model: [databindAttrs:context.databindAttrs.toString(), source: context.source])
    }

    @Override
    void renderEmbeddedImage(WidgetRenderContext context) {
        context.addDeferredTemplate('/output/fileUploadTemplate')
        context.databindAttrs.add 'imageUpload', "{target:${context.source}, config:{}}"
        context.writer << context.g.render(template: '/output/imageDataTypeTemplate', plugin:'fieldcapture-plugin', model: [databindAttrs: context.databindAttrs.toString(), source: context.source])
    }

    @Override
    void renderEmbeddedImages(WidgetRenderContext context) {
        // The file upload template has support for multiple images.
        renderEmbeddedImage(context)
    }

    @Override
    void renderAutocomplete(WidgetRenderContext context) {
        renderFusedAutocomplete(context)
    }

    @Override
    void renderFusedAutocomplete(WidgetRenderContext context) {
        def newAttrs = new Databindings()
        def source = context.g.createLink(controller: 'search', action:'species', absolute:'true')
        newAttrs.add "value", "name"
        newAttrs.add "event", "{focusout:focusLost}"
        newAttrs.add "fusedAutocomplete", "{source:transients.source, name:transients.name, guid:transients.guid}"
        context.writer << context.g.render(template: '/output/speciesTemplate', plugin:'fieldcapture-plugin', model:[source: context.source, databindAttrs: newAttrs.toString(), validationAttrs:context.validationAttr])
    }

    @Override
    void renderPhotoPoint(WidgetRenderContext context) {
        context.writer << """
        <div><b><span data-bind="text:name"/></b></div>
        <div>Lat:<span data-bind="text:lat"/></div>
        <div>Lon:<span data-bind="text:lon"/></div>
        <div>Bearing:<span data-bind="text:bearing"/></div>
        """
    }

    @Override
    void renderLink(WidgetRenderContext context) {
        context.writer << "<a href=\"" + context.g.createLink(context.specialProperties(context.model.properties)) + "\">${context.model.source}</a>"
    }

    @Override
    void renderButtonGroup(WidgetRenderContext context) {
        context.model.buttons.each {
            context.writer << """
            <a href="#" data-bind="${it.dataBind}" class="${it.class}" title="${it.title}"><span class="${it.iconClass}">&nbsp;</span>${it.title}</a>
        """
        }

    }

    @Override
    void renderDate(WidgetRenderContext context) {
        context.writer << "<div class=\"input-append\"><input data-bind=\"datepicker:${context.source}.date\" type=\"text\" size=\"12\"${context.validationAttr}/>"
        context.writer << "<span class=\"add-on open-datepicker\"><i class=\"icon-th\"></i></span></div>"
    }


    @Override
    void renderDocument(WidgetRenderContext context) {
        context.writer << """<div data-bind="if:(${context.source}())">"""
        context.writer << """    <div data-bind="editDocument:${context.source}"></div>"""
        context.writer << """</div>"""
        context.writer << """<div data-bind="ifnot:${context.source}()">"""
        context.writer << """    <button class="btn" id="doAttach" data-bind="click:function(target) {attachDocument(${context.source})}">Attach Document</button>"""
        context.writer << """</div>"""
    }

}
