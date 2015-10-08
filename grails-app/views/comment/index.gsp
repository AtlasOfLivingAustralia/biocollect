<%--
 Created by Temi Varghese on 6/10/15.
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Comment here</title>
    <meta name="layout" content="ala2"/>
    <r:require modules="comments"></r:require>
    <script>
        var fcConfig = {
            createCommentUrl : '/biocollect/activity/1/comment',
            commentListUrl: '/biocollect/activity/1/comment',
            updateCommentUrl: '/biocollect/activity/1/comment'
        }
    </script>
</head>

<body>
    <g:render template="comment"></g:render>
<script>

    $(window).load(function(){
        ko.applyBindings(new CommentListViewModel(),document.getElementById('commentOutput'))
    })
</script>
</body>
</html>