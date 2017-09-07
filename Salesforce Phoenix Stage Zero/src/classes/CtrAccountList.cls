global class CtrAccountList {
    
    private static String userEmail = UserInfo.getUserEmail();
    private static String userRole = '';

    global CtrAccountList(){
        
    }
    
    @RemoteAction
    global static String loadAccountList(Boolean compleateList,String userRl){
        try{
            userRole = userRl;
            String api = '/v2/sites/UKHH/restaurants?number_of_leads=30';  //TAJ:31-10-2016  will not work as not supported by API. will always return full list
            if(compleateList){
                api = '/v2/sites/UKHH/restaurants';
            }
            HttpResponse res = new HttpResponse();      
            Http http = new Http();
            HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('UK',api,'GET',null);
            if(req!=null){
                //req.setHeader('user-info','{"user_email":"'+userEmail+'", "user_role":"'+userRole+'"}');
                //System.debug('user-info {"user_email":"'+userEmail+'", "user_role":"'+userRole+'"}');
                res = http.send(req);
                //System.debug('response :'+res.getBody());
                //system.debug('##status code'+res.getStatusCode());
                if(res.getStatusCode()==200) {
                    return res.getBody();
                }else{
                    return 'Error: '+res.getStatus()+': '+res.getBody();
                }
            }else{
                return 'Error: MidasIntegration__c is not configured';
            }
        }catch(System.CalloutException e){
            system.debug('Error: '+e.getMessage());
            return 'Error: '+e.getMessage();
        }
    }

    @RemoteAction
    global static String loadPPSlots(String zipcode,String userRl,String begDate,String endDate){
        try{
            userRole = userRl;
            if(zipcode!=null && zipcode.length()>0){
                //List<String> mY = monthYear.split('-');
                //Integer currentYear = Date.today().year();
                //Integer currentMonth = Date.today().month();
                //String api = 'postcode/UKHH/'+zipcode+'/'+year+'/'+month+'/';  TAJ:31-10-2016: disabled for v2 API
                String api = '/v2/sites/UKHH/postcodes/'+zipcode+'/bookings?filter_date_begin=' +begDate + '&filter_date_end='+endDate;
                System.debug('url3' + api);
                HttpResponse res = new HttpResponse();      
                Http http = new Http();
                HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('UK',api,'GET',null);
                System.debug('request message = ' + req.toString());
                if(req!=null){
                    //req.setHeader('user-info','{"user_email":"'+userEmail+'", "user_role":"'+userRole+'"}');
                    res = http.send(req);
                    system.debug('##status code'+res.getStatusCode());
                    if(res.getStatusCode()==200) {
                          System.debug('response JSON = ' + res.getBody());
                        return res.getBody();
                      
                    }else{
                        return 'Error: '+res.getStatus()+': '+res.getBody();
                    }
                }else{
                    return 'Error: MidasIntegration__c is not configured';
                }
            }else{
               return 'Error: Enter zip code'; 
            }
        }catch(System.CalloutException e){
            system.debug('Error: '+e.getMessage());
            return 'Error: '+e.getMessage();
        }
    }


    @RemoteAction
    global static String loadPPAccounts(String zipcode,String userRl,Boolean compleateList,String dateISO){
        try{
            userRole = userRl;
            if(zipcode!=null && zipcode.length()>0){
                //List<String> mY = monthYear.split('-');
                //Integer currentYear = Date.today().year();
                //Integer currentMonth = Date.today().month();
                String api = '/v2/sites/UKHH/postcodes/' + zipcode  + '/restaurants?status_date='+ dateISO;
                if(compleateList){
                    //api = 'accounts/UKHH/'+zipcode+'/'+year+'/'+month+'/?assign_recommendations=true&min_new_accounts=20';
                      api = '/v2/sites/UKHH/postcodes/' + zipcode  + '/restaurants?status_date='+ dateISO;
                    System.debug('url2 = ' + api);
                }
                HttpResponse res = new HttpResponse();      
                Http http = new Http();
                HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('UK',api,'GET',null);
                if(req!=null){
                    //req.setHeader('user-info','{"user_email":"'+userEmail+'", "user_role":"'+userRole+'"}');
                    res = http.send(req);
                    if(res.getStatusCode()==200) {
                        return res.getBody();
                    }else{
                        return 'Error: '+res.getStatus()+': '+res.getBody();
                    }
                }else{
                    return 'Error: MidasIntegration__c is not configured';
                }
            }else{
               return 'Error: Enter zip code'; 
            }
        }catch(System.CalloutException e){
            system.debug('Error: '+e.getMessage());
            return 'Error: '+e.getMessage();
        }
    }
    
    @RemoteAction
    global static String createOpportunity(String accountId){

        try{
        List<Account> aclist = [select id from Account where id=:accountId];
        if(aclist!=null && !aclist.isEmpty()){
            List<Opportunity> opps = [select Id from Opportunity where AccountId=:accountId and name='Premium Placement' and StageName not in ('Closed Won','Closed Lost') limit 1];
            if(!opps.isEmpty()){
                return opps[0].Id;
            }   
            Tarif__c tr = [select id from Tarif__c where Name='Premium Placement' and recordtype.developername='UK_Tarif' limit 1];
            Opportunity opp = new Opportunity(name='Premium Placement',Type='Product Only',business_type__c='Upgrade/Upsell',accountId = accountId,recordtypeId=LibRecordTypeHelper.getRecordTypeValue('UK_Opportunity'),Id_Tarif__c=tr.Id,stageName='Verbal Agreement',probability=50,closeDate=Date.today());
            insert opp;
            return opp.Id;
        }else{
            return 'Error: SF Account id does not exist.';
        }
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
            return 'Error: '+e.getMessage();
        }
        
    }

    @RemoteAction
    global static String getOppLineItems(String backendId,String bookingId){
        try{
            String query = 'select id,Booking_Api_Id__c,Position_fm__c,City_ZipCode__c,Id_Opportunity__c,Id_Opportunity__r.name,Id_Opportunity__r.Account.name,Id_Opportunity__r.Account.Backend_ID__c,Id_Opportunity__r.AccountId from Opportunity_Line_Item__c where Id_Opportunity__r.StageName!=\'Closed Won\' and ';
            if(backendId!=null && backendId.trim().length()>2){
                String backendIdIn = '';
                if(backendId.indexOf(',') > 0){
                    for(String str : backendId.split(',')){
                        backendIdIn +='\''+str+'\',';
                    }
                    String ss =  backendIdIn.removeEnd(',');
                    query +='Booking_Api_Id__c!=null and Id_Opportunity__r.Account.Backend_ID__c in ('+ss+')';
                }else{
                    query +='Booking_Api_Id__c!=null and Id_Opportunity__r.Account.Backend_ID__c =\''+backendId+'\'';
                }
            }else if(bookingId!=null && bookingId.trim().length()>0){
                String bookingIdIn = '';
                if(bookingId.indexOf(',') > 0){
                    for(String str : bookingId.split(',')){
                        bookingIdIn +='\''+str+'\',';
                    }
                    String ss =  bookingIdIn.removeEnd(',');
                    query +='Booking_Api_Id__c in ('+ss+')';
                }else{
                    query +='Booking_Api_Id__c=\''+bookingId+'\'';
                }
            }
            System.debug('query: '+query);
            List<Opportunity_Line_Item__c> opplines = Database.query(query);
            return JSON.serialize(opplines);
        }catch(Exception e){
            System.debug('error: '+e.getMessage());
            return 'Error: '+e.getMessage();
        }
    }

    @RemoteAction
    global static String cancelBookings(List<Bookings> bookings,String usrRole,String usrEmail){
        if(bookings.isEmpty()){
            return 'Error: Select atleast one Booking Id to cancel';
        }else{
            try{
                Map<String,String> mapOfbooks = new Map<String,String>();
                userRole = usrRole;
                userEmail = usrEMail;
                //String oppId = [select Id_Opportunity__c from Opportunity_Quote_Line_Item__c where Booking_Api_Id__c =: bookings[0].bookingId limit 1].Id_Opportunity__c;
                String oppId = [select Id_Opportunity__c from Opportunity_Line_Item__c where id =: bookings[0].opplineId limit 1].Id_Opportunity__c;
                //String bodyparam = '{"booking_ids":[';
                String bodyparam = ' {"meta": {"username": "'+userEmail+'","sf_role": "'+userRole+'","sf_opportunity_id": "'+oppId+'"},"data": {"bookings": [';
                String arrays = '';
                List<Opportunity_Line_Item__c> opplines = new List<Opportunity_Line_Item__c>();
                for(Bookings bk : bookings){
                    mapOfbooks.put(bk.bookingId,bk.opplineId);
                    //arrays += bk.bookingId+',';
                    arrays+='{"type":"booking", "id":'+bk.bookingId+'},';
                    opplines.add(new Opportunity_Line_Item__c(id=bk.opplineId));
                }
                List<Opportunity_Quote_Line_Item__c> oppQuotes = [select id from Opportunity_Quote_Line_Item__c where Booking_Api_Id__c in : mapOfbooks.keySet()];
                bodyparam += arrays.removeEnd(',');
                bodyparam += ']}}';
                System.debug('bodyparam: '+bodyparam);
                HttpResponse res = new HttpResponse();      
                Http http = new Http();
                //HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('UK','cancelbooking/UKHH/','POST',bodyparam);
                HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('UK','/v2/sites/UKHH/bookings/cancel','POST',bodyparam);
                if(req!=null){
                    //req.setHeader('user-info','{"user_email":"'+userEmail+'", "user_role":"'+userRole+'"}');
                    res = http.send(req);
                    System.debug('response :'+res.getBody());
                    system.debug('##status code'+res.getStatusCode());
                    if(res.getStatusCode()==204) {
                        delete opplines;
                        delete oppQuotes;
                      return 'success';
                    }else{
                        return 'Error: '+res.getBody();
                    }
                }else{
                    return 'Error: MidasIntegration__c is not configured';
                }
            }catch(System.CalloutException e){
                system.debug('Error: '+e.getMessage());
                return 'Error: '+e.getMessage();
            }
        }
    }

    global class Bookings{
        String bookingId;
        String opplineId;
        global bookings(String bookingId,String opplineId){
            this.bookingId = bookingId;
            this.opplineId = opplineId;
        }
    }
}