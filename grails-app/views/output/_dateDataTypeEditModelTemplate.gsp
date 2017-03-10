<div id="${source}Date" class="input-append">
    <input ${attr.toString()} data-bind="datepicker:${source}.date" type="text" size="12"${validationAttr}/>
    <span class="add-on open-datepicker"><i class="icon-calendar"></i></span>
</div>
<script>
    $(function () {
        $(document).on('imagedatetime', function (event, data) {
            var id = "${source}Date",
                el = document.getElementById(id),
                viewModel = ko.dataFor(el);

            if(viewModel.${source} && !viewModel.${source}()){
                viewModel.${source}(data.date);
            }
        });
    });
</script>