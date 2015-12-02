public class EMP_ReadAllBlogController {
    public id contentVersionId {get;set;}
    public Set<Id> cVersionID = new Set<Id>();
    public Set<String> cTitle = new Set<String>(); //contains contentversion titles
    public Set<Id> setContentDocumentIds = new Set<Id>(); //contains set of contentDocument Ids
    public list<ContentVersion> recentUpdates {get;set;}
    public Set<String> subHeaderTitle = new Set<String>();
    public Set<Id> latestVersion = new Set<Id>();
    public static final String workspace = System.Label.EMP_Library_Name;
    public List<ContentWrapper> contentSource { get; set; }
    public String ContentTag {get;set;}
    public Integer NumColumns {get;set;}
    public Boolean showAll {get;set;}   
    public EMP_ReadAllBlogController()
    {
        recentUpdates = new List<ContentVersion>();
        contentSource = new List<ContentWrapper>();
        //query all contentDocument Id
        //query all contentDocument Id and add to the linksId
        EMP_ContentDocumentHelper  cdhelper = new EMP_ContentDocumentHelper (workspace);
        
        setContentDocumentIds = cdHelper.ContentDocumentIds;
        latestVersion = cdHelper.LatestVersionIds;  
        
        // validates that set(setContentDocumentIds) contains value
        if(!setContentDocumentIds.isEmpty() || setContentDocumentIds.size() > 0)
        {
            // query all ContentVersion 
            list<ContentVersion> ContentVersions = [
                Select ContentDocumentId, Title, Publish_Date__c, TagCsv, Document_Type__c, Video_File_Location__c , Executive__c
                From ContentVersion 
                WHERE Id IN: latestVersion
                AND ContentDocumentId IN:setContentDocumentIds               
                AND Expiration_Date__c >: system.Today()
                AND Content_Start_Date__c <=: system.Today()               
                ORDER BY Publish_Date__c DESC 
            ];
            
            if(ContentVersions != null && !ContentVersions.isEmpty())
            {
                Map<Id,ContentWrapper> userUrl = mapUser(ContentVersions);
                for(ContentVersion objContentVersion : ContentVersions)
                {
                    if (!subHeaderTitle.contains(objContentVersion.Title))
                    {  
                        // modified by Lalitha Adduru on 19th Feb 2015 to check 
                        // if the tag 'contains' leadership blog rather than 
                        // 'equal to' , and an if condition prior to that, to prevent null pointer exception. 
                        if(objContentVersion.TagCsv != null)
                        {
                            if (string.valueof(objContentVersion.TagCsv).contains('Leadership Blog'))
                            {
                                subHeaderTitle.add(objContentVersion.Title);                               
                                ContentWrapper execInfo =  userUrl.get(objContentVersion.Executive__c);                                
                                ContentWrapper contents = new ContentWrapper();
                                contents.userFullName = execInfo.userFullName;
                                contents.userUrl  = execInfo.userUrl;                                   
                                contents.content = objContentVersion;
                                contentSource.add(contents);        
                            }
                        }
                    }
                }
            }
        } // end of if condition
    } // end of contstructor
    
    public map<Id,ContentWrapper> mapUser(List<ContentVersion> contentVersions)
    {
        Map<Id,ContentWrapper> mapItem = new Map<Id,ContentWrapper>();
        Map<Id,Id> userId = new Map<Id,Id>();
        for(ContentVersion objContentVersion : contentVersions)
        {
            if (!userId.containsKey(objContentVersion.Executive__c)) {
                userId.put(objContentVersion.Executive__c,objContentVersion.Executive__c);
            }
        }
        
        List<User> listUser = [Select Id,Name, smallphotourl from User where Id in : userId.keySet() ];
        for (User users : listUser)
        {
            ContentWrapper content = new ContentWrapper();
            content.userUrl = users.smallphotourl;
            content.userFullName = users.Name;
            mapItem.put(users.Id,content);
        }
        
        return mapItem;
    }
    
    public class ContentWrapper {
        public String userUrl { get; set; }
        public String userFullName { get; set; }
        public ContentVersion content { get; set; }
    }
}