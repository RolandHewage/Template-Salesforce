# Template: Salesforce record update to Google sheet row

When a record is updated in Salesforce, update a row in Google sheets.

It is tiresome to continuously go through Google Sheets and Salesforce to update them with data from your updated records. Automating this process would save the effort and time of Salesforce admins. We use spreadsheets to append new Salesforce records and track them easily to share across multiple stackholders. But manually updating the relevant row in a spreadsheet with the updated Salesforce record information is an annoying task. 

This template can be used to update the relevant row in a specific Google Sheet with all the defined fields of a particular SObject, when a record is updated in Salesforce.

## Use this template to
- Update a row in Google Sheet with the updated information, when a record is updated in Salesforce.

## What you need
- A Salesforce Account
- A Google Cloud Platform Account

## How to set up
- Import the template.
- Allow access to the Salesforce account.
- Select a push topic.
- Allow access to the Google account.
- Select spreadsheet.
- Select worksheet.
- Set up the template. 

# Developer Guide
<p align="center">
<img src="./docs/images/template_flow.png?raw=true" alt="Salesforce-GSheet Integration template overview"/>
</p>

## Supported versions

<table>
  <tr>
   <td>Ballerina Language Version
   </td>
   <td>Swan Lake Alpha2
   </td>
  </tr>
  <tr>
   <td>Java Development Kit (JDK) 
   </td>
   <td>11
   </td>
  </tr>
  <tr>
   <td>Salesforce API 
   </td>
   <td>v48.0
   </td>
  </tr>
  <tr>
   <td>Google Sheets API Version
   </td>
   <td>V4
   </td>
  </tr>
</table>


## Pre-requisites
* Download and install [Ballerina](https://ballerinalang.org/downloads/).
* Salesforce account
* Google Cloud Platform Account
* Ballerina connectors for Salesforce and Google Sheets which will be automatically downloaded when building the application for the first time


## Account Configuration
### Configuration steps for Salesforce account
1. Create a Salesforce account and create a connected app by visiting [Salesforce](https://www.salesforce.com). 
2. Salesforce username, password will be needed for initializing the listener. 
3. Once you obtained all configurations, Replace "" in the `Conf.toml` file with your data.

4. Create Push Topic in Salesforce developer console

    The Salesforce trigger requires topics to be created for each event. We need to configure topic to listen on record creation of particular SObject. 

    * From the Salesforce UI, select developer console. Go to debug > Open Execute Anonymous Window. 
    * Following apex code is an example for creating a pushtopic to trigger record update of `Lead` SObject. You can change the `pushTopic.Name` to match with the SObject you wish to get triggered  and `pushTopic.Query` by adding the fields you want to receive when the event triggered. 
    It is mandatory to specify the "Id" field.
      ```apex
      PushTopic pushTopic = new PushTopic();
      pushTopic.Name = 'LeadUpdate';
      pushTopic.Query = 'SELECT Id, FirstName , LastName, Company, Phone, Email, Industry, LeadSource from Lead';
      pushTopic.ApiVersion = 48.0;
      pushTopic.NotifyForOperationCreate = true;
      pushTopic.NotifyForFields = 'Referenced';
      insert pushTopic;
      ```
    * Once the creation is done, specify the topic name in your `Config.toml` file as `sf_push_topic`.

### Configuration steps for Google sheets account

1. Create a Google account and create a connected app by visiting [Google cloud platform APIs and Services](https://console.cloud.google.com/apis/dashboard). 
2. Click Library from the left side menu.
3. In the search bar enter Google Sheets.
4. Then select Google Sheets API and click Enable button.
5. Complete OAuth Consent Screen setup.
6. Click Credential tab from left side bar. In the displaying window click Create Credentials button
Select OAuth client Id.
7. Fill the required field. Add https://developers.google.com/oauthplayground to the Redirect URI field.
8. Get clientId and secret. Put it on the config(Config.toml) file.
9. Visit https://developers.google.com/oauthplayground/ 
    Go to settings (Top right corner) -> Tick 'Use your own OAuth credentials' and insert Oauth ClientId and secret.Click close.
10. Then,Complete Step1 (Select and Authotrize API's)
11. Make sure you select https://www.googleapis.com/auth/drive & https://www.googleapis.com/auth/spreadsheets Oauth scopes.
12. Click Authorize API's and You will be in Step 2.
13. Exchange Auth code for tokens.
14. Copy Access token and Refresh token. Put it on the config(Config.toml) file.

## Template Configuration

1. Create new spreadsheet.
2. Rename the sheet if you want.
3. Get the ID of the spreadsheet.  
Spreadsheet ID in the URL "https://docs.google.com/spreadsheets/d/" + `<spreadsheetId>` + "/edit#gid=" + `<worksheetId>` 
5. Get the worksheet name
6. Once you obtained all configurations, Create `Config.toml` in root directory.
7. Replace "" in the `Config.toml` file with your data.

### Config.toml 

```
[<ORG_NAME>.sfdc_record_update_to_gsheet_row]
sf_username = "<SALESFORCE_USERNAME>"  
sf_password = "<SALESFORCE_PASSWORD>"  
sf_push_topic = "<SALESFORCE_PUSH_TOPIC>" 
sheets_spreadsheet_id = "<SPREADSHEET_ID>"
sheets_worksheet_name = "<WORKSHEET_NAME>"
sheets_refresh_token = "<REFRESH_TOKEN>"
sheets_client_id = "<CLIENT_ID>"
sheets_client_secret = "<CLIENT_SECRET>"
``` 

## Running the template

1. First you need to build the integration template and create the executable binary. Run the following command from the root directory of the integration template. 
`$ bal build`. 

2. Then you can run the integration binary with the following command. 
`$ bal run /target/bin/sfdc_record_update_to_gsheet_row.jar`. 

    Successful listener startup will print following in the console.
    ```
    >>>>
    [2021-03-08 18:21:37.847] Success:[/meta/handshake]
    {ext={replay=true, payload.format=true}, minimumVersion=1.0, clientId=5un14t4h1t7hpz9yijwy1s5mijhw, supportedConnectionTypes=[Ljava.lang.Object;@3b8746fc, channel=/meta/handshake, id=1, version=1.0, successful=true}
    <<<<
    >>>>
    [2021-03-08 18:21:38.017] Success:[/meta/connect]
    {clientId=5un14t4h1t7hpz9yijwy1s5mijhw, advice={reconnect=retry, interval=0, timeout=110000}, channel=/meta/connect, id=2, successful=true}
    <<<<
    >>>>
    ```

3. Now you can add update records in Salesforce account and observe that integration template runtime has received the event notification for the new record update.

4. You can check the Google Sheet to verify that the relevant record is updated in the specified sheet. 
