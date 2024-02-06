import logo from "./logo.svg";
import "./App.css";
import { useFetchAuthTokenFromCodeQuery } from "services/authService";
import * as config from "config";
import { Route, Routes, Navigate, BrowserRouter } from "react-router-dom";

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

class AuthToken {
  static setToken(token) {
    localStorage.setItem("authToken", token);
  }

  static getToken() {
    return localStorage.getItem("authToken");
  }
}

const Auth = () => {
  const queryParams = new URLSearchParams(window.location.search);
  const code = queryParams.get("code");
  const {
    data: token,
    isLoading,
    isError,
  } = useFetchAuthTokenFromCodeQuery({ code }, { skip: !code });
  if (token) {
    AuthToken.setToken(token);
    return <Navigate to={"/"} />;
  }
  if (isLoading) {
    return <div>Loading...</div>;
  }
  if (isError) {
    return <div>Error</div>;
  }
  console.log(queryParams);
  return <div>{queryParams}</div>;
};

const WhirlyGig = () => (
  <div className="App">
    <header className="App-header">
      <img src={logo} className="App-logo" alt="logo" />
      <a
        className="App-link"
        href="https://reactjs.org"
        target="_blank"
        rel="noopener noreferrer"
      >
        You are logged in.
      </a>
    </header>
  </div>
);

const Redirect = ({ to }) => {
  window.location.replace(to);
  return <></>;
};

const App = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path={"auth"} element={<Auth />} />
        {AuthToken.getToken() ? (
          <Route path={"*"} element={<WhirlyGig />} />
        ) : (
          <Route path={"*"} element={<Redirect to={loginHref()} />} />
        )}
      </Routes>
    </BrowserRouter>
  );
};

export default App;
