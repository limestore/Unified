global with sharing class CB_CreativeCaseTallyOnWebID_Scheduler implements Schedulable {
	
	public static string scheduleString = '0 0 3 1 * ?'; //Every 1st of the month at 3AM 
	
	global void execute(SchedulableContext sc)
	{
		
		CB_CreativeCaseTallyOnWebIdReset_Batch batchclass = new CB_CreativeCaseTallyOnWebIdReset_Batch();
		database.executeBatch(batchclass);
	}
	global static string schedulefunc(){
		CB_CreativeCaseTallyOnWebID_Scheduler schedular = new CB_CreativeCaseTallyOnWebID_Scheduler();
		return system.schedule('Creative Case Tally Reset on WebID',scheduleString, schedular);
	}
}