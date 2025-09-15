import { registerPlugin } from '@capacitor/core';

import type { CapgoAlarmPlugin } from './definitions';

const CapgoAlarm = registerPlugin<CapgoAlarmPlugin>('CapgoAlarm', {
  web: () => import('./web').then((m) => new m.CapgoAlarmWeb()),
});

export * from './definitions';
export { CapgoAlarm };
