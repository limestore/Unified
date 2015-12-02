<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Check_Business_Unit_Changed_for_SProject</fullName>
        <field>Business_Unit_Changed__c</field>
        <literalValue>1</literalValue>
        <name>Check Business Unit Changed for SProject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unchk_Business_Unit_Changed_for_SProject</fullName>
        <field>Business_Unit_Changed__c</field>
        <literalValue>0</literalValue>
        <name>Unchk Business Unit Changed for SProject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>IMP_Business_Unit_Changed_SubProject</fullName>
        <actions>
            <name>Check_Business_Unit_Changed_for_SProject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Business_Unit_Changed__c to true if the Business Unit field changes</description>
        <formula>!ISNULL(TEXT( SubProject_Region__c )) &amp;&amp; !ISBLANK(TEXT(SubProject_Region__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IMP_No_Business_Unit_SubProject</fullName>
        <actions>
            <name>Unchk_Business_Unit_Changed_for_SProject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Business_Unit_Changed__c to false if the Business Unit field changes</description>
        <formula>ISCHANGED( SubProject_Region__c ) &amp;&amp; ISPICKVAL( SubProject_Region__c , &apos;&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
