<%@ page import="au.org.ala.biocollect.DateUtils" %>

<div class="photo-slider">

    <ul>
        <g:each in="${photos}" var="image" status="i">
            <g:set var="title" value="${(image.dateTaken ? DateUtils.isoToDisplayFormat(image.dateTaken)+" - " : "") +image.name}"/>


            <div id="caption-${i}" style="display:none;">
                <p class="caption large"><b>${image.name}</b>
                    <g:if test="${image.attribution}"><br/> ${image.attribution}</g:if>
                    <br/><b>POI: </b> ${image.poiName}
                    <g:if test="${image.dateTaken}">
                        <br/><b>Date taken: </b>${DateUtils.isoToDisplayFormat(image.dateTaken)}
                    </g:if>
                    <br/><b>Site: </b> ${image.siteName}
                    <br/><b>Project: </b> ${image.projectName}
                    <g:if test="${image.activity}">
                        <br/><b>Stage: </b> ${image.stage}
                        <br/><b>Activity type: </b> ${image.activity.type}
                        <br/><b>Activity description: </b> ${image.activity.description?:''}
                    </g:if>
                </p>
            </div>
            <li class="thumb">
                <a class="fancybox" rel="group" href="${image.url}" title="${title}" data-caption="caption-${i}" aria-label="Show full size images in popup window"><img src="${image.thumbnailUrl?:image.url}" aria-label="${title ?:"Un-captioned site image"}"/></a>
                <g:set var="activityLink" value="${image.activity?g.createLink(controller: 'activity', action:'index', id:image.activity.activityId):'#'}"/>
                <a href="${activityLink}">
                    <div class="caption large">
                        <div style="text-overflow: ellipsis; height: 40px; overflow-y:hidden;"><b>${image.name}</b></div>
                        <g:if test="${image.dateTaken}">
                            <b>Date taken: </b>${DateUtils.isoToDisplayFormat(image.dateTaken)}
                        </g:if>
                        <g:if test="${image.activity}">
                            <g:if test="${image.stage}">
                                ( ${image.stage} )
                            </g:if>
                            <br/><b>Activity type: </b> ${image.activity.type}
                        </g:if>
                    </div>
                </a>
            </li>
        </g:each>
    </ul>
</div>
