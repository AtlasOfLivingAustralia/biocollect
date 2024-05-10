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
    <meta name="layout" content="${mobile ? "mobile" : "bs4"}"/>
    <title></title>
    <asset:javascript src="common.js"/>
</head>

<body>
<div class="${fluidLayout ? 'container-fluid' : 'container'}">
    <auth:ifAnyGranted roles="ROLE_ADMIN">
        <div class="row">
            <div class="col-12">
                <g:if test="${flash.errorMessage}">
                    <div class="row">
                        <div class="col-12 alert alert-danger fade show">
                            ${flash.errorMessage}
                        </div>
                    </div>
                </g:if>

                <g:if test="${flash.message}">
                    <div class="row">
                        <div class="col-12">
                            <div class="alert alert-info alert-dismissible fade show">
                                ${flash.message}
                                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                        </div>
                    </div>
                </g:if>
            </div>
        </div>

        <div class="btn-space">
            <a href="${g.createLink(controller: 'staticPage', action: 'edit',
                    params: [page: setting, editMode: true])}"
               class="btn btn-dark"><i class="fas fa-pencil-alt"></i> Edit
            </a>
        </div>
    </auth:ifAnyGranted>
    <fc:getSettingContentForDynamicKey key="${setting}"></fc:getSettingContentForDynamicKey>
</div>
</body>
</html>