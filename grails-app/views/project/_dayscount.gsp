<style type="text/css">
.dayscount {
    text-align: center;
}
.dayscount > h2 {
    font-size: 300%;
}
.dayscount > h4 {
    color: grey;
}
.dayscount > img {
    width: 70px;
}
</style>
<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() > 0">
    <h2 data-bind="text:transients.daysRemaining"></h2>
    <h4>DAYS TO GO</h4>
</div>
<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() == 0">
    <h4>PROJECT</h4>
    <h4>ENDED</h4>
</div>
<div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() < 0">
    <r:img file="infinity.png" />
    <h4>PROJECT</h4>
    <h4>ONGOING</h4>
</div>
<div class="dayscount" data-bind="visible:transients.daysSince() < 0">
    <h4>STARTS IN</h4>
    <h2 data-bind="text:-transients.daysSince()"></h2>
    <h4>DAYS</h4>
</div>
