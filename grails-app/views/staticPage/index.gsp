<!--
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
 * Created by Temi on 3/11/16.
 */
-->
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="${mobile ? "mobile" : hubConfig.skin}"/>
    <title></title>
</head>

<body>
    <div class="${fluidLayout?'container-fluid':'container'}">
        <auth:ifAnyGranted roles="ROLE_ADMIN">
            <div class="row-fluid">
                <g:if test="${flash.errorMessage}">
                    <div class="row-fluid">
                        <div class="span6 alert alert-error">
                            ${flash.errorMessage}
                        </div>
                    </div>
                </g:if>

                <g:if test="${flash.message}">
                    <div class="row-fluid">
                        <div class="span6 alert alert-info">
                            <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
                            ${flash.message}
                        </div>
                    </div>
                </g:if>
            </div>
            <a href="${g.createLink(controller: 'staticPage', action:'edit',
                    params:[page:setting, editMode:true])}"
               class="btn btn-default">edit
            </a>
        </auth:ifAnyGranted>
        <fc:getSettingContentForDynamicKey key="${setting}"></fc:getSettingContentForDynamicKey>
    </div>
</body>
</html>