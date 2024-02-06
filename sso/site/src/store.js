import { configureStore } from "@reduxjs/toolkit";
import allApis from "services/all";

export const store = configureStore({
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(...allApis.map((x) => x.middleware)),
  reducer: {
    ...Object.fromEntries(allApis.map((x) => [x.reducerPath, x.reducer])),
  },
});
