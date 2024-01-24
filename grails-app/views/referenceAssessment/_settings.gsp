<!-- ko stopBinding: true -->
<h4 class="mt-3 mt-lg-0">Reference assessment settings</h4>

<p>Manage the configuration for <b>reference assessment</b> projects, where user-editable assessment records are created from a reference set.</p>

<div id="pReferenceAssessmentActivities" >

    <div id="admin-project-reference-assessment">

        <div class="row mb-2">
            <div class="col-12">
                <div class="btn-space">
                    <!-- ko if: projectActivities().length > 0 -->
                     <span> <b> Select reference survey: </b></span>
                     <div class="btn-group" role="group">
                         <button type="button" class="btn btn-sm btn-dark dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            <!-- ko  foreach: projectActivities -->
                                <span data-bind="if: current">
                                   <span data-bind="text: name"></span> <span class="caret"></span>
                                </span>
                            <!-- /ko -->
                          </button>
                         <div class="dropdown-menu" style="height: auto;max-height: 200px;overflow-x: hidden;">
                            <!-- ko  foreach: projectActivities -->
                                <a class="dropdown-item" href="#" data-bind="click: $root.setCurrent" >
                                    <span data-bind="attr:{'class': published() ? 'badge badge-success' : 'badge badge-danger'}">
                                    <span data-bind="if:published()"> <small>P</small></span>
                                    <span data-bind="if:!published()"> <small>X</small></span>
                                    </span>
                                    <span data-bind="text: name"></span>
                                    <span data-bind="if: current"> <span class="badge badge-info">selected</span></span>
                                </a>
                            <!-- /ko -->
                          </div>
                     </div>
                    <!-- /ko -->
                </div>
            </div>
        </div>
        <div class="row mb-4">
            <div class="col-12">
                <div class="btn-space">
                    <!-- ko if: projectActivities().length > 0 -->
                     <span> <b> Select assessment survey: </b></span>
                     <div class="btn-group" role="group">
                         <button type="button" class="btn btn-sm btn-dark dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            <!-- ko  foreach: projectActivities -->
                                <span data-bind="if: current">
                                   <span data-bind="text: name"></span> <span class="caret"></span>
                                </span>
                            <!-- /ko -->
                          </button>
                         <div class="dropdown-menu" style="height: auto;max-height: 200px;overflow-x: hidden;">
                            <!-- ko  foreach: projectActivities -->
                                <a class="dropdown-item" href="#" data-bind="click: $root.setCurrent" >
                                    <span data-bind="attr:{'class': published() ? 'badge badge-success' : 'badge badge-danger'}">
                                    <span data-bind="if:published()"> <small>P</small></span>
                                    <span data-bind="if:!published()"> <small>X</small></span>
                                    </span>
                                    <span data-bind="text: name"></span>
                                    <span data-bind="if: current"> <span class="badge badge-info">selected</span></span>
                                </a>
                            <!-- /ko -->
                          </div>
                     </div>
                    <!-- /ko -->
                </div>
            </div>
        </div>

        <!-- ko if: projectActivities().length > 0 -->
                <div id="project-reference-assessment-activities-result-placeholder"></div>
        <!-- /ko -->
</div>

</span>

</div>
<!-- /ko -->

<asset:script type="text/javascript">
    function initialiseProjectAssessmentActivitiesSettings(pActivitiesVM) {
        var pReferenceAssessmentActivitiesSettingsVM = new ProjectActivitiesSettingsViewModel(pActivitiesVM, 'project-reference-assessment-activities-result-placeholder');
        ko.applyBindings(pReferenceAssessmentActivitiesSettingsVM, document.getElementById('pReferenceAssessmentActivities'));

        // Delay subscription until the databinding has modified pActivity.pFormName if any
        if(pReferenceAssessmentActivitiesSettingsVM.current()) {
            pReferenceAssessmentActivitiesSettingsVM.current().transients.subscribeOrDisposePActivityFormName(true);
        }
    };
</asset:script>

