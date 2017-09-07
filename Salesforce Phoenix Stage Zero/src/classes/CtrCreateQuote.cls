public with sharing class CtrCreateQuote {



    //public Id oppId { get; set;}
    // public Id oppQuoteId {get;set;}
    public Id oppQId { get; set;}
    public String acctId { get; set; }
    public String placeHolder { get; set; }
    public Double setUpFee {get; set;}
    public Boolean subsidy {get; set;}
    public List<Opportunity_Quote_Line_Item__c> listLineItems {get{
            if (this.listLineItems == null) {
                System.debug('creating lineItems');
                createLineItemList();
                System.debug('lineItem size: ' +  this.listLineItems.size());
                return this.listLineItems;
            } else{
                System.debug('returning lineItem size: '  + this.listLineItems.size());
                return this.listLineItems;
            }
        }
        private set;
    }

    /* public List<Opportunity_Quote_Product_Item__c> listQuoteLineItems {get{
                                                                     if(this.listQuoteLineItems == null){
                                                                         System.debug('creating listQuoteLineItems');
                                                                         createQuoteLineItemList();
                                                                         System.debug('listQuoteLineItems size: ' +  this.listQuoteLineItems.size());
                                                                         return this.listQuoteLineItems;
                                                                     }else{
                                                                         System.debug('returning listQuoteLineItems size: '  + this.listQuoteLineItems.size());
                                                                         return this.listQuoteLineItems;
                                                                     }
                                                                 }
                                                                   private set;}*/

    public Double lineItemsTotalAmount {get{
            if (this.lineItemsTotalAmount == null) {
                calculateLineItemTotalAmount();
                return lineItemsTotalAmount;
            } else{
                return lineItemsTotalAmount;
            }
        }
        private set;
    }

    public String weekday {get; set;}
    public Date startDate  {get; set;}
    public Date endDate {get; set;}
    public String entityName {get; set;}
    public String entityAddress {get; set;}
    public String entityPhone {get; set;}
    public String entityFax {get; set;}
    public String entityCountry {get; set;}
    public String entityEmail {get; set;}
    public String entityFooter {get; set;}
    public String entityHeader {get; set;}
    public Boolean errorFlag {get; set;}
    public String entityHead {get; set;}
    public String entityRole {get; set;}
    public Opportunity_Quote_Line_Item__c registrationProduct {get; set;}
    public Boolean menuPrinting { get; set; }
    public Boolean marketingMaterial { get; set; }
    public Boolean nineCookies { get; set; }
    public Boolean reccuringFee { get; set; }
    public Boolean isFixedAmt {get; set;}
    //public Decimal totalAmount { get; set; }
    public Opportunity_Quote_Line_Item__c commissionFeeItem {get; set;}
    public Opportunity_Quote_Line_Item__c annualRenewalProduct {get; set;}
    //public Opportunity_Quote_Product_Item__c registrationQuoteProduct {get;set;}
    //public Opportunity_Quote_Product_Item__c annualRenewalQuoteProduct {get;set;}
    
    public Opportunity opportunity {
        get {
            if (oppQId != null) {
                Opportunity_quote__c oqli = [SELECT id_opportunity__c FROM Opportunity_quote__c WHERE Id = :oppQId];
                return [select owner.name, owner.lastname, owner.firstname, Id_Tarif__r.name, owner.phone, owner.email, SubTotalRF__c, VAT_fm__c, Total_fm__c, CloseDate from opportunity where id = :oqli.id_opportunity__c];
            }
            return new Opportunity();
        } private set;
    }

    // right now used only for CD.
    public String oppCloseDateDayAsLiteral {
        get {
            return UtilsNumberToStringLiteral.getStringLiteralByLocale(opportunity.CloseDate.day(), 'es_ES');
        }
    }

    public String oppCLoseDateMonthName {
        get {
            return Datetime.newInstance(opportunity.CloseDate, System.now().time()).format('MMMM');
        }
    }

    public List<Opportunity_Quote_Line_Item__c> listCommisionItems {
        get {
            if (this.listCommisionItems == null) {
                createComissionItemsList();
                return this.listCommisionItems;
            } else
                return this.listCommisionItems;
        }
        private set;
    }

    public Boolean comissionsExist { get; set; }
    public Boolean tieredCommissionExist { get; set; }
    public Boolean additionalCostsExist { get; set; }
    public Boolean showOnlinePayment {get; set;}
    public Boolean commPercent {get; set;}
    public Boolean commPerOrder {get; set;}
    public Boolean isDiscount {get; set;}
    public String displayAuto {

        get{
            if (oppQId != null) {
                List<Opportunity_Quote_Line_Item__c > opp = [SELECT Id, Id_List_Product_Price__r.Product_Type__c FROM Opportunity_Quote_Line_Item__c where Id_Opportunity_Quote__c = :oppQId and Line_Item_type__c = 'Product'];
                system.debug('*opp' + opp );
                for (Opportunity_Quote_Line_Item__c o : opp) {

                    if (o.Id_List_Product_Price__r.Product_Type__c == Label.SE_Automatic_CarLease || o.Id_List_Product_Price__r.Product_Type__c == Label.SE_Manual_CarLease) {
                        displayAuto = o.Id_List_Product_Price__r.Product_Type__c;
                        system.debug('**displayauto' + displayAuto);
                    }

                }
            }
            return displayAuto;

        }
        private set;
    }
    //Added this method for SP-1309(Bhupendra)
   public String quoteNonstandardTextMjam {
        get{
            if (quoteNonstandardTextMjam == null) {
                if (oppQId != null) {
                    Opportunity_Quote__c oppQ = [select id, Non_Standard_Contract_Terms__c,Non_Standard_Contract_Components__c,Template_Name__c from Opportunity_Quote__c where Id = :oppQId];
                    if (oppQ.Non_Standard_Contract_Terms__c != null && oppQ.Non_Standard_Contract_Components__c!=null && oppQ.Non_Standard_Contract_Components__c=='Mjam Web' && oppQ.Template_Name__c == 'AT_QuoteVFTemplate_Both') {
                        quoteNonstandardTextMjam = oppQ.Non_Standard_Contract_Terms__c;
                        
                    } else if(oppQ.Non_Standard_Contract_Terms__c != null && oppQ.Non_Standard_Contract_Components__c!=null && oppQ.Template_Name__c == 'AT_QuoteVFTemplate_Asset'){
                        quoteNonstandardTextMjam = oppQ.Non_Standard_Contract_Terms__c;
                        
                    }
                }
            }
            return quoteNonstandardTextMjam;
        }
        private set;

    }
    
    public String quoteNonstandardText {
        get{
            if (quoteNonstandardText == null) {
                if (oppQId != null) {

                    Opportunity_Quote__c oppQ = [select id, Non_Standard_Contract_Terms__c from Opportunity_Quote__c where Id = :oppQId];
                    if (oppQ.Non_Standard_Contract_Terms__c != null) {
                        quoteNonstandardText = oppQ.Non_Standard_Contract_Terms__c;

                    }
                }
            }
            return quoteNonstandardText;
        }
        private set;

    }
    
    public Opportunity_Quote__c oppQuote {
        get{
            if (oppQuote == null) {
                if (oppQId != null) {
                    isDiscount = false;
                    oppQuote = [select id, Total_fm__c, SubTotalRF__c, VAT_fm__c, Approval_Comments__c, Non_Standard_Contract_Components__c from Opportunity_Quote__c where Id = :oppQId];
                    if (oppQuote.Non_standard_contract_components__c != null && oppQuote.Non_standard_contract_components__c.containsIgnoreCase('Show Discount')) {
                        isDiscount = true;
                    }
                }
            }
            return oppQuote;
        }
        private set;

    }


    public ClsAccountWrapper getAccountWrapper() {
        ClsAccountWrapper accountWrapper;
        errorFlag = false;
        System.debug('AccountWrapper: ');
        this.entityHeader = '';
        this.entityFooter = '';
        if (acctId != null && accountWrapper == null) {
            Account acct = [
                               SELECT Id, Name, Backend_Id__c, Phone, X3rd_Party_Delivery_Service__c, Fax, Holiday__c, Main_Contact__r.Name, Account_Email__c, Company_Number__c, Restaurant_Name__c, Website, Payment_Method__c, Person_In_Charge__c,
                               Available_Delivery_Time_Weekday_Begin__c, Available_Delivery_Time_Weekday_End__c, Available_Delivery_Time_Weekend_Begin__c, Available_Delivery_Time_Weekend_End__c, Minimum_order_value_Cash__c,
                               Minimum_order_value_Credit_card__c, Owner.Phone, BillingPostalCode, BillingStreet, BillingState, BillingCity, BillingCountry, Billing_Dong__c, Billing_GunGu__c, Billing_Subdistrict__c,
                               Available_Delivery_Time_Comment__c, Closing_Schedule__c, Delivery_Fee__c, Delivery_Zone__c, Delivery_Time__c, First_Payment_Date__c, Paid_Period_Of_Application__c, Credit_Card_Number__c, Credit_Card_Validity_Period__c,
                               Refund_Account_Number__c, Refund_Account_Owner__c, Refund_Bank_Name__c, Collection_Account_Birthdate__c, bank_name__c, Collection_Account_Number__c, Collection_Account_Owner__c, Collection_Bank_Name__c,
                               Invoice_Transmission_method__c, Bank_Account_Owner__c, Bank_Account_Number__c, Bank_Sort_Code__c, Bank_Account_Type__c,
                               Collection_Account_Sort_Code__c, recordType.DeveloperName, Delivery_ServicePicklist__c, Key_VIP_Account__c, Platform__c, Record_country__c, Tax_Number__c, Trade_Register_Number__c, (SELECT Id, FirstName, LastName, Salutation, Name, Phone, MobilePhone, Email, Contact_Role__c, Birthdate, MailingStreet, MailingCity, MailingPostalCode FROM Contacts WHERE AccountId = : acctId /*AND Contact_Role__c = 'Owner'*/)
                               FROM Account
                               WHERE Id = : acctId
                           ];
            System.debug('acct' + acct);
            accountWrapper = new ClsAccountWrapper(acct);

            if (acct.recordType.DeveloperName == 'Talabat_Account') {
                if (acct.Platform__c != null) {
                    if (acct.Platform__c.contains('Talabat')) {
                        this.entityCountry = acct.Record_country__c;
                        this.entityName = 'Talabat';
                        Company__c comp = [select id, name, Address__c, Fax__c, Phone__c, Email__c, Header_Name__c, Footer_Name__c, Entity_Name__c, Entity_Head__c, Role__c from Company__c where Country__r.Name = :acct.Record_country__c limit 1];
                        System.debug('comp: ' + comp);
                        if (comp.Entity_Name__c != null) {
                            this.entityName = comp.Entity_Name__c;
                        }
                        this.entityHead = comp.Entity_Head__c;
                        this.entityRole = comp.Role__c;
                        this.entityAddress = comp.Address__c;
                        this.entityPhone = comp.Phone__c;
                        this.entityFax = comp.Fax__c;
                        this.entityEmail = comp.Email__c;
                        this.entityHeader = comp.Header_Name__c;
                        this.entityFooter = comp.Footer_Name__c;
                    }
                } else {
                    errorFlag = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Please select a platform'));
                }
            }
        }
        return accountWrapper;
    }

    public Decimal getCommissionFee() {
        Decimal commissionFee = null;
        System.debug('oppQId: ' + oppQId);
        if (oppQId != null) {
            List<Opportunity_Quote_Line_Item__c> qItems = [SELECT Id, Name, Commission_In_Percentage__c, Start_Date__c, end_Date__c FROM Opportunity_Quote_Line_Item__c WHERE Id_Opportunity_Quote__c = : this.oppQId and Line_Item_Type__c = 'Service'];
            if (!qItems.isEmpty()) {
                LibOpportunityLineItemsHelper.sortList(qItems, 'Start_Date__c', 'DESC');
                commissionFeeItem = qItems[0];
                commissionFee = qItems[0].Commission_In_Percentage__c;
                this.startDate = qItems[0].Start_Date__c;
                this.endDate = qItems[0].end_Date__c;
                if (this.startDate != null) {
                    datetime myDate = datetime.newInstance(startDate.year(), startDate.month(), startDate.day());
                    this.weekday = myDate.format('EEEE');
                }

            }
        }/*else if(this.oppId != null){
            List<Opportunity_Service_Item__c> serviceItems = [SELECT Id,Name, Commission_In_Percentage__c, Start_Date__c,end_Date__c, Id_Opportunity__c FROM Opportunity_Service_Item__c WHERE Id_Opportunity__c =: this.oppId];
            if(!serviceItems.isEmpty()){
                LibOpportunityLineItemsHelper.sortList(serviceItems, 'Start_Date__c', 'DESC');
                commissionFeeItem = serviceItems[0];
                commissionFee = serviceItems[0].Commission_In_Percentage__c;
                this.startDate = serviceItems[0].Start_Date__c;
                this.endDate = serviceItems[0].end_Date__c;
                if(this.startDate!=null){
                   datetime myDate = datetime.newInstance(startDate.year(), startDate.month(), startDate.day());
                    this.weekday = myDate.format('EEEE');
                }

            }
        }*/
        return commissionFee;
    }

    public CtrCreateQuote() {
        placeHolder = 'place holder';
        this.comissionsExist = true;
        this.tieredCommissionExist = false;
        this.additionalCostsExist = true;
        this.menuPrinting = false;
        this.marketingMaterial = false;
        this.nineCookies = false;
        this.commPercent = false;
        this.commPerOrder = false;
        this.showOnlinePayment = false;
        this.subsidy = false;
        //this.totalAmount = 0;
        if (ApexPages.currentPage().getParameters().get('id') != null) {
            oppQId = ApexPages.currentPage().getParameters().get('id');
            acctId = ([select Id_Account__c from Opportunity_Quote__c where id = :oppQId]).Id_Account__c;
        }
    }

    private void createLineItemList() {

        this.listLineItems = new List<Opportunity_Quote_Line_Item__c>();
        //Opportunity theOpp = [SELECT Id,(SELECT Id,Category__c,District__c,Start_Date__c,Total_Amount__c FROM Opportunity_Product_Items__r) FROM Opportunity WHERE Id=:oppId ];
        //this.listLineItems = theOpp.Opportunity_Product_Items__r;
        this.listLineItems = [SELECT Id, Id_List_Product_Price__r.Displayed_Name__c, Category__c, Subsidy__c, size__c, weight__c, Number_of_Copies__c, Design_Note__c, online_payment_fee__c, Deposit_Method__c, Deposit__c, District__c, sub_type__c, Start_Date__c, Total_Amount__c, End_Date__c, Id_List_Product_Price__r.product_Type__c, Id_List_Product_Price__r.Requires_Asset__c, Name, Listed_Price__c, Discount__c, Quantity__c, Installments__c, City_ZipCode__c, Booking_Api_Id__c, Position__c, Position_fm__c FROM Opportunity_Quote_Line_Item__c where Id_Opportunity_Quote__c = :oppQId and Line_Item_type__C = 'Product'];
        for (Opportunity_Quote_Line_Item__c oppProd : this.listLineItems) {
            //if(oppProd.Total_Amount__c != null)
            //     this.totalAmount += oppProd.Total_Amount__c;
            if (oppProd.Sub_type__c == 'Setup Fee') {
                this.registrationProduct = oppProd;

            } else if (oppProd.Sub_type__c == 'Annual Fee') {
                this.annualRenewalProduct = oppProd;
            } /*else if (oppProd.Sub_type__c == 'Terminal Box') {
                system.debug('reg***');
                this.registrationProduct = oppProd;
            } */else if ( oppProd.Sub_type__c == 'Exclusive Special Offer') {
                this.subsidy = true;
            } else if (oppProd.Id_List_Product_Price__r.product_Type__c == 'Menu Printing') {
                this.menuPrinting = true;
            } else if (oppProd.Id_List_Product_Price__r.product_Type__c == 'Blade Sign') {
                this.marketingMaterial = true;
            } else if (oppProd.Id_List_Product_Price__r.product_Type__c == '9 Cookies') {
                this.nineCookies = true;
            } else if (oppProd.Id_List_Product_Price__r.product_Type__c == 'Recurring Fee') {
                this.reccuringFee = true;
            }


        }
        /*Opportunity_Quote__c theQuote = [SELECT Id FROM Opportunity_Quote__c WHERE Id_Opportunity__c =: this.oppId];

        this.listLineItems = theQuote.Opportunity_Quote_Product_Items__r;
        this.listLineItems = [SELECT Id, Category__c, District__c, Listed_Price__c, Start_Date__c, Total_Amount__c
                              FROM Opportunity_Quote_Product_Item__c
                              WHERE Id_Opportunity_Quote__c =: this.oppQuoteId];*/
        this.additionalCostsExist = this.listLineItems.size() >= 1 ? true : false;
    }

    /*private void createQuoteLineItemList(){
        this.listQuoteLineItems = new List<Opportunity_Quote_Product_Item__c>();
        this.listQuoteLineItems = [SELECT Id,Category__c,District__c,Start_Date__c,Total_Amount__c,End_Date__c,Id_List_Product_Price__r.Product_Type__c,Id_List_Product_Price__r.Requires_Asset__c,Name FROM Opportunity_Quote_Product_Item__c where  Id_Opportunity_Quote__c=:oppQuoteId];
        for(Opportunity_Quote_Product_Item__c oppProd : this.listQuoteLineItems){
            if(oppProd.Id_List_Product_Price__r.Product_Type__c=='Setup Fee'){
                this.registrationQuoteProduct = oppProd;
            }else if(oppProd.Id_List_Product_Price__r.Product_Type__c=='Annual Fee'){
                 this.annualRenewalQuoteProduct = oppProd;
            }
           else if(oppProd.Id_List_Product_Price__r.Product_Type__c == 'Menu Printing') {
                this.menuPrinting = true;
            }
            else if(oppProd.Id_List_Product_Price__r.Product_Type__c == 'Marketing Material') {
                this.marketingMaterial = true;
            }
            else if(oppProd.Id_List_Product_Price__r.Product_Type__c == '9 Cookies') {
                this.nineCookies = true;
            }
            else if(oppProd.Id_List_Product_Price__r.Product_Type__c == 'Recurring Fee') {
                this.reccuringFee = true;
            }

        }

    }*/

    private void calculateLineItemTotalAmount() {
        Double result = 0.0;
        if (!listLineItems.isEmpty()) {
            for (Opportunity_Quote_Line_Item__c item : listLineItems) {
                result += item.Total_Amount__c;
            }
        }
        this.lineItemsTotalAmount = result;
    }

    private void createComissionItemsList() {
        this.listCommisionItems = new List<Opportunity_Quote_Line_Item__c>([SELECT Id,  Id_List_Service_Price__r.Displayed_Name__c, Sub_Type__c, online_payment_fee__c, Name, Recurring_Fee__c, Commission_In_Percentage__c, Commission_Per_Order__c, Commission_Type__c,  Id_Opportunity__c, Id_List_Service_Price__c, Id_List_Service_Price__r.Maximum_Commission_In_Percentage__c, Id_List_Service_Price__r.Minimum_Commission_in_Percentage__c, Has_Related_Tarif__c, End_Date__c, Start_Date__c, CurrencyIsoCode, IsTiered__c, index__c, Min__c, Max__c
                FROM Opportunity_Quote_Line_Item__c WHERE Id_Opportunity_Quote__c = : this.oppQId and Line_Item_type__C = 'Service' ORDER BY Start_Date__c, index__c ASC]);
        this.comissionsExist = this.listCommisionItems.size() >= 1 ? true : false;

        if ( this.comissionsExist) {
            if ( this.listCommisionItems[0].commission_per_order__C != null )
                this.commPerOrder = true;
            if ( this.listCommisionItems[0].Commission_In_Percentage__c != null )
                this.commPercent = true;

        }
        if (this.listCommisionItems.size() > 1 && this.listCommisionItems[0].IsTiered__c && this.listCommisionItems[0].index__c != null) {
            if ( this.listCommisionItems[0].online_payment_fee__c != null )
                this.showOnlinePayment = true;
            if ( this.listCommisionItems[0].commission_per_order__C != null )
                this.commPerOrder = true;
            if ( this.listCommisionItems[0].Commission_In_Percentage__c != null )
                this.commPercent = true;

            this.tieredCommissionExist = true;
            this.comissionsExist = false;
        }
        if (this.listCommisionItems.size() > 0) {
            for (Opportunity_Quote_Line_Item__c oqli : this.listCommisionItems) {
                if (oqli.Commission_Type__c == 'Per Order')
                    this.isFixedAmt = true;
            }

        }

    }

    //public
}