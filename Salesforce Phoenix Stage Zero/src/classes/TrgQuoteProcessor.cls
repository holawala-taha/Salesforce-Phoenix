public with sharing class TrgQuoteProcessor {
    private static Boolean linkingAssetFlag = false;
    private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

    public static void quoteAcceptAndDecline(List<Opportunity_Quote__c> newList, Map<Id,Opportunity_Quote__c> oldMap){

        Map<Id,Opportunity_Quote__c> mapQuotes = new Map<Id,Opportunity_Quote__c>();
        Set<Id> setOpportuintyIds = new Set<Id>();
        Map<id,Opportunity_Quote__c > oppQuoteMap = new Map<id,Opportunity_Quote__c >();
        Set<string> updateQuoteLine = new Set<String>();
        Set<ID> oppIDs = new Set<ID>();
        List<opportunity>oppTarifToUpd =new List<Opportunity>();
        List<Id> quoteIds = new List<Id>();
        for(Opportunity_Quote__c qt : newList){
            if(qt.Status__c == 'Accepted' && (oldMap==null || (oldMap!=null && oldMap.get(qt.id).Status__c!=qt.Status__c))){
                setOpportuintyIds.add(qt.Id_Opportunity__c);
                oppQuoteMap.put(qt.id_opportunity__c,qt);
                quoteIds.add(qt.id);
            }
        }
        if(!System.isBatch() && !quoteIds.isEmpty() && !linkingAssetFlag){
            System.debug('quoteIds: '+quoteIds);
            processLinkingOfAssetAndBranding(quoteIds);
            linkingAssetFlag = true;
        }
        if(!setOpportuintyIds.isEmpty()){
            List<Opportunity_Quote__c> listOtherQuotes = new List<Opportunity_Quote__c>();
            for(Opportunity_Quote__c qq : [select id,Status__c,Id_Opportunity__c, createddate 
                                            From Opportunity_Quote__c 
                                            where Id_Opportunity__c in : setOpportuintyIds and Status__c!='Accepted' and Status__c!='Expired' and Status__c!='Declined']){
                qq.Status__c = 'Declined';
                listOtherQuotes.add(qq);
                if(!System.isBatch() && qq.createddate>oppQuoteMap.get(qq.Id_Opportunity__c).createddate){
                    updateQuoteLine.add(oppQuoteMap.get(qq.Id_Opportunity__c).id);                    
                      if(oppIds==null || !oppIds.contains(qq.Id_Opportunity__c))
                        oppTarifToUpd.add(new Opportunity(id=qq.Id_Opportunity__c,Id_Tarif__c=oppQuoteMap.get(qq.Id_Opportunity__c).ID_tarif__c));
                    oppIds.add(qq.Id_Opportunity__c);
                    
                }
                
                
            }
            try{
            update listOtherQuotes;
            }catch(DmlException e){
                System.debug('Error: '+e.getMessage());
            }
        }
        if(!updateQuoteLine.isEmpty() && updateQuoteLine!=null ){
            if(!oppTarifToUpd.isEmpty() && oppTarifToUpd!=null){
                update oppTarifToUpd;
        
            }
            updateOppLineItems(updateQuoteLine,oppIds);
            
       } 
    }
    @future
     public static void updateOppLineItems(Set<string> updateQuoteLine,Set<ID> oppIds){
        if(!updateQuoteLine.isEmpty() && updateQuoteLine!=null){
            system.debug('**updating line items**');  
            List<Opportunity_Line_Item__c> oppLst = new List<Opportunity_Line_Item__c>();
            for(opportunity_quote_line_item__c oqli:[select id,recordtype.developername,Booking_Api_Id__c,Category__c,Subsidy__c,online_payment_fee__C,name,Category_Id__c,City_ZipCode__c,Commission_In_Percentage__c,Commission_Per_Order__c,Deposit__c,Deposit_Method__c,Design_Note__c,Discount__c,District_Id__c,End_Date__c,Has_Related_Tarif__c,Id_List_Service_Price__c,Id_Opportunity__c,Id_Replacement_Order__c,Installments__c,Line_Item_Type__c,Listed_Price__c,Id_List_Product_Price__c,Number_of_Copies__c,Position__c,Product_Group__c,Quantity__c,Recurring_Fee__c,Size__c,Start_Date__c,Sub_type__c,Total_Amount__c,Weight__c,IsTiered__c,index__c,Max__c,Min__c from opportunity_quote_line_item__c where id_opportunity_quote__c IN:updateQuoteLine ]){
                if(oqli.Sub_type__c=='Premium Placement' && oqli.recordtype.developername=='UK_Opportunity_Quote_Line_Item')
                    oppIds.remove(oqli.ID_Opportunity__C);
                else{
                    oppLst.add(new Opportunity_Line_Item__c(Booking_Api_Id__c=oqli.Booking_Api_Id__c,Category__c=oqli.Category__c,Category_Id__c=oqli.Category_Id__c,City_ZipCode__c=oqli.City_ZipCode__c,Commission_In_Percentage__c=oqli.Commission_In_Percentage__c,Commission_Per_Order__c=oqli.Commission_Per_Order__c,Deposit__c=oqli.Deposit__c,Deposit_Method__c=oqli.Deposit_Method__c,Design_Note__c=oqli.Design_Note__c,
                    Discount__c=oqli.Discount__c,District_Id__c=oqli.District_Id__c,End_Date__c=oqli.End_Date__c,Has_Related_Tarif__c=oqli.Has_Related_Tarif__c,Id_List_Service_Price__c=oqli.Id_List_Service_Price__c,Id_Opportunity__c=oqli.Id_Opportunity__c,Id_Replacement_Order__c=oqli.Id_Replacement_Order__c,Installments__c=oqli.Installments__c,Line_Item_Type__c=oqli.Line_Item_Type__c,Listed_Price__c=oqli.Listed_Price__c,
                    Id_List_Price_Product__c=oqli.Id_List_Product_Price__c,name=oqli.name,Subsidy__c=oqli.Subsidy__c,online_payment_fee__c=oqli.online_payment_fee__c,Number_of_Copies__c=oqli.Number_of_Copies__c,Position__c=oqli.Position__c,Product_Group__c=oqli.Product_Group__c,Quantity__c=oqli.Quantity__c,Recurring_Fee__c=oqli.Recurring_Fee__c,Size__c=oqli.Size__c,Start_Date__c=oqli.Start_Date__c,Sub_type__c=oqli.Sub_type__c,Total_Amount__c=oqli.Total_Amount__c,Weight__c=oqli.Weight__c,IsTiered__c= oqli.IsTiered__c,index__c= oqli.index__c,Max__c= oqli.Max__c,Min__c= oqli.Min__c));
                }
            }
             List<Opportunity_line_item__c> opliToDelete =[select id from opportunity_line_item__c where id_opportunity__c in:oppIds];
        
        if(!opliToDelete.isEmpty() && opliToDelete!=null){
            delete opliToDelete;
        }
        if(!oppLst.isEmpty() && oppLst!=null){
            insert oppLst;
        }
        /*if(!oppTarifToUpd.isEmpty() && oppTarifToUpd!=null){
            update oppTarifToUpd;
        
        }*/
            
       } 
        
        
        
    }



    public static void quoteDeclineAcceptValidation(List<Opportunity_Quote__c> newList, Map<Id,Opportunity_Quote__c> oldMap){
        for(Opportunity_Quote__c qt : newList){
            if( oldMap.get(qt.id).Status__c=='Declined' && qt.Status__c != oldMap.get(qt.id).Status__c){
                qt.addError(Label.Declined_quote_validation+' '+qt.Status__c);
                return;
            }
        }
    }


    public static void oppTypeAndStageProcess(List<Opportunity_Quote__c> listOppQuotes, Map<Id,Opportunity_Quote__c> oldMapOppQuotes){
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('OppTypeAndStageProcess');
        Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('OppTypeAndStageProcess');
        Map<Id,Opportunity_Quote__c> oppQuoteMap = new Map<Id,Opportunity_Quote__c>();
        List<Opportunity> listOppUpdates = new List<Opportunity>();
        Map<Id,Case> oppWithQC = new Map<Id,Case>();

        for(Opportunity_Quote__c oppQuote : [select recordtype.developerName, Id_Opportunity__r.type,Id_Opportunity__c,Id_Opportunity__r.Is_DataLoaded__c,status__c,Id_Opportunity__r.Id_Tarif__r.name from Opportunity_Quote__c where id in: listOppQuotes]){
            oppQuoteMap.put(oppQuote.id,oppQuote);
        }
        try{
            if(mapBusinessLogic!=null && !mapBusinessLogic.isEmpty()){
                for(Opportunity_Quote__c oppQuote : listOppQuotes){
                    Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(oppQuoteMap.get(oppQuote.id).recordtype.developerName);

                    if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){
                        System.debug('type: '+oppQuote.Id_Opportunity__r.type);
                        
                        String quoteStatus = mapBusinessRules.get('Status__c').Business_Rule_Value__c;
                        if(quoteStatus == oppQuote.status__c && (oldMapOppQuotes==null || (oldMapOppQuotes!=null && !oldMapOppQuotes.isEmpty() && oldMapOppQuotes.get(oppQuote.id).status__c!= quoteStatus))){
                            if(oppQuote.isReplacementQuote__c==false){    
                                if(oppQuoteMap.get(oppQuote.Id).Id_Opportunity__r.type==null && !oppQuoteMap.get(oppQuote.Id).Id_Opportunity__r.Is_DataLoaded__c){
                                    listOppQuotes[0].addError(Label.OpportunityTypeStageValidation);
                                    return;
                                }
                                if(mapBusinessRules.get(oppQuoteMap.get(oppQuote.id).Id_Opportunity__r.type)!=null){
                                    Opportunity opp = new Opportunity(id=oppQuote.Id_Opportunity__c);
                                    Set<String> tariffs = new Set<String>();

                                    if(mapBusinessRules.get('SetToClosedWonForTariff')!=null){
                                       if(mapBusinessRules.get('SetToClosedWonForTariff').Business_Rule_Value__c.indexOf(',') > 1 ){
                                            for(String str : mapBusinessRules.get('SetToClosedWonForTariff').Business_Rule_Value__c.split(',')){
                                                tariffs.add(str);
                                            }
                                       }else{
                                            tariffs.add(mapBusinessRules.get('SetToClosedWonForTariff').Business_Rule_Value__c);
                                       } 
                                    }
                                    if(!tariffs.isEmpty() && tariffs.contains(oppQuoteMap.get(oppQuote.id).Id_Opportunity__r.Id_Tarif__r.name)){
                                        opp.put('StageName','Closed Won');
                                        opp.put('Probability',100);
                                    }else if(mapBusinessRules.get('IfTariff-'+oppQuoteMap.get(oppQuote.id).Id_Opportunity__r.Id_Tarif__r.name)!=null){
                                        for(String newStr : mapBusinessRules.get('IfTariff-'+oppQuoteMap.get(oppQuote.id).Id_Opportunity__r.Id_Tarif__r.name).Business_Rule_Value__c.split(',')){
                                            String[] filedStr = newStr.split('=');
                                            if(filedStr[0].toLowerCase().contains('name')){
                                                opp.put(filedStr[0],filedStr[1]);
                                            }else{
                                                opp.put(filedStr[0],Decimal.valueOf(filedStr[1]));
                                            }
                                        }
                                    }else{
                                        for(String newStr : mapBusinessRules.get(oppQuoteMap.get(oppQuote.id).Id_Opportunity__r.type).Business_Rule_Value__c.split(',')){
                                            String[] filedStr = newStr.split('=');
                                            if(filedStr[0].toLowerCase().contains('name')){
                                                opp.put(filedStr[0],filedStr[1]);
                                            }else{
                                                opp.put(filedStr[0],Decimal.valueOf(filedStr[1]));
                                            }
                                        }
                                    }
                                    if(oppQuote.Non_Standard_Contract_Components__c!=null){
                                        opp.Non_Standard_Contract_Components__c=oppQuote.Non_Standard_Contract_Components__c;
                                    }
                                    listOppUpdates.add(opp);
                                }
                            }else{
                                if(mapBusinessRules.get('UpdateStageToIfReplacementQuote')!=null){
                                    Opportunity opp = new Opportunity(id=oppQuote.Id_Opportunity__c);
                                    for(String newStr : mapBusinessRules.get('UpdateStageToIfReplacementQuote').Business_Rule_Value__c.split(',')){
                                        String[] filedStr = newStr.split('=');
                                        if(filedStr[0].toLowerCase().contains('name')){
                                            opp.put(filedStr[0],filedStr[1]);
                                        }else{
                                            opp.put(filedStr[0],Decimal.valueOf(filedStr[1]));
                                        }
                                    }
                                    if(oppQuote.Non_Standard_Contract_Components__c!=null){
                                            opp.Non_Standard_Contract_Components__c=oppQuote.Non_Standard_Contract_Components__c;
                                        }
                                    listOppUpdates.add(opp);
                                    if(oppWithQC.isEmpty() || (!oppWithQC.isEmpty() && oppWithQC.get(oppQuote.Id_Opportunity__c)==null)){
                                        ReplacementOrderSettings__c rpsettings = ReplacementOrderSettings__c.getValues('UK');
                                        if(rpsettings.QualityCheckCaseSP__c!=null){
                                            Case cs = new Case(Opportunity__c=oppQuote.Id_Opportunity__c,AccountId=oppQuote.Id_Account__c);
                                            for(String fieldAndValue : rpsettings.QualityCheckCaseSP__c.split(',')){
                                                List<String> fields = fieldAndValue.split('=');
                                                cs.put(fields[0],fields[1]);
                                            }
                                            oppWithQC.put(oppQuote.Id_Opportunity__c,cs);
                                        }
                                    }
                                }

                            }   
                        }
                    }
                }
                update listOppUpdates;
                if(!oppWithQC.isEmpty()){
                    insert oppWithQC.values();
                }
            }

        }catch(Exception e){
            if(e.getDmlType(0)==StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                   listOppQuotes[0].addError(e.getDmlMessage(0));
                    return;
                }
            System.debug('Error: '+e.getMessage());
            listOppQuotes[0].addError(e.getMessage());
        }
    }

    public static void checkIfAlreadyAcceptedQuoteExist(List<Opportunity_Quote__c> listOppQuotes){
        Set<ID> opp = new Set<ID>();
        for(Opportunity_Quote__c oppQuote : listOppQuotes){
            if(!oppQuote.isReplacementQuote__c){
                opp.add(oppQuote.Id_Opportunity__c);
             }
        }
        for(Opportunity_Quote__c oppq : [select id,Id_Opportunity__c from Opportunity_Quote__c where Id_Opportunity__c in :opp and status__c='Accepted']){
            listOppQuotes[0].addError(Label.Opportunity_Quote_Save_Validation);
        }
    }


    @future
    public static void processLinkingOfAssetAndBranding(List<Id> quoteIds){
        Map<Id,Id> mapQlines = new Map<Id,Id>();
        System.debug('quoteIds: '+quoteIds);
        for(Opportunity_Quote_Line_Item__c oppQline : [select id,OldOppQuoteLineId__c from Opportunity_Quote_Line_Item__c where Id_Opportunity_Quote__c in : quoteIds and Id_Opportunity_Quote__r.Status__c='Accepted' and OldOppQuoteLineId__c!=null]){
            mapQlines.put(Id.valueOf(oppQline.OldOppQuoteLineId__c),oppQline.Id);
        }
        List<sObject> updateRecords = new List<sObject>();
        if(!mapQlines.isEmpty()){
            for(Asset__c ast : [select id,Id_Opportunity_Quote_Line_Item__c from Asset__c where Id_Opportunity_Quote_Line_Item__c in : mapQlines.keySet()]){
                ast.Id_Opportunity_Quote_Line_Item__c = mapQlines.get(ast.Id_Opportunity_Quote_Line_Item__c);
                updateRecords.add(ast); 
            }
            for(Branding_Content__c bdc : [select id,Id_Opportunity_Quote_Line_Item__c from Branding_Content__c where Id_Opportunity_Quote_Line_Item__c in : mapQlines.keySet()]){
                bdc.Id_Opportunity_Quote_Line_Item__c = mapQlines.get(bdc.Id_Opportunity_Quote_Line_Item__c);
                updateRecords.add(bdc);
            }
            update updateRecords;
        }
    }
    
    public static void premiumPlacementMultipleQuote(List<Opportunity_Quote__c> newQuotes){
        List<Id>OppIds = new List<ID>();
        List<opportunity_Quote__c> oppQuotes = new List<Opportunity_Quote__c>();
        Map<Id,Opportunity_Quote__C> oppQuoteMap = new Map<ID,Opportunity_Quote__c>();
        for(Opportunity_quote__c oq:newQuotes){
            if(LibRecordTypeHelper.getRecordTypeValue(oq.recordtypeid)=='UK_Opportunity_Quote')
                oppQuoteMap.put(oq.ID_Opportunity__c,oq);
            
        }
        if(!oppQuoteMap.isEmpty() && oppQuoteMap!=null) {
            for(opportunity_quote__C q:[select id,createddate,id_tarif__r.name,status__c,Id_Opportunity__c  from opportunity_quote__c where id_opportunity__c in:oppQuoteMap.keySet() and id_tarif__r.name='Premium Placement' and recordtype.developername='UK_Opportunity_Quote' and status__c!='Accepted' and status__c!='Declined']){
                if(oppQuoteMap.get(q.Id_opportunity__c)!=null && oppQuoteMap.get(q.Id_opportunity__c).Id!=q.id){
                    q.status__c='Expired';
                    system.debug('**update');
                    oppQuotes.add(q);
                }
            }
           update oppQuotes;  
        }   
    }
}