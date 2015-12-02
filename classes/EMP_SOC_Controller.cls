/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Load SOC Reports and soc contacts
Test Class: EMP_SOC_Controller_Test
History
1/21/15    Rey Austral      Created
------------------------------------------------------------*/
public class EMP_SOC_Controller {
    public List<EMP_SOC_Contacts__c> contactInformation { get; set; }
    public List<report_Wrapper> lstContent { get; set; }
    public List<report_Wrapper> lstExternalSite { get; set; }
    Map<String, Map<String,List<ContentVersion>>> mapContent { get; set; }
    public EMP_SOC_Controller() 
    {
        //get the workspace data to retrieve the content
        Map<Id, ContentDocument> contentDocuments = new map<Id, ContentDocument> ([
            SELECT Title,  PublishStatus,  ParentId, OwnerId,  Id, LatestPublishedVersionId
            FROM ContentDocument
            WHERE ParentId IN: [
                SELECT Id 
                FROM ContentWorkspace 
                WHERE Name = 'Report'
            ] 
        ]);        
        //get all the content that have report catergory SOC and not yet expired
        Map<Id,ContentVersion> contentVersions = new Map<Id,ContentVersion> ([Select Title,Id, VersionNumber, Applicability__c ,
                                                                              Sort_Order__c,Section_SubGroup__c
                                                                              From ContentVersion where ContentDocumentId in: contentDocuments.keyset() 
                                                                              and Expiration_Date__c >= TODAY and Report_Category__c = 'SOC' ] ); 
        
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();        
        //only get the latest uploaded file
        for(ContentDocument contentDoc : contentDocuments.values())
        {            
            if (contentVersions.containsKey(contentDoc.LatestPublishedVersionId))
            {
                ContentVersion latestContent = contentVersions.get(contentDoc.LatestPublishedVersionId);
                lstContentVersion.add(latestContent);
            }
        }
        
        mapContent = new Map<String, Map<String,List<ContentVersion>>>();
        //group the content by Applicability and Subgroup
        for(ContentVersion con : lstContentVersion) {
            if (!mapContent.containskey(con.Applicability__c)) {
                Map<String,List<ContentVersion>> sub = new  Map<String,List<ContentVersion>>();               
                List<ContentVersion> countVer = new List<ContentVersion>();
                
                if (con.Section_SubGroup__c == null) {
                    con.Section_SubGroup__c = ' ';
                }
                
                countVer.add(con);
                sub.put(con.Section_SubGroup__c,countVer);                 
                mapContent.put(con.Applicability__c, sub);
                
            } else {
                Map<String,List<ContentVersion>> storedValues = mapContent.get(con.Applicability__c);
                if (con.Section_SubGroup__c == null) {
                    con.Section_SubGroup__c = ' ';
                }
                if(!storedValues.containsKey(con.Section_SubGroup__c)) {
                    List<ContentVersion> countVer = new List<ContentVersion>();
                    
                    countVer.add(con);
                    storedValues.put(con.Section_SubGroup__c,countVer); 
                } else {
                    List<ContentVersion> content = storedValues.get(con.Section_SubGroup__c);
                    content.add(con);
                }
            }
        }
        lstContent = new List<report_Wrapper>();
        lstExternalSite = new List<report_Wrapper>();
        //add additional property (image and Description) and order the data        
        if (!mapContent.isEmpty()){           
            generateContentRecord();
        }
        //load contact information in the custom settings
        contactInformation = EMP_SOC_Contacts__c.getAll().values();
        
    }    
    
    private void generateContentRecord()
    {
        List<EMP_SOC_Config__c> mapSOC_Config = [Select Name,Image_URL__c,Description__c,isReportCategory__c from EMP_SOC_Config__c order by Order__c];
        for (EMP_SOC_Config__c config : mapSOC_Config)
        {
            report_Wrapper wrapSection = new report_Wrapper();
            List<reportSubCategory_Wrapper> lstSubCategory = new List<reportSubCategory_Wrapper>();
            //get the applicability value
            String section =  config.Name; 
            //get the description and image in the custom settings           
            
            wrapSection.image = config.Image_URL__c;
            //wrapSection.description = config.Description__c;
            
            if (mapContent.containsKey(section)) {
                //get the report category value of the current section
                Map<String,List<ContentVersion>> mapSubcategory = mapContent.get(section);
                for (String subCategory : mapSubcategory.keySet()) {
                    //get the content of the report category
                    List<ContentVersion> content = mapSubcategory.get(subCategory);
                    //add the key and data in the wrapper class
                    reportSubCategory_Wrapper wrapSubCategory = new reportSubCategory_Wrapper();
                    wrapSubCategory.subCategory = subCategory;
                    wrapSubCategory.contentData = content;
                    wrapSubCategory.content = sortContentDataByOrder(content);
                    //add in the list
                    lstSubCategory.add(wrapSubCategory);
                }
                //save the section and list of sub category in the main wrapper class
                wrapSection.applicability = section;
                wrapSection.reportSubCategoryWrapper = lstSubCategory;
                //check if the content is in the left side or right side
                //if isReportCategory__c is true, content will be loaded in the left side
                if (config.isReportCategory__c) {
                    lstContent.add(wrapSection);
                } else {
                    lstExternalSite.add(wrapSection);
                }
            }
        }
    }
    
    public List<content_Wrapper> sortContentDataByOrder(List<ContentVersion> content)
    {
        List<content_Wrapper> wrap = new List<content_Wrapper>();
        for (ContentVersion con : content) 
        {
            content_Wrapper c = new content_Wrapper();
            c.Title = con.Title;
            c.contentId = con.Id;           
            c.Order = Integer.valueOf(con.Sort_Order__c);
            wrap.add(c);
        }
        wrap.sort();
        return wrap;
    }
    
    public class report_Wrapper
    {
        public String applicability { get; set; }
        //public String description { get; set; }
        public String image { get; set; }
        public List<reportSubCategory_Wrapper> reportSubCategoryWrapper { get; set; }
    }
    
    public class reportSubCategory_Wrapper 
    {
        public String subCategory { get; set; }
        public List<ContentVersion> contentData { get; set; }
        public List<content_Wrapper> content { get; set; }
    }
    
    public class content_Wrapper implements Comparable
    {
        public string Title { get; set; }
        public string contentId { get; set; }       
        public Integer Order { get; set; }
        public Integer compareTo(Object compareTo)
        {
            content_Wrapper comWrap = (content_Wrapper) compareTo;
            if (Order == comWrap.Order) return 0;
            if (Order > comWrap.Order) return 1;
            return -1;  
        }
    }
    
    
}