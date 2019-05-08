# ☝🏼 React Native Permissions

[![npm version](https://badge.fury.io/js/react-native-permissions.svg)](https://badge.fury.io/js/react-native-permissions)
[![npm](https://img.shields.io/npm/dt/react-native-permissions.svg)](https://www.npmjs.org/package/react-native-permissions)
![Platform - Android and iOS](https://img.shields.io/badge/platform-Android%20%7C%20iOS-yellow.svg)
![MIT](https://img.shields.io/dub/l/vibe-d.svg)
[![styled with prettier](https://img.shields.io/badge/styled_with-prettier-ff69b4.svg)](https://github.com/prettier/prettier)

Check and request user permissions in React Native

### ⚠️  Branch "master" is a WIP of version 2.0.0

## Support

| version | react-native version |
| ------- | -------------------- |
| 2.0.0+  | 0.59.5+              |
| 1.1.1   | 0.40.0 - 0.52.2      |

## Setup

```bash
$ npm install --save react-native-permissions
# --- or ---
$ yarn add react-native-permissions
```

### iOS

To allow installation of the needed permission handlers for your project (and only them), `react-native-permissions` uses CocoaPods. Update the following line with your path to `node_modules/` and add it to your podfile:

```ruby
target 'YourAwesomeProject' do

  # …

  pod 'RNPermissions', :path => '../node_modules/react-native-permissions', :subspecs => [
    'Core',
    ## Uncomment wanted permissions
    # 'BluetoothPeripheral',
    # 'Calendars',
    # 'Camera',
    # 'Contacts',
    # 'FaceID',
    # 'LocationAlways',
    # 'LocationWhenInUse',
    # 'MediaLibrary',
    # 'Microphone',
    # 'Motion',
    # 'Notifications',
    # 'PhotoLibrary',
    # 'Reminders',
    # 'Siri',
    # 'SpeechRecognition',
    # 'StoreKit',
  ]

end
```

### Android

1.  Add the following lines to `android/settings.gradle`:

```gradle
include ':react-native-permissions'
project(':react-native-permissions').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-permissions/android')
```

2.  Add the compile line to the dependencies in `android/app/build.gradle`:

```gradle
dependencies {
  // ...
  implementation project(':react-native-permissions')
}
```

3.  Add the import and link the package in `MainApplication.java`:

```java
import com.reactnativecommunity.rnpermissions.RNPermissionsPackage; // <-- Add the import

public class MainApplication extends Application implements ReactApplication {

  // …

  @Override
  protected List<ReactPackage> getPackages() {
    return Arrays.<ReactPackage>asList(
      new MainReactPackage(),
      // …
      new RNPermissionsPackage() // <-- Add it to the packages list
    );
  }

  // …
}
```

_📌 Don't forget to add permissions to `AndroidManifest.xml` for android and
`Info.plist` for iOS._

## API

### Permissions statuses

Promises resolve into one of these statuses:

| Return value              | Notes                                                             |
| ------------------------- | ----------------------------------------------------------------- |
| `RESULTS.UNAVAILABLE`     | This feature is not available (on this device / in this context)  |
| `RESULTS.GRANTED`         | The permission is granted                                         |
| `RESULTS.DENIED`          | The permission has not been requested / is denied but requestable |
| `RESULTS.NEVER_ASK_AGAIN` | The permission is denied and not requestable anymore              |

### Supported permissions

```js
import { PERMISSIONS } from 'react-native-permissions';

// Android permissions

// similar to PermissionsAndroid
PERMISSIONS.ANDROID.READ_CALENDAR;
PERMISSIONS.ANDROID.WRITE_CALENDAR;
PERMISSIONS.ANDROID.CAMERA;
PERMISSIONS.ANDROID.READ_CONTACTS;
PERMISSIONS.ANDROID.WRITE_CONTACTS;
PERMISSIONS.ANDROID.GET_ACCOUNTS;
PERMISSIONS.ANDROID.ACCESS_FINE_LOCATION;
PERMISSIONS.ANDROID.ACCESS_COARSE_LOCATION;
PERMISSIONS.ANDROID.RECORD_AUDIO;
PERMISSIONS.ANDROID.READ_PHONE_STATE;
PERMISSIONS.ANDROID.CALL_PHONE;
PERMISSIONS.ANDROID.READ_CALL_LOG;
PERMISSIONS.ANDROID.WRITE_CALL_LOG;
PERMISSIONS.ANDROID.ADD_VOICEMAIL;
PERMISSIONS.ANDROID.USE_SIP;
PERMISSIONS.ANDROID.PROCESS_OUTGOING_CALLS;
PERMISSIONS.ANDROID.BODY_SENSORS;
PERMISSIONS.ANDROID.SEND_SMS;
PERMISSIONS.ANDROID.RECEIVE_SMS;
PERMISSIONS.ANDROID.READ_SMS;
PERMISSIONS.ANDROID.RECEIVE_WAP_PUSH;
PERMISSIONS.ANDROID.RECEIVE_MMS;
PERMISSIONS.ANDROID.READ_EXTERNAL_STORAGE;
PERMISSIONS.ANDROID.WRITE_EXTERNAL_STORAGE;
// exclusives ones
PERMISSIONS.ANDROID.ANSWER_PHONE_CALLS;
PERMISSIONS.ANDROID.ACCEPT_HANDOVER;
PERMISSIONS.ANDROID.READ_PHONE_NUMBERS;

// iOS permissions

PERMISSIONS.IOS.BLUETOOTH_PERIPHERAL;
PERMISSIONS.IOS.CALENDARS;
PERMISSIONS.IOS.CAMERA;
PERMISSIONS.IOS.CONTACTS;
PERMISSIONS.IOS.FACE_ID;
PERMISSIONS.IOS.LOCATION_ALWAYS;
PERMISSIONS.IOS.LOCATION_WHEN_IN_USE;
PERMISSIONS.IOS.MEDIA_LIBRARY;
PERMISSIONS.IOS.MICROPHONE;
PERMISSIONS.IOS.MOTION;
PERMISSIONS.IOS.NOTIFICATIONS;
PERMISSIONS.IOS.PHOTO_LIBRARY;
PERMISSIONS.IOS.REMINDERS;
PERMISSIONS.IOS.SIRI;
PERMISSIONS.IOS.SPEECH_RECOGNITION;
PERMISSIONS.IOS.STOREKIT;
```

### Methods

_types used in usage examples_

```ts
type Permission =
  | 'android.permission.READ_CALENDAR'
  | 'android.permission.WRITE_CALENDAR'
  // …
  | 'ios.permission.SPEECH_RECOGNITION'
  | 'ios.permission.STOREKIT';

type PermissionStatus =
  | 'granted'
  | 'denied'
  | 'never_ask_again'
  | 'unavailable';
```

#### check()

Check one permission status.

#### Method type

```ts
function check(permission: Permission): Promise<PermissionStatus>;
```

#### Usage example

```js
import { check, PERMISSIONS, RESULTS } from 'react-native-permissions';

check(PERMISSIONS.IOS.LOCATION_ALWAYS)
  .then(result => {
    switch (result) {
      case RESULTS.UNAVAILABLE:
        console.log('the feature is not available');
        break;
      case RESULTS.GRANTED:
        console.log('permission is granted');
        break;
      case RESULTS.DENIED:
        console.log('permission is denied and / or requestable');
        break;
      case RESULTS.NEVER_ASK_AGAIN:
        console.log('permission is denied and not requestable');
        break;
    }
  })
  .catch(error => {
    // …
  });
```

---

#### checkMultiple()

Check multiples permissions.

#### Method type

```ts
function checkMultiple(
  permissions: Permission[],
): Promise<{ [permission: Permission]: PermissionStatus }>;
```

#### Usage example

```js
import { checkMultiple, PERMISSIONS } from 'react-native-permissions';

checkMultiple([
  PERMISSIONS.IOS.LOCATION_ALWAYS,
  PERMISSIONS.IOS.MEDIA_LIBRARY,
]).then(results => {
  // results.LOCATION_ALWAYS
  // results.MEDIA_LIBRARY
});
```

---

#### request()

Request one permission.

#### Method type

```ts
type NotificationOption =
  | 'badge'
  | 'sound'
  | 'alert'
  | 'carPlay'
  | 'criticalAlert'
  | 'provisional';

type Rationale = {
  title: string;
  message: string;
  buttonPositive?: string;
  buttonNegative?: string;
  buttonNeutral?: string;
};

function request(
  permission: Permission,
  config: {
    notificationOptions?: NotificationOption[];
    rationale?: Rationale;
  } = {},
): Promise<PermissionStatus>;
```

#### Usage example

```js
import { request, PERMISSIONS } from 'react-native-permissions';

request(PERMISSIONS.IOS.LOCATION_ALWAYS).then(result => {
  // …
});
```

---

#### requestMultiple()

Request multiples permissions.

#### Method type

```ts
function requestMultiple(
  permissions: Permission[],
): Promise<{ [permission: Permission]: PermissionStatus }>;
```

#### Usage example

```js
import { requestMultiple, PERMISSIONS } from 'react-native-permissions';

requestMultiple([
  PERMISSIONS.IOS.LOCATION_ALWAYS,
  PERMISSIONS.IOS.MEDIA_LIBRARY,
]).then(results => {
  // results.LOCATION_ALWAYS
  // results.MEDIA_LIBRARY
});
```

---

#### openSettings()

Open application settings.

#### Method type

```ts
function openSettings(): Promise<void>;
```

#### Usage example

```js
import { openSettings } from 'react-native-permissions';

openSettings().catch(() => console.warn('cannot open settings'));
```

## 🍎  iOS Notes

- If `notificationOptions` config array is omitted on `NOTIFICATIONS` request, it will request `alert`, `badge` and `sound`.
