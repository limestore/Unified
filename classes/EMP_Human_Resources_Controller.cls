/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Load policy, forms component, generate link for the human resources
Test Class: EMP_Human_ResourcesController_Test
History
09/17/14    Rey Austral      Created
09/24/14        Rey Austral              Add forms component
------------------------------------------------------------*/
public class EMP_Human_Resources_Controller 
{
    public List<EMP_Human_Resource_Item__c> HRSource { get; set; }
    public List<EMP_HumanResourceTopLinks__c> HRTopSource { get; set; }    
   
    Public Boolean showPolicyHub { get; set; }
    Public Boolean showPolicyAck { get; set; }
    Public Boolean showFormHub { get; set; }
    Public Boolean showDefault { get; set; }
    Public Boolean showImmigration { get; set; }
    public EMP_Human_Resources_Controller()
    {  
        String showComponent = ApexPages.CurrentPage().getParameters().get('page');
        showComponents(showComponent);
        
                if (showDefault == true)       
        {
            //generate the top link in the right section
            generateTopLinks();   
            
            //generate thte bottom link in the right section
            generateBottomLinks(); 
        }
    }
    
    private void showComponents(String showComponent)
    {
        showPolicyHub = false;
        showPolicyAck = false;
        showFormHub = false;
        showDefault = false;
        showImmigration =false;
        EMP_HR_Components__c comp = EMP_HR_Components__c.getOrgDefaults();
       
        //show only policy hub component when the policy hub link is click
        if(comp.Policy__c.equals(showComponent)) 
        {
            showPolicyHub = true;           
        }
        else if(comp.Acknowledgement__c.equals(showComponent))
        {
            //show only policy Acknowledgements component when the policy Acknowledgements link is click           
            showPolicyAck = true;            
        } 
        else if (comp.Form__c.equals(showComponent)) 
        {
            //show form component when the form is click from common task or human resource page
            showFormHub = true;
        }
        else if (comp.Immigration__c.equals(showComponent))
        {
            //show immigration component when the form is click from common task or human resource page
            showImmigration = true;
        }
        else 
        {  
            //show the default human resources content
            showDefault = true;
        }     
       
    }
    
    private void generateTopLinks()
    {
        //get records in the custom settings objects
        HRTopSource = EMP_HumanResourceTopLinks__c.getAll().values();
        
        //iterate the values and replace the page_target__c value that will be read by the html
        for(EMP_HumanResourceTopLinks__c setting : HRTopSource)
        {            
            if ('New Page'.equals(setting.Page_Target__c))
            {
                setting.Page_Target__c = '_blank';
            }
            else if ('Self'.equals(setting.Page_Target__c))
            {
                setting.Page_Target__c = '_top';
            }
            else
            {
                setting.Page_Target__c = '_blank';
            }            
        }
        HRTopSource.sort();     
    }    

    private void generateBottomLinks()
    {
        //get records in the custom settings objects    
        HRSource = EMP_Human_Resource_Item__c.getAll().values();
        Integer ctr=0,policyAckIndex = 0;
        Boolean ackFound = false;
        
        //iterate the values and replace the page_target__c value that will read by the html
        for(EMP_Human_Resource_Item__c setting : HRSource)
        {            
            if ('New Page'.equals(setting.Page_Target__c))
            {
                setting.Page_Target__c = '_blank';
            }
            else if ('Self'.equals(setting.Page_Target__c))
            {
                setting.Page_Target__c = '_top';
            }
            else
            {
                setting.Page_Target__c = '_blank';
            }
            
            //condition to get the policy acknowledgement index in the list
            if ('Policy Acknowledgement'.equals(setting.HR_Name__c))
            {
                policyAckIndex = ctr;
                ackFound = true;
            }
            ctr++;            
        }
        
        //check if the current user as policy acknowledgement to process
        //if none, remove the policy acknowledement in the list
        Boolean acknowledgement = hasAcknowledgement();        
        if (acknowledgement == false && ackFound == true)
        {
            HRSource.remove(policyAckIndex);
        }
        
        HRSource.sort();   
    }
    
    private Boolean hasAcknowledgement()
    {
        //get the policy that will be needed to be acknowledge by the current user
        Boolean result = false;

        Id usrID = userInfo.getUserId();
        List<EMP_Policy__c> policy = [SELECT Id, Name , Content_Version_ID__c                                
                                       FROM EMP_Policy__c
                                       WHERE User_Name__c =: usrID ];
        if (!policy.isEmpty())
        {
            result = true;
        }
        return result;
    }    
  
}