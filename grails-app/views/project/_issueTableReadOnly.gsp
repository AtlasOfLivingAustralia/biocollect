<div class="project-issues margin-bottom-10 margin-right-20">
    <label><b>Project issues</b></label>
    <table class="table-striped" style="width:100%;">
        <thead >
        <tr>
        <tr>
            <th class="type">Type of issue </th>
            <th class="date">Date</th>
            <th class="status">Status </th>
            <th class="priority">Priority </th>
            <th class="description">Description</th>
            <th class="actionPlan">Action plan </th>
            <th class="impact">Impact</th>
        </tr>
        </tr>
        </thead>
        <tbody data-bind="foreach : issues" >
        <tr>
            <td class="type">
                <label data-bind="text: type" ></label>
            </td>
            <td class="date">
                <label data-bind="text: date.formattedDate"></label>
            </td>
            <td class="status">
                <label data-bind="text: status" ></label>
            </td>
            <td class="priority">
                <label data-bind="text: priority" ></label>
            </td>
            <td  class="description">
                <label data-bind="text: description" ></label>
            </td>
            <td class="actionPlan">
                <label data-bind="text: actionPlan" ></label>
            </td>
            <td class="impact">
                <label data-bind="text: impact" ></label>
            </td>
        </tr>
        </tbody>
    </table>
</div>