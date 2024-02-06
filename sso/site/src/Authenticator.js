
import { useFetchAuthTokenFromCodeQuery } from "services/authService";
import * as config from "config";
import { Route, Routes, Navigate, BrowserRouter } from "react-router-dom";
import Loading from "components/Loading";
import Error from "components/Error";
import AuthToken from "AuthToken";

const loginHref = () => {
  return (
    `https://${config.getOAuthDomain()}/oauth2/authorize?` +
    new URLSearchParams({
      scope: "email openid",
      response_type: "code",
      client_id: config.getClientId(),
      redirect_uri: config.getCallbackUrl(),
    })
  );
};

const Auth = () => {
  const queryParams = new URLSearchParams(window.location.search);
  const code = queryParams.get("code");
  const {
    data: token,
    isLoading,
    isError,
  } = useFetchAuthTokenFromCodeQuery({ code }, { skip: !code });
  if (queryParams.has("error")) {
    return <Error
      title={"Unable to get login code: " + queryParams.get("error")}
      description={queryParams.get("error_description")}
    />;
  }
  if (isLoading) {
    return <Loading />;
  }
  if (isError) {
    return <Error
      title={"Unable to load token from code"}
      description={JSON.stringify(token, null, 2)}
    />;
  }
  if (token) {
    AuthToken.setToken(token);
    return <Navigate to={"/"} />;
  }
};

const Redirect = ({ to }) => {
  window.location.replace(to);
  return <></>;
};

const SignOut = () => {
  AuthToken.clearToken();
  return <Navigate to={"/"} />;
};

const Authenticator = ({ children }) => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path={"auth"} element={<Auth />} />
        <Route path={"login"} element={<Redirect to={loginHref()} />} />
        <Route path={"logoff"} element={<SignOut />} />
        {AuthToken.getToken() ? (
          <Route path={"*"} element={<>{children}</>} />
        ) : (
          <Route path={"*"} element={<Redirect to={loginHref()} />} />
        )}
      </Routes>
    </BrowserRouter>
  );
};

export default Authenticator;
