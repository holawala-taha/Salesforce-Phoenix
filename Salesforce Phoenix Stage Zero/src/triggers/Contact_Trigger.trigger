trigger Contact_Trigger on Contact (before insert, before update) {

	if (Trigger_Manager__c.getInstance().Deactivate_Contact_Trigger__c) return;

	ClsContactProcessor.enforceOneOwnerRoleForAccountContacts(Trigger.new);
	if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
		LibBusinessConfig.setSObjectCurrencyAndCompanyCode(Trigger.new);
	}

}