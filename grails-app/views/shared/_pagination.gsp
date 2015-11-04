<span data-bind="if: pagination.info()">
    <span data-bind="if: pagination.totalResults() >= pagination.rppOptions[0]-1">
        <div class="row-fluid">
            <div class="span12">
                <div class="span4 text-left">
                    <p class="hidden-xs pull-left nomargin padding20">
                        <span data-bind="text: pagination.info()"></span>
                    </p>
                </div>
                <div class="span4 text-center">
                    <p class="hidden-xs pull-center nomargin padding20">
                        <select style="width:20%;" data-bind="options: pagination.rppOptions, value: pagination.resultsPerPage" ></select>
                    </p>
                </div>
                <div class="span4 text-right">
                    <span>
                        <span data-bind="if: pagination.currentPage() > 1"><a class="btn btn-small" href="#" data-bind="click:pagination.first"><i class="fa fa-chevron-left"></i><i class="fa fa-chevron-left"></i></a></span>
                        <span data-bind="if: pagination.currentPage() > 1"><a class="btn btn-small" href="#" data-bind="click:pagination.previous"><i class="fa fa-chevron-left"></i></a></span>
                        <span data-bind="if: pagination.currentPage() > 1, click: pagination.previous"><a href="#" class="btn btn-small"><span data-bind="text: pagination.currentPage() - 1"></span></a></span>
                        <span class="active"><span class="btn btn-small btn-primary" data-bind="text: pagination.currentPage()"></span></li>
                        <span data-bind="if: pagination.currentPage() < pagination.lastPage(), click:pagination.next"><a href="#" class="btn btn-small"><span data-bind="text:pagination.currentPage() + 1"></span></a></span>
                        <span data-bind="if: pagination.currentPage() < pagination.lastPage()"><a href="#" class="btn btn-small" data-bind="click:pagination.next"><i class="fa fa-chevron-right"></i></a></span>
                        <span data-bind="if: pagination.currentPage() < pagination.lastPage()"><a href="#" class="btn btn-small" data-bind="click:pagination.last"><i class="fa fa-chevron-right"></i><i class="fa fa-chevron-right"></i></a></span>
                    </span>
                </div>
            </div>
        </div>
    </span>
</span>
</br>