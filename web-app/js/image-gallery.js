/**
 * Created by Temi Varghese on 13/01/16.
 */
function ImageGalleryViewModel(config){
    var self = this, activitiesModel, map, selectedData;
    var prop = $.extend({
        method: 'POST',
        images: [],
        margin: 30
    },config);

    self.recordImages = ko.observableArray();
    self.error = ko.observable('');
    self.total = ko.observable();
    self.offset = ko.observable(0);
    self.pagination = new PaginationViewModel({}, self);
    self.max = ko.observable(self.pagination.resultsPerPage());
    self.isLoadMore = ko.computed(function(){
        return self.total() > self.max();
    });
    self.transients = {};
    self.transients.loading = ko.observable(false);

    /**
     * This function is called by the Pagination component everytime a new page needs to be displayed.*
     * @param offset The number of records to skip, if ommitted the first page (offset 0) will be loaded.
     */
    self.refreshPage = function (offset) {
        self.offset( offset || 0);
        self.fetchRecordImages();

    }

    /**
     * Replace VM images with current result retreived.
     * @param images
     */
    self.refreshRecordImages = function(images){
        self.recordImages.removeAll();
        images && images.forEach(function(image){
            self.recordImages.push(new ImageViewModel(image, true));
        });
    }

    /**
     * fetches the next batch of images from the server.
     * max and offset params used for pagination
     */
    self.fetchRecordImages = function(){
        // update post parameters eg. max and offset
        self.getUrlParameter();
        self.error('');
        $.ajax({
            url: prop.recordUrl,
            type: prop.method,
            data: JSON.stringify(prop.data),
            contentType: 'application/json',
            beforeSend: function () {
                self.transients.loading(true);
            },
            success: function(data){
                if(data.documents){
                    self.refreshRecordImages(data.documents);
                    self.total(data.total);
                    self.pagination.totalResults(data.total);
                }
            },
            error: function(jxhr, status, message){
                self.error(jxhr.responseText);
            },
            complete: function () {
                self.transients.loading(false);
            }
        })
    }

    /**
     * parameters sent to webservice are saved here.
     */
    self.getUrlParameter = function(){
        prop.data.fq = activitiesModel.urlFacetParameter();
        prop.data.searchTerm = activitiesModel.searchTerm();
        prop.data.max = self.pagination.resultsPerPage();
        prop.data.offset = self.offset()
    }

    /**
     * clears image gallery of all images
     */
    self.reset = function(){
        self.offset(0)
        self.max(self.pagination.resultsPerPage)
        self.recordImages.removeAll();
        self.total(0);
    }

    self.reloadRecordImages = function(){
        self.reset();
        // Let's force a pagination reconfiguration asynchronously.
        self.transients.paginationSubscription = self.transients.loading.subscribe(self.loadPagination);
        self.fetchRecordImages();
    }

    self.loadPagination = function () {
        if(!self.transients.loading()) { // Loading has finished
            self.pagination.loadPagination(0, self.total());
            // We only want this function on page load or when the filter has been updated, we don't want to be
            // called when the actual pagination controls are used in the UI hence we unsubscribe after it has been
            // (re)initialised - The subscription is created on self.reloadRecordImages()
            self.transients.paginationSubscription.dispose();
        }
    }

    // subscribe so that changes to filter and search text will trigger a image gallery update
    activitiesModel = prop.viewModel;

    // initialise images
    if(prop.images && prop.images.length){
        self.refreshRecordImages(prop.images);
        self.total(prop.images.length);
    } else if (prop.recordUrl){
        self.reloadRecordImages();
    }
}