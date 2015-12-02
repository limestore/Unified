<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LMA_RFP_Email_To_AMA_Region_Alias</fullName>
        <description>LMA RFP Email To AMA Region Alias</description>
        <protected>false</protected>
        <recipients>
            <field>LMA_AMA_Region_Alias_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>LMA_Regional_Director_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/LMA_RFP_Submission_Response</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assign_CB_LMA_RFP_Queue_as_Owner</fullName>
        <description>Assign CB LMA RFP Queue</description>
        <field>OwnerId</field>
        <lookupValue>LMA_Inquiry_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign CB LMA RFP Queue as Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_IO_Attached_Date_Time</fullName>
        <field>I_O_Attached_Date_Time__c</field>
        <name>Clear IO Attached Date Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Proforma_Attached_Date_Time</fullName>
        <field>Proforma_Attached_Date_Time__c</field>
        <name>Clear Proforma Attached Date Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_IO_Attached_DateTime</fullName>
        <field>I_O_Attached_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update IO Attached DateTime</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_IO_Proforma_DateTime</fullName>
        <field>Proforma_Attached_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update IO Proforma DateTime</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_LMA_AMA_Region_Alias_Email</fullName>
        <field>LMA_AMA_Region_Alias_Email__c</field>
        <formula>LMA__r.AMA_Regional_Alias__c</formula>
        <name>Update LMA AMA Region Alias Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_LMA_Regional_Director_Alias_EMail</fullName>
        <field>LMA_Regional_Director_Email__c</field>
        <formula>LMA__r.LMA_Regional_Director1__r.Email</formula>
        <name>Update LMA Regional Director Alias EMail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CB LMA RFP Clear IO Attached Date Time</fullName>
        <actions>
            <name>Clear_IO_Attached_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( I_O_Attached__c = False, NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB LMA RFP Clear Proforma Attached Date Time</fullName>
        <actions>
            <name>Clear_Proforma_Attached_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( Proforma_Attached__c = FALSE, NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB LMA RFP Update Fields Email Alert</fullName>
        <actions>
            <name>LMA_RFP_Email_To_AMA_Region_Alias</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Assign_CB_LMA_RFP_Queue_as_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_LMA_AMA_Region_Alias_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_LMA_Regional_Director_Alias_EMail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>CB LMA RFP Update Fields Email Alert</description>
        <formula>AND( Status__c = &quot;Created&quot;, NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB LMA RFP Update IO Attached DateTime</fullName>
        <actions>
            <name>Update_IO_Attached_DateTime</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( I_O_Attached__c = True, NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB LMA RFP Update Proforma Attached DateTime</fullName>
        <actions>
            <name>Update_IO_Proforma_DateTime</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( Proforma_Attached__c = True, NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
