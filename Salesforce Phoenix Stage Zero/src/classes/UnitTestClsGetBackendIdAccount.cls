@isTest
public class UnitTestClsGetBackendIdAccount {
    static List<Account> accounts, tbAcc, seAcc;
    static {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert testCountry;
        Country__c conTalabat = UnitTestDataFactory.createCountry('BH', 'Baharain', 'BHD');
        insert conTalabat;
         Country__c conSweden = UnitTestDataFactory.createCountry('SE', 'Sweden', 'SEK');
        insert conSweden;
        List<Integration_Config__c> integrationSettings = new List<Integration_Config__c>();
        integrationSettings.add(new Integration_Config__c(name = 'Talabat', ClientId__c = 'test', clientSecret__c = 'test123',
                                endpoint__c = 'http://talabat/', username__c = 'uksfuser',
                                CountryCode__c = '{"Kuwait":1,"Kingdom of Saudi Arabia":2,"Bahrain": 3,"United Arab Emirates":4,"Oman":5, "Qatar":6, "Lebanon":7,"Jordan":8}',
                                PlatformCode__c = '{"Talabat":1,"FoodOnClick":2,"IFOOD":3}', password__c = 'SFs3cr3tPw'));
        integrationSettings.add(new Integration_Config__c(name = 'Sweden', ClientId__c = 'test', clientSecret__c = 'test123',
                                endpoint__c = 'http://sweden/', username__c = 'uksfuser',
                                CountryCode__c = '{"Kuwait":1,"Kingdom of Saudi Arabia":2,"Bahrain": 3,"United Arab Emirates":4,"Oman":5, "Qatar":6, "Lebanon":7,"Jordan":8}',
                                PlatformCode__c = '{"Talabat":1,"FoodOnClick":2,"IFOOD":3}', password__c = 'SFs3cr3tPw'));
        insert integrationSettings;

        Company__c testCompany = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
        insert testCompany;
        Company__c comTalabat = UnitTestDataFactory.createCompany('Talabat', 'Talabat', conTalabat);
        insert comTalabat;
        Company__c comSweden = UnitTestDataFactory.createCompany('OnlinePizza', 'SE', conSweden);
        insert comSweden;
        accounts = UnitTestDataFactory.createAccounts(5, testCountry, 'Yogiyo_Account');
        accounts[0].Type = 'Client';
        accounts[1].Type = 'Franchise';
        accounts[2].Type = 'Branch';
        accounts[3].Type = 'Brand';
        accounts[4].Type = 'Group';
        insert accounts;

        seAcc = UnitTestDataFactory.createAccounts(5, conSweden, 'SE_Account');
        insert seAcc;


        tbAcc = UnitTestDataFactory.createAccounts(3, conTalabat, 'Talabat_Account');
        tbAcc[0].Type = 'Group';
        tbAcc[1].Type = 'Brand';
        tbAcc[2].Type = 'Branch';

        tbAcc[0].platform__c = 'Talabat';
        tbAcc[1].platform__c = 'Talabat;FoodOnClick';
        tbAcc[2].platform__c = 'Talabat;FoodOnClick';

        tbAcc[0].Area__c = '10';
        tbAcc[1].Area__c = '10';
        tbAcc[2].Area__c = '10';

        insert tbAcc;

        List<AddressDetail__c> tbAccsAddress = new List<AddressDetail__c>();
        for (Account acc : tbAcc) {
            tbAccsAddress.add(new AddressDetail__c(
                                  SubAdministrativeAreaCode__c = '123',
                                  Type__c = 'Restaurant Address',
                                  Account__c = acc.Id
                              ));
        }
        insert tbAccsAddress;


        //Create Contact
        Contact con = new Contact();
        con.LastName = 'TestMe2017';
        con.Email = 'bbb@sas.ns';
        con.AccountId = accounts[2].Id;
        insert con;

        BEIntegration_CountriesToCities__c cntCit = new BEIntegration_CountriesToCities__c();
        cntCit.Name = 'Hallo';
        cntCit.City_Backend_Id__c = '12';
        cntCit.Country_Backend_Id__c = '12';
        cntCit.Country_Code__c = 'SE';
        insert cntCit;
    }

    @isTest static void testCallout_Company() {
        String res =  ClsGetBackendIdAccount.getBackendIdAccount(accounts[0].Id, 'Client');
        String res1 = ClsGetBackendIdAccount.getBackendIdAccount(accounts[1].Id, 'Franchise');
        String res2 = ClsGetBackendIdAccount.getBackendIdAccount(accounts[0].Id, 'Branch');
        String res3 = ClsGetBackendIdAccount.getBackendIdAccount(accounts[3].Id, 'Brand');

    }

    @istest static void testTalabatBackend() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        String res4 = ClsGetBackendIdAccount.getBackendIdTalabat(String.valueof(tbAcc[0].Id), 'Group');
        String res5 = ClsGetBackendIdAccount.getBackendIdTalabat(String.valueof(tbAcc[1].Id), 'Brand');
        String res6 = ClsGetBackendIdAccount.getBackendIdTalabat(String.valueof(tbAcc[2].Id), 'Branch');

        Test.stopTest();
    }

     @istest static void testSwedenBackend() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        String res4 = ClsGetBackendIdAccount.createBackendIDSweden(String.valueof(seAcc[0].Id), 'test acc');
        

        Test.stopTest();
    }

}