package au.org.ala.biocollect.merit

/**
 * Created by baird on 18/10/13.
 */
class PrintModelWidgetRenderer implements ModelWidgetRenderer {

    @Override
    void renderLiteral(WidgetRenderContext context) {
        context.writer << "<span ${context.attributes.toString()}>${context.model.source}</span>"
    }

    @Override
    void renderText(WidgetRenderContext context) {
        defaultRender(context)
    }

    @Override
    void renderNumber(WidgetRenderContext context) {
        defaultRender(context)
    }

    @Override
    void renderBoolean(WidgetRenderContext context) {
        defaultRender(context)
    }

    @Override
    void renderTextArea(WidgetRenderContext context) {
        context.writer << "<span class=\"span12 printed-form-field textarea\"></span>"
//        context.databindAttrs.add 'value', context.source
//        context.writer << "<textarea ${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}'></textarea>"
    }

    @Override
    void renderSimpleDate(WidgetRenderContext context) {
        defaultRender(context)
    }

    @Override
    void renderSelectOne(WidgetRenderContext context) {
        renderCheckboxes(context)
    }

    @Override
    void renderSelectMany(WidgetRenderContext context) {
        renderCheckboxes(context)
    }

    @Override
    void renderImage(WidgetRenderContext context) {
        defaultRender(context)
    }

    @Override
    void renderEmbeddedImage(WidgetRenderContext context) {
        defaultRender(context)
    }

    @Override
    void renderEmbeddedImages(WidgetRenderContext context) {
        defaultRender(context)
    }

    @Override
    void renderAutocomplete(WidgetRenderContext context) {
        defaultRender(context)
    }

    @Override
    void renderPhotoPoint(WidgetRenderContext context) {
        defaultRender(context)
    }

    @Override
    void renderLink(WidgetRenderContext context) {
        defaultRender(context)
    }

    @Override
    void renderDate(WidgetRenderContext context) {
        defaultRender(context)
    }

    @Override
    void renderDocument(WidgetRenderContext context) {
        defaultRender(context)
    }

    private void defaultRender(WidgetRenderContext context) {


        context.writer << "<span class=\"span12 printed-form-field\"></span>"
        // context.databindAttrs.add 'value', context.source
//        context.writer << "<input ${context.attributes.toString()} data-bind='${context.databindAttrs.toString()}' ${context.validationAttr} type='text' class='input-small'/>"
    }

    private void renderCheckboxes(WidgetRenderContext context) {
        context.labelAttributes.addClass 'checkbox-list-label '
        def constraints = 'transients.' + context.model.source + 'Constraints'
        context.writer << """
            <ul class="checkbox-list" data-bind="foreach: ${constraints}">
                <li>
                    <span class="printed-checkbox">&nbsp;</span>&nbsp;<span data-bind="text:\$data"></span>
                </li>
            </ul>
        """
    }
}
