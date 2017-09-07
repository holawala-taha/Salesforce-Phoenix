trigger Branding_Trigger on Branding_Content__c(after insert, after update, before delete) {

    if (Trigger_Manager__c.getInstance().Deactivate_Branding_Trigger__c) return;
    
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            ClsBrandingContent.updateOppOnBrandingActivation(trigger.new, trigger.oldmap);
            ClsBrandingContent.updateAccountBrandingStatus(trigger.new, trigger.oldmap);
            clsBrandingContent.createBackendEntryCase(trigger.new, trigger.oldmap);
        }

        if (Trigger.isInsert) {
            ClsBrandingContent.updateAccountBrandingStatus(Trigger.new);
        }
    }

    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            ClsBrandingContent.updateAccountBrandingStatus(Trigger.old);
        }
    }

}