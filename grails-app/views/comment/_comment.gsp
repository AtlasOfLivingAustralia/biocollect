<div id="commentOutput" class="${mobile?'d-none':''}">
    <h3>Comments (<b data-bind="text: total"></b>)</h3>
    <div id="postComment" class="comment clearfix comment-post">
        <div class="comment-header">
        </div>

        <div class="comment-body">
            <label for="commentMainTextarea">Write your comment below</label>
            <textarea id="commentMainTextarea" class="form-control" data-bind="value: newComment().text"></textarea>
        </div>

        <div class="comment-footer float-right">
            <div class="btn btn-primary-dark btn-sm" data-bind="click: create"><i class="fas fa-plus"></i> post</div>
        </div>
    </div>
    <hr>
    <div id="commentDisplay">
        <div id="commentTools">
            <span>
                <select class="form-control"
                        data-bind="options: sortOptions, optionsText: 'text', value: selectedSort, event:{change: list}"></select>
            </span>
        </div>

        <div class="comment-list" data-bind="template:{name:'template-comment',foreach: comments}">
        </div>
    </div>
    <div data-bind="visible: showLoadMore" class="row">
        <div class="col-12">
            <button class="btn btn-block btn-primary-dark" data-bind="click: more"><i class="fas fa-chevron-circle-down"></i> load more comments</button>
        </div>
    </div>
</div>
<script type="text/html" id="template-comment">
    <div class="comment-body">
        <div class="media" >
            <div class="float-left comment-indent" data-bind="css: { hide: !$data.parent()}"></div>
            <div class="media-body" >
                <b class="comment-username media-heading" data-bind="text: displayName, visible: !!displayName"></b>
                <span data-bind="visible: !!lastUpdated()">commented on <span data-bind="text: lastUpdated.formattedDate"></span></span>
                <div data-bind="visible: !edit()">
                    <pre class="media" data-bind="text: text">
                    </pre>
                    <div class="row btn-space">
                        <div class="col-12">
                            <span data-bind="visible: $root.canModifyOrDeleteComment($data)"><a class="btn btn-sm btn-dark" data-bind="click: $root.edit"><i class="fas fa-pencil-alt"></i> edit</a> <span class="divider">|</span></span>
                            <span data-bind="visible: $root.canModifyOrDeleteComment($data)"><a class="btn btn-sm btn-danger" data-bind="click: $root.remove"><i class="far fa-trash-alt"></i> delete</a> <span class="divider">|</span></span>
                            <span data-bind="visible: !showChildren() && children().length, click: $root.viewChildren" text="view replies"><a class="btn btn-sm btn-dark">
                                <i class="fas fa-comment"></i> show
                            </a><span class="divider">|</span></span>
                            <span data-bind="visible: showChildren() && children().length, click: $root.hideChildren" text="view replies"><a class="btn btn-sm btn-dark">
                                <i class="fas fa-comment-slash"></i> hide
                            </a><span class="divider">|</span></span>
                            <span><a class="btn btn-sm btn-dark" data-bind="click: $root.reply"><i class="fa fa-reply"></i> reply</a></span>
                        </div>
                    </div>

                </div>
                <div data-bind="visible: edit">
                    <div class="comment clearfix comment-post">
                    <div>
                        <textarea class="form-control mb-1" data-bind="value: text" placeholder="Write your comments here."></textarea>
                    </div>
                    <div class="row mb-1">
                        <div class="col-12">
                            <span data-bind="visible: !$data.id()">
                                <a class="btn btn-sm btn-primary-dark" data-bind="click: $root.createChild"><i class="fas fa-plus"></i> post</a>
                            </span>
                            <span data-bind="visible: !!$data.id()">
                                <a class="btn btn-sm btn-primary-dark" data-bind="click: $root.update"><i class="fas fa-hdd"></i> update</a>
                            </span>
                            <span><a class="btn btn-sm btn-dark" data-bind="click: $root.cancel"><i class="far fa-times-circle"></i> cancel</a></span>
                        </div>
                    </div>
                    </div>
                </div>
                <div class="comment-children" data-bind="template:{name:'template-comment',foreach: children}, visible: showChildren">

                </div>
            </div>
        </div>
    </div>
</script>