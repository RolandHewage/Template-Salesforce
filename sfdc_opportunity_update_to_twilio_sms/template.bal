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
                            log:print(opportunityObject.toString());
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
    var result = twilioClient->sendSms(from_mobile, to_mobile, opportunity.toString());
    if (result is error) {
        log:printError(result.message());
    } else {
        log:print("SMS sent successfully for the opportunity update");
    }
}

// function createSheetWithNewLead(json lead) returns @tainted error? {
//     (int|string|float)[] values = [];
//     (string)[] headerValues = [];
//     map<json> leadMap = <map<json>>lead;
//     foreach var [key, value] in leadMap.entries() {
//         headerValues.push(key.toString());
//         values.push(value.toString());
//     }
//     // var headers = gSheetClient->getRow(sheets_id, sheets_name, 1);
//     // if(headers == []){
//     //     _ = check gSheetClient->appendRowToSheet(sheets_id, sheets_name, headerValues);
//     // }
//     // _ = check gSheetClient->appendRowToSheet(sheets_id, sheets_name, values);
//     var result = twilioClient->sendSms(from_mobile, to_mobile, messageContent);
//     if (result is error) {
//         log:printError("Error Occured : ", err = result);
//     } else {
//         log:print("Message sent successfully");
//     }
// }
