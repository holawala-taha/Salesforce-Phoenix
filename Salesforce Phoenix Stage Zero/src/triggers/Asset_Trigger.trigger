trigger Asset_Trigger on Asset__c (before update, before insert, after update, after insert) {

    if (Trigger_Manager__c.getInstance().Deactivate_Asset_Trigger__c) return;

    // update
    if (Trigger.isUpdate) {

        if (Trigger.isBefore) {
            // before update
            ClsAssetProcessor.resetAllReturnFields(Trigger.new, Trigger.oldMap);
            ClsStockItemProcessor.copySerialNumberForGlobalSearch(Trigger.new, Trigger.oldMap);

        } else if (Trigger.isAfter) {

            // after update 
            ClsAssetProcessor.createAssetCancellation(Trigger.new, Trigger.oldMap);
            ClsAssetProcessor.setAssignedStockStatus(Trigger.new, Trigger.oldMap);
            ClsStockItemProcessor.trackAccountHistory(Trigger.newMap, Trigger.oldMap);
            ClsAssetProcessor.updateAdditionalChargeShadowRecord(Trigger.newMap, Trigger.oldMap);
            ClsAssetProcessor.stockItemFollowUp(Trigger.new, Trigger.oldMap);
            ClsAssetProcessor.assetStatusUpdateProcess(Trigger.new, Trigger.oldMap);
            ClsAssetProcessor.opportunityUpdateonAssetStatusChange(Trigger.new, Trigger.oldMap);
        }
    }

    // insert
    if (Trigger.isInsert) {

        if (Trigger.isBefore) {

            // before insert
            ClsStockItemProcessor.copySerialNumberForGlobalSearch(Trigger.new, null);
            ClsAssetProcessor.changeAssetStatusByProductType(Trigger.new);

        } else if (Trigger.isAfter) {

            // after insert
            ClsStockItemProcessor.trackAccountHistory(Trigger.newMap, Trigger.oldMap);
        }
    }
}