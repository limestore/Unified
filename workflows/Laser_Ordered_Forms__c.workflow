<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>DS_LSR_ConditionalA_RStatement</fullName>
        <field>Conditional_A_R_Statement__c</field>
        <formula>1</formula>
        <name>DS_LSR_ConditionalA/RStatement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_LSR_ePaymentsClient</fullName>
        <field>Laser_Ordered_Forms__c</field>
        <formula>1</formula>
        <name>DS_LSR_ePaymentsClient</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_LSR_eSignatureClient</fullName>
        <field>eSignature__c</field>
        <formula>1</formula>
        <name>DS_LSR_eSignatureClient</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_Lsr_Tablet_Forms</fullName>
        <field>Service_Edge_Client__c</field>
        <formula>1</formula>
        <name>DS_Lsr_Tablet_Forms</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LaserOrderedForms_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>LaserOrderedForms_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>DS_LSR_UPD_ConditionalA%2FRStatement</fullName>
        <actions>
            <name>DS_LSR_ConditionalA_RStatement</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Laser_Ordered_Forms__c.Update_Conditional_A_R_Statement__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Created to update Conditional A/R Statement field under LOF object to call as Roll up under LAO object per RQ-03560</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_LSR_UPD_ePaymentsClient</fullName>
        <actions>
            <name>DS_LSR_ePaymentsClient</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Laser_Ordered_Forms__c.Update_ePayments__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Created to update ePayments field under LOF object to call as Roll up under LAO object per RQ-04868</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_LSR_UPD_eSignatureClient</fullName>
        <actions>
            <name>DS_LSR_eSignatureClient</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Laser_Ordered_Forms__c.Update_eSignature__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Created to update eSignature field under LOF object to call as Roll up under LAO object per RQ-03344</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_Lsr_UPD_Tablet_Forms</fullName>
        <actions>
            <name>DS_Lsr_Tablet_Forms</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Laser_Ordered_Forms__c.Update_Service_Edge__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Created to update service edge field under LOF object to call as Roll up under LAO object for Laser Tablet Forms</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LaserOrderedForms_Set_Migration_ID</fullName>
        <actions>
            <name>LaserOrderedForms_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
