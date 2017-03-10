<div class="timefield input-append">
    <input${attr.toString()} id="${source}TimeField" data-bind='${databindAttrs.toString()}'${validationAttr} type='text' class='input-mini timepicker'/>
</div>
<script>
    $(function () {
        $(document).on('imagedatetime', function (event, data) {
            var id = "${source}TimeField",
                el = document.getElementById(id),
                viewModel = ko.dataFor(el);

            if(viewModel.data.${source} && !viewModel.data.${source}()){
                var date = new Date(data.date);
                $('#${source}TimeField').timeEntry('setTime', date);
            }
        });
    });
</script>