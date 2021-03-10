// import ballerina/log;
import ballerina/io;
import ballerinax/sfdc;
import ballerinax/twilio;

// Twilio configuration parameters
configurable string account_sid = ?;
configurable string auth_token = ?;
configurable string from_mobile = ?;
configurable string to_mobile = ?;

twilio:TwilioConfiguration twilioConfig = {
    accountSId: account_sid,
    authToken: auth_token
};

twilio:Client twilioClient = new(twilioConfig);

// Salesforce configuration parameters
configurable string sf_username = ?;
configurable string sf_password = ?;
configurable string sf_push_topic = ?;

sfdc:ListenerConfiguration listenerConfig = {
    username: sf_username,
    password: sf_password
};

listener sfdc:Listener sfdcEventListener = new (listenerConfig);

@sfdc:ServiceConfig {
    topic: TOPIC_PREFIX + sf_push_topic
}
service on sfdcEventListener {
    remote function onEvent(json opportunity) returns error? {
        io:StringReader sr = new (opportunity.toJsonString());
        json opportunityInfo = check sr.readJson();        
        json eventType = check opportunityInfo.event.'type;                
        if (TYPE_UPDATED.equalsIgnoreCaseAscii(eventType.toString())) {
            json opportunityId = check opportunityInfo.sobject.Id;            
            json opportunityObject = check opportunityInfo.sobject;            
            check sendMessageWithOpportunityUpdate(opportunityObject);            
        }        
    }
}

function sendMessageWithOpportunityUpdate(json opportunity) returns error? {
    string message = "Salesforce opportunity updated successfully! \n";
    map<json> opportunityMap = <map<json>> opportunity;
    foreach var [key, value] in opportunityMap.entries() {
        if(value != ()) {
            message = message + key + " : " + value.toString() + "\n";
        }
    }
    twilio:SmsResponse result = check twilioClient->sendSms(from_mobile, to_mobile, message);
}
