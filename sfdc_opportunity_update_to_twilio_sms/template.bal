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
    remote function onEvent(json opportunity) {
        io:StringReader sr = new (opportunity.toJsonString());
        json|error opportunityInfo = sr.readJson();
        if(opportunityInfo is json) {   
            json|error eventType = opportunityInfo.event.'type;        
            if(eventType is json) {
                if(TYPE_UPDATED.equalsIgnoreCaseAscii(eventType.toString())) {
                    json|error opportunityId = opportunityInfo.sobject.Id;
                    if(opportunityId is json) {
                        json|error opportunityObject = opportunityInfo.sobject;
                        if(opportunityObject is json) {
                            sendMessageWithOpportunityUpdate(opportunityObject);
                        } else {
                            log:printError(opportunityObject.message());
                        }
                    } else {
                        log:printError(opportunityId.message());
                    }
                }
            } else {
                log:printError(eventType.message());
            }
        } else {
            log:printError(opportunityInfo.message());
        }
    }
}

function sendMessageWithOpportunityUpdate(json opportunity) {
    string message = "Salesforce opportunity updated successfully! \n";
    map<json> opportunityMap = <map<json>> opportunity;
    foreach var [key, value] in opportunityMap.entries() {
        if(value != ()) {
            message = message + key + " : " + value.toString() + "\n";
        }
    }

    var result = twilioClient->sendSms(from_mobile, to_mobile, message);
    if (result is twilio:SmsResponse) {
        log:print("SMS sent successfully for the Salesforce opportunity update" + "\nSMS_SID: " + result.sid.toString() + 
            "\nSMS Body: \n" + result.body.toString());
    } else {
        log:printError(result.message());
    }
}
