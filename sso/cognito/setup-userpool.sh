#!/bin/bash
MANTISSA=$(date +"%Y%m%d%H%M")
echo "Create User Pool and Connect to Azure AD (Entra ID)"

TMP_DIR=$(mktemp -d)
echo Creating a temporary directory at $TMP_DIR
pushd $TMP_DIR

echo "Please enter the profile that will be used to set up in AWS:"
read AWS_PROFILE
echo

echo "Please enter the AWS region that will be used. e.g. us-east-1"
read AWS_REGION_DEFAULT
echo

echo "Please enter a name for the Fully Specified Application User Pool e.g. {app-name}-{env}-{optional-miscellaneous}"
echo e.g. "demo-sso-dev-attempt-$MANTISSA"
read APP_NAME
echo

POOL_NAME=$APP_NAME-UserPool
echo Creating User Pool with Pool Name: $POOL_NAME
aws cognito-idp create-user-pool --pool-name $POOL_NAME > create-user-pool.json
POOL_ID=$(cat create-user-pool.json | jq -r .UserPool.Id)
echo Created User Pool, $POOL_NAME, with POOL_ID: $POOL_ID
echo

echo "Please enter a globally unique domain prefix e.g. {reverse-domain}-{app-name}-{env}-{optional-miscellaneous}"
echo e.g. "bm-cactus-demo-sso-dev-attempt-$MANTISSA"
read DOMAIN_PREFIX
echo

echo Creating User Pool Domain for pool with id $POOL_ID with Domain Prefix: $DOMAIN_PREFIX
aws cognito-idp create-user-pool-domain --domain $DOMAIN_PREFIX --user-pool-id $POOL_ID
echo Created User Pool Domain
echo

echo Assigning variables for future use:
ENTITY_ID=urn:amazon:cognito:sp:$POOL_ID
REPLY_URL=https://$DOMAIN_PREFIX.auth.$AWS_REGION_DEFAULT.amazoncognito.com/saml2/idpresponse
echo ENTITY_ID: $ENTITY_ID
echo REPLY_URL: $REPLY_URL
echo

echo The following steps must be completed in Azure, who knows if this part is scriptable because, Microsoft, after each instruction press return to get the next instruction.
echo

echo Log in to the Azure Portal at https://portal.azure.com
read

echo Go to Microsoft Entra ID by entering \"Microsoft Entra ID\" in the search bar at the top of the page.
read

echo In the left side bar click \"Enterprise Applications\"
read

echo Click \"New Application\"
read

echo Click \"Create your own application.\"
read

echo Enter the name of the app: $APP_NAME
echo $APP_NAME | pbcopy 
echo $APP_NAME will be in your clipboard if using a mac.
read

echo Choose "\"Integrate any other application you don't find in the gallery (Non-gallery)\""
read

echo Click Create
read

echo Wait for the overview screen to load this may take several seconds. Press enter when it has completed.
read

echo Click "Get Started" in the "Set up single sign on card."
read

echo Click SAML
read

echo Click the edit button in the basic SAML configuration section.
read 

echo "Click \"Add identifier\" in the Identifier (Entity Id) section."
read

echo Enter $ENTITY_ID into the text field, the value will be in your clipboard if using a mac.
echo $ENTITY_ID | pbcopy
read

echo "Click Add reply URL under Reply URL (Assertion Customer Service URL)."
read

echo Enter the value $REPLY_URL into the box, the value will be in your clipboard if using a mac.
echo $REPLY_URL | pbcopy
read

echo Press the save button
read

echo Close the Bascic SAML configuration section.
read

echo "Click edit in the Attributes & Claims section."
read

echo Click Add a group claim.
read

echo Click Groups assigned to the application option in the popup.
read

echo Leave source attribute as Group ID and press save.
read

echo Copy the value from the newly created Group claims and paste below
read GROUP_CLAIM_NAME
echo

echo Copy the value from the email claim and paste below
read MAIL_CLAIM_NAME
echo

echo Copy the value from the given name claim and paste below.
read GIVENNAME_CLAIM_NAME
echo

echo Copy the value from the principal name claim and paste below.
read PRINCIPALNAME_CLAIM_NAME
echo

echo Copy the value from the surname claim and paste below.
read SURNAME_CLAIM_NAME
echo

echo "Close the Attributes & Claims window."
read

echo Scroll down to the SAML certificates section.
read

echo Copy the App Federation Metadata Url and paste below.
read APP_FEDERATION_METADATA_URL
echo

echo Set yourself up as a user of this application.
echo Click Users and groups in the left hand side bar.
read

echo Click Add user/group
read

echo "Click None Selected (as this is a new application there should be no users but once users are added it will instead say n users selected)." 
read

echo Click the check boxes next to any users or groups you would like to add to the application.
read

echo "Click Select (the pop-up will close)"
read

echo Click Assign
read

echo Enter a name for the groups attribute in cognito which will store the azure groups e.g. azure_groups
read GROUPS_ATTRIBUTE

echo Enter a name for the id provider with a maximum of 32 chars e.g. azure-{app-name}-{env}-{optional-miscellaneous}, e.g. azure-demo-sso-dev-$MANTISSA.
read ID_PROVIDER_NAME

echo Adding groups attribute $GROUPS_ATTRIBUTE to pool: $POOL_ID
aws cognito-idp add-custom-attributes --user-pool-id $POOL_ID --custom-attributes Name=$GROUPS_ATTRIBUTE,AttributeDataType="String"
echo Added groups attribute $GROUPS_ATTRIBUTE to pool: $POOL_ID

echo Creating identity provider $ID_PROVIDER_NAME.
aws cognito-idp create-identity-provider \
    --user-pool-id $POOL_ID \
    --provider-name=$ID_PROVIDER_NAME \
    --provider-type SAML \
    --provider-details MetadataURL=$APP_FEDERATION_METADATA_URL \
    --attribute-mapping email=$MAIL_CLAIM_NAME,custom:$GROUPS_ATTRIBUTE=$GROUP_CLAIM_NAME > create-identity-provider.json
echo Created identity provider $ID_PROVIDER_NAME
echo

echo Enter a name for the client application and assign e.g. {app-name}-{env}-{optional-miscellaneous}-client e.g. demo-sso-dev-client-$MANTISSA
read CLIENT_NAME
echo

echo Enter the callback url, if working in dev this will want to be something like 
echo 
echo https://localhost:3000 
echo
echo you may want to use a different port so that you can have different applications on different ports.
echo 
echo This will have to be https in production.
read CALLBACK_URL
echo

echo When using react locally https with a self signed certificate can be used with the following command: 
echo
echo HTTPS=true npm start
echo 
echo However, chrome will reject self-signed certificates. 
echo You can enable self-signed certificates on localhost by going to 
echo 
echo chrome://flags/#allow-insecure-localhost 
echo 
echo and enabling the option.
read

echo "If working in dev enter the port number below (if not press return):"
read PORT
echo

echo Creating user pool client.
aws cognito-idp create-user-pool-client \
    --user-pool-id $POOL_ID \
    --client-name $CLIENT_NAME \
    --no-generate-secret \
    --callback-urls $CALLBACK_URL \
    --allowed-o-auth-flows code \
    --allowed-o-auth-scopes openid email \
    --supported-identity-providers $ID_PROVIDER_NAME \
    --allowed-o-auth-flows-user-pool-client > create-user-pool-client.json
CLIENT_ID=$(cat create-user-pool-client.json | jq -r .UserPoolClient.ClientId)
echo Created user pool client with client id: $CLIENT_ID
echo

echo "Go into the AWS amplify console at (https://$AWS_REGION_DEFAULT.console.aws.amazon.com/amplify/home?region=$AWS_REGION_DEFAULT)."
read

echo "Click New App and choose Build an app"
read

echo "Give the app a name such as \"demo-sso-$MANTISSA\" and click Confirm deployment."
read

echo "Wait for amplify to initialise the app and then click on \"Launch Studio\" the default backend name is staging."
read

echo "If a warning appears about the app not being connected to a valid back end select \"staging\" from the dropdown and click \"Connect Backend\"."
read

echo "Click \"Authentication\" in the left hand side bar."
read

echo "Click \"Reuse existing Amazon Cognito resources\"."
read

echo "Under Select a Cognito User Pool, select the one we have just created. Pool name: $POOL_NAME, pool id: $POOL_ID"
read

echo "Under Select an app client choose the one we have just created. Client name: $CLIENT_NAME, client id: $CLIENT_ID"
read

echo "Wait for it to finish processing and the click Import."
read

echo "Wait for it to finish deploying."
read

echo "Click the copy to clipboard button next to the amplify pull ... command."
read

echo "Open a terminal and navigate to the site directory for this project."
read

echo Paste the command that has just been copied to the clipboard and press return.
read

echo "Answer all the questions, this probably involes accepting all the defaults."
read

echo "If working in dev make sure the site is running with the command below: "
echo HTTPS=true PORT=$PORT npm start
read

echo Open the cognito management console at https://console.aws.amazon.com/cognito/home
read

echo Click into the userpool we have created: $POOL_NAME
read

echo Click App integration.
read

echo Scroll down to App clients and analytics.
read

echo Click on the client we have just made: $CLIENT_NAME
read

echo Scroll down to Hosted UI and Click View Hosted UI
read

TOKEN_URL="https://$DOMAIN_PREFIX.auth.$AWS_REGION_DEFAULT.amazoncognito.com/oauth2/token"
echo If everything has been configured correctly you should be directed to Microsoft to log in,
echo as we have not set up any other authenticaion methods if you are logged in already you will 
echo then get transferred back to the site with a query parameter of code and a value that can 
echo be used to get a proper token.
echo
echo If you paste the value of code below the script will construct a curl request for you to get a token.
read CODE
echo 

echo The following command will get a token from the code you have just been provided.
echo 
echo "curl -X POST -H \"Content-Type: application/x-www-form-urlencoded\" \\"
echo "     -d grant_type=authorization_code \\"
echo "     -d client_id=$CLIENT_ID \\"
echo "     -d code=$CODE \\"
echo "     -d redirect_uri=$CALLBACK_URL \\"
echo "     $TOKEN_URL"
echo
echo To run that command press return
read
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
     -d grant_type=authorization_code \
     -d client_id=$CLIENT_ID \
     -d code=$CODE \
     -d redirect_uri=$CALLBACK_URL \
     $TOKEN_URL | jq .

