<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() > 0">
    <strong>Status: </strong> <span data-bind="text:transients.daysRemaining"></span> <span>days to go</span>
</div>
<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() == 0">
    <strong>Status: </strong> <span>Project Ended</span>
</div>
<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() < 0">
    <strong>Status: </strong> <span>Project Ongoing</span>
</div>
<div class="dayscount" data-bind="visible:transients.daysSince() < 0">
    <strong>Status: </strong> <span>Starts in </span> <span data-bind="text:-transients.daysSince()"></span><span> days</span>
</div>
<span class="dayscount" data-bind="visible:plannedStartDate">
    <small data-bind="text:'Start date: ' + moment(plannedStartDate()).format('DD MMMM, YYYY')"></small>
</span>
<span class="dayscount" data-bind="visible:plannedEndDate">
    <br/><small data-bind="text:'End date: ' + moment(plannedEndDate()).format('DD MMMM, YYYY')"></small>
</span>