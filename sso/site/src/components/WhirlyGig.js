import logo from "logo.svg";
import "App.css";

import AuthToken from "AuthToken";

const WhirlyGig = () => {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        {"Logged in as: "}
        {AuthToken.getClaims()["email"]}
      </header>
    </div>
  );
};

export default WhirlyGig;
