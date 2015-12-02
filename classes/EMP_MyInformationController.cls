/*RQ-04089 -line 7 : added fields to query *** Vijay Manimaran *** 2/25/2015 */

public class EMP_MyInformationController {
    public List<User> infoSource { get; set; }
    public list<contact> myInfoContact {get; set; }
    public EMP_MyInformationController() {
        infoSource = [Select Id,Name , (Select FirstName,LastName,Title,Vendor_ID__c,Email,HR_Title__c,HR_Manager__r.Name,HR_Location__c,HR_Business_Unit__c from contacts__r) from User where Id = : UserInfo.getUserId()];
        system.debug('****** infoSource' +infoSource);
        user u =[select id, Name from user where Id = : UserInfo.getUserId() ];
        myInfoContact =[Select FirstName,LastName,Title,Vendor_ID__c,Email,HR_Title__c,HR_Manager__r.Name,HR_Location__c,HR_Business_Unit__c from contact where User__c =: u.id];
    }
}