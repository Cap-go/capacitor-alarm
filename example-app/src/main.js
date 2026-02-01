
import './style.css';
import { CapgoAlarm } from '@capgo/capacitor-alarm';

const plugin = CapgoAlarm;
const state = {};


const actions = [
{
              id: 'get-os-info',
              label: 'Get OS info',
              description: 'Calls getOSInfo() to discover the current platform capabilities.',
              inputs: [],
              run: async (values) => {
                const info = await plugin.getOSInfo();
return info;
              },
            },
{
              id: 'request-permissions',
              label: 'Request permissions',
              description: 'Requests alarm-related permissions on supported platforms.',
              inputs: [{ name: 'exactAlarm', label: 'Request exact alarm permission (Android)', type: 'checkbox', value: true }],
              run: async (values) => {
                const result = await plugin.requestPermissions({ exactAlarm: Boolean(values.exactAlarm) });
return result;
              },
            },
{
              id: 'create-alarm',
              label: 'Create alarm',
              description: 'Attempts to schedule a native alarm. Works on platforms that expose alarm APIs. Returns alarm ID on iOS.',
              inputs: [{ name: 'hour', label: 'Hour (0-23)', type: 'number', value: 7 }, { name: 'minute', label: 'Minute (0-59)', type: 'number', value: 30 }, { name: 'label', label: 'Label', type: 'text', value: 'Wake up' }, { name: 'skipUi', label: 'Skip UI (Android)', type: 'checkbox', value: false }, { name: 'vibrate', label: 'Vibrate (Android)', type: 'checkbox', value: true }],
              run: async (values) => {
                const hour = Number.isNaN(Number(values.hour)) ? 0 : Number(values.hour);
                const minute = Number.isNaN(Number(values.minute)) ? 0 : Number(values.minute);
                const result = await plugin.createAlarm({
                  hour,
                  minute,
                  label: values.label || undefined,
                  skipUi: Boolean(values.skipUi),
                  vibrate: Boolean(values.vibrate),
                });
                // Store last created alarm ID for easy cancel testing
                if (result.id) {
                  state.lastAlarmId = result.id;
                }
                return result;
              },
            },
{
  id: 'open-alarms',
  label: 'Open system alarm list',
  description: 'Requests the system alarm list if the platform supports it.',
  inputs: [],
  run: async (values) => {
    return await plugin.openAlarms();
  },
},
{
  id: 'get-alarms',
  label: 'Get scheduled alarms',
  description: 'Retrieves a list of alarms scheduled by this app. Works on iOS 26+ with AlarmKit.',
  inputs: [],
  run: async (values) => {
    const result = await plugin.getAlarms();
    return result;
  },
},
{
  id: 'cancel-alarm',
  label: 'Cancel alarm',
  description: 'Cancels a scheduled alarm by ID. On iOS 26+, removes the alarm from AlarmKit.',
  inputs: [{ name: 'id', label: 'Alarm ID (UUID)', type: 'text', value: '' }],
  run: async (values) => {
    // Use provided ID or fall back to last created alarm
    const alarmId = values.id || state.lastAlarmId;
    if (!alarmId) {
      return { success: false, message: 'No alarm ID provided. Create an alarm first or enter an ID.' };
    }
    const result = await plugin.cancelAlarm({ id: alarmId });
    if (result.success && alarmId === state.lastAlarmId) {
      state.lastAlarmId = null;
    }
    return result;
  },
},
{
  id: 'check-permissions',
  label: 'Check permissions',
  description: 'Checks current permission state for alarm access without triggering UI.',
  inputs: [],
  run: async (values) => {
    const result = await plugin.checkPermissions();
    return result;
  },
},
{
  id: 'demo-metadata-persistence',
  label: 'Demo: Metadata persistence',
  description: 'Demonstrates the full alarm lifecycle: create → get (with metadata) → cancel → verify removal.',
  inputs: [
    { name: 'hour', label: 'Hour (0-23)', type: 'number', value: 8 },
    { name: 'minute', label: 'Minute (0-59)', type: 'number', value: 0 },
    { name: 'label', label: 'Label', type: 'text', value: 'Test Alarm' }
  ],
  run: async (values) => {
    const steps = [];
    const hour = Number.isNaN(Number(values.hour)) ? 8 : Number(values.hour);
    const minute = Number.isNaN(Number(values.minute)) ? 0 : Number(values.minute);
    const label = values.label || 'Test Alarm';

    // Step 1: Create alarm
    steps.push('=== Step 1: Create Alarm ===');
    const createResult = await plugin.createAlarm({ hour, minute, label });
    steps.push(`Created: ${JSON.stringify(createResult, null, 2)}`);

    if (!createResult.success || !createResult.id) {
      steps.push('ERROR: Failed to create alarm or no ID returned.');
      steps.push('Tip: Run "Request permissions" first, and ensure iOS 26+ simulator.');
      return steps.join('\n\n');
    }

    const alarmId = createResult.id;
    steps.push(`Alarm ID: ${alarmId}`);

    // Step 2: Get alarms to verify metadata is stored
    steps.push('\n=== Step 2: Get Alarms (verify metadata) ===');
    const getResult = await plugin.getAlarms();
    steps.push(`Alarms: ${JSON.stringify(getResult, null, 2)}`);

    const foundAlarm = getResult.alarms?.find(a => a.id === alarmId);
    if (foundAlarm) {
      steps.push(`✓ Found alarm with metadata:`);
      steps.push(`  - hour: ${foundAlarm.hour}`);
      steps.push(`  - minute: ${foundAlarm.minute}`);
      steps.push(`  - label: ${foundAlarm.label}`);
      steps.push(`  - enabled: ${foundAlarm.enabled}`);
    } else {
      steps.push('⚠ Alarm not found in list');
    }

    // Step 3: Cancel the alarm
    steps.push('\n=== Step 3: Cancel Alarm ===');
    const cancelResult = await plugin.cancelAlarm({ id: alarmId });
    steps.push(`Cancel result: ${JSON.stringify(cancelResult, null, 2)}`);

    // Step 4: Verify alarm is removed
    steps.push('\n=== Step 4: Verify Removal ===');
    const verifyResult = await plugin.getAlarms();
    const stillExists = verifyResult.alarms?.find(a => a.id === alarmId);
    if (stillExists) {
      steps.push('⚠ Alarm still exists (unexpected)');
    } else {
      steps.push('✓ Alarm successfully removed');
    }
    steps.push(`Remaining alarms: ${verifyResult.alarms?.length || 0}`);

    return steps.join('\n');
  },
}
];

const actionSelect = document.getElementById('action-select');
const formContainer = document.getElementById('action-form');
const descriptionBox = document.getElementById('action-description');
const runButton = document.getElementById('run-action');
const output = document.getElementById('plugin-output');

function buildForm(action) {
  formContainer.innerHTML = '';
  if (!action.inputs || !action.inputs.length) {
    const note = document.createElement('p');
    note.className = 'no-input-note';
    note.textContent = 'This action does not require any inputs.';
    formContainer.appendChild(note);
    return;
  }
  action.inputs.forEach((input) => {
    const fieldWrapper = document.createElement('div');
    fieldWrapper.className = input.type === 'checkbox' ? 'form-field inline' : 'form-field';

    const label = document.createElement('label');
    label.textContent = input.label;
    label.htmlFor = `field-${input.name}`;

    let field;
    switch (input.type) {
      case 'textarea': {
        field = document.createElement('textarea');
        field.rows = input.rows || 4;
        break;
      }
      case 'select': {
        field = document.createElement('select');
        (input.options || []).forEach((option) => {
          const opt = document.createElement('option');
          opt.value = option.value;
          opt.textContent = option.label;
          if (input.value !== undefined && option.value === input.value) {
            opt.selected = true;
          }
          field.appendChild(opt);
        });
        break;
      }
      case 'checkbox': {
        field = document.createElement('input');
        field.type = 'checkbox';
        field.checked = Boolean(input.value);
        break;
      }
      case 'number': {
        field = document.createElement('input');
        field.type = 'number';
        if (input.value !== undefined && input.value !== null) {
          field.value = String(input.value);
        }
        break;
      }
      default: {
        field = document.createElement('input');
        field.type = 'text';
        if (input.value !== undefined && input.value !== null) {
          field.value = String(input.value);
        }
      }
    }

    field.id = `field-${input.name}`;
    field.name = input.name;
    field.dataset.type = input.type || 'text';

    if (input.placeholder && input.type !== 'checkbox') {
      field.placeholder = input.placeholder;
    }

    if (input.type === 'checkbox') {
      fieldWrapper.appendChild(field);
      fieldWrapper.appendChild(label);
    } else {
      fieldWrapper.appendChild(label);
      fieldWrapper.appendChild(field);
    }

    formContainer.appendChild(fieldWrapper);
  });
}

function getFormValues(action) {
  const values = {};
  (action.inputs || []).forEach((input) => {
    const field = document.getElementById(`field-${input.name}`);
    if (!field) return;
    switch (input.type) {
      case 'number': {
        values[input.name] = field.value === '' ? null : Number(field.value);
        break;
      }
      case 'checkbox': {
        values[input.name] = field.checked;
        break;
      }
      default: {
        values[input.name] = field.value;
      }
    }
  });
  return values;
}

function setAction(action) {
  descriptionBox.textContent = action.description || '';
  buildForm(action);
  output.textContent = 'Ready to run the selected action.';
}

function populateActions() {
  actionSelect.innerHTML = '';
  actions.forEach((action) => {
    const option = document.createElement('option');
    option.value = action.id;
    option.textContent = action.label;
    actionSelect.appendChild(option);
  });
  setAction(actions[0]);
}

actionSelect.addEventListener('change', () => {
  const action = actions.find((item) => item.id === actionSelect.value);
  if (action) {
    setAction(action);
  }
});

runButton.addEventListener('click', async () => {
  const action = actions.find((item) => item.id === actionSelect.value);
  if (!action) return;
  const values = getFormValues(action);
  try {
    const result = await action.run(values);
    if (result === undefined) {
      output.textContent = 'Action completed.';
    } else if (typeof result === 'string') {
      output.textContent = result;
    } else {
      output.textContent = JSON.stringify(result, null, 2);
    }
  } catch (error) {
    output.textContent = `Error: ${error?.message ?? error}`;
  }
});

populateActions();
