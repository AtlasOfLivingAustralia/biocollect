<script>
    (function (){
        $("${listenTo}").on("resizefilters", setFilterPanelSize);
        $(document).on("shown.bs.tab", setFilterPanelSize);
        // Boostrap Collapse removes styles when filter is hidden. Reset height everytime filter panel is shown.
        $("${target}").on("shown.bs.collapse", setFilterPanelSize);
        function setFilterPanelSize() {
            var dependent = "${dependentDiv}",
                dependency = "${target ?: "#filters"}",
                height = $(dependent).outerHeight();

            $(dependency).outerHeight(height);
        }
    })();
</script>
