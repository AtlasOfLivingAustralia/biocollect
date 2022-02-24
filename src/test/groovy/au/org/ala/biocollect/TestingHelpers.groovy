package au.org.ala.biocollect

import au.org.ala.biocollect.merit.RoleService
import au.org.ala.biocollect.permissions.AppUserDetails
import au.org.ala.biocollect.permissions.AppUserPermissions

class TestingHelpers {

    static int getRandomInRange(int minInclusive, int maxInclusive) {
        def randomValue = Math.random()
        // random value can be in range min (inclusive) to max (inclusive)
        return (int) (randomValue * ((maxInclusive - minInclusive) + 1)) + minInclusive
    }

    static String getRandomId() {
        return getRandomInRange(1000, 100000)?.toString()
    }

    static Map mergeWith(Closure fn, Map... maps) {
        maps*.keySet().sum().collectEntries { k ->
            [k, maps.findAll { it.containsKey k }*.get(k).inject(fn)]
        }
    }

    static List<String> getAllMethodsBooleanNoArgs(Class aClass) {
        aClass.methods.findAll { it.parameterCount == 0 && it.returnType == boolean.class }.collect { it.name }
    }

    static AppUserPermissions createUserPermissions(
            String userId,
            List<String> hasRoles = null, List<List<String>> hasAccessLevels = null,
            boolean rolesApiSuccess = true, boolean accessLevelsApiSuccess = true) {

        if (!rolesApiSuccess && hasRoles != null) {
            assert false, "rolesApiSuccess must be true if hasRoles"
        }
        if (!accessLevelsApiSuccess && hasAccessLevels != null) {
            assert false, "accessLevelsApiSuccess must be true if hasAccessLevels"
        }

        def isLoggedIn = userId?.trim()
        try {
            if (isLoggedIn) {
                isLoggedIn = userId.toBigInteger() > 0
            }
        } catch (Exception ignored) {
            isLoggedIn = false
        }

        def user = isLoggedIn ? new AppUserDetails(userId: userId) : null
        Map<String, Boolean> roles = RoleService.ALL_ROLES.collectEntries { [it, hasRoles?.contains(it)] }
        roles[RoleService.LOGGED_IN_USER_ROLE] = isLoggedIn

        Map<String, Map<String, List<String>>> accessLevels = [:]
        hasAccessLevels.each {
            def accessLevel = it[0]
            def entityType = it[1]
            def entityId = it[2]
            if (!accessLevels.containsKey(accessLevel)) {
                accessLevels[accessLevel] = [:]
            }
            if (!accessLevels[accessLevel].containsKey(entityType)) {
                accessLevels[accessLevel][entityType] = []
            }
            if (!accessLevels[accessLevel][entityType].contains(entityId)) {
                accessLevels[accessLevel][entityType].add(entityId)
            }
        }

        return new AppUserPermissions(user, rolesApiSuccess, roles, accessLevelsApiSuccess, accessLevels)
    }
}
