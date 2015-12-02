//RQ-05454 Hemanth.kesapragada@cdk.com Change status from closed to completed,Modified Test Class
@IsTest
public class DS_RequestAssignOnCloseTest
{
        
    //Toggle enable/disable debug logs
    private static final boolean GENERATE_DEBUG_LOGS = true;
    //TestMethod control variables
    private static final boolean RUN_ALL = true;
    private static final boolean RUN_TEST_REQUEST = true;

    @TestSetup
    public static void loadData()
    {
        User userObj = DS_TestObjects.NewAdminUser();
        userObj.UserRoleId = [Select Id, RollupDescription From UserRole Where RollupDescription like '%System Administrator%'].Id;
        insert userObj;
        
        System.runAs(DS_TestObjects.CurrentUser()) 
        {
            test.startTest();
            Request__c requestObj = new Request__c();
            requestObj.Name = 'TestRequest';
            requestObj.ownerid=userObj.Id;
            requestObj.Initial_Estimate__c = 5;
            insert requestObj;
            test.stopTest();
        }
    }
    
    public static testmethod void TestRequest()
    {
        if(RUN_ALL || RUN_TEST_REQUEST)
           {
               User userObj = [select id from user order by lastmodifiedDate desc limit 1];
               System.runAs(DS_TestObjects.CurrentUser()) 
               {
                   Test.startTest();
                   Request__c reqObj = [
                       select id,Status__c,
                       Reason_Not_Completed_In_All_Environments__c,
                       Change_Classification__c,Duration_to_Completion__c,
                       Assigned_Config__c,ownerid,createdById
                       from Request__c 
                   ];
                   System.assertNotEquals(reqObj.OwnerId,reqObj.CreatedById);
                   if(reqObj != null) {
                       reqObj.Status__c = 'Completed'; 
                       reqObj.Reason_Not_Completed_In_All_Environments__c = 'Testing...';
                       reqObj.Change_Classification__c = 'Routine';
                       reqObj.Duration_to_Completion__c = 25;
                       reqObj.Assigned_Config__c = userObj.Id;
                       reqObj.Initial_Estimate__c = 5;
                       
                       Request_Team_Member__c rtm = new Request_Team_Member__c();
                       rtm.Request__c = reqObj.Id;
                       rtm.Role__c = 'SF Config Admin';
                       rtm.User__c = UserInfo.getUserId();
                       insert rtm;
                       
                       update reqObj;
                   }
                   Test.stopTest();
                   reqObj = [
                       select id,ownerid,createdById
                       from Request__c 
                       where id=:reqObj.Id
                   ];
                   System.assertEquals(reqObj.OwnerId,reqObj.CreatedById);
               } 
           }
           
    }
    
    private static void setHeaderLogs(String txt)
    {
        if(GENERATE_DEBUG_LOGS)
        {
            //Genereate debug logs
            System.debug('**********************************');
            System.debug('***** '+txt);
            System.debug('**********************************');  
        }
        
    }
}