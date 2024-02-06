import jwt from 'jsonwebtoken';

class AuthToken {
    static setToken(token) {
        console.log(token)
        localStorage.setItem("token.access_token", token.access_token);
        localStorage.setItem("token.expires_at", (token.expires_in - 30) * 1000 + new Date().getTime());
        localStorage.setItem("token.id_token", token.id_token);
        localStorage.setItem("token.refresh_token", token.refresh_token);
        localStorage.setItem("token.token_type", token.token_type);
    }

    static hasToken() {
        return localStorage.getItem("token.access_token") != null;
    }

    static getToken() {
        if (!AuthToken.hasToken()) {
            return null;
        }
        return {
            access_token: localStorage.getItem("token.access_token"),
            expires_at: new Date(parseInt(localStorage.getItem("token.expires_at"))),
            id_token: localStorage.getItem("token.id_token"),
            refresh_token: localStorage.getItem("token.refresh_token"),
            token_type: localStorage.getItem("token.token_type")
        };
    }

    static getClaims() {
        const token = this.getToken();
        if (token) {
            var parts = token.id_token.split('.');
            if (parts.length !== 3) {
                throw new Error('JWT must have 3 parts');
            }

            // Decode the Header and Payload
            const header = JSON.parse(atob(parts[0].replace(/_/g, '/').replace(/-/g, '+')));
            const payload = JSON.parse(atob(parts[1].replace(/_/g, '/').replace(/-/g, '+')));

            return { header, payload };
        }
        return null;
    }

    static clearToken() {
        localStorage.setItem("token.access_token", null);
        localStorage.setItem("token.expires_at", null);
        localStorage.setItem("token.id_token", null);
        localStorage.setItem("token.refresh_token", null);
        localStorage.setItem("token.token_type", null);
    }
}

export default AuthToken;