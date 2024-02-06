import Authenticator from "Authenticator";
import logo from "./logo.svg";
import "./App.css";
import AuthToken from "AuthToken";

const App = () => {
    return (
        <Authenticator>
            <div className="App">
                <header className="App-header">
                    <img src={logo} className="App-logo" alt="logo" />
                    <a
                        className="App-link"
                        href="https://reactjs.org"
                        target="_blank"
                        rel="noopener noreferrer"
                    >
                        {AuthToken.getClaims()}
                    </a>
                </header>
            </div>
        </Authenticator>
    )
}

export default App;