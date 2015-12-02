<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CB_Update_AAManagerEmail</fullName>
        <field>Advocate_Manager_Email__c</field>
        <formula>Advocate__r.Manager.Email</formula>
        <name>CB_Update_AAManagerEmail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Update_StatusRole_NewHire</fullName>
        <description>Update the Status/Role field to New Hire.</description>
        <field>Status_Role__c</field>
        <literalValue>New Hire</literalValue>
        <name>CB_Update_StatusRole_NewHire</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CB_UpdateAAManagerEmail</fullName>
        <actions>
            <name>CB_Update_AAManagerEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Any time the record is edited and the AA Manager formula field has changed, update the record with the new manager email.</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)), NOT(BEGINS($User.Username,&quot;integration_user@cdk.com&quot;)),  ISCHANGED( Advocate_Manager__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_Update_Status_to_NewHire</fullName>
        <actions>
            <name>CB_Update_StatusRole_NewHire</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Requisition Status is &quot;Cleared&quot;, the Status/Role field should update to &quot;New Hire.&quot;</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  NOT(BEGINS($User.Username,&quot;integration_user@cdk.com&quot;)),  ISPICKVAL( Requisition_Status__c , &quot;Cleared&quot;),  NOT(ISPICKVAL(PRIORVALUE(Requisition_Status__c),&quot;Cleared&quot;)),  NOT(ISPICKVAL( Status_Role__c ,&quot;New Hire&quot;))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
