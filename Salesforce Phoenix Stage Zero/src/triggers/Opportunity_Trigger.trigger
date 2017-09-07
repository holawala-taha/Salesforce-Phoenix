trigger Opportunity_Trigger on Opportunity (after update, before insert, before update, after insert) {

    if (Trigger_Manager__c.getInstance().Deactivate_Opportunity_Trigger__c) return;

    if (Trigger.isUpdate && Trigger.isAfter) {
        //Asset and contract process are merged together in TrgOpportunityProcessor.contractProcess method
        TrgOpportunityProcessor.contractProcess(Trigger.new, Trigger.oldMap);
        //SP-1364 Added by Bhupendra Kshatri
        TrgOpportunityProcessor.populateAccOnOppCloseWon(Trigger.new, Trigger.oldMap);
        //SP-35 triggers creation of menu chnage for non contracted opportunity when it attains certain stage
        TrgOpportunityProcessor.nonContractedMenuChange(Trigger.new, Trigger.oldMap);
        //SP-35 triggers creation of menu processing for contracted opportunity
        TrgOpportunityProcessor.contractedMenuProcessing(Trigger.new, Trigger.oldMap);
        //SP-373 triggers creation of Quality check internal case
        TrgOpportunityProcessor.qualityCheckInternalCase(Trigger.new, Trigger.oldMap);
        //SP-496 triggers creation of asset according to the stage of the opportunity
        TrgOpportunityProcessor.assetCreationProcess(Trigger.new, Trigger.oldMap);
        //SP-526 Automatically a Case [Record Type : Yogiyo Entry Case / Type : 0% Commission Entry] will be created, assigned to editorial queue
        TrgOpportunityProcessor.flatCommissionEntryCaseProcess(Trigger.new, Trigger.oldMap);
        //SP-SP-945 Cancel Midas Opp for PP
        TrgOpportunityProcessor.closedLostPPandUpdateMidasAPI(Trigger.new, Trigger.oldMap);
        TrgOpportunityProcessor.createBackendID(Trigger.new, Trigger.oldMap);
        TrgOpportunityProcessor.restaurantCareCaseCreation(Trigger.new, Trigger.oldMap);
        //SP-1084 CD - Product Opportunity Flow
        TrgOpportunityProcessor.createBackendShippingCase(Trigger.new, Trigger.oldMap);
        TrgOpportunityProcessor.createBrandingOnAcceptQuote(Trigger.new, Trigger.oldMap);
        ClsOpportunityProcessor.terminateOpportunityChildRecordsOnLost(Trigger.new, Trigger.oldMap);

    }
    if ((Trigger.isInsert ||  Trigger.isUpdate) && Trigger.isAfter) {
        //SP-35 triggers creation of menu processing for non contracted opportunity
        TrgOpportunityProcessor.nonContractedMenuProcessing(Trigger.new);
        TrgOpportunityProcessor.genericMenuProcessing(Trigger.new, Trigger.oldMap);
        TrgOpportunityProcessor.adSalesCaseProcessing(Trigger.new, Trigger.oldMap);
    }

    if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
        LibBusinessConfig.setSObjectCurrencyAndCompanyCode(Trigger.new);
        TrgOpportunityProcessor.validateClosedOpportunity(Trigger.new, Trigger.oldMap);
        if (Trigger.isUpdate) {
            TrgOpportunityProcessor.MenuProcessingCaseCheck(Trigger.new, Trigger.oldMap);

            //TrgOpportunityProcessor.validateClosedOpportunity(Trigger.new,Trigger.oldMap);

        }
    }

    if (Trigger.isInsert && Trigger.isBefore) {
        TrgOpportunityProcessor.setDefaultValueForOpportunityQuoteComment(Trigger.new, false);
        TrgOpportunityProcessor.checkOppStageOnCreation(Trigger.new);
        //TrgOpportunityProcessor.resetFields(Trigger.new);
    }
}