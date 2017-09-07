public with sharing class ctrDH_AU_QuoteVFTemplate {
    public list<Opportunity_Quote_Line_Item__c> oppProdItems{get;set;}
    
    public Opportunity_Quote__c theOppQ {get;set;}
    public Boolean premiumPlacement { get; set; }
    public Boolean ukQuote { get; set; }
    public Boolean menuPrinting {get;set;}
    public Boolean colombia { get; set; }
    public Boolean peru { get; set; }
    public Boolean ecuador { get; set; }
    public Boolean prodOnly{get;set;}
    public Boolean foodora {get;set;}
    public Boolean foodoraColombia{get;set;}
    public Boolean foodoraPeru{get;set;}
    public Boolean foodoraEcuador{get;set;}
    public Boolean addContract {get;set;}

    
    public ctrDH_AU_QuoteVFTemplate() {
        Id objId = ApexPages.currentPage().getParameters().get('id');
        this.premiumPlacement = false;
        this.ukQuote = true;
        this.menuPrinting=false;
        this.colombia = false;
        this.peru = false;
        this.ecuador = false;
        this.foodora = false;
        this.addContract = false;
        this.foodoraColombia=false;
        this.foodoraPeru=false;
        this.foodoraEcuador=false;

        theOppQ = [SELECT Id, Id_Account__c,Id_Account__r.Name,Id_Account__r.Invoice_Frequency__c,Id_Opportunity__c,SubTotalRF__c,VAT_fm__c,Total_fm__c,Id_Opportunity__r.Main_Commission_Fee__c ,Id_Opportunity__r.Invoice_Transmission_method__c,Id_Opportunity__r.Main_Online_Payment_Fee__c ,Id_Opportunity__r.Quote_Comment_Menu_Printing__c,Id_Opportunity__r.Type FROM Opportunity_Quote__c WHERE Id =: objId];        
        oppProdItems = [select Name, Listed_Price__c,Quantity__c,Total_Amount__c from Opportunity_Quote_Line_Item__c where Id_Opportunity_Quote__c=:theOppQ.id and Line_item_type__c='Product'];
        List<opportunity> oppTariffItems = [select Record_Country__c,Id_Tarif__r.Name,type, Name from opportunity where id=:theOppQ.Id_Opportunity__c];
        //List<Opportunity_Tarif_Item__c> oppTariffItems = [SELECT Id_Tarif__r.Name, Id_Opportunity__c FROM Opportunity_Tarif_Item__c WHERE Id_Opportunity__c =:theOppQ.Id_Opportunity__c];
        
        Set<String> logisticFees = new Set<String>(Label.logistics_fee.split(','));
        
        System.debug('@@@ Rijad ctrDH');
        if(oppTariffItems.size() > 0) {
            System.debug('@@@ Rijad found tarif item');
            for(Opportunity opt : oppTariffItems) {
                System.debug('@@@ Rijad tarif item name: ' + opt.Id_Tarif__r.Name);
                if(opt.Name == 'Premium Placement') {
                    this.premiumPlacement = true;
                    this.ukQuote = false; 
                }
                else if(opt.type == 'Additional Contract'){
                    this.addContract = true;
                    this.ukQuote = false; 
                
                }
                else if(opt.Id_Tarif__r.Name == 'Menu Printing'){
                    this.menuPrinting=true;
                    this.ukQuote =false;
                
                }

                if(logisticFees.contains(opt.Id_Tarif__r.Name)){
                    if(opt.Record_Country__c == 'Colombia')
                        this.foodoraColombia=true;
                    if(opt.Record_Country__c == 'Peru')
                        this.foodoraPeru=true;
                    if(opt.Record_Country__c == 'Ecuador')
                        this.foodoraEcuador=true;
                    this.foodora=true;
                }
                if(this.foodora==false){
                    if(opt.Record_Country__c == 'Colombia')
                        this.colombia = true;
                    else if (opt.Record_Country__c == 'Peru')
                        this.peru = true;
                    else if (opt.Record_Country__c == 'Ecuador')
                        this.ecuador = true;
                        
                    if(opt.type!=null && opt.type.indexOf('Contract')==-1){
                        this.prodOnly=true;
                        this.colombia = false;
                        this.peru = false;
                        this.ecuador = false; 
                    }
                }
            }
        }
        
    }
    
   

}