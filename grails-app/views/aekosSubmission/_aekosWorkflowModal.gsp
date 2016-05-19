<%--
  Created by IntelliJ IDEA.
  User: koh032
  Date: 11/05/2016
  Time: 2:05 PM
--%>

<style>

.modal {
//   position: relative;
    display: table;
    overflow-y: auto;
    overflow-x: auto;
    width: auto;
    min-width: 450px;
    min-height: 450px;
    text-align: center;
    top: 90px !important;
    left: 350px !important;
}


.modal-dialog {
 //   position: absolute;
    display: inline-block;
    text-align: left;
    vertical-align: middle;
    display: table;
    overflow-y: auto;
    overflow-x: auto;
    width: auto;
    min-width: 450px;
    min-height: 400px;
}
</style>

<!-- Modal -->
<div class="modal hide fade" id="aekosModal" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog"  data-bind="bootstrapShowModal:aekosModalView().show">
    <div class="modal-dialog">

        <!--div class="modal-content"-->
            <div class="modal-header">
                <button type="button" class="close" data-bind="click:aekosModalView().hideModal" aria-hidden="true">&times;</button>
                <!--button type="btton" class="close" data-dismiss="modal">&times;</button-->
                <h4 class="modal-title">Dataset: <span data-bind="text: aekosModalView().name"></span></h4>
            </div>
            <div class="modal-body" >

                <ul id="ul_submission_info" class="nav nav-pills">
                    <li class="active"><a data-bind="attr: {href: '#project-info-' + $index()}, click: aekosModalView().selectTab" data-toggle="tab" >Project Info</a></li>
                    <li><a data-bind="attr: {href: '#dataset-info-' + $index()}, click: aekosModalView().selectTab" data-toggle="tab">Dataset Description</a></li>
                    <li><a data-bind="attr: {href: '#dataset-content-' + $index()}, click: aekosModalView().selectTab" data-toggle="tab" >Dataset Content</a></li>
                    <li><a data-bind="attr: {href: '#location-dates-' + $index()}, click: aekosModalView().selectTab" data-toggle="tab" >Study Location and Dates</a></li>
                    <li><a data-bind="attr: {href: '#species-' + $index()}, click: aekosModalView().selectTab"  data-toggle="tab" >Dataset Species</a></li>
                    <li><a data-bind="attr: {href: '#materials-' + $index()}, click: aekosModalView().selectTab"  data-toggle="tab" >Supplementary Materials</a></li>
                    <li><a data-bind="attr: {href: '#collection-methods-' + $index()}, click: aekosModalView().selectTab"  data-toggle="tab" >Data Collection Methods</a></li>
                    <li><a data-bind="attr: {href: '#management-' + $index()}, click: aekosModalView().selectTab"  data-toggle="tab" >Dataset Conditions of Use and Management</a></li>
                </ul>

                <div class="tab-content">
                    <div class="tab-pane active" data-bind="attr: {id: 'project-info-' + $index() }">
                        <g:render template="/aekosSubmission/projectInfo" />
                    </div>

                    <div class="tab-pane" data-bind="attr: {id: 'dataset-info-' + $index() }" >
                        <g:render template="/aekosSubmission/datasetInfo" />
                    </div>

                    <div class="tab-pane" data-bind="attr: {id: 'dataset-content-' + $index() }">
                        <p>testabc4</p>
                        <!--g:render template="/aekosSubmission/locationDates" /-->
                    </div>

                    <div class="tab-pane" data-bind="attr: {id: 'location-dates-' + $index() }" >
                        <p>test</p>
                    </div>

                    <div class="tab-pane" data-bind="attr: {id: 'species-' + $index() }">
                        <p>test1</p>
                    </div>

                    <div class="tab-pane" data-bind="attr: {id: 'materials-' + $index() }">
                        <p>test1</p>
                    </div>

                    <div class="tab-pane" data-bind="attr: {id: 'collection-methods-' + $index() }" >
                        <p>test3</p>
                    </div>

                    <div class="tab-pane" data-bind="attr: {id: 'management-' + $index() }">
                        <p>test4</p>
                    </div>

                </div>
            </div>


            <div class="modal-footer">
                <!--button type="button" class="btn btn-default" data-dismiss="modal">Close</button-- data-bind="click: aekosModalView().selectTab"-->


                    <button class="btn-primary btn btn-small block" data-bind="disable: !aekosModalView().isSubmissionStep1InfoValid()"><i class="icon-white  icon-hdd" ></i>  Submit </button>
                    <button class="btn-primary btn btn-small block" data-bind="disable: !aekosModalView().isSubmissionStep1InfoValid(), showTabOrRedirect: {url:'', tabId: aekosModalView().selectedTab}">Next <i class="icon-white icon-chevron-right" ></i></button>

                <!--a href="#" class="btn" data-bind="click: aekosModalView().hideModal">Close</a-->
            </div>
        <!--/div-->

    </div>
</div>

<r:script>

    $(window).load(function () {

    /*    $('#aekosModal a[data-toggle="tab"]').on('show', function (e) {
            debugger;
            e.target // activated tab
            e.relatedTarget // previous tab
        }) */
       // $('tab-pane#dataset-info').show();

        //$("#ul_submission_info li a").click(function(e){
        //    e.preventDefault();
        //    var showIt =  $(this).attr('href');
        //    alert(showIt);
        //    $(".tab-pane").hide();
        //    $('tab-pane' + showIt).show();
        //})

      /*  $('.modal').resizable({
            alsoResize: ".modal-dialog",
            //minHeight: 150
        });
        $('.modal').draggable();

        $('#aekosModal').on('show', function () {
            $(this).find('.modal-body').css({
                'max-height': '100%',
                'max-width': '100%'
            });
        }); */
    });
</r:script>
