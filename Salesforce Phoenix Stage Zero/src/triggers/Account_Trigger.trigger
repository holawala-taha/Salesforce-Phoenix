trigger Account_Trigger on Account (before insert, before update, after update) {

	if (Trigger_Manager__c.getInstance().Deactivate_Account_Trigger__c) return;

	if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
		ClsAccountProcessor.assignRecordCountryToBillingCountry(Trigger.new, Trigger.oldMap);
		LibBusinessConfig.setSObjectCurrencyAndCompanyCode(Trigger.new);
		ClsAccountProcessor.checksBillingAndMailingCityValues(Trigger.new, Trigger.oldMap);


	}
	if (Trigger.isUpdate && Trigger.isAfter) {
		ClsAccountProcessor.menuProcessingClosingAction(Trigger.new, Trigger.oldMap);
		ClsAssetProcessor.checkIfAssetIsInUse(Trigger.new, Trigger.oldmap);
	}
}