<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>IMP_Stamp_Record_Type_in_Lookup_Search</fullName>
        <description>When a new SubProject External Reference record is created, stamp the record type value into the text &apos;Type&apos; field to enable lookup dialog searches for the record type value.</description>
        <field>Type__c</field>
        <formula>RecordType.Name</formula>
        <name>IMP Stamp Record Type in (Lookup) Search</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>IMP Stamp Record Type in %28Lookup%29 Searchable Type Field</fullName>
        <actions>
            <name>IMP_Stamp_Record_Type_in_Lookup_Search</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SubProject_External_Reference__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>When a new SubProject External Reference record is created, stamp the record type value into the text &apos;Type&apos; field to enable lookup dialog searches for the record type value.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
