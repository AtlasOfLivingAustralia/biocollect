<span>
    <!-- ko if: published()-->
    <a href="#" class="helphover" data-bind="popover: {title:'Survey status', content:'Survey is listed on the survey page and ready for data entry'}">
        <span class="badge badge-success">Published</span>
    </a>
    <!-- /ko -->

    <!-- ko if: !published()-->
    <a href="#" class="helphover" data-bind="popover: {title:'Survey status', content:'Survey is not visible on the survey page and no survey data is accessible.'}">
        <span class="badge badge-important">Unpublished</span>
    </a>
    <!-- /ko -->
</span>