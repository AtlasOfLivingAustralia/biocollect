<r:require module="species"/>
<div class="row-fluid" data-bind="with:${source}">
    <div class="span6">
        <g:if test="${readonly}">
            <span data-bind="${databindAttrs}"></span>
        </g:if>
        <g:else>
            <span class="input-prepend input-append">
                <input type="text" placeholder="Start typing a species name" data-bind="${databindAttrs}" ${validationAttrs} ${attrs}/>
            </span>
        </g:else>
    </div>

    <div class="span6">
        <div class="well well-small" data-bind="slideVisible: transients.guid">
            <div class="row-fluid">
                <div class="span12">
                    <img class="speciesThumbnail" alt="thumbnail image of species"
                         data-bind="getImage: transients.guid, attr: {src: transients.image}, visible: transients.image">
                </div>
            </div>
            <div class="row-fluid">
                <div class="span12">
                    <div class="sciName">
                        <a href="" class="tooltips" title="view species page" target="BIE"
                           data-bind="attr:{href: transients.bioProfileUrl}, text: transients.scientificName"></a>
                    </div>
                    <div class="commonName" data-bind="text: transients.commonName"></div>
                </div>

            </div>
        </div>
    </div>
</div>
