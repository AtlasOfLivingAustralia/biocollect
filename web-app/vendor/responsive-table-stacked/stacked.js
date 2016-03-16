/*
 * Copyright (C) 2016 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 * 
 * Created by Temi on 26/02/16.
 */
$(document).ready(function() {
    $('table').each(function(index, item){
        $(this).addClass('responsive-table-stacked').parent().addClass('overflow-table');
        addAttributeToTd(item)
        watch(this, addAttributeToTd)
    });
});

/**
 * adding data-th attribute to td elements of the table. this attribute is used to display
 * header on each table cell.
 * @param item
 */
function addAttributeToTd(item){
    $(item).find('thead th').each(function(col, th){
        var colNum = col + 1;
        var text = $(th).text()
        if(text){
            $(item).find('tbody tr td:nth-child('+colNum+')').attr('data-th',text.trim());
        }
    });
}

/**
 * checks if the inner html has changed on the target element and calls back if true.
 * http://stackoverflow.com/questions/12386058/html-table-onchange
 * @param targetElement
 * @param triggerFunction
 * @param delay
 */
function watch( targetElement, triggerFunction, delay ){
    delay = delay || 500;
    /// store the original html to compare with later
    var html = targetElement.innerHTML;
    /// start our constant checking function
    setInterval(function(){
        /// compare the previous html with the current
        if ( html != targetElement.innerHTML ) {
            /// trigger our function when a change occurs
            triggerFunction(targetElement);
            /// update html so that this doesn't keep triggering
            html = targetElement.innerHTML;
        }
    },delay);
}