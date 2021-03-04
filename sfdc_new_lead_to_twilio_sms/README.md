# Send Twilio SMS when a new lead is created in Salesforce

## Intergration use case
At the execution of this template, each time a new lead is created in salesforce, Twilio SMS containing all 
the defined fields in opportunity SObject will be sent. 

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
* Twilio account with sms capable phone number
* Ballerina connectors for Salesforce and Twilio which will be automatically downloaded when building the application for the first time


## Configuration

### Setup Salesforce configurations
* Create a Salesforce account and create a connected app by visiting [Salesforce](https://www.salesforce.com). 
* Salesforce username, password will be needed for initializing the listener. 
* Once you obtained all configurations, Replace "" in the `Conf.toml` file with your data.

### Create push topic in Salesforce developer console

The Salesforce trigger requires topics to be created for each event. We need to configure topic to listen on Custom Object entity.

1. From the Salesforce UI, select developer console. Go to debug > Open Execute Anonymous Window. 
2. Paste following apex code to create topic with <NewLead> and execute. You can change the `pushTopic.Query` adding the fields you want to receive when the event triggered.
```apex
PushTopic pushTopic = new PushTopic();
pushTopic.Name = 'OpportunityUpdate';
pushTopic.Query = 'select Id, FirstName , LastName, Company, Phone, Email, Industry, LeadSource  from Lead';
pushTopic.ApiVersion = 48.0;
pushTopic.NotifyForOperationCreate = true;
pushTopic.NotifyForFields = 'Referenced';
insert pushTopic;
```
3. Once the creation is done, specify the topic name in your `Config.toml` file as `sf_push_topic`.

### Setup Twilio configurations
Create a [Twilio developer account](https://www.twilio.com/). 

1. Create a Twilio project with SMS capabilities.
2. Obtain the Account Sid and Auth Token from the project dashboard.
3. Obtain the phone number from the project dashboard and set as the value of the `from_mobile` variable in the `Config.toml`.
4. Give a mobile number where the SMS should be send as the value of the `to_mobile` variable in the `Config.toml`.
5. Once you obtained all configurations, Replace "" in the `Config.toml` file with your data.

### Config.toml 

#### ballerinax/sfdc related configurations 

sf_username = ""  
sf_password = ""  
sf_push_topic = ""  


#### ballerinax/twilio related configurations  

account_sid = ""  
auth_token = ""  
from_mobile = ""  
to_mobile = ""    

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


