package au.org.ala.biocollect.merit
/**
 * Sends email messages to notify interested parties of changes.
 */
class EmailService {

    def projectService, userService, mailService, settingService, grailsApplication, organisationService

    def createAndSend(mailSubjectTemplate, mailTemplate, model, recipient, sender, ccList) {
        def systemEmailAddress = grailsApplication.config.fieldcapture.system.email.address
        try {
            def subjectLine = settingService.getSettingText(mailSubjectTemplate, model)
            def body = settingService.getSettingText(mailTemplate, model).markdownToHtml()

            // This is to prevent spamming real users while testing.
            def emailFilter = grailsApplication.config.emailFilter
            if (emailFilter) {
                if (!recipient instanceof Collection) {
                    recipient = [recipient]
                }
                if (!ccList instanceof Collection) {
                    ccList = [ccList]
                }

                recipient = recipient.findAll {it ==~ emailFilter}
                if (!recipient) {
                    // The email won't be sent unless we have a to address - use the submitting user since
                    // the purpose of this is testing.
                    recipient = [userService.getUser().userName]
                }
                ccList = ccList.findAll {it ==~ emailFilter}
            }
            log.info("Sending email: ${subjectLine} to: ${recipient}, from: ${sender}, cc:${ccList}, body: ${body}")

            mailService.sendMail {
                to recipient
                if (ccList) {cc ccList}
                from systemEmailAddress
                replyTo sender
                subject subjectLine
                html body

            }
        }
        catch (Exception e) {
            log.error("Failed to send email: ", e)
        }
    }

    def sortEmailAddressesByRole(members) {
        def user = userService.getUser()
        def caseManagerEmails = members.findAll{it.role == RoleService.GRANT_MANAGER_ROLE}.collect{it.userName}
        def adminEmails = members.findAll{it.role == RoleService.PROJECT_ADMIN_ROLE && it.userName != user.userName}.collect{it.userName}

        [userEmail:user.userName, grantManagerEmails:caseManagerEmails, adminEmails:adminEmails]
    }

    def getOrganisationEmailAddresses(organisationId) {
        def members = organisationService.getMembersOfOrganisation(organisationId)
        sortEmailAddressesByRole(members)
    }

    def getProjectEmailAddresses(projectId) {
        def members = projectService.getMembersForProjectId(projectId)
        sortEmailAddressesByRole(members)

    }
}
