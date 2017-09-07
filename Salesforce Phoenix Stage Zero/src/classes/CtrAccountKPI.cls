global with sharing class CtrAccountKPI{
    
    public CtrAccountKPI(ApexPages.StandardController stdController) {

    }

    @RemoteAction
    global static List<ReviewWrapper> getAccReviews(String accId){
        Account acc =[select review_comments__c,Contact_Log__c,Delivery_Time__c,Delivery_Zone__c,NPS_Response_History__c from account where id=:accId];
        String orderdate;
        String OrderId;
        String RatingQuality;
        String RatingSpeed;
        String RatingValue;
        String ReviewComment;
        JSONParser parser;
        List<ReviewWrapper> reviewsLstToDisplay = new List<ReviewWrapper>();
        List<ReviewWrapper> reviewsLst = new List<ReviewWrapper>();
        if(acc.review_comments__c!=null){
            parser = JSON.createParser(acc.review_comments__c);
            do{
                parser.nextToken();
            }while(parser.hasCurrentToken() && !'data'.equals(parser.getCurrentName()));
            parser.nextToken();
            reviewsLst= (List<ReviewWrapper>)parser.readValueAs(List<ReviewWrapper>.class);
            for(ReviewWrapper review :reviewsLst){                           
                //reviewsLstToDisplay.add(new ReviewWrapper(review.OrderDate,review.OrderId,review.RatingQuality,review.RatingSpeed,review.RatingValue,review.ReviewComment,'Review'));
                review.KPItype='Review';
            }
            reviewsLstToDisplay.addAll(reviewsLst);
        }
        //string contactLog=acc.Contact_Log__c;

        if(acc.Contact_Log__c!=null){
            reviewsLst = new List<ReviewWrapper>();
           
            Map<String, Object> resultsMap = (Map<String, Object>) JSON.deserializeUntyped(acc.Contact_Log__c);
             Map<String, Object> dataMap= (Map<String, Object>) resultsMap.get('root');
            List<Object> contactLog = (List<Object>) dataMap.get('data');

            for (Object o : contactLog) {
                Map<String, Object> conlog = (Map<String, Object>) o;
                //for(String s:conlog.keySet()){
                ReviewWrapper rw= new ReviewWrapper();
                if(conlog.get('OrderId') instanceof String){
                    rw.OrderId=(String)conlog.get('OrderId');
                   
                 }
                  if(conlog.get('ContactNotes') instanceof String){
                    rw.ContactNotes=(String)conlog.get('ContactNotes');
                   
                 }
                    rw.KPItype='ContactLog';
                    rw.ContactDate=(String)conlog.get('ContactDate');
                    rw.ContactType=(String)conlog.get('ContactType');
                    rw.ContactReason=(String)conlog.get('ContactReason');
                    rw.ContactFrom =(String)conlog.get('ContactFrom');
                    rw.ContactAgent =(String)conlog.get('ContactAgent');
                    reviewsLst.add(rw);

                System.debug('>>> ' + reviewsLst);
            }
            

            reviewsLstToDisplay.addAll(reviewsLst);
        }  
        if(acc.Delivery_Time__c!=null){
            reviewsLst = new List<ReviewWrapper>();
           parser = JSON.createParser(acc.Delivery_Time__c);
            //List<ReviewWrapper> reviewsLstToDisplay = new List<ReviewWrapper>();
            //List<ReviewWrapper> reviewsLst = new List<ReviewWrapper>();
            do{
                parser.nextToken();
            }while(parser.hasCurrentToken() && !'data'.equals(parser.getCurrentName()));
            parser.nextToken();
            reviewsLst= (List<ReviewWrapper>)parser.readValueAs(List<ReviewWrapper>.class);
            for(ReviewWrapper review :reviewsLst){                           
                //reviewsLstToDisplay.add(new ReviewWrapper(review.OrderDate,review.OrderId,review.RatingQuality,review.RatingSpeed,review.RatingValue,review.ReviewComment,'Review'));
                review.KPItype='Failure';
            }
            reviewsLstToDisplay.addAll(reviewsLst);
        }
        if(acc.Delivery_Zone__c!=null){
            reviewsLst = new List<ReviewWrapper>();
           parser = JSON.createParser(acc.Delivery_Zone__c);
            //List<ReviewWrapper> reviewsLstToDisplay = new List<ReviewWrapper>();
            //List<ReviewWrapper> reviewsLst = new List<ReviewWrapper>();
             ReviewWrapper rw = new ReviewWrapper();
            do{
                parser.nextToken();
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                
                    if(parser.getText() == 'Header') {
                        parser.nextToken();
                        rw.areaHeader = parser.getText();
                        rw.KPItype='DeliveryArea';
                    }
                 }
            }while(parser.hasCurrentToken() && !'data'.equals(parser.getCurrentName()));
            parser.nextToken();
            reviewsLst= (List<ReviewWrapper>)parser.readValueAs(List<ReviewWrapper>.class);
            for(ReviewWrapper review :reviewsLst){                           
                //reviewsLstToDisplay.add(new ReviewWrapper(review.OrderDate,review.OrderId,review.RatingQuality,review.RatingSpeed,review.RatingValue,review.ReviewComment,'Review'));
                review.KPItype='DeliveryArea';
            }
            reviewsLstToDisplay.add(rw);
            reviewsLstToDisplay.addAll(reviewsLst);
        }
        if(acc.NPS_Response_History__c !=null){
            reviewsLst = new List<ReviewWrapper>();
           parser = JSON.createParser(acc.NPS_Response_History__c );
            //List<ReviewWrapper> reviewsLstToDisplay = new List<ReviewWrapper>();
           
            do{
                parser.nextToken();
                
            }while(parser.hasCurrentToken() && !'data'.equals(parser.getCurrentName()));
            parser.nextToken();
            reviewsLst= (List<ReviewWrapper>)parser.readValueAs(List<ReviewWrapper>.class);
            for(ReviewWrapper review :reviewsLst){                           
                //reviewsLstToDisplay.add(new ReviewWrapper(review.OrderDate,review.OrderId,review.RatingQuality,review.RatingSpeed,review.RatingValue,review.ReviewComment,'Review'));
                review.KPItype='NPSResponse';
            }
            
            reviewsLstToDisplay.addAll(reviewsLst);
        }
        
        
        
        
        
        
         return reviewsLstToDisplay;
    }

    global Class ReviewWrapper{
        public String areaHeader{get;set;}
        public String OrderDate {get; set;}
        public String OrderId{get;set;}
        public String OrderStatus{get;set;}
        public String RatingQuality{get;set;}
        public String RatingSpeed{get;set;}
        public String RatingValue{get;set;}
        public String ReviewComment{get;set;}
        public String ContactDate{get;set;}
        public String ContactFrom{get;set;}
        public String ContactType{get;set;}
        public String ContactAgent{get;set;}
        public String ContactReason{get;set;}
        public String ContactNotes{get;set;}
        public string Postcode{get;set;}
        public string Reason{get;set;}
        public string OrderAmount{get;set;}
        public String Shortcode{get;set;}
        public String RestaurantCoverage{get;set;}
        public String RestaurantOrders{get;set;}
        public String RestaurantOrdersPerc{get;set;}
        public String AreaOrders{get;set;}
        public String AreaRestaurants{get;set;}
        public String AreaOpR{get;set;}
        public String AreaYoY{get;set;}
        public String AreaRevenueAvg{get;set;}
        public String AreaCustomers{get;set;}
        public String AreaBasket{get;set;}
        public String AreaCuisineOrders{get;set;}
        public String AreaCuisineRestaurants{get;set;}
        public String NPSType{get;set;}
        public String NPSDate{get;set;}
        public String NPSScore{get;set;}
        public String NPSContact{get;set;}
        public String NPSReason{get;set;}
        public String NPSFeedback{get;set;}
        public String KPItype{get;set;}
}
       
       

       /* public ReviewWrapper(String Orderdate,String OrderId,String RatingQuality,String RatingSpeed,String RatingValue,String ReviewComment){
            this.OrderDate=Orderdate;
            this.OrderId=OrderId;
            this.RatingQuality=RatingQuality;
            this.RatingSpeed=RatingSpeed;
            this.RatingValue=RatingValue;
            this.ReviewComment=ReviewComment;
       // }
        
       // public ReviewWrapper(String ContactDate,String ContactFrom,String ContactType,String ContactAgent,List<String> OrderId,String ContactReason,List<String> ContactNotes){
            this.ContactDate=ContactDate;
            this.ContactFrom=ContactFrom;
            this.ContactType=ContactType;
            this.ContactAgent=ContactAgent;
            this.OrderId=String.valueOf(OrderId);
            this.ContactReason=ContactReason;
           // this.ContactNotes=String.valueOf(ContactNotes);

        }*/


}