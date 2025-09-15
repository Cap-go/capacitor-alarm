import { WebPlugin } from '@capacitor/core';

import type { CapgoAlarmPlugin } from './definitions';

export class CapgoAlarmWeb extends WebPlugin implements CapgoAlarmPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
