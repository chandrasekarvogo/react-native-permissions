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
  BLUETOOTH_PERIPHERAL: 'bluetooth-peripheral',
  CALENDARS: 'calendars',
  CAMERA: 'camera',
  CONTACTS: 'contacts',
  FACE_ID: 'face-id',
  LOCATION_ALWAYS: 'location-always',
  LOCATION_WHEN_IN_USE: 'location-when-in-use',
  MEDIA_LIBRARY: 'media-library',
  MICROPHONE: 'microphone',
  MOTION: 'motion',
  NOTIFICATIONS: 'notifications',
  PHOTO_LIBRARY: 'photo-library',
  REMINDERS: 'reminders',
  SIRI: 'siri',
  SPEECH_RECOGNITION: 'speech-recognition',
  STOREKIT: 'storekit',
});

export const PERMISSIONS = Object.freeze({ ANDROID, IOS });

export const RESULTS = Object.freeze({
  UNAVAILABLE: 'unavailable', // feature not available on OS / device or restricted by parental control
  DENIED: 'denied', // denied but requestable
  GRANTED: 'granted',
  BLOCKED: 'blocked', // // iOS & android: denied and not requestable (should open settings)
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
    : RESULTS.BLOCKED;
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

export const getRequested = RNPermissions.getRequested;

export function check(permission: string): Promise<PermissionStatus> {
  // $FlowFixMe
  __DEV__ && assertPermission(permission);
  return internalCheck(permission);
}

export function checkMultiple(
  permissions: string[],
): Promise<{ [permission: string]: PermissionStatus }> {
  // $FlowFixMe
  __DEV__ && permissions.forEach(assertPermission);
  return internalCheckMultiple(permissions);
}

export function request(
  permission: string,
  config: RequestConfig = {},
): Promise<PermissionStatus> {
  // $FlowFixMe
  __DEV__ && assertPermission(permission);
  return internalRequest(permission, config);
}

export function requestMultiple(
  permissions: string[],
): Promise<{ [permission: string]: PermissionStatus }> {
  // $FlowFixMe
  __DEV__ && permissions.forEach(assertPermission);
  return internalRequestMultiple(permissions);
}
