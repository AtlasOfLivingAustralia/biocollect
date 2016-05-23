<%--
  Created by IntelliJ IDEA.
  User: koh032
  Date: 11/05/2016
  Time: 2:05 PM
--%>

<style>

.aekosModal{
    width: 90%; /* desired relative width */
    min-height:80%;
    left: 5%; /* (100%-width)/2 */
    margin: auto auto auto auto; /* place center */}

.aekosModal .modal-body{overflow-y:scroll;max-height:none;position:absolute;top:50px;bottom:50px;right:0px;left:0px;}

.aekosModal .modal-footer {position: absolute;bottom: 0;right: 0;left: 0;}


</style>

<!-- Modal -->
<div class="modal hide fade aekosModal validationEngineContainer" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog"  data-bind="bootstrapShowModal:aekosModalView().show">
    <div class="modal-dialog">

        <!--div class="modal-content"-->
            <div class="modal-header">
                <button type="button" class="close" data-bind="click:aekosModalView().hideModal" aria-hidden="true">&times;</button>
                <!--button type="btton" class="close" data-dismiss="modal">&times;</button-->
                <h4 class="modal-title">Dataset: <span data-bind="text: aekosModalView().name"></span></h4>
            </div>
            <div class="modal-body" >

                %{--<span data-bind="text: aekosModalView().selectedTab"></span>--}%

                <ul  data-bind="attr: {id: 'ul_submission_info-' + $index() }" class="nav nav-pills">
                    <li data-bind="css: { active: aekosModalView().selectedTab() == 'tab-1' }"><a data-bind="attr: {href: '#project-info-' + $index(), id: 'tab-1-' + $index()}, click: aekosModalView().selectTab" data-toggle="tab" >Project<br>Info</a></li>
                    <li data-bind="css: { active: aekosModalView().selectedTab() == 'tab-2', disabled: !aekosModalView().isValidationValid() }"><a data-bind="attr: {href: '#dataset-info-' + $index(), id: 'tab-2-' + $index(), 'data-toggle': aekosModalView().dataToggleVal()}, css:{disabled: !aekosModalView().isValidationValid()}, click: function(data, event) {aekosModalView().selectTab(data, event);}">Dataset<br>Description</a></li>
                    <li data-bind="css: { active: aekosModalView().selectedTab() == 'tab-3' }"><a data-bind="attr: {href: '#dataset-content-' + $index(), id: 'tab-3-' + $index()}, click: aekosModalView().selectTab" data-toggle="tab" >Dataset<br>Content</a></li>
                    <li data-bind="css: { active: aekosModalView().selectedTab() == 'tab-4' }"><a data-bind="attr: {href: '#location-dates-' + $index(), id: 'tab-4-' + $index()}, click: aekosModalView().selectTab" data-toggle="tab" >Study Location<br>and Dates</a></li>
                    <li data-bind="css: { active: aekosModalView().selectedTab() == 'tab-5' }"><a data-bind="attr: {href: '#species-' + $index(), id: 'tab-5-' + $index()}, click: aekosModalView().selectTab"  data-toggle="tab" >Dataset<br>Species</a></li>
                    <li data-bind="css: { active: aekosModalView().selectedTab() == 'tab-6' }"><a data-bind="attr: {href: '#materials-' + $index(), id: 'tab-6-' + $index()}, click: aekosModalView().selectTab"  data-toggle="tab" >Supplementary<br>Materials</a></li>
                    <li data-bind="css: { active: aekosModalView().selectedTab() == 'tab-7' }"><a data-bind="attr: {href: '#collection-methods-' + $index(), id: 'tab-7-' + $index()}, click: aekosModalView().selectTab"  data-toggle="tab" >Data Collection<br>Methods</a></li>
                    <li data-bind="css: { active: aekosModalView().selectedTab() == 'tab-8' }"><a data-bind="attr: {href: '#contacts-' + $index(), id: 'tab-8-' + $index()}, click: aekosModalView().selectTab"  data-toggle="tab" >Dataset Contact<br>and Author(s)</a></li>
                    <li data-bind="css: { active: aekosModalView().selectedTab() == 'tab-9' }"><a data-bind="attr: {href: '#management-' + $index(), id: 'tab-9-' + $index()}, click: aekosModalView().selectTab"  data-toggle="tab" >Dataset Conditions<br>of Use and Management</a></li>
                </ul>

                <div class="tab-content">
                    <div class="tab-pane active" data-bind="attr: {id: 'project-info-' + $index() }">
                        <g:render template="/aekosSubmission/projectInfo" />
                    </div>

                    <div class="tab-pane" data-bind="attr: {id: 'dataset-info-' + $index() }" >
                        <g:render template="/aekosSubmission/datasetInfo" />
                    </div>

                    <div class="tab-pane" data-bind="attr: {id: 'dataset-content-' + $index() }">
                        <g:render template="/aekosSubmission/datasetContent" />
                    </div>

                    <div class="tab-pane" data-bind="attr: {id: 'location-dates-' + $index() }" >
                        <g:render template="/aekosSubmission/locationDates" />
                    </div>

                    <div class="tab-pane" data-bind="attr: {id: 'species-' + $index() }">
                        <g:render template="/aekosSubmission/species" />
                    </div>

                    <div class="tab-pane" data-bind="attr: {id: 'materials-' + $index() }">
                        %{--<g:render template="/aekosSubmission/materials" />--}%
                    </div>

                    <div class="tab-pane" data-bind="attr: {id: 'collection-methods-' + $index() }" >
                        <g:render template="/aekosSubmission/methods" />
                    </div>

                    <div class="tab-pane" data-bind="attr: {id: 'contacts-' + $index() }" >
                        <g:render template="/aekosSubmission/contacts" />
                    </div>

                    <div class="tab-pane" data-bind="attr: {id: 'management-' + $index() }">
                        <p>test4</p>
                    </div>

                </div>
            </div>


            <div class="modal-footer">
                <!--button type="button" class="btn btn-default" data-dismiss="modal">Close</button-- data-bind="click: aekosModalView().selectTab"-->

                    %{--<span data-bind="text: aekosModalView().selectedTab"></span>--}%
                    <button class="btn-primary btn btn-small block" data-bind="disable: !aekosModalView().isValidationValid(), click: aekosModalView().submit"><i class="icon-white  icon-hdd" ></i>  Submit </button>
                    <button class="btn-primary btn btn-small block" data-bind="disable: !aekosModalView().isValidationValid(), click: function() {aekosModalView().selectNextTab('#' + aekosModalView().nextTab() + '-' + $index())}">Next <i class="icon-white icon-chevron-right" ></i></button>

                <!--a href="#" class="btn" data-bind="click: aekosModalView().hideModal">Close</a      -->
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

        $("div.modal.hide.fade.aekosModal").on('hide', function () {
            window.location.reload();
        });

        $("div.modal.hide.fade.aekosModal").validationEngine();
    });
</r:script>
