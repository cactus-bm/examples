import { Route, Routes, BrowserRouter } from "react-router-dom";
import Loading from "components/Loading";
import Error from "components/Error";
import { Auth } from "aws-amplify";
import { useState, useEffect } from "react";
import * as config from "config";

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
  return <>{"You have been signed out."}</>;
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
        triggerSignIn();
      } finally {
        setLoading(false);
      }
    };
    login();
  }, []);

  if (loading) {
    return <Loading />;
  }
  if (session) {
    return <>{children}</>;
  }
  return (
    <Error
      title={"You are not authenticated."}
      description={"Some how you are not authenticated. We do not know why."}
    />
  );
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
