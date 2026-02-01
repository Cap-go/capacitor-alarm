# @capgo/capacitor-alarm
 <a href="https://capgo.app/"><img src='https://raw.githubusercontent.com/Cap-go/capgo/main/assets/capgo_banner.png' alt='Capgo - Instant updates for capacitor'/></a>

<div align="center">
  <h2><a href="https://capgo.app/?ref=plugin_alarm"> ➡️ Get Instant updates for your App with Capgo</a></h2>
  <h2><a href="https://capgo.app/consulting/?ref=plugin_alarm"> Missing a feature? We’ll build the plugin for you 💪</a></h2>
</div>

Manage native alarm Capacitor plugin

## Why Capacitor Alarm?

The only plugin implementing the **latest native alarm APIs** for both iOS and Android:

- **iOS 26+ AlarmKit** - Full integration with Apple's new alarm framework
- **Android AlarmClock intents** - Modern alarm management following OEM policies
- **Future-proof** - Built on the newest platform APIs, not deprecated methods
- **Cross-platform** - Consistent API across iOS and Android

Essential for alarm clock apps, reminder apps, medication trackers, and any app needing native system alarms.

## Documentation

The most complete doc is available here: https://capgo.app/docs/plugins/alarm/

## Compatibility

| Plugin version | Capacitor compatibility | Maintained |
| -------------- | ----------------------- | ---------- |
| v8.\*.\*       | v8.\*.\*                | ✅          |
| v7.\*.\*       | v7.\*.\*                | On demand   |
| v6.\*.\*       | v6.\*.\*                | ❌          |
| v5.\*.\*       | v5.\*.\*                | ❌          |

> **Note:** The major version of this plugin follows the major version of Capacitor. Use the version that matches your Capacitor installation (e.g., plugin v8 for Capacitor 8). Only the latest major version is actively maintained.

## Install

```bash
npm install @capgo/capacitor-alarm
npx cap sync
```

## Requirements

- iOS: iOS 26+ only. This plugin relies on `AlarmKit` APIs and will report unsupported on earlier versions or when the framework is unavailable.
- Android: Uses `AlarmClock` intents; behavior depends on the default Clock app and OEM policies.

Note: This plugin only exposes native alarm actions (create/open). It does not implement any custom in-app alarm scheduling/CRUD.

## Permission checks

Use `CapgoAlarm.checkPermissions()` to query whether AlarmKit (iOS) or the platform clock integration (Android) is ready before prompting users. The method never opens system UI and returns a `PermissionResult` with `details` describing platform-specific states (for example, `{ alarmKit: true }` on iOS or `{ exactAlarm: false }` on Android 12+).

If your native runtime ships an older build of this plugin that predates the `checkPermissions` bridge, the JavaScript shim resolves with `{ granted: false, message: 'CapgoAlarm.checkPermissions is not implemented...' }` so you can gracefully fall back to feature detection or request an update.

## API

<docgen-index>

* [`createAlarm(...)`](#createalarm)
* [`openAlarms()`](#openalarms)
* [`getOSInfo()`](#getosinfo)
* [`requestPermissions(...)`](#requestpermissions)
* [`checkPermissions()`](#checkpermissions)
* [`getPluginVersion()`](#getpluginversion)
* [`getAlarms()`](#getalarms)
* [`cancelAlarm(...)`](#cancelalarm)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

Capacitor Alarm Plugin interface for managing native OS alarms.

### createAlarm(...)

```typescript
createAlarm(options: NativeAlarmCreateOptions) => Promise<NativeActionResult>
```

Create a native OS alarm using the platform clock app.
On Android this uses the Alarm Clock intent; on iOS this uses AlarmKit if available (iOS 16+).

| Param         | Type                                                                          | Description                      |
| ------------- | ----------------------------------------------------------------------------- | -------------------------------- |
| **`options`** | <code><a href="#nativealarmcreateoptions">NativeAlarmCreateOptions</a></code> | - Options for creating the alarm |

**Returns:** <code>Promise&lt;<a href="#nativeactionresult">NativeActionResult</a>&gt;</code>

**Since:** 1.0.0

--------------------


### openAlarms()

```typescript
openAlarms() => Promise<NativeActionResult>
```

Open the platform's native alarm list UI, if available.

**Returns:** <code>Promise&lt;<a href="#nativeactionresult">NativeActionResult</a>&gt;</code>

**Since:** 1.0.0

--------------------


### getOSInfo()

```typescript
getOSInfo() => Promise<OSInfo>
```

Get information about the OS and capabilities.

**Returns:** <code>Promise&lt;<a href="#osinfo">OSInfo</a>&gt;</code>

**Since:** 1.0.0

--------------------


### requestPermissions(...)

```typescript
requestPermissions(options?: { exactAlarm?: boolean | undefined; } | undefined) => Promise<PermissionResult>
```

Request relevant permissions for alarm usage on the platform.
On Android, may route to settings for exact alarms.

| Param         | Type                                   | Description                                      |
| ------------- | -------------------------------------- | ------------------------------------------------ |
| **`options`** | <code>{ exactAlarm?: boolean; }</code> | - Optional parameters for the permission request |

**Returns:** <code>Promise&lt;<a href="#permissionresult">PermissionResult</a>&gt;</code>

**Since:** 1.0.0

--------------------


### checkPermissions()

```typescript
checkPermissions() => Promise<PermissionResult>
```

Check the current permission state for native alarm access without triggering UI.
On iOS this reports AlarmKit readiness; on Android it reports capability details.

**Returns:** <code>Promise&lt;<a href="#permissionresult">PermissionResult</a>&gt;</code>

**Since:** 8.0.4

--------------------


### getPluginVersion()

```typescript
getPluginVersion() => Promise<{ version: string; }>
```

Get the native Capacitor plugin version.

**Returns:** <code>Promise&lt;{ version: string; }&gt;</code>

**Since:** 1.0.0

--------------------


### getAlarms()

```typescript
getAlarms() => Promise<{ alarms: AlarmInfo[]; message?: string; }>
```

Get a list of alarms scheduled by this app.
On iOS 26+, returns alarms from AlarmKit. On Android, this is not supported
as the system does not provide an API to query alarms.

**Returns:** <code>Promise&lt;{ alarms: AlarmInfo[]; message?: string; }&gt;</code>

**Since:** 1.1.0

--------------------


### cancelAlarm(...)

```typescript
cancelAlarm(options: { id: string; }) => Promise<NativeActionResult>
```

Cancel a scheduled alarm by its ID.
On iOS 26+, removes the alarm from AlarmKit. On Android/web, returns not supported.

| Param         | Type                         | Description                                 |
| ------------- | ---------------------------- | ------------------------------------------- |
| **`options`** | <code>{ id: string; }</code> | - Options containing the alarm ID to cancel |

**Returns:** <code>Promise&lt;<a href="#nativeactionresult">NativeActionResult</a>&gt;</code>

**Since:** 8.1.0

--------------------


### Interfaces


#### NativeActionResult

Result of a native action.

| Prop          | Type                 | Description                                        |
| ------------- | -------------------- | -------------------------------------------------- |
| **`success`** | <code>boolean</code> | Whether the action was successful                  |
| **`message`** | <code>string</code>  | Optional message with additional information       |
| **`id`**      | <code>string</code>  | Optional alarm ID (returned by createAlarm on iOS) |


#### NativeAlarmCreateOptions

Options for creating a native OS alarm via the platform clock app.

| Prop          | Type                 | Description                                  |
| ------------- | -------------------- | -------------------------------------------- |
| **`hour`**    | <code>number</code>  | Hour of day in 24h format (0-23)             |
| **`minute`**  | <code>number</code>  | Minute of hour (0-59)                        |
| **`label`**   | <code>string</code>  | Optional label for the alarm                 |
| **`skipUi`**  | <code>boolean</code> | Android only: attempt to skip UI if possible |
| **`vibrate`** | <code>boolean</code> | Android only: set alarm to vibrate           |


#### OSInfo

Returned info about current OS and capabilities.

| Prop                                 | Type                 | Description                                                 |
| ------------------------------------ | -------------------- | ----------------------------------------------------------- |
| **`platform`**                       | <code>string</code>  | Platform identifier: 'ios' \| 'android' \| 'web'            |
| **`version`**                        | <code>string</code>  | OS version string                                           |
| **`supportsNativeAlarms`**           | <code>boolean</code> | Whether the platform exposes a native alarm app integration |
| **`supportsScheduledNotifications`** | <code>boolean</code> | Whether scheduling local notifications is supported         |
| **`canScheduleExactAlarms`**         | <code>boolean</code> | Android only: whether exact alarms are allowed              |


#### PermissionResult

Result of a permissions request.

| Prop          | Type                                                             | Description                        |
| ------------- | ---------------------------------------------------------------- | ---------------------------------- |
| **`granted`** | <code>boolean</code>                                             | Overall grant for requested scope  |
| **`details`** | <code><a href="#record">Record</a>&lt;string, boolean&gt;</code> | Optional details by permission key |
| **`message`** | <code>string</code>                                              | Optional human readable diagnostic |


#### AlarmInfo

Information about a scheduled alarm.

| Prop          | Type                 | Description                                                                             |
| ------------- | -------------------- | --------------------------------------------------------------------------------------- |
| **`id`**      | <code>string</code>  | Unique identifier for the alarm                                                         |
| **`hour`**    | <code>number</code>  | Hour of day in 24h format (0-23). May be absent for alarms created outside this plugin. |
| **`minute`**  | <code>number</code>  | Minute of hour (0-59). May be absent for alarms created outside this plugin.            |
| **`label`**   | <code>string</code>  | Optional label for the alarm                                                            |
| **`enabled`** | <code>boolean</code> | Whether the alarm is enabled                                                            |


### Type Aliases


#### Record

Construct a type with a set of properties K of type T

<code>{ [P in K]: T; }</code>

</docgen-api>
