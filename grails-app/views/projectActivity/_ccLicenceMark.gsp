<a href="${licence.url}" target="_blank" rel="noopener noreferrer" class="cc-licence-mark">
    <g:each in="${licence.icons}" var="icon">
        <img class="cc-licence-icon" src="${asset.assetPath(src: "licence/${icon}.svg")}" alt="" aria-hidden="true">
    </g:each>
    <span class="cc-licence-label">${label ?: licence.description}</span>
</a>
