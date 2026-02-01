/**
 * Options for creating a native OS alarm via the platform clock app.
 *
 * @since 1.0.0
 */
export interface NativeAlarmCreateOptions {
  /** Hour of day in 24h format (0-23) */
  hour: number;
  /** Minute of hour (0-59) */
  minute: number;
  /** Optional label for the alarm */
  label?: string;
  /** Android only: attempt to skip UI if possible */
  skipUi?: boolean;
  /** Android only: set alarm to vibrate */
  vibrate?: boolean;
}

/**
 * Result of a native action.
 *
 * @since 1.0.0
 */
export interface NativeActionResult {
  /** Whether the action was successful */
  success: boolean;
  /** Optional message with additional information */
  message?: string;
}

/**
 * Information about a scheduled alarm.
 *
 * @since 1.1.0
 */
export interface AlarmInfo {
  /** Unique identifier for the alarm */
  id: string;
  /** Hour of day in 24h format (0-23) */
  hour: number;
  /** Minute of hour (0-59) */
  minute: number;
  /** Optional label for the alarm */
  label?: string;
  /** Whether the alarm is enabled */
  enabled?: boolean;
}

/**
 * Returned info about current OS and capabilities.
 *
 * @since 1.0.0
 */
export interface OSInfo {
  /** Platform identifier: 'ios' | 'android' | 'web' */
  platform: string;
  /** OS version string */
  version: string;
  /** Whether the platform exposes a native alarm app integration */
  supportsNativeAlarms: boolean;
  /** Whether scheduling local notifications is supported */
  supportsScheduledNotifications: boolean;
  /** Android only: whether exact alarms are allowed */
  canScheduleExactAlarms?: boolean;
}

/**
 * Result of a permissions request.
 *
 * @since 1.0.0
 */
export interface PermissionResult {
  /** Overall grant for requested scope */
  granted: boolean;
  /** Optional details by permission key */
  details?: Record<string, boolean>;
  /** Optional human readable diagnostic */
  message?: string;
}

/**
 * Capacitor Alarm Plugin interface for managing native OS alarms.
 *
 * @since 1.0.0
 */
export interface CapgoAlarmPlugin {
  /**
   * Create a native OS alarm using the platform clock app.
   * On Android this uses the Alarm Clock intent; on iOS this uses AlarmKit if available (iOS 16+).
   *
   * @param options - Options for creating the alarm
   * @returns Promise that resolves with the action result
   * @throws Error if alarm creation fails or permissions are not granted
   * @since 1.0.0
   * @example
   * ```typescript
   * const result = await CapgoAlarm.createAlarm({
   *   hour: 7,
   *   minute: 30,
   *   label: 'Wake up',
   *   skipUi: false,
   *   vibrate: true
   * });
   * console.log('Alarm created:', result.success);
   * ```
   */
  createAlarm(options: NativeAlarmCreateOptions): Promise<NativeActionResult>;

  /**
   * Open the platform's native alarm list UI, if available.
   *
   * @returns Promise that resolves with the action result
   * @throws Error if opening alarms UI fails
   * @since 1.0.0
   * @example
   * ```typescript
   * const result = await CapgoAlarm.openAlarms();
   * if (result.success) {
   *   console.log('Alarms UI opened');
   * }
   * ```
   */
  openAlarms(): Promise<NativeActionResult>;

  /**
   * Get information about the OS and capabilities.
   *
   * @returns Promise that resolves with OS information
   * @throws Error if getting OS info fails
   * @since 1.0.0
   * @example
   * ```typescript
   * const info = await CapgoAlarm.getOSInfo();
   * console.log('Platform:', info.platform);
   * console.log('Supports native alarms:', info.supportsNativeAlarms);
   * if (info.platform === 'android') {
   *   console.log('Can schedule exact alarms:', info.canScheduleExactAlarms);
   * }
   * ```
   */
  getOSInfo(): Promise<OSInfo>;

  /**
   * Request relevant permissions for alarm usage on the platform.
   * On Android, may route to settings for exact alarms.
   *
   * @param options - Optional parameters for the permission request
   * @returns Promise that resolves with the permission result
   * @throws Error if permission request fails
   * @since 1.0.0
   * @example
   * ```typescript
   * const result = await CapgoAlarm.requestPermissions({ exactAlarm: true });
   * if (result.granted) {
   *   console.log('Permissions granted');
   * } else {
   *   console.log('Permissions denied');
   * }
   * ```
   */
  requestPermissions(options?: { exactAlarm?: boolean }): Promise<PermissionResult>;

  /**
   * Check the current permission state for native alarm access without triggering UI.
   * On iOS this reports AlarmKit readiness; on Android it reports capability details.
   *
   * @returns Promise that resolves with the permission result
   * @throws Error if the native layer fails to respond
   * @since 8.0.4
   * @example
   * ```typescript
   * const status = await CapgoAlarm.checkPermissions();
   * console.log('AlarmKit allowed?', status.details?.alarmKit);
   * ```
   */
  checkPermissions(): Promise<PermissionResult>;

  /**
   * Get the native Capacitor plugin version.
   *
   * @returns Promise that resolves with the plugin version
   * @throws Error if getting the version fails
   * @since 1.0.0
   * @example
   * ```typescript
   * const { version } = await CapgoAlarm.getPluginVersion();
   * console.log('Plugin version:', version);
   * ```
   */
  getPluginVersion(): Promise<{ version: string }>;

  /**
   * Get a list of alarms scheduled by this app.
   * On iOS 26+, returns alarms from AlarmKit. On Android, this is not supported
   * as the system does not provide an API to query alarms.
   *
   * @returns Promise that resolves with an array of alarm information
   * @since 1.1.0
   * @example
   * ```typescript
   * const { alarms } = await CapgoAlarm.getAlarms();
   * console.log('Scheduled alarms:', alarms);
   * alarms.forEach(alarm => {
   *   console.log(`Alarm ${alarm.id}: ${alarm.hour}:${alarm.minute} - ${alarm.label}`);
   * });
   * ```
   */
  getAlarms(): Promise<{ alarms: AlarmInfo[]; message?: string }>;

  /**
   * Cancel a scheduled alarm by its ID.
   * On iOS 26+, removes the alarm from AlarmKit. On Android/web, returns not supported.
   *
   * @param options - Options containing the alarm ID to cancel
   * @returns Promise resolving with the result of the action
   * @since 8.1.0
   * @example
   * ```typescript
   * const result = await CapgoAlarm.cancelAlarm({ id: 'alarm-uuid-here' });
   * if (result.success) {
   *   console.log('Alarm cancelled');
   * }
   * ```
   */
  cancelAlarm(options: { id: string }): Promise<NativeActionResult>;
}
