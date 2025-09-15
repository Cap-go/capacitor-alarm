import { WebPlugin } from '@capacitor/core';

import type {
  CapgoAlarmPlugin,
  NativeAlarmCreateOptions,
  NativeActionResult,
  OSInfo,
  PermissionResult,
} from './definitions';

export class CapgoAlarmWeb extends WebPlugin implements CapgoAlarmPlugin {
  async createAlarm(_options: NativeAlarmCreateOptions): Promise<NativeActionResult> {
    return { success: false, message: 'Native alarm not supported on web' };
  }

  async openAlarms(): Promise<NativeActionResult> {
    return { success: false, message: 'Native alarm UI not available on web' };
  }

  async getOSInfo(): Promise<OSInfo> {
    return {
      platform: 'web',
      version: navigator.userAgent,
      supportsNativeAlarms: false,
      supportsScheduledNotifications: false,
    };
  }

  async requestPermissions(_options?: { exactAlarm?: boolean }): Promise<PermissionResult> {
    return { granted: true };
  }
}
