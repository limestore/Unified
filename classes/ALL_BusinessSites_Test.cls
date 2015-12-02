@isTest
public class ALL_BusinessSites_Test 
{
    public static testMethod void unitTest()
    {
        Site_Type__c st = DS_TestObjects.NewSiteType();
        st.Name = 'Local Marketing';
        st.Active__c = true;
        insert st;
        
        Account acc = DS_TestObjects.NewAccount();
        acc.Site_Type__c = st.ID;
        acc.Account_Number__c = '12345';
        insert acc;
        
        Business_Site__c bs = new Business_Site__c();
        bs.LMA_Account__c = acc.ID;
        bs.Account_Number__c = acc.Account_Number__c;
        bs.Status__c = 'inactive';
        bs.Account__c = acc.ID;
        insert bs;
        
        bs.Account_Number__c = null;
        update bs;
        
        bs.Account_Number__c = '12345';
        update bs;
        
        delete bs;
    }
}