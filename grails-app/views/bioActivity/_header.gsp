<style type="text/css">
.daysline-positive {
    margin: 2px 0;
    height: 4px;
    background: lightgrey;
}
.daysline-positive > div {
    height: 4px;
    background: #337AB7;
}
.daysline-zero {
    margin: 2px 0;
    height: 4px;
    background: #65B045;
}

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

<div class="row-fluid">

    <div class="span12 well">
        <div class="span1 text-center">
            <img class="bioactivity-logo" alt="No image" data-bind="attr:{title:transients.pActivity.name, src: transients.pActivity.transients.logoUrl()}"/>
        </div>
        <div class="span9 text-center">
            <h1 data-bind="text: transients.pActivity.name"></h1>
            <h5 data-bind="text: transients.pActivity.description"></h5>
        </div>

        <div class="span2">

            <div class="dayscount" data-bind="visible: transients.pActivity.transients.daysSince() >= 0 && transients.pActivity.transients.daysRemaining() > 0">
                <h2 data-bind="text: transients.pActivity.transients.daysRemaining"></h2>
                <h4>DAYS TO GO</h4>
            </div>
            <div class="dayscount" data-bind="visible: transients.pActivity.transients.daysSince() >= 0 && transients.pActivity.transients.daysRemaining() == 0">
                <h4>SURVEY</h4>
                <h4>ENDED</h4>
            </div>
            <div class="dayscount" data-bind="visible: transients.pActivity.transients.daysSince() >= 0 && transients.pActivity.transients.daysRemaining() < 0">
                <h4>SURVEY</h4>
                <h4>ONGOING</h4>
            </div>
            <div class="dayscount" data-bind="visible: transients.pActivity.transients.daysSince() < 0">
                <h4>STARTS IN</h4>
                <h2 data-bind="text:-transients.pActivity.transients.daysSince()"></h2>
                <h4>DAYS</h4>
            </div>

        </div>

    </div>

</div>

<div class="row-fluid">
    <div class="span12">

        <div class="span12">
            <div class="daysline-positive" data-bind="visible:transients.pActivity.transients.daysSince() >= 0 && transients.pActivity.transients.daysRemaining() > 0">
                <div data-bind="style:{width: Math.floor(transients.pActivity.transients.daysRemaining()/transients.pActivity.transients.daysTotal() * 100) + '%'}"></div>
            </div>
            <div class="daysline-positive" data-bind="visible:transients.pActivity.transients.daysSince() >= 0 && transients.pActivity.transients.daysRemaining() < 0">
                <div style="width:0%"></div>
            </div>

            <div class="daysline-zero" data-bind="visible: transients.pActivity.transients.daysSince() >= 0 && transients.pActivity.transients.daysRemaining() == 0"></div>
        </div>
    </div>
</div>