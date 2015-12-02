trigger ALL_User on User (after insert,after update) 
{
    if(Trigger.New!=null && Trigger.isAfter)
    {
        DS_AddPermissionSet_Handler.addPermissionSetsAndGroups(Trigger.New);
    }
}