//= require_self
//= require compile/biocollect-templates.js
//= require_tree javascript

if (typeof componentService === "undefined") {
    componentService = function () {
        var cache = {};
        function getTemplate(name) {
            return cache[name];
        };

        function setTemplate(name, template) {
            cache[name] = template;
        };

        return {
            getTemplate: getTemplate,
            setTemplate: setTemplate
        };
    }();
}