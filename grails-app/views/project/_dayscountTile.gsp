%{--<g:if test="${hubConfig?.content?.hideProjectFinderStatusIndicatorTile != true}">--}%
%{--<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() > 0">--}%
%{--    <strong>Status: </strong> <span data-bind="text:transients.daysRemaining"></span> <span>days to go</span>--}%
%{--</div>--}%
%{--<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() == 0">--}%
%{--    <strong>Status: </strong> <span>Project Ended</span>--}%
%{--</div>--}%
%{--<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() < 0">--}%
%{--    <strong>Status: </strong> <span>Project Ongoing</span>--}%
%{--</div>--}%
%{--<div class="dayscount" data-bind="visible:transients.daysSince() < 0">--}%
%{--    <strong>Status: </strong> <span>Starts in </span> <span data-bind="text:-transients.daysSince()"></span><span> days</span>--}%
%{--</div>--}%
%{--</g:if>--}%
%{--<span class="dayscount" data-bind="visible:plannedStartDate">--}%
%{--    <small data-bind="text:'Start date: ' + moment(plannedStartDate()).format('DD MMMM, YYYY')"></small>--}%
%{--</span>--}%
%{--<span class="dayscount" data-bind="visible:plannedEndDate">--}%
%{--    <br/><small data-bind="text:'End date: ' + moment(plannedEndDate()).format('DD MMMM, YYYY')"></small>--}%
%{--</span>--}%

<g:if test="${hubConfig?.content?.hideProjectFinderStatusIndicatorTile != true}">
    <div class="detail dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() > 0">
        <span class="label">Status: </span>
        <span class="status"><!--ko text:transients.daysRemaining --><!--/ko--> days to go</span>
    </div>
    <div class="detail dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() == 0">
        <span class="label">Status: </span>
        <span class="status">Project Ended</span>
    </div>
    <div class="detail dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() < 0">
        <span class="label">Status: </span>
        <span class="status">Project Ongoing</span>
    </div>
    <div class="detail dayscount" data-bind="visible:transients.daysSince() < 0">
        <span class="label">Status: </span>
        <span class="status">Starts in <!-- ko text: -transients.daysSince()--> <!-- /ko --> days</span>
    </div>
</g:if>
<div class="detail dayscount" data-bind="visible:plannedStartDate">
    <span class="label">Start date: </span>
    <time aria-label="Project Start Date" data-bind="text: moment(plannedStartDate()).format('DD MMMM, YYYY'), attr:{datetime: moment(plannedStartDate)}"></time>
</div>
<div class="detail dayscount" data-bind="visible:plannedEndDate">
    <span class="label">End date: </span>
    <time aria-label="Project End Date" data-bind="text: moment(plannedEndDate()).format('DD MMMM, YYYY'), attr:{datetime: moment(plannedEndDate)}"></time>
</div>
