/**
 * This code is dependent on knockout js v3.3, jquery and other libraries.
 * Created by Temi Varghese on 6/10/15.
 *
 */
/**
 Bootstrap Alerts -
 Function Name - showAlertOnTarget() = modified version of showAlert
 Inputs - message,alerttype,DOM
 Example - showalert("Invalid Login","alert-error", DOM)
 Types of alerts -- "alert-error","alert-success","alert-info"
 Required - You only need to add a alert_placeholder div in your html page wherever you want to display these alerts "<div id="alert_placeholder"></div>"
 Written On - 14-Jun-2013
 **/
function showAlertOnTarget(message, alerttype, target) {

    if(typeof target === 'string'){
        $('#'+target).append('<div id="alertdiv" class="alert ' +  alerttype + '"><a class="close" data-dismiss="alert">×</a><span>'+message+'</span></div>')
    } else if(typeof target === 'object') {
        $(target).append('<div id="alertdiv" class="alert ' +  alerttype + '"><a class="close" data-dismiss="alert">×</a><span>'+message+'</span></div>')
    }

    setTimeout(function() { // this will automatically close the alert and remove this if the users doesnt close it in 5 secs
        $("#alertdiv").remove();
    }, 5000);
}


function CommentViewModel(config) {
    var self = this;
    // domain object fields
    self.id = ko.observable(config.id || null)
    self.userId = ko.observable(config.userId || '')
    self.displayName = ko.observable(config.displayName || '')
    self.text = ko.observable(config.text || '')
    self.parent = ko.observable(config.parent || null)
    self.lastUpdated = ko.observable(config.lastUpdated || null).extend({simpleDate: true})
    //stores replies to a comment
    self.children = ko.observableArray(config.children || [])
    // controls editing of a comment by an owner
    self.edit = ko.observable(config.edit || false)
    // easy reference to parent node
    self.parentNode = config.parentNode;
    // prevent display of long reply threads
    self.showChildren = ko.observable(false);
    // load function called after create/update operation. It synchronizes certain fields.
    self.load = function(config){
        self.id(config.id)
        self.userId(config.userId)
        self.displayName(config.displayName)
        self.text(config.text)
        self.parent(config.parent)
        self.lastUpdated(config.lastUpdated)
    }

    // talk with server to create a comment, callback sent from listmodelview
    self.create = function (successCallback, errorCallback) {
        var url = fcConfig.createCommentUrl;
        $.ajax({
            url: url,
            type: 'POST',
            data: JSON.parse(self.commentJSON(self)),
            success: function (result) {
                self.load(result);
                successCallback && successCallback();
            },
            error: function () {
                console.log('failed creating comment');
                errorCallback && errorCallback()
            }
        })
    }

    // talk with server to update a comment, callback sent from listmodelview
    self.update = function(successCallback, errorCallback){
        var url = fcConfig.updateCommentUrl + '/' + self.id();
        $.ajax({
            url: url,
            type: 'POST',
            data: JSON.parse(self.commentJSON(self)),
            success: function (result) {
                self.load(result);
                self.edit(false);
                successCallback && successCallback();
            },
            error: function () {
                console.log('failed updating comment');
                errorCallback && errorCallback()
            }
        })
    }

    // talk with server to delete a comment, callback sent from listmodelview
    self.remove = function(successCallback, errorCallback){
        var url = fcConfig.deleteCommentUrl + '/' + self.id();
        $.ajax({
            url: url,
            type: 'DELETE',
            success: function (result) {
                successCallback && successCallback();
            },
            error: function () {
                console.log('failed deleting comment');
                errorCallback && errorCallback()
            }
        })
    }

    // model specific JSON converter since there are a lot of variable that need not sync with database
    self.commentJSON = function(){
        var json = ko.toJSON(self, function(k, value){
            if(k){
                if(typeof value  === 'function' || k === 'parentNode'){
                    return;
                }
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
    // a new comment posted is stored here before adding to comment list
    self.newComment = ko.observable(new CommentViewModel({}));
    //list of comments shown
    self.comments = ko.observableArray();
    // sort order options
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
    // current user id
    self.userId = ko.observable();
    // total comments in list
    self.total = ko.observable(0)
    // flag giving admin privileges like delete / edit comments
    self.admin = false;
    // current sorting mechanism
    self.selectedSort = ko.observable(self.sortOptions()[0])
    // controls load more button visibility
    self.showLoadMore = ko.observable(true);

    self.sort = {
        field: ko.observable('lastUpdated'),
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
            self.total(self.total() + 1)
        }, function(){
            showAlertOnTarget('Could not create your comment. Are you logged in?','alert-error','postComment');
        });
    }

    // creates child comment. different from creating a comment.
    self.createChild = function (comment, event) {
        comment.create(function(){
            comment.edit(false);
        }, function(){
            showAlertOnTarget('Could not create your comment. Are you logged in?','alert-error',$(event.target).parents('div')[0]);
        });
    }

    // params for passing to list comments webservice
    self.getParams = function(){
        var params = {}, selection = self.selectedSort();
        switch (selection.sort) {
            case 'oldestfirst':
                params.sort = 'lastUpdated'
                params.order = 'asc'
                break;
            case 'latestfirst':
                params.sort = 'lastUpdated'
                params.order = 'desc'
                break;
        }
        // chances that start can go below 0 when there is a delete
        params.start = self.page.start < 0 ? 0: self.page.start;
        params.pageSize = self.page.pageSize
        return params;
    }

    //called when sort order is changed
    self.removeComments = function(){
        self.firstPage();
        self.comments.removeAll()
    }

    // webservice call to list comments
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
                self.load(result);
            },
            error: function(){
                showAlertOnTarget('Could not load comments','alert-error','commentDisplay');
            }
        })
    }

    // initialise/load comments and other metadata
    self.load = function(data){
        self.userId(data.userId);
        self.total(data.total)
        self.admin = data.admin;
        self.addItems(data.items);
        if(self.total() > (self.page.start + self.page.pageSize)){
            self.showLoadMore(true)
        } else {
            self.showLoadMore(false)
        }
    }

    //called to load the next set of comments
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
                self.load(result);
            },
            error: function(){
                showAlertOnTarget('Could not load more comments. An error occurred.','alert-error','commentDisplay');
            }
        })
    }

    self.edit = function(comment, e){
        comment && comment.edit(true);
        self.focusTextArea(e.target)
    }

    // to make sure cursor is on text area box
    self.focusTextArea = function(target){
        $(target).parents('.media-body').find('textarea').focus()
    }

    self.update = function(comment){
        comment && comment.update(null,function(){
            showAlertOnTarget('Could not save your edit. An error occurred.','alert-error',$(event.target).parents('div')[0]);
        });
    }

    self.remove = function(comment, event){
        comment && comment.remove(function(){
            if(comment.parentNode){
                comment.parentNode.children.remove(comment);
            } else {
                self.comments.remove(comment);
                self.total(self.total() - 1)
            }
            // if a comment is deleted and parent is null, start is adjusted so that when load more is run no comments are missed
            (comment.parent() == null) && (self.page.start -= 1)
        }, function(){
            showAlertOnTarget('Could not delete comment. An error occurred.','alert-error',$(event.target).parents('div')[0]);
        })
    }

    // adds each comment from list
    self.addItems = function (items) {
        items && $.map(items, function (item) {
            var comment = new CommentViewModel(item)
            comment.children(self.createChildrenComment(comment))
            self.comments.push(comment);
        })
    }

    // recursive function to create children comments
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
                comment.parentNode.children.remove(comment)
            }
        }
    }

    self.reply = function(comment, e){
        comment.children.unshift(new CommentViewModel({
            parent : comment.id(),
            edit: true,
            parentNode: comment
        }))
        //otherwise, reply textarea will be hidden.
        comment.showChildren(true);
        self.focusTextArea(e.target)
    }

    // delete a comment that user owns
    self.removeChild = function(comment, parent){
        parent.children.remove(comment);
    }

    // controls edit/delete button on a comment
    self.canModifyOrDeleteComment = function(comment){
        return self.admin || (self.userId() == comment.userId())
    }

    // show children comment threads
    self.viewChildren = function(comment){
        comment.showChildren(true);
    }

    // hide children comment threads
    self.hideChildren = function(comment){
        comment.showChildren(false);
    }

    self.list();
}