<div id="commentOutput" class="clearfix ${mobile?'hide':''}">
    <h3>Comments (<b data-bind="text: total"></b>)</h3>
    <div id="postComment" class="comment clearfix comment-post">
        <div class="comment-header">
        </div>

        <div class="comment-body">
            <label for="commentMainTextarea">Write your comment below</label>
            <textarea id="commentMainTextarea" class="boxsizingBorder" data-bind="value: newComment().text"></textarea>
        </div>

        <div class="comment-footer pull-right">
            <div class="btn btn-primary btn-small" data-bind="click: create">post</div>
        </div>
    </div>
    <hr>
    <div id="commentDisplay">
        <div id="commentTools">
            <span>
                <select
                        data-bind="options: sortOptions, optionsText: 'text', value: selectedSort, event:{change: list}"></select>
            </span>
        </div>

        <div class="comment-list" data-bind="template:{name:'template-comment',foreach: comments}">
        </div>
    </div>
    <div data-bind="visible: showLoadMore" class="row-fluid">
        <div class="span12">
            <button class="btn span12" data-bind="click: more">load more comments</button>
        </div>
    </div>
</div>
<script type="text/html" id="template-comment">
    <div class="comment-body">
        <div class="media" >
            <div class="pull-left comment-indent" data-bind="css: { hide: !$data.parent()}"></div>
            <div class="media-body" >
                <b class="comment-username media-heading" data-bind="text: displayName, visible: !!displayName"></b>
                <span data-bind="visible: !!lastUpdated()">commented on <span data-bind="text: lastUpdated.formattedDate"></span></span>
                <div data-bind="visible: !edit()">
                    <pre class="media" data-bind="text: text">
                    </pre>
                    <ul class="breadcrumb margin-bottom-five">
                        <li data-bind="visible: $root.canModifyOrDeleteComment($data)"><a class="btn-link" data-bind="click: $root.edit">edit</a> <span class="divider">|</span></li>
                        <li data-bind="visible: $root.canModifyOrDeleteComment($data)"><a class="btn-link" data-bind="click: $root.remove">delete</a> <span class="divider">|</span></li>
                        <li data-bind="visible: !showChildren() && children().length, click: $root.viewChildren" text="view replies"><a class="btn-link">
                            <i class="icon-comment"></i> show
                        </a><span class="divider">|</span></li>
                        <li data-bind="visible: showChildren() && children().length, click: $root.hideChildren" text="view replies"><a class="btn-link">
                            <i class="icon-comment"></i> hide
                        </a><span class="divider">|</span></li>
                        <li><a class="btn-link" data-bind="click: $root.reply">reply</a></li>
                    </ul>

                </div>
                <div data-bind="visible: edit">
                    <div class="comment clearfix comment-post">
                    <div>
                        <textarea class="boxsizingBorder" data-bind="value: text" placeholder="Write your comments here."></textarea>
                    </div>
                    <ul class="breadcrumb margin-bottom-five">
                        <li data-bind="visible: !$data.id()">
                            <a class="btn btn-small btn-primary" data-bind="click: $root.createChild">post</a>
                        </li>
                        <li data-bind="visible: !!$data.id()">
                            <a class="btn btn-small btn-primary" data-bind="click: $root.update">update</a>
                        </li>
                        <li><a class="btn btn-small" data-bind="click: $root.cancel">cancel</a></li>
                    </ul>
                    </div>
                </div>
                <div class="comment-children" data-bind="template:{name:'template-comment',foreach: children}, visible: showChildren">

                </div>
            </div>
        </div>
    </div>
</script>