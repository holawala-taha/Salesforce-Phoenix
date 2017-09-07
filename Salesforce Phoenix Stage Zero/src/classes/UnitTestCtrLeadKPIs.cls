@isTest
private class UnitTestCtrLeadKPIs{

    private static User testUser;
    private static Country__c testCountry;
    private static Company__c testCompany;
    private static List<Lead> leads;
    
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
            leads = UnitTestDataFactory.createLeads (2, testCountry, 'Mustermann', 'HungryHouse', 'GBP', 'Mustermann Food', 'UK_Lead');
            
            leads[0].postalcode='M60 1NW';
            leads[0].external_rating__c='2';
            leads[0].number_of_reviews__c=20;
            leads[0].review_source__c='Yelp';
            leads[0].feature_competitor__c='yes';
            leads[0].number_of_restaurants__c=1;
            leads[0].target_partner__c='Basic Lead';
            leads[0].Delivery_Zone__c='{ "root":{"Region":"West Midlands","City":"West Midlands","CityYoY":"39.10%","CompetitorLink":"http://www.just-eat.co.uk/restaurants-oriental-delights-willenhall/menu","CompetitorReviews":"334","Header":"April KPIs | Location: E2 - Cuisine: Pizza & Fast Food - Revenue (Avg): £1031","data":[{ "Shortcode":"EC1V","AreaOrders":"1","AreaRestaurants":"245","AreaOpR":"0.0","AreaYoY":"-92.86%","AreaRevenueAvg":"£20.55","AreaCustomers":"2364","AreaBasket":"£0.00","AreaCuisineOrders":"490", "AreaCuisineRestaurants":"49"}]}}';
          try{
              insert leads[0];
              leads[0].ownerid=testUser.id;
              update leads[0];
              system.debug(leads[0].id);
              }catch(Exception e){
                   system.debug('Exception -'+e);
              }
       // }
    }
    
    static testmethod void UnitTest1(){
        List<CtrLeadKPIs.LeadKPI> reviewLst;
        Test.startTest();
        
       // System.runas(testuser){
            
            //ctrAccountKPI ctrl = new ctrAccountKPI();
            reviewLst=ctrLeadKPIs.getLeadKPI(leads[0].id);
            
        //}
        Test.stopTest();
        System.assert(!reviewLst.isEmpty());
        
        
    }
}