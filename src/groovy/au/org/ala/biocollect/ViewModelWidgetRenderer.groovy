package au.org.ala.biocollect
/**
 * Created by baird on 16/10/13.
 */
class ViewModelWidgetRenderer implements ModelWidgetRenderer {

    @Override
    void renderLiteral(WidgetRenderContext context) {
        context.writer << "<span ${context.attributes.toString()}>${context.model.source}</span>" // don't include context in literals
    }

    @Override
    void renderText(WidgetRenderContext context) {
        context.databindAttrs.add 'text', context.source
        context.writer << "<span ${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}'></span>"
    }

    @Override
    void renderTime(WidgetRenderContext context) {
        context.databindAttrs.add 'text', context.source
        context.writer << "<span ${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}'></span>"
    }

    @Override
    void renderReadonlyText(WidgetRenderContext context) {
        context.databindAttrs.add 'value', context.source
        context.writer << "<span ${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}'></span>"
    }

    @Override
    void renderNumber(WidgetRenderContext context) {
        context.databindAttrs.add 'text', context.source
        context.writer << "<span ${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}'></span>"
    }

    @Override
    void renderBoolean(WidgetRenderContext context) {
        context.databindAttrs.add 'visible', context.source
        context.writer << "<i data-bind='${context.databindAttrs.toString()}' class='icon-ok'></i>"
    }

    @Override
    void renderTextArea(WidgetRenderContext context) {
        context.databindAttrs.add 'text', context.source
        context.writer << "<span ${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}'></span>"
    }

    @Override
    void renderSimpleDate(WidgetRenderContext context) {
        context.databindAttrs.add 'datepicker', context.source + '.date'
        context.writer << "<input ${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}'${context.validationAttr} type='text' class='input-small'/>"
    }

    @Override
    void renderSelectOne(WidgetRenderContext context) {
        context.databindAttrs.add 'text', context.source
        context.writer << "<span ${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}'></span>"
    }

    @Override
    void renderSelectMany(WidgetRenderContext context) {
        context.databindAttrs.add 'text', context.source
        context.writer << "<span ${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}'></span>"
    }

    @Override
    void renderImage(WidgetRenderContext context) {
        context.addDeferredTemplate('/output/fileUploadTemplate')
        context.databindAttrs.add 'imageUpload', "{target:${context.source}, config:{}}"
        context.writer << context.g.render(template: '/output/imageDataTypeTemplate', model: [databindAttrs:context.databindAttrs.toString(), source: context.source, readOnly: true, name: context.source])
    }

    @Override
    void renderEmbeddedImage(WidgetRenderContext context) {
        context.databindAttrs.add "attr",  "{src: ${context.source}['thumbnail_url']}"
        context.writer << "<img data-bind=\"${context.databindAttrs.toString()}\"></img>"
    }

    @Override
    void renderEmbeddedImages(WidgetRenderContext context) {
        context.writer << "<ul class=\"imageList\" data-bind=\"foreach: ${context.source}\">"
        context.databindAttrs.add "attr",  "{src: thumbnail_url}"
        context.writer << "<li><a data-bind=\"attr:{href:url}\"><img data-bind=\"${context.databindAttrs.toString()}\"></img></a></li>"
        context.writer << "</ul>"
    }

    @Override
    void renderAutocomplete(WidgetRenderContext context) {
        renderFusedAutocomplete(context);
    }

    @Override
    void renderFusedAutocomplete(WidgetRenderContext context) {
        context.databindAttrs.add 'text', 'name'
        context.writer << """<span data-bind="with: ${context.source}"><span${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}'></span>
            <a  target="_blank" data-bind="visible: guid, attr: {href: transients.bioProfileUrl}"><i class="icon-info-sign"></i></a>
            </span>"""
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
    void renderDate(WidgetRenderContext context) {
        context.writer << "<span data-bind=\"text:${context.source}.formattedDate\"></span>"
    }

    @Override
    void renderDocument(WidgetRenderContext context) {
        context.writer << """<div data-bind="if:(${context.source}())">"""
        context.writer << """    <div data-bind="template:{name:'documentViewTemplate', data:${context.source}}"></div>"""
        context.writer << """</div>"""
    }

    @Override
    void renderButtonGroup(WidgetRenderContext context) {

    }

    @Override
    void renderGeoMap(WidgetRenderContext context) {
        context.model.readonly = true
        context.writer << context.g.render(template: '/output/dataEntryMap', model: context.model)
    }
}
