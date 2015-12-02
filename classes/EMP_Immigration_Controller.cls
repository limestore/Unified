/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Load Immigration data for the human resources
Test Class: EMP_Immigration_Controller_Test
History
12/18/14    Rey Austral      Created
------------------------------------------------------------*/
public class EMP_Immigration_Controller {
    public List<ContentDataWrapper> content { get; set; }
    public EMP_Immigration_Controller() {
        content = new List<ContentDataWrapper>();
        List<ContentVersion> contentVersions = new  List<ContentVersion>();
        //get the content in the library
        contentVersions = EMP_PolicyUtility.getAllLatestDocument('Immigration');
        
        if (!contentVersions.isEmpty())
        {
            //arrange the content by geographic 
            populateContentWrapper(contentVersions);
        }
    }
    
    private void populateContentWrapper(List<ContentVersion> contentVersions) 
    {
        //get the distinct geographic in the list        
        List<String> contentGeographicField = getPolicyCategory(contentVersions);        
        for (String geographic : contentGeographicField)
        {                      
            ContentDataWrapper policyContent =  new ContentDataWrapper();
            List<ContentVersion> toAddContent = new List<ContentVersion>();
            
            //iterate all the content
            for (ContentVersion content : contentVersions)
            {
                //check if the content belongs to the geographic location
                if (geographic == content.Immigration_Geographic_Applicability__c)                 
                {
                    toAddContent.add(content);
                }
            }
            
            //add to content wrapper
            if (!toAddContent.isEmpty())
            {
                toAddContent.sort();
                policyContent.geographic = geographic;
                policyContent.contentData = toAddContent;
                content.add(policyContent);
            }
        }
    }

    
    private List<String> getPolicyCategory(List<ContentVersion> contents)
    {
        //this method is to get the distinct value of geographic in the policy content
        //this method will sort the cateogory by asc order
        //this method will also check if there are global content then make the global in the first list
        List<String> contentGeographicField = new List<String>();
        Map<String,String> MapPolicyGeographic = new Map<String,String>();
        Boolean policyGlobal = false;
        
        for (ContentVersion content : contents)
        {   
            
            if(!MapPolicyGeographic.containsKey(content.Immigration_Geographic_Applicability__c))
            {                    
                MapPolicyGeographic.put(content.Immigration_Geographic_Applicability__c, content.Immigration_Geographic_Applicability__c);
                contentGeographicField.add(content.Immigration_Geographic_Applicability__c);                    
            }
            
        }       
        contentGeographicField.sort();  
        
        return contentGeographicField;
    }
    
    public class ContentDataWrapper
    {
        public String geographic { get; set; }
        public List<ContentVersion> contentData { get; set; }
    }
}