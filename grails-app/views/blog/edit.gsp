<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="bs4"/>
    <title>Edit | Blog Entry | <g:message code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/'+ hubConfig.urlPath)},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'project', action: 'index')}/${blogEntry.projectId},Project"/>
    <meta name="breadcrumb" content="Edit blog entry"/>
    <asset:stylesheet src="blog-manifest.css"/>
%{--    <script type="text/javascript" src="${grailsApplication.config.google.maps.url}" async defer></script>--}%
    <asset:script type="text/javascript">
        var fcConfig = {
            <g:applyCodec encodeAs="none">
            intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
            featuresService: "${createLink(controller: 'proxy', action: 'features')}",
            featureService: "${createLink(controller: 'proxy', action: 'feature')}",
            spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
            layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            blogUpdateUrl: "${grailsApplication.config.grails.serverURL}/blog/update?id=${blogEntry.blogEntryId}",
            blogViewUrl: "${grailsApplication.config.grails.serverURL}/blog/index",
            documentUpdateUrl: "${grailsApplication.config.grails.serverURL}/document/documentUpdate",
            </g:applyCodec>
            returnTo: "${params.returnTo}"
            };
    </asset:script>
    <asset:javascript src="blog-manifest.js"/>
</head>
<body>
<div class="container">
    <g:render template="editBlogEntry"/>

    <div class="row">
        <div class="col-12 btn-space">
            <button type="button" id="save" data-bind="click:save" class="btn btn-primary-dark"><i class="fas fa-hdd"></i> Save</button>
            <button type="button" id="cancel" data-bind="click:cancel" class="btn btn-dark"><i class="far fa-times-circle"></i> Cancel</button>
        </div>
    </div>
</div>

<asset:script type="text/javascript">

var EditableBlogEntryViewModel = function(blogEntry, options) {

    var defaults = {
        validationElementSelector:'.validationEngineContainer',
        types:['News and Events', 'Project Stories'],
        returnTo:fcConfig.returnTo,
        blogUpdateUrl:fcConfig.blogUpdateUrl
    };

    var config = $.extend(defaults, options);
    var self = this;
    var now = convertToSimpleDate(new Date());
    self.blogEntryId = ko.observable(blogEntry.blogEntryId);
    self.projectId = ko.observable(blogEntry.projectId || undefined);
    self.title = ko.observable(blogEntry.title || '');
    self.date = ko.observable(blogEntry.date || now).extend({simpleDate:false});
    self.content = ko.observable(blogEntry.content);
    self.stockIcon = ko.observable(blogEntry.stockIcon);
    self.documents = ko.observableArray();
    self.image = ko.observable();
    self.type = ko.observable(blogEntry.type);
    self.viewMoreUrl = ko.observable(blogEntry.viewMoreUrl).extend({url:true});

    self.imageUrl = ko.computed(function() {
        if (self.image()) {
            return self.image().url;
        }
    });
    self.imageId = ko.computed(function() {
        if (self.image()) {
           return self.image().documentId;
        }
    });
    self.documents.subscribe(function() {
        if (self.documents()[0]) {
           self.image(new DocumentViewModel(self.documents()[0]));
        }
        else {
            self.image(undefined);
        }
    });
    self.removeBlogImage = function() {
        self.documents([]);
    };

    self.modelAsJSON = function() {
        var js = ko.mapping.toJS(self, {ignore:['transients', 'documents', 'image', 'imageUrl']});
        if (self.image()) {
            js.image = self.image().modelForSaving();
        }
        return JSON.stringify(js);
    };

    self.editContent = function() {
        editWithMarkdown('Blog content', self.content);
    };

    self.save = function() {
        if ($(config.validationElementSelector).validationEngine('validate')) {
            self.saveWithErrorDetection(
                function() {document.location.href = config.returnTo},
                function(data) {bootbox.alert("Error: "+data.responseText);}
            );
        }
    };

    self.cancel = function() {
        document.location.href = config.returnTo;
    };

    self.transients = {};
    self.transients.blogEntryTypes = config.types;

    if (blogEntry.documents && blogEntry.documents[0]) {
        self.documents.push(blogEntry.documents[0]);
    }
    $(config.validationElementSelector).validationEngine();
    autoSaveModel(self, config.blogUpdateUrl, {blockUIOnSave:true});
};

    $(function () {
        var blogEntry = <fc:modelAsJavascript model="${blogEntry}" default="{}"/>;
        var blogEntryViewModel = new EditableBlogEntryViewModel(blogEntry, '.validationEngineContainer');

        ko.applyBindings(blogEntryViewModel);

        $('.helphover').popover({animation: true, trigger:'hover'});
    });



</asset:script>

</body>


</html>
