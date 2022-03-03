<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() > 0">
    <h2 class="mb-1 ${classes?:""}" data-bind="text:transients.daysRemaining"></h2>
    <h4 class="mb-1 ${classes?:""}">DAYS TO GO</h4>
</div>
<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() == 0">
    <h4 class="mb-1 ${classes?:""}">PROJECT</h4>
    <h4 class="mb-1 ${classes?:""}">ENDED</h4>
</div>
<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() < 0">
    <h4 class="mb-1 ${classes?:""}">PROJECT</h4>
    <h4 class="mb-1 ${classes?:""}">ONGOING</h4>
</div>
<div class="dayscount" data-bind="visible:transients.daysSince() < 0">
    <h4 class="mb-1 ${classes?:""}">STARTS IN</h4>
    <h2 class="mb-1 ${classes?:""}" data-bind="text:-transients.daysSince()"></h2>
    <h4 class="mb-1 ${classes?:""}">DAYS</h4>
</div>
