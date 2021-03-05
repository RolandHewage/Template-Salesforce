import ballerina/log;
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
    remote function onEvent(json lead) {
        io:StringReader sr = new (lead.toJsonString());
        json|error leadInfo = sr.readJson();
        if(leadInfo is json) {   
            json|error eventType = leadInfo.event.'type;        
            if(eventType is json) {
                if(TYPE_CREATED.equalsIgnoreCaseAscii(eventType.toString())) {
                    json|error leadId = leadInfo.sobject.Id;
                    if(leadId is json) {
                        json|error leadObject = leadInfo.sobject;
                        if(leadObject is json) {
                            sendMessageForNewLead(leadObject);
                        } else {
                            log:printError(leadObject.message());
                        }
                    } else {
                        log:printError(leadId.message());
                    }
                }
            } else {
                log:printError(eventType.message());
            }
        } else {
            log:printError(leadInfo.message());
        }
    }
}

function sendMessageForNewLead(json lead) {
    string message = "New Salesforce lead created successfully! \n";
    map<json> leadMap = <map<json>> lead;
    foreach var [key, value] in leadMap.entries() {
        if(value != ()) {
            message = message + key + " : " + value.toString() + "\n";
        }
    }

    var result = twilioClient->sendSms(from_mobile, to_mobile, message);
    if (result is twilio:SmsResponse) {
        log:print("SMS sent successfully for the new Salesforce lead created" + "\nSMS_SID: " + result.sid.toString() + 
            "\nSMS Body: \n" + result.body.toString());
    } else {
        log:printError(result.message());
    }
}
