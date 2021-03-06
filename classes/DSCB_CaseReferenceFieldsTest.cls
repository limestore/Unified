@IsTest
public class DSCB_CaseReferenceFieldsTest
{
    static testMethod void CaseReferenceLimitsWorkAround()
    {
        Trigger_Toggle__c tt = new Trigger_Toggle__c();
        tt.Name = 'ALL DSCB_CaseReferenceFields';
        tt.Code_Reference__c = 'DSCB_CaseReferenceFields';
        tt.On__c = true;
        tt.sObject__c = 'Case';
        insert tt;
        
        //Insert User and Account
        User u = DS_TestObjects.NewUser_Inserted();
        Account a = New Account(); 
        a.Name ='testName'; 
        a.Account_Number__c = '12345';
        insert a;
        
        //Insert WebId Field values
        WebId__c w = New WebId__c(); 
        w.Account__c = a.Id; 
        w.BAC_Dealer_Code__c = '1234';
        w.Account_Advocate__c = u.Id;
        w.Online_Marketing_Specialist__c = u.Id;
        w.Primary__c = True;
        w.WebNum__c = '12345';
        insert w;
        
        contact con = DS_TestObjects.NewContact();
        con.AccountId = a.Id;
        insert con;
        
        //Insert Case Filed values
        Case c = New Case(); 
        c.AccountId = a.Id; 
        c.BAC_Dealer_Code__c = w.BAC_Dealer_Code__c; 
        c.Account_Advocate__c = 'Siva Pragada';
        c.Online_Marketing_Specialist__c = 'Siva Pragada';
        c.Zip_Code__c = '12345'; 
        c.WebNum__c = '1234';
        //c.Primary_Site_Status__c = 'Primary';  
        c.webid__c = w.id;
        c.Destination_Account__c = a.id;
        c.Dealer_Group_Contact__c = con.Id;
        c.ContactId = con.Id;
        insert c;
        
        // Update Case
        w.Primary__c = False;
        update w;
        
        u.Extension = '123';
        
        update u;
        update c;
    }
}