echo Create User Pool and Connect to Azure AD (Entra ID)

TMP_DIR=$(mktemp -d)
echo Creating a temporary directory at $TMP_DIR
pushd $TMP_DIR

echo "Please enter the profile that will be used to set up in AWS:"
read AWS_PROFILE

echo "Please enter the AWS region that will be used. e.g. us-east-1"
read AWS_REGION_DEFAULT

echo "Please enter a name for the Fully Specified Application User Pool e.g. {app-name}-{env}-{optional-miscellaneous}"
echo e.g. "demo-sso-dev-attempt-20230205"
read APP_NAME

POOL_NAME=$APP_NAME-UserPool
echo Creating User Pool with Pool Name: $POOL_NAME
aws cognito-idp create-user-pool --pool-name $POOL_NAME | tee create-user-pool.json
POOL_ID=$(cat create-user-pool.json | jq -r .UserPool.Id)
echo Created User Pool, $POOL_NAME, with POOL_ID: $POOL_ID

echo "Please enter a globally unique domain prefix e.g. {reverse-domain}-{app-name}-{env}-{optional-miscellaneous}"
echo e.g. "bm-cactus-demo-sso-dev-attempt-20230205"
read DOMAIN_PREFIX

echo Creating User Pool Domain for pool with id $POOL_ID with Domain Prefix: $DOMAIN_PREFIX
aws cognito-idp create-user-pool-domain --domain $DOMAIN_PREFIX --user-pool-id $POOL_ID
echo Created User Pool Domain

echo Assigning variables for future use:
ENTITY_ID=urn:amazon:cognito:sp:$POOL_ID
REPLY_URL=https://$DOMAIN_PREFIX.auth.$AWS_REGION_DEFAULT.amazoncognito.com/saml2/idpresponse
echo ENTITY_ID: $ENTITY_ID
echo REPLY_URL: $REPLY_URL

echo The following steps must be completed in Azure, who knows if this part is scriptable because, Microsoft, after each instruction press return to get the next instruction.

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

echo Choose "\"Integrate any other application you don\'t find in the gallery (Non-gallery)\""
read

echo Click create
read

echo Wait for the overview screen to load this may take several seconds. Press enter when it has completed.
read

echo Click "Set up single sign on."
read

echo Click SAML
read

echo Click the edit button in the basic SAML configuration section.
read 

echo Click add identifier in the Entity Id section.
read

echo Enter $ENTITY_ID into the text field, the value will be in your clipboard if using a mac.
echo $ENTITY_ID | pbcopy
read

echo Click Add Identifier in the Reply URL.
read

echo Enter the value $REPLY_URL into the box, the value will be in your clipboard if using a mac.
echo $REPLY_URL | pbcopy
read

echo Press the save button
read

echo Close the Bascic SAML configuration section.
read

echo Click edit in the attributes and claims section.
read

echo Click add a group claim.
read

echo Click Groups Assigned to the application option in the popup.
read

echo Leave source attribute as group id and press save.
read

echo Copy the value from the newly created Group claims and paste below
read GROUP_CLAIM_NAME

echo Copy the value from the email claim and paste below
read MAIL_CLAIM_NAME

echo Copy the value from the given name claim and paste below.
read GIVENNAME_CLAIM_NAME

echo Copy the value from the principal name claim and paste below.
read PRINCIPALNAME_CLAIM_NAME

echo Copy the value from the surname claim and paste below.
read SURNAME_CLAIM_NAME

echo Close the user attributes and claims window.
read

echo Scroll down to the SAML certificates section.
read

echo Copy the app Federation Meta URL and assign to a value, paste below.
read APP_FEDERATION_METADATA_URL

echo Set yourself up as a user of this application.
read

echo Enter a name for the groups attribute in cognito which will store the azure groups e.g. azure_groups
read GROUPS_ATTRIBUTE

echo Enter a name for the id provider e.g. azure-{reverse-domain}-{app-name}-{env}-{optional-miscellaneous}, e.g. azure-bm-cactus-demo-sso-dev-attempt-20230205.
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
    --attribute-mapping email=$GROUP_MAIL_NAME,custom:$GROUPS_ATTRIBUTE=$GROUP_CLAIM_NAME
echo Created identity provider $ID_PROVIDER_NAME

echo Enter a name for the client application and assign e.g. {app-name}-{env}-{optional-miscellaneous}-client
read CLIENT_NAME

echo Enter the callback url, if working in dev this will want to be something like https://localhost:3000, you may want to use a different port so that you can have different applications on different ports.
echo This will have to be https in production, when using react locally https with a self signed certificate can be used with the following command: HTTPS=true npm start
echo However, chrome will reject self-signed certificates. However, you can enable self-signed certificates on localhost by going to chrome://flags/#allow-insecure-localhost and enabling the option.
read CALLBACK_URL

echo "If working in dev enter the port number below (if not press return):"
read PORT

echo Creating user pool client.
aws cognito-idp create-user-pool-client \
    --user-pool-id $POOL_ID \
    --client-name $CLIENT_NAME \
    --no-generate-secret \
    --callback-urls $CALLBACK_URL \
    --allowed-o-auth-flows code \
    --allowed-o-auth-scopes openid email \
    --supported-identity-providers $ID_PROVIDER_NAME \
    --allowed-o-auth-flows-user-pool-client | tee create-user-pool-client.json
CLIENT_ID=$(cat create-user-pool-client.json | jq -r .UserPoolClient.ClientId)
echo Created user pool client with client id: $CLIENT_ID

echo "Go into the AWS amplify console and create a backend environment for the application."
read

echo "Under Authentication choose the user pool we have just created. Pool name: $POOL_NAME, pool id: $POOL_ID, client id: $CLIENT_ID"
read

echo "If working in dev make sure the site is running with the command below: "
echo HTTPS=true PORT=$PORT npm start"
read

echo Open the cognito management console at https://console.aws.amazon.com/cognito/home
read

echo Click into the userpool we have created.
read

echo Click app integration.
read

echo Scroll down to app clients and analytics.
read

echo Click on the client we have just made.
read

echo Click See Hosted UI
read

