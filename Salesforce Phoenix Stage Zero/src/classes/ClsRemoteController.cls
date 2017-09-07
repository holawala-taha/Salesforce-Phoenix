global without sharing class ClsRemoteController {
     public static Boolean chkAcceptQuote=false;
       public Static Boolean skipOppUpd=false;
    
    //private static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Opportunity','Asset__c','Opportunity_Quote__c','Case'});
    //private static Map<Id,RecordType> mapRecordTypesForIds = LibRecordTypeHelper.getRecordTypeForIds(new Set<String>{'Opportunity','Opportunity_Quote__c','Case'});
    private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

    //SP-711
    webservice static List<String> escalateCaseAU(String caseId){
        List<String> listResult = new List<String>();

        Map<String,Business_Config__c> mapProcessData = new Map<String,Business_Config__c>();
        Case theCase = [SELECT Id, OwnerId, Status, IsClosed,recordType.developerName 
        					FROM Case 
        					WHERE Id =: caseId LIMIT 1];
        try{
            if(moam.get('EscalateCaseBtn')!=null && 
              	moam.get('EscalateCaseBtn').get(theCase.recordType.developerName) != null){
	                mapProcessData = moam.get('EscalateCaseBtn').get(theCase.recordType.developerName);
	                system.debug('mapProcessData : ' + mapProcessData);    
	                System.debug('theCase: ' + theCase);
	
	
	                Id theId = Id.valueOf(theCase.OwnerId);
	                Schema.SObjectType theObjType = theId.getSobjectType();
	                String theObjTypeName = theObjType.getDescribe().getName();
	
	                
	                
	                if(theCase.IsClosed){
	                    listResult.add(Label.Escalated_closed_case_AU);
	                    return listResult;
	                }
	                System.debug('theObjTypeName ' + theObjTypeName);
	                if(theObjTypeName == 'Group'){
	                    listResult.add(Label.Escalated_already_AU);
	                    return listResult;
	
	                }else if(theObjTypeName == 'User'){
	
	                    String ownerId = mapProcessData.get('ownerId').Business_Rule_Value__c;
	                    //SP-728
	                    if(UserInfo.getUserId() == theCase.OwnerId){
	                        if(theCase.OwnerId != ownerId){
	                            theCase.OwnerId = ownerId;
	
	                            Database.SaveResult saveResult = Database.update(theCase,true);
	
	                            if(saveResult.getErrors().isEmpty()){
	                                listResult.add(Label.Escalated_successful_AU);
	                            }else{
	                                listResult.add(Label.Escalated_not_sucessful_AU);
	                            }
	                        }else{
	                            listResult.add(Label.Escalated_already_AU);
	                        }
	                    }else{
	                        listResult.add(Label.Escalated_only_if_owner);
	                    }
	                }
	                
	            }
        }catch(Exception e){
            listResult.add(e.getMessage());
            return listResult;
        }

        return listResult;
    }
    
    
    
     webservice static List<String> backToQueue(String caseId){
        List<String> listResult = new List<String>();
        system.debug('*backtoQueue');
        Map<String,Business_Config__c> mapProcessData = new Map<String,Business_Config__c>();
        Case theCase = [SELECT Id, OwnerId, Status, IsClosed,recordtype.developername,queue_id__c FROM Case WHERE Id =: caseId LIMIT 1];
        system.debug('Case Recordtype : ' + theCase.recordtype.developername);
        system.debug('moam  : ' + moam.keyset());
        system.debug('moam BackToQueueBtn : ' + moam.get('BackToQueueBtn'));
        try{
            if(moam.get('BackToQueueBtn').get(theCase.recordtype.developername) != null){
                mapProcessData = moam.get('BackToQueueBtn').get(theCase.recordtype.developername);

                
                System.debug('theCase: ' + theCase);

                System.debug('theCase.ownerId: ' + theCase.OwnerId);
                Id theId = Id.valueOf(theCase.OwnerId);
                system.debug('theId : ' + theId);
                Schema.SObjectType theObjType = theId.getSobjectType();
                String theObjTypeName = theObjType.getDescribe().getName();

                String ownerId='';
                
                if(mapProcessData.get('chkForPrevQueue')!=null && Boolean.valueOf(mapProcessData.get('chkForPrevQueue').Business_Rule_Value__c) && theCase.queue_id__c!=null){
                    ownerId=theCase.queue_id__c;
                }
                else
                    ownerId=mapProcessData.get('ownerId').Business_Rule_Value__c;
                
                if(theCase.IsClosed){
                    listResult.add(Label.Back_to_Queue_Closed_Case);
                    return listResult;
                }
                System.debug('theObjTypeName ' + theObjTypeName);
                if(theObjTypeName == 'Group' && theId == ownerId ){
                    listResult.add(Label.Level_1_Support_Queue);
                    return listResult;

                }
                
                else if(theObjTypeName == 'Group' && theId != ownerId ){
                    listResult.add(Label.BacktoQueue_owner_change);
                    return listResult;

                }
                else if(theObjTypeName == 'User'){

                    //String ownerId = mapProcessData.get('ownerId').Business_Rule_Value__c;

                    if(theCase.OwnerId != ownerId /*&& theCase.OwnerId==UserInfo.getUserId()*/ ){
                        theCase.OwnerId = ownerId;

                        Database.SaveResult saveResult = Database.update(theCase,true);

                        if(saveResult.getErrors().isEmpty()){
                            listResult.add(Label.BackToQueue_successful);
                        }else{
                            listResult.add(Label.Back_to_Queue_Unsucessful_AU);
                        }
                    }else{
                        listResult.add(Label.BacktoQueue_owner_change);
                    }
                }
                
            }
        }catch(Exception e){
            listResult.add(e.getMessage());
            return listResult;
        }

        return listResult;
    }
    
    
     webservice static List<String> markComplete(String caseId) {
        List<String> listResult = new List<String>();
        system.debug('*backtoQueue');
        Map<String, Business_Config__c> mapProcessData = new Map<String, Business_Config__c>();
        try {
            Case theCase = [SELECT Id, OwnerId, recordtype.developername, Delivery_Area_Type_Date__c, Person_in_Charge_Final_Check__c, Person_in_charge_BE__c, Person_In_Charge_Take_Online__c, Status, Type, Take_Online_Date__c, Person_In_Charge_First_Check__c, Person_in_charge_Menu_Typing__c, Final_Check_Date__c, Menu_Typed_Date__c , IsClosed FROM Case WHERE Id = : caseId LIMIT 1];
            if (moam.get('MarkCompleteBtn').get(theCase.recordtype.developername) != null) {
                mapProcessData = moam.get('MarkCompleteBtn').get(theCase.recordtype.developername);

                System.debug('theCase: ' + theCase);


                Id theId = Id.valueOf(theCase.OwnerId);
                Schema.SObjectType theObjType = theId.getSobjectType();
                String theObjTypeName = theObjType.getDescribe().getName();

                String ownerId = mapProcessData.get('ownerId').Business_Rule_Value__c;

                if (theCase.IsClosed) {
                    listResult.add(Label.Mark_Complete_Case_Closed);
                    return listResult;
                }
                set<string> caseType = new set<string>();
                caseType.addAll( mapProcessData.get('Type').Business_Rule_Value__c.split(','));
                system.debug('casetype' + caseType);
                if (!caseType.contains(theCase.type)) {
                    listResult.add(Label.Mark_Complete_Unsuccessful);
                    return listResult;


                }
                System.debug('theObjTypeName ' + theObjTypeName);
                /* if(theObjTypeName == 'Group' && theId == ownerId ){
                     listResult.add(Label.Level_1_Support_Queue);
                     return listResult;

                 }*/

                if (theObjTypeName == 'Group') {
                    listResult.add(Label.Mark_Complete_Queue);
                    return listResult;

                } else if (theObjTypeName == 'User') {

                    //String ownerId = mapProcessData.get('ownerId').Business_Rule_Value__c;
                    Map<String, String> fieldStatusMap = new Map<String, String>();
                    if (mapProcessData.get('fieldMap') != null)
                        fieldStatusMap = (Map<String, String>)JSON.deserialize(mapProcessData.get('fieldMap').Business_Rule_Value__c, Map<String, String>.class);
                    if (theCase.OwnerId != ownerId && theCase.OwnerId == UserInfo.getUserId() ) {
                        //theCase.OwnerId = ownerId;
                        Database.SaveResult saveResult;
                        Map<string, string> personInchargeTochk = new Map<String, String>();
                        if (mapProcessData.get('chkForPersonInCharge') != null && Boolean.valueOf(mapProcessData.get('chkForPersonInCharge').Business_Rule_Value__c)) {
                            if (mapProcessData.get('personInchargeMap') != null) {
                                personInchargeTochk = (Map<String, String>)JSON.deserialize(mapProcessData.get('personInchargeMap').Business_Rule_Value__c, Map<String, String>.class);

                                if (personInchargeTochk != null && !personInchargeTochk.isEmpty() && personInchargeTochk.containsKey(theCase.status)) {
                                    if (theCase.get(personInchargeTochk.get(theCase.status)) == null) {
                                        listResult.add(theCase.status + ' ' + Label.Mark_Complete_Person);
                                        return listResult;

                                    }
                                }

                            }


                        }
                        if (mapProcessData.get(theCase.type) != null) {
                            if (fieldStatusMap != null && !fieldStatusMap.isEmpty() && fieldStatusMap.containsKey(theCase.status))
                                theCase.put(fieldStatusMap.get(theCase.status), system.now());
                        
                            Map<string,String>  typeStatus = (Map<String, String>)JSON.deserialize(mapProcessData.get(theCase.type).Business_Rule_Value__c, Map<String, String>.class);
                            if(!typeStatus.isEmpty()){
                                if(typeStatus.containskey('FinalStatus') && typestatus.get('FinalStatus')==theCase.Status){
                                    theCase.Status = 'Closed';
                                    theCase.Closed_Reason__c = mapProcessData.get('ClosingReasonPositive').Business_Rule_value__c;
                                    saveResult = Database.update(theCase, true);

                                }else{
                                    if(typeStatus.containsKey(theCase.Status))
                                        theCase.Status = typeStatus.get(theCase.status);
                                        

                                    if (mapProcessData.get(theCase.type + 'NextStatusQueue ' + theCase.status) != null && mapProcessData.get(theCase.type + 'NextStatusQueue ' + theCase.status).Business_Rule_value__c != null ) {
                                        theCase.ownerId = mapProcessData.get(theCase.type + 'NextStatusQueue ' + theCase.status).Business_Rule_value__c;
                                    }
                                    else
                                    theCase.ownerid = ownerId ;
                                }
                                saveResult  = Database.update(theCase, true);
                            }

                        } else {
                            listResult.add(Label.Mark_Complete_Unsuccessful);
                            return listResult;
                        }
                        if (saveResult != null && saveResult.getErrors().isEmpty()) {
                            //backToQueue(theCase.id);
                            listResult.add(Label.Mark_Complete_Success);
                        } else {
                            listResult.add(Label.Mark_Complete_Unsuccessful);
                        }
                    } else {
                        listResult.add(Label.Mark_Complete_NoAccess);
                    }
                }

            } else {
                listResult.add(Label.Mark_Complete_Unsuccessful);

            }
        } catch (Exception e) {
            listResult.add(e.getMessage());
            return listResult;
        }

        return listResult;
    }

    webservice static List<String> createBackendAccountKR(String restaurantName, String salesforceId, String salesRep, String accountType){
        List<String> listResult = new List<String>();
        Boolean profileValid = false;
        /*System.debug('$$$ method started');
        System.debug('$$$ moam : ' + moam);
        System.debug('$$$ moam.get(\'SendToBackendProcess\') '+moam.get('QuoteApprovalProcess'));
        System.debug('query backend : ' + [SELECT Id FROM Business_Config__c WHERE Process_Name__c='SendToBackendProcess'].size());
        System.debug('query approval : ' + [SELECT Id FROM Business_Config__c WHERE Process_Name__c='QuoteApprovalProcess'].size());*/

        Map<String,Business_Config__c> mapProcessData = new Map<String,Business_Config__c>();

        if(!Test.isRunningTest()){
            mapProcessData = moam.get('SendToBackendProcess').get('Yogiyo_Account');
        }else{
            for(Business_Config__c bc : [SELECT Id,Business_Rule_Value__c,Business_Rule_Name__c FROM Business_Config__c WHERE Process_Name__c='SendToBackendProcess']){
                System.debug('config: ' + bc);
                mapProcessData.put(bc.Business_Rule_Name__c,bc);
            }
        }
        



        if(mapProcessData != null){

            if(accountType != mapProcessData.get('allowedAccountType').Business_Rule_Value__c){
                listResult.add(Label.Account_type_not_allowed_for_backend_creation_KR);

                return listResult;
            }

            for(String profile : mapProcessData.get('allowedProfileIds').Business_Rule_Value__c.split(',')){
                System.debug('current profile: ' + Userinfo.getProfileId());
                if(profile == Userinfo.getProfileId() || Test.isRunningTest()){
                    profileValid = true;
                    break;
                }
            }
        

            if(!profileValid){
                listResult.add(Label.Profile_not_allowed_for_backend_creation_KR);

                return listResult;
            }else{

                String backendId = ClsWebserviceCalloutsKR.createBackendAccount(restaurantName, salesforceId, salesRep);

                if(backendId != null){

                    Account theAccount = [SELECT Id, Backend_ID__c FROM Account WHERE Id =: salesforceId LIMIT 1];
                    theAccount.Backend_ID__c = backendId;
                    update theAccount;

                    listResult.add(Label.Successfully_created_in_backend_KR);
                }else{
                    listResult.add(Label.Backend_creation_failed);
                }
            }
        }
        return listResult;
    }
    
    webService static List<String> checkForItemsToTerminate(String accountId){
        List<String> result = new List<String>();

        List<Asset__c> listAssets = [select id,Status__c  from Asset__c where Account__c =:accountId and termination_date__c=null];
        List<Additional_Charges__c> listAddCharge = [select id,termination_date__c from Additional_Charges__c where Id_Account__c =:accountId and termination_date__c=null];
        List<Contract> allContracts = [SELECT Id, ContractNumber, StartDate, End_Date__c, Status, Commission__c, Recurring_Fee__c FROM Contract WHERE AccountId =: accountId AND Status != 'Terminated' ORDER BY StartDate DESC];
        
        if(!listAssets.isEmpty() || !listAddCharge.isEmpty() || !allContracts.isEmpty()){
            result.add('true');
        }else{
            result.add('false');    
        }

        return result;
    }


     webService static List<String> acceptQuote(String quoteId){
        List<String> result = new List<String>();
        System.Savepoint sp = Database.setSavepoint();
        try{
           chkAcceptQuote=true;
            updateOpportunityType(quoteId);
            chkAcceptQuote=false;
            Opportunity_Quote__c quote = [select id,id_opportunity__c,Id_Opportunity__r.type ,status__c from Opportunity_Quote__c where id=:quoteId];
            /*if(quote.Id_Opportunity__r.type==null){
                result.add(Label.Error+' '+Label.OpportunityTypeStageValidation);
                return result;
            }*/
            quote.status__c ='Accepted';
            try{

                update quote;   
            }catch(DmlException e){
                System.debug('Error: '+e.getMessage());
                System.debug('e.getDmlType(0): '+e.getDmlType(0));
                 
                if(e.getDmlType(0)==StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                    if(e.getDmlMessage(0).contains('INSUFFICIENT_ACCESS_OR_READONLY'))
                        result.add(Label.Accept_Quote_Error);
                    else    
                    result.add(Label.Error+' '+e.getDmlMessage(0));
                    Database.rollback(sp);
                    return result;
                }
                result.add(Label.Accept_Quote_Error);
                Database.rollback(sp);
                return result;
            }
            result.add(Label.Opportunity_Quote_Accepted);
            
            return result;
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
            result.add(Label.Accept_Quote_Error);
            Database.rollback(sp); 
            return result;
        }

    }

    /*
        SP-581 approval for ME
    */

    webService static List<String> approveQuote(String quoteId) {
        List<String> result = new List<String>();
        System.Savepoint sp = Database.setSavepoint();

        Boolean updateOpp = false;
        try {

            updateOpportunityType(quoteId);
            Opportunity_Quote__c quote = [select id, RecordType.DeveloperName, id_opportunity__c, Id_Opportunity__r.type, Id_Opportunity__r.Record_Country__c , status__c, Approval_L1__c, Approval_L2__c from Opportunity_Quote__c where id = :quoteId];

            Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('QuoteApprovalProcess');
            system.debug('*mapBusinessLogic ' + mapBusinessLogic + quote  );
            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(quote.RecordType.DeveloperName);
            Map<String,Map<String,OpportunityTeamMember>>mapOppTeam = LibBusinessConfig.determineApproverMap(quote.id_opportunity__c);


            Map<String, OpportunityTeamMember> mapApprovalEntriesLevel1 = mapOppTeam.get('HOS');
            Map<String, OpportunityTeamMember>  mapApprovalEntriesLevel2 = mapOppTeam.get('Legal');
            Map<String, OpportunityTeamMember>  mapApprovalEntriesLevel3 = mapOppTeam.get('Regional HOS');

            if (mapBusinessRules != null && !mapBusinessRules.isEmpty() &&
                    mapBusinessRules.get('level1ApprovedStatus').Business_Rule_Value__c != null &&
                    quote.status__c != mapBusinessRules.get('level1ApprovedStatus').Business_Rule_Value__c &&
                    (quote.status__c == mapBusinessRules.get('initialStatusLevel1').Business_Rule_Value__c || (mapBusinessRules.get('initialStatusLevel3') != null && quote.status__c == mapBusinessRules.get('initialStatusLevel3').Business_Rule_Value__c) )) {
                //Stage1 approval

                //if(quote.Approver_L2__c == null){ //no level 2 approval
                if (quote.Approval_L2__c == false) { //no level 2 approval
                    quote.Status__c = mapBusinessRules.get('finalApprovalStatus').Business_Rule_Value__c;
                    updateOpp = true;
                } else {
                    quote.status__c = mapBusinessRules.get('level1ApprovedStatus').Business_Rule_Value__c;
                    updateOpp = true;
                }



            } else if (mapBusinessRules != null &&
                       !mapBusinessRules.isEmpty() &&
                       quote.status__c == mapBusinessRules.get('level1ApprovedStatus').Business_Rule_Value__c &&
                       (mapApprovalEntriesLevel1!=null && mapApprovalEntriesLevel1.keySet().contains(Userinfo.getUserId()) || (mapApprovalEntriesLevel3 != null && !mapApprovalEntriesLevel3.isEmpty() && mapApprovalEntriesLevel3.keySet().contains(Userinfo.getUserId()) )) && !mapApprovalEntriesLevel2.keySet().contains(Userinfo.getUserId())) {
                //quote.Approver_L1__c == Userinfo.getUserId() && quote.Approver_L2__c != Userinfo.getUserId()){

                result.add(Label.Opportunity_Quote_Approved_Already);
                return result;
            } else if (mapBusinessRules != null &&
                       !mapBusinessRules.isEmpty() &&
                       quote.status__c != mapBusinessRules.get('level2ApprovedStatus').Business_Rule_Value__c &&
                       quote.status__c == mapBusinessRules.get('level1ApprovedStatus').Business_Rule_Value__c) {

                quote.status__c = mapBusinessRules.get('level2ApprovedStatus').Business_Rule_Value__c;
                updateOpp = true;

            } else if (mapBusinessRules != null && !mapBusinessRules.isEmpty() && quote.status__c == mapBusinessRules.get('level2ApprovedStatus').Business_Rule_Value__c) {
                result.add(Label.Opportunity_Quote_Approved_Already);
                return result;
            }
            try {

                update quote;

                if (updateOpp) {
                    Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = : quote.Id_Opportunity__c LIMIT 1];

                    if (quote.Status__c == mapBusinessRules.get('level1ApprovedStatus').Business_Rule_Value__c ) {
                        opp.StageName = mapBusinessRules.get('pushStageNameAfterLevel1Approval').Business_Rule_Value__c;
                        //ClsEmailProcessor.notifyApprover(quote.Approver_L2__c, quote.RecordType.DeveloperName, quote.Id);
                        if(LibBusinessConfig.determineApprover(quote.Id_Opportunity__r.Record_Country__c,'Legal' )!=null && LibBusinessConfig.determineApprover(quote.Id_Opportunity__r.Record_Country__c,'Legal' ).Notification__C)
                            ClsEmailProcessor.notifyApprovers(mapApprovalEntriesLevel2.values(), quote.RecordType.DeveloperName, quote.Id);

                    } else if (mapBusinessRules.get('level2ApprovedStatus') != null && quote.Status__c == mapBusinessRules.get('level2ApprovedStatus').Business_Rule_Value__c) {
                        opp.StageName = mapBusinessRules.get('pushStageNameAfterLevel2Approval').Business_Rule_Value__c;
                    } else if (  mapBusinessRules.get('finalApprovalStatus').Business_Rule_Value__c != null && quote.Status__c == mapBusinessRules.get('finalApprovalStatus').Business_Rule_Value__c) {
                        opp.StageName = mapBusinessRules.get('pushStageNameAfterFinalApproval').Business_Rule_Value__c;
                    }

                    update opp;
                }


            } catch (DmlException e) {
                System.debug('Error: ' + e.getMessage());
                System.debug('e.getDmlType(0): ' + e.getDmlType(0));

                if (e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                    result.add(Label.Error + ' ' + e.getDmlMessage(0));
                    Database.rollback(sp);
                    return result;
                }
                result.add(Label.Error + ' ' + e.getMessage());
                Database.rollback(sp);
                return result;
            }
            result.add(Label.Opportunity_Quote_Approved);
            return result;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString());
            result.add(Label.Error + ' ' + e.getMessage());
            Database.rollback(sp);
            return result;
        }

    }

    

    webService static List<String> rejectQuote(String quoteId) {
        List<String> result = new List<String>();
        System.Savepoint sp = Database.setSavepoint();



        try {

            updateOpportunityType(quoteId);
            Opportunity_Quote__c quote = [select id, Id_Opportunity__r.OwnerId, RecordType.DeveloperName, id_opportunity__c, Approval_L2__c, Approval_L1__c , Id_Opportunity__r.Record_Country__c, Id_Opportunity__r.type , status__c from Opportunity_Quote__c where id = :quoteId];
            /*if(quote.Id_Opportunity__r.type==null){
                result.add(Label.Error+' '+Label.OpportunityTypeStageValidation);
                return result;
            }*/

            Map<String,Map<String,OpportunityTeamMember>>mapOppTeam = LibBusinessConfig.determineApproverMap(quote.id_opportunity__c);


            Map<String, OpportunityTeamMember> mapApprovalEntriesLevel1 = mapOppTeam.get('HOS');
            Map<String, OpportunityTeamMember>  mapApprovalEntriesLevel2 = mapOppTeam.get('Legal');
            Map<String, OpportunityTeamMember>  mapApprovalEntriesLevel3 = mapOppTeam.get('Regional HOS');
            quote.status__c = 'Rejected';
            Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = : quote.Id_Opportunity__c LIMIT 1];

            Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('QuoteApprovalProcess');
            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(quote.RecordType.DeveloperName);

            //if(quote.Approver_L1__c == UserInfo.getUserId()){
            if (mapApprovalEntriesLevel1!=null && mapApprovalEntriesLevel1.keySet().contains(UserInfo.getUserId()) || (mapApprovalEntriesLevel3 != null && !mapApprovalEntriesLevel3.isEmpty() && mapApprovalEntriesLevel3.keySet().contains(UserInfo.getUserId()))) {
                opp.StageName = mapBusinessRules.get('pushStageNameAfterLevel1Rejection').Business_Rule_Value__c;
            }

            //if(quote.Approver_L2__c == UserInfo.getUserId()){
            if (mapApprovalEntriesLevel2!=null && mapApprovalEntriesLevel2.keySet().contains(UserInfo.getUserId())) {
                opp.StageName = mapBusinessRules.get('pushStageNameAfterLevel2Rejection').Business_Rule_Value__c;
            }

            try {

                update quote;
                update opp;
                ClsEmailProcessor.sendRejectionNotification(quote.Id_Opportunity__r.OwnerId, quote.RecordType.DeveloperName, quote.Id);
            } catch (DmlException e) {
                System.debug('Error: ' + e.getMessage());
                System.debug('e.getDmlType(0): ' + e.getDmlType(0));

                if (e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                    result.add(Label.Error + ' ' + e.getDmlMessage(0));
                    Database.rollback(sp);
                    return result;
                }
                result.add(Label.Error + ' ' + e.getMessage());
                Database.rollback(sp);
                return result;
            }
            result.add(Label.Opportunity_Quote_Rejected);
            return result;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            result.add(Label.Error + ' ' + e.getMessage());
            Database.rollback(sp);
            return result;
        }

    }

    webService static List<String> cancelAssetAdditionalCharges(String assetId){
        List<String> result = new List<String>();
        try{
            Asset__c Assetrec = [select id,Status__c,termination_date__c  from Asset__c where Id =:assetId];
            if(Assetrec.termination_date__c==null){
                Assetrec.status__c = 'Cancellation - To Collect';
                Assetrec.termination_date__c = Date.today();
                update Assetrec;
                
                List<Additional_Charges__c> listAddCharge = [select id,termination_date__c from Additional_Charges__c where Id_Asset__c =:assetId and termination_date__c=null];
                for(Additional_Charges__c addch : listAddCharge){
                        addch.termination_date__c = Date.today();
                }
                update listAddCharge;
                result.add(Label.Asset_terminated_successfully);
            }else{
                result.add(Label.Asset_terminated_already);
            }
            return result;

        }catch(Exception e){
            result.add(Label.Error+' '+e.getMessage());
            System.debug('Error: '+e.getMessage());
            return result;
        }
    }

    public static List<String> cancelAllAssetAdditionalCharges(String accountId){
        List<String> result = new List<String>();
        try{
            List<Asset__c> listAssets = [select id,Status__c  from Asset__c where Account__c =:accountId and termination_date__c=null];
            for(Asset__c asst : listAssets){
                asst.status__c = 'Cancellation - To Collect';
                asst.termination_date__c = Date.today();
            }
            update listAssets;

            List<Additional_Charges__c> listAddCharge = [select id,termination_date__c from Additional_Charges__c where Id_Account__c =:accountId and termination_date__c=null];
            for(Additional_Charges__c addch : listAddCharge){
                addch.termination_date__c = Date.today();
            }
            update listAddCharge;
            result.add(Label.Asset_terminated_successfully);
            return result;
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
            result.add(Label.Error+' '+e.getMessage());
            return result;
        }
    }




    /*webService static list<String> qualityCheck(String oppId){
        List<String> result = new List<String>();
        System.Savepoint sp = Database.setSavepoint();
        try{

            Opportunity opp = [select name,RecordType.DeveloperName,stageName,Probability from Opportunity where id =: oppId];
            //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('QualityCheckButton');
            Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('QualityCheckButton');
            Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(opp.RecordType.DeveloperName);
            if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){

                Boolean permittedUserProfile = false;
                String currentUserProfile = UserInfo.getProfileId();
                List<String> listPermittedProfileNames = mapBusinessRules.get('permittedProfiles').Business_Rule_Value__c.trim().split(',');
                String currentUserProfileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() ].Name;
                
                for(String profileName : listPermittedProfileNames){
                    if (profileName == currentUserProfileName){
                        permittedUserProfile = true;
                        system.debug('@@@@ permittedUserProfile : '+ permittedUserProfile);
                        break;
                    }
                }


                if(permittedUserProfile){
                    opp.Quality_Check__c = Date.today(); 
                    opp.Quality_Check_By__c = UserInfo.getUserId(); 
                    opp.StageName = mapBusinessRules.get('set StageName').Business_Rule_Value__c;
                    opp.Probability = Decimal.valueOf(mapBusinessRules.get('set Probability').Business_Rule_Value__c);

                    update opp;
                    result.add(Label.Quality_Checked);
                    system.debug('@@@Opportunity updated');
                    if(Boolean.valueOf(mapBusinessRules.get('createAsset').Business_Rule_Value__c)){
                        result.add(createAssets(opp,mapBusinessRules));
                        system.debug('@@@Asset Created');
                    }   
                }else{
                    result.add(Label.QualityCheckProfileIsNotPermitted);
                    system.debug('@@@Label.QualityCheckProfileIsNotPermitted');
                }
                system.debug('@@@ result : ' + result);
                return result;
            }else{
                result.add(Label.QualityCheckButton_Business_validation);
                System.debug('Result : ' + Label.QualityCheckButton_Business_validation+'  :  ' +opp.RecordType.DeveloperName);
                return result;
            }
            }catch(Exception e){
                if(e.getTypeName()=='DmlException' && e.getDmlType(0)==StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                    result.add(Label.Error+' '+e.getDmlMessage(0));
                    return result;
                }
                result.add(Label.Error+' '+e.getMessage());
                System.debug('Error: '+e.getMessage());
                Database.rollback(sp); 
                return result;
            }

    }

    private static String createAssets(Opportunity processOpp, Map<String,Business_Config__c> mapBusinessRules){
    String result = Label.Assets_created;
    try{
            List<Opportunity_Quote__c> opquote = [SELECT Id, Name, Id_Account__c, Status__c, Id_Opportunity__c, RecordType.DeveloperName 
                    FROM Opportunity_Quote__c 
                    WHERE Id_Opportunity__c =:processOpp.id 
                    AND Status__c='Accepted' limit 1];
            if(opquote.isEmpty()){
                result = Label.No_Accepted_Quote;
                return result;

            }
            List<Asset__c> listAssets = new List<Asset__c>();
            Map<Id,Opportunity_Quote_Line_Item__c> mapOppQuoteProd = new Map<Id,Opportunity_Quote_Line_Item__c>([select (select name,Account__c,CurrencyIsoCode,RecordTypeId,Id_Opportunity_Quote_Line_Item__c,Opportunity__c,Status__c from Assets__r),id, name,CurrencyIsoCode,Id_List_Product_Price__r.Requires_Asset__c,Has_Related_Tarif__c,Id_List_Product_Price__c,Installments__c,Listed_Price__c,
                                                        Id_Opportunity_Quote__c,Id_Opportunity_Quote__r.Id_Account__c,Id_Opportunity__c,Quantity__c
                                                            from Opportunity_Quote_Line_Item__c where Id_Opportunity_Quote__c =:opquote[0].id and Line_Item_type__c='Product']);
            for(Opportunity_Quote_Line_Item__c qq1 : mapOppQuoteProd.values()){
                if(qq1.Id_List_Product_Price__r.Requires_Asset__c){
                    System.debug('qq1.Assets__r: '+qq1.Assets__r);
                    if(qq1.Assets__r==null || qq1.Assets__r.isEmpty()){
                        if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){
                            Boolean createAsset = true;
                            if(mapBusinessRules.get('createAsset')!=null)
                                createAsset = Boolean.valueOf(mapBusinessRules.get('createAsset').Business_Rule_Value__c);
                            if(createAsset){
                                for(integer i=1; i<=qq1.Quantity__c; i++  ){
                                            Asset__c newAsset = new Asset__c();
                                            newAsset.name = qq1.name;
                                            newAsset.Account__c = qq1.Id_Opportunity_Quote__r.Id_Account__c;
                                            newAsset.CurrencyIsoCode = qq1.CurrencyIsoCode;
                                            newAsset.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('Asset RecordType').Business_Rule_Value__c);
                                            //newAsset.Is_Active__c = false;
                                            newAsset.Id_Opportunity_Quote_Line_Item__c = qq1.Id;
                                            newAsset.Opportunity__c = qq1.Id_Opportunity__c;
                                            newAsset.Status__c = mapBusinessRules.get('Asset Status__c').Business_Rule_Value__c;
                                            listAssets.add(newAsset);
                                }
                            }
                        }
                    }
                }
            }
            insert listAssets;
                        
        }catch(Exception e){
            result = ' '+Label.Error+' '+e.getMessage();
            System.debug('Error: '+e.getMessage());
        }
        return result;
    }*/


    public static String updateOpportunityType(String sObId){
        System.debug('@@@@ updateOpportunityType sObId: ' + sObId);
        String result = '';
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('OppTypeAndServiceType');
        Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('OppTypeAndServiceType');
        Schema.SObjectType token = Id.valueOf(sObId).getSObjectType();
        Opportunity updateOpp;
        String OppType;
        Set<String> ServiceType = new Set<String>();
        Boolean isProduct = false;
        Boolean isAdditional = false;
        Boolean isOtherService = false;
        Boolean isRecurringCharge = false;
        Boolean isAdSales = false;
        Boolean isSplOffer = false;
        skipOppUpd=false;
        String recordTypeName;
        Map<String, String> recurringChargeTypes;
        String nonStandardComponents;
        String accountId;
        //List<Opportunity_Tarif_Item__c> oppTarif;
         Opportunity opp;

        try{
            if(token == Opportunity.getSObjectType()){
                 //oppTarif = [select name from Opportunity_Tarif_Item__c where Id_Opportunity__c=:sObId limit 1];
                opp = [select RecordType.DeveloperName,Id_Tarif__c,Id_Tarif__r.name,Type,(select Id_List_Price_Product__r.Product_Type__c,Line_Item_type__c,sub_Type__c from Opportunity_Line_Items__r) from Opportunity where id=:sObId];
                recurringChargeTypes =  getRecurringFeeTypes(opp.RecordType.DeveloperName);
                for(Opportunity_Line_Item__c oli : opp.Opportunity_Line_Items__r){
                    if(oli.Line_Item_type__C=='Service'){
                        if(oli.Line_Item_type__c=='Service' && oli.sub_Type__c!=null){
                            ServiceType.add(oli.Sub_Type__c);
                        }else{
                            isOtherService = true;
                        }
                    }
                    else{
                        if(/*oli.Ad_Sales_Type__c!=null*/ oli.sub_Type__c=='Ad Sales'){
                            isAdSales = true;
                        }else if(oli.sub_Type__c==Label.CD_Special_Offer){
                            isSplOffer = true;
                            // skipOppUpd=true;
                            isProduct = true;
                        }else if(oli.Id_List_Price_Product__r.Product_Type__c != null && recurringChargeTypes.get(oli.Id_List_Price_Product__r.Product_Type__c) != null){
                            isRecurringCharge = true;
                        } else {
                            isProduct = true;
                        }

                    }
                }
                /*if(!opp.Opportunity_Product_Items__r.isEmpty()){
                    //isProduct = true;
                    for(Opportunity_Product_Item__c opi : opp.Opportunity_Product_Items__r){
                        if(opi.Ad_Sales_Type__c!=null){
                            isAdSales = true;
                        }else if(opi.Id_List_Price_Product__r.Product_Type__c != null && recurringChargeTypes.get(opi.Id_List_Price_Product__r.Product_Type__c) != null){
                            isRecurringCharge = true;
                        } else {
                            isProduct = true;
                        }
                    }
                }*/
                recordTypeName = opp.RecordType.DeveloperName;
                updateOpp = new Opportunity(Id=opp.Id,Type=opp.Type);

            }else if(token == Opportunity_Quote__c.getSObjectType()){
                Opportunity_Quote__c oppQuote = [SELECT id,Id_Opportunity__c,Id_Opportunity__r.Type,Non_Standard_Contract_Components__c,Id_Account__c,Id_Opportunity__r.RecordType.DeveloperName, (select id, Line_Item_type__c, Sub_Type__c from Opportunity_Quote_Line_Items__r) FROM Opportunity_Quote__c WHERE id =:sObId];
                recurringChargeTypes =  getRecurringFeeTypes(oppQuote.Id_Opportunity__r.RecordType.DeveloperName);
                if(!oppQuote.Opportunity_Quote_Line_Items__r.isEmpty()){
                    for(Opportunity_Quote_Line_Item__c oqpi : oppQuote.Opportunity_Quote_Line_Items__r){
                        if(oqpi.Line_Item_type__c=='Product'){
                            if(oqpi.Sub_Type__c!=null && oqpi.Sub_Type__c=='Ad Sales'){
                                isAdSales = true;
                            }else if(oqpi.sub_Type__c==Label.CD_Special_Offer){
                                isSplOffer = true;
                                //skipOppUpd=true;
                                isProduct = true;
                            }
                            else if(oqpi.Sub_Type__c != null && recurringChargeTypes.get(oqpi.Sub_Type__c) != null){
                                isRecurringCharge = true;
                            } else {
                                isProduct = true;
                            }
                        }else if(oqpi.Line_Item_type__c=='Service'){
                            if(oqpi.Sub_Type__c!=null){
                                ServiceType.add(oqpi.Sub_Type__c);   
                            }else{
                                isOtherService = true;
                            }
                        }
                        
                    }
                }
                recordTypeName = oppQuote.Id_Opportunity__r.RecordType.DeveloperName;
                updateOpp = new Opportunity(Id=oppQuote.Id_Opportunity__c,Type=oppQuote.Id_Opportunity__r.Type);
                nonStandardComponents = oppQuote.Non_Standard_Contract_Components__c;
                accountId=oppQuote.id_account__C;
            }
            Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(recordTypeName);
            if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){
                

                
                String additionalValue = mapBusinessRules.get('Additional Contract').Business_Rule_Value__c;
                set<String> additionalContract =  new Set<String>();

                if(additionalValue.indexOf(',') > -1){
                    additionalContract.addAll(additionalValue.split(','));
                }else{
                     additionalContract.add(additionalValue); 
                }
                if(mapBusinessRules.get('AdSales Tarif')!=null){
                    String adSalesTarifName = mapBusinessRules.get('AdSales Tarif').Business_Rule_Value__c;
                    if(opp.Id_Tarif__c!=null && opp.Id_Tarif__r.name.equalsIgnoreCase(adSalesTarifName)){
                        isAdSales = true;
                    }
                }
                System.debug('isProduct: '+isProduct);
                System.debug('ServiceType.isEmpty(): '+ServiceType.isEmpty());
                System.debug('isOtherService: '+isOtherService);
                System.debug('isOtherService: '+isOtherService);
                system.debug('servicetype: '+ServiceType);
                system.debug('additionalContract :'+additionalContract);
                system.debug(isSplOffer);
                
                if(isAdSales){
                    OppType = 'AdSales';
                }else if(isSplOffer && mapBusinessRules.get('SplOffer')!=null && Boolean.valueof(mapBusinessRules.get('SplOffer').Business_Rule_Value__c)){
                    oppType= Label.CD_Special_Offer_OppType;
                }else if(isRecurringCharge && !isProduct && ServiceType.isEmpty() && !isOtherService){
                    OppType = 'Administration';
                } else if(isProduct && !ServiceType.isEmpty() && !additionalContract.containsAll(ServiceType)){
                    OppType = 'Contract & Product';
                }else if(isProduct && ServiceType.isEmpty() && isOtherService ){
                    OppType = 'Contract & Product';
                }else if(isProduct && ServiceType.isEmpty()){
                    OppType = 'Product Only';
                }else {
                    for(String ss : ServiceType){
                        if(additionalContract.contains(ss)){
                            isAdditional = true;
                        }else{
                            isOtherService = true;
                        }
                    }
                    if(isAdditional && isOtherService){
                        OppType = 'Contract Only';
                    }else if(isAdditional && !isOtherService){
                        OppType = 'Additional Contract';
                    }else if(isOtherService){
                        OppType = 'Contract Only';
                    }
                }
                
                System.debug('OppType: '+OppType);
                if(OppType!=null){
                    //if(updateOpp.type!=null  && updateOpp.type!=OppType){
                        updateOpp.type = OppType;
                        update updateOpp;
                    /*}else if(updateOpp.type==null){
                        updateOpp.type = OppType;
                        update updateOpp;
                    }*/
                    
                }
                

            }
        }catch(Exception e){
            result = ' ' + Label.Error + ' ' + e.getMessage();
            System.debug('Error - result: ' + e.getMessage());
            System.debug('Error: ' + e.getCause());
        }
        
        return result;
    }

    private static Map<String, String> getRecurringFeeTypes(String recordTypeName){
        Map<String, String> recurringChargeType = new Map<String, String>();
        //Map<String,Map<String,Business_Config__c>> mapProcessData= LibBusinessConfig.getGenericProcessData('addOpportunityLineItems');
        Map<String,Map<String,Business_Config__c>> mapProcessData= moam.get('addOpportunityLineItems');
        Map<String,Business_Config__c> mapBusinessData = mapProcessData.get(recordTypeName);
        if(mapBusinessData!=null && !mapBusinessData.isEmpty()){
            if(mapBusinessData.get('recurringFee') != null && String.isNotBlank(mapBusinessData.get('recurringFee').Business_Rule_Value__c)){
                for(String str : mapBusinessData.get('recurringFee').Business_Rule_Value__c.split(',')){
                    recurringChargeType.put(str, str);
                }
            }
        }
        return recurringChargeType;
    }

    /*global static List<String> sendEmail(Id oppId){
            List<String> result = new List<String>();
            List<OpportunityContactRole> listContact = [SELECT Id,contactid,contact.email, Role, IsPrimary FROM OpportunityContactRole Where OpportunityId=:oppId];
            List<Messaging.SingleEmailMessage> listMySend = new List<Messaging.SingleEmailMessage>();
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>();
            if(!listContact.isEmpty()){
                for(OpportunityContactRole c : listContact){
                    if(c.contact.email!=null){
                        toAddresses.add(c.contact.email); 
                    }  
                }
                mail.setTargetObjectId(listContact[0].contactid);
            }else{
                result.add('No Opportunity contact role');
                return result;
            }
            System.debug('toAddresses: '+toAddresses);
            mail.setToAddresses(toAddresses);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);
            mail.setTemplateId('00X11000000IFUXEA4');
            if(!toAddresses.isEmpty()){
                listMySend.add(mail);
                Messaging.sendEmail(listMySend);
                result.add('Email sent to customer.');
                return result;
            }else{

                result.add('No email address for the Opportunity contact role');
                return result;
            }
    }*/


    /*webservice static String calculateSalesTarget(List<Id> ids){
        Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('SalesTargetProcess');
        Map<Id,List<Sales_Target__c>> mapUserSTarget = new Map<Id,List<Sales_Target__c>>();
        String result; 
        System.debug('ids: '+ids);
        try{
            
            if(ids!=null && ids.size() > 10){
               List<AsyncApexJob> currentJob =  [SELECT ApexClass.name,CompletedDate,CreatedDate,Id,JobItemsProcessed,JobType,MethodName,Status,TotalJobItems FROM AsyncApexJob where JobType='BatchApex' and ApexClass.name='BatchSalesTarget' and Status!='Completed' limit 1];
                if(currentJob!=null && currentJob.size()==1){
                    system.debug('currentJob not null');
                    return 'The Batch for calculating Sales target is in progress!';
                }else{
                    BatchSalesTarget bt = new BatchSalesTarget(ids);
                    ID batchprocessid = Database.executeBatch(bt);
                    system.debug('currentJob ' + batchprocessid );
                    return 'A batch execution has been initiated. The data update process will take around 10 to 30 mins to finish.';
                }
            }else{
                for(Sales_Target__c st : [Select Id,RecordType.developerName,NoOfCommissionInPercent__c,TotalCommissionForAvgCal__c,Name,Business_Type__c,Product_Group__c,Closed_Deals__c,Commission_Target__c,From__c,Product_Target__c,Revenue_Achieved__c,Sales_Rep__c,Target_Deals__c,Target_Product_Name__c,Target_Revenue__c,Target_Units__c,To__c,Type__c,Units_Achieved__c 
                from Sales_Target__c where Id in : ids]){
                    st.Revenue_Achieved__c = null;
                    st.Closed_Deals__c=null;
                    st.Units_Achieved__c = null;
                    st.TotalCommissionForAvgCal__c = null;
                    if(mapUserSTarget.get(st.Sales_Rep__c)==null){
                        mapUserSTarget.put(st.Sales_Rep__c,new List<Sales_Target__c>{st});
                        system.debug('mapUserSTarget  ' + mapUserSTarget);
                    }else{
                        List<Sales_Target__c> lis = mapUserSTarget.get(st.Sales_Rep__c);
                        lis.add(st);
                        mapUserSTarget.put(st.Sales_Rep__c,lis);
                        system.debug('mapUserSTarget 2 ' + mapUserSTarget);
                    }
                }
                processSalesTarget(mapUserSTarget,mapBusinessLogic);
            }
            
        }catch(Exception e){
            System.debug('error: '+e.getStackTraceString()+' : '+e.getMessage());
            return 'error: '+e.getMessage();
        }
        return 'success';
    }


    public static void processSalesTarget(Map<Id,List<Sales_Target__c>> mapUserSTarget,Map<String,Map<String,Business_Config__c>> mapBusinessLogic){
        Map<id,String> oppStageMap = new Map<Id,String>();
        //List<Sales_Target__c> updateSalesTrgt = new List<Sales_Target__c>();
        Map<Id,Sales_Target__c> updateSalesTrgtMap = new Map<Id,Sales_Target__c>();
        Map<Id,Opportunity_Quote__c> updateOppQuoteMap = new Map<Id,Opportunity_Quote__c>();
        Map<String,Id> oppIdWithProductId =  new Map<String,Id>();
        
        if(mapBusinessLogic!=null && !mapBusinessLogic.isEmpty()){
            for(Opportunity_Quote_Line_Item__c oppQLines : [SELECT Id_Opportunity__c,Id_Opportunity_Quote__c,Id_Opportunity__r.CloseDate,Id_Opportunity_Quote__r.SalesCloseDate__c,Id_Opportunity__r.ownerid,Id_Opportunity__r.StageName,Id_Opportunity__r.RecordTypeId,Id_Opportunity__r.Is_DataLoaded__c,Id_Opportunity__r.Business_Type__c,Id_Opportunity__r.Type, Category__c,Commission_Type__c,Id_List_Product_Price__c,Id_List_Product_Price__r.Id_List_Product_Group__c,Id_List_Service_Price__c,Line_Item_Type__c,Product_Group__c,Sub_type__c,Quantity__c,Total_Amount__c,Id_Opportunity_Quote__r.lastModifiedDate,Commission_In_Percentage__c FROM Opportunity_Quote_Line_Item__c where Id_Opportunity_Quote__r.Status__c='Accepted' and Id_Opportunity__r.ownerid in : mapUserSTarget.keySet()]){
                if(!oppQLines.Id_Opportunity__r.Is_DataLoaded__c){
                    String stage;
                    Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(oppQLines.Id_Opportunity__r.RecordTypeId));
                    set<string> stageNameSet = new Set<string>();
                    if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){

                        if(oppStageMap.get(oppQLines.Id_Opportunity__c)==null){

                            if(oppQLines.Id_Opportunity__r.Type=='Contract & Product' || oppQLines.Id_Opportunity__r.Type=='Additional Contract' || oppQLines.Id_Opportunity__r.Type=='Contract Only' ){
                                if(mapBusinessRules.get('Service_Stage')!=null){
                                    oppStageMap.put(oppQLines.Id_Opportunity__c,mapBusinessRules.get('Service_Stage').Business_Rule_Value__c);
                                }
                            }else if(oppQLines.Id_Opportunity__r.Type=='Product Only' || oppQLines.Id_Opportunity__r.Type=='AdSales'){
                                if(mapBusinessRules.get('Product_Stage')!=null){
                                    oppStageMap.put(oppQLines.Id_Opportunity__c,mapBusinessRules.get('Product_Stage').Business_Rule_Value__c);
                                }
                            }

                        }
                        stage =  oppStageMap.get(oppQLines.Id_Opportunity__c);
                        //System.debug('oppQLines.Id_Opportunity__r.stageName.: '+oppQLines.Id_Opportunity__r.stageName);
                        if((stage == oppQLines.Id_Opportunity__r.stageName || oppQLines.Id_Opportunity__r.stageName=='Closed Won' || (oppQLines.Id_Opportunity__r.stageName=='Closed Lost' && oppQLines.Id_Opportunity_Quote__r.SalesCloseDate__c!=null)) && mapUserSTarget.containsKey(oppQLines.Id_Opportunity__r.ownerid)){
                            for(Sales_Target__c st : mapUserSTarget.get(oppQLines.Id_Opportunity__r.ownerid)){
                                Date dateCheck;
                                if(oppQLines.Id_Opportunity__r.stageName!='Closed Won' && oppQLines.Id_Opportunity_Quote__r.SalesCloseDate__c!=null){
                                    dateCheck = oppQLines.Id_Opportunity_Quote__r.SalesCloseDate__c;
                                }else if(oppQLines.Id_Opportunity__r.stageName!='Closed Won' && oppQLines.Id_Opportunity_Quote__r.SalesCloseDate__c==null){
                                    dateCheck = (oppQLines.Id_Opportunity_Quote__r.lastModifiedDate).date();
                                    updateOppQuoteMap.put(oppQLines.Id_Opportunity_Quote__c,new Opportunity_Quote__c(Id=oppQLines.Id_Opportunity_Quote__c,SalesCloseDate__c=dateCheck));
                                }else if(oppQLines.Id_Opportunity__r.stageName=='Closed Won' && oppQLines.Id_Opportunity_Quote__r.SalesCloseDate__c!=null){
                                    dateCheck = oppQLines.Id_Opportunity_Quote__r.SalesCloseDate__c;
                                }else if(oppQLines.Id_Opportunity__r.stageName=='Closed Won'){
                                    dateCheck = oppQLines.Id_Opportunity__r.CloseDate;
                                }
                                if(dateCheck >= st.From__c &&  dateCheck <= st.To__c){
                                    Boolean conditionMet = false;
                                    if(st.Type__c=='Product' && oppQLines.Id_List_Product_Price__c!=null){
                                        if(st.Product_Group__c!=null && st.Product_Group__c==oppQLines.Id_List_Product_Price__r.Id_List_Product_Group__c){
                                            conditionMet = true;
                                        }else if(st.Product_Group__c==null && st.Product_Target__c!=null  && oppQLines.Id_List_Product_Price__c==st.Product_Target__c){
                                            conditionMet = true;
                                        }else if(st.Product_Group__c==null && st.Product_Target__c==null ){
                                            conditionMet = true;
                                        }

                                        if(conditionMet){
                                            String keyElements = oppQLines.Id_Opportunity__c+''+st.Product_Target__c+''+st.Product_Group__c; 
                                            if(oppQLines.Quantity__c!=null){
                                                if(st.Units_Achieved__c==null)
                                                    st.Units_Achieved__c = oppQLines.Quantity__c;
                                                else
                                                    st.Units_Achieved__c += oppQLines.Quantity__c;
                                            }
                                            if(oppQLines.Total_Amount__c!=null){
                                                if(st.Revenue_Achieved__c==null)
                                                    st.Revenue_Achieved__c = oppQLines.Total_Amount__c;
                                                else
                                                    st.Revenue_Achieved__c += oppQLines.Total_Amount__c;
                                            }
                                            if(oppIdWithProductId.get(keyElements)==null){
                                                if(st.Closed_Deals__c==null)
                                                    st.Closed_Deals__c = 1;
                                                else
                                                    st.Closed_Deals__c += 1; 
                                                oppIdWithProductId.put(keyElements,oppQLines.Id_Opportunity__c);
                                            }
                                            //updateSalesTrgt.add(st);
                                            updateSalesTrgtMap.put(st.Id,st); 
                                        }
                                    }else if(st.Type__c=='Service'){
                                        if(st.Business_Type__c!=null && st.Business_Type__c==oppQLines.Id_Opportunity__r.Business_Type__c && st.Commission_Target__c==null){
                                            conditionMet = true;
                                        }else if(st.Business_Type__c!=null && st.Business_Type__c==oppQLines.Id_Opportunity__r.Business_Type__c && st.Commission_Target__c!=null && st.Commission_Target__c==oppQLines.Id_List_Service_Price__c){
                                            conditionMet = true;
                                        }else if(st.Business_Type__c==null && st.Commission_Target__c!=null && st.Commission_Target__c==oppQLines.Id_List_Service_Price__c){
                                            conditionMet = true;
                                        }else if(st.Business_Type__c==null && st.Commission_Target__c==null){
                                            conditionMet = true;
                                        }
                                        if(conditionMet){
                                           if(st.Closed_Deals__c==null)
                                                st.Closed_Deals__c = 1;
                                           else
                                                st.Closed_Deals__c += 1;
                                                
                                           if(oppQLines.Commission_In_Percentage__c!=null && oppQLines.Commission_In_Percentage__c > 0){
                                                if(st.NoOfCommissionInPercent__c!=null){
                                                    st.NoOfCommissionInPercent__c += 1;
                                                }else{
                                                    st.NoOfCommissionInPercent__c = 1;
                                                }
                                                if(st.TotalCommissionForAvgCal__c!=null){
                                                    st.TotalCommissionForAvgCal__c += oppQLines.Commission_In_Percentage__c;
                                                }else{
                                                    st.TotalCommissionForAvgCal__c = oppQLines.Commission_In_Percentage__c;
                                                }
                                            }
                                            //updateSalesTrgt.add(st); 
                                            updateSalesTrgtMap.put(st.Id,st); 
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //update updateSalesTrgt;
            update updateSalesTrgtMap.values();
            update updateOppQuoteMap.values();
            System.debug('updateSalesTrgt Batch: '+updateSalesTrgtMap.size());
        }
    }*/
}