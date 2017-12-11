<div id="project-risks-threats" class="margin-bottom-10 margin-right-20">
    <label><b>Project risks & threats</b></label>
    <div align="right">
        <b> Overall project risk profile : <span data-bind="text: risks.overallRisk, css: overAllRiskHighlight" ></span></b>
    </div>
    <table style="width:100%;">
        <thead >
        <tr>
            <th>Type of threat / risk</th>
            <th>Description</th>
            <th>Likelihood</th>
            <th>Consequence</th>
            <th>Risk rating</th>
            <th>Current control / Contingency strategy</th>
            <th>Residual risk</th>
        </tr>
        </thead>
        <tbody data-bind="foreach : risks.rows" >
        <tr>
            <td>
                <label data-bind="text: threat" ></label>
            </td>
            <td>
                <label data-bind="text: description" ></label>
            </td>
            <td>
                <label data-bind="text: likelihood" ></label>
            </td>
            <td>
                <label data-bind="text: consequence" ></label>
            </td>
            <td>
                <label data-bind="text: riskRating" ></label>
            </td>
            <td>
                <label data-bind="text: currentControl" ></label>
            </td>
            <td>
                <label data-bind="text: residualRisk" ></label>
            </td>
        </tr>
        </tbody>
    </table>
</div>