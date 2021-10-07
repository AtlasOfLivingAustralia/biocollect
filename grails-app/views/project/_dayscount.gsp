<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() > 0">
    <h2 class="mb-1" data-bind="text:transients.daysRemaining"></h2>
    <h4 class="mb-1">DAYS TO GO</h4>
</div>
<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() == 0">
    <h4 class="mb-1">PROJECT</h4>
    <h4 class="mb-1">ENDED</h4>
</div>
<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() < 0">
    <h4 class="mb-1">PROJECT</h4>
    <h4 class="mb-1">ONGOING</h4>
</div>
<div class="dayscount" data-bind="visible:transients.daysSince() < 0">
    <h4 class="mb-1">STARTS IN</h4>
    <h2 class="mb-1" data-bind="text:-transients.daysSince()"></h2>
    <h4 class="mb-1">DAYS</h4>
</div>
