import logo from "./logo.svg";
import "./App.css";
import { useFetchAuthTokenFromCodeQuery } from "services/authService";
import * as config from "config";

const redirectToLogin = () => {
  window.location.href =
    `https://${config.getOAuthDomain()}/oauth2/authorize?` +
    new URLSearchParams({
      scope: "email openid",
      response_type: "code",
      client_id: config.getClientId(),
      redirect_uri: config.getLocalUrl(),
    });
};

const App = () => {
  const code = new URLSearchParams(window.location.search).get("code");
  const {
    data: token,
    isLoading,
    isError,
  } = useFetchAuthTokenFromCodeQuery({ code }, { skip: !code });

  if (!code && !token) {
    redirectToLogin();
  }

  if (isError) {
    return <div>Something went wrong</div>;
  }

  if (isLoading) {
    return <div>Loading...</div>;
  }

  console.log("token", token);

  return (
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
};

export default App;
