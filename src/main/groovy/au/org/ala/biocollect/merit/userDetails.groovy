/*
 * Copyright (C) 2013 Atlas of Living Australia
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
 */

package au.org.ala.biocollect.merit

/**
 * Created with IntelliJ IDEA.
 *
 * @author "Nick dos Remedios <Nick.dosRemedios@csiro.au>"
 */
class UserDetails {

    public static final String REQUEST_USER_DETAILS_KEY = 'ecodata.request.user.details'

    String displayName
    String userName
    String userId

    public UserDetails(String displayName, String userName, String userId) {
        this.displayName = displayName
        this.userName = userName
        this.userId = userId
    }

    public UserDetails() {}

    @Override
    public String toString() {
        "[ userId: ${userId}, userName: ${userName}, displayName: ${displayName} ]"
    }
}