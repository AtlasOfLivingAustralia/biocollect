
    <div class="row-fluid">
        <span class="span12"><h4>Report: </h4>
            <select id="dashboardType" name="dashboardType">
                <g:each in="${reports}" var="report">
                    <option value="${report.name}">${report.label}</option>
                </g:each>
            </select>
        </span>
    </div>
    <div class="loading-message">
        <r:img dir="images" file="loading.gif" alt="saving icon"/> Loading...
    </div>
    <div id="dashboard-content">

    </div>

