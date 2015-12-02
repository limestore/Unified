public class ALL_BusinessSites_Handler 
{
    public static void fieldsettingMethod(map<ID, Business_Site__c> oldMap, list<Business_Site__c> newList)
    {       
        set<string> accountNumberSet = new set<string>();
        list<CB_LMA_Relationship__c> toBeInsertedLMArelationships = new list<CB_LMA_Relationship__c>();
        
        if(Trigger.isDelete){ newList = oldMap.Values();}
        
        if(newList != null && !newList.isEmpty())
        {
            for(Business_Site__c bs: newList)
            {
                if(bs.Account_Number__c != null)
                {
                    accountNumberSet.add(bs.Account_Number__c);
                    if(oldMap != null && !oldMap.isEmpty())
                    {
                        accountNumberSet.add(oldMap.get(bs.ID).Account_Number__c);
                    }
                }
            }
        }
        
        map<ID, Account> accountMap;
        
        if(accountNumberSet != null && !accountNumberSet.isEmpty())
        {
            accountMap = new map<ID, Account>([
                Select ID, Name, Account_Number__c
                From Account
                Where Account_Number__c 
                IN :accountNumberSet 
                AND Account_Number__c != null
                AND isDeleted = false
            ]);
        }
        
        map<string, Account> numberToAccount = new map<string, Account>();
        
        system.debug(accountMap);
        
        if(accountMap != null && !accountMap.isEmpty())
        {
            for(Account a: accountMap.values())
            {
                if(a.Account_Number__c != null)
                {
                    numberToAccount.put(a.Account_Number__c, a);
                }
            }
        }
        
        system.debug(numberToAccount);
        
        if(Trigger.isInsert && Trigger.isBefore)
        {        
            for(Business_Site__c bs: newList)
            {
                if(bs.Account_Number__c != null)
                {
                    Account acc = numberToAccount.get(bs.Account_Number__c);
                    system.debug(acc);
                    if(acc != null)
                    {
                        bs.LMA_Account__c = acc.ID;
                        
                        CB_LMA_Relationship__c newCBLMArelation = new CB_LMA_Relationship__c();
                        newCBLMArelation.Dealer_Account__c = bs.Account__c != null ? bs.Account__c : null;
                        newCBLMArelation.LMA_Account__c = acc.ID;
                        toBeInsertedLMArelationships.add(newCBLMArelation);
                    }
                }
            }
            
            if(toBeInsertedLMArelationships != null && !toBeInsertedLMArelationships.isEmpty())
            {
                insert toBeInsertedLMArelationships;
            }
        }
        
        if(Trigger.isUpdate && Trigger.isBefore)
        { 
            Boolean QueryLMArelations = false;
            set<ID> BusinessAccounts = new set<ID>();
            for(Business_Site__c bs: newList)
            {                
                if(bs.Account_Number__c == null || 
                   (bs.Status__c != null && bs.Status__c.toLowerCase() == 'inactive' && bs.Account_Number__c != null))
                {
                    bs.LMA_Account__c = null;
                    QueryLMArelations = true;
                    BusinessAccounts.add(bs.Account__c);
                }                
            }
            
            map<ID, CB_LMA_Relationship__c> LMArelationsMap;
            if(QueryLMArelations)
            {
                LMArelationsMap = new map<ID, CB_LMA_Relationship__c>([
                    Select ID, Name, LMA_Account__c
                    From CB_LMA_Relationship__c
                    Where Dealer_Account__c IN :BusinessAccounts
                ]);
            }
            
            list<CB_LMA_Relationship__c> toBeDeletedRelations = new List<CB_LMA_Relationship__c>();
            if(LMArelationsMap != null && !LMArelationsMap.isEmpty())
            {
                for(CB_LMA_Relationship__c LMArelation: LMArelationsMap.values())
                {
                    for(Business_Site__c bs: newList)
                    {
                        Account acc = numberToAccount.get(oldMap.get(bs.ID).Account_Number__c);
                        
                        if(acc != null && 
                           LMArelation.LMA_Account__c == acc.ID && bs.Status__c != null && bs.Status__c.toLowerCase() != 'inactive')
                        {
                            toBeDeletedRelations.add(LMArelation);
                        }
                    }
                }
            }
            
            if(toBeDeletedRelations != null && !toBeDeletedRelations.isEmpty())
            {
                Delete toBeDeletedRelations; 
            }            
        }
        
        if(Trigger.isDelete)
        {
            list<Business_site__c> oldList = oldMap.values();           
            set<ID> BusinessAccounts = new set<ID>();
            for(Business_Site__c bs: oldMap.values())
            {                
                if(bs.Account_Number__c != null)
                {                    
                    BusinessAccounts.add(bs.Account__c);
                }                
            }
            
            map<ID, CB_LMA_Relationship__c> LMArelationsMap = new map<ID, CB_LMA_Relationship__c>([
                Select ID, Name, LMA_Account__c
                From CB_LMA_Relationship__c
                Where Dealer_Account__c IN :BusinessAccounts
            ]);
            
            
            system.debug(LMArelationsMap);
            
            list<CB_LMA_Relationship__c> toBeDeletedRelations = new List<CB_LMA_Relationship__c>();
            if(LMArelationsMap != null && !LMArelationsMap.isEmpty())
            {
                for(CB_LMA_Relationship__c LMArelation: LMArelationsMap.values())
                {
                    for(Business_Site__c bs: oldMap.values())
                    {
                        Account a = numberToAccount.get(bs.Account_Number__c);
                        if(a != null && 
                           LMArelation.LMA_Account__c == a.ID)
                        {
                            toBeDeletedRelations.add(LMArelation);
                        }
                    }
                }
            }
            
            if(toBeDeletedRelations != null && !toBeDeletedRelations.isEmpty())
            {
                Delete toBeDeletedRelations; 
            } 
        }
    }
}