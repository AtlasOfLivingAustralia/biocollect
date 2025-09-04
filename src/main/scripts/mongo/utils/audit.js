/** Inserts a document into the auditMessage collection */
function audit(entity, entityId, type, userId, projectId, eventType) {
    var auditMessage = {
        date: ISODate(),
        entity: entity,
        eventType: eventType || 'Update',
        entityType: type,
        entityId: entityId,
        userId: userId
    };
    if (entity.projectId || projectId) {
        auditMessage.projectId = (entity.projectId || projectId);
    }
    db.auditMessage.insertOne(auditMessage);
}