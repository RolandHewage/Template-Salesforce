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
    remote function onEvent(json lead) returns error? {
        io:StringReader sr = new (lead.toJsonString());
        json leadInfo = check sr.readJson();         
        json eventType = check leadInfo.event.'type;               
        if (TYPE_CREATED.equalsIgnoreCaseAscii(eventType.toString())) {
            json leadId = check leadInfo.sobject.Id;
            json leadObject = check leadInfo.sobject;
            check sendMessageForNewLead(leadObject);
        }     
    }
}

function sendMessageForNewLead(json lead) returns error? {
    string message = "New Salesforce lead created successfully! \n";
    map<json> leadMap = <map<json>> lead;
    foreach var [key, value] in leadMap.entries() {
        if (value != ()) {
            message = message + key + " : " + value.toString() + "\n";
        }
    }

    twilio:SmsResponse result = check twilioClient->sendSms(from_mobile, to_mobile, message);
}
