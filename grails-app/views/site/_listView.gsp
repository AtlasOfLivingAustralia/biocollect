<bc:koLoading>
    <!-- ko foreach: sites -->
    <div class="row">
        <h3><a data-bind="attr:{href:getSiteUrl()}, text: name"></a></h3>
    </div>
    <!-- /ko -->
</bc:koLoading>