global class ClsGetBackendIdAccount {

    webservice static String getBackendIdAccount(String accId, String accType) {
        try {
            String label = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get('Backend_ID__c').getDescribe().getLabel();
            //get account details
            Account acc = [Select Id, Name, Restaurant_Name__c, Backend_ID__c, BillingStreet, BillingCity, Phone, Delivery_Fee__c, Minimum_order_value_Cash__c,
                           parent.Backend_ID__c, parent.parent.Backend_ID__c, Company_Number__c, Brand__c, parent.Chain__c, Record_Country__c, parent.brand__c
                           from account where Id = : accId];

            // get the contacts:
            List<Contact> conlst = [Select Id, email, Phone from contact where id in (select contactid from AccountContactRelation  where accountid = : accId)];



            //Construct Body
            String body;
            String backEndId;
            String path;
            BEIntegration_CountriesToCities__c cntCit;
            if (accType == 'Client' || accType == 'Branch') {
                cntCit = BEIntegration_CountriesToCities__c.getValues(acc.BillingCity);
                //check if cntCit != null
                if (cntCit == null) {return 'warning';}
            }
            if (accType == 'Client') {
                // set the path
                path = '/clients/create';
                //Construct body
                // Billing Street can contain new line characters.  we need to escape it
                String street =  acc.BillingStreet;
                street = street.replace('\r\n', ' ');
                street = street.replace('\n', ' ');
                street = street.replace('\r', ' ');


                String bodySt = '{"salesforce-id":'     + '"' + String.valueOf(acc.Id)  + '"' + ',' +
                                '"legal-number":'       + '"' + acc.Company_Number__c   + '"'   + ',' +
                                '"address":'                + '"' + street                  + '"'   +  ',' +
                                '"city-id":'                + '"' + cntCit.City_Backend_Id__c + '"' +  ',' +
                                '"country-id":'         + '"' + cntCit.Country_Backend_Id__c + '"'  + ',' +
                                '"legal-name":'         + '"' + acc.Name        + '"' + ',' +
                                '"commercial-name":'    + '"' + acc.Restaurant_Name__c  + '"' + ',' +
                                '"salesperson-email":'    + '"' + UserInfo.getUserEmail() + '"'   + ',';
                String bodyParEmail = '';
                String bodyParPhone = '';
                for (contact con : conlst) {
                    bodyParEmail += con.email + ',';
                    bodyParPhone += con.Phone + ',';
                }

                //body
                body = bodySt + '"contact-emails":' + '"' + bodyParEmail.removeEnd(',') + '"' + ',' + '"contact-phones":' + '"' + bodyParPhone.removeEnd(',') + '"' + '}';
                system.debug(body);
            }
            // Brand
            if (accType == 'Brand') {
                path = '/brands/create';
                String bodySt = '{"salesforce-id":' + '"' + String.valueOf(acc.Id)  + '"' + ',' + '"name":' + '"' + acc.Name + '"' + '}';

                body = bodySt;
                system.debug(body);
            }

            if (accType == 'Franchise') {
                path = '/franchises/create';
                String bodySt = '{"salesforce-id":'     + '"' + String.valueOf(acc.Id)    + '"' + ',' +
                                '"name":'           + '"' + acc.Name            + '"'   + ',' +
                                '"client-id":'        + '"' + acc.parent.Id   + '"'   + ',' +
                                '"brand-id":'         + '"' + acc.Brand__c        + '"';

                //body
                body = bodySt + '}';
            }

            if (accType == 'Branch') {

                String street =  acc.BillingStreet;
                street = street.replace('\r\n', ' ');
                street = street.replace('\n', ' ');
                street = street.replace('\r', ' ');

                path = '/branches/create';
                String bodySt = '{"salesforce-id":'     + '"' + String.valueOf(acc.Id)        + '"' + ',' +
                                '"brand-id":'           + '"' + acc.parent.brand__c             + '"'   + ',' +
                                '"client-id":'          + '"' + acc.parent.parent.Id            + '"' + ',' +
                                '"address":'          + '"' + street                              + '"' + ',' +
                                '"name":'           + '"' + acc.Name              + '"' + ',';

                //min-order-amount and delivery-cost are optional fields
                //in the request message. only include them if populated.

                if (acc.phone != null) {bodySt += '"manager-phone":' + '"' + acc.Phone + '"' + ',';}
                if (acc.Delivery_Fee__c != null) {bodySt += '"min-order-amount":' + acc.Delivery_Fee__c + ',';}
                if (acc.Minimum_order_value_Cash__c != null) {bodySt += '"delivery-cost":' + acc.Minimum_order_value_Cash__c + ',';}

                bodySt += '"city-id":' + '"' + cntCit.City_Backend_Id__c + '"' + ',';
                bodySt += '"country-id":' + '"'  + cntCit.Country_Backend_Id__c + '"';

                body = bodySt + '}';
                system.debug('body' + body);
            }

            HttpResponse res = new HttpResponse();
            Http http = new Http();

            //system.debug('countrycode' + acc.Record_Country__c);
            HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest(acc.Record_Country__c, path, 'POST', body);

            if (req != null) {
                res = http.send(req);
                if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
                    JSONParser parser = JSON.createParser(res.getBody());

                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'Id') {
                            parser.nextToken();
                            backEndId = parser.getText();
                            break;
                        }
                    }
                } else {
                    return 'Error:' + res.getStatus();
                }

            } else {
                return 'MidasIntegration__c is not configured';
            }


            acc.Backend_ID__c = backEndId;

            update acc;
            return 'SUCCESS:' + label + ':' + acc.Backend_ID__c;
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }


    }



    webservice static String getBackendIdTalabat(String accId, String accType) {
        Account acc = [SELECT
                       Name,
                       Restaurant_Name__c,
                       Backend_ID__c,
                       Phone,
                       Delivery_Fee__c,
                       Minimum_order_value_Cash__c,
                       parent.Backend_ID__c,
                       parent.parent.Backend_ID__c,
                       Company_Number__c,
                       Account_Email__c,
                       Platform__c,
                       Brand__c,
                       parent.Chain__c,
                       Record_Country__c,
                       parent.brand__c,
                       (
                           SELECT
                           SubAdministrativeAreaCode__c
                           FROM AddressDetails__r
                           WHERE Type__c = 'Restaurant Address'
                       )
                       FROM Account
                       WHERE Id = : accId];


        String platform = '';
        Integration_Config__c integrationConfigs = Integration_Config__c.getValues('Talabat');
        String baseEp = integrationConfigs.endpoint__c;
        String ep;
        String tokenContent = 'client_Id=' + EncodingUtil.urlEncode(integrationConfigs.ClientId__c, 'UTF-8') + '&client_secret=' + EncodingUtil.urlEncode(integrationConfigs.clientSecret__c, 'UTF-8') + '&username=' + integrationConfigs.username__c + '&password=' + EncodingUtil.urlEncode(integrationConfigs.password__c, 'UTF-8') + '&grant_type=' + EncodingUtil.urlEncode('password', 'UTF-8');
        Map<String, Integer> countryMap = (Map<String, Integer>)JSON.deserialize(integrationConfigs.CountryCode__c, Map<String, Integer>.class);
        Map<String, Integer> platformMap = (Map<String, Integer>)JSON.deserialize(integrationConfigs.PlatformCode__c, Map<String, Integer>.class);
        List<String> platformList = new List<string>();
        String con = '';
        Integer timeout = Integer.valueof(integrationConfigs.timeout__c);



        if (acc.platform__c.contains(';')) {
            platformList = acc.platform__C.split(';');
        } else
            platformList.add(acc.platform__c);
        for (string s : platformList) {
            platform += platformMap.get(s) + ',';
        }
        platform = platform.removeEndIgnoreCase(',');
        String content = '{"salesforceid":'         + '"' + String.valueOf(acc.Id)          + '"'  +
                         ',' + '"CountryId":'        + countryMap.get(acc.Record_Country__c)  ;

        if (acctype == 'Group') {
            ep = baseEp + 'api/group/add';
            content += ',' + '"LegalName":'     +  '"' + acc.name        + '"'  +
                       ',' + '"GroupName":'     +  '"' + acc.name        + '"'  +
                       ',' + '"PlatformId":'   +  '"' + platform        + '"'  +
                       +'}';
        } else if (acctype == 'Brand') {
            ep = baseEp + 'api/restaurant/add';
            if (acc.name != null) {content +=   ',' + '"RestaurantName":' + '"' + acc.name + '"' ;  }
            if (acc.account_email__c != null)   {content += ',' + '"BillingEmail":' + '"'  + acc.account_email__C + '"' ;}
            content += ',' +  '"RestaurantLegalName":'       + '"' + acc.name + '"'  +
                       ',' + '"PlatformId":'                 +  '"' + platform + '"'  +
                       ',' +  '"GroupSalesForceId":'           +  '"'    +          +acc.parent.id + '"}';
        } else if (acctype == 'Branch') {
            ep = baseEp + 'api/branch/add';
            List<Contact> conlst = [Select Id, email, firstname, lastname, Phone, MobilePhone from contact where id in (select contactid from AccountContactRelation  where accountid = : accId)];

            if (acc.account_email__c != null) {content += ',' + '"BranchEmail":' + '"'  + acc.account_email__C + '"' ;}
            content += ',' + '"BranchName":'       +   '"'   + acc.name                     + '"'  +
                       ',' + '"RestaurantSalesForceId":'     +  '"'    + acc.parent.id    + '"'  +
                       ',' + '"AreaId":' + Integer.valueof(acc.AddressDetails__r.get(0).SubAdministrativeAreaCode__c);

            for (Contact c : conLst) {
                con += '{ "Name":'            +  '"' + c.Firstname  + '"'  +
                       ',"SurName ":'        +  '"' + c.LastName   + '"'  +
                       ',"Email ":'          +  '"' + c.Email   + '"'  +
                       ',"ContactNo  ":'     +  '"' + c.phone   + '"'  +
                       ',"Email ":'          +  '"' + c.MobilePhone   + '"'  +
                       '}'   ;


            }
            content +=  ',' + '"Contacts ": [' + con + ']}';

        }

        

        try {
            HttpRequest req = LibWebserviceHelper.createBackendCalloutHeaderTalabat(tokenContent, baseEp);
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            String backendID;
            if (req != null) {
                system.debug(req.getBody());
                res = http.send(req);
                if (res.getStatusCode() == 200) {
                    String accessToken;
                    JSONParser parser = JSON.createParser(res.getBody());
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'access_token') {
                            parser.nextToken();
                            accessToken = parser.getText();
                            break;
                        }
                    }
                    if (accessToken != null) {
                        backendID = createBackendIdTalabat(accessToken, content, ep, acc, timeout);
                        return backendID;
                    } else
                        return 'Error: No accessToken ';
                } else
                    return 'Error :' + res.getStatus();

            } else
                return ' Error : Something went wrong. Please contact Admins.';
        } catch (Exception e) {
            system.debug(e);
            return 'Error : ' + e.getMessage();
        }

    }


    public static String createBackendIdTalabat(String accessToken, String  content, String ep, Account acc, Integer timeout) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(ep);
        req.setMethod('POST');
        req.setBody(content);
        req.setTimeout(timeout);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('authorization', 'bearer ' + accessToken);
        system.debug(content);
        system.debug(req);
        if (req != null) {
            res = http.send(req);
            system.debug(res.getBody());
            if (res.getStatusCode() == 200) {
                String backendId;
                backendId = parseResponse(res.getBody(), 'id');
                acc.backend_id__c = backendId;
                update acc;
                return 'Success ' + backendId;
            } if (res.getStatusCode() == 403) {
                return 'Error :' + parseResponse(res.getBody(), 'Message');
            } if (res.getStatusCode() == 500) {
                return 'Error :' + res.getBody();
            } else
                return 'Error : ' + res.getStatus();

        }
        return 'Error';
    }

    public static string parseResponse(String resp, String strName) {
        JSONParser parser = JSON.createParser(resp);
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.VALUE_STRING ) {
                JSONParser p = Json.createParser(parser.getText());
                while (p.nextToken() != null) {
                    if (p.getCurrentToken() == JSONToken.FIELD_NAME && p.getCurrentName() == strName) {
                        p.nextToken();
                        return  p.getText();
                    }
                }
            }
        }
        return null;
    }


    webservice static String createBackendID(String accId, String accType) {
        Account acc = [Select Id, Name, Restaurant_Name__c, Backend_ID__c, BillingStreet, BillingCity, Phone, Delivery_Fee__c,
                       Minimum_order_value_Cash__c, parent.Backend_ID__c, parent.parent.Backend_ID__c, Area__c, Company_Number__c,
                       Account_Email__c, Platform__c, Brand__c, parent.Chain__c, Record_Country__c, parent.brand__c
                       from account where Id = : accId];

        List<Contact> conLst = [Select Id, email, Phone, firstname, LastName from contact where id in (select contactid from AccountContactRelation  where accountid = : accId) and Contact_Role__c = 'Owner' Limit 1];

        List<Backend_Integration__e> backendAccLst = new List<Backend_Integration__e>();
        Backend_Integration__e beRec = new Backend_Integration__e(AccountId__c = acc.id, Account_Name__c = acc.name,
                Account_Type__c = acctype, Account_country__c = acc.Record_Country__c, Account_City__c = acc.BillingCity, Account_Platform__c = acc.Platform__c,
                Account_Parent_BackendID__c = acc.parent.Backend_ID__c);
        if (conLst != null && !conLst.isEmpty()) {
            beRec.Contact_First_Name__c = conLst[0].firstname;
            beRec.Contact_last_name__c = conLst[0].lastname;
            beRec.Contact_Email__c = conLst[0].Email ;
            beRec.contact_phone__c = conLst[0].Phone;
        }
        backendAccLst.add(beRec);



        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(backendAccLst);

        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
                return 'Successfully published event.';
            } else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                    return  err.getMessage();
                }
            }
        }
        return null;




    }

    webservice static String createBackendIDSweden(String accId,String accName){
        Integration_Config__c integrationConfigs = Integration_Config__c.getValues('Sweden');
        String baseEp=integrationConfigs.endpoint__c;
        String nonce =String.valueOf(Crypto.getRandomLong());
        System.debug('nonce'+nonce);
        Account acc = new Account(id=accid);
        Blob hash =Crypto.generateMac('HmacSHA256',Blob.valueOf(integrationConfigs.UserName__c+nonce),Blob.valueOf(integrationConfigs.ClientSecret__c));
        String hashStr=EncodingUtil.convertToHex(hash);
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String content= '{ "salesforce_id":"'+accid+'",'+
                        +'"customer_name" :"'+accname+'",'+
                        +'"customer_type":"restaurant" }';
        req.setEndpoint(baseEp);
        req.setMethod('POST');
        req.setBody(content);
       // req.setTimeout(timeout);
        req.setHeader('Content-Type','application/json');
        req.setHeader('X-API-KEY',integrationConfigs.UserName__c);
        req.setHeader('X-API-NONCE',nonce);
        req.setHeader('X-API-HASH',hashStr);
        
        if(req!=null){
            res = http.send(req);
            system.debug(res.getBody());
            if(res.getStatusCode() == 200){
                String backEndId = parseResponseSE(res.getBody(),'Id');
                if(backEndId!=null){
                    acc.backend_id__c = backendId;
                            update acc;
                            System.debug(backEndId);
                            
                }
                 
     
                return 'Success '+ backendId;
            }else if(res.getStatusCode() == 409){
                    String err =parseResponseSE(res.getBody(),'msg');
                            return 'Error :'+ err;
                                
            }if(res.getStatusCode() == 500){
                return 'Error :'+res.getBody();
            }else 
                return 'Error : '+res.getStatus();

        }
        return 'Error';
    }

    public static string parseResponseSE(String resp, String strName) {
        JSONParser parser = JSON.createParser(resp);
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == strName) {
                            parser.nextToken();
                            return parser.getText();
                            
                        
                    }
                    
                }
            
        
        return null;
    }
}