<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="au.org.ala.biocollect.merit.SettingPageType" %>
<!DOCTYPE html>
<head>
    <title><g:layoutTitle /></title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <link rel="stylesheet" href="${grailsApplication.config.headerAndFooter.baseURL}/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="${grailsApplication.config.headerAndFooter.baseURL}/css/bootstrap-responsive.min.css"/>
    <link rel="stylesheet" href="${grailsApplication.config.headerAndFooter.baseURL}/css/ala-styles.css"/>
    <asset:stylesheet src="base.css"/>
    <asset:stylesheet src="ala2.css"/>
    <asset:javascript src="base.js"/>
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

<asset:script type="text/javascript">
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
</asset:script>
<asset:deferredScripts/>
</body>
</html>