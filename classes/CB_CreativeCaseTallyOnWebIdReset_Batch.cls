global with sharing class CB_CreativeCaseTallyOnWebIdReset_Batch implements Database.Batchable<sObject> {
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'SELECT ID, Creative_Case_Tally__c, (Select Id,Creative_Case_Tally__c, RecordType.Name, WebId__c, Status from Cases__r), (Select Id,Creative_Case_Tally__c, RecordType.Name, WebId__c from Account_Plans__r)  from WebID__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<WebID__c> scope){
        list<sObject> webIdCasesAccountPlanList = new list<sObject>();
        for(WebID__c webId: scope)
        {
            if(webId.Creative_Case_Tally__c!=null)
            {
                webId.Creative_Case_Tally__c =0;
                webIdCasesAccountPlanList.add(webId);
            }
            for(Case cs:webId.Cases__r)
            {
                if(cs.RecordType.Name=='Inquiry - Creative'  && cs.Creative_Case_Tally__c!=null){
                   cs.Creative_Case_Tally__c = 0;
                    webIdCasesAccountPlanList.add(cs);
                }
             }
            for(Account_Plan__c acPlan:webId.Account_Plans__r)
            {
                if(acPlan.RecordType.Name == 'DAA Account Plan' && acPlan.Creative_Case_Tally__c!=null){
                    acPlan.Creative_Case_Tally__c = 0;
                    webIdCasesAccountPlanList.add(acPlan);
                }
            }
            
        }
        update webIdCasesAccountPlanList;
    }
    global void finish(Database.BatchableContext BC){
    	
    	Id JobId = null;
    	if(BC != null) { JobId = BC.getJobId(); }
    	
    	AsyncApexJob BatchJob = null;
    	List<AsyncApexJob> BatchJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedDate 
            FROM AsyncApexJob WHERE Id = :JobId LIMIT 1];
    	
    	ALL_UtilitiesMiscellaneous.Job j = null;
    	if(!BatchJobs.IsEmpty()) { j = new ALL_UtilitiesMiscellaneous.Job(BatchJobs[0]); } 
		else { j = new ALL_UtilitiesMiscellaneous.Job(); }
    	
        ALL_UtilitiesMiscellaneous.SendBatchCompleteMessage(j,
        	'CB_CreativeCaseTallyOnWebIdReset_Batch', 
        	'Finished Resetting the Creative limit to 0 on AccountPlan<-WebID->Cases ', 
        	'Batch Complete');
    }
    
    

}