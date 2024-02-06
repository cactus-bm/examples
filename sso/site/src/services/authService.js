import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

import * as config from "config";

export const authApi = createApi({
  reducerPath: "authApi",
  baseQuery: fetchBaseQuery({
    baseUrl: `https://${config.getOAuthDomain()}/`,
    prepareHeaders: (headers) => {
      headers.set("content-type", "application/x-www-form-urlencoded");
      return headers;
    },
  }),
  endpoints: (builder) => ({
    fetchAuthTokenFromCode: builder.query({
      query: ({ code }) => ({
        url: "oauth2/token",
        method: "POST",
        body: new URLSearchParams({
          grant_type: "authorization_code",
          client_id: config.getClientId(),
          code,
          redirect_uri: config.getLocalUrl(),
        }),
      }),
    }),
  }),
});

export const { useFetchAuthTokenFromCodeQuery } = authApi;
