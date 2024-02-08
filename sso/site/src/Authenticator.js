import { Route, Routes, BrowserRouter } from "react-router-dom";
import Loading from "components/Loading";
import Error from "components/Error";
import { Auth } from "aws-amplify";
import { useState } from "react";

const MAX_RETRIES = 3;

const SignIn = () => {
  Auth.federatedSignIn();
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
  return <>{"You have been signed out."}</>;
};

const Validator = ({ children }) => {
  const [loading, setLoading] = useState(false);
  const [user, setUser] = useState(null);
  const [error, setError] = useState(null);
  const [count, setCount] = useState(0);

  Auth.currentSession().then((session) => {
    console.log("currentSession", session);
  });
  Auth.currentAuthenticatedUser().then((user) => {
    console.log("currentAuthenticatedUser", user);
  });
  Auth.currentUserPoolUser().then((userPoolUser) => {
    console.log("currentUserPoolUser", userPoolUser);
  });

  if (!loading && !user && !error) {
    setLoading(true);
    Auth.currentAuthenticatedUser().then((currentAuthenticatedUser) => {
      if (currentAuthenticatedUser == null) {
        if (count < MAX_RETRIES) {
          setCount(count + 1);
          Auth.federatedSignIn();
        } else {
          setLoading(false);
          setError(`Failed to log you in after ${MAX_RETRIES} attempts.`);
        }
      } else {
        setLoading(false);
        setUser(currentAuthenticatedUser);
      }
    });
  }

  if (loading) {
    return <Loading />;
  }
  if (error) {
    return <Error title={"Unable to log you in."} description={error} />;
  }
  if (user) {
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
