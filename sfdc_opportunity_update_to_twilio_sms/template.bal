// import ballerina/log;
import ballerina/io;
import ballerinax/sfdc;
import ballerinax/twilio;

// Twilio configuration parameters
configurable twilio:TwilioConfiguration & readonly twilioConfig = ?;
configurable string & readonly from_mobile = ?;
configurable string & readonly to_mobile = ?;

// Initialize the Twilio Client
twilio:Client twilioClient = new (twilioConfig);

// Salesforce configuration parameters
configurable sfdc:ListenerConfiguration & readonly listenerConfig = ?;
configurable string & readonly sf_push_topic = ?;

// Initialize the Salesforce Listener
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
