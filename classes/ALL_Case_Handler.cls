/*----------------------------------------------
HISTORY:

07/13/15 - Hemanth Kesapragada - RQ-04941-Added logic to call Entitlements method when record type changes
07/28/15 - Venkata Shrivol     - Code Refactored for total Entitlements and RQ-05068 
-------------------------------------------------*/
public class ALL_Case_Handler 
{  
    public static void ToggleController(List<Case> NewList, List<Case> OldList, Map<Id, Case> newMap, Map<Id, Case> oldMap)
    {
        boolean notFutureOrBatch = !system.isFuture() && !system.isBatch() && !system.isScheduled();
        
        // begin checking processing for each code block
        // map<CodeReference, list<Case>>
        map<string, list<Case>> FilteredTriggerNew = new map<string, list<Case>>(); 
        
        FilteredTriggerNew = ALL_Case_Handler.ToggleFilter(NewList);
        //system.debug(FilteredTriggerNew);
        FilteredTriggerNew = ALL_Case_Handler.ProfileFilter(FilteredTriggerNew);
        //system.debug(FilteredTriggerNew);
                
        // for debugging, FilteredTriggerNew2 is not used in the code
       /*map<string, list<string>> FilteredTriggerNew2 = new map<string, list<string>>();
        FilteredTriggerNew2 = ALL_Case_Handler.ToggleFilter_ForDebug(NewList);        
        system.debug(FilteredTriggerNew2);*/
        
        // process before insert and before update actions
        if(Trigger.isBefore) 
        {
            boolean recursiveCheckBefore = All_CheckRecursive.runCodeBlockOnce('AllowOnlyOnce');
            if(Trigger.isInsert || Trigger.isUpdate) 
            {
                if(recursiveCheckBefore)
                {
                    // DSCB_CaseReferenceFields                
                    list<Case> ReferenceFieldCases = FilteredTriggerNew.get('DSCB_CaseReferenceFields');
                    
                    if( ReferenceFieldCases != null && !ReferenceFieldCases.isEmpty())  
                    {                     
                        DSCB_CaseReferenceFields.SetCaseReferenceFields(ReferenceFieldCases); 
                    }
                    
                    // DS_CaseDefaultAccount
                    list<Case> DefaultAccountCases = FilteredTriggerNew.get('DS_CaseDefaultAccount');
                    
                    if( DefaultAccountCases != null && !DefaultAccountCases.isEmpty())
                    {
                        DSCB_CaseReferenceFields.CaseDefaultAccount(DefaultAccountCases);
                    }  
                    
                    //DSCB_CaseUserManager
                    list<Case> UserManagerCases = FilteredTriggerNew.get('DSCB_CaseUserManager');
                    
                    if(UserManagerCases != null && !UserManagerCases.isEmpty())
                    {
                        DSCB_CaseReferenceFields.CaseUserManager(UserManagerCases, oldMap);
                    }
                    
                    // SEO Case Assignment rule through the trigger based on Account Plan resource fields added 11/24/2014 SivaP
                    list<Case> SeoAssignmentCases = FilteredTriggerNew.get('DSCB_CaseAssignment');
                    
                    if(SeoAssignmentCases != null && !SeoAssignmentCases.isEmpty()) 
                    {                      
                        DSCB_CaseAssignment.CaseAssignmentRule(SeoAssignmentCases, OldMap);                    
                    } 
                    
                    if(Trigger.isInsert)
                    {
                        // begin CB_EntitlementsToCaseAssignment_Handler                
                        // Added by Venkata 03/16/2015 for updating case with Entitlements from related WebId 
                        list<Case> EntitlementToCases = FilteredTriggerNew.get('CB_EntitlementsToCaseAssignment_Handler');
                        
                        if(EntitlementToCases != null && !EntitlementToCases.isEmpty())
                        {
                            CB_EntitlementsToCaseAssignment_Handler.webIdNullCheck(EntitlementToCases, oldMap);
                        }
                    }
                    
                    if(Trigger.isUpdate)
                    {
                        // begin CB_MileStoneDatesOnCase_Handler
                        
                        // Case COmpletion Dates - Start
                        list<Case> completionDateCasesBU = FilteredTriggerNew.get('CB_MileStoneDatesOnCase_Handler');
                        
                        if( completionDateCasesBU != null && !completionDateCasesBU.isEmpty()) 
                        {                      
                            CB_MileStoneDatesOnCase_Handler.updateCases(completionDateCasesBU, oldMap);
                        } // Case COmpletion Dates - End
                        
                        
                        list<Case> creativeAndTechSupportCases = FilteredTriggerNew.get('CB_EntitlementsToCaseAssignment_Handler');
                        
                        if(creativeAndTechSupportCases != null && !creativeAndTechSupportCases.isEmpty())
                        {
                            CB_Entitlements_Handler.routeEntitlementCallsToHandlers(creativeAndTechSupportCases, oldMap);
                        }
                        
                        // Added by Venkata 06/04/2015 for updating case with Entitlements from related WebId 
                        list<Case> EntitlementToCasesBU = FilteredTriggerNew.get('CB_EntitlementsToCaseAssignment_Handler');
                        
                        if(EntitlementToCasesBU != null && !EntitlementToCasesBU.isEmpty())
                        {
                            CB_Entitlements_Handler.entitlementsToCasesBU(EntitlementToCasesBU, oldMap);
                        }
                    } // end Trigger.isUpdate
                }
            }
            
        } // end Trigger.isBefore
        
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
        {
            boolean recursiveCheckAfter = All_CheckRecursive.runCodeBlockOnce('recursiveCheckAfter');
            
            if(recursiveCheckAfter)
            {
                if(Trigger.isUpdate)
                {
                    // begin CB_MileStoneDatesOnCase_Handler
                    // Case Entitlements COmpletion Date - Start
                    list<Case> completionDateCasesAU = FilteredTriggerNew.get('CB_MileStoneDatesOnCase_Handler');
                    
                    if(completionDateCasesAU != null && !completionDateCasesAU.isEmpty())
                    {
                        CB_Entitlements_Handler.completionDateCasesAU(completionDateCasesAU, oldMap);
                    }
                } 
                
                if(Trigger.isInsert)
                {
                    // begin CB_CrtiveCseTallyUpdteWbIdAccPlan_Hndler, also CB_MileStoneDatesOnCase_Handler
                    list<Case> ccTallyUpdateCases = FilteredTriggerNew.get('CB_CrtiveCseTallyUpdteWbIdAccPlan_Hndler');
                    
                    if(ccTallyUpdateCases != null && !ccTallyUpdateCases.isEmpty())
                    {
                        CB_Entitlements_Handler.ccTallyUpdateCases(ccTallyUpdateCases);
                    }
                    
                    list<Case> targetDateTimecaseListAI = FilteredTriggerNew.get('CB_MileStoneDatesOnCase_Handler');
                    
                    if(targetDateTimecaseListAI != null && !targetDateTimecaseListAI.isEmpty())
                    {
                        CB_Entitlements_Handler.targetDateTimecaseListAI(targetDateTimecaseListAI);
                    }
                }
            }
            
            // CaseTriggers - separate class, but not separate trigger
            list<Case> CaseTriggerCases = FilteredTriggerNew.get('caseTriggers');
            
            if(CaseTriggerCases != null && !CaseTriggerCases.isEmpty() && ALL_CheckRecursive.runCodeBlockGivenTimes('CaseTeamMember', 3))
            { 
                caseTriggers.CaseTriggerCases(CaseTriggerCases, NewMap, oldMap);
            } 
            
            
            // DSCB_CaseAccountFieldUpdate - pulled in, not a separate trigger/class            
            list<Case> AccountFieldUpdateCases = FilteredTriggerNew.get('DSCB_CaseAccountFieldUpdate');
            
            if(AccountFieldUpdateCases != null && !AccountFieldUpdateCases.isEmpty())
            {
                CB_Entitlements_Handler.AccountFieldUpdateCases(AccountFieldUpdateCases);
            }
            // end DSCB_CaseAccountFieldUpdate
            
            // For updating the response date field value on contact object with the same field value on Case if record type is Tier 1
            // This is controlled from Trigger Toggle custom settings
            list<Case> ResponseDateCases = FilteredTriggerNew.get('DSCB_UpdatesThroughCaseObject');
            
            if(ResponseDateCases != null && !ResponseDateCases.isEmpty() && recursiveCheckAfter)
            {
                DSCB_UpdatesThroughCaseObject.UpdateMethod(ResponseDateCases);
            }
            
        } // end Trigger.isAfter
        
    }
    
    //collects cases in a list recordtype wise and puts in a map
    public static map<string, list<Case>> RecordTypeToCases(List<Case> NewList) 
    {
        map<string, list<Case>> RecordTypeToCases = new map<string, list<Case>>();
        
        for(Case c: NewList)
        {
            string RecordTypeName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Case', c.RecordTypeId);
            list<Case> CasesRecordTypeWise = RecordTypeToCases.get(RecordTypeName);
            
            if(CasesRecordTypeWise == null)
            { 
                CasesRecordTypeWise = new list<Case>();
                CasesRecordTypeWise.add(c);
            }
            else
            {
                CasesRecordTypeWise.add(c);
            }
            
            RecordTypeToCases.put(RecordTypeName, CasesRecordTypeWise);
        }
        
        return RecordTypeToCases;
    }
    
    //collects trigger toggles of recordtype field null and non null values separately in two lists and puts them in a map 
    public static map<string, list<Trigger_Toggle__c>> getOrganizedTriggerToggles()
    {
        map<string, Trigger_Toggle__c> TriggerToggle = Trigger_Toggle__c.getAll();
        
        map<string, list<Trigger_Toggle__c>> TriggerTogglesRecordTypeWise = new map<string, list<Trigger_Toggle__c>>();
        
        set<string> AllCodeReferences = new set<string>();
        
        for(Trigger_Toggle__c tt: TriggerToggle.values())
        {
            AllCodeReferences.add(tt.Code_Reference__c);
            
            if(tt.sObject__c == 'Case')
            {
                list<Trigger_Toggle__c> NullRecordTypeToggles = TriggerTogglesRecordTypeWise.get('TogglesWithNullRecordTypes');
                if(NullRecordTypeToggles == null){ NullRecordTypeToggles = new list<Trigger_Toggle__c>();}
                
                list<Trigger_Toggle__c> RecordTypeToggles = TriggerTogglesRecordTypeWise.get('TogglesWithRecordTypes');
                if(RecordTypeToggles == null){ RecordTypeToggles = new list<Trigger_Toggle__c>();}
                
                if(tt.RecordType_Name__c == null) 
                {
                    NullRecordTypeToggles.add(tt);                    
                }
                if(tt.RecordType_Name__c != null) { RecordTypeToggles.add(tt); }
                
                TriggerTogglesRecordTypeWise.put('TogglesWithNullRecordTypes', NullRecordTypeToggles);
                TriggerTogglesRecordTypeWise.put('TogglesWithRecordTypes', RecordTypeToggles);
            }
        }        
        return TriggerTogglesRecordTypeWise;
    }
    
    // loops through trigger toggles and decides and collects cases that are meant for each code reference block in a map
    public static map<string, list<case>> recordWiseCasesOrganizer(
        map<string, list<Trigger_Toggle__c>> TriggerTogglesRecordTypeWise, map<string, list<case>> RecordTypeToCases)
    {
        map<string, list<case>> CasesToRecordName = new map<string, list<case>> ();
        
        list<Trigger_Toggle__c> NullTriggerToggleList = TriggerTogglesRecordTypeWise.get('TogglesWithNullRecordTypes');
        
        if(NullTriggerToggleList != null && !NullTriggerToggleList.isEmpty())
        {
            for(Trigger_Toggle__c Toggle: NullTriggerToggleList)
            {           
                if(Toggle != null )
                {
                    string CodeReference = Toggle.Code_Reference__c;
                    
                    list<Trigger_Toggle__c> TriggerToggleList = TriggerTogglesRecordTypeWise.get('TogglesWithRecordTypes');
                    
                    if(TriggerToggleList != null && !TriggerToggleList.isEmpty())
                    {
                        for(Trigger_Toggle__c tt:  TriggerToggleList)
                        {
                            if(Toggle.On__c)
                            {                        
                                if(tt.Code_Reference__c == CodeReference && !tt.On__c)
                                {
                                    list<case> CodeReferenceWiseCases = CasesToRecordName.get(CodeReference);
                                    
                                    for(string RecordTypeName: RecordTypeToCases.keySet())
                                    {                                
                                        if(CodeReferenceWiseCases == null)
                                        {
                                            CodeReferenceWiseCases = new list<case>();
                                            
                                            if(RecordTypeName != tt.RecordType_Name__c)
                                            { 
                                                list<case> RecordTypesAndCases = RecordTypeToCases.get(RecordTypeName);
                                                if(RecordTypesAndCases != null && !RecordTypesAndCases.isEmpty())
                                                {
                                                    for(case c:RecordTypesAndCases){
                                                        CodeReferenceWiseCases.add(c);
                                                    }
                                                }
                                            }
                                        }
                                        else
                                        {
                                            if(RecordTypeName != tt.RecordType_Name__c)
                                            { 
                                                list<case> RecordTypesAndCases = RecordTypeToCases.get(RecordTypeName);
                                                if(RecordTypesAndCases != null && !RecordTypesAndCases.isEmpty())
                                                {
                                                    for(case c:RecordTypesAndCases){
                                                        CodeReferenceWiseCases.add(c);
                                                    } 
                                                }
                                            } 
                                        }                                                       
                                    }                            
                                    CasesToRecordName.put(CodeReference, CodeReferenceWiseCases); 
                                }                        
                            }
                            
                            if(!Toggle.On__c)
                            {
                                if(tt.Code_Reference__c == CodeReference && tt.On__c)
                                {
                                    list<case> CodeReferenceWiseCases = CasesToRecordName.get(CodeReference);
                                    
                                    for(string RecordTypeName: RecordTypeToCases.keySet())
                                    {                        
                                        if(CodeReferenceWiseCases == null)
                                        {
                                            CodeReferenceWiseCases = new list<case>();
                                            
                                            if(RecordTypeName == tt.RecordType_Name__c)
                                            { 
                                                list<case> RecordTypesAndCases = RecordTypeToCases.get(RecordTypeName);
                                                if(RecordTypesAndCases != null && !RecordTypesAndCases.isEmpty())
                                                {
                                                    for(case c:RecordTypesAndCases){
                                                        CodeReferenceWiseCases.add(c);
                                                    }
                                                }
                                            }
                                        }
                                        else
                                        {
                                            if(RecordTypeName == tt.RecordType_Name__c)
                                            { 
                                                list<case> RecordTypesAndCases = RecordTypeToCases.get(RecordTypeName);
                                                if(RecordTypesAndCases != null && !RecordTypesAndCases.isEmpty())
                                                {
                                                    for(case c:RecordTypesAndCases){
                                                        CodeReferenceWiseCases.add(c);
                                                    }
                                                }
                                            } 
                                        }                      
                                    }                            
                                    
                                    CasesToRecordName.put(CodeReference, CodeReferenceWiseCases);
                                }                                           
                            }
                        }
                    }
                }
            }
        }
        system.debug(CasesToRecordName);
        return CasesToRecordName;
    }
    
    public static map<string, list<Case>> ToggleFilter(list<Case>NewList)
    {       
        
        map<string, list<Trigger_Toggle__c>> TriggerTogglesRecordTypeWise = new map<string, list<Trigger_Toggle__c>>(
            ALL_Case_Handler.getOrganizedTriggerToggles()
        );
        
        
        map<string, list<case>> RecordTypeToCases = new map<string, list<case>>(
            ALL_Case_Handler.RecordTypeToCases(NewList)
        ); 
           
        
        return ALL_Case_Handler.recordWiseCasesOrganizer(TriggerTogglesRecordTypeWise, RecordTypeToCases);
    }
    
    public static map<string, list<Case>> ProfileFilter(map<string, list<Case>> FinalCasesMap)
    {       
        map<string, Trigger_Toggle_Profile__c> TpMap = Trigger_Toggle_Profile__c.getAll();
        
        for(Trigger_Toggle_Profile__c tp: TpMap.values())
        {
            if(tp.sObject__c == 'Case')
            {
                for(string CodeReference: FinalCasesMap.keySet())
                {
                    if(tp.get('Code_Reference__c') != null && 
                       tp.get('Code_Reference__c') == CodeReference && 
                       !tp.On__c && tp.Profile_Id__c == userInfo.getProfileId())
                    {                     
                         FinalCasesMap.get(CodeReference).Clear();                        
                    }
                    
                }
            }
        }        
        return FinalCasesMap;
    } 
    
    
    //For debugging purpose only
    /* public static map<string, list<string>> RecordTypeToCases_ForDebug(List<Case> NewList) 
    {
        map<string, list<string>> RecordTypeToCases = new map<string, list<string>>();
        
        for(Case c: NewList)
        {
            string RecordTypeName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Case', c.RecordTypeId);
            list<string> CasesRecordTypeWise = RecordTypeToCases.get(RecordTypeName);
            
            if(CasesRecordTypeWise == null)
            { 
                CasesRecordTypeWise = new list<string>();
                CasesRecordTypeWise.add(c.status);
            }
            else
            {
                CasesRecordTypeWise.add(c.status);
            }
            
            RecordTypeToCases.put(RecordTypeName, CasesRecordTypeWise);
        }
        
        return RecordTypeToCases;
    }
    
    public static map<string, list<string>> ToggleFilter_ForDebug(list<Case> NewList)
    {       
        
        map<string, list<Trigger_Toggle__c>> TriggerTogglesRecordTypeWise = new map<string, list<Trigger_Toggle__c>>(
            ALL_Case_Handler.getOrganizedTriggerToggles()
        );
        
        
        map<string, list<string>> RecordTypeToCases = new map<string, list<string>>(
            ALL_Case_Handler.RecordTypeToCases_ForDebug(NewList)
        ); 
           
        
        return ALL_Case_Handler.recordWiseCasesOrganizer_ForDebug(TriggerTogglesRecordTypeWise, RecordTypeToCases);
    }
    
     public static map<string, list<string>> recordWiseCasesOrganizer_ForDebug(
        map<string, list<Trigger_Toggle__c>> TriggerTogglesRecordTypeWise, map<string, list<string>> RecordTypeToCases)
    {
        map<string, list<string>> CasesToRecordName = new map<string, list<string>> ();
        
        for(Trigger_Toggle__c Toggle: TriggerTogglesRecordTypeWise.get('TogglesWithNullRecordTypes'))
        {           
            if(Toggle != null )
            {
                string CodeReference = Toggle.Code_Reference__c;
                
                if(Toggle.On__c)
                {
                    for(Trigger_Toggle__c tt:  TriggerTogglesRecordTypeWise.get('TogglesWithRecordTypes'))
                    {
                        if(tt.Code_Reference__c == CodeReference && !tt.On__c)
                        {
                            list<string> CodeReferenceWiseCases = CasesToRecordName.get(CodeReference);
                            
                            for(string RecordTypeName: RecordTypeToCases.keySet())
                            {                                
                                if(CodeReferenceWiseCases == null)
                                {
                                    CodeReferenceWiseCases = new list<string>();
                                    
                                    if(RecordTypeName != tt.RecordType_Name__c)
                                    { 
                                        list<string> RecordTypesAndCases = RecordTypeToCases.get(RecordTypeName);
                                        if(RecordTypesAndCases != null && !RecordTypesAndCases.isEmpty())
                                        {
                                            for(string c:RecordTypesAndCases){
                                                CodeReferenceWiseCases.add(c);
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    if(RecordTypeName != tt.RecordType_Name__c)
                                    { 
                                        list<string> RecordTypesAndCases = RecordTypeToCases.get(RecordTypeName);
                                        if(RecordTypesAndCases != null && !RecordTypesAndCases.isEmpty())
                                        {
                                            for(string c:RecordTypesAndCases){
                                                CodeReferenceWiseCases.add(c);
                                            } 
                                        }
                                    } 
                                }                                                       
                            }                            
                            CasesToRecordName.put(CodeReference, CodeReferenceWiseCases); 
                        }
                    }
                }
                
                if(!Toggle.On__c)
                {
                    for(Trigger_Toggle__c tt:  TriggerTogglesRecordTypeWise.get('TogglesWithRecordTypes'))
                    {
                        if(tt.Code_Reference__c == CodeReference && tt.On__c)
                        {
                            list<string> CodeReferenceWiseCases = CasesToRecordName.get(CodeReference);
                            
                            for(string RecordTypeName: RecordTypeToCases.keySet())
                            {                        
                                if(CodeReferenceWiseCases == null)
                                {
                                    CodeReferenceWiseCases = new list<string>();
                                    
                                    if(RecordTypeName == tt.RecordType_Name__c)
                                    { 
                                        list<string> RecordTypesAndCases = RecordTypeToCases.get(RecordTypeName);
                                        if(RecordTypesAndCases != null && !RecordTypesAndCases.isEmpty())
                                        {
                                            for(string c:RecordTypesAndCases){
                                                CodeReferenceWiseCases.add(c);
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    if(RecordTypeName == tt.RecordType_Name__c)
                                    { 
                                        list<string> RecordTypesAndCases = RecordTypeToCases.get(RecordTypeName);
                                        if(RecordTypesAndCases != null && !RecordTypesAndCases.isEmpty())
                                        {
                                            for(string c:RecordTypesAndCases){
                                                CodeReferenceWiseCases.add(c);
                                            }
                                        }
                                    } 
                                }                      
                            }                            
                             
                            CasesToRecordName.put(CodeReference, CodeReferenceWiseCases);
                        }
                    }                     
                }
            }
        }        
        system.debug(CasesToRecordName);
        return CasesToRecordName;
    }*/
    

}