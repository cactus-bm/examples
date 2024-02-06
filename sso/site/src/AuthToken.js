class AuthToken {
    static setToken(token) {
        localStorage.setItem("authToken", token);
    }

    static getToken() {
        return localStorage.getItem("authToken");
    }

    static clearToken() {
        localStorage.setItem("authToken", null);
    }
}

export default AuthToken;