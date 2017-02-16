<div id="datasetInfo" >

    <div class="row-fluid">
        <div class="span12">
            <h4 class="strong">Step 3 of 9 - Dataset Content</h4>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label"><g:message code="aekos.dataset.content.fos"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'',
                          content:'<g:message code="aekos.dataset.content.fos.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div data-bind="treeView: {data: fieldsOfResearch,
                                       extraFieldLabel: '<g:message code="aekos.dataset.content.fos.extra"/>'}" ></div>
        </div>
    </div>

    <div class="row-fluid">
           <div class="span4 text-right">
               <label class="control-label"><g:message code="aekos.dataset.content.seo"/>
                   <a href="#" class="helphover"
                      data-bind="popover: {title:'',
                             content:'<g:message code="aekos.dataset.content.seo.help"/>'}">
                       <i class="icon-question-sign"></i>
                   </a>
               </label>
           </div>

           <div class="span8">
               <div data-bind="treeView: {data: socioEconomic,
                                          extraFieldLabel: '<g:message code="aekos.dataset.content.seo.extra"/>'}" ></div>
           </div>
       </div>

       <div class="row-fluid">
           <div class="span4 text-right">
               <label class="control-label"><g:message code="aekos.dataset.content.research"/>
                   <a href="#" class="helphover"
                      data-bind="popover: {title:'',
                             content:'<g:message code="aekos.dataset.content.research.help"/>'}">
                       <i class="icon-question-sign"></i>
                   </a>
               </label>
           </div>

           <div class="span8">
               <div data-bind="treeView: {data: economicResearch,
                                          extraFieldLabel: '<g:message code="aekos.dataset.content.research.extra"/>'}" ></div>
           </div>
       </div>

       <div class="row-fluid">
           <div class="span4 text-right">
               <label class="control-label"><g:message code="aekos.dataset.content.threat"/>
                   <a href="#" class="helphover"
                      data-bind="popover: {title:'',
                             content:'<g:message code="aekos.dataset.content.threat.help"/>'}">
                       <i class="icon-question-sign"></i>
                   </a>
               </label>
           </div>

           <div class="span8">
               <div data-bind="treeView: {data: anthropogenic,
                                          extraFieldLabel: '<g:message code="aekos.dataset.content.threat.extra"/>'}" ></div>
           </div>
       </div>

       <div class="row-fluid">
           <div class="span4 text-right">
               <label class="control-label"><g:message code="aekos.dataset.content.conservation"/>
                   <a href="#" class="helphover"
                      data-bind="popover: {title:'',
                             content:'<g:message code="aekos.dataset.content.conservation.help"/>'}">
                       <i class="icon-question-sign"></i>
                   </a>
               </label>
           </div>

           <div class="span8">
               <div data-bind="treeView: {data: conservationManagement,
                                          extraFieldLabel: '<g:message code="aekos.dataset.content.conservation.extra"/>'}" ></div>
           </div>
       </div>
</div>