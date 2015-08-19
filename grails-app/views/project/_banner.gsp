<style type="text/css">
    .logo {
        height:110px;
        margin-left:10px;
        margin-bottom:10px;
        float:left;
    }
    .header-days {
        float:right;
        margin-right:10px;
    }
    .header-dates {
        color: grey;
    }
    .header-text {
        float:left;
        margin-left:10px;
    }
    .header-text h2,.header-text h4 {
        margin-top: 0;
        margin-bottom: 0;
    }
    .header-text .organisation {
        font-weight: 300;
        margin-left: 5px;
    }

</style>
<div class="project-header project-banner" data-bind="style:{'backgroundImage':asBackgroundImage(bannerUrl())}">
    <div class="row-fluid" style="margin-left:10px;">
        <ul class="breadcrumb">
            <li>
                <g:link controller="home">Home</g:link> <span class="divider">/</span>
            </li>
            <li class="active">Projects <span class="divider">/</span></li>
            <li class="active" data-bind="text:name"/>
        </ul>
    </div>
    <div class="row-fluid ">
        <span data-bind="visible:logoUrl"><img class="logo" data-bind="attr:{'src':logoUrl}"></span>
        <div class="header-text">
            <h2 data-bind="text:name"></h2>
            <h4 class="organisation" data-bind="visible:!organisationId(),text:organisationName"></h4>
            <a data-bind="visible:organisationId(),attr:{href:fcConfig.organisationLinkBaseUrl + '/' + organisationId()}">
              <h4 class="organisation" data-bind="text:organisationName"></h4>
            </a>
        </div>
        <div class="header-days">
            <g:render template="dayscount"/>
            <span class="header-dates" data-bind="visible:plannedStartDate,text:'Start date: ' + moment(plannedStartDate()).format('DD MMMM, YYYY')"></span>
            <br/>
            <span class="header-dates" data-bind="visible:plannedEndDate,text:'End date: ' + moment(plannedEndDate()).format('DD MMMM, YYYY')"></span>
        </div>
    </div>
    <g:render template="daysline"/>
</div>