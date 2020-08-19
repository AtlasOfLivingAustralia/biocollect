<div class="organisation-header banner" data-bind="style:{'backgroundImage':asBackgroundImage(bannerUrl())}">
    <div class="row-fluid ">
        <span data-bind="visible:logoUrl"><img class="logo" data-bind="attr:{'src':logoUrl}"></span>

        <div class="pull-right" style="vertical-align: middle;">
            <span data-bind="foreach:transients.socialMedia">
                <a data-bind="attr:{href:link.url}"><img data-bind="attr:{src:logo('${imageUrl}')}"/></a>
            </span>
        </div>

        <div class="header-text">
            <h2>${organisation.name}</h2>
        </div>
    </div>
</div>