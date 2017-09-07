trigger Task_Trigger on Task (before insert, before update, after update, after insert) {

    if (Trigger_Manager__c.getInstance().Deactivate_Task_Trigger__c) return;

    /*if(trigger.isInsert && trigger.isAfter){
        ClsTaskProcessor.convertTaskToCases(Trigger.new);
    }*/
    if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
        ClsTaskProcessor.updateLatestCallCommentsInOpportunity(Trigger.new, Trigger.oldMap);
        ClsTaskProcessor.updateLeadStatus(Trigger.new, Trigger.oldMap);
        //ClsTaskProcessor.updateCaseLastCallDate(Trigger.new);//Commented for SP-1393. Will fire only on insert
        //ClsTaskProcessor.updateLeadLastCallDate(Trigger.new);//Commented for SP-1393. Will fire only on insert
    }

    //Added for SP-1393. Will fire only on Insert
    if (Trigger.isInsert && Trigger.isAfter) {
        ClsTaskProcessor.updateCaseLastCallDate(Trigger.new);
        ClsTaskProcessor.updateLeadLastCallDate(Trigger.new);
    }

}