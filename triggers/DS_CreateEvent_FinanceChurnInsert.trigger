trigger DS_CreateEvent_FinanceChurnInsert on Finance_Churn_Prevention__c (after insert) {


		Task MyTask = new Task();
		
		
  		list<Task> lNewTasks = new list<Task>();
  		for(integer i=0; i<trigger.new.size(); i++)
  		{
     		lNewTasks.add(MyTask = new Task(
       		Subject = 'Financial Services Call',
       		WhatID = trigger.new[i].id,
       		Activity_Type__c = 'Call',
       		//AccountId = trigger.new[i].Account__c,
       		Priority = 'Normal',
       		Status = 'Not Started',
       		OwnerId = trigger.new[i].OwnerId));
   		}
   		
   		if(lNewTasks.size() > 0){
   			insert lNewTasks;
   		}

}