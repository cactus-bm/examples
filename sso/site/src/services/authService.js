import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

import * as config from "config";

export const authApi = createApi({
  reducerPath: "authApi",
  baseQuery: fetchBaseQuery({
    baseUrl: `https://${config.getOAuthDomain}/`,
    prepareHeaders: (headers) => {
      headers.set("content-type", "application/x-www-form-urlencoded");
      return headers;
    },
  }),
  endpoints: (builder) => ({
    fetchAuthTokenFromCode: builder.mutation({
      query: ({ code }) => {
        const formData = new URLSearchParams();
        Object.entries({
          grant_type: "authorization_code",
          client_id: config.getClientId(),
          code,
          redirect_uri: config.getLocalUrl(),
        }).forEach(([key, value]) => {
          formData.append(key, value);
        });

        return {
          url: "oauth2/token",           
          method: "POST",
          body: formData,
        };
      },
    }),
  }),
});

export const { useFetchAuthTokenFromCodeMutation } = authApi;