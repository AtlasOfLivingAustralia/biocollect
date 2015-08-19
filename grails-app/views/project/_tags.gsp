<style type="text/css">
.projecttag {
    background: orange;
    color: white;
    padding: 4px;
    white-space: nowrap;
}
</style>
<span class="projecttag" data-bind="visible:isDIY()"><g:message code="project.tag.diy"/></span>
<span class="projecttag" data-bind="visible:isSuitableForChildren()"><g:message code="project.tag.children"/></span>
<span class="projecttag" data-bind="visible:!hasParticipantCost()"><g:message code="project.tag.noCost"/></span>
<span class="projecttag" data-bind="visible:hasTeachingMaterials()"><g:message code="project.tag.teach"/></span>
<span class="projecttag" data-bind="visible:difficulty() == 'Easy'"><g:message code="project.tag.difficultyEasy"/></span>
<span class="projecttag" data-bind="visible:difficulty() == 'Medium'"><g:message code="project.tag.difficultyMedium"/></span>
<span class="projecttag" data-bind="visible:difficulty() == 'Hard'"><g:message code="project.tag.difficultyHard"/></span>
<span class="projecttag" data-bind="visible:transients.scienceTypeDisplay(),text:transients.scienceTypeDisplay()"></span>
