global with sharing class CB_GMTechMileStonesTimeTriggerUpdate implements Support.MilestoneTriggerTimeCalculator
{
    
    global Integer calculateMilestoneTriggerTime(string caseId, string milestoneId) 
    {
        Case currentCase = new Case();
        
        if(caseId != null)
        {
            currentCase = [
                SELECT Id, Priority, EntitlementId, SlaStartDate, Product_Category__c,Problem_Code__c 
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
        
        Entitlement ent = new Entitlement();
        
        if(currentCase != null && currentCase.EntitlementId != null)
        {
            ent = [
                Select Id, BusinessHoursId 
                from Entitlement 
                where Id = :currentCase.EntitlementId
                limit 1
            ];
        }
        
        system.debug('----BusinessHoursId----'+ent.BusinessHoursId);
        
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
        
        system.debug('-----EProcess Started Time--------'+currentCase.SlaStartDate);
        
        Datetime startDate = DateTime.newInstance(00, 00, 00);
        
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
        system.debug('-----StartDay---------'+startDay);
        
        integer multiplier = 0;
        Time StartDateTime = Time.newInstance(00, 00, 00, 00);
        Time EndDateTime = Time.newInstance(00, 00, 00, 00);
        
        if(testhHours != null)
        {
            StartDateTime = (Time)testhHours.get(startDay + 'StartTime');
            EndDateTime = (Time)testhHours.get(startDay + 'EndTime');
        }
        
        if(mt != null && mt.Name != null)
        {
            multiplier = integer.valueOf(mt.Name.split(' ')[0]);
        }
        
        integer minutes = 0;
        
        if (currentCase != null && currentCase.Priority != null && currentCase.Priority.equals('Same Day'))
        {
              if (mt.Name != null && mt.Name.equals('0 Same Day')) 
              { 
                  if(startDay.equals('Saturday'))
                  {
                      minutes = calcSameBDayDiffSaturday(startDate, EndDateTime, StartDateTime);
                  }
                  else if(startDay.equals('Friday'))
                  {
                      minutes = calcSameBDayDiffFriday(startDate, EndDateTime, StartDateTime, true );
                  }
                  else if(startDay.equals('Sunday'))
                  {
                      minutes = 720;
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
        else if(multiplier != null && multiplier >= 1)
        { 
            if(startDay.equals('Saturday'))
            {
                minutes = 720 * (multiplier - 1) + calcSameBDayDiffSaturday(startDate, EndDateTime, StartDateTime);
            }
            else if(startDay.equals('Friday'))
            {
                minutes = 720 * (multiplier - 1) + calcSameBDayDiffFriday(startDate, EndDateTime, StartDateTime, false );
            }
            else
            {
                minutes = multiplier * 720;
            }
        }         
        else 
        {
            minutes = 20;
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
        else if(businessEndDateTime != null && startDate != null && 
                businessEndDateTime.getTime() > startDate.getTime() && 
                businessStartDateTime.getTime() < startDate.getTime())
        {
            tw.timeDiff = businessEndDateTime.getTime() - startDate.getTime();
            tw.diffType = 'InTime';
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
        
        if(tw != null && tw.diffType != null && 
           timeDiff != null && tw.diffType.equals('InTime'))
        {
            integer diff = Math.abs((Integer.valueOf(timeDiff/(1000*60))));
            system.debug('The difference returned is----'+diff);
            return diff; //remaining time from business hours...
        }
        else
        {
            return 720;
        }        
    }
    global static Integer calcSameBDayDiffSaturday(Datetime startDate, Time businessEndTime, Time businessStartTime)
    {
        TimeWrap tw = calcBusinessTimeDiff(startDate, businessEndTime, businessStartTime);
        
        Long timeDiff = null ;
        
        if(tw != null)
        {
            timeDiff = tw.timeDiff;
        }
        
        system.debug('---tw-Sat-'+tw);
        
        if(tw != null && tw.diffType != null && tw.diffType.equals('Early'))
        {
            return 1440; 
        }
        else if(tw != null && tw.diffType != null && 
                timeDiff != null && tw.diffType.equals('InTime'))
        {
            integer diff = Math.abs((Integer.valueOf(timeDiff/(1000*60)))); 
            
            system.debug('---diff-Sat-'+diff);
            
            return diff+720; //remaining time from business hours...
         } 
        else
        {
          return 720;
        }       
    }
    global static Integer calcSameBDayDiffFriday(Datetime startDate, Time businessEndTime, Time businessStartTime, Boolean isSameDay)
    {
        TimeWrap tw = calcBusinessTimeDiff(startDate, businessEndTime, businessStartTime);
        
        Long timeDiff = null;
        
        if(tw != null)
        {
            timeDiff = tw.timeDiff;
        }
        
        system.debug('---tw-Fri-'+tw);
        
        if(tw != null && tw.diffType != null && tw.diffType.equals('Early'))
        {
            return 720; 
        }
        else if(tw != null && tw.diffType != null && tw.diffType.equals('InTime'))
        { 
            if(isSameDay && timeDiff != null)
            {
                integer diff = Math.abs((Integer.valueOf(timeDiff/(1000*60))));
                
                system.debug('---diff-Fri-'+diff);
                
                return diff;
            }
            else
            {
                return 720;
            }                 
        }
        else
        {
            return 1440;
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