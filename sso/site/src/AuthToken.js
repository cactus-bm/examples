class AuthToken {
    static setToken(token) {
        localStorage.setItem("authToken", token);
    }

    static getToken() {
        return localStorage.getItem("authToken");
    }
}

export default AuthToken;