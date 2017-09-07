trigger Lead_Trigger on Lead (before insert, before update) {

	if (Trigger_Manager__c.getInstance().Deactivate_Lead_Trigger__c) return;
	
	if (Trigger.isBefore) {
		if (Trigger.isInsert) {
			ClsLeadProcessor.PhoneToMobileForAUContactPage(Trigger.new);
		}
		ClsLeadProcessor.assignRecordCountryToBillingCountry(Trigger.new, Trigger.oldMap);
		LibBusinessConfig.setCountryLookUp(Trigger.new);
		LibBusinessConfig.setSObjectCurrencyAndCompanyCode(Trigger.new);
	}
}