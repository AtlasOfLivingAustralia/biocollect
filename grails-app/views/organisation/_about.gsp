<div class="row" data-bind="visible:description">
    <div class="col-12">
        <h4>About ${organisation.name}</h4>

        <div data-bind="html:description.markdownToHtml()"></div>
    </div>
</div>