<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>DS_LSR_InstallerName</fullName>
        <field>Installer_Name__c</field>
        <formula>CreatedBy.FirstName &amp;&quot; &quot;&amp; CreatedBy.LastName</formula>
        <name>DS_LSR_InstallerName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>DS_LSR_UPD_InstallerName</fullName>
        <actions>
            <name>DS_LSR_InstallerName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Installer Name to creator of the record</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
