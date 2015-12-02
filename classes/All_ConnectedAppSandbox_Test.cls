@isTest
public class All_ConnectedAppSandbox_Test 
{
	public static testmethod void testTrigger()
    {
        ConnectedApp_Sandbox__c c = new ConnectedApp_Sandbox__c(name='fulldev',isProduction__c=false,username__c='abc',password__c='def',consumer_Key__c='samplekey',consumer_Secret__c='sampleSecret');
        insert c;
        c.Username__c = 'ChangedUserName';
        update c;
    }
}