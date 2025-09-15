# @capgo/capacitor-alarm
 <a href="https://capgo.app/"><img src='https://raw.githubusercontent.com/Cap-go/capgo/main/assets/capgo_banner.png' alt='Capgo - Instant updates for capacitor'/></a>

<div align="center">
  <h2><a href="https://capgo.app/?ref=plugin"> ➡️ Get Instant updates for your App with Capgo</a></h2>
  <h2><a href="https://capgo.app/consulting/?ref=plugin"> Missing a feature? We’ll build the plugin for you 💪</a></h2>
</div>

Manage native alarm Capacitor plugin

## Install

```bash
npm install @capgo/capacitor-alarm
npx cap sync
```

## Requirements

- iOS: iOS 26+ only. This plugin relies on `AlarmKit` APIs and will report unsupported on earlier versions or when the framework is unavailable.
- Android: Uses `AlarmClock` intents; behavior depends on the default Clock app and OEM policies.

Note: This plugin only exposes native alarm actions (create/open). It does not implement any custom in-app alarm scheduling/CRUD.

## API

<docgen-index>

* [`createAlarm(...)`](#createalarm)
* [`openAlarms()`](#openalarms)
* [`getOSInfo()`](#getosinfo)
* [`requestPermissions(...)`](#requestpermissions)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### createAlarm(...)

```typescript
createAlarm(options: NativeAlarmCreateOptions) => Promise<NativeActionResult>
```

Create a native OS alarm using the platform clock app.
On Android this uses the Alarm Clock intent; on iOS this is not supported.

| Param         | Type                                                                          |
| ------------- | ----------------------------------------------------------------------------- |
| **`options`** | <code><a href="#nativealarmcreateoptions">NativeAlarmCreateOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#nativeactionresult">NativeActionResult</a>&gt;</code>

--------------------


### openAlarms()

```typescript
openAlarms() => Promise<NativeActionResult>
```

Open the platform's native alarm list UI, if available.

**Returns:** <code>Promise&lt;<a href="#nativeactionresult">NativeActionResult</a>&gt;</code>

--------------------


### getOSInfo()

```typescript
getOSInfo() => Promise<OSInfo>
```

Get information about the OS and capabilities.

**Returns:** <code>Promise&lt;<a href="#osinfo">OSInfo</a>&gt;</code>

--------------------


### requestPermissions(...)

```typescript
requestPermissions(options?: { exactAlarm?: boolean | undefined; } | undefined) => Promise<PermissionResult>
```

Request relevant permissions for alarm usage on the platform.
On Android, may route to settings for exact alarms.

| Param         | Type                                   |
| ------------- | -------------------------------------- |
| **`options`** | <code>{ exactAlarm?: boolean; }</code> |

**Returns:** <code>Promise&lt;<a href="#permissionresult">PermissionResult</a>&gt;</code>

--------------------


### Interfaces


#### NativeActionResult

| Prop          | Type                 |
| ------------- | -------------------- |
| **`success`** | <code>boolean</code> |
| **`message`** | <code>string</code>  |


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
| **`platform`**                       | <code>string</code>  | 'ios' \| 'android' \| 'web'                                 |
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


### Type Aliases


#### Record

Construct a type with a set of properties K of type T

<code>{ [P in K]: T; }</code>

</docgen-api>
