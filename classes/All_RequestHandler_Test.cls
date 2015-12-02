// Author : Lalitha Adduru
// Description : Test class for All_Request trigger
// History : Modified by Lalitha Adduru on 9 October 2015 to satisfy validation rules on request object

@isTest
public class All_RequestHandler_Test {
    public static testmethod void testRequestTrigger()
    {
        Request__c req = new Request__c(
            Name = 'TestDescription',
            Details__c='TestDetails',
            Business_Justification__c = 'TestJustification',
            Deployment_Strategy__c='In PROD Only',
            Status__c='Open',
            Internal_Priority__c='2 High', 
            Initial_Estimate__C= 12345,
            User_Groups_Impacted__c='CB - Finance',
            Duration_to_Completion__c = 20
        );
        insert req;
        
        User testUserOne = DS_TestObjects.NewAdminUser();
        insert testUserOne;
        Request_Team_Member__c test_rtm = new Request_Team_Member__c(Request__c = req.id, User__c= testUserOne.id, Role__c='SF Config Admin');
        insert test_rtm;        
        EntitySubscription follower = new EntitySubscription(ParentId = req.id , subscriberId = UserInfo.getUserId());
        insert follower;
        req.Name = 'TestDesriptionEdited';
        update req;
        req.Status__c = 'Completed';
        req.Change_Classification__c = 'Routine';
        req.Duration_to_Completion__c = 20;
        req.Completed_in_Unified__c = true;
        req.Completed_in_Prod__c= true;
        req.Completed_in_QA__c = true;
        update req;       
    }
}