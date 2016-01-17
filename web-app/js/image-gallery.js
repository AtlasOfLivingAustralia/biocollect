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
    self.total = ko.observable();
    self.pagesize = 10;
    self.offset = ko.observable(0);
    self.max = ko.observable(self.pagesize)
    self.isLoadMore = ko.computed(function(){
        return self.total() > self.max();
    });

    /**
     * appends a list of images to the existing images.
     * @param images
     */
    self.addImages = function(images){
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
        $.ajax({
            url: prop.recordUrl,
            type: prop.method,
            data: JSON.stringify(prop.data),
            contentType: 'application/json',
            success: function(data){
                if(data.documents){
                    self.addImages(data.documents);
                    self.total(data.count);
                }
            }
        })
    }

    /**
     * parameters sent to webservice are saved here.
     */
    self.getUrlParameter = function(){
        prop.data.fq = activitiesModel.urlFacetParameter();
        prop.data.searchTerm = activitiesModel.searchTerm();
        prop.data.max = self.max();
        prop.data.offset = self.offset()
    }

    /**
     * clears image gallery of all images
     */
    self.reset = function(){
        self.offset(0)
        self.max(self.pagesize)
        self.recordImages.removeAll();
        self.total(0);
    }

    self.firstPage = function(){
        self.reset();
        self.fetchRecordImages();
    }

    self.nextPage = function(){
        self.offset(self.offset() + self.pagesize);
        self.max(self.offset() + self.pagesize);
        self.fetchRecordImages();
    }

    // subscribe so that changes to filter and search text will trigger a image gallery update
    activitiesModel = prop.viewModel;
    activitiesModel && activitiesModel.selectedFilters.subscribe(self.firstPage);
    activitiesModel && activitiesModel.searchTerm.subscribe(self.firstPage);
    // initialise images
    if(prop.images && prop.images.length){
        self.addImages(prop.images);
        self.total(prop.images.length);
    } else if (prop.recordUrl){
        self.firstPage();
    }
}