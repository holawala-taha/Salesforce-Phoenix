@isTest
private class UnitTestCtrAccountList {

    private static User runningUser = UnitTestDataFactory.createUser('UK Sales Management', 'testUser@deliveryherotest.com', 'UK', 'UK');

    static Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Case'});
    private static Account acc_uk;
    private static Country__c c_uk;
    private static USerRole ur;
    private static Company__c com_uk;


    @testSetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        List<MidasIntegration__c> midasIntg = new List<MidasIntegration__c>();
        midasIntg.add(new MidasIntegration__c(name = 'UK', EndPoint__c = 'http://midas.medusa-hero.com/backend/', AuthenticationToken__c = 'WyI0IiwiYzUwNjRkMmQ2MWUwNTE3YjVhNjRmMTk4Yjc2NmFiODgiXQ.CgtJbA.kFY4BLsKd3XXiXg7QtVxmLqZ7i0'));
        insert midasIntg;
    }

    static void setupUserData() {
        c_uk = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
        com_uk = UnitTestDataFactory.createCompany('hungryhouse', 'UK', c_uk);
        insert new List<sObject> {c_uk, com_uk};
        acc_uk = UnitTestDataFactory.createAccount('TestAccount', c_uk, 'UK_Account');
        acc_uk.Backend_ID__c = '2266';
        insert new List<sObject> {acc_uk};
    }

    @isTest static void test_AccountList() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        System.runAs(runningUser) {
            setupUserData();

            
            String result = CtrAccountList.loadAccountList(true, 'UK Sales Management');

            System.debug('result: ' + result);
            //System.assertEquals(result.contains('restaurant_id'));
        }
        Test.stopTest();
    }

    @isTest static void test_createOpp() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        System.runAs(runningUser) {
            setupUserData();
            Tarif__c t = UnitTestDataFactory.createTarif(com_uk, c_uk, 'Premium Placement', 'UK_Tarif', false);
            insert t;

            
            String result = CtrAccountList.createOpportunity(acc_uk.Id);

            Opportunity Opp = [select id, Record_Country__c from Opportunity where id = :result];
            //System.assertNotEquals(Opp,null);
        }
        Test.stopTest();
    }


    @isTest static void test_getOppLines() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        System.runAs(runningUser) {
            setupUserData();
            Tarif__c t = UnitTestDataFactory.createTarif(com_uk, c_uk, 'Premium Placement', 'UK_Tarif', false);
            List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_uk, c_uk, 'Premium Placement', 'UK_List_Product_Group');
            insert new List<sObject> {lpg, t};
            List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_uk, c_uk, 'Premium Placement', lpg.id, 'UK_List_Product_Price', 1, true, 100, 1, false, 20);
            insert lpp;
            Opportunity opp = UnitTestDataFactory.createOpportunity('TestOppUK', acc_uk, 'UK_Opportunity', Date.today());
            insert opp;
            Opportunity_Line_Item__c oppProduct = UnitTestDataFactory.createOpportunityLineItemProduct('Premium Placement', opp, lpg.id, lpp.id, true, 'UK_Opportunity_Line_Item', 1, '', 50, 1, 50, 'Premium Placement');
            oppProduct.Booking_Api_Id__c = '58983';
            insert oppProduct;

            
            String result1 = CtrAccountList.getOppLineItems(null, '58983');
            List<Opportunity_Line_Item__c> opplines1 = (List<Opportunity_Line_Item__c>) JSON.deserialize(result1, List<Opportunity_Line_Item__c>.class);
            String result2 = CtrAccountList.getOppLineItems('2266', null);
            List<Opportunity_Line_Item__c> opplines2 = (List<Opportunity_Line_Item__c>) JSON.deserialize(result2, List<Opportunity_Line_Item__c>.class);
            String result3 = CtrAccountList.getOppLineItems('2266,2266', null);
            List<Opportunity_Line_Item__c> opplines3 = (List<Opportunity_Line_Item__c>) JSON.deserialize(result2, List<Opportunity_Line_Item__c>.class);
            String result4 = CtrAccountList.getOppLineItems(null, '58983,58984');
            List<Opportunity_Line_Item__c> opplines4 = (List<Opportunity_Line_Item__c>) JSON.deserialize(result2, List<Opportunity_Line_Item__c>.class);

            //System.assertEquals(opplines1.size(),1);
            //System.assertEquals(opplines2.size(),1);
        }
        Test.stopTest();
    }


    @isTest static void test_cancelBookings() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        System.runAs(runningUser) {
            setupUserData();
            Tarif__c t = UnitTestDataFactory.createTarif(com_uk, c_uk, 'Premium Placement', 'UK_Tarif', false);
            List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_uk, c_uk, 'Premium Placement', 'UK_List_Product_Group');
            insert new List<sObject> {lpg, t};
            List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_uk, c_uk, 'Premium Placement', lpg.id, 'UK_List_Product_Price', 1, true, 100, 1, false, 20);
            insert lpp;
            Opportunity opp = UnitTestDataFactory.createOpportunity('TestOppUK', acc_uk, 'UK_Opportunity', Date.today());
            insert opp;
            Opportunity_Line_Item__c oppProduct = UnitTestDataFactory.createOpportunityLineItemProduct('Premium Placement', opp, lpg.id, lpp.id, true, 'UK_Opportunity_Line_Item', 1, '', 50, 1, 50, 'Premium Placement');
            oppProduct.Booking_Api_Id__c = '58983';
            insert oppProduct;

            
            String result = CtrAccountList.cancelBookings(new List<CtrAccountList.Bookings> {new CtrAccountList.Bookings('58983', oppProduct.id)}, 'UK Sales Management', 'test@deliveryhero.com');

            //System.assertEquals(result,'success');
        }
        Test.stopTest();
    }


    @isTest static void test_loadPPSlots() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        System.runAs(runningUser) {
            setupUserData();

            
            String result = CtrAccountList.loadPPSlots('CM18', 'UK Sales Management', '2016', '8');
            String result2 = CtrAccountList.loadPPSlots(null, 'UK Sales Management', '2016', '8');

            System.debug('result: ' + result);
            //System.assert(result.contains('status'));
        }
        Test.stopTest();
    }

    @isTest static void test_loadPPAccounts() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        System.runAs(runningUser) {
            setupUserData();

            
            String result = CtrAccountList.loadPPAccounts('N1', 'UK Sales Management', false, '2016-08-08');
            String result2 = CtrAccountList.loadPPAccounts('N1', 'UK Sales Management', true, '2016-08-10');
            String result3 = CtrAccountList.loadPPAccounts(null, 'UK Sales Management', true, '2016-08-09');


            System.debug('result: ' + result);
            //System.assert(result.contains('sf_restaurant_id'));
        }
        Test.stopTest();
    }


}