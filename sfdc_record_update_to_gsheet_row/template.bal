import ballerina/log;
import ballerina/io;
import ballerinax/sfdc;
import ballerinax/googleapis_sheets as sheets;

// Google sheet configuration parameters
configurable string sheets_refreshToken = ?;
configurable string sheets_clientId = ?;
configurable string sheets_clientSecret = ?;
configurable string sheets_spreadsheet_id = ?;
configurable string sheets_worksheet_name = ?;

sheets:SpreadsheetConfiguration spreadsheetConfig = {
    oauthClientConfig: {
        clientId: sheets_clientId,
        clientSecret: sheets_clientSecret,
        refreshUrl: sheets:REFRESH_URL,
        refreshToken: sheets_refreshToken
    }
};

// Initialize the Spreadsheet Client
sheets:Client spreadsheetClient = checkpanic new (spreadsheetConfig);

// Salesforce configuration parameters
configurable string sf_username = ?;
configurable string sf_password = ?;
configurable string sf_push_topic = ?;

sfdc:ListenerConfiguration listenerConfig = {
    username: sf_username,
    password: sf_password
};

// Initialize the Salesforce listener
listener sfdc:Listener sfdcEventListener = new (listenerConfig);

@sfdc:ServiceConfig {
    topic: TOPIC_PREFIX + sf_push_topic
}
service on sfdcEventListener {
    remote function onEvent(json sObject) {
        io:StringReader sr = new (sObject.toJsonString());
        json|error sObjectInfo = sr.readJson();
        if (sObjectInfo is json) {   
            json|error eventType = sObjectInfo.event.'type;        
            if (eventType is json) {
                if (TYPE_UPDATED.equalsIgnoreCaseAscii(eventType.toString())) {
                    json|error sObjectId = sObjectInfo.sobject.Id;
                    if (sObjectId is json) {
                        json|error sObjectObject = sObjectInfo.sobject;
                        if (sObjectObject is json) {
                            checkpanic updateSheetWithUpdatedRecord(sObjectObject);
                        } else {
                            log:printError(sObjectObject.message());
                        }
                    } else {
                        log:printError(sObjectId.message());
                    }
                }
            } else {
                log:printError(eventType.message());
            }
        } else {
            log:printError(sObjectInfo.message());
        }
    }
}


function updateSheetWithUpdatedRecord(json sObject) returns @tainted error? {
    (string)[] headerValues = [];
    (int|string|float)[] values = [];

    string[] columnNames = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", 
        "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
    string updatedRecordId = "";
    string updatedColumn = "";
    int updatedRow = 0;
    int columnCounter = 0;
    int rowCounter = 1;


    map<json> sObjectMap = <map<json>>sObject;
    foreach var [key, value] in sObjectMap.entries() {
        headerValues.push(key.toString());
        values.push(value.toString());
        if (key.toString() == SOBJECT_ID) {
            updatedRecordId = value.toString();
            updatedColumn = columnNames[columnCounter];
        }
        columnCounter = columnCounter + 1;
    }
    
    var headers = spreadsheetClient->getRow(sheets_spreadsheet_id, sheets_worksheet_name, 1);
    if(headers == []){
        _ = check spreadsheetClient->appendRowToSheet(sheets_spreadsheet_id, sheets_worksheet_name, headerValues);
    }

    var updatedColumnValues = spreadsheetClient->getColumn(sheets_spreadsheet_id, sheets_worksheet_name, updatedColumn);
    if (updatedColumnValues is (int|string|float)[]) {
        foreach var item in updatedColumnValues {
            if (item == updatedRecordId) {
                updatedRow = rowCounter;
            }
            rowCounter = rowCounter + 1;
        }
    } else {
        return error(updatedColumnValues.message());
    }

    _ = check spreadsheetClient->createOrUpdateRow(sheets_spreadsheet_id, sheets_worksheet_name, updatedRow, values);

    log:print("Updated Record ID : " + updatedRecordId);
    log:print("Updated Headers : " + headerValues.toString());
    log:print("Updated Values : " + values.toString());
}
