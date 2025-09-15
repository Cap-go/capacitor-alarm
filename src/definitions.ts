/** Options for creating a native OS alarm via the platform clock app. */
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

export interface NativeActionResult {
  success: boolean;
  message?: string;
}

/** Returned info about current OS and capabilities. */
export interface OSInfo {
  /** 'ios' | 'android' | 'web' */
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

/** Result of a permissions request. */
export interface PermissionResult {
  /** Overall grant for requested scope */
  granted: boolean;
  /** Optional details by permission key */
  details?: Record<string, boolean>;
}

export interface CapgoAlarmPlugin {
  /**
   * Create a native OS alarm using the platform clock app.
   * On Android this uses the Alarm Clock intent; on iOS this is not supported.
   */
  createAlarm(options: NativeAlarmCreateOptions): Promise<NativeActionResult>;

  /**
   * Open the platform's native alarm list UI, if available.
   */
  openAlarms(): Promise<NativeActionResult>;

  /**
   * Get information about the OS and capabilities.
   */
  getOSInfo(): Promise<OSInfo>;

  /**
   * Request relevant permissions for alarm usage on the platform.
   * On Android, may route to settings for exact alarms.
   */
  requestPermissions(options?: { exactAlarm?: boolean }): Promise<PermissionResult>;
}
