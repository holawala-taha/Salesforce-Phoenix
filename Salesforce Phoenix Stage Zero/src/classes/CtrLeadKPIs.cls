global with sharing class CtrLeadKPIs {


    public Lead leadObj {get;set;}
    //public List<Lead> ListLeadFields { get; set; }

    public CtrLeadKPIs(ApexPages.StandardController stdcontroller) {

    }
    
    @RemoteAction
    global static List<LeadKPI> getLeadKPI(String leadId){
        List<LeadKPI> leadKPILst = new List<LeadKPI>();
        LeadKPI ldKPI = new LeadKPI( );
        Lead ld=[select id,Delivery_Zone__c from Lead where id=:leadId];
        JSONParser parser;
        if(ld.Delivery_Zone__c!=null){
            parser = JSON.createParser(ld.Delivery_Zone__c);
            do{
                parser.nextToken();
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                
                    if(parser.getText() == 'Region') {
                        parser.nextToken();
                        ldKPI.Region = parser.getText();
                        ldKPI.isHeader=true;
                    }
                    else if(parser.getText() == 'City') {
                        parser.nextToken();
                        ldKPI.City = parser.getText();
                        
                    }
                    else if(parser.getText() == 'CompetitorLink') {
                        parser.nextToken();
                        ldKPI.CompetitorLink = parser.getText();
                        
                    }
                    else if(parser.getText() == 'CompetitorReviews') {
                        parser.nextToken();
                        ldKPI.CompetitorReviews = parser.getText();
                        
                    }
                     else if(parser.getText() == 'CityYoY') {
                        parser.nextToken();
                        ldKPI.CityYoY= parser.getText();
                        
                    }

                }

            }while(parser.hasCurrentToken() && !'data'.equals(parser.getCurrentName()));
            parser.nextToken();
            leadKPILst = (List<LeadKPI>)parser.readValueAs(List<LeadKPI>.class);
            system.debug(leadKPILst );
            leadKPILst.add(ldKPI);
           
            
        }
        return leadKPILst;
    }
    
    
    global class LeadKPI{
        public String Shortcode{get;set;}
        public String AreaOrders{get;set;}
        public String AreaRestaurants{get;set;}
        public String AreaOpR{get;set;}
        public String AreaYoY{get;set;}
        public String AreaRevenueAvg{get;set;}
        public String AreaCustomers{get;set;}
        public String AreaBasket{get;set;}
        public String AreaCuisineOrders{get;set;}
        public String AreaCuisineRestaurants{get;set;}
        public String Region{get;set;}
        public String City{get;set;}
        public String CityYoY{get;set;}
        public String CompetitorLink{get;set;}
        public String CompetitorReviews{get;set;}
        public Boolean isHeader{get;set;}
        
        
    
    
    }

}