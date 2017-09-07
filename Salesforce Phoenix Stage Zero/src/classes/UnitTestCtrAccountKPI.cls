@isTest
private class UnitTestCtrAccountKPI{

    private static User testUser;
    private static Country__c testCountry;
    private static Company__c testCompany;
    private static List<Account> accounts;
    
    static {
        UnitTestDataFactory.getRecordtypeValues();
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
       // testUser = UnitTestDataFactory.createUser('UK Sales Management', 'uk@test.com', 'HungryHouse', 'UK');
        //insert testUser;
        
        //System.runAs(testUser){
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
            accounts[0].review_comments__c='{"root":{"header":"Review Comment History","data":[{"OrderDate":"2016-04-23 20:27:00 (SAT)","OrderId":"30161777", "RatingQuality":"4","RatingSpeed":"5","RatingValue":"4","ReviewComment":"Very good - enjoyed the masala fish starter in particular. Speed of delivery phenomenal. Meal came in under 30 minutes. Compared to the other Indian takeaways in the area this is superb." }]}}';
            accounts[0].Contact_Log__c='{"root":{"header":"Contacts Logged History","data":[{"ContactDate":"2016-04-27 19:36:01 (WED)","ContactFrom":"Customer","ContactType":"Chat","ContactAgent":"Adam Merai","OrderId":"88810559","ContactReason":"User Error","ContactNotes":"hacked account"}]}}';
            accounts[0].Delivery_time__c='{ "root":{"header":"Order Failure History","data":[{"OrderId":"34295957","OrderStatus":"Cancelled","OrderDate":"2016-04-27 22:52:13 (WED)","OrderAmount":"£12.49","Postcode":"E11 4JQ","Reason":"Restaurant closed - no answer"}]}}';
            accounts[0].Delivery_Zone__c='{"root":{"header":"April KPIs | Location: E2 - Cuisine: Pizza & Fast Food - Revenue (Avg): £1031", "data":[{"Shortcode":"EC1V","RestaurantCoverage":"100%","RestaurantOrders":"3","RestaurantOrdersPerc":"42.86%","AreaOrders":"1","AreaRestaurants":"245","AreaOpR":"0.0","AreaYoY":"-92.86%","AreaRevenueAvg":"£20.55","AreaCustomers":"2364","AreaBasket":"£0.00","AreaCuisineOrders":"490","AreaCuisineRestaurants":"49"}]}}';
             accounts[0].NPS_Response_History__c='{"root":{ "header":"NPS History", "data":[{"NPSType":"Contact (Call / Email)","NPSDate":"2016-04-20","NPSScore":"10","NPSContact":"soransalim90@yahoo.com","NPSReason":"NA","NPSFeedback":"Promoter: Contacting Customer Care Was Very Easy (Thanks)"}]}}';
            insert accounts;
       // }
    }
    
    static testmethod void UnitTest1(){
        List<ctrAccountKPI.ReviewWrapper> reviewLst;
        Test.startTest();
        
        //System.runas(testuser){
            
            //ctrAccountKPI ctrl = new ctrAccountKPI();
            reviewLst=ctrAccountKPI.getAccReviews(accounts[0].id);
            
       // }
        Test.stopTest();
        System.assert(!reviewLst.isEmpty());
        
        
    }
}