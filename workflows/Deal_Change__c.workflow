<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DS_BDC_DealChangeClosed</fullName>
        <description>DS_BDC_DealChangeClosed</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>On_Behalf_Of__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BDC_Docs/BDC_Close_Deal_Change</template>
    </alerts>
    <alerts>
        <fullName>DS_BDC_NetworkNeeded_DC</fullName>
        <ccEmails>DS_PSEMail@cdk.com</ccEmails>
        <description>DS_BDC_NetworkNeeded_DC</description>
        <protected>false</protected>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BDC_Docs/BDC_Network_Needed_DC</template>
    </alerts>
    <fieldUpdates>
        <fullName>DS_BDC_CompletedDate</fullName>
        <field>Completed_Date__c</field>
        <formula>Now()</formula>
        <name>DS_BDC_CompletedDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_BDC_CompletedDate_Null</fullName>
        <field>Completed_Date__c</field>
        <name>DS_BDC_CompletedDate_Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_BDC_PSEQuoteReceivedDate</fullName>
        <field>PSE_Quote_s_Received_Date__c</field>
        <formula>Now()</formula>
        <name>DS_BDC_PSEQuoteReceivedDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Deal_State__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_BDC_Rush_DC</fullName>
        <field>Rush__c</field>
        <literalValue>1</literalValue>
        <name>DS_BDC_Rush_DC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_BDC_UPD_RushReason_DC</fullName>
        <field>Rush_Reasons__c</field>
        <literalValue>Client Needs ASAP</literalValue>
        <name>DS_BDC_UPD_RushReason_DC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>DS_BDC_EML_DealChangeClosed</fullName>
        <actions>
            <name>DS_BDC_DealChangeClosed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 and 4</booleanFilter>
        <criteriaItems>
            <field>Deal_Change__c.Change_Completed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deal_Change__c.Type_of_Change__c</field>
            <operation>notEqual</operation>
            <value>SOW</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deal_Change__c.Type_of_Change__c</field>
            <operation>notEqual</operation>
            <value>Network Quote Uploaded</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deal_Change__c.CreatedById</field>
            <operation>notEqual</operation>
            <value>Admin</value>
        </criteriaItems>
        <description>Sends email notification to user who created the deal change record when deal change is completed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_BDC_EML_NetworkNeeded_DC</fullName>
        <actions>
            <name>DS_BDC_NetworkNeeded_DC</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Deal_Change__c.Network_Needed__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <description>Sends a email notification to PSE whenever Network Needed is required for a Deal Change</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_BDC_UPD_CompletedDate</fullName>
        <actions>
            <name>DS_BDC_CompletedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deal_Change__c.Change_Completed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates Completed Date to current date/time when Change Completed is checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_BDC_UPD_CompletedDate_Null</fullName>
        <actions>
            <name>DS_BDC_CompletedDate_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deal_Change__c.Change_Completed__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Updates Completed Date to null when Change Completed is un checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_BDC_UPD_PSEQuoteReceivedDate</fullName>
        <actions>
            <name>DS_BDC_PSEQuoteReceivedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deal_Change__c.Type_of_Change__c</field>
            <operation>equals</operation>
            <value>Network Quote Uploaded</value>
        </criteriaItems>
        <description>Updates PSE Quote Received Date on deal state with current date/time for Deal Change Type of Network Quote Uploaded</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_BDC_UPD_RushReason_DC</fullName>
        <actions>
            <name>DS_BDC_Rush_DC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>DS_BDC_UPD_RushReason_DC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deal_Change__c.Contract_Needed_By_Date__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>Updates Rush to Check and Rush Reason to Client Needs it ASAP when contract needed by date is current date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>