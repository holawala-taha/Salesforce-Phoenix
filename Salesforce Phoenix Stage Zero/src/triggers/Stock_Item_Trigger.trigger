trigger Stock_Item_Trigger on Stock_Item__c (before update) {

	if (Trigger_Manager__c.getInstance().Deactivate_StockItems_Trigger__c) return;
	
	ClsStockItemProcessor.resetRestaurantsNameOnStockItem(trigger.newMap, trigger.oldMap);
	ClsStockItemProcessor.stockBeforUpdate(trigger.new, trigger.oldMap);
	ClsStockItemProcessor.calculateStockUsedDays(trigger.new);
}