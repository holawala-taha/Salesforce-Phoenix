@isTest
private class UnitTestCtrRestaurantCare{
    static Map<String,RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Case'});
    private static User testUser;
    private static Country__c testCountry;
    private static Company__c testCompany;
    private static List<Account> accounts;
    private static List<case> csLst = new List<Case>();
    
    static {
        UnitTestDataFactory.getRecordtypeValues();
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        //testUser = UnitTestDataFactory.createUser('UK Sales Management', 'uk@test.com', 'HungryHouse', 'UK');
        //insert testUser;
        
       // System.runAs(testUser){
            testCountry = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
            insert testCountry;
            testCompany = UnitTestDataFactory.createCompany('HungryHouse', 'HungryHouse', testCountry);
            insert testCompany;
            accounts = UnitTestDataFactory.createAccounts(2, testCountry, 'UK_Account'); 
            accounts[0].Payment_method__c = 'Cash';
            accounts[1].Payment_Method__c = 'Credit Card';
            accounts[0].BillingState = 'CA';
            accounts[0].BillingCity = 'San Francisco';
            accounts[0].BillingPostalCode = '12345';
            accounts[0].BillingStreet = 'test str. 22';
            accounts[0].Delivery_servicepicklist__c = 'no';
            insert accounts;
            
            
            Case Onboarding= new Case( Type = 'Onboarding',
                                           RecordTypeId=mapRecordtypes.get('UK_Restaurant_Operations').id,
                                           Status = 'New', accountid=accounts[0].id
                                        );
            Case Onboarding2= new Case( Type = 'test',
                                           RecordTypeId=mapRecordtypes.get('UK_Restaurant_Operations').id,
                                           Status = 'New', accountid=accounts[0].id
                                        );
            
            csLst.add(Onboarding);
            csLst.add(Onboarding2);
            insert csLst;
        //}
   }
   
    static testmethod void UnitTest1(){
        List<case> cLst;
        List<task> taskLst;
        Test.startTest();
        
        //System.runas(testuser){
            List<string> csIDs = new List<string>();
            csIds.add(csLst[0].id);
            //ctrAccountKPI ctrl = new ctrAccountKPI();
            cLst=CtrRestaurantCare.getCaseLst(accounts[0].id, csLst[0].id, 'UK_Restaurant_Operations',date.valueof(csLst[0].createddate));
            taskLst=CtrRestaurantCare.getTaskLst(csIds);
       // }
        Test.stopTest();
        System.assert(!cLst.isEmpty());
        
        
    }
   
   
}