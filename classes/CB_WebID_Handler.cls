public class CB_WebID_Handler 
{
    public static void setAccountPlanFields()
    {
        list<webID__c> webIDlist = Trigger.new != null ? (list<WebID__c>)Trigger.new : null;
        map<ID, WebID__c> webIDMap = Trigger.newMap != null ? (map<ID, WebID__c>)Trigger.newMap : null;
        map<ID, WebID__c> webIDOldMap = Trigger.oldMap != null ? (map<ID, WebID__c>)Trigger.oldMap : new map<ID, WebID__c>();
        set<string> fieldSet = new set<string>{'LMA_Analyst__c', 'LMA_Analyst2__c', 'LMA_strategist__c', 'Digital_Advertising_Strategist__c',
            'Online_Marketing_Specialist__c'};
        set<ID> webIDset = new set<ID>();
        
        if(webIDlist != null && !webIDlist.isEmpty())
        {
            for(WebID__c w: webIDlist)
            {  
                WebID__c newRecord = w;
                WebID__c oldRecord = (webIDOldMap != null && !webIDOldMap.isEmpty()) ? webIDOldMap.get(w.ID) : null;
                
                if(fieldSet != null && newRecord != null && oldRecord != null)
                {
                    boolean fieldValueChanged = false;
                    fieldValueChanged = ALL_UtilitiesLogic.compareNewAndOldTriggerValues(fieldSet, newRecord, oldRecord);
                    
                    if(fieldValueChanged)
                    {
                        webIDset.add(w.ID);
                    }
                }
                
            }
        }
        
        map<ID, Account_Plan__c> accountPlanMap;
        
        if(webIDset != null && !webIDset.isEmpty())
        {
            accountPlanMap = new map<ID, Account_Plan__c>([
                Select Id, WebId__c, OwnerID, Secondary_Owner__c, RecordTypeId
                From Account_Plan__c
                Where WebID__c
                IN :webIDset
            ]);
        }
        
        if(accountPlanMap != null && !accountPlanMap.isEmpty())
        {
            for(Account_Plan__c ap: accountPlanMap.values())
            {
                string recordTypeName;
                if(ap != null && ap.RecordTypeId != null)
                {
                    recordTypeName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Account_Plan__c', ap.RecordTypeId);
                }
                
                if(ap.webID__c != null)
                {
                    webID__c currentWebID = webIDMap.get(ap.webId__c);
                    
                    if(currentWebID != null)
                    {
                        if(currentWebID.Digital_Advertising_Strategist__c != null)
                        {
                            if(recordTypeName == 'DAA Account Plan')
                            {
                                if(currentWebID.Digital_Advertising_Strategist__c != null)
                                {
                                    ap.ownerID = currentWebID.Digital_Advertising_Strategist__c;
                                }
                                
                                ap.Secondary_Owner__c = currentWebID.Online_Marketing_Specialist__c;
                            }
                        }
                        if(currentWebID.Digital_Advertising_Strategist__c == null)
                        {
                            if(recordTypeName == 'DAA Account Plan')
                            {
                                if(currentWebID.Online_Marketing_Specialist__c != null)
                                {
                                    ap.ownerID = currentWebID.Online_Marketing_Specialist__c;
                                }
                                ap.Secondary_Owner__c = null;
                            }
                        }
                        if(currentWebID.LMA_Strategist__c != null)
                        {
                            if(recordTypeName == 'AMA Account Plan')
                            {
                                ap.OwnerId = currentWebID.LMA_Strategist__c;
                            }
                        }
                    }
                }
            }
        }
       
        if(accountPlanMap != null && !accountPlanMap.isEmpty())
        {
            update accountPlanMap.values();
            //ALL_UtilitiesData.SerializesObjectList(accountPlanMap.values(), 'Update');           
        }
    }
}