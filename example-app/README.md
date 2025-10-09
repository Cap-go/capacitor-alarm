# Example App for `@capgo/capacitor-alarm`

This Vite project links directly to the local plugin source so you can exercise the native APIs while developing.

## Actions in this playground

- **Get OS info** – Calls getOSInfo() to discover the current platform capabilities.
- **Request permissions** – Requests alarm-related permissions on supported platforms.
- **Create alarm** – Attempts to schedule a native alarm. Works on platforms that expose alarm APIs.
- **Open system alarm list** – Requests the system alarm list if the platform supports it.

## Getting started

```bash
npm install
npm start
```

Add native shells with `npx cap add ios` or `npx cap add android` from this folder to try behaviour on device or simulator.
