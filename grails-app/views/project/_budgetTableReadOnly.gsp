<div id="keq" class="margin-bottom-10 margin-right-20">
    <label><b>Project Budget</b></label>
    <table style="width: 100%;">
        <thead>
        <tr>
            <th width="2%"></th>
            <th width="12%">Investment/Priority Area</th>
            <th width="12%">Description</th>
            <!-- ko foreach: details.budget.headers -->
            <th style="text-align: center;" width="10%" ><div style="text-align: center;" data-bind="text:data"></div>$</th>
            <!-- /ko -->
            <th  style="text-align: center;" width="10%">Total</th>

        </tr>
        </thead>
        <tbody data-bind="foreach : details.budget.rows">
        <tr>
            <td><span data-bind="text:$index()+1"></span></td>
            <td><span style="width: 97%;" data-bind="text:shortLabel"> </span></td>
            <td><div style="text-align: left;"><span style="width: 90%;" data-bind="text: description"></span></div></td>

            <!-- ko foreach: costs -->
            <td><div style="text-align: center;"><span style="width: 90%;" data-bind="text: dollar.formattedCurrency"></span></div></td>
            <!-- /ko -->

            <td style="text-align: center;" ><span style="width: 90%;" data-bind="text: rowTotal.formattedCurrency"></span></td>

        </tr>
        </tbody>
        <tfoot>
        <tr>
            <td></td>
            <td></td>
            <td style="text-align: right;" ><b>Total </b></td>
            <!-- ko foreach: details.budget.columnTotal -->
            <td style="text-align: center;" width="10%"><span data-bind="text:data.formattedCurrency"></span></td>
            <!-- /ko -->
            <td style="text-align: center;"><b><span data-bind="text:details.budget.overallTotal.formattedCurrency"></span></b></td>
        </tr>
        </tfoot>
    </table>
</div>