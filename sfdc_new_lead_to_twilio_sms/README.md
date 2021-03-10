# Template: Salesforece new lead to Twilio SMS

When a new lead is created in Salesforce, send Twilio sms to a specific number.

A customer can use Twilio to send internal notifications to a specific person of interest, based on the new lead information in Salesforce. 
It is important to follow up with leads as soon as they are added in Salesforce. There maybe a specific person who wanted to be on 
alert of new Salesforce leads. Any time you create a new lead in Salesforce, a SMS message will automatically send to 
the specific person via Twilio.

This template can be used to send a Twilio SMS message containing all 
the defined fields in lead SObject to a given mobile number when a new lead is created in Salesforce.

## Use this template to
- Send a Twilio SMS message to a specific number when a new lead is created in Salesforce.

## What you need
- A Twilio Account
- A Salesforce Account

## How to set up
- Import the template.
- Allow access to Salesforce account.
- Provide the Salesforce push topic.
- Allow access to the Twilio account.
- Provide the Twilio Account SID and Auth Token.
- Provide the number we want to send the SMS from.
- Provide the number we want to send the SMS to.
- Set up the template. 

# Developer Guide

<p align="center">
<img src="./docs/images/template_flow.png?raw=true" alt="Github-Slack Integration template overview"/>
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
   <td>Twilio Basic API
   </td>
   <td>2010-04-01
   </td>
  </tr>
</table>


## Pre-requisites
* Download and install [Ballerina](https://ballerinalang.org/downloads/).
* A Salesforce account with a push topic created
* Twilio account with sms capable phone number
* Ballerina connectors for Salesforce and Twilio which will be automatically downloaded when building the application for the first time


## Account Configuration

### Configuration steps for Salesforce account
1. Create a Salesforce account and create a connected app by visiting [Salesforce](https://www.salesforce.com). 
2. Salesforce username, password will be needed for initializing the listener. 
3. Once you obtained all configurations, Replace "" in the `Conf.toml` file with your data.
4.  Create push topic in Salesforce developer console

    The Salesforce trigger requires topics to be created for each event. We need to configure topic to listen on Custom Object entity.

    * From the Salesforce UI, select developer console. Go to debug > Open Execute Anonymous Window. 
    * Paste following apex code to create topic with <NewLead> and execute. You can change the `pushTopic.Query` adding the fields you want to receive when the event triggered.
    ```apex
    PushTopic pushTopic = new PushTopic();
    pushTopic.Name = 'NewLead';
    pushTopic.Query = 'SELECT Id, FirstName, LastName, Company, Phone, Email, Industry, LeadSource from Lead';
    pushTopic.ApiVersion = 48.0;
    pushTopic.NotifyForOperationCreate = true;
    pushTopic.NotifyForFields = 'Referenced';
    insert pushTopic;
    ```
    * Once the creation is done, specify the topic name in your `Config.toml` file as `sf_push_topic`.

### Configuration steps for Twilio account

1. Create a [Twilio developer account](https://www.twilio.com/). 
2. Create a Twilio project with SMS capabilities.
3. Obtain the Account Sid and Auth Token from the project dashboard.
4. Obtain the phone number from the project dashboard and set as the value of the `from_mobile` variable in the `Config.toml`.
5. Give a mobile number where the SMS should be send as the value of the `to_mobile` variable in the `Config.toml`.
6. Once you obtained all configurations, Replace "" in the `Config.toml` file with your data.

## Template Configuration

1. Create a push topic in salesforce developer console.
2. Create a Twilio account with sms capabilities.
3. Obtain all the above necessary configurations.
4. Once you obtained all configurations, Create `Config.toml` in root directory.
5. Replace the necessary fields in the `Config.toml` file with your data.

### Config.toml 

```
[<ORG_NAME>.sfdc_new_lead_to_twilio_sms]
sf_username = "<SALESFORCE_USERNAME>"  
sf_password = "<SALESFORCE_PASSWORD>"  
sf_push_topic = "<SALESFORCE_PUSH_TOPIC>"  
tw_account_sid = "<TWILIO_ACCOUNT_SID>"  
tw_auth_token = "<TWILIO_AUTH_TOKEN>"  
tw_from_mobile = "<TWILIO_FROM_MOBILE>"  
tw_to_mobile = "<TWILIO_TO_MOBILE>"    
```

## Running the template

1. First you need to build the integration template and create the executable binary. Run the following command from the root directory of the integration template. 
`$ bal build`. 

2. Then you can run the integration binary with the following command. 
`$ bal run /target/bin/sfdc_new_lead_to_twilio_sms-0.1.0.jar`. 

    Successful listener startup will print following in the console.
```
>>>>
[2021-03-04 20:03:06.590] Success:[/meta/handshake]
{ext={replay=true, payload.format=true}, minimumVersion=1.0, clientId=5ztfj0t4ktnvq9o190gi3iin4un, supportedConnectionTypes=[Ljava.lang.Object;@16a62b0b, channel=/meta/handshake, id=1, version=1.0, successful=true}
<<<<
>>>>
[2021-03-04 20:03:06.880] Success:[/meta/connect]
{clientId=5ztfj0t4ktnvq9o190gi3iin4un, advice={reconnect=retry, interval=0, timeout=110000}, channel=/meta/connect, id=2, successful=true}
<<<<
```

3. Now you can create a new lead in Salesforce Account and observe that integration template runtime has received the event notification for the new lead created.

4. You can check the SMS received to verify that information about the new lead created is received. 
