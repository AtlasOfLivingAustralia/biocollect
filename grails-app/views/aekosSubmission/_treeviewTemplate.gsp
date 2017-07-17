<%--
  Created by IntelliJ IDEA.
  User: koh032
  Date: 19/05/2016
  Time: 4:22 PM
--%>

<style>
/*:not(ul.childNode)*/
div.treeview-nav-bar > ul {
    list-style-type: none;
    margin: 4px;
    position: relative;
}

div.treeview-nav-bar {
    border: 1px solid lightgrey;
}

/*ul.childNode li {*/
div.treeview-nav-bar ul.childNode li {
    padding-left: 0px;
    list-style-type: none;
   // border-left: 1px dotted #000;
   // border-bottom: 1px dotted #000;;
    margin: 0;
    position: relative;
}

/*ul.childNode li div::before {*/
div.treeview-nav-bar ul.childNode li div::before {
    content: '';
    position: absolute;
    top: 0;
    left: -2px;
    bottom: 60%;
    width: 0.65em;
   // border: 1px dotted #000;
   // border-left: 0 none transparent;
    border-top: 0 none transparent;
    border-right: 0 none transparent;
}

/*ul.childNode > li:last-child {*/
div.treeview-nav-bar ul > li:last-child {
    border-left: 2px solid transparent;
}

div.treeviewItem label {
    display: inline-block;
    margin-bottom: 0px;
/*    -webkit-font-smoothing: antialiased;*/
    /*font-size: 75%;*/
}

.pointer-icon {
    cursor: pointer;
}
</style>


<script type="text/html" id="tree-template">

<div class="treeview-nav-bar">
    <ul data-bind="foreach: data.tree.nodes">
        <li>
            <div data-bind="template: { name: 'node-name-template', data: $data }, css: { 'pointer-icon': nodes().length > 0 }"></div>

            <div data-bind="template: { name: 'folder-template', data: $data }, visible: isExpanded"></div>
        </li>
    </ul>

</div>
<br>
<div>
    %{--<label class="control-label" data-bind="text: data.extraFieldLabel"></label>--}%
    <label class="control-label" data-bind="text: $root.extraFieldLabel"></label>
    <input class="extrafield" data-bind="value: data.extraField" />
    <button class="btn-info btn btn-small block" data-bind="click: data.addTreeNode(data.tree.nodes)">Add</button>
%{--    <button class="btn btn-small" data-bind="click: data.addExtraField(data.tree.nodes)">Add</button>

    <br>
    <!-- ko foreach: data.extraAddedField() -->
    <br>
    <span id="ExtraField" data-bind="text: $data"></span>
    <!-- /ko -->--}%
</div>

    <br><br>

</script>

<script type="text/html" id="folder-template">

<ul class="childNode" data-bind="foreach: nodes">
    <li>
        <div data-bind="template: { name: 'node-template', data: $data }"></div>
    </li>
</ul>

</script>

<script type="text/html" id="node-template">

<div data-bind="template: { name: 'node-name-template', data: $data }, css: { 'pointer-icon': nodes().length > 0 }"></div>

<!-- ko if: nodes().length !== 0 -->
    <div data-bind="template: { name: 'folder-template', data: $data }, visible: isExpanded"></div>
<!-- /ko -->

</script>

<script type="text/html" id="node-name-template">
<div class="treeviewItem">

    <span class="tree-item" data-bind="
    css: {
        'icon-minus': isExpanded() && nodes().length > 0,
        'icon-plus': !isExpanded() && nodes().length > 0
    }, click: toggleVisibility"></span>

    <span class="tree-item" data-bind="visible: nodes().length == 0, text: '&nbsp;&nbsp;&nbsp;&nbsp;'"></span>

 %{--   <input class="tree-item" type="checkbox" data-bind="attr:{'id': name, 'name': name}, checkedValue: name, checked: $root.selected" />
 attr:{'id': name, 'name': name},
 --}%
    <input class="tree-item" type="checkbox" data-bind="attr:{'name': $root.data.treeName}, checkedValue: name, checked: $root.data.selectedValues" />

    <label data-bind="text: name, attr: { 'for': name, 'title': description }, tooltip: { delay: { show: 500, hide: 10 } }"></label>
</div>
</script>