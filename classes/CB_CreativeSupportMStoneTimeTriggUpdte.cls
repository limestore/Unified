//2015-09-17 - Venkata Shrivol      - Refactored code
//2015-09-25 - Siva.Pragada@cdk.com - logic fix  
//2015-09-28 - Siva.Pragada@cdk.com - logic fix to compare if the time is before given time e.g: 10:30 am
//2015-10-13 - Siva.Pragada@cdk.com - added check for if the time falls within business hours and also to see if the status value is not fix

global with sharing class CB_CreativeSupportMStoneTimeTriggUpdte implements Support.MilestoneTriggerTimeCalculator
{ 
    static final integer PACIFIC_HOURS = 10;
    static final integer PACIFIC_MINUTES = 30;
    static final integer PACIFIC_SECONDS = 0;
    static datetime businessStartDateTime = null;
    static dateTime businessEndDateTime = null;
    static boolean isWithInBusinessHours = false;
    
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneId) 
    {
        Case currentCase = new Case();
        
        if(caseId != null)
        {       
            currentCase = [
                SELECT Id, Priority, Status, EntitlementId, SlaStartDate,X911_Escalation__c, DA_Echelon_Level__c 
                FROM Case 
                WHERE Id=:caseId 
                LIMIT 1
            ];
        }
            
        MilestoneType mt = new MilestoneType();
        
        if(milestoneId != null)
        {
            mt = [
                SELECT Name 
                FROM MilestoneType 
                WHERE Id=:milestoneId 
                LIMIT 1
            ];
        }
        
        Integer multiplier=0;
        
       
        if(mt!=null && mt.Name!=null)            
        { 
            multiplier = Integer.valueOf(mt.Name.subString(0,1));
        }
        
        system.debug('-------Multiplier--------'+multiplier);
        
        Entitlement ent = new Entitlement();
        
        if(currentCase != null && currentCase.EntitlementId != null)
        {
            ent = [
                SELECT Id, BusinessHoursId 
                FROM Entitlement 
                WHERE Id = :currentCase.EntitlementId 
                LIMIT 1
            ];
        }
        
        BusinessHours testhHours = new BusinessHours();
        
        if(ent != null && ent.BusinessHoursId != null)
        {
            
            testhHours = [
                SELECT Id, TimeZoneSidKey,MondayStartTime, MondayEndTime,TuesdayStartTime, TuesdayEndTime,
                       WednesdayStartTime, WednesdayEndTime,ThursdayStartTime, ThursdayEndTime,FridayStartTime, 
                       FridayEndTime,SaturdayStartTime,SaturdayEndTime, SundayStartTime, SundayEndTime  
                FROM BusinessHours 
                WHERE id = :ent.BusinessHoursId 
                LIMIT 1
            ];
        }
        
        DateTime startDate = null;
        
        if(currentCase != null && currentCase.SlaStartDate != null && testhHours != null && testhHours.TimeZoneSidKey != null)
        {
            startDate = DateTime.valueOf((currentCase.SlaStartDate.format('yyyy-MM-dd HH:mm:ss', testhHours.TimeZoneSidKey)));
        }
        
        
        string startDay = null;
        
        if(startDate != null)
        {
            Integer removeSeconds = startDate.second();
            startDate = startDate.addSeconds(-removeSeconds);
            startDay = startDate.format('EEEE');
        }
        
        Time BusinessStartTime = null;
        Time BusinessEndTime = null;        
        
        if(testhHours != null)
        {
            BusinessEndTime = (Time)testhHours.get(startDay+'EndTime');
            BusinessStartTime = (Time)testhHours.get(startDay+'StartTime');
        }
                
        if(startDate != null && BusinessEndTime != null && BusinessStartTime != null)
        {
             businessStartDateTime = DateTime.newInstance(
                startDate.date().year(), startDate.date().month(), startDate.date().day(), 
                 BusinessStartTime.hour(), BusinessStartTime.minute(), BusinessStartTime.second());
            
            businessEndDateTime = DateTime.newInstance(
                startDate.date().year(), startDate.date().month(), startDate.date().day(), 
                BusinessEndTime.hour(), BusinessEndTime.minute(), BusinessEndTime.second());
        }
        
        if(businessStartDateTime != null && businessEndDateTime != null)
        {
            if(StartDate >= businessStartDateTime && StartDate <= businessEndDateTime)
            {
                isWithInBusinessHours = true;
            }
        }
        
        system.debug('----MilestoneType---'+mt);
        system.debug('----CaseMilestone---'+ent);
        system.debug('-----Case-----------'+currentCase);
        system.debug('-----startDay-----------'+startDay);
        
        TimeWrapper resultClass = new TimeWrapper();
        
        if(startDay.equals('Saturday') || startDay.equals('Sunday') )
        {
            if(multiplier>1)
            {
                Integer minutes = (multiplier)*540;
                
                setTheTargetDateTimeOnCase(testhHours, currentCase, minutes);
                
                return minutes;     
            }
            else
            {
                Integer minutes = 540;
                
                setTheTargetDateTimeOnCase(testhHours, currentCase, minutes);
                
                return minutes;
            }
        }
        else
        {
            resultClass = calcSameBDayDiff(
                startDate, 
                (Time)testhHours.get(startDay+'EndTime'), //testHours(MondayTime)
                (Time)testhHours.get(startDay+'StartTime'), 
                testhHours.TimeZoneSidKey
            );
            
            system.debug('----TimeWrapper----'+resultClass);
            
            boolean statusIsFixEditOrChanges = (
                currentCase != null && currentCase.Status != null &&                                             
                (currentCase.Status.equalsIgnoreCase('Fix') || 
                 currentCase.Status.equalsIgnoreCase('Minor Edit') || 
                 currentCase.Status.equalsIgnoreCase('Changes'))
            );
            
            if(resultClass.before1030PacificTime && !statusIsFixEditOrChanges && isWithInBusinessHours) //before 10:30 am
            {
                if(Multiplier <= 1)
                {
                    long diff =businessEndDateTime.getTime() - startDate.getTime();
                    integer minutes = Math.abs(Integer.valueOf(diff/(60 * 1000)));
                    currentCase.Target_Date_Time__c =  businessEndDateTime; update currentCase;
                    
                    return Minutes;
                }
                else
                {
                    Integer minutes = (multiplier * 540) - resultClass.timeDifference;
                    
                    setTheTargetDateTimeOnCase(testhHours, currentCase, minutes);
                    
                	return minutes; 
                }
            }
            else // after 10:30 am
            {
                if(Multiplier == 0)
                {
                    long diff = businessEndDateTime.getTime() - StartDate.getTime();
                    Integer Minutes = Math.abs(Integer.valueOf(diff/(60 * 1000)));
                    currentCase.Target_Date_Time__c = businessEndDateTime; update currentCase;
                    
                    return Minutes;                    
                }
                
                Integer Minutes = Multiplier * 540;
                
                setTheTargetDateTimeOnCase(testhHours, currentCase, minutes);
                
                return Minutes;                
            }
        }
    }
   
    global static TimeWrapper calcSameBDayDiff(Datetime startDate, Time businessEndTime,Time businessStartTime,string TimeZoneKey)
    {
        system.debug('startDateInPST***'+startDate);
        
        Date tempdate = startDate.date(); 
        
        //construct 10:30 AM of PDT
        Timezone tz = Timezone.getTimeZone('America/Los_Angeles');
        integer offSetTimeFromGMT = tz.getOffset(dateTime.now());
        offSetTimeFromGMT = Math.abs(offSetTimeFromGMT);
        
        DateTime currentConvertedDateTimeInGMT = 
            dateTime.newInstanceGmt(startDate.yearGMT(), startDate.monthGmt(), startDate.dayGmt(), startDate.hourGmt(), startDate.minuteGmt(), startDate.secondGmt());
        
        DateTime tenThirtyPSTInGMT = 
            dateTime.newInstanceGmt(
                startDate.yearGMT(), startDate.monthGmt(), startDate.dayGmt(), 10 + offSetTimeFromGMT, 30, 0);
                
        
        DateTime tempGmtOfPST = DateTime.newInstanceGMT(tempdate.year(), tempdate.month(),tempdate.day(),0,0,0);
        
        system.debug('tempDate1---JustStartDATEwith000timevalues'+tempGmtOfPST);
        
        //in otherwords this is equivalent to 10:30 AM pst
        tempGmtOfPST = tempGmtOfPST.addHours(16).addminutes(30).addSeconds(0);
        
        system.debug('tempDatefinal*****'+tempGmtOfPST);
        
        system.debug('-startDate-'+startDate);
        system.debug('-businessEndDateTime-'+businessEndDateTime);
        system.debug('-businessEndDateTime-'+businessStartDateTime);
        
        system.debug(startDate.getTime() < tempGmtOfPST.getTime() && startDate.getTime()>=businessStartDateTime.getTime());
        system.debug(startDate.getTime() < tempGmtOfPST.getTime());
        system.debug(startDate.getTime()>=businessStartDateTime.getTime());
        
        dateTime tenThirtyEqvalntOfGMTPst = CB_CreativeSupportMStoneTimeTriggUpdte.getThreshHoldDateTime(startDate, PACIFIC_HOURS, PACIFIC_MINUTES, PACIFIC_SECONDS);
        
        system.debug(tenThirtyEqvalntOfGMTPst);
        
        boolean lessThanGivenTime = startDate.getTime() < tenThirtyEqvalntOfGMTPst.getTime();
        
        system.debug(lessThanGivenTime);
        
        TimeWrapper tw = new TimeWrapper();
        if(lessThanGivenTime && startDate.getTime()>=businessStartDateTime.getTime())
        {
            long timeDiff = (businessEndDateTime.getTime()  - startDate.getTime());
            integer diff = Math.abs(Integer.valueOf(timeDiff/(1000*60)));
            system.debug('-diff-'+diff);
            tw.timeDifference = diff;                    
            tw.before1030PacificTime = true;
        }
        else
        {
            tw.timeDifference = 540;
            tw.before1030PacificTime = false;
        }
        return tw;
    }
    global class TimeWrapper {
        integer timeDifference;
        boolean before1030PacificTime;
    }
    
    public static void setTheTargetDateTimeOnCase(BusinessHours bh, Case currentCase, Integer totalMinutes)
    {
        if(bh != null && currentCase != null && totalMinutes != null)
        {
            dateTime startDate = currentCase.SlaStartDate;
            long convertedToMilliSeconds = (totalMinutes * 60 * 1000);
            system.debug('-----startDate--------'+startDate);
            dateTime calculatedTargetDateTime = BusinessHours.add(bh.ID, startDate, convertedToMilliSeconds);
            system.debug('-------calculatedTargetDateTime-----'+calculatedTargetDateTime);
            currentCase.Target_Date_Time__c = calculatedTargetDateTime;
            
            Database.Update(currentCase, false);
        } 
    }
    
    public static dateTime getThreshHoldDateTime(dateTime caseStartDateTime, integer hours, integer minutes, integer seconds)
    {
        Timezone tz = Timezone.getTimeZone('America/Los_Angeles');
        integer offSetTimeFromGMT = tz.getOffset(dateTime.now());
        offSetTimeFromGMT = Math.abs(offSetTimeFromGMT/(60* 60 * 1000));
        
        DateTime tenThirtyPSTInGMT = 
            dateTime.newInstanceGmt(
                caseStartDateTime.yearGMT(), caseStartDateTime.monthGmt(), caseStartDateTime.dayGmt(), hours + offSetTimeFromGMT, minutes, seconds);
        
        return tenThirtyPSTInGMT;
    }    
}