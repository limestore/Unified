global with sharing class CB_USCanadaMileStonesTimeTriggerUpdate implements Support.MilestoneTriggerTimeCalculator
{
    
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneId) 
    {
        Case currentCase = new Case();
        
        if(caseId != null)
        {
            currentCase = [
                SELECT Id, Priority, EntitlementId, SlaStartDate 
                FROM Case 
                WHERE Id=:caseId
                Limit 1
            ];
        }
        
        MilestoneType mt = new MilestoneType();
        
        if(milestoneId != null)
        {
            mt = [
                SELECT Name 
                FROM MilestoneType 
                WHERE Id=:milestoneId
                limit 1
            ];
        }
        
        Entitlement ent = new Entitlement();
        
        if(currentCase != null && currentCase.EntitlementId != null)
        {
            ent = [
                Select Id, BusinessHoursId 
                from Entitlement 
                where Id = :currentCase.EntitlementId
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
        
        DateTime startDate = DateTime.newInstance(00, 00, 00);
               
        if(currentCase != null && currentCase.SlaStartDate != null && testhHours != null && testhHours.TimeZoneSidKey != null)
        { 
            startDate = DateTime.valueOf((currentCase.SlaStartDate.format('yyyy-MM-dd HH:mm:ss', testhHours.TimeZoneSidKey)));
        }
        
        Integer removeSeconds = 0;
        
        if(startDate != null)
        {
            removeSeconds = startDate.second();
        }
        
        startDate = startDate.addSeconds(-removeSeconds);
        
		string startDay = startDate.format('EEEE');
        
        system.debug('----MilestoneType---'+mt);
        system.debug('----CaseMilestone---'+ent);
        
        integer multiplier = 0;
        
        if(mt != null && mt.Name != null)
        {
            multiplier = integer.valueOf(mt.Name.split(' ')[0]);
        }
        
        Time StartDateTime = Time.newInstance(00, 00, 00, 00);
        Time EndDateTime = Time.newInstance(00, 00, 00, 00);
        
        if(testhHours != null)
        {
            StartDateTime = (Time)testhHours.get(startDay + 'StartTime');
            EndDateTime = (Time)testhHours.get(startDay + 'EndTime');
        }
        
        integer minutes = 0;
        
        if (currentCase.Priority != null && currentCase.Priority.equals('Same Day'))
        {
              if (mt.Name != null && mt.Name.equals('0 Same Day')) 
              {
                  if(startDay.equals('Saturday') || startDay.equals('Sunday'))
                  {
                      minutes = 780;
                  }
                  else
                  {
                     minutes = calcSameBDayDiff(startDate, EndDateTime, StartDateTime);
                  }
              }
              else 
              { 
                  minutes = 0;
              }
        }
        else if(multiplier != null && multiplier >= 1 )
        {
            minutes = multiplier * 780;
        }
        else 
        {
            minutes = 0;
        }
        
        if(testhHours != null && currentCase != null && minutes != null)
        {
            setTheTargetDateTimeOnCase(testhHours, currentCase, minutes);
        }
        return minutes; 
    }
   
    global static TimeWrap calcBusinessTimeDiff(Datetime startDate, Time businessEndTime, Time businessStartTime)
    {
        Date tempdate = null;
        
        if(startDate != null)
        {
            tempdate = startDate.date(); 
        }
        
        DateTime businessEndDateTime = null;
        
        if(tempdate != null)
        {
            businessEndDateTime = DateTime.newInstance(tempdate.year(), tempdate.month(), tempdate.day());
        }
        
        if(businessEndTime != null)
        {
            businessEndDateTime = businessEndDateTime.addHours(
                businessEndTime.hour()).addMinutes(businessEndTime.minute()).addSeconds(businessEndTime.second());
        }
        
        DateTime businessStartDateTime = null;
        
        if(tempdate != null)
        {
            businessStartDateTime = DateTime.newInstance(tempdate.year(), tempdate.month(), tempdate.day());
        }
        
        if(businessStartTime != null)
        {
            businessStartDateTime = businessStartDateTime.addHours(
                businessStartTime.hour()).addMinutes(businessStartTime.minute()).addSeconds(businessStartTime.second());
        }
        
        TimeWrap tw = new TimeWrap();
        
        if(businessStartDateTime != null && startDate != null && 
           businessStartDateTime.getTime() >= startDate.getTime())
        {
            tw.timeDiff = businessStartDateTime.getTime() - startDate.getTime();
            tw.diffType = 'Early';
        }
        else if(businessStartDateTime != null && startDate != null && 
                businessEndDateTime.getTime() > startDate.getTime() && 
                businessStartDateTime.getTime() < startDate.getTime())
        {
            tw.timeDiff = businessEndDateTime.getTime() - startDate.getTime();
            tw.diffType = 'In Time';
        }
        else
        {
            if(businessEndDateTime != null && startDate != null)
            {
                tw.timeDiff = businessEndDateTime.getTime() - startDate.getTime();
            }
            
            tw.diffType = 'Late';
        }
        
        system.debug('***tw***'+tw);
        
        return tw;
    }
    
    global static Integer calcSameBDayDiff(Datetime startDate, Time businessEndTime, Time businessStartTime)
    {
        TimeWrap tw = calcBusinessTimeDiff(startDate, businessEndTime, businessStartTime);
        Long timeDiff = null;
        
        if(tw != null)
        {
           timeDiff = tw.timeDiff;
        }
        
        if(tw != null && tw.diffType == 'Early')
        {
            return 780; 
        }
        else if(tw != null && timeDiff != null && tw.diffType == 'In Time')
        {
            integer diff = Math.abs(Integer.valueOf(timeDiff/(1000*60)));
            return diff; //remaining time from business hours...
        }
        else
        {
            return 780;
        }        
    }
    global class TimeWrap
    {
        Long timeDiff;
        string diffType;        
    }
    public static void setTheTargetDateTimeOnCase(BusinessHours bh, Case currentCase, Integer totalMinutes)
    {
        if(bh != null && currentCase != null && totalMinutes != null)
        {
            dateTime startDate = currentCase.SlaStartDate;
            long convertedToMilliSeconds = (totalMinutes * 60 * 1000);            
            dateTime calculatedTargetDateTime = BusinessHours.add(bh.ID, startDate, convertedToMilliSeconds);            
            currentCase.Target_Date_Time__c = calculatedTargetDateTime;
            
            Database.Update(currentCase, false);
        } 
    }
}