import logo from "logo.svg";
import "App.css";
import Loading from "components/Loading";
import Error from "components/Error";
import { Auth } from "aws-amplify";
import { useState, useEffect } from "react";

const WhirlyGig = () => {
  const [loading, setLoading] = useState(true);
  const [user, setUser] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchSession = async () => {
      try {
        setLoading(true);
        const session = await Auth.currentSession();
        const payload = session?.getIdToken()?.payload;
        if (payload == null) {
          setError("Failed to retrieve user information.");
        } else {
          setUser(payload);
        }
      } catch (error) {
        setError("Failed to retrieve the current session.");
        console.log("currentSession error", error);
      } finally {
        setLoading(false);
      }
    };
    fetchSession();
  }, []);

  if (loading) {
    return <Loading />;
  }
  if (error) {
    return <Error error={error} />;
  }
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        {`Logged in as: ${user.email}`}
      </header>
    </div>
  );
};

export default WhirlyGig;
