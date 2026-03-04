import { registerPlugin } from '@capacitor/core';

import type { CapgoAlarmPlugin, PermissionResult } from './definitions';

const CapgoAlarm = registerPlugin<CapgoAlarmPlugin>('CapgoAlarm', {
  web: () => import('./web').then((m) => new m.CapgoAlarmWeb()),
});

const missingCheckPermissionsResult: PermissionResult = {
  granted: false,
  message:
    'CapgoAlarm.checkPermissions is not implemented on this platform or native plugin version. Update the native plugin to use this feature.',
};

const nativeCheckPermissions = CapgoAlarm.checkPermissions?.bind(CapgoAlarm);

CapgoAlarm.checkPermissions = (async (): Promise<PermissionResult> => {
  if (!nativeCheckPermissions) {
    return missingCheckPermissionsResult;
  }
  try {
    return await nativeCheckPermissions();
  } catch (error: unknown) {
    if (isUnimplementedError(error)) {
      return missingCheckPermissionsResult;
    }
    throw error;
  }
}) as CapgoAlarmPlugin['checkPermissions'];

function isUnimplementedError(error: unknown): boolean {
  if (!error || typeof error !== 'object') {
    return false;
  }
  const code = (error as { code?: string }).code;
  if (code === 'UNIMPLEMENTED') {
    return true;
  }
  const message = (error as { message?: unknown }).message;
  return typeof message === 'string' && message.toLowerCase().includes('not implemented');
}

export * from './definitions';
export { CapgoAlarm };
