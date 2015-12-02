// Author -  Lalitha Adduru
// Description  - Handler class for trigger on ConnectedApp_Sandbox__c object, to encode username and password fields

public class IT_ConnectedAppSandboxHandler {
    public static void encodeDecodeForInsert(List<ConnectedApp_Sandbox__c> TriggerNew)
    {
        if(TriggerNew!=null)
        {            
            for(ConnectedApp_Sandbox__c sandbox : TriggerNew)
            {
                String userName = sandbox.username__c;
                String password = sandbox.password__c;
                Blob blobValue = Blob.valueOf(userName);
                sandbox.username__c=EncodingUtil.base64Encode(blobValue);
                blobValue = Blob.valueOf(password);
                sandbox.password__c=EncodingUtil.base64Encode(blobValue); 
            }            
        }
    }
    public static void encodeDecodeForUpdate(Map<Id,ConnectedApp_Sandbox__c> TriggerOld, List<ConnectedApp_Sandbox__c> TriggerNew)
    {
        for(ConnectedApp_Sandbox__c sandbox : TriggerNew)
        {
            ConnectedApp_Sandbox__c oldsandbox = TriggerOld.get(sandbox.Id);
            system.debug('$$$Old Values - '+'username '+oldsandbox.username__c +' password:'+oldsandbox.password__c);
            system.debug('$$$New Values - '+'username '+sandbox.username__c +' password:'+sandbox.password__c);
            Boolean isEncoded;
            if(oldsandbox.username__c != sandbox.username__c )
            {
                Blob blobValue = Blob.valueOf(sandbox.username__c);
                sandbox.username__c=EncodingUtil.base64Encode(blobValue);
                system.debug('username -- >' + sandbox.username__c);
            }
            if(oldsandbox.password__c != sandbox.password__c)
            {
                Blob blobValue = Blob.valueOf(sandbox.password__c);
                sandbox.password__c=EncodingUtil.base64Encode(blobValue);
                system.debug('Password -- >'+ sandbox.Password__c);
            }       
        }
    }
}