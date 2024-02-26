# SSO Azure AD Setup Script

This script is designed to run on a mac. It will likely not run on a linux bash terminal and will certainly not run on windows.

In particular it uses `pbcopy` and `open` as commands to cause data to be written to the clipboard and websites to be opened.

## Default Values

Default values are set at the top of the script.

## AWS Params

### Profile

There is an assumption that multiple profiles are set up in a file in the standard `~/.aws/credentials` file. These are printed out for information purposes and any value can then be entered.

The profile is not passed to each command using `--profile` instead `AWS_PROFILE` is exported.

### Region

The region is not passed in with each command. The region for commands will come from the profile. The value requested is only used to specify which region the cognito pool will be 
placed in.

## Cognoto Values

### Company Identifier

This will be used to create names which will be unique across aws. It will also be used as the prefix for creating other identifiers used elsewhere. Consequently a reverse domain but
with hyphens instead of dots (dots are not supported).

### App Name

This is a name for the application that you are building. 

### Env Name

As it is assumed the script may be used to create multiple applications in multiple environments. Standard values would be `dev`, `test` and `prod` etc.

### Mantissa

As this script is expected to be used to get to grips with how this all works one might end up running everything multiple times. It is unlikely to be used more than once per minute and so the minute timestamp seemed appropriate. When making in prod or finally once happy with everything one would likely not want a mantissa, so if `NONE` is specified it works without adding the mantissa or the trailing `-`.

### Identifier

The identifier is used as the name of the application in azure and as the default name for the app in Azure and as a prefix for the default names of the user pool, client and provider name.

## Cognito Actions

### Create a User Pool

Users need to be placed inside a user pool. We will need to get the pool id from the output.

### Creata a User Pool Domain

Not really sure what this does.

### Create Custom Attribute for the Azure Groups.

As we are going to receive some groups from Azure we need a place to put them. This custom attribute goes inside the user pool. Custom attributes have the name `custom:` as a prefix.

## Azure Actions

A number of steps will be set up in Azure. Follow the instructions in the script. Nothing is very exciting. From time to time there maybe an extra dialog or similar that needs closing.

It is supposedly possible to set up Azure to allow multiple azure instances to be part of an Enterprise application. However, this does not seem to work as the `urn` protocol is not supported in that scenario.

### Create an identity provider. 

Identity providers can be set up to support only users that meet some criteria. This can be either a whole email address or else a domain from an email address. 

Multiple identity providers can be registered to a user pool.

If multiple Azure AD need to be set up this is the way to do it, by adding multiple identity providers. Which users they will work for can be controlled using the `--idp-identifiers` flag. Multiple values can be specified. They can be individual email addresses or whole domains.

It is also possible to set the the attributes to map hard coded values if wanted.

### Create an application cliemt

An application can support multiple identity providers.

## Demo Application

With everything set up the demo application in the `site` directory can be run and should be able to be run.

### `.env`

The contents of teh required `.env` file are posted to the screen and can be written to the folder in which the `site` application lives.

### Allow self-signed certificates in dev

It is better to use https for these things, when working in dev `localhost` can be allowed to have self-signed certificates in chrome by setting the flag at `chrome://flags/#allow-insecure-localhost`

### Demo Application

There is a demo application in the `site` folder. It can be run using the command provided.

As the demo app was created using `create-react-app` it can be run using `HTTPS=true PORT=3000 npm start` where `3000` would be replaced with the value entered in teh script.

## Hosted UI Login

Everything can be tested using the Hosted UI.


