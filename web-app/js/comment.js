/**
 * Created by Temi Varghese on 6/10/15.
 */
function CommentViewModel(config) {
    var self = this;
    self.id = ko.observable(config.id || null)
    self.text = ko.observable(config.text || '')
    self.parent = ko.observable(config.parent || null)
    self.dateCreated = ko.observable(config.dateCreated || null)
    self.children = ko.observableArray(config.children || [])
    self.edit = ko.observable(config.edit || false)
    self.parentNode = config.parentNode;

    self.create = function (successCallback) {
        var url = fcConfig.createCommentUrl;
        $.ajax({
            url: url,
            type: 'POST',
            data: JSON.parse(self.commentJSON(self)),
            success: function (result) {
                self.id(result['id']);
                successCallback && successCallback();
            },
            error: function () {
                console.log('failed creating comment');
            }
        })
    }

    self.update = function(successCallback){
        var url = fcConfig.updateCommentUrl + '/' + self.id();
        $.ajax({
            url: url,
            type: 'POST',
            data: JSON.parse(self.commentJSON(self)),
            success: function (result) {
                self.edit(false);
                successCallback && successCallback();
            },
            error: function () {
                console.log('failed updating comment');
            }
        })
    }

    self.delete = function(successCallback){
        var url = fcConfig.updateCommentUrl + '/' + self.id();
        $.ajax({
            url: url,
            type: 'DELETE',
            success: function (result) {
                successCallback && successCallback();
            },
            error: function () {
                console.log('failed deleting comment');
            }
        })
    }

    self.commentJSON = function(){
        var json = ko.toJSON(self, function(k, value){
            if(k){
                //for(var k in value){
                    if(typeof value  === 'function' || k === 'parentNode'){
                        return;
                    }
                //}
                return value;
            } else if(value){
                return value
            }
        });
        return json
    }
}

function CommentListViewModel() {
    var self = this,
        SortOption = function (config) {
            this.text = config.text
            this.sort = config.value
        };
    self.newComment = ko.observable(new CommentViewModel({}));
    self.comments = ko.observableArray();
    self.sortOptions = ko.observableArray([
        new SortOption({
            text: 'Latest first',
            value: 'latestfirst'
        }),
        new SortOption({
            text: 'Oldest first',
            value: 'oldestfirst'
        })
    ])

    self.selectedSort = ko.observable(self.sortOptions()[0])

    self.sort = {
        field: ko.observable('dateCreated'),
        order: ko.observable('desc')
    }

    self.page = {
        pageSize : 10,
        start: 0
    }

    self.firstPage = function(){
        self.page.pageSize = 10;
        self.page.start = 0;
    }

    self.nextPage = function(){
        self.page.start += self.page.pageSize;
    }

    self.create = function () {
        self.newComment().create(function () {
            self.comments.unshift(self.newComment())
            self.newComment(new CommentViewModel({}));
        });
    }

    self.createChild = function (comment) {
        comment.create(function(){
            comment.edit(false);
        });
    }

    self.getParams = function(){
        var params = {}, selection = self.selectedSort();
        switch (selection.sort) {
            case 'oldestfirst':
                params.sort = 'dateCreated'
                params.order = 'asc'
                break;
            case 'latestfirst':
                params.sort = 'dateCreated'
                params.order = 'desc'
                break;
        }
        // chances that start can go below 0 when there is a delete
        params.start = self.page.start < 0 ? 0: self.page.start;
        params.pageSize = self.page.pageSize
        return params;
    }

    self.removeComments = function(){
        self.firstPage();
        self.comments.removeAll()
    }

    self.list = function () {
        var url = fcConfig.commentListUrl,
            params;

        self.removeComments()

        params = self.getParams()

        $.ajax({
            url: url,
            type: 'GET',
            data: params,
            success: function (result) {
                self.addItems(result.items);
            }
        })
    }

    self.more = function () {
        var url = fcConfig.commentListUrl,
            params;

        self.nextPage()

        params = self.getParams()

        $.ajax({
            url: url,
            type: 'GET',
            data: params,
            success: function (result) {
                self.addItems(result.items);
            }
        })
    }

    self.edit = function(comment){
        comment && comment.edit(true);
    }

    self.update = function(comment){
        comment && comment.update();
    }

    self.delete = function(comment){
        comment && comment.delete(function(){
            if(comment.parentNode){
                comment.parentNode.children.remove(comment);
            } else {
                self.comments.remove(comment);
            }
            // if a comment is deleted and parent is null, start is adjusted so that when load more is run no comments are missed
            (comment.parent() == null) && (self.page.start -= 1)
        })
    }

    self.addItems = function (items) {
        $.map(items, function (item) {
            var comment = new CommentViewModel(item)
            comment.children(self.createChildrenComment(comment))
            self.comments.push(comment);
        })
    }

    self.createChildrenComment = function(item){
        var children = [];
        $.map(item.children(), function(child){
            var childComment = new CommentViewModel(child)
            if(childComment.children().length){
                childComment.children(self.createChildrenComment(childComment))
            }
            childComment.parentNode = item;
            children.push(childComment)
        })
        return children;
    }

    self.cancel = function(comment){
        if(comment){
            if(comment.id()){
                comment.edit(false);
            }  else {
                comment.destroy()
            }
        }
    }

    self.reply = function(comment){
        comment.children.push(new CommentViewModel({
            parent : comment.id(),
            edit: true,
            parentNode: comment
        }))
    }

    self.removeChild = function(comment, parent){
        parent.children.remove(comment);
    }

    self.list();
}