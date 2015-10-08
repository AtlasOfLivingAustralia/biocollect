<style>
.boxsizingBorder {
    -webkit-box-sizing: border-box;
    -moz-box-sizing: border-box;
    box-sizing: border-box;
}

textarea {
    width: 100%;
    position: relative;
}

.textwrapper {
    /*border:1px solid #999999;*/
    margin: 5px 0;
    padding: 3px;
}
</style>

<div id="commentOutput">
    <div id="postComment" class="comment well">
        <div class="comment-header">
            <h4>Write your comments here</h4>
            <hr>
        </div>

        <div class="comment-body textwrapper">
            <textarea data-bind="value: newComment().text"></textarea>
        </div>

        <div class="comment-footer">
            <div class="btn btn-primary pull-right" data-bind="click: create">submit</div>
        </div>
    </div>

    <div id="commentDisplay">
        <div id="commentTools">
            <span>
                <label>Order comments by <select
                        data-bind="options: sortOptions, optionsText: 'text', value: selectedSort, event:{change: list}"></select>
                </label>
            </span>
        </div>

        <div data-bind="template:{name:'template-comment',foreach: comments}">
        </div>

        <div data-bind="click: more">load more</div>
    </div>
</div>
<script type="text/html" id="template-comment">
    <div class="comment-body">
        <div class="media" >
            <div class="pull-left" href="#" style="width: 64px; height: 64px"></div>
            <div class="media-body" >
                <h4 class="media-heading">User 1</h4>
                <div data-bind="visible: !edit()">
                    <div class="media" data-bind="html: text">
                    </div>
                    <ul class="breadcrumb">
                        <li><a class="btn-link" data-bind="click: $root.edit">edit</a> <span class="divider">~</span></li>
                        <li><a class="btn-link" data-bind="click: $root.delete">delete</a> <span class="divider">~</span></li>
                        <li><a class="btn-link" data-bind="click: $root.reply">reply</a></li>
                    </ul>

                </div>
                <div data-bind="visible: edit">
                    <textarea data-bind="value: text"></textarea>

                    <ul class="breadcrumb">
                        <li data-bind="visible: !$data.id()">
                            <a class="btn-link" data-bind="click: $root.createChild">post</a> <span class="divider">~</span>
                        </li>
                        <li data-bind="visible: !!$data.id()">
                            <a class="btn-link" data-bind="click: $root.update">update</a> <span class="divider">~</span>
                        </li>
                        <li><a class="btn-link" data-bind="click: $root.cancel">cancel</a></li>
                    </ul>
                </div>
                <div class="comment-children" data-bind="template:{name:'template-comment',foreach: children}">

                </div>
            </div>
        </div>
    </div>

</script>