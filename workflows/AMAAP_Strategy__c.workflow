<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CB_DA_EML_A2_Strategy_Detail_Created</fullName>
        <description>CB DA EML A2 Strategy Detail Created</description>
        <protected>false</protected>
        <recipients>
            <field>LMA_Analyst_2_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Service_Templates/Alert_to_A2_AMA_Account_Plan_Strategy_Detail_Created</template>
    </alerts>
    <fieldUpdates>
        <fullName>CB_Svc_UPD_LMA_Analyst_2_Email</fullName>
        <description>Update the LMA Analyst 2 email from the AMA Account Plan</description>
        <field>LMA_Analyst_2_Email__c</field>
        <formula>Account_Plan__r.LMA_Analyst2_Email__c</formula>
        <name>CB Svc UPD LMA Analyst 2 Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CB DA EML A2 Strategy Detail Created</fullName>
        <actions>
            <name>CB_DA_EML_A2_Strategy_Detail_Created</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CB_Svc_UPD_LMA_Analyst_2_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the AMA Account Plan AMAAP Strategy Detail is created Email the Analyst 2</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
