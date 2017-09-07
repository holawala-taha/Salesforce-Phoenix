trigger Case_Trigger on Case (after update, before update, before insert, after insert) {

    if (Trigger_Manager__c.getInstance().Deactivate_Case_Trigger__c) return;

    if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
        LibBusinessConfig.setCaseCurrencyAndCompanyCodeFromAccount(Trigger.new);
        if (Trigger.isUpdate) {

            clsCaseProcessor.menuProcessingStatusUpdateValidation(Trigger.new, Trigger.oldMap);
            clsCaseProcessor.preventParentCaseClose(Trigger.new, Trigger.oldMap);
            clsCaseProcessor.updateMenuProcessingCaseOwner(Trigger.new, Trigger.oldMap);
            clsCaseProcessor.updateDueDateonCase(Trigger.new, Trigger.oldMap);
            clsCaseProcessor.preventSalesTeamFromEditingQC(Trigger.new, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter && Trigger.isUpdate) {

        //clsCaseProcessor.retentionProcess(Trigger.new, Trigger.oldMap);
        //clsCaseProcessor.takeOfflineProcess(Trigger.new, Trigger.oldMap);
        //clsCaseProcessor.dataChangeProcess(Trigger.new, Trigger.oldMap);
        //clsCaseProcessor.businessLicenseeChange(Trigger.new, Trigger.oldMap);
        //clsCaseProcessor.invoiceAddressChange(Trigger.new, Trigger.oldMap);
        //clsCaseProcessor.validateMenuProcessingCase(Trigger.new);

        clsCaseProcessor.menuTypingCaseClosingAction(Trigger.new, Trigger.oldMap);
        clsCaseProcessor.menuTypingCaseCreation(Trigger.new, Trigger.oldMap);
        clsCaseProcessor.nonContractedMenuChange(Trigger.new);
        clsCaseProcessor.menuProcessingClosingAction(Trigger.new, Trigger.oldMap);
        clsCaseProcessor.terminationCaseFlow(Trigger.newMap, Trigger.oldMap);
        clsCaseProcessor.retentionCaseFlow(Trigger.newMap, Trigger.oldMap);
        clsCaseProcessor.qualityCheckClosingAction(Trigger.new, Trigger.oldMap);
        clsCaseProcessor.NonContractedMenuProcessingClosingAction(Trigger.new, Trigger.oldMap);
        clsCaseProcessor.updateAccountOnlineStatusByMenuProcessing(Trigger.newMap, Trigger.oldMap);
        //clsCaseProcessor.takeOfflineCaseFlow(Trigger.new);
        clsCaseProcessor.onboardingCaseClosingAction(Trigger.new, Trigger.oldMap);
        clsCaseProcessor.inboundUKPPUpdateMidasAPI(Trigger.new, Trigger.oldMap);
        clsCaseProcessor.qualityCheckReplacementClosingAction(Trigger.new, Trigger.oldMap);
        //SP-1084 CD - Product Opportunity Flow
        clsCaseProcessor.backendShippingCaseClosure(Trigger.new, Trigger.oldMap);
        clsCaseProcessor.brandingCaseClosure(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isInsert && Trigger.isAfter) {
        clsCaseProcessor.backendAccountCaseCreation(Trigger.new);
        clsCaseProcessor.updateAccountOnlineStatusByMenuProcessing(Trigger.newMap, Trigger.oldMap);
    }
}