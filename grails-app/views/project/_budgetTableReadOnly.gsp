<div class="budget-table-read-only margin-bottom-10 margin-right-20">
    <label><b>Project Budget</b></label>
    <table class="budget">
        <thead>
        <tr>
            <th class="index"></th>
            <th class="category">Investment/Priority Area</th>
            <th class="payment-number">Payment number</th>
            <th class="funding-source">Funding source</th>
            <th class="payment-status">Status <fc:iconHelp title="Payment Status">(P) Processing, (C) Complete</fc:iconHelp></th>
            <th class="description">Description</th>
            <th class="due-date">Date due</th>
            <!-- ko foreach: details.budget.headers -->
            <th style="text-align: center;" width="10%" ><div style="text-align: center;" data-bind="text:data"></div>$</th>
            <!-- /ko -->
            <th  style="text-align: center;" width="10%">Total</th>

        </tr>
        </thead>
        <tbody data-bind="foreach : details.budget.rows">
        <tr>
            <td class="index"><span data-bind="text:$index()+1"></span></td>
            <td class="category"><span data-bind="text:shortLabel"> </span></td>
            <td class="payment-number"><span data-bind="text:paymentNumber"></span></td>
            <td class="funding-source"><span data-bind="text:fundingSource"></span></td>
            <td class="payment-status"><span data-bind="text:paymentStatus"></span></td>

            <td class="description"><div style="text-align: left;"><span data-bind="text: description"></span></div></td>
            <td class="due-date"><span data-bind="text:dueDate.formattedDate()"></span></td>

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
            <td></td>
            <td></td>
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