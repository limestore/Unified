function CreateEnvelopeAndRedirect(
    OpportunityId, 
    Recipient1Email, Recipient1FirstName, Recipient1LastName, 
    Recipient2Email, Recipient2LastName, 
    Recipient3Email, Recipient3FirstName, Recipient3LastName,
    ManagerEmail, ManagerFirstName, ManagerLastName) 
{
    // * Option Declarations *************************
    var RC = ''; var RSL=''; var RSRO=''; var RROS=''; 
    var CCRM=''; var CCTM=''; var CCNM=''; 
    var CRCL=''; var CRL=''; var OCO=''; var DST=''; 
    var LA=''; var CEM=''; var CES=''; var STB=''; 
    var SSB=''; var SES=''; var SEM=''; var SRS=''; 
    var SCS =''; var RES=''; var CCRM=''; 
    // ***********************************************
    
    //OCO = 'Send'; 
    LA = '0'; 
    RES = '1,2,3,1,30,3'; 
    CES = 'Please Review and Sign CDK Global Agreement and Order Form';  
    CEM = 'Attached please find the agreements for the CDK Digital Marketing Solutions we discussed. '
        + 'Simply open the document(s) and follow the prompts to electronically review and sign the agreement(s). '
        + 'If you have any questions, please feel free to contact me directly. '
        + 'Thank you for your business and I am looking forward to work with you '
        + 'and your team as we execute on your complete digital marketing strategy.';

    CRL = 'Email~'+Recipient1Email+';Role~Signer1;FirstName~'+Recipient1FirstName+';LastName~'+Recipient1LastName+';RoutingOrder~1,'
    	+ 'Email~'+Recipient2Email+';Role~Signer2;LastName~'+Recipient2LastName+';RoutingOrder~2,'
    	+ 'Email~'+Recipient1Email+';Role~CC1;FirstName~'+Recipient1FirstName+';LastName~'+Recipient1LastName+';RoutingOrder~3,'
    	+ 'Email~'+ManagerEmail+';Role~CC2;FirstName~'+ManagerFirstName+';LastName~'+ManagerLastName+';RoutingOrder~4,'    	
    	+ 'Email~'+Recipient3Email+';Role~Signer3;FirstName~'+Recipient3FirstName+';LastName~'+Recipient3LastName+';RoutingOrder~5;';
        
    
    CCRM='Signer1~DSM;Signer2~Customer;CC1~DSMCC;CC2~DOS;Signer3~Contract Admin;'; 
    CCTM= 'CC1~Carbon Copy;CC2~Carbon Copy;'; 
    
    var redirect = "/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0"
        +"&SourceID="+OpportunityId
        +"&CRL="+CRL
        +"&OCO="+OCO
        +"&LA="+LA
        +"&CEM="+CEM
        +"&CES="+CES
        +"&STB="+STB
        +"&RES="+RES
        +"&CCTM="+CCTM
        +"&CCRM="+CCRM; 
    
    //if(console) { console.log(redirect); }
    
    //window.setTimeout(function(){
        
        // * Page Callout ********************************
        window.location.href = redirect;
        // ***********************************************
        
    //},3000);
}