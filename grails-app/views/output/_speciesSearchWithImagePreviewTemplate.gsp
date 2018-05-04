<div class="row-fluid" data-bind="with:${source}">
    <div class="span6">
        <div class="row-fluid">
            <div class="span12">
                <g:if test="${readonly}">
                    <span data-bind="${databindAttrs}"></span>
                </g:if>
                <g:else>
                    <input class="full-width-input content-box form-control" type="text" placeholder="Start typing a species name" data-bind="${databindAttrs}" ${validationAttrs} ${attrs}/>
                </g:else>
            </div>
        </div>
    </div>
    <g:if test="${!readonly}">
    <div class="span6">
        <div class="row-fluid">
            <div class="span12" data-bind="slideVisible: transients.guid">
                <div class="sciName">
                    <a href="" class="tooltips" title="view species page" target="BIE"
                       data-bind="attr:{href: transients.bioProfileUrl}, text: name"></a>
                </div>
            </div>
        </div>
        <div class="row-fluid">
            <div class="span12" data-bind="slideVisible: transients.guid">
                <img class="speciesThumbnail" alt="thumbnail image of species"
                 data-bind="getImage: transients.guid, attr: {src: transients.image}, visible: transients.image">
            </div>
        </div>
    </div>
    </g:if>
</div>
