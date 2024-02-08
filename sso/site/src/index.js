import React from "react";
import ReactDOM from "react-dom/client";
import "./index.css";
import App from "App";
import { Provider } from "react-redux";
import { store } from "store";
import * as config from "config";
import { Amplify } from "aws-amplify";

Amplify.configure({
  aws_project_region: config.getRegion(),
  aws_cognito_region: config.getRegion(),
  aws_user_pools_id: config.getUserPoolId(),
  aws_user_pools_web_client_id: config.getClientId(),
  oauth: config.getOAuth(),
  federationTarget: "COGNITO_USER_POOLS",
});

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <React.StrictMode>
    <Provider store={store}>
      <App />
    </Provider>
  </React.StrictMode>
);
