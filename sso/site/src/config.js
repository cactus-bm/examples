const USERPOOL_ID = process.env.REACT_APP_USERPOOL_ID;
const CLIENT_ID = process.env.REACT_APP_CLIENT_ID;
const REGION = process.env.REACT_APP_REGION;
const OAUTH_DOMAIN = process.env.REACT_APP_OAUTH_DOMAIN;
const OAUTH_CALLBACK_URL = process.env.REACT_APP_OAUTH_CALLBACK_URL;
const OAUTH_SIGNOUT_URL = process.env.REACT_APP_OAUTH_SIGNOUT_URL;
const OAUTH_SCOPE = process.env.REACT_APP_OAUTH_SCOPE;
const OAUTH_RESPONSE_TYPE = process.env.REACT_APP_OAUTH_RESPONSE_TYPE;

export const getRegion = () => REGION;
export const getUserPoolId = () => USERPOOL_ID;
export const getClientId = () => CLIENT_ID;

export const getOAuth= () => ({
    domain: OAUTH_DOMAIN,
    scope: OAUTH_SCOPE,
    redirectSignIn: OAUTH_CALLBACK_URL,
    redirectSignOut: OAUTH_SIGNOUT_URL,
    responseType: OAUTH_RESPONSE_TYPE,
});