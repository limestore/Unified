@isTest
public class EMP_AssociatePortalHomeController_test {
    static testMethod void test_ShowDefaultPage() {        
        test.startTest();  
        PageReference pageRef = Page.EMP_AssociatePortalHome;
        Test.setCurrentPage(pageRef);            
        EMP_AssociatePortalHomeController controller = new EMP_AssociatePortalHomeController();        
        test.stopTest();   
        system.assert(controller.showDefault);
    }
    
    static testMethod void test_ShowReadAll() {        
        test.startTest();  
        PageReference pageRef = Page.EMP_AssociatePortalHome;
        pageRef.getParameters().put('page', 'ReadllBlog');
        Test.setCurrentPage(pageRef);            
        EMP_AssociatePortalHomeController controller = new EMP_AssociatePortalHomeController();        
        test.stopTest();   
        system.assert(controller.showReadAll);
    }
}