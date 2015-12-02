//Modified By				Dated					Description
//anirudh.singh@cdk.com		23rd September, 2015	To upgrade the API Version FROM 26.0 to 34.0.
//RQ-05454 Hemanth.kesapragada@cdk.com Change status from closed to completed
trigger DS_RequestAssignOnClose on Request__c (before update) 
{
    list<Id> CreatedByIds = new list<Id>();
    
    for(Request__c r : Trigger.new)
    {
        CreatedByIds.add(r.CreatedById);
    }
    
    map<Id, User> Users = new map<Id, User>([
        select Id, Name, IsActive
        from User
        Where Id IN :CreatedByIds
    ]);
    
    for(Request__c r : Trigger.new)
    {
        if(r.Status__c != null) 
        {
            User CurrentUser = Users.get(r.CreatedById);
            //RQ-05454 Hemanth.kesapragada@cdk.com Change status from closed to completed
            if((r.Status__c.toLowerCase().contains('completed') ||
               r.Status__c.toLowerCase().contains('closed')) && 
               r.OwnerId != r.CreatedById && CurrentUser.IsActive) 
            { 
                r.OwnerId = r.CreatedById; 
            }
        }
    }
}