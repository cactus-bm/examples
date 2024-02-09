# Getting started with SSO with Cognito and Azure AD (Entra ID)

A very simple website which demonstrates how to use Azure AD (Entra ID) for SSO with Cognito

## Prerequisits

You will need:
* An AWS Account
* An Azure Account

Both our AWS Account and our Azure Account are paid, I do not know if that would be required.

## Background

One of our clients would like for us to use their Office 365 Azure AD set up to allow them to control which users have access to the system. This is a critical piece of infrastructure and to increase the likelihood that the result would be secure I decided to build a public example on the internet. 

After all the fastest why to find out that you are wrong, is to publically state that something is correct on the internet.

## Setting up the cognito pool

Everything this site requires can be set up using the script and instructions in `../cognito/setup-userpool.sh` this will also guide through step by step how and what to set up in Azure.

## Getting the environment variables

Once you have run the `setup-userpool.sh` script you will be provided with all the environment variables that you will need to run the user pool. They will be printed to the screen, copied to your clipboard and written to the `site/.env` file as part of that process.

## Acknowledgements

This project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).