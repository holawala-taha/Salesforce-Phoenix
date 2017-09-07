@isTest
private class UnitTestClsRemoteController {
    static List<Opportunity_Quote__c> oppQuoteList;
    static Map<String,RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Additional_Charges__c','Account','Sales_Target__c'});
    //static User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team','testUser@deliveryherotest.com','Yogiyo','KR');
    static User testUser = UnitTestDataFactory.createUser('DH AU Sales Team', 'dhautestuser@test.com', 'DH_AU','AU');
    static User testUser_uk = UnitTestDataFactory.createUser('UK Customer Care Management', 'uktestuser@test.com', 'Hungryhouse','UK');
    static User testUser_kr = UnitTestDataFactory.createUser('Yogiyo Local Admin', 'kradmintestuser@test.com', 'Yogiyo','KR');
    static User escalationUser_aus = UnitTestDataFactory.createUser('DH AU Sales Management', 'escalationtestuser2@test.com', 'DH_AU','AU');
    static Country__c testCountry;
    static Country__c c_au;
    static Country__c c_uk;
    static List<Asset__c> assetList;
    static List<Account> accList;
    static Account acc;
    static{
        UnitTestDataFactory.getRecordtypeValues();
        insert testUser_kr;
        insert testUser_uk;
        insert escalationUser_aus;
        testUser.CountryCode__c = 'KR;AU';
        testUser.Company_Name__c = 'Yogiyo;DH_AU';
        insert testUser;
        
        Id userProfileId = [Select ProfileId FROM User WHERE Id =: testUser.Id LIMIT 1].Id;
        Id userProfileId_kr = [Select ProfileId FROM User WHERE Id =: testUser_kr.Id LIMIT 1].Id;//@Bhupendra
        
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='UKPlatform', country__c='United Kingdom'));
        insert platformCountry;
        
        testCountry = UnitTestDataFactory.createCountry('KR','Korea','KRW');
        c_au=UnitTestDataFactory.createCountry('AU','Australia','AUD');
        c_uk=UnitTestDataFactory.createCountry('UK','United Kingdom','GBP');
        Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
        Company__c com_uk = UnitTestDataFactory.createCompany('Hungryhouse', 'UK',c_uk);
        insert new List<sObject>{testCountry,c_au,com,c_uk,com_uk};
        //Added by Bhupendra Start
        Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c='level1ApprovedStatus',Business_Rule_Value__c='Pending - legal',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
        Business_Config__c b8 = new Business_Config__c(Business_Rule_Name__c='finalApprovalStatus',Business_Rule_Value__c='Accepted',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
        Business_Config__c b9 = new Business_Config__c(Business_Rule_Name__c='level2ApprovedStatus',Business_Rule_Value__c='Accepted',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
        Business_Config__c b10 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterFinalApproval',Business_Rule_Value__c='Menu received',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
        Business_Config__c b11 = new Business_Config__c(Business_Rule_Name__c='rejectionTemplate',Business_Rule_Value__c='Menu received',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
        Business_Config__c b12 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel1Approval',Business_Rule_Value__c='Positive Feedback - HOS',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
        Business_Config__c b13 = new Business_Config__c(Business_Rule_Name__c='initialStatusLevel1',Business_Rule_Value__c='Approval pending',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
        Business_Config__c b14 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel1Rejection',Business_Rule_Value__c='Negotiating',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
        Business_Config__c b15 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel2Rejection',Business_Rule_Value__c='Please correct errors',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
        insert new List<sobject>{b7,b8,b9,b10,b11,b12,b13,b14,b15};
        
        //Added by Bhupendra End
        Business_Config__c b16 = new Business_Config__c(Business_Rule_Name__c='calloutBaseURL',Business_Rule_Value__c='https://www.yogiyo.co.kr/salesforce/restaurant/create/',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='SendToBackendProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        Business_Config__c b17 = new Business_Config__c(Business_Rule_Name__c='calloutAPIKey',Business_Rule_Value__c='salesforce',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='SendToBackendProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        Business_Config__c b18 = new Business_Config__c(Business_Rule_Name__c='calloutSecret',Business_Rule_Value__c='23752ba30a8811e5a0b434363bd33456',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='SendToBackendProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        Business_Config__c b19 = new Business_Config__c(Business_Rule_Name__c='allowedAccountType',Business_Rule_Value__c='Child',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='SendToBackendProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        Business_Config__c b20 = new Business_Config__c(Business_Rule_Name__c='allowedProfileIds',Business_Rule_Value__c=userProfileId + ',' + userProfileId_kr,Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='SendToBackendProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        Business_Config__c b21 = new Business_Config__c(Business_Rule_Name__c='ownerId',Business_Rule_Value__c= escalationUser_aus.Id,Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EscalateCaseBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
        Business_Config__c b22 = new Business_Config__c(Business_Rule_Name__c='ownerId',Business_Rule_Value__c=escalationUser_aus.Id,Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='BackToQueueBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
        Business_Config__c b23x = new Business_Config__c(Business_Rule_Name__c='ownerId',Business_Rule_Value__c= escalationUser_aus.Id,Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
        Business_Config__c b26x = new Business_Config__c(Business_Rule_Name__c='Type',Business_Rule_Value__c='Menu Processing, Menu Change',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
        Business_Config__c b23y = new Business_Config__c(Business_Rule_Name__c='fieldMap',Business_Rule_Value__c= '{"Final Check":"Final_Check_Date__c","Menu Typing":"Menu_Typed_Date__c","Take Online":"Take_Online_Date__c"}',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
        Business_Config__c b23z = new Business_Config__c(Business_Rule_Name__c='Menu Processing FinalStatus',Business_Rule_Value__c= 'Take Online',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='UK_Entry_Case',Type__c='Process');
        Business_Config__c b23au = new Business_Config__c(Business_Rule_Name__c='Menu Processing',Business_Rule_Value__c= '{"Menu Typing":"First Check","FinalStatus":"Final Check","New":"Menu Typing","First Check":"Final Check","Please Correct Errors":"Final Check"}',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
        
        Business_Config__c b23k = new Business_Config__c(Business_Rule_Name__c='Menu Processing',Business_Rule_Value__c= '{"Menu Typing":"First Check","FinalStatus":"Final Check","New":"Menu Typing","First Check":"Final Check","Please Correct Errors":"Final Check"}',Id_Country__c=c_uk.id,Is_Active__c=true,Parent__c=true,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='UK_Entry_Case',Type__c='Process');
        Business_Config__c b23uk = new Business_Config__c(Business_Rule_Name__c='personInchargeMap',Business_Rule_Value__c= '{"Menu Typing":"Person_in_charge_Menu_Typing__c","First Check":"Person_In_Charge_First_Check__c"}',Id_Country__c=c_uk.id,Is_Active__c=true,Parent__c=true,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='UK_Entry_Case',Type__c='Process');
        Business_Config__c b24uk = new Business_Config__c(Business_Rule_Name__c='chkForPersonInCharge',Business_Rule_Value__c= 'true',Id_Country__c=c_uk.id,Is_Active__c=true,Parent__c=true,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='UK_Entry_Case',Type__c='Process');
        Business_Config__c b25uk = new Business_Config__c(Business_Rule_Name__c='Type',Business_Rule_Value__c='Menu Processing, Menu Change',Id_Country__c=c_uk.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='UK_Entry_Case',Type__c='Process');
        Business_Config__c b1x = new Business_Config__c(Business_Rule_Name__c='Additional Contract',Business_Rule_Value__c='White Label Website Fee,Order Now Button Fee',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='OppTypeAndServiceType',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b2x = new Business_Config__c(Business_Rule_Name__c='recurringFee',Business_Rule_Value__c='test',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
                     
        insert new List<sObject>{b16,b17,b18,b19,b20,b21,b22,b23x, b26x, b23y, b23z, b23k, b23uk, b24uk,b23au,b1x,b2x};
        
        System.runAs(testUser){
        //UnitTestDataFactory.testDataFor_DH_AU_ContractProcess();
        //c_au = [select id,name,CurrencyIsoCode from Country__c where name='Australia' limit 1];
        
        //Business_Config__c b0 = new Business_Config__c(Business_Rule_Name__c='Additional Contract',Business_Rule_Value__c='White Label Website Fee,Order Now Button Fee',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='OppTypeAndServiceType',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        //insert b0;
        Business_Config__c b0 = new Business_Config__c(Business_Rule_Name__c='Additional Contract',Business_Rule_Value__c='White Label Website Fee,Order Now Button Fee',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='OppTypeAndServiceType',Record_Type_Id__c='yogiyo_Opportunity',Type__c='Process');
        insert b0;
        //List<Opportunity> listOpp = [select id from Opportunity where name='TestOpp123'];
        //Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='set StageName',Business_Rule_Value__c='Editorial Queue',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
       // Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='Asset RecordType',Business_Rule_Value__c='DH_AU_Asset',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        //Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='set Probability',Business_Rule_Value__c='95',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        //Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='Asset Status__c',Business_Rule_Value__c='New - Awaiting Shipping',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        //Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='createAsset',Business_Rule_Value__c='true',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        //Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='permittedProfiles',Business_Rule_Value__c='DH AU Sales Team',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        //Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c='QuoteApprovalProcess',Business_Rule_Value__c='Pending - legal',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
        //Business_Config__c b8 = new Business_Config__c(Business_Rule_Name__c='finalApprovalStatus',Business_Rule_Value__c='Accepted',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
        //Business_Config__c b9 = new Business_Config__c(Business_Rule_Name__c='level2ApprovedStatus',Business_Rule_Value__c='Accepted',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
        //Business_Config__c b10 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterFinalApproval',Business_Rule_Value__c='Menu received',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
        //Business_Config__c b11 = new Business_Config__c(Business_Rule_Name__c='rejectionTemplate',Business_Rule_Value__c='Menu received',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
        //Business_Config__c b12 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel1Approval',Business_Rule_Value__c='Positive Feedback - HOS',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
        //Business_Config__c b13 = new Business_Config__c(Business_Rule_Name__c='initialStatusLevel1',Business_Rule_Value__c='Approval pending',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
        //Business_Config__c b14 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel1Rejection',Business_Rule_Value__c='Negotiating',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
        //Business_Config__c b15 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel2Rejection',Business_Rule_Value__c='Please correct errors',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
         
        //insert new List<sObject>{b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15};
        //Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='set StageName',Business_Rule_Value__c='Editorial Queue',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QualityCheckButton',Record_Type_Id__c='yogiyo_Opportunity',Type__c='Process');
        //Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='Asset RecordType',Business_Rule_Value__c='yogiyo_Asset',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='yogiyo_Opportunity',Type__c='Process');
        //Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='set Probability',Business_Rule_Value__c='95',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='yogiyo_Opportunity',Type__c='Process');
       // Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='Asset Status__c',Business_Rule_Value__c='New - Awaiting Shipping',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='yogiyo_Opportunity',Type__c='Process');
       // Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='createAsset',Business_Rule_Value__c='true',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
       // Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='permittedProfiles',Business_Rule_Value__c='Yogiyo Sales Team',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='yogiyo_Opportunity',Type__c='Process');
       // Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c='level1ApprovedStatus',Business_Rule_Value__c='Pending - legal',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
       // Business_Config__c b8 = new Business_Config__c(Business_Rule_Name__c='finalApprovalStatus',Business_Rule_Value__c='Accepted',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
       // Business_Config__c b9 = new Business_Config__c(Business_Rule_Name__c='level2ApprovedStatus',Business_Rule_Value__c='Accepted',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
      //  Business_Config__c b10 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterFinalApproval',Business_Rule_Value__c='Menu received',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
       // Business_Config__c b11 = new Business_Config__c(Business_Rule_Name__c='rejectionTemplate',Business_Rule_Value__c='Menu received',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
       // Business_Config__c b12 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel1Approval',Business_Rule_Value__c='Positive Feedback - HOS',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
       // Business_Config__c b13 = new Business_Config__c(Business_Rule_Name__c='initialStatusLevel1',Business_Rule_Value__c='Approval pending',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
       // Business_Config__c b14 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel1Rejection',Business_Rule_Value__c='Negotiating',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
        //Business_Config__c b15 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel2Rejection',Business_Rule_Value__c='Please correct errors',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
       
        
        //Business_Config__c b21 = new Business_Config__c(Business_Rule_Name__c='ownerId',Business_Rule_Value__c=escalationUser_aus.Id,Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EscalateCaseBtn',Record_Type_Id__c='DH_AU_Case',Type__c='Process');
        //insert b21;
       // Business_Config__c b22 = new Business_Config__c(Business_Rule_Name__c='ownerId',Business_Rule_Value__c=escalationUser_aus.Id,Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='BackToQueueBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
       // Business_Config__c b24 = new Business_Config__c(Business_Rule_Name__c='Menu Processing FinalStatus',Business_Rule_Value__c='Take Online',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
       // Business_Config__c b25 = new Business_Config__c(Business_Rule_Name__c='Menu Processing New',Business_Rule_Value__c='Backend ID Created',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
       // Business_Config__c b26 = new Business_Config__c(Business_Rule_Name__c='Type',Business_Rule_Value__c='Menu Processing, Menu Change',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
        
        
      
        
        //insert new List<sObject>{b22,b24,b25,b26};
        //insert new List<sObject>{b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16,b17,b18,b19,b20,b21,b22,b23,b24,b25,b26};
       // System.debug('$$$ inserted config APprovalProcess: ' + b8);
       // System.debug('$$$ inserted configs'+b16);      
       // Business_Config__c c =  UnitTestDataFactory.createBusinessConfig('Quote is won process', 'Trigger',null,null, testCountry.id, null, true, true);
       // Business_Config__c b = UnitTestDataFactory.createBusinessConfig('Quote Accept Process', 'Process','set opportunity stage','100% Closed', testCountry.id, 'Yogiyo_Opportunity', true, true);
       // insert new List<sObject>{c,b}; 
        accList = UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        oppQuoteList = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1,'Yogiyo_Opportunity_Quote','Draft','test data',100.45,100.45,'','',0);
        insert oppQuoteList;
    }
}

    @isTest static void test_EscalateButton(){
        System.runAs(testUser){
            c_au = [select id,name,CurrencyIsoCode from Country__c where name='Australia' limit 1];
            Business_Config__c b21 = new Business_Config__c(Business_Rule_Name__c='ownerId',Business_Rule_Value__c=escalationUser_aus.Id,Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EscalateCaseBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
            insert new List<sObject>{b21};
            acc = UnitTestDataFactory.createAccount('TestAccount',c_au ,'DH_AU_Account');
            acc.OwnerId= testUser.Id;
            insert acc;
            Case theCase = UnitTestDataFactory.createCase(acc, 'status','type', 'caseReason', 'origin', c_au , 'DH_AU_Entry_Case', 'subject');
            theCase.OwnerId= testUser.Id;
            insert theCase;
            
            Test.startTest();
                String[] resultMessage = ClsRemoteController.escalateCaseAU(theCase.Id);
            Test.stopTest();
            
            //System.assertEquals(Label.Escalated_already_AU,resultMessage[0]);
        }
    }
    
    @isTest static void test_EscalateButton1(){
        System.runAs(testUser){
            c_au = [select id,name,CurrencyIsoCode from Country__c where name='Australia' limit 1];
            Business_Config__c b21 = new Business_Config__c(Business_Rule_Name__c='ownerId',Business_Rule_Value__c= escalationUser_aus.Id,Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EscalateCaseBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
            insert new List<sObject>{b21};
            acc = UnitTestDataFactory.createAccount('TestAccount',c_au ,'DH_AU_Account');
            acc.OwnerId= testUser.Id;
            insert acc;
            Case theCase = UnitTestDataFactory.createCase(acc, 'status','type', 'caseReason', 'origin', c_au , 'DH_AU_Entry_Case', 'subject');
            theCase.OwnerId= testUser.Id;
            insert theCase;
            
            Test.startTest();
                String[] resultMessage = ClsRemoteController.escalateCaseAU(theCase.Id);
                System.debug('resultMessage' + resultMessage);
            Test.stopTest();
            
            //System.assertEquals(Label.Escalated_already_AU,resultMessage[0]);
        }
    }
    
    @isTest static void test_EscalateButton2(){
        System.runAs(testUser){
            c_au = [select id,name,CurrencyIsoCode from Country__c where name='Australia' limit 1];
            Business_Config__c b21 = new Business_Config__c(Business_Rule_Name__c='ownerId',Business_Rule_Value__c= escalationUser_aus.Id,Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EscalateCaseBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
            insert new List<sObject>{b21};
            acc = UnitTestDataFactory.createAccount('TestAccount',c_au ,'DH_AU_Account');
            acc.OwnerId= testUser.Id;
            insert acc;
            Case theCase = UnitTestDataFactory.createCase(acc, 'status','type', 'caseReason', 'origin', c_au , 'DH_AU_Entry_Case', 'subject');
            theCase.OwnerId= testUser.Id;
            insert theCase;
            
            Test.startTest();
                String[] resultMessage = ClsRemoteController.escalateCaseAU(theCase.Id);
                System.debug('resultMessage' + resultMessage);
            Test.stopTest();
            
            //System.assertEquals(Label.Escalated_already_AU,resultMessage[0]);
        }
    }
    
    @isTest static void test_EscalateButtonClosed(){
        System.runAs(testUser){
            c_au = [select id,name,CurrencyIsoCode from Country__c where name='Australia' limit 1];
            Business_Config__c b21 = new Business_Config__c(Business_Rule_Name__c='ownerId',Business_Rule_Value__c=escalationUser_aus.Id,Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EscalateCaseBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
            insert new List<sObject>{b21};
            acc = UnitTestDataFactory.createAccount('TestAccount',c_au ,'DH_AU_Account');
            acc.OwnerId= testUser.Id;
            insert acc;
            Case theCase = UnitTestDataFactory.createCase(acc, 'Closed','type', 'caseReason', 'origin', c_au , 'DH_AU_Entry_Case', 'subject');
            theCase.ownerid= escalationUser_aus.Id;
            insert theCase;
            List<String> resultMessage;
            Test.startTest();
                resultMessage = ClsRemoteController.escalateCaseAU(theCase.Id);
                System.debug('resultMessage' + resultMessage);
            Test.stopTest();
            
            System.assertEquals(Label.Escalated_closed_case_AU,resultMessage[0]);
        }
    }
    
    @isTest static void test_EscalateButtonClosed1(){
        System.runAs(testUser){
            c_au = [select id,name,CurrencyIsoCode from Country__c where name='Australia' limit 1];
            acc = UnitTestDataFactory.createAccount('TestAccount',c_au ,'DH_AU_Account');
            acc.OwnerId= testUser.Id;
            insert acc;
            Case theCase = UnitTestDataFactory.createCase(acc, 'Closed','type', 'caseReason', 'origin', c_au , 'DH_AU_Entry_Case', 'subject');
            theCase.ownerid= escalationUser_aus.Id;
            insert theCase;
            
            List<String> resultMessage;
            Test.startTest();
                resultMessage = ClsRemoteController.escalateCaseAU(theCase.Id);
                System.debug('resultMessage' + resultMessage);
            Test.stopTest();
        }
    }
   
    @isTest static void test_BackToQueueButton(){
          System.runAs(testUser){
              c_au = [select id,name,CurrencyIsoCode from Country__c where name='Australia' limit 1];
              acc = UnitTestDataFactory.createAccount('TestAccount',c_au ,'DH_AU_Account');
              acc.OwnerId= testUser.Id;
              insert acc;
              Case theCase = UnitTestDataFactory.createCase(acc, 'New','type', 'caseReason', 'origin', c_au , 'DH_AU_Entry_Case', 'subject');
              theCase.ownerid= testUser.Id;
              insert theCase;
              
              Test.startTest();
                  String[] resultMessage = ClsRemoteController.backToQueue(theCase.Id);
                  System.debug('resultMessage' + resultMessage);
              Test.stopTest();
         }
    }
   
    @isTest static void test_BackToQueueButton2(){
          System.runAs(testUser){
            c_au = [select id,name,CurrencyIsoCode from Country__c where name='Australia' limit 1];
            acc = UnitTestDataFactory.createAccount('TestAccount',c_au ,'DH_AU_Account');
            acc.OwnerId= testUser.Id;
            insert acc;
            Case theCase = UnitTestDataFactory.createCase(acc, 'status','type', 'caseReason', 'origin', c_au , 'DH_AU_Entry_Case', 'subject');
            theCase.OwnerId= escalationUser_aus.Id;
            insert theCase;
            
            Test.startTest();
                String[] resultMessage = ClsRemoteController.backToQueue(theCase.Id);
                System.debug('resultMessage' + resultMessage);
            Test.stopTest();
        }
    }
    
    @isTest static void test_BackToQueueButtonClosed(){
        System.runAs(testUser){
            c_au = [select id,name,CurrencyIsoCode from Country__c where name='Australia' limit 1];
            Business_Config__c b21 = new Business_Config__c(Business_Rule_Name__c='ownerId',Business_Rule_Value__c=escalationUser_aus.Id,Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='BackToQueueBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
            acc = UnitTestDataFactory.createAccount('TestAccount',c_au ,'DH_AU_Account');
            Insert acc;
            Case theCase = UnitTestDataFactory.createCase(acc, 'Closed','type', 'caseReason', 'origin', c_au , 'DH_AU_Entry_Case', 'subject');
            theCase.OwnerId= escalationUser_aus.Id;
            insert theCase;
            
            Test.startTest();
                insert new List<sObject>{b21};
                String[] resultMessage = ClsRemoteController.backToQueue(theCase.Id);
                System.debug('resultMessage' + resultMessage);
            Test.stopTest();
        }
    }
        
    @isTest static void test_MarkCompleteBtn(){
        System.runAs(testUser){
            c_au = [select id,name,CurrencyIsoCode from Country__c where name='Australia' limit 1];
            acc = UnitTestDataFactory.createAccount('TestAccount',c_au ,'DH_AU_Account');
            acc.ownerId= testUser.Id;
            Insert acc;
            Case theCase = UnitTestDataFactory.createCase(acc, 'Take Online','Menu Processing', 'caseReason', 'origin', c_au , 'DH_AU_Entry_Case', 'subject');
            theCase.OwnerId = testUser.Id;
            theCase.Status='Take Online';
            insert theCase;
            
            Test.startTest();
                String[] resultMessage = ClsRemoteController.markComplete(theCase.Id);
                System.debug('resultMessage' + resultMessage);
            Test.stopTest();
        }
    }
    
    @isTest static void test_MarkCompleteBtnCaseType(){
        System.runAs(testUser){
            c_au = [select id,name,CurrencyIsoCode from Country__c where name='Australia' limit 1];
            acc = UnitTestDataFactory.createAccount('TestAccount',c_au ,'DH_AU_Account');
            acc.ownerId= testUser.Id;
            Insert acc;
            Case theCase = UnitTestDataFactory.createCase(acc, 'New','Accounting', 'caseReason', 'origin', c_au , 'DH_AU_Entry_Case', 'subject');
            theCase.OwnerId = testUser.Id;
            insert theCase;
            
            Test.startTest();
                String[] resultMessage = ClsRemoteController.markComplete(theCase.Id);
                System.debug('resultMessage' + resultMessage);
            Test.stopTest();
        }
    }
    
    @isTest static void test_MarkCompleteMenuProcessFinalCheck(){
        System.runAs(testUser){
            c_au = [select id,name,CurrencyIsoCode from Country__c where name='Australia' limit 1];
            acc = UnitTestDataFactory.createAccount('TestAccount',c_au ,'DH_AU_Account');
            acc.ownerId= testUser.Id;
            Insert acc;
            Case theCase = UnitTestDataFactory.createCase(acc, 'Final Check','Menu Processing', 'caseReason', 'origin', c_au , 'DH_AU_Entry_Case', 'subject');
            theCase.OwnerId = testUser.Id;
            theCase.Status = 'Final Check';

            insert theCase;
            
            Test.startTest();
                String[] resultMessage = ClsRemoteController.markComplete(theCase.Id);
                System.debug('resultMessage' + resultMessage);
            Test.stopTest();
        }
    }
    
    @isTest static void test_MarkCompleteUKchkForPersonInCharge(){
        System.runAs(testUser_uk){
            c_uk = [select id,name,CurrencyIsoCode from Country__c where name='United Kingdom' limit 1];
            acc = UnitTestDataFactory.createAccount('TestAccount',c_uk ,'UK_Account');
            acc.ownerId= testUser_uk.Id;
            Insert acc;
            Case theCase = UnitTestDataFactory.createCase(acc, 'Menu Typing','Menu Typing', 'caseReason', 'origin', c_uk , 'UK_Entry_Case', 'subject');
            theCase.OwnerId = testUser_uk.Id;
            insert theCase;
            
            Test.startTest();
                String[] resultMessage = ClsRemoteController.markComplete(theCase.Id);
                System.debug('resultMessage' + resultMessage);
            Test.stopTest();
        }
    }
    
    @isTest static void test_MarkCompleteBtnClosed(){
        System.runAs(escalationUser_aus){
            c_au = [select id,name,CurrencyIsoCode from Country__c where name='Australia' limit 1];
            Business_Config__c b23x = new Business_Config__c(Business_Rule_Name__c='OwnerId',Business_Rule_Value__c= escalationUser_aus.Id,Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
            Business_Config__c b26x = new Business_Config__c(Business_Rule_Name__c='Type',Business_Rule_Value__c='Menu Processing,Menu Change',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
            insert new List<sObject>{b23x,b26x};
            acc = UnitTestDataFactory.createAccount('TestAccount',c_au ,'DH_AU_Account');
            acc.ownerId= escalationUser_aus.Id;
            Insert acc;
            Case theCase = UnitTestDataFactory.createCase(acc, 'Closed','Menu Processing', 'caseReason', 'origin', c_au , 'DH_AU_Entry_Case', 'subject');
            theCase.OwnerId= escalationUser_aus.Id;
            insert theCase;
           
            Test.startTest();
                String[] resultMessage = ClsRemoteController.markComplete(theCase.Id);
                System.debug('resultMessage' + resultMessage);
            Test.stopTest();
        }
    }

    static void testDataForCancelAsset(){
        System.runAs(testUser){
            acc = UnitTestDataFactory.createAccount('TestAccount',testCountry,'Yogiyo_Account');
            insert acc;
            Opportunity opp = UnitTestDataFactory.createOpportunity('TestOpp123',acc,'Yogiyo_Opportunity',Date.today());
            insert opp;
            assetList = UnitTestDataFactory.createAssets(2,acc,opp,Date.today().addDays(-10),true,null,null,'Yogiyo_Asset',
                    '12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Exchange Requested',
                    Date.today().addDays(20), 'Yazi Logistics', '1234', 'Delivered to Warehouse');
            insert assetList;
            Additional_Charges__c add1 = new Additional_Charges__c(Id_Account__c=acc.id,Id_Asset__c=assetList[0].id,Id_Opportunity__c=opp.id,Installments__c=1,Listed_Price__c=100,Product_Group__c='terminal',Product__c='test  prod',Quantity__c=1,RecordTypeId=mapRecordtypes.get('Yogiyo_Additional_Charges').Id,Total_Amount__c=100);
            Additional_Charges__c add2 = new Additional_Charges__c(Id_Account__c=acc.id,Id_Asset__c=assetList[1].id,Id_Opportunity__c=opp.id,Installments__c=1,Listed_Price__c=50,Product_Group__c='terminal2',Product__c='test  prod2',Quantity__c=1,RecordTypeId=mapRecordtypes.get('Yogiyo_Additional_Charges').Id,Total_Amount__c=50);
            insert new List<sObject>{add1,add2};
        }
    }

    @isTest static void test_createBackendAccountKR(){
        System.runas(testUser){
            acc = UnitTestDataFactory.createAccount('TestAccount',testCountry,'Yogiyo_Account');
            acc.Type = 'Child';
            acc.Restaurant_Name__c = 'TestRestaurant';
            insert acc;
        
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceKR());
                List<String> listResult = ClsRemoteController.createBackendAccountKR(acc.Restaurant_Name__c, String.valueOf(acc.Id), 'John Doe', acc.Type);
            Test.stopTest();
            
            acc = [SELECT Id,Backend_ID__c FROM Account WHERE Id =: acc.Id LIMIT 1];
            System.assertEquals('123456', acc.Backend_ID__c);
        }
    }

    @isTest static void test_method_positive() {
        accList = UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());
        insert oppList;
        Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',oppList[0],null,true,'DH_AU_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        oppService.Line_item_type__c = 'Service';
        insert oppService;
        
        List<Opportunity_Quote_Line_item__c> quotelineItems = new List<Opportunity_Quote_Line_item__c>();
        Opportunity_Quote_Line_item__c item1 = UnitTestDataFactory.createOpportunityQuoteLineItem(oppQuoteList[0],oppService,'AT_Opportunity_Quote_Line_Item');
        item1.Line_item_type__c = 'Product';
        item1.sub_type__c = 'Ad Sales';
        quotelineItems.add(item1);
        
        Opportunity_Quote_Line_item__c item2 = UnitTestDataFactory.createOpportunityQuoteLineItem(oppQuoteList[0],oppService,'AT_Opportunity_Quote_Line_Item');
        item2.Line_item_type__c = 'Product';
        item2.sub_type__c = Label.CD_Special_Offer;
        quotelineItems.add(item2);
        
        Opportunity_Quote_Line_item__c item3 = UnitTestDataFactory.createOpportunityQuoteLineItem(oppQuoteList[0],oppService,'AT_Opportunity_Quote_Line_Item');
        item3.Line_item_type__c = 'Service';
        item3.sub_type__c = 'Logistics';
        quotelineItems.add(item3);
        
        Opportunity_Quote_Line_item__c item4 = UnitTestDataFactory.createOpportunityQuoteLineItem(oppQuoteList[0],oppService,'AT_Opportunity_Quote_Line_Item');
        item4.Line_item_type__c = 'Service';
        item4.sub_type__c = null;
        quotelineItems.add(item4);
        
        insert quotelineItems;
        Test.startTest();
            System.runAs(testUser){
                ClsRemoteController.acceptQuote(oppQuoteList[0].id);
                List<string> itemsToTerminate=ClsRemoteController.checkForItemsToTerminate('acc.id');
            }
        Test.stopTest();

        System.assertEquals([select Status__c from Opportunity_Quote__c where id=:oppQuoteList[0].id].Status__c,'Accepted');

    }
    
    @isTest static void test_method_negative() {
        Test.startTest();
            System.runAs(testUser){
                oppQuoteList[0].Status__c = 'Draft';
                update oppQuoteList[0];
                ClsRemoteController.acceptQuote(oppQuoteList[0].Id);
            }
        Test.stopTest();

        //System.assertEquals([select Status__c from Opportunity_Quote__c where id=:oppQuoteList[0].id].Status__c,'Accepted');

    }
    
    @isTest static void test_checkForItemsToTerminate_negative(){
        testDataForCancelAsset();
        
        Test.startTest();
        List<String> itemsExist;
            System.runAs(testUser){
                itemsExist = ClsRemoteController.checkForItemsToTerminate(accList[0].Id);
            }
        Test.stopTest();
        
        System.assertEquals('false', itemsExist[0]);
    }

    @isTest static void test_checkForItemsToTerminate_positive(){
        testDataForCancelAsset();
        Test.startTest();
            List<String> itemsExist;
            System.runAs(testUser){
                itemsExist = ClsRemoteController.checkForItemsToTerminate(acc.Id);
            }
        Test.stopTest();
        
        System.assertEquals('true', itemsExist[0]);
    }

    @isTest static void test_cancelAssetAdditionalCharge(){
        testDataForCancelAsset();
        
        Test.startTest();
            System.runAs(testUser){
                ClsRemoteController.cancelAssetAdditionalCharges(assetList[0].Id);
                //negative test 
                ClsRemoteController.cancelAssetAdditionalCharges(assetList[0].Id);
            }
        Test.stopTest();
        
        Additional_Charges__c add = [select termination_date__c from Additional_Charges__c where id_Asset__c =:assetList[0].Id];
        System.assertEquals(add.termination_date__c,Date.today());
    }

    @isTest static void test_Negative_cancelAssetAdditionalCharge(){
        testDataForCancelAsset();
        Test.startTest();
            System.runAs(testUser){
                ClsRemoteController.cancelAssetAdditionalCharges('34234234324');
            }
        Test.stopTest();
        
        Additional_Charges__c add = [select termination_date__c from Additional_Charges__c where id_Asset__c =:assetList[0].Id];
        System.assertEquals(add.termination_date__c,null);
    }

    @isTest static void test_cancelAllAssetAdditionalCharges(){
        testDataForCancelAsset();
        Test.startTest();
            System.runAs(testUser){
                ClsRemoteController.cancelAllAssetAdditionalCharges(acc.Id);
            }
        Test.stopTest();
        
        List<Additional_Charges__c> addList = [select termination_date__c from Additional_Charges__c where termination_date__c=null];
        System.assertEquals(addList.isEmpty(),true);
    }

    @isTest static void test_Negative_cancelAllAssetAdditionalCharges(){
        testDataForCancelAsset();
        
        Test.startTest();
        System.runAs(testUser){
            ClsRemoteController.cancelAllAssetAdditionalCharges('23452335');
        }
        Test.stopTest();
        
        List<Additional_Charges__c> addList = [select termination_date__c from Additional_Charges__c where termination_date__c=null];
        System.assertEquals(addList.isEmpty(),false);
    }
    
    /*@isTest static void test_qualityCheck_Positive(){
        accList = UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());
        insert oppList;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='set StageName',Business_Rule_Value__c='Editorial Queue',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='Asset RecordType',Business_Rule_Value__c='DH_AU_Asset',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='set Probability',Business_Rule_Value__c='95',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='Asset Status__c',Business_Rule_Value__c='New - Awaiting Shipping',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='createAsset',Business_Rule_Value__c='true',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='permittedProfiles',Business_Rule_Value__c='System Administrator,DH AU Sales Management,DH AU Customer Care Team,DH AU Sales Team',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        
        System.runAs(testUser){
            insert new List<sObject>{b1,b2,b3,b4,b5,b6};
            
            Test.startTest();
                ClsRemoteController.qualityCheck(oppList[0].id);
            Test.stopTest();
            
            List<Asset__c> resultAssets = [select id from Asset__c where Opportunity__c=: oppList[0].id];
           // System.assertEquals(resultAssets.size(),1); 
        }
    }

    @isTest static void test_qualityCheck_ProfileMisMatch(){
        accList = UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());
        insert oppList;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='set StageName',Business_Rule_Value__c='Editorial Queue',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='Asset RecordType',Business_Rule_Value__c='DH_AU_Asset',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='set Probability',Business_Rule_Value__c='95',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='Asset Status__c',Business_Rule_Value__c='New - Awaiting Shipping',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='createAsset',Business_Rule_Value__c='true',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='permittedProfiles',Business_Rule_Value__c='System Administrator,DH AU Sales Management,DH AU Customer Care Team',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        
        System.runAs(testUser){
            insert new List<sObject>{b1,b2,b3,b4,b5,b6};
            
            Test.startTest();
                ClsRemoteController.qualityCheck(oppList[0].id);
            Test.stopTest();
            
            List<Asset__c> resultAssets = [select id from Asset__c where Opportunity__c=: oppList[0].id];
           // System.assertEquals(resultAssets.size(),1); 
        }
    }

    @isTest static void test_qualityCheck_Negative(){
        accList = UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());
        insert oppList;
        List< Opportunity_Quote__c > oppQuoteList1 = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1,'DH_AU_Opportunity_Quote','Accepted','test data',100.45,100.45,'','',0);
        insert oppQuoteList1;
        system.debug('oppQuoteList1 : ' + oppQuoteList1); 
        
        System.runAs(testUser){
            Opportunity_Quote__c oppQuote = [select id from Opportunity_Quote__c limit 1];
            oppQuote.Status__c = 'Declined';
            update oppQuote;
            
            Test.startTest();
                ClsRemoteController.qualityCheck(oppList[0].id);
            Test.stopTest();
            
            List<Asset__c> resultAssets = [select id from Asset__c where Opportunity__c=: oppList[0].id];
           // System.assertEquals(resultAssets.size(),0); 
        }
    }*/

    @isTest static void test_updateOpportunityType_positive(){
        accList = UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());
        insert oppList;
        List<Opportunity_line_item__c> lineItems = new List<Opportunity_line_item__c>();
        Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',oppList[0],null,true,'DH_AU_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        oppService.Line_item_type__c = 'Service';
        lineItems.add(oppService);
        Opportunity_Line_Item__c oppService2 = UnitTestDataFactory.createOpportunityLineItemService('testService3',oppList[0],null,true,'DH_AU_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        oppService2.Line_item_type__c = 'Service';
        oppService2.Sub_type__c = null;
        lineItems.add(oppService2);
        Opportunity_Line_Item__c oppProduct = UnitTestDataFactory.createOpportunityLineItemService('testService3',oppList[0],null,true,'DH_AU_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        oppproduct.Line_item_type__c = 'Product';
        lineItems.add(oppProduct);
        Opportunity_Line_Item__c oppProduct2 = UnitTestDataFactory.createOpportunityLineItemService('testService3',oppList[0],null,true,'DH_AU_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        oppproduct2.Line_item_type__c = 'Product';
        oppproduct2.Sub_type__c = 'Ad Sales';
        lineItems.add(oppProduct2);
        Opportunity_Line_Item__c oppProduct3 = UnitTestDataFactory.createOpportunityLineItemService('testService3',oppList[0],null,true,'DH_AU_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        oppproduct3.Line_item_type__c = 'Product';
        oppproduct3.Sub_type__c = Label.CD_Special_Offer;
        lineItems.add(oppProduct3);
        insert lineItems;
        List<Opportunity_Line_Item__c> listOppService = [select id,Sub_Type__c from Opportunity_Line_Item__c where Id_Opportunity__r.name=: oppList[0].Name AND Line_Item_Type__c = 'Service'];
        List<Opportunity_Line_Item__c> listOppProduct = [select id from Opportunity_Line_Item__c where Id_Opportunity__r.name=:oppList[0].Name AND Line_Item_Type__c = 'Product'];
        

        System.runAs(testUser){

            Test.startTest();
                ClsRemoteController.updateOpportunityType(oppList[0].id);
            Test.stopTest();
        }
        List<Opportunity> result = [select type from opportunity where id=: oppList[0].id];
        //System.assertEquals(result[0].type,'Contract & Product');
    }

    @isTest static void test_updateOpportunityType_positive2(){
        accList = UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());
        insert oppList;
        List<Opportunity_Line_Item__c> listOppService = [select id,Sub_Type__c from Opportunity_Line_Item__c where Id_Opportunity__r.name=: oppList[0].Name AND Line_Item_Type__c = 'Service'];
        List<Opportunity_Line_Item__c> listOppProduct = [select id from Opportunity_Line_Item__c where Id_Opportunity__r.name=:oppList[0].Name AND Line_Item_Type__c = 'Product'];
        Business_Config__c b1x = new Business_Config__c(Business_Rule_Name__c='Additional Contract',Business_Rule_Value__c='White Label Website Fee,Order Now Button Fee',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='OppTypeAndServiceType',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        
        System.runAs(testUser){
            insert b1x;
            delete listOppProduct;
            
            Test.startTest();
                ClsRemoteController.updateOpportunityType(oppList[0].id);
            Test.stopTest();
        }
        List<Opportunity> result = [select type from opportunity where id=: oppList[0].id];
        //System.assertEquals(result[0].type,'Contract Only');
    }
    
    @isTest static void test_updateOpportunityType_positive3(){
        accList = UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());
        insert oppList;
        List<Opportunity_Line_Item__c> listOppService = [select id,Sub_Type__c from Opportunity_Line_Item__c where Id_Opportunity__r.name=: oppList[0].Name AND Line_Item_Type__c = 'Service'];
        List<Opportunity_Line_Item__c> listOppProduct = [select id from Opportunity_Line_Item__c where Id_Opportunity__r.name=:oppList[0].Name AND Line_Item_Type__c = 'Product'];
        Business_Config__c b1x = new Business_Config__c(Business_Rule_Name__c='Additional Contract',Business_Rule_Value__c='White Label Website Fee,Order Now Button Fee',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='OppTypeAndServiceType',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        
        System.runAs(testUser){
           insert b1x;
            delete listOppService;
            
            Test.startTest();
                ClsRemoteController.updateOpportunityType(oppList[0].id);
            Test.stopTest();
        }
        List<Opportunity> result = [select type from opportunity where id=: oppList[0].id];
        //System.assertEquals(result[0].type,'Product Only');
    }

    @isTest static void test_updateOpportunityType_positive4(){
        accList = UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());
        insert oppList;
        List<Opportunity_Line_Item__c> listOppService = [select id,Sub_Type__c from Opportunity_Line_Item__c where Id_Opportunity__r.name=: oppList[0].Name AND Line_Item_Type__c = 'Service'];
        List<Opportunity_Line_Item__c> listOppProduct = [select id from Opportunity_Line_Item__c where Id_Opportunity__r.name=:oppList[0].Name AND Line_Item_Type__c = 'Product'];
        Business_Config__c b1x = new Business_Config__c(Business_Rule_Name__c='Additional Contract',Business_Rule_Value__c='White Label Website Fee,Order Now Button Fee',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='OppTypeAndServiceType',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        
        System.runAs(testUser){
           insert b1x;
            for(Opportunity_Line_Item__c opps: listOppService){
                opps.Sub_Type__c='White Label Website Fee';
            }
            update listOppService;
            delete listOppProduct;
            
            Test.startTest();
                ClsRemoteController.updateOpportunityType(oppList[0].id);
            Test.stopTest();
        }
        List<Opportunity> result = [select type from opportunity where id=: oppList[0].id];
        //System.assertEquals(result[0].type,'Additional Contract');
    }

    @isTest static void test_updateOpportunityType_positive5(){
        accList = UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());
        insert oppList;
        List<Opportunity_Line_Item__c> listOppService = [select id,Sub_Type__c from Opportunity_Line_Item__c where Id_Opportunity__r.name=: oppList[0].Name AND Line_Item_Type__c = 'Service'];
        List<Opportunity_Line_Item__c> listOppProduct = [select id from Opportunity_Line_Item__c where Id_Opportunity__r.name=:oppList[0].Name AND Line_Item_Type__c = 'Product'];
        Business_Config__c b1x = new Business_Config__c(Business_Rule_Name__c='Additional Contract',Business_Rule_Value__c='White Label Website Fee,Order Now Button Fee',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='OppTypeAndServiceType',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        
        System.runAs(testUser){
            insert b1x;
            for(Opportunity_Line_Item__c opps: listOppService){
                opps.Sub_Type__c='White Label Website Fee';
            }
            update listOppService;
            delete listOppProduct;
            
            Test.startTest();
                ClsRemoteController.updateOpportunityType(oppList[0].id);
            Test.stopTest();
        }
        List<Opportunity> result = [select type from opportunity where id=: oppList[0].id];
        //System.assertEquals(result[0].type,'Additional Contract');
    }
   
    /*@isTest static void test_CalculateSalesTarget(){
        //Added by Bhupendra Start      
        Company__c com = UnitTestDataFactory.createCompany('Delivery Hero Australia', 'DH_AU', c_au);
        insert new List<sObject>{com};
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,c_au,'Apple','DH_AU_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,c_au,'Setup Fee','DH_AU_List_Product_Group');
        List_Product_Group__c lpg2 = UnitTestDataFactory.createProductGroup(com,c_au,'Terminal','DH_AU_List_Product_Group');
        Account acc1 = UnitTestDataFactory.createAccount('TestAccount1',c_au,'DH_AU_Account');
        insert new List<sObject>{lpg,lpg1,lpg2,acc1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,c_au,'Ipad 4 Gen. 16GB',lpg.id,'DH_AU_List_Product_Price',1,true,100,1,false,20);        
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,c_au,'Super Hero Setup 1',lpg1.id,'DH_AU_List_Product_Price',1,true,100,1,false,null);
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,c_au,'Super Hero Setup 2',lpg1.id,'DH_AU_List_Product_Price',1,true,50,1,true,20);
        List_Product_Price__c lpp3 = UnitTestDataFactory.createProduct(com,c_au,'Terminal A (One-time Payment)',lpg2.id,'DH_AU_List_Product_Price',1,true,100,1,false,null);
        List_Product_Price__c lpp4 = UnitTestDataFactory.createProduct(com,c_au,'Premium Placement API',lpg2.id,'DH_AU_List_Product_Price',null,true,0,1,false,null);
        List_Service_Price__c lsp = UnitTestDataFactory.createService(com,c_au,'testService1','DH_AU_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        List_Service_Price__c lsp1 = UnitTestDataFactory.createService(com,c_au,'testService2','DH_AU_List_Service_Price',12,12,13,5,null,true,null,'Commission','ServiceType');
        List_Service_Price__c lsp2 = UnitTestDataFactory.createService(com,c_au,'testService3','DH_AU_List_Service_Price',12,12,13,5,null,true,null,'Commission','ServiceType');
    
        Tarif__c t = UnitTestDataFactory.createTarif(com,c_au,'testTarif1','DH_AU_Tarif',false);
        Tarif__c t1 = UnitTestDataFactory.createTarif(com,c_au,'testTarif2','DH_AU_Tarif',false);
        insert new List<sObject>{lpp,lpp1,lpp2,lpp3,lpp4,lsp,lsp1,lsp2,t,t1};
        Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp456',acc1,'DH_AU_Opportunity',Date.today());
        opp1.type = 'Contract & Product';
        opp1.Id_Tarif__c = t1.id;

        insert new List<sObject>{opp1};
        
        Tarif_Member__c tm = UnitTestDataFactory.createTarifMember(lpp.id,'DH_AU_Tarif_Member',t.id,'Product');
        Tarif_Member__c tm1 = UnitTestDataFactory.createTarifMember(lpp3.id,'DH_AU_Tarif_Member',t.id,'Product');
        Tarif_Member__c tm2 = UnitTestDataFactory.createTarifMember(lsp.id,'DH_AU_Tarif_Member',t.id,'Service');
        Tarif_Member__c tm3 = UnitTestDataFactory.createTarifMember(lsp2.id,'DH_AU_Tarif_Member',t1.id,'Service');
        Tarif_Member__c tm4 = UnitTestDataFactory.createTarifMember(lpp2.id,'DH_AU_Tarif_Member',t1.id,'Product');
        Tarif_Member__c tm5 = UnitTestDataFactory.createTarifMember(lpp1.id,'DH_AU_Tarif_Member',t1.id,'Product');
        Opportunity_Line_Item__c oppProduct = UnitTestDataFactory.createOpportunityLineItemProduct('Super Hero Setup 2',opp1,lpg1.id,lpp2.id,true,'DH_AU_Opportunity_Line_Item',1,'',50,1,50,'Setup Fee');
        Opportunity_Line_Item__c oppProduct2 = UnitTestDataFactory.createOpportunityLineItemProduct('Super Hero Setup 1',opp1,lpg1.id,lpp1.id,true,'DH_AU_Opportunity_Line_Item',1,'',50,1,50,'Setup Fee');

        Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',opp1,lsp2.id,true,'DH_AU_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        
        insert new List<sObject>{tm,tm1,tm2,tm3,tm4,tm5};
        t.Is_Active__c = true;
        t1.Is_Active__c = true;
        update new List<Tarif__c>{t,t1};

        insert new List<sObject>{oppProduct,oppProduct2,oppService};
        //Added by Bhupendra End
        
        List<Sales_Target__c> st = new List<Sales_Target__c>();
        //UnitTestDataFactory.testDataFor_DH_AU_ContractProcess();
        List<List_Product_Price__c> listPP = [select id,Product_Name__c,CurrencyIsoCode,Id_List_Product_Group__c from List_Product_Price__c ];
        for(List_Product_Price__c lp : listPP){
            st.add(new Sales_Target__c(Product_Target__c=lp.Id,Type__c='Product',Sales_Rep__c=testUser.Id,CurrencyIsoCode=lp.CurrencyIsoCode,From__c=Date.today().addDays(-5),To__c=Date.today().addDays(5),RecordTypeId=mapRecordtypes.get('DH_AU_Sales_Target').Id));
        }
        List<List_Service_Price__c> listSP  = [select id, name,CurrencyIsoCode from List_Service_Price__c];
        for(List_Service_Price__c ls: listSP){
                st.add(new Sales_Target__c(Commission_Target__c=ls.Id,Type__c='Service',Sales_Rep__c=testUser.Id,CurrencyIsoCode=ls.CurrencyIsoCode,From__c=Date.today().addDays(-5),To__c=Date.today().addDays(5),RecordTypeId=mapRecordtypes.get('DH_AU_Sales_Target').Id));
        }
        insert st;

        System.runAs(testUser){
            accList = UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
            insert accList;
            List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());
            insert oppList;
            oppQuoteList = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1,'DH_AU_Opportunity_Quote','Draft','test data',100.45,100.45,'','',0);
            insert oppQuoteList;

            Test.startTest();
                oppList[0].stageName='Closed Won';
                oppList[0].Probability = 100;
                update oppList[0];
            Test.stopTest();
        
        }    
        List<ID> stid = new List<ID>();
        for(Sales_Target__c ss : [select id,Product_Target__c,Product_Target__r.name,Commission_Target__c,Commission_Target__r.name,Units_Achieved__c,Revenue_Achieved__c,NoOfCommissionInPercent__c,Closed_Deals__c from Sales_Target__c]){
            system.debug('ss**'+ss);
            stid.add(ss.Id);
            if(ss.Product_Target__c!=null && ss.Product_Target__r.name=='Super Hero Setup 1'){
                System.assertEquals(ss.Closed_Deals__c,1);
            }else if(ss.Product_Target__c!=null && ss.Product_Target__r.name=='Super Hero Setup 2'){
                System.assertEquals(ss.Closed_Deals__c,1);
            }else if(ss.Commission_Target__c!=null && ss.Commission_Target__r.name=='testService3'){
                //System.assertEquals(ss.Closed_Deals__c,1);
            }
        }
        
        //ClsRemoteController.calculateSalesTarget(stid);
        List<Sales_Target__c> newST = new List<Sales_Target__c>();
        for(List_Product_Price__c lp : listPP){
            newST.add(new Sales_Target__c(Product_Group__c=lp.Id_List_Product_Group__c,Type__c='Product',Sales_Rep__c=testUser.Id,CurrencyIsoCode=lp.CurrencyIsoCode,From__c=Date.today().addDays(-5),To__c=Date.today().addDays(5),RecordTypeId=mapRecordtypes.get('DH_AU_Sales_Target').Id));
        }
        newST.add(new Sales_Target__c(Type__c='Product',Sales_Rep__c=testUser.Id,CurrencyIsoCode=listPP[0].CurrencyIsoCode,From__c=Date.today().addDays(-5),To__c=Date.today().addDays(5),RecordTypeId=mapRecordtypes.get('DH_AU_Sales_Target').Id));
        newST.add(new Sales_Target__c(Type__c='Service',Sales_Rep__c=testUser.Id,CurrencyIsoCode=listPP[0].CurrencyIsoCode,From__c=Date.today().addDays(-5),To__c=Date.today().addDays(5),RecordTypeId=mapRecordtypes.get('DH_AU_Sales_Target').Id));
        
        insert newST;
        for(Sales_Target__c aa: newST){
            stid.add(aa.Id);
        }

        ClsRemoteController.calculateSalesTarget(stid);
        System.Debug('ClsRemoteController.calculateSalesTarget : ' + ClsRemoteController.calculateSalesTarget(stid));
    }*/
    
    @isTest static void test_approveQuote6(){
        accList = UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        oppQuoteList = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1,'Yogiyo_Opportunity_Quote','Draft','test data',100.45,100.45,'','',0);
        insert oppQuoteList;
        List<Opportunity_Line_Item__c> listOppService = [select id,Sub_Type__c from Opportunity_Line_Item__c where Id_Opportunity__r.name=:oppList[0].Name AND Line_Item_Type__c = 'Service'];
        List<Opportunity_Line_Item__c> listOppProduct = [select id from Opportunity_Line_Item__c where Id_Opportunity__r.name=:oppList[0].Name AND Line_Item_Type__c = 'Product'];
        
        System.runAs(testUser){
            Test.startTest();
                List<string> quoteApprove= ClsRemoteController.approveQuote(oppQuoteList[0].id);
            Test.stopTest();
        }
    }
    
    @isTest static void test_approveQuoteLevel1(){
        accList = UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        oppQuoteList = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1,'Yogiyo_Opportunity_Quote','Approval pending','test data',100.45,100.45,'','',0);
        oppQuoteList [0].Approval_L2__c = false;
        insert oppQuoteList;
        List<Opportunity_Line_Item__c> listOppService = [select id,Sub_Type__c from Opportunity_Line_Item__c where Id_Opportunity__r.name=:oppList[0].Name AND Line_Item_Type__c = 'Service'];
        List<Opportunity_Line_Item__c> listOppProduct = [select id from Opportunity_Line_Item__c where Id_Opportunity__r.name=:oppList[0].Name AND Line_Item_Type__c = 'Product'];
        
        System.runAs(testUser){
            Test.startTest();
                List<string> quoteApprove= ClsRemoteController.approveQuote(oppQuoteList[0].id);
            Test.stopTest();
        }
    }
    
    @isTest static void test_approveQuoteLevel2(){
        accList = UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        oppQuoteList = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1,'Yogiyo_Opportunity_Quote','Approval pending','test data',100.45,100.45,'','',0);
        oppQuoteList [0].Approval_L2__c = true;
        insert oppQuoteList;
        List<Opportunity_Line_Item__c> listOppService = [select id,Sub_Type__c from Opportunity_Line_Item__c where Id_Opportunity__r.name=:oppList[0].Name AND Line_Item_Type__c = 'Service'];
        List<Opportunity_Line_Item__c> listOppProduct = [select id from Opportunity_Line_Item__c where Id_Opportunity__r.name=:oppList[0].Name AND Line_Item_Type__c = 'Product'];
        
        System.runAs(testUser){
            Test.startTest();
                List<string> quoteApprove= ClsRemoteController.approveQuote(oppQuoteList[0].id);
            Test.stopTest();
        }
    }
    
    @isTest static void test_approveQuoteLevel1AppStatus(){
        accList = UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        oppQuoteList = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1,'Yogiyo_Opportunity_Quote','Pending - legal','test data',100.45,100.45,'','',0);
        oppQuoteList [0].Approval_L2__c = true;
        insert oppQuoteList;
        List<Opportunity_Line_Item__c> listOppService = [select id,Sub_Type__c from Opportunity_Line_Item__c where Id_Opportunity__r.name=:oppList[0].Name AND Line_Item_Type__c = 'Service'];
        List<Opportunity_Line_Item__c> listOppProduct = [select id from Opportunity_Line_Item__c where Id_Opportunity__r.name=:oppList[0].Name AND Line_Item_Type__c = 'Product'];
        
        System.runAs(testUser){
            Test.startTest();
                List<string> quoteApprove= ClsRemoteController.approveQuote(oppQuoteList[0].id);
            Test.stopTest();
        }
    }
    
    @isTest static void test_rejectQuote6(){
        accList = UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        oppQuoteList = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1,'Yogiyo_Opportunity_Quote','Pending - legal','test data',100.45,100.45,'','',0);
        oppQuoteList [0].Approval_L2__c = true;
        insert oppQuoteList;
        List<Opportunity_Line_Item__c> listOppService = [select id,Sub_Type__c from Opportunity_Line_Item__c where Id_Opportunity__r.name=:oppList[0].Name AND Line_Item_Type__c = 'Service'];
        List<Opportunity_Line_Item__c> listOppProduct = [select id from Opportunity_Line_Item__c where Id_Opportunity__r.name=:oppList[0].Name AND Line_Item_Type__c = 'Product'];
        
        System.runAs(testUser){
            Test.startTest();
                List<string> quoteApprove= ClsRemoteController.rejectQuote(oppQuoteList[0].id);
            Test.stopTest();
        }
        
    }
}