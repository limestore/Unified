/*------------------------------------------------------------
Author: Vijay manimaran
Company: CDK Global
Description: My Communities based on chatter Group
History
11/11/2015    Vijay.manimaran@cdk.com     Created

------------------------------------------------------------*/
public class EMP_MyCommunities_Controller {

    public List<CollaborationGroupMember> CollaborationGroupMembers {get;set;}

    public EMP_MyCommunities_Controller(){
        CollaborationGroupMembers = new list<CollaborationGroupMember>();
        CollaborationGroupMembers = [ 
            Select
            MemberId, CollaborationGroupMember.CollaborationGroup.OwnerId,CollaborationGroupId,
            CollaborationGroup.name
            from CollaborationGroupMember 
            where MemberId =: UserInfo.getUserId()
        ];
    }
}