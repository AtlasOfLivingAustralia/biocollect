<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() > 0">
    <h2 data-bind="text:transients.daysRemaining"></h2>
    <h4>days to go</h4>
</div>
<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() == 0">
    <h4>Project</h4>
    <h4>Ended</h4>
</div>
<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() < 0">
    <h4>Project</h4>
    <h4>Ongoing</h4>
</div>
<div class="dayscount" data-bind="visible:transients.daysSince() < 0">
    <h4>Starts in</h4>
    <h2 data-bind="text:-transients.daysSince()"></h2>
    <h4>days</h4>
</div>
