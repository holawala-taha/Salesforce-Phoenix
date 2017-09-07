public with sharing class ClsTaskProcessor {

    /**
     * Updates case's Last_Call_Date__c field when a new call is logged
     * @param tasksList Logged calls
     */
    public static void updateCaseLastCallDate(List<task> tasksList) {
        System.debug('ClsTaskProcessor.updateCaseLastCallDate: start');

        Map<Id, Task> caseIdToLastCall = new Map<Id, Task>();
        List<Case> toUpdate = new List<Case>();

        try {
            // filter tasks
            for (Task ts : tasksList) {

                if (ts.Type == 'Call'
                        && ts.WhatId != null
                        && String.valueOf(ts.WhatId).startsWith('500') // is a case
                        && ts.Status == 'Completed') {
                    caseIdToLastCall.put(ts.WhatId, ts);
                }
            }

            System.debug('ClsTaskProcessor.updateCaseLastCallDate: caseIdToLastCall size is: ' + caseIdToLastCall.size());

            if (caseIdToLastCall.isEmpty()) {
                return; // nothing to do
            }

            // gets cases
            for (Case cs : [
                        Select Last_Call_Date__c
                        From Case
                        Where Id in :caseIdToLastCall.keySet()
                    ]) {
                cs.Last_Call_Date__c = caseIdToLastCall.get(cs.Id).CreatedDate;
                toUpdate.add(cs);
            }

            System.debug('ClsTaskProcessor.updateCaseLastCallDate: cases to update are: ' + toUpdate);

            // updates cases
            if (!toUpdate.isEmpty()) {
                update toUpdate;
            }

        } catch (Exception e ) {
            System.debug('ClsTaskProcessor.updateCaseLastCallDate: exception occurred. Message is: ' + e.getMessage());
        }

        System.debug('ClsTaskProcessor.updateCaseLastCallDate: done');
    }

    /**
     * Updates lead's Last_Call_Date__c field when a new call is logged
     * @param tasksList Logged calls
     */
    public static void updateLeadLastCallDate(List<task> tasksList) {
        System.debug('ClsTaskProcessor.updateLeadLastCallDate: start');

        Map<Id, Task> leadIdToLastCall = new Map<Id, Task>();
        List<Lead> toUpdate = new List<Lead>();

        try {

            // filter calls
            for (Task ts : tasksList) {
                if (ts.Type == 'Call'
                        && ts.WhoId != null
                        && String.valueOf(ts.WhoId).startsWith('00Q') // is a Lead
                        && ts.Status == 'Completed') {
                    leadIdToLastCall.put(ts.WhoId, ts);
                }
            }

            System.debug('ClsTaskProcessor.updateLeadLastCallDate: leadIdToLastCall size is: ' + leadIdToLastCall.size());

            if (leadIdToLastCall.isEmpty()) {
                return; // nothing to do
            }

            // gets Leads
            for (Lead ld : [
                        Select Last_Call_Date__c
                        From Lead
                        Where Id in :leadIdToLastCall.keySet()
                    ]) {
                ld.Last_Call_Date__c = leadIdToLastCall.get(ld.Id).CreatedDate;
                toUpdate.add(ld);
            }

            System.debug('ClsTaskProcessor.updateLeadLastCallDate: lead to update are: ' + toUpdate);

            // updates leads
            if (!toUpdate.isEmpty()) {
                update toUpdate;
            }

        } catch (Exception e ) {
            System.debug('ClsTaskProcessor.updateLeadLastCallDate: exception occurred. Message is: ' + e.getMessage());
        }

        System.debug('ClsTaskProcessor.updateLeadLastCallDate: done');
    }


    /*public static void convertTaskToCases(List<Task> tasks){
        system.debug('Inside Trigger : Task_Trigger: ' + tasks);
        List<Task> taskToDelete = new List<Task>();
        List<Case> newCases = new List<Case>();

        for(Task t : tasks){
            if(t.IsClosed && t.Subject.indexOf('Email') != -1){
                newCases.add(createClosedCase(t));
                taskToDelete.add(new Task(Id = t.Id));
            }
        }

        try {
            delete taskToDelete;
        } catch(Exception e){
            system.debug('@@@@ calling Task_Trigger  - ERROR OCCURRED:  '  + e.getMessage());
        }

        system.debug('Inside Trigger : newCases: ' + newCases);

        try{
            List<Database.Saveresult> result = Database.insert(newCases);
            system.debug('Inside Trigger : result: ' + result);
        } catch(Exception e){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, Label.Quote_Email_Activity_History_Creation_Error));
            System.debug('@@@@ The following error occured while creating the email log for the quote email : ' + e.getMessage());
        }
    }

    public static Case createClosedCase(Task t){
        Case closedCase = new Case();
        closedCase.Subject = 'Email : ' + t.Subject;
        closedCase.Priority = 'Normal';
        closedCase.AccountId = t.AccountId;
        closedCase.OwnerId = Userinfo.getUserId();
        closedCase.Status = 'Closed';
        return closedCase;

    }*/

    public static void updateLatestCallCommentsInOpportunity(List<Task> tasksList, Map<Id, Task> oldTaskMap) {
        try {
            Map<Id, Task> oppTaskMap = new Map<Id, Task>();
            for (Task ts : tasksList) {
                System.debug('Inside the for Loop:' + ts.Type);
                System.debug('Inside the for Loop:' + ts.Whatid);
                if (ts.Type != null && ts.WhatId != null) {

                    if (ts.Type == 'Call' && string.valueof(ts.Whatid).indexof('006') == 0 && ts.RecordTypeid == LibRecordTypeHelper.getRecordTypeValue('Yogiyo_Task') ) {
                        oppTaskMap.put(ts.WhatId, ts);
                        System.debug('Updating the map' + ts.whatid);
                    }
                }
            }
            List<Opportunity> updateOppList = new List<Opportunity>();
            if (!oppTaskMap.isEmpty()) {
                for (Opportunity opp : [select id, Last_Call_Comments__c from Opportunity where id in : oppTaskMap.keySet() and recordtype.developername = 'Yogiyo_Opportunity']) {
                    String loggedBy = '[ Call logged on: ' + (oppTaskMap.get(opp.id).ActivityDate).format() + ' by ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' ]:\n';
                    if (oppTaskMap.get(opp.id).Description != null) {
                        opp.Last_Call_Comments__c = loggedBy + oppTaskMap.get(opp.id).Description;
                        updateOppList.add(opp);
                    }
                }
            }
            update updateOppList;
        } catch (Exception e) {
            tasksList[0].addError(e.getMessage());
        }
    }

    public static void updateLeadStatus(List<Task> tasksList, Map<Id, Task> oldTaskMap) {
        Map<Id, Task> leadTaskMap = new Map<Id, Task>();
        for (Task ts : tasksList) {
            if (ts.Type != null && ts.WhoId != null) {
                if (ts.Type == 'Call' && string.valueof(ts.WhoId).indexof('00Q') == 0) {
                    leadTaskMap.put(ts.WhoId, ts);
                }
            }
        }
        List<Lead> updateOppList = new List<Lead>();
        if (!leadTaskMap.isEmpty()) {
            for (Lead lead : [SELECT Status FROM Lead WHERE Id IN :leadTaskMap.keySet() FOR UPDATE]) {
                if (leadTaskMap.get(lead.Id) != null) {
                    if (leadTaskMap.get(lead.Id).Activity_Subject__c != null) {
                        if (lead.Status == 'Lost' || lead.Status == 'Contacted') {
                            return;
                        }
                        if (leadTaskMap.get(lead.Id).Activity_Subject__c.containsIgnoreCase('decision maker reached') && lead.Status != 'Contacted') {
                            lead.Status = 'Contacted';
                            updateOppList.add(lead);
                        }
                        if (lead.Status != 'Open' && leadTaskMap.get(lead.Id).Activity_Subject__c.containsIgnoreCase('employee reached') || leadTaskMap.get(lead.Id).Activity_Subject__c.containsIgnoreCase('nobody reached')) {
                            lead.Status = 'Open';
                            updateOppList.add(lead);
                        }
                    }
                }
            }
        }
        if (!updateOppList.isEmpty())
            update updateOppList;
    }
}