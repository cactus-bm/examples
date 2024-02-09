class AuthToken {
  static setToken(token) {
    localStorage.setItem("token.access_token", token.access_token);
    localStorage.setItem(
      "token.expires_at",
      (token.expires_in - 30) * 1000 + new Date().getTime()
    );
    localStorage.setItem("token.id_token", token.id_token);
    localStorage.setItem("token.refresh_token", token.refresh_token);
    localStorage.setItem("token.token_type", token.token_type);
  }

  static hasToken() {
    return !!localStorage.getItem("token.access_token");
  }

  static tokenExpired() {
    return (
      !!localStorage.getItem("token.expires_at") &&
      (new Date(parseInt(localStorage.getItem("token.expires_at"))) > new Date())
    );

  }

  static getAccessToken() {
    localStorage.getItem("token.access_token");
  }

  static getClaims() {
    const id_token = localStorage.getItem("token.id_token");
    if (id_token) {
      var parts = id_token.split(".");
      if (parts.length !== 3) {
        return null;
      }

      const payload = JSON.parse(
        atob(parts[1].replace(/_/g, "/").replace(/-/g, "+"))
      );

      return payload;
    }
    return null;
  }

  static getRefreshToken() {
    return localStorage.getItem("token.refresh_token");
  }

  static clearToken() {
    localStorage.removeItem("token.access_token");
    localStorage.removeItem("token.expires_at");
    localStorage.removeItem("token.id_token");
    localStorage.removeItem("token.refresh_token");
    localStorage.removeItem("token.token_type");
  }
}

export default AuthToken;
