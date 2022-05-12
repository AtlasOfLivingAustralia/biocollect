<g:if test="${bs == 4}">
    <!-- ko if: pagination.info() && (pagination.totalResults() >= pagination.rppOptions[0]-1) -->
        <div class="pagination-container pagination-footer row ${classes?:''}">
            <div class="col-xs-12 col-lg-4 d-flex align-items-center justify-content-center justify-content-lg-start">
                <div class="showing" data-bind="text: pagination.info()"></div>
            </div>

            <div class="col-xs-12 col-lg-4 d-flex align-items-center justify-content-center pt-3 pt-lg-0 pb-3 pb-lg-0">
                <nav aria-label="Featured Projects Navigation">
                    <ul class="pagination justify-content-center">
                        <!-- ko if: pagination.currentPage() > 1 -->
                        <li class="page-item"><a class="page-link" href="#"
                                                                                              data-bind="click:pagination.first"><i
                                    class="fas fa-angle-double-left"></i></a></li>
                        <li class="page-item"><a class="page-link" href="#"
                                                                                              data-bind="click:pagination.previous"><i
                                    class="fa fa-angle-left"></i></a></li>
                        <li class="page-item"
                            data-bind="click: pagination.previous"><a
                                class="page-link" href="#"><span data-bind="text: pagination.currentPage() - 1"></span>
                        </a></li>
                        <!-- /ko -->
                        <li class="page-item"><a class="page-link active"
                                                 data-bind="text: pagination.currentPage()"></a></li>
                        <!-- ko if: pagination.currentPage() < pagination.lastPage() -->
                        <li class="page-item"
                            data-bind="click:pagination.next"><a
                                class="page-link" href="#"><span data-bind="text:pagination.currentPage() + 1"></span>
                        </a></li>
                        <li class="page-item"><a
                                class="page-link" href="#" data-bind="click:pagination.next"><i
                                    class="fa fa-angle-right"></i></a></li>
                        <li class="page-item"><a
                                class="page-link" href="#" data-bind="click:pagination.last"><i
                                    class="fas fa-angle-double-right"></i></a></li>
                        <!-- /ko -->
                    </ul>
                </nav>
            </div>

            <div class="col-xs-12 col-lg-4 d-flex align-items-center justify-content-center justify-content-lg-end">
                <div class="limiter text-right">
                    <g:message code="label.show"/>
                    <label for="projectsLimit" class="sr-only"><g:message code="label.items.page"/></label>
                    <select class="custom-select projects-limiter" id="projectsLimit"
                            data-bind="options: pagination.rppOptions, value: pagination.resultsPerPage"></select>
                </div>
            </div>
        </div>
    <!-- /ko -->
</g:if>
<g:else>
    <span data-bind="if: pagination.info()">
        <span data-bind="if: pagination.totalResults() >= pagination.rppOptions[0]-1">
            <div class="row-fluid">
                <div class="span12">
                    <div class="span4 text-left">
                        <p class="hidden-xs pull-left nomargin">
                            <span data-bind="text: pagination.info()"></span>
                        </p>
                    </div>

                    <div class="span3 text-center">
                        <p class="hidden-xs pull-center nomargin padding20">
                            <select style="width:60px;"
                                    data-bind="options: pagination.rppOptions, value: pagination.resultsPerPage"></select>
                        </p>
                    </div>

                    <div class=" text-right">
                        <span>
                            <span data-bind="if: pagination.currentPage() > 1"><a class="btn btn-small" href="#"
                                                                                  data-bind="click:pagination.first"><i
                                        class="fa fa-chevron-left"></i><i class="fa fa-chevron-left"></i></a></span>
                            <span data-bind="if: pagination.currentPage() > 1"><a class="btn btn-small" href="#"
                                                                                  data-bind="click:pagination.previous"><i
                                        class="fa fa-chevron-left"></i></a></span>
                            <span data-bind="if: pagination.currentPage() > 1, click: pagination.previous"><a href="#"
                                                                                                              class="btn btn-small"><span
                                        data-bind="text: pagination.currentPage() - 1"></span></a></span>
                            <span class="active"><span class="btn btn-small btn-primary"
                                                       data-bind="text: pagination.currentPage()"></span></span>
                            <span data-bind="if: pagination.currentPage() < pagination.lastPage(), click:pagination.next"><a
                                    href="#" class="btn btn-small"><span
                                        data-bind="text:pagination.currentPage() + 1"></span></a></span>
                            <span data-bind="if: pagination.currentPage() < pagination.lastPage()"><a href="#"
                                                                                                      class="btn btn-small"
                                                                                                      data-bind="click:pagination.next"><i
                                        class="fa fa-chevron-right"></i></a></span>
                            <span data-bind="if: pagination.currentPage() < pagination.lastPage()"><a href="#"
                                                                                                      class="btn btn-small"
                                                                                                      data-bind="click:pagination.last"><i
                                        class="fa fa-chevron-right"></i><i class="fa fa-chevron-right"></i></a></span>
                        </span>
                    </div>
                </div>
            </div>
        </span>
    </span>
</g:else>