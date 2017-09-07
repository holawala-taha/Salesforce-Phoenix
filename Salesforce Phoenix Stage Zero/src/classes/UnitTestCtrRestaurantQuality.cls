@isTest
private class UnitTestCtrRestaurantQuality {

    static void setup() {
        UnitTestDataFactory.getRecordtypeValues();

        Country__c c1 = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
        c1.Restaurant_Quality_Code__c = 'ABC';

        Country__c c2 = UnitTestDataFactory.createCountry('CO', 'Colombia', 'USD');
        c2.Restaurant_Quality_Code__c = 'DEF';

        Country__c c3 = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'USD');
        c3.Restaurant_Quality_Code__c = 'GHI';

        insert new List<Country__c> {c1, c2, c3};    
    }

    @isTest
    static void getCountryBrandCodesPerCurrentUserReturnsCorrectly() {
        setup();

        User current = [Select CountryCode__c From User Where Id =: UserInfo.getUserId()];
        current.CountryCode__c = 'EC;CO';
        update current;

        PageReference ref = Page.RestaurantQuality;
        Map<String, String> res;

        Test.startTest();

        Test.setCurrentPage(ref);

        res = CtrRestaurantQuality.getCountryBrandCodesPerCurrentUser();

        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assert(!res.isEmpty());

        System.assert(res.containsKey('Ecuador'));
        System.assert(res.containsKey('Colombia'));
        System.assert(!res.containsKey('Bahrain'));
    }

    @isTest
    static void getCountryBrandCodesPerCurrentUserReturnsEmptyMapIfCountryCOdeIsNull() {
        setup();

        User current = [Select CountryCode__c From User Where Id =: UserInfo.getUserId()];
        current.CountryCode__c = '';
        update current;

        PageReference ref = Page.RestaurantQuality;
        Map<String, String> res;

        Test.startTest();

        Test.setCurrentPage(ref);

        res = CtrRestaurantQuality.getCountryBrandCodesPerCurrentUser();

        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assert(res.isEmpty());
    }

    @isTest
    static void ctrRestaurantQualityBuildCOrrectly() {
        PageReference pref = Page.RestaurantQuality;
        CtrRestaurantQuality ctr;

        Test.startTest();

        Test.setCurrentPage(pref);
        ctr = new CtrRestaurantQuality();

        Test.stopTest();
    }

    @isTest
    static void getRestaurantsReturnsCorrectly() {
        PageReference pref = Page.RestaurantQuality;
        ClsRestaurantQualityApi.ResponseWrapper res;

        Test.startTest();
        Test.setCurrentPage(pref);

        res = CtrRestaurantQuality.getRestaurants('Ecuador');

        Test.stopTest();

        System.assertNotEquals(null, res);
    }

    @isTest
    static void assignFirstReturnsCorrectly() {
        PageReference pref = Page.RestaurantQuality;
        ClsRestaurantQualityApi.ResponseWrapper res;

        Test.startTest();
        Test.setCurrentPage(pref);

        res = CtrRestaurantQuality.assignFirst('Ecuador');

        Test.stopTest();

        System.assertNotEquals(null, res);
    }
}