// Author : Lalitha Adduru
// Description : Trigger on Request Object

trigger ALL_Request on Request__c (before update) {
if(trigger.isbefore)
{
    if(trigger.isUpdate)
    {
        All_Request_Handler handler =  new All_Request_Handler();
        handler.unfollowOnCompletion(trigger.new,trigger.oldMap);
    }
}
}