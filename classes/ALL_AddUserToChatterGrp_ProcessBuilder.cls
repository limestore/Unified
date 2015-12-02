/*******************************************************
* Author: Hemanth.Kesapragada@cdk.com
* Description: Class to add users to chatter group via Process Builder
* Test Class: ALL_AddUserToChatterGrp_Test
* 
* History:
* 2015-08-12 	Hemanth Kesapragada		Created
* 2015-08-12	Hemanth Kesapragada		Added addUserToGrp method
* *************************************************** */
public class ALL_AddUserToChatterGrp_ProcessBuilder
{
    public class UserAndChatterGrp
    {
        @InvocableVariable
        public String chatterGroupId;

        @InvocableVariable
        public String UserId;   
    }

    
    //Process Builder Identifies classes with @InvocableMethod annotation
    @InvocableMethod(label='User Id' description='Requires UserID and Chatter Id')
    public static void addUserToGrp(List<UserAndChatterGrp> UserChatterGrpList)
    {
        try
        {
            List<CollaborationGroupMember> collabList = new List<CollaborationGroupMember>();
            if(UserChatterGrpList.size()!=0)
            {
                for(UserAndChatterGrp userChatterGrpObj : UserChatterGrpList)
                {
                    CollaborationGroupMember collabGrpMem = new CollaborationGroupMember();
                    collabGrpMem.CollaborationGroupId = userChatterGrpObj.chatterGroupId;
                    collabGrpMem.MemberId = userChatterGrpObj.UserId;
                    collabList.add(collabGrpMem);
                }
                if(collabList.size()!=0)
                {
                    insert collabList;   
                }
            }
        }
        Catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
        }
    }
}