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

package au.org.ala.biocollect.permissions

import groovy.transform.Immutable

/**
 * Biocollect-specific user details object.
 */
@Immutable
class AppUserDetails {
    String firstName
    String lastName
    String displayName
    String userName
    String userId
    Set<String> roles

    /**
     * Returns true if this user has the supplied role.
     * @param role the role to check.
     * @return true if this user has the supplied role.
     */
    boolean hasRole(String role) {
        return roles.contains(role)
    }

    @Override
    String toString() {
        "[ userId: ${userId}, userName: ${userName}, displayName: ${displayName}, " +
                "roles: ${roles}, firstName: ${firstName}, lastName: ${lastName} ]"
    }
}