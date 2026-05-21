<span class="float-end">
    <!-- ko if: published()-->
    <a href="#" class="helphover" data-bind="popover: {title:'Survey status', content:'Survey is listed on the survey page and ready for data entry'}">
        <span class="badge text-bg-success">Published</span>
    </a>
    <!-- /ko -->

    <!-- ko if: !published()-->
    <a href="#" class="helphover" data-bind="popover: {title:'Survey status', content:'Survey is not visible on the survey page and no survey data is accessible.'}">
        <span class="badge text-bg-info">Unpublished</span>
    </a>
    <!-- /ko -->
</span>