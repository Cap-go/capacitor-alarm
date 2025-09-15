export interface CapgoAlarmPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
