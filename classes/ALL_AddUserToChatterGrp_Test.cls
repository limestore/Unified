/*******************************************************
* Author: Hemanth.Kesapragada@cdk.com
* Description: Test class to test ALL_AddUserToChatterGrp_ProcessBuilder
* 
* History:
* 2015-08-12 	Hemanth Kesapragada		Created
* 2015-08-12	Hemanth Kesapragada		added loadData,testAddUsers methods
* 2015-08-19	Hemanth Kesapragada		added testAddUsersException methods
* *************************************************** */
@IsTest
public class ALL_AddUserToChatterGrp_Test 
{
    private static final boolean RUN_ALL = true;
    private static final boolean GENERATE_DEBUG_LOGS = true;
    private static final boolean RUN_ADD_USERS = true;
    private static final boolean RUN_ADD_USERS_EXCEPTION = true;
    
   
    @TestSetup
    public static void loadData()
    {
        CollaborationGroup collabGroup = new CollaborationGroup();
        collabGroup.CollaborationType = 'public';
        collabGroup.Description = 'This is Test Group';
        collabGroup.InformationBody = 'Test';
        collabGroup.InformationTitle = 'Test Group';
        collabGroup.Name = 'Test Name';
        collabGroup.OwnerId = UserInfo.getUserId();
        insert collabGroup;
    }
    
    public static testMethod void testAddUsers()
    {
        if(RUN_ADD_USERS || RUN_ALL)
        {
            User currentUser = [select id from User where id = :UserInfo.getUserId()];
            System.runAs(currentUser)
            {
                setHeaderLogs('Testing add users to chatter group method');
                CollaborationGroup collabGroup = [
                    select id,Name 
                    from CollaborationGroup 
                    limit 1
                ];
                
                Test.startTest();
                List<User> userList  = new List<User>();
                for(Integer i=0;i<3;i++)
                {
                    User userObj = DS_TestObjects.NewUser();
                    userList.add(userObj);
                }
                insert userList;
                List<ALL_AddUserToChatterGrp_ProcessBuilder.UserAndChatterGrp> idWrapperList = 
                    new List<ALL_AddUserToChatterGrp_ProcessBuilder.UserAndChatterGrp>();
                
                ALL_AddUserToChatterGrp_ProcessBuilder.UserAndChatterGrp idWrapperObj;
                for(User userObj : userList)
                {
                    idWrapperObj = new ALL_AddUserToChatterGrp_ProcessBuilder.UserAndChatterGrp();
                    idWrapperObj.chatterGroupId = collabGroup.id;
                    idWrapperObj.UserId = userObj.id;
                    idWrapperList.add(idWrapperObj);
                }
                
                ALL_AddUserToChatterGrp_ProcessBuilder.addUserToGrp(idWrapperList);
                
                Test.stopTest();
                
                List<CollaborationGroupMember> groupMemberList = [
                    select CollaborationGroupId,MemberId 
                    from CollaborationGroupMember  
                    where CollaborationGroupId =:collabGroup.Id
                ];
                //3 users + 1 group owner
                System.assertEquals(4, groupMemberList.size());
            }
        }
    }
    
    
    public static testMethod void testAddUsersException()
    {
        if(RUN_ADD_USERS_EXCEPTION || RUN_ALL)
        {
            User currentUser = [select id from User where id = :UserInfo.getUserId()];
            System.runAs(currentUser)
            {
                setHeaderLogs('Testing add users to chatter group method -  Negative test case');
                CollaborationGroup collabGroup = [
                    select id,Name 
                    from CollaborationGroup 
                    limit 1
                ];
                
                Test.startTest();
                List<User> userList  = new List<User>();
                for(Integer i=0;i<3;i++)
                {
                    User userObj = DS_TestObjects.NewUser();
                    userList.add(userObj);
                }
                insert userList;
                List<ALL_AddUserToChatterGrp_ProcessBuilder.UserAndChatterGrp> idWrapperList = 
                    new List<ALL_AddUserToChatterGrp_ProcessBuilder.UserAndChatterGrp>();
                
                ALL_AddUserToChatterGrp_ProcessBuilder.UserAndChatterGrp idWrapperObj;
                for(User userObj : userList)
                {
                    idWrapperObj = new ALL_AddUserToChatterGrp_ProcessBuilder.UserAndChatterGrp();
                    idWrapperObj.chatterGroupId = collabGroup.id;
                    idWrapperObj.UserId = null;
                    idWrapperList.add(idWrapperObj);
                }
                
                ALL_AddUserToChatterGrp_ProcessBuilder.addUserToGrp(idWrapperList);
                
                Test.stopTest();
                
                List<CollaborationGroupMember> groupMemberList = [
                    select CollaborationGroupId,MemberId 
                    from CollaborationGroupMember  
                    where CollaborationGroupId =:collabGroup.Id
                ];
                //3 users + 1 group owner
                System.assertEquals(1, groupMemberList.size());
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