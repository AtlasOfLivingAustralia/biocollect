%{--
  - Copyright (C) 2013 Atlas of Living Australia
  - All Rights Reserved.
  -
  - The contents of this file are subject to the Mozilla Public
  - License Version 1.1 (the "License"); you may not use this file
  - except in compliance with the License. You may obtain a copy of
  - the License at http://www.mozilla.org/MPL/
  -
  - Software distributed under the License is distributed on an "AS
  - IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  - implied. See the License for the specific language governing
  - rights and limitations under the License.
  --}%

<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<!doctype html>
<html>
    <head>
        <meta name="layout" content="adminLayout"/>
        <title>Static pages | Admin | Data capture | Atlas of Living Australia</title>
    </head>

    <body>
        <content tag="pageTitle">Static pages</content>
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>Page Id</th>
                    <th>View</th>
                    <th>Edit</th>
                </tr>
            </thead>
            <tbody>
                <g:each var="setting" in="${settings}">
                    <tr>
                        <td>
                            ${setting.key}
                        </td>
                        <td>
                            <a href="${createLink(controller: 'home', action: 'staticPage', id: setting.name)}" class="btn btn-small">
                                <i class="icon-file"></i>&nbsp;View</a>
                        </td>
                        <td style="max-width:500px;overflow-wrap:break-word;">
                            <g:if test="${setting.editLink}">
                                <a href="${setting.editLink}/${setting.name}" class="btn btn-small">
                                    <i class="icon-edit"></i>&nbsp;Edit
                                </a>
                            </g:if>
                            <g:else>
                                ${setting.value}
                            </g:else>
                        </td>
                    </tr>
                </g:each>
            </tbody>
        </table>

    </body>
</html>