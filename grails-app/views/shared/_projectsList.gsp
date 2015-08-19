<table style="width:100%;">

    <thead>
        <tr>
            <td>Name</td>

        </tr>
    </thead>
    <tbody data-bind="foreach:projects">
        <tr>
            <td> <a data-bind="attr:{href:fcConfig.viewProjectUrl+'/'+projectId}"><span data-bind="text:name"></span></a></td>
        </tr>
    </tbody>
</table>
