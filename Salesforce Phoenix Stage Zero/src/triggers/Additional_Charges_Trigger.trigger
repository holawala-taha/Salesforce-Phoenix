trigger Additional_Charges_Trigger on Additional_Charges__c (after insert, after update) {

	if (Trigger_Manager__c.getInstance().Deactivate_Add_Charges_Trigger__c) return;

	if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
		ClsAdditionalChargeProcessor.createAdditionalChargeShadow(Trigger.new);
		if (Trigger.isUpdate) {
			ClsAdditionalChargeProcessor.createEntryCaseForFlatCommissionCancelation(Trigger.new, Trigger.oldMap);
		}
	}
}