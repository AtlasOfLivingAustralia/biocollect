<r:require modules="imageDataType"></r:require>
%{-- html element id cannot have dot(s) in them --}%
<g:set var="id" value="${name?.replace('.','')}"></g:set>
<div id="" class="fileupload-buttonbar" data-bind="visible: ${name}().length">
    <div id="${id}Carousel" class="carousel slide images-carousel-size">
        <ol class="carousel-indicators">
            <!-- ko foreach: ${name} -->
            <!-- ko if: status() != 'deleted' -->
            <li data-target="#${id}Carousel" data-bind="attr:{'data-slide-to':$index}"></li>
            <!-- /ko -->
            <!-- /ko -->
        </ol>
        <!-- Carousel items -->
        <div class="carousel-inner text-center">
            <!-- ko foreach: ${name} -->
            <!-- ko if: status() != 'deleted' -->
            <div class="item" data-bind="css:{active:$index()==0}">
                <img data-bind="attr:{src:url}">

                <div class="carousel-caption">
                    <h4 data-bind="text:name"></h4>

                    <p data-bind="html:summary()"></p>
                </div>
            </div>
            <!-- /ko -->
            <!-- /ko -->
        </div>
        <!-- Carousel nav -->
        <a class="carousel-control left" href="#${id}Carousel" data-slide="prev">&lsaquo;</a>
        <a class="carousel-control right" href="#${id}Carousel" data-slide="next">&rsaquo;</a>
    </div>
</div>