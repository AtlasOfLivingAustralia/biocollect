<r:require modules="imageDataType,imageViewer"></r:require>
%{-- html element id cannot have dot(s) in them --}%
<g:set var="id" value="${name?.replace('.','')}"></g:set>
<g:set var="carId" value="${id}Carousel"></g:set>
<g:set var="carInit" value="${carId}Init"/>
<div id="" class="fileupload-buttonbar" data-bind="visible: ${name}().length">
    <div class="carousel slide images-carousel images-carousel-size" data-bind="attr:{id: '${carId}'+${index}}">
        <ol class="carousel-indicators">
            <!-- ko foreach: ${name} -->
            <!-- ko if: status() != 'deleted' -->
            <li data-bind="attr:{'data-slide-to':$index}"></li>
            <!-- /ko -->
            <!-- /ko -->
        </ol>
        <!-- Carousel items -->
        <div class="carousel-inner text-center">
            <!-- ko foreach: ${name} -->
            <!-- ko if: status() != 'deleted' -->
            <div class="item images-carousel-size" data-bind="css:{active:$index()==0}">
                <a data-bind="attr:{href:url}" data-target="_photo" class="images-carousel-size">
                    <img data-bind="attr:{src:url}" onload="initCarouselImages(this)" alt="">
                </a>

                <div class="carousel-caption">
                    <h4 data-bind="text:name"></h4>

                    <p data-bind="html:summary()"></p>
                </div>
            </div>
            <!-- /ko -->
            <!-- /ko -->
        </div>
        <!-- Carousel nav -->
        <a class="carousel-control left"  data-bind="attr:{href: '#' + '${carId}'+${index}}" data-slide="prev">&lsaquo;</a>
        <a class="carousel-control right" data-bind="attr:{href: '#' + '${carId}'+${index}}" data-slide="next">&rsaquo;</a>
    </div>
</div>