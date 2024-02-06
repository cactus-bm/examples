#!/bin/bash
DEFAULT_APP_NAME=demo-sso
DEFAULT_ENV_NAME=dev
DEFAULT_MANTISSA=$(date +"%Y%m%d%H%M")
DEFAULT_COMPANY_IDENTIFIER=org-example
DEFAULT_GROUPS_ATTRIBUTE=azure_groups
DEFAULT_PORT=3000
CHOSEN_PORT=""

DEFAULT_GROUP_CLAIM_NAME=http://schemas.microsoft.com/ws/2008/06/identity/claims/groups
DEFAULT_MAIL_CLAIM_NAME=http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress
DEFAULT_GIVENNAME_CLAIM_NAME=http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname
DEFAULT_PRINCIPALNAME_CLAIM_NAME=http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name
DEFAULT_SURNAME_CLAIM_NAME=http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname

AZURE_PORTAL_URL=https://portal.azure.com
COGNITO_CONSOLE_URL=https://console.aws.amazon.com/cognito/home
echo "Create User Pool and Connect to Azure AD (Entra ID)"
echo

if [ -f ~/.aws/credentials ]; then
    echo "AWS Profiles:"
    echo
    cat ~/.aws/credentials| grep "\[" | sed 's/\[//g' | sed 's/\]//g'
    echo
fi

AWS_PROFILE_PROMPT="Which AWS profile would you like to use? "
if [ -n "$AWS_PROFILE" ]; then
  AWS_PROFILE_PROMPT="$AWS_PROFILE_PROMPT($AWS_PROFILE) "
fi
read -p "$AWS_PROFILE_PROMPT" INPUT
AWS_PROFILE=${INPUT:-$AWS_PROFILE}
if [ -z "$AWS_PROFILE" ]; then
  echo "An AWS Profile is required"
  exit 1
fi
echo

AWS_REGION_PROMPT="Which AWS region would you like to use? "
if [ -n "$AWS_REGION_DEFAULT" ]; then
  AWS_REGION_PROMPT="$AWS_REGION_PROMPT($AWS_REGION_DEFAULT) "
fi
read -p "$AWS_REGION_PROMPT" INPUT
AWS_REGION_DEFAULT=${INPUT:-$AWS_REGION_DEFAULT}
if [ -z "$AWS_REGION_DEFAULT" ]; then
  echo "An AWS Region is required"
  exit 2
fi
echo

read -p "What is company identifier for you today? ($DEFAULT_COMPANY_IDENTIFIER) " INPUT
COMPANY_IDENTIFIER=${INPUT:-$DEFAULT_COMPANY_IDENTIFIER}
echo

read -p "What is the name of the app you are building today? ($DEFAULT_APP_NAME) " INPUT
APP_NAME=${INPUT:-$DEFAULT_APP_NAME}
echo

read -p "Which environment are you working in today? ($DEFAULT_ENV_NAME) " INPUT
ENV_NAME=${INPUT:-$DEFAULT_ENV_NAME}
echo

read -p "Would you like to use a mantissa today, type NONE to reject the default? ($DEFAULT_MANTISSA) " INPUT
MANTISSA=${INPUT:-$DEFAULT_MANTISSA}
echo

DEFAULT_IDENTIFIER=${APP_NAME}-${ENV_NAME}-${MANTISSA}
DEFAULT_IDENTIFIER_NO_ENV=${APP_NAME}-${MANTISSA}
if [ "$MANTISSA" == "NONE" ]; then
  DEFAULT_IDENTIIFER=${APP_NAME}-${ENV_NAME}
  DEFAULT_IDENTIFIER_NO_ENV=${APP_NAME}
fi
read -p "What identifier would you like to use today? ($DEFAULT_IDENTIFIER) " INPUT
IDENTIFIER=${INPUT:-$DEFAULT_IDENTIFIER}
echo

TMP_DIR=$(mktemp -d)
echo Creating a temporary directory at $TMP_DIR
pushd $TMP_DIR
echo

DEFAULT_POOL_NAME=$IDENTIFIER-userPool
read -p "What would you like to call the user pool? ($DEFAULT_POOL_NAME) " INPUT
POOL_NAME=${INPUT:-$DEFAULT_POOL_NAME}
aws cognito-idp create-user-pool --pool-name $POOL_NAME > create-user-pool.json
POOL_ID=$(cat create-user-pool.json | jq -r .UserPool.Id)
echo Created User Pool, $POOL_NAME, with POOL_ID: $POOL_ID
echo

DEFAULT_DOMAIN_PREFIX=${COMPANY_IDENTIFIER}-${IDENTIFIER}
read -p "Please enter a globally unique domain prefix. ($DEFAULT_DOMAIN_PREFIX) " INPUT
DOMAIN_PREFIX=${INPUT:-$DEFAULT_DOMAIN_PREFIX}
echo

echo Creating User Pool Domain for pool with id $POOL_ID with Domain Prefix: $DOMAIN_PREFIX
aws cognito-idp create-user-pool-domain --domain $DOMAIN_PREFIX --user-pool-id $POOL_ID
echo Created User Pool Domain
echo

echo Assigning variables for future use:
ENTITY_ID=urn:amazon:cognito:sp:$POOL_ID
OAUTH_DOMAIN=$DOMAIN_PREFIX.auth.$AWS_REGION_DEFAULT.amazoncognito.com
REPLY_URL=https://$OAUTH_DOMAIN/saml2/idpresponse
TOKEN_URL=https://$OAUTH_DOMAIN/oauth2/token
echo ENTITY_ID: $ENTITY_ID
echo REPLY_URL: $REPLY_URL
echo TOKEN_URL: $TOKEN_URL
echo

echo The following steps must be completed in Azure, who knows if this part is scriptable because, Microsoft, after each instruction press return to get the next instruction.
echo

echo Log in to the Azure Portal at $AZURE_PORTAL_URL
open $AZURE_PORTAL_URL
read

echo Go to Microsoft Entra ID by entering \"Microsoft Entra ID\" in the search bar at the top of the page.
read

echo In the left side bar click \"Enterprise Applications\"
read

echo Click \"New application\"
read

echo Click \"Create your own application\"
read

echo Enter the name of the app: $IDENTIFIER the value will be in your clipboard if using a mac.
echo $IDENTIFIER | pbcopy 
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

echo Press the Save button
read

echo Close the Bascic SAML configuration section.
read

echo "Click edit in the Attributes & Claims section."
read

echo Click Add a group claim.
read

echo Click Groups assigned to the application option in the popup.
read

echo Leave source attribute as Group ID and press Save.
read

echo Copy the value from the newly created Group claims and paste below
read -p "($DEFAULT_GROUP_CLAIM_NAME)" INPUT
GROUP_CLAIM_NAME=${INPUT:-$DEFAULT_GROUP_CLAIM_NAME}
echo

echo Copy the value from the email claim and paste below
read -p "($DEFAULT_MAIL_CLAIM_NAME)" INPUT
MAIL_CLAIM_NAME=${INPUT:-$DEFAULT_MAIL_CLAIM_NAME}
echo

echo Copy the value from the given name claim and paste below.
read -p "($DEFAULT_GIVENNAME_CLAIM_NAME)" INPUT
GIVENNAME_CLAIM_NAME=${INPUT:-$DEFAULT_GIVENNAME_CLAIM_NAME}
echo

echo Copy the value from the principal name claim and paste below.
read -p "($DEFAULT_PRINCIPALNAME_CLAIM_NAME)" INPUT
PRINCIPALNAME_CLAIM_NAME=${INPUT:-$DEFAULT_PRINCIPALNAME_CLAIM_NAME}
echo

echo Copy the value from the surname claim and paste below.
read -p "($DEFAULT_SURNAME_CLAIM_NAME)" INPUT
SURNAME_CLAIM_NAME=${INPUT:-$DEFAULT_SURNAME_CLAIM_NAME}
echo

echo "Close the Attributes & Claims window."
read

echo Scroll down to the SAML certificates section.
read

echo Copy the App Federation Metadata Url and paste below.
read APP_FEDERATION_METADATA_URL
echo

echo Set yourself up as a user of this application.
echo
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

read -p "Enter a name for the groups attribute in cognito which will store the azure groups: ($DEFAULT_GROUPS_ATTRIBUTE) " INPUT
GROUPS_ATTRIBUTE=${INPUT:-$DEFAULT_GROUPS_ATTRIBUTE}
echo

echo Adding groups attribute $GROUPS_ATTRIBUTE to pool: $POOL_ID
aws cognito-idp add-custom-attributes \
    --user-pool-id $POOL_ID \
    --custom-attributes Name=$GROUPS_ATTRIBUTE,AttributeDataType="String"
echo Added groups attribute $GROUPS_ATTRIBUTE to pool: $POOL_ID
echo

DEFAULT_ID_PROVIDER_NAME=azure-${IDENTIFIER}
read -p "Enter a name for the id provider with a maximum of 32 chars. ($DEFAULT_ID_PROVIDER_NAME) " INPUT
ID_PROVIDER_NAME=${INPUT:-$DEFAULT_ID_PROVIDER_NAME}
echo

echo Creating identity provider $ID_PROVIDER_NAME.
aws cognito-idp create-identity-provider \
    --user-pool-id $POOL_ID \
    --provider-name=$ID_PROVIDER_NAME \
    --provider-type SAML \
    --provider-details MetadataURL=$APP_FEDERATION_METADATA_URL \
    --attribute-mapping email=$MAIL_CLAIM_NAME,custom:$GROUPS_ATTRIBUTE=$GROUP_CLAIM_NAME > create-identity-provider.json
echo Created identity provider $ID_PROVIDER_NAME
echo

DEFAULT_CLIENT_NAME=${IDENTIFIER}-client
read -p "Enter a name for the client application and assign: ($DEFAULT_CLIENT_NAME) " INPUT
CLIENT_NAME=${INPUT:-$DEFAULT_CLIENT_NAME}
echo

DEFAULT_CALLBACK=$DEFAULT_PORT
read -p "Enter the callback url, if working in dev on localhost please enter just the port number. ($DEFAULT_CALLBACK) " INPUT
echo 
CALLBACK_URL=${INPUT:-$DEFAULT_CALLBACK}
if [[ "$CALLBACK_URL" =~ ^[0-9]+$ ]]; then
  CHOSEN_PORT=$CALLBACK_URL
  CALLBACK_URL=https://localhost:$CALLBACK_URL
fi

echo "Using $CALLBACK_URL as the callback url."
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

AMPLIFY_CONSOLE_URL=https://$AWS_REGION_DEFAULT.console.aws.amazon.com/amplify/home?region=$AWS_REGION_DEFAULT
echo "Go into the AWS amplify console at ($AMPLIFY_CONSOLE_URL)."
open $AMPLIFY_CONSOLE_URL
read

echo "Click New App and choose Build an app"
read

echo "Give the app a name such as \"$DEFAULT_IDENTIFIER_NO_ENV\" which is now on the clipboard."
echo $DEFAULT_IDENTIFIER_NO_ENV | pbcopy
read

echo "Click Confirm deployment."
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

if [ -n "$CHOSEN_PORT" ]; then
    echo When using react locally https with a self signed certificate can be used with the following command: 
    echo
    echo HTTPS=true PORT=$CHOSEN_PORT npm start
    echo 
    echo However, chrome will reject self-signed certificates. 
    echo You can enable self-signed certificates on localhost by going to 
    echo 
    echo chrome://flags/#allow-insecure-localhost 
    echo 
    echo and enabling the option.
    read
fi

echo Open the cognito management console at $COGNITO_CONSOLE_URL
open $COGNITO_CONSOLE_URL
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
echo

echo "To run the example site app with all of the above configured place the following in a .env file in the root of the site directory."
echo
echo REACT_APP_OAUTH_DOMAIN=$OAUTH_DOMAIN
echo REACT_APP_USERPOOL_ID=$POOL_ID
echo REACT_APP_CLIENT_ID=$CLIENT_ID
echo REACT_APP_REGION=$AWS_REGION_DEFAULT
echo REACT_APP_LOCAL_URL=$CALLBACK_URL
