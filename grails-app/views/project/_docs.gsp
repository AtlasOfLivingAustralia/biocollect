<div class="well" >
    <div class="row-fluid text-center">
        <div class="span2 ">
            <b>Project documents:</b>
        </div>
        <div class="span10 text-left">
            <!-- <div id="documents" data-bind="css: { span3: primaryImages() != null, span7: primaryImages() == null }"> -->
            <div id="documents">
                <div data-bind="visible:documents().length == 0">
                    No documents are currently attached to this project.
                    <g:if test="${user?.isAdmin}">To add a document use the Documents section of the Admin tab.</g:if>
                </div>
                <g:render template="/shared/listDocuments"
                          model="[useExistingModel: true, editable: false, filterBy: 'all', ignore: 'programmeLogic', imageUrl:asset.assetPath(src:'filetypes'),containerId:'overviewDocumentList']"/>
            </div>
        </div>

    </div>
</div>
