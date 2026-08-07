import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// `base` follows the deploy target: GitHub Pages serves the staging build from
// /<repo>/, a local dev server from /. CI sets BASE_PATH for the Pages build.
export default defineConfig({
  base: process.env.BASE_PATH ?? "/",
  plugins: [react()],
  test: {
    environment: "jsdom",
    globals: true,
    setupFiles: ["./src/setupTests.ts"],
  },
});
