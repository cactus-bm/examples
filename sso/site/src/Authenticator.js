import { Route, Routes, BrowserRouter } from "react-router-dom";
import Loading from "components/Loading";
import Error from "components/Error";
import { Auth, Hub } from "aws-amplify";
import { useState, useEffect } from "react";
import * as config from "config";

const ERROR_MESSAGE_KEY =
  "Authenticator.Hub.auth.cognitoHostedUI_failure.message";
const ERROR_TIMESTAMP_KEY =
  "Authenticator.Hub.auth.cognitoHostedUI_failure.timestamp";
const ERRORS_PERSIST_FOR = 1000 * 60 * 5;

Hub.listen("auth", ({ payload: { data, event } }) => {
  switch (event) {
    case "cognitoHostedUI_failure":
      setErrorMessage(data);
      break;
    case "cognitoHostedUI":
      clearErrorMessage();
      break;
    default:
      break;
  }
});

const getErrorMessage = () => {
  const timestampStr = localStorage.getItem(ERROR_TIMESTAMP_KEY);
  if (timestampStr == null) {
    return null;
  }
  const timestamp = new Date(timestampStr);
  if (Date.now() - timestamp.getTime() > ERRORS_PERSIST_FOR) {
    return null;
  }
  return localStorage.getItem(ERROR_MESSAGE_KEY);
};

const setErrorMessage = (data) => {
  const decoded = decodeURIComponent(data.message.replace(/\+/g, " "));
  localStorage.setItem(ERROR_MESSAGE_KEY, decoded);
  localStorage.setItem(ERROR_TIMESTAMP_KEY, new Date().toISOString());
};

const clearErrorMessage = () => {
  localStorage.removeItem(ERROR_MESSAGE_KEY);
  localStorage.removeItem(ERROR_TIMESTAMP_KEY);
};

const triggerSignIn = async () => {
  Auth.federatedSignIn();
};

const SignIn = () => {
  triggerSignIn();
  return <Loading />;
};

const SignOut = () => {
  const [loading, setLoading] = useState(true);
  Auth.signOut().then(() => {
    setLoading(false);
  });
  if (loading) {
    return <Loading />;
  }
  window.location.replace(config.getOAuthSignoutUrl());
  return <Loading />;
};

const Validator = ({ children }) => {
  const [loading, setLoading] = useState(false);
  const [session, setSession] = useState(null);

  useEffect(() => {
    const login = async () => {
      try {
        setLoading(true);
        const session = await Auth.currentSession();
        setSession(session);
      } catch (error) {
        if (getErrorMessage() == null) {
          triggerSignIn();
        }
      } finally {
        setLoading(false);
      }
    };
    login();
  }, []);

  if (loading) {
    return <Loading />;
  } else if (session) {
    return <>{children}</>;
  } else {
    return <Error title={"Unable to login."} description={getErrorMessage()} />;
  }
};

const Authenticator = ({ children }) => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path={"signin"} element={<SignIn />} />
        <Route path={"signout"} element={<SignOut />} />
        <Route path={"*"} element={<Validator children={children} />} />
      </Routes>
    </BrowserRouter>
  );
};

export default Authenticator;
