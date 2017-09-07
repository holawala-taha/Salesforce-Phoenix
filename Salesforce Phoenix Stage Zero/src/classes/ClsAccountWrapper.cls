public with sharing class ClsAccountWrapper {

  public String ownerName { get; set; }
  public String ownerMobilePhone { get; set; }
  public String ownerPhone { get; set; }
  public String ownerEmail { get; set; }
  public String ownerSalutation {get;set;}
  public String fax { get; set; }
  public String companyName { get; set; }
  public String companyId { get; set; }
  public String restaurantName { get; set; }
  public String restaurantPhoneNumber { get; set; }
  public String restaurantAddress { get; set; }
  public String restaurantWebsite { get; set; }
  public String restaurantEmail { get; set; }
  public String restaurantClosingSchedule { get; set; }
  public Decimal deliveryFee { get; set; }
    public String deliveryTime {get; set; }
    public String deliveryZone {get; set; }
  public Boolean paymentMethodCash { get; set; }
  public Boolean paymentMethodCreditCard { get; set; }
  public Decimal minimumOrderValue { get; set; }
  public String closingSchedule { get; set; }
  public String availableDeliveryTimeWeekdayOpen { get; set; }
  public String availableDeliveryTimeWeekdayClose { get; set; }
  public String availableDeliveryTimeWeekendOpen { get; set; }
  public String availableDeliveryTimeWeekendClose { get; set; }
  public String availableDeliveryTimeComment { get; set; }
  public String availableDeliveryArea { get; set; }
    public String holiday {get;set;}
  public Date firstPaymentDate { get; set; }
  public Date paidPeriodOfApplictaion { get; set; }

  public Decimal creditCardNumber { get; set; }
  public Date creditCardValidityPeriod { get; set; }
  public Date collectionAccountBirthDate { get; set; }
  public String collectionAccountOwner { get; set; }
  public String collectionBankName { get; set; }
  public String collectionAccoutSortCode { get; set; }
  public Decimal collectionAccountNumber { get; set; }
  public String refundAccountOwner { get; set; }
  public String refundBankName { get; set; }
  public String refundAccountNumber { get; set; }

  public String bankAccountNumber { get; set; }
  public String bankAccountOwner { get; set; }
  public String bankSortCode { get; set; }
  public String invoiceTransmissionMethod { get; set; }
  public String addressStreet {get;set;}
  public String addressPostal {get;set;}
  public String addressCity {get;set;}
  public String owner2Name { get; set; }
  public String owner2MobilePhone { get; set; }
  public String owner2Phone { get; set; }
  public String owner2Email { get; set; }

  public String backendId { get; set;}
  public String ownerFirstname { get; set; }
  public String ownerLastname { get; set; }
  public String owner2Firstname { get; set;}
  public String owner2Lastname { get; set; }
  public String ownerMailingStreet { get; set;}
  public String ownerMailingCity { get; set; }
  public String ownerMailingPostalCode { get; set; }
  public Boolean keyAccount{get;set;}
   public Boolean deliveryService{get;set;}

  public String taxNumber { get; set; }
  public String tradeRegNumber { get; set; }
  public String bankName{get;set;}

  public Date ownerBirthdate { get; set;}
  public Date owner2Birthdate { get; set;}
  public String accountCountry{get;set;}
  public String bankAccountType{get;set;}
  public String thirdPartyDeliveryService{get;set;}
  public String accPlatform{get;set;}
  public Map<String, String> mapFieldTranslation{get;set;}

  public ClsAccountWrapper(Account acct) {
    this.paymentMethodCash = false;
    this.paymentMethodCreditCard = false;
    this.keyAccount=acct.Key_VIP_Account__c;
    if(acct.Delivery_ServicePicklist__c=='No')
      this.deliveryService=true;
    this.minimumOrderValue = acct.Minimum_order_value_Credit_card__c;
    this.restaurantAddress = '';
    this.availableDeliveryArea = '';
    this.accPlatform='';
    this.ownerName = '';
    this.ownerMobilePhone = '';
    this.ownerEmail = '';
    this.ownerMailingStreet = '';
    this.ownerMailingCity = '';
    this.ownerMailingPostalCode = '';
    this.ownerSalutation='';
    this.fax = acct.Fax;
    this.companyName = acct.Name;
    this.companyId = acct.Company_Number__c;
    this.restaurantName = acct.Restaurant_Name__c;
    this.restaurantPhoneNumber = acct.Phone;
    this.restaurantWebsite = acct.Website;
    this.restaurantEmail = acct.Account_Email__c;
    this.restaurantClosingSchedule = acct.Closing_Schedule__c;
    this.deliveryFee = acct.Delivery_Fee__c;
        this.deliveryTime = acct.Delivery_Time__c;
        this.deliveryZone = acct.Delivery_Zone__c;
    this.thirdPartyDeliveryService='';    
    this.firstPaymentDate = acct.First_Payment_Date__c;
    this.paidPeriodOfApplictaion = acct.Paid_Period_Of_Application__c;
    this.availableDeliveryTimeWeekdayOpen = acct.Available_Delivery_Time_Weekday_Begin__c;
    this.availableDeliveryTimeWeekdayClose = acct.Available_Delivery_Time_Weekday_End__c;
    this.availableDeliveryTimeWeekendOpen = acct.Available_Delivery_Time_Weekend_Begin__c;
    this.availableDeliveryTimeWeekendClose = acct.Available_Delivery_Time_Weekend_End__c;
    this.availableDeliveryTimeComment = acct.Available_Delivery_Time_Comment__c;
        this.holiday = acct.Holiday__c;

    this.creditCardNumber = acct.Credit_Card_Number__c;
    this.creditCardValidityPeriod = acct.Credit_Card_Validity_Period__c;
    this.collectionAccountNumber = acct.Collection_Account_Number__c;
    this.collectionAccountOwner = acct.Collection_Account_Owner__c;
    this.collectionAccountBirthDate = acct.Collection_Account_Birthdate__c;
    this.collectionBankName = acct.Collection_Bank_Name__c;
    this.collectionAccoutSortCode = acct.Collection_Account_Sort_Code__c;
    this.refundAccountOwner = acct.Refund_Account_Owner__c;
    this.refundAccountNumber = acct.Refund_Account_Number__c;
    this.refundBankName = acct.Refund_Bank_Name__c;
    this.bankAccountType=acct.Bank_Account_Type__c;

    this.bankAccountNumber = acct.Bank_Account_Number__c;
    this.bankAccountOwner = acct.Bank_Account_Owner__c;
    this.bankSortCode = acct.Bank_Sort_Code__c;
    this.bankName = acct.Bank_Name__c;
    this.invoiceTransmissionMethod = acct.Invoice_Transmission_method__c;
    this.accountCountry=acct.billingcountry;
    

    this.backendId = acct.Backend_ID__c;

    this.taxNumber = acct.Tax_Number__c;
    this.tradeRegNumber = acct.Trade_Register_Number__c;
    if(acct.X3rd_Party_Delivery_Service__c!=null)
        this.thirdPartyDeliveryService=acct.X3rd_Party_Delivery_Service__c;
    if(acct.Platform__c!=null){
      this.accPlatform=acct.platform__c;
     if(acct.platform__c.contains(';'))
        this.accPlatform=acct.platform__c.replace(';',' & ');
    }
    Schema.DescribeFieldResult FRes = Account.Bank_Account_Type__c.getDescribe();
    List<Schema.PicklistEntry> PickVal = FRes.getPicklistValues();
    Map<String, String> mapFieldTranslation = new Map<String, String>();
 
    for(Schema.PicklistEntry e : PickVal)
    {
      mapFieldTranslation.put(e.value, e.label);
    }
    this.bankaccounttype=mapFieldTranslation.get(acct.Bank_Account_Type__c);
    Boolean noContact =true;
    if(acct.Contacts != null && !acct.Contacts.isEmpty()){
      for(Contact con : acct.Contacts){
        if(con.Contact_Role__c != null){
          if(con.Contact_Role__c.equals('Owner')){
            this.ownerName = con.Name != null ? con.Name : '';
            this.ownerFirstname = con.FirstName != null ? con.FirstName : '';
            this.ownerLastname = con.LastName != null ? con.LastName : '';
            this.ownerMobilePhone = con.MobilePhone != null ? con.MobilePhone : '';
            this.ownerEmail = con.Email != null ? con.Email : '';
            this.ownerPhone = con.Phone != null ? con.Phone : '';
            this.ownerBirthdate = con.Birthdate;
            this.ownerMailingStreet = con.MailingStreet != null ? con.MailingStreet : '';
            this.ownerMailingCity = con.MailingCity != null ? con.MailingCity : '';
            this.ownerMailingPostalCode = con.MailingPostalCode != null ? con.MailingPostalCode : '';
            this.ownerSalutation =con.Salutation!=null ? con.Salutation : '' ;
            noContact =false;
          }else if(con.Contact_Role__c.equals('Manager')){
            this.owner2Name = con.Name != null ? con.Name : '';
            this.owner2Firstname = con.FirstName != null ? con.FirstName : '';
            this.owner2Lastname = con.LastName != null ? con.LastName : '';
            this.owner2MobilePhone = con.MobilePhone != null ? con.MobilePhone : '';
            this.owner2Email = con.Email != null ? con.Email : '';
            this.owner2Phone = con.Phone != null ? con.Phone : '';
            this.owner2Birthdate = con.Birthdate;
            noContact =false;
          }
        }
      }
      
      } if(noContact){
          List<AccountContactRelation > accCon = [select contactid, contact.email,contact.name,contact.FirstName,contact.LastName,contact.Phone,contact.Birthdate,contact.MailingStreet,contact.MailingCity,contact.MailingPostalCode,contact.Salutation,contact.MobilePhone from AccountContactRelation  where accountid=:acct.id and contact.contact_role__c = 'owner' and isactive=true order by CreatedDate desc];
            if(accCon!=null && !accCon.isEmpty()){
                this.ownerName = accCon[0].contact.Name != null ? accCon[0].contact.Name : '';
                this.ownerFirstname = accCon[0].contact.FirstName != null ? accCon[0].contact.FirstName : '';
                this.ownerLastname = accCon[0].contact.LastName != null ? accCon[0].contact.LastName : '';
                this.ownerMobilePhone = accCon[0].contact.MobilePhone != null ? accCon[0].contact.MobilePhone : '';
                this.ownerEmail = accCon[0].contact.Email != null ? accCon[0].contact.Email : '';
                this.ownerPhone = accCon[0].contact.Phone != null ? accCon[0].contact.Phone : '';
                this.ownerBirthdate = accCon[0].contact.Birthdate;
                this.ownerMailingStreet = accCon[0].contact.MailingStreet != null ? accCon[0].contact.MailingStreet : '';
                this.ownerMailingCity = accCon[0].contact.MailingCity != null ? accCon[0].contact.MailingCity : '';
                this.ownerMailingPostalCode = accCon[0].contact.MailingPostalCode != null ? accCon[0].contact.MailingPostalCode : '';
                this.ownerSalutation =accCon[0].contact.Salutation!=null ? accCon[0].contact.Salutation : '' ;
            }
    }

    if(acct.Payment_Method__c != null && acct.Payment_Method__c.equals('Cash')){
      this.paymentMethodCash = true;
      this.minimumOrderValue = acct.Minimum_order_value_Cash__c;
    } else {
      this.paymentMethodCreditCard = true;
      this.minimumOrderValue = acct.Minimum_order_value_Credit_card__c;
    }

    if(acct.BillingState != null && String.isNotBlank(acct.BillingState)){
      this.restaurantAddress += acct.BillingState + ', ';
    }

    if(acct.BillingCity != null && String.isNotBlank(acct.BillingCity)){
      this.restaurantAddress += acct.BillingCity + ', ';
      this.addressCity = acct.BillingCity;
    }

    if(acct.Billing_GunGu__c != null && String.isNotBlank(acct.Billing_GunGu__c)){
      this.restaurantAddress += acct.Billing_GunGu__c + ', ';
    }

    if(acct.Billing_Dong__c != null && String.isNotBlank(acct.Billing_Dong__c)){
      this.restaurantAddress += acct.Billing_Dong__c + ', ';
    }

    if(acct.BillingStreet != null && String.isNotBlank(acct.BillingStreet)){
      this.restaurantAddress += acct.BillingStreet + ', ';
      this.addressStreet = acct.BillingStreet;
    }
    if(acct.BillingPostalCode !=null && String.isNotBlank(acct.BillingPostalCode)){
      this.addressPostal = acct.BillingPostalCode;
    }
    
    if(this.restaurantAddress.length() > 2){
      this.restaurantAddress = this.restaurantAddress.subString(0, this.restaurantAddress.length() -2);
    }
    

    /*if(acct.BillingPostalCode != null && acct.BillingPostalCode.length() != 0){
      this.restaurantAddress += acct.BillingPostalCode + ', ';
    }
    if(acct.BillingStreet != null && acct.BillingStreet.length() != 0){
      this.restaurantAddress += acct.BillingStreet + ', ';
    }
    if(acct.BillingState != null && acct.BillingState.length() != 0){
      this.restaurantAddress += acct.BillingState + ', ';
    }
    if(acct.BillingCity != null && acct.BillingCity.length() != 0){
      this.restaurantAddress += acct.BillingCity + ', ';
    }
    if(acct.BillingCountry != null && acct.BillingCountry.length() != 0){
      this.restaurantAddress += acct.BillingCountry  + ', ';
    }

    if(this.restaurantAddress.length() > 2){
      this.restaurantAddress = this.restaurantAddress.subString(0, this.restaurantAddress.length() -2);
    }

    if(acct.Billing_Dong__c != null && acct.Billing_Dong__c.length() != 0){
      this.availableDeliveryArea += acct.Billing_Dong__c + ', ';
    }

    if(acct.Billing_GunGu__c != null && acct.Billing_GunGu__c.length() != 0){
      this.availableDeliveryArea += acct.Billing_GunGu__c + ', ';
    }

    if(acct.Billing_Subdistrict__c != null && acct.Billing_Subdistrict__c.length() != 0){
      this.availableDeliveryArea += acct.Billing_Subdistrict__c + ', ';
    }
    
    if(this.availableDeliveryArea.length() > 2){
      this.availableDeliveryArea = this.availableDeliveryArea.subString(0, this.availableDeliveryArea.length() - 2);
    }*/
  }
}