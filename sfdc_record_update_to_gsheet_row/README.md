# Update a row in Google sheets when a record is updated in Salesforce

## Intergration use case
At the execution of this template, each time a record is updated in salesforce, Google Sheets Spreadsheet row will be updated containing all the defined fields of particular SObject. 

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
* Google Cloud Platform Account
* Ballerina connectors for Salesforce and Google Sheets which will be automatically downloaded when building the application for the first time


## Configuration
### Setup Salesforce configurations
* Create a Salesforce account and create a connected app by visiting [Salesforce](https://www.salesforce.com). 
* Salesforce username, password will be needed for initializing the listener. 
* Once you obtained all configurations, Replace "" in the `Conf.toml` file with your data.

### Create Push Topic in Salesforce developer console

The Salesforce trigger requires topics to be created for each event. We need to configure topic to listen on record creation of particular SObject. 

1. From the Salesforce UI, select developer console. Go to debug > Open Execute Anonymous Window. 
2. Following apex code is an example for creating a pushtopic to trigger record update of `Lead` SObject. You can change the `pushTopic.Name` to match with the SObject you wish to get triggered  and `pushTopic.Query` by adding the fields you want to receive when the event triggered. 
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
3. Once the creation is done, specify the topic name in your `Config.toml` file as `sf_push_topic`.

### Setup Google sheets configurations
Create a Google account and create a connected app by visiting [Google cloud platform APIs and Services](https://console.cloud.google.com/apis/dashboard). 

1. Click Library from the left side menu.
2. In the search bar enter Google Sheets.
3. Then select Google Sheets API and click Enable button.
4. Complete OAuth Consent Screen setup.
5. Click Credential tab from left side bar. In the displaying window click Create Credentials button
Select OAuth client Id.
6. Fill the required field. Add https://developers.google.com/oauthplayground to the Redirect URI field.
7. Get clientId and secret. Put it on the config(Config.toml) file.
8. Visit https://developers.google.com/oauthplayground/ 
    Go to settings (Top right corner) -> Tick 'Use your own OAuth credentials' and insert Oauth ClientId and secret.Click close.
9. Then,Complete Step1 (Select and Authotrize API's)
10. Make sure you select https://www.googleapis.com/auth/drive & https://www.googleapis.com/auth/spreadsheets Oauth scopes.
11. Click Authorize API's and You will be in Step 2.
12. Exchange Auth code for tokens.
13. Copy Access token and Refresh token. Put it on the config(Config.toml) file.

## Configuring the integration template

1. Create new spreadsheet.
2. Rename the sheet if you want.
3. Get the ID of the spreadsheet.  
Spreadsheet ID in the URL "https://docs.google.com/spreadsheets/d/" + `<spreadsheetId>` + "/edit#gid=" + `<worksheetId>` 
5. Get the sheet name
6. Once you obtained all configurations, Create `Config.toml` in root directory.
7. Replace "" in the `Config.toml` file with your data.

### Config.toml 

#### ballerinax/sfdc related configurations 

sf_username = ""   
sf_password = ""  
sf_push_topic = ""  


#### ballerinax/googleapis_sheet related configurations  

sheets_refreshToken = ""  
sheets_clientId = ""  
sheets_clientSecret = ""  
sheets_refreshurl = ""  
sheets_id = ""  
sheets_name = ""  

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


