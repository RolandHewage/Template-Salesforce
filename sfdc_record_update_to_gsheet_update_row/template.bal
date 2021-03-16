import ballerina/log;
import ballerina/io;
import ballerina/http;
import ballerinax/sfdc;
import ballerinax/googleapis_sheets as sheets;

// google sheet configuration parameters
configurable http:OAuth2DirectTokenConfig & readonly directTokenConfig = ?;
configurable string & readonly sheets_spreadsheet_id = ?;
configurable string & readonly sheets_worksheet_name = ?;

sheets:SpreadsheetConfiguration spreadsheetConfig = {
    oauthClientConfig: directTokenConfig
};

// Initialize the Spreadsheet Client
sheets:Client spreadsheetClient = check new (spreadsheetConfig);

// Salesforce configuration parameters
configurable sfdc:ListenerConfiguration & readonly listenerConfig = ?;
configurable string & readonly sf_push_topic = ?;

// Initialize the Salesforce Listener
listener sfdc:Listener sfdcEventListener = new (listenerConfig);

@sfdc:ServiceConfig {
    topic: TOPIC_PREFIX + sf_push_topic
}
service on sfdcEventListener {
    remote function onEvent(json sObject) returns error? {
        io:StringReader sr = new (sObject.toJsonString());
        json sObjectInfo = check sr.readJson();         
        json eventType = check sObjectInfo.event.'type;               
        if (TYPE_UPDATED.equalsIgnoreCaseAscii(eventType.toString())) {
            json sObjectId = check sObjectInfo.sobject.Id;            
            json sObjectObject = check sObjectInfo.sobject;
            check updateSheetWithUpdatedRecord(sObjectObject);            
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
