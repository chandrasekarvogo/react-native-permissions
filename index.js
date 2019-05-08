// @flow

import { NativeModules, PermissionsAndroid, Platform } from 'react-native';
const { RNPermissions } = NativeModules;

const ANDROID = Object.freeze({
  READ_CALENDAR: 'android.permission.READ_CALENDAR',
  WRITE_CALENDAR: 'android.permission.WRITE_CALENDAR',
  CAMERA: 'android.permission.CAMERA',
  READ_CONTACTS: 'android.permission.READ_CONTACTS',
  WRITE_CONTACTS: 'android.permission.WRITE_CONTACTS',
  GET_ACCOUNTS: 'android.permission.GET_ACCOUNTS',
  ACCESS_FINE_LOCATION: 'android.permission.ACCESS_FINE_LOCATION',
  ACCESS_COARSE_LOCATION: 'android.permission.ACCESS_COARSE_LOCATION',
  RECORD_AUDIO: 'android.permission.RECORD_AUDIO',
  READ_PHONE_STATE: 'android.permission.READ_PHONE_STATE',
  CALL_PHONE: 'android.permission.CALL_PHONE',
  READ_CALL_LOG: 'android.permission.READ_CALL_LOG',
  WRITE_CALL_LOG: 'android.permission.WRITE_CALL_LOG',
  ADD_VOICEMAIL: 'com.android.voicemail.permission.ADD_VOICEMAIL',
  USE_SIP: 'android.permission.USE_SIP',
  PROCESS_OUTGOING_CALLS: 'android.permission.PROCESS_OUTGOING_CALLS',
  BODY_SENSORS: 'android.permission.BODY_SENSORS',
  SEND_SMS: 'android.permission.SEND_SMS',
  RECEIVE_SMS: 'android.permission.RECEIVE_SMS',
  READ_SMS: 'android.permission.READ_SMS',
  RECEIVE_WAP_PUSH: 'android.permission.RECEIVE_WAP_PUSH',
  RECEIVE_MMS: 'android.permission.RECEIVE_MMS',
  READ_EXTERNAL_STORAGE: 'android.permission.READ_EXTERNAL_STORAGE',
  WRITE_EXTERNAL_STORAGE: 'android.permission.WRITE_EXTERNAL_STORAGE',
  // Dangerous permissions not included in PermissionsAndroid
  // They might be unavailable in the current OS version
  ANSWER_PHONE_CALLS: 'android.permission.ANSWER_PHONE_CALLS',
  ACCEPT_HANDOVER: 'android.permission.ACCEPT_HANDOVER',
  READ_PHONE_NUMBERS: 'android.permission.READ_PHONE_NUMBERS',
});

const IOS = Object.freeze({
  BLUETOOTH_PERIPHERAL: 'ios.permission.BLUETOOTH_PERIPHERAL',
  CALENDARS: 'ios.permission.CALENDARS',
  CAMERA: 'ios.permission.CAMERA',
  CONTACTS: 'ios.permission.CONTACTS',
  FACE_ID: 'ios.permission.FACE_ID',
  LOCATION_ALWAYS: 'ios.permission.LOCATION_ALWAYS',
  LOCATION_WHEN_IN_USE: 'ios.permission.LOCATION_WHEN_IN_USE',
  MEDIA_LIBRARY: 'ios.permission.MEDIA_LIBRARY',
  MICROPHONE: 'ios.permission.MICROPHONE',
  MOTION: 'ios.permission.MOTION',
  NOTIFICATIONS: 'ios.permission.NOTIFICATIONS',
  PHOTO_LIBRARY: 'ios.permission.PHOTO_LIBRARY',
  REMINDERS: 'ios.permission.REMINDERS',
  SIRI: 'ios.permission.SIRI',
  SPEECH_RECOGNITION: 'ios.permission.SPEECH_RECOGNITION',
  STOREKIT: 'ios.permission.STOREKIT',
});

export const PERMISSIONS = { ANDROID, IOS };

export const RESULTS = Object.freeze({
  GRANTED: 'granted',
  DENIED: 'denied',
  NEVER_ASK_AGAIN: 'never_ask_again',
  UNAVAILABLE: 'unavailable',
});

export type PermissionStatus = $Values<typeof RESULTS>;

export type Rationale = {|
  title: string,
  message: string,
  buttonPositive?: string,
  buttonNegative?: string,
  buttonNeutral?: string,
|};

export type NotificationOption =
  | 'badge'
  | 'sound'
  | 'alert'
  | 'carPlay'
  | 'criticalAlert'
  | 'provisional';

export type RequestConfig = {
  notificationOptions?: NotificationOption[],
  rationale?: Rationale,
};

const platformPermissions = Object.values(
  Platform.OS === 'ios' ? IOS : ANDROID,
);

function assertPermission(permission: string) {
  if (!platformPermissions.includes(permission)) {
    let message = `Invalid ${Platform.OS} permission "${permission}".`;
    message += ' Must be one of:\n\n• ';
    message += platformPermissions.join('\n• ');

    throw new Error(message);
  }
}

function extractUnavailables(permissions: string[]) {
  return Promise.all(
    permissions.map(p => RNPermissions.isPermissionAvailable(p)),
  ).then(availabilities =>
    availabilities.reduce((acc, available, i) => {
      if (!available) {
        acc[permissions[i]] = RESULTS.UNAVAILABLE;
      }
      return acc;
    }, {}),
  );
}

// RNPermissions.check(IOS.CAMERA).then(p => console.log(p));

async function internalCheck(permission: string): Promise<PermissionStatus> {
  if (Platform.OS !== 'android') {
    return RNPermissions.check(permission);
  }

  if (!(await RNPermissions.isPermissionAvailable(permission))) {
    return RESULTS.UNAVAILABLE;
  }
  if (await PermissionsAndroid.check(permission)) {
    return RESULTS.GRANTED;
  }
  if (!(await RNPermissions.hasAlreadyBeenRequested(permission))) {
    return RESULTS.DENIED;
  }

  return (await NativeModules.PermissionsAndroid.shouldShowRequestPermissionRationale(
    permission,
  ))
    ? RESULTS.DENIED
    : RESULTS.NEVER_ASK_AGAIN;
}

async function internalRequest(
  permission: string,
  config: RequestConfig = {},
): Promise<PermissionStatus> {
  const { notificationOptions, rationale } = config;

  if (Platform.OS !== 'android') {
    return RNPermissions.request(permission, { notificationOptions });
  }

  if (!(await RNPermissions.isPermissionAvailable(permission))) {
    return RESULTS.UNAVAILABLE;
  }

  const status = await PermissionsAndroid.request(permission, rationale);
  return RNPermissions.setPermissionAsRequested(permission).then(() => status);
}

async function internalCheckMultiple(
  permissions: string[],
): Promise<{ [permission: string]: PermissionStatus }> {
  let result = {};
  let availables = permissions;

  if (Platform.OS === 'android') {
    const unavailables = await extractUnavailables(permissions);
    const unavailablesKeys = Object.keys(result);
    result = unavailables;
    availables = permissions.filter(p => !unavailablesKeys.includes(p));
  }

  return Promise.all(availables.map(p => internalCheck(p)))
    .then(statuses =>
      statuses.reduce((acc, status, i) => {
        acc[availables[i]] = status;
        return acc;
      }, {}),
    )
    .then(statuses => ({ ...result, ...statuses }));
}

async function internalRequestMultiple(
  permissions: string[],
): Promise<{ [permission: string]: PermissionStatus }> {
  if (Platform.OS !== 'android') {
    const result = {};

    for (let i = 0; i < permissions.length; i++) {
      const permission = permissions[i];
      // ask once at the time on iOS
      result[permission] = await internalRequest(permission);
    }

    return result;
  } else {
    const unavailables = await extractUnavailables(permissions);
    const unavailablesKeys = Object.keys(unavailables);

    const availables = await PermissionsAndroid.requestMultiple(
      permissions.filter(p => !unavailablesKeys.includes(p)),
    );

    return Promise.all(
      permissions.map(p => RNPermissions.setPermissionAsRequested(p)),
    ).then(() => ({
      ...availables,
      ...unavailables,
    }));
  }
}

export function openSettings(): Promise<void> {
  return RNPermissions.openSettings().then(() => {});
}

export function check(permission: string): Promise<PermissionStatus> {
  // $FlowFixMe
  if (__DEV__) {
    assertPermission(permission);
  }
  return internalCheck(permission);
}

export function checkMultiple(
  permissions: string[],
): Promise<{ [permission: string]: PermissionStatus }> {
  // $FlowFixMe
  if (__DEV__) {
    permissions.forEach(assertPermission);
  }
  return internalCheckMultiple(permissions);
}

export function request(
  permission: string,
  config: RequestConfig = {},
): Promise<PermissionStatus> {
  // $FlowFixMe
  if (__DEV__) {
    assertPermission(permission);
  }
  return internalRequest(permission, config);
}

export function requestMultiple(
  permissions: string[],
): Promise<{ [permission: string]: PermissionStatus }> {
  // $FlowFixMe
  if (__DEV__) {
    permissions.forEach(assertPermission);
  }
  return internalRequestMultiple(permissions);
}
