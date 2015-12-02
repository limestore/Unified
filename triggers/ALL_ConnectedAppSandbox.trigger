// Author - Lalitha Adduru
// Trigger on ConnectedApp_Sandbox__c that right now encodes userName and password fields, on insert and update

trigger ALL_ConnectedAppSandbox on ConnectedApp_Sandbox__c (before insert, before update) {
    try
    {
        if(Trigger.isInsert)
        {
            IT_ConnectedAppSandboxHandler.encodeDecodeForInsert(Trigger.New);
        }
        else
        {
            if(Trigger.Old!=null)
            {
                IT_ConnectedAppSandboxHandler.encodeDecodeForUpdate(Trigger.oldMap,Trigger.New);
            } 
        }
    }
    catch(Exception e)
    {
        System.debug('Exception in '+e.getMessage());
    }  
}