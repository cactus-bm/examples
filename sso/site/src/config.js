const OAUTH_DOMAIN = process.env.REACT_APP_OAUTH_DOMAIN;
const USERPOOL_ID = process.env.REACT_APP_USERPOOL_ID;
const CLIENT_ID = process.env.REACT_APP_CLIENT_ID;
const REGION = process.env.REACT_APP_REGION;
const CALLBACK_URL = process.env.REACT_APP_CALLBACK_URL;

export const getOAuthDomain = () => OAUTH_DOMAIN;

export const getUserPoolId = () => USERPOOL_ID;

export const getClientId = () => CLIENT_ID;

export const getRegion = () => REGION;

export const getCallbackUrl = () => CALLBACK_URL;

