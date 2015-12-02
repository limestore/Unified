public class EMP_Chatter_Controller 
{
    public String UserStatus { get; set; }
    public String profileImageUrl { get; set; }
    public String CurrPageName {get;set;}
    public String post { get; set; } 
    public String AddAFeedPost { get; set; }  
    public Portal_Page__c lstportal {get;set;}
    public List<ClsCollGrp> lstCollGrp {get;set;}
    public string strGroupID {get;set;}
    public string CurrPageName1 {get;set;}
    public string ChatterGroupId {get;set;}
    public string ErrorMessage {get;set;}
    
    List<feeditem> myfeed = New List<feeditem>();
    List<user> lstuser;
    
    public String ChatterGroupIdvalue 
    {
        get{
            system.debug('getter method for chattergroupId' +chatterGroupIdvalue);
            return ChatterGroupIdvalue;
        }
        set {
            strGroupID = value;
            system.debug('******* strGroupID' +strGroupID);
            lstCollGrp=new  List<ClsCollGrp>();    
            List<id> lstUser = new List<id>();
            List<CollaborationGroupFeed> lstCollGrpTemp = [
                SELECT Body,CommentCount,CreatedById,CreatedBy.Name,CreatedDate,Id,InsertedById,LikeCount,ParentId,Parent.SmallPhotoURL,Parent.Name 
                FROM CollaborationGroupFeed 
                where parent.id=: strGroupID
                ORDER BY createddate desc 
                limit 5
            ];
            for(CollaborationGroupFeed objCollGrp :lstCollGrpTemp  ){
                //Get the id of user
                system.debug('******** objCollGrp  :'+objCollGrp.Body);
                lstUser.add(objCollGrp.CreatedById); 
            }
            Map<id,User> mapUser = new Map<id,User>([select id, name, SmallPhotoURL from User where id IN:lstUser ]);
            for(CollaborationGroupFeed objCollGrp :lstCollGrpTemp  ){
                ClsCollGrp objc = new ClsCollGrp();
                objc.objGrpFeed = objCollGrp;
                objc.strUserPhoto = mapUser.get(objCollGrp.CreatedById).SmallPhotoURL ;
                lstCollGrp.add(objc );
            }
        }
    }
    
    // constructor
    public EMP_Chatter_Controller ()
    {
    }
    
    // post from vfpage.
    public pagereference AddPost()
    {
        PageReference CurrPageReference = apexpages.currentpage();
        String CurrPageParameter = apexpages.currentpage().getparameters().get('page');
        CurrPageReference.getParameters().put('page',CurrPageParameter);
        String CurrPageName = EMP_PortalHelperClass.getVFPageName();
        
        // To grab the current PageName like "Emp_associateportal"
        if(CurrPageParameter==null || CurrPageParameter==''){ 
            CurrPageParameter = EMP_PortalHelperClass.getVFPageName();
        }
        
        FeedItem fpost = new FeedItem();
        fpost.ParentId = strGroupID;
        fpost.Body = AddAFeedPost;
        fpost.CreatedById = UserInfo.getUserId();
        fpost.Type= 'textpost';
        fpost.NetworkScope=Network.getNetworkId();
        
        /*
        PageReference pageRef;
        
        if(currPageName == null || CurrPageParameter ==''){
            PageRef = new PageReference('/apex/'+CurrPageName);
        }
        else {
            PageRef = new PageReference('/apex/'+CurrPageName+'?page='+CurrPageParameter);
        }
        */
        
        ErrorMessage = null;
        try {
            insert fpost;
        }
        catch(Exception e) {
            ErrorMessage = e.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, e.getMessage()));
        }
        
        return CurrPageReference;
    }
    
    public PageReference ShowMore() {
        PageReference pageRef = new PageReference('/_ui/core/chatter/groups/GroupProfilePage?g='+strGroupID);
        return Pageref;
    }
    
    public List<CollaborationGroup> ChattData;
    public List<CollaborationGroup> getGroupNames()
    {
        ChattData = [Select c.OwnerId, c.Name, c.Id, c.Description From CollaborationGroup c];
        return ChattData;
    }
    
    public class ClsCollGrp 
    {
        public CollaborationGroupFeed objGrpFeed {get;set;}
        public String strUserPhoto {get;set;}
        public ClsCollGrp() {
            objGrpFeed = new CollaborationGroupFeed();
        }
    }
    
}