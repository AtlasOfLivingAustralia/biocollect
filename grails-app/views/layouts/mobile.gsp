<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="au.org.ala.biocollect.merit.SettingPageType" %>
<!DOCTYPE html>
<head>
    <title><g:layoutTitle /></title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <r:require modules="ala2Skin, jquery_cookie"/>
    <r:layoutResources/>
    <g:layoutHead />
    <style type="text/css">
        input[type=checkbox] {  -webkit-transform: scale(1.5); }
        .checkbox-list label { min-height: 40px; }
        .speciesAutocompleteRow {min-height:40px;}
        .datepicker td, .datepicker th {
            width:40px;
            height:40px;
            vertical-align: middle;
        }
        body {
            padding-top: 0px;
        }
    </style>
</head>
<body><g:layoutBody />

<r:script>
    $(function() {
        $.ajaxSetup({
            cache: false,
            xhrFields: {
                withCredentials: true
            },
            beforeSend: function(xhr){
                xhr.setRequestHeader('authKey', "${authKey}");
                xhr.setRequestHeader('userName', "${userName}");
            }
        });
    });
</r:script>
<r:layoutResources/>
</body>
</html>