import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import { ErrorBoundary } from "./components/ErrorBoundary";
import { AnalyticsErrorBoundary } from "./components/AnalyticsErrorBoundary";
import { analytics, resourceMonitor } from "./lib/analytics";
import { PostHogProvider } from "posthog-js/react";
import "./assets/shimmer.css";
import "./styles.css";

// Initialize analytics before rendering
analytics.initialize();

// Start resource monitoring (check every 2 minutes)
resourceMonitor.startMonitoring(120000);

// Add a macOS-specific class to the <html> element to enable platform-specific styling
// Browser-safe detection using navigator properties (works in Tauri and web preview)
(() => {
  const isMacLike = typeof navigator !== "undefined" &&
    (navigator.platform?.toLowerCase().includes("mac") ||
      navigator.userAgent?.toLowerCase().includes("mac os x"));
  if (isMacLike) {
    document.documentElement.classList.add("is-macos");
  }
})();

const AppWithProviders = () => {
  const app = (
    <ErrorBoundary>
      <AnalyticsErrorBoundary>
        <App />
      </AnalyticsErrorBoundary>
    </ErrorBoundary>
  );

  // Only wrap with PostHogProvider if API key is provided and PostHog is not disabled
  if (import.meta.env.VITE_PUBLIC_POSTHOG_KEY && import.meta.env.VITE_DISABLE_POSTHOG !== 'true') {
    return (
      <PostHogProvider
        apiKey={import.meta.env.VITE_PUBLIC_POSTHOG_KEY}
        options={{
          api_host: import.meta.env.VITE_PUBLIC_POSTHOG_HOST,
          capture_exceptions: true,
          debug: import.meta.env.MODE === "development",
        }}
      >
        {app}
      </PostHogProvider>
    );
  }

  return app;
};

ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <React.StrictMode>
    <AppWithProviders />
  </React.StrictMode>,
);
