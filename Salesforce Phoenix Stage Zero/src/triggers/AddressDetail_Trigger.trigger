trigger AddressDetail_Trigger on AddressDetail__c (before insert, before update) {
	// checks if trigger is disabled
	if (Trigger_Manager__c.getInstance().Deactivate_AddressDetail_Trigger__c) return;

	TrgAddressDetailProcessor.checksDuplicateAddressTypesPerAccount(Trigger.New);
}