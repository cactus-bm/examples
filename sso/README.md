# SSO

A demo application for showing how to configure sso using aws cognito and azure ad (now called entra id).

## Amplify v5 vs v6 changes

`Auth.federatedSignIn` has been renamed to `signInWithRedirect`

`fetchAuthSession` does not throw an exception if the user is not logged in as `Auth.currentSession` did. 
However, `getCurrentUser` does throw an exception if not logged in.

## Cognito

There a script, designed to be run on a mac, that will take you through the steps required to set everything up.

You can review the commands to understand better. 

As a general rule you should not run random scripts that you found on the internet.

The actions that you need to take in Azure Portal are given to you step-by-step.

## Site

This example uses Amplify v6.

This is a very simple example site that will let you log in with Azure Id.

It adds the following very basic routes

- `/signin` will cause you to be directed the Cognito Hosted Sign In Page
- `/signout` will cause you to be directed to be logged out and redirected to the signout page

Everything else will fall through providing Auth has access to a token in local storage.

The docs read like there is some easy mechanism to make this all work using `withAuthenticator`. I would dearly like this to be true.
In placing this example on the internet I was hoping that it would cause someone to point it out to me. `withAuthenticator` appears to
have a flag that feels like it should work with Hosted UI if you set it to true. I could not make it work, AWS Amplify have recently
renonvated their website and I found lots of hopefully useful links from across the internet to be no longer pointing to the documentation
and instead redirecting one to the front page.

The only way to get sign in failures appears to be to use the `Hub` and register for the auth events. With redirects happening to an external
website local storage is used to store the most recent login failure message. A timestamp is used to ensure that reattempts would happen
after an appropriate period of time.

The example site has been created using create-react-app, using the command `npx create-react-app site` from the root sso folder.
