<r:require module="species"/>
<span class="input-prepend input-append" data-bind="with:${source}">
    <input type="text" placeholder="" data-bind="${databindAttrs}" ${validationAttrs}/>
    <span class="add-on" data-bind="if: transients.guid">
        <a target="_blank" data-bind="attr:{href: transients.bioProfileUrl}"><i class="icon-info-sign"></i></a>
    </span>
</span>
