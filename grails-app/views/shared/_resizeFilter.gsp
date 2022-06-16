<script>
    (function (){
        $("${listenTo}").on("resizefilters", setFilterPanelSize);
        $(document).on("shown.bs.tab", setFilterPanelSize);
        // Boostrap Collapse removes styles when filter is hidden. Reset height everytime filter panel is shown.
        // Using setTimeout to wait for animation to finish.
        $("${target}").on("shown.bs.collapse", function () { setTimeout(setFilterPanelSize, 100) });
        function setFilterPanelSize() {
            var dependent = "${dependentDiv}",
                dependency = "${target ?: "#filters"}",
                height = $(dependent).outerHeight();

            $(dependency).outerHeight(height);
        }
    })();
</script>
